# Casbin Authorization Migration Design Document

## Document Information

| Field | Value |
|-------|-------|
| **Title** | Casbin Authorization Migration Architecture |
| **Version** | 1.0 |
| **Status** | Draft |
| **Date** | 2025-12-17 |

---

## 1. Executive Summary

Migrate from scattered middleware/handler authorization to unified **Casbin policy-based authorization**. Consolidates:
- System-level RBAC (`admin`, `user`)
- Group-level roles (`owner`, `moderator`, `member`)
- Resource-level ABAC (ownership, status, shared access)

---

## 2. Casbin Model Design

### Model Configuration (`model.conf`)

```ini
[request_definition]
r = sub, dom, obj, act, attrs

[policy_definition]
p = sub, dom, obj, act, eft
p2 = sub_rule, dom, obj, act, eft

[role_definition]
g = _, _                    # System roles: user -> role
g2 = _, _, _                # Group roles: user -> role -> group

[policy_effect]
e = some(where (p.eft == allow)) && !some(where (p.eft == deny))

[matchers]
m = (g(r.sub, "admin") && r.dom == "system") || \
    (g(r.sub, p.sub) && r.dom == p.dom && keyMatch2(r.obj, p.obj) && r.act == p.act && p.eft == "allow") || \
    (g2(r.sub, p.sub, r.dom) && keyMatch2(r.obj, p.obj) && r.act == p.act && p.eft == "allow") || \
    evalAttrRule(r.sub, r.obj, r.act, r.attrs, p2.sub_rule)
```

### Request Elements

| Element | Description | Example |
|---------|-------------|---------|
| `sub` | Subject (user ID) | `"user:123"` |
| `dom` | Domain (system or group) | `"system"`, `"group:42"` |
| `obj` | Resource being accessed | `"media:456"`, `"/api/admin/*"` |
| `act` | Action | `"read"`, `"write"`, `"delete"`, `"download"` |
| `attrs` | JSON attributes for ABAC | `{"owner_id": 123, "status": "approved"}` |

---

## 3. Policy Examples

### System Admin Bypass
```csv
p, admin, system, /api/*, *, allow
g, user:1, admin
```

### Media Ownership ABAC
```csv
# User can modify media IF they own it
p2, owner_check, system, media:*, write, allow
p2, owner_check, system, media:*, delete, allow
```

### Media Status-Based Deny
```csv
# Block download of quarantined/pending_scan media
p2, status_block, system, media:*, download, deny
```

### Group Role Policies
```csv
# Member permissions
p, member, group:*, /api/groups/:id, read, allow
p, member, group:*, /api/groups/:id/members, read, allow

# Moderator permissions (inherits member)
p, moderator, group:*, /api/groups/:id/members, create, allow
p, moderator, group:*, /api/groups/:id/audit, read, allow

# Owner permissions (inherits moderator)
p, owner, group:*, /api/groups/:id, write, allow
p, owner, group:*, /api/groups/:id, delete, allow
p, owner, group:*, /api/groups/:id/members/:userId, *, allow

# Role inheritance
g2, moderator, member, group:*
g2, owner, moderator, group:*

# User assignments (from group_members table)
g2, user:123, owner, group:42
g2, user:456, moderator, group:42
```

### Shared Media Access
```csv
# User can access media shared via fulfilled request
p2, shared_access, system, media:*, read, allow
```

---

## 4. Package Structure

```
backend/internal/
  authz/                          # NEW: Authorization package
    casbin.go                     # Enforcer initialization
    middleware.go                 # Chi middleware integration
    functions.go                  # Custom matcher functions (evalAttrRule)
    loader.go                     # Attribute loader for ABAC
    sync.go                       # Group role synchronization
    audit.go                      # Authorization audit logging
  models/
    casbin_rule.go               # GORM model for casbin_rule table
```

---

## 5. Key Components

### Enforcer Initialization
```go
func NewEnforcer(db *gorm.DB, modelPath string) (*Enforcer, error) {
    adapter, _ := gormadapter.NewAdapterByDB(db)
    e, _ := casbin.NewEnforcer(modelPath, adapter)

    // Register custom ABAC functions
    e.AddFunction("evalAttrRule", evalAttrRuleFunc)
    e.EnableAutoSave(true)
    e.LoadPolicy()

    return &Enforcer{Enforcer: e, db: db}, nil
}
```

### Chi Middleware
```go
func (m *CasbinMiddleware) Authorize(action string) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            userID, _ := mw.GetUserID(r.Context())
            domain := determineDomain(r)  // "system" or "group:42"
            resource := chi.RouteContext(r.Context()).RoutePattern()
            attrs, _ := m.attrLoader.LoadAttributes(r)

            allowed, _ := m.enforcer.EnforceWithAttrs(userID, domain, resource, action, attrs)
            if !allowed {
                respondForbidden(w, "Insufficient permissions")
                return
            }
            next.ServeHTTP(w, r)
        })
    }
}
```

### Custom ABAC Functions
```go
func evalAttrRuleFunc(args ...interface{}) (interface{}, error) {
    sub, obj, act, attrsJSON, rule := parseArgs(args)
    attrs := parseJSON(attrsJSON)
    userID := extractUserID(sub)

    switch rule {
    case "owner_check":
        return attrs["owner_id"] == userID, nil
    case "status_block":
        return attrs["status"] in ["quarantined", "pending_scan"], nil
    case "shared_access":
        return attrs["is_shared"] == true, nil
    }
    return false, nil
}
```

### Attribute Loader
```go
func (l *AttributeLoader) LoadAttributes(r *http.Request) (map[string]interface{}, error) {
    attrs := make(map[string]interface{})

    // Load media attributes
    if mediaID := chi.URLParam(r, "id"); isMediaRoute(r) {
        var media models.Media
        l.db.First(&media, mediaID)
        attrs["owner_id"] = media.UserID
        attrs["status"] = media.Status
    }

    // Check shared access via requests
    userID, _ := mw.GetUserID(r.Context())
    attrs["is_shared"] = l.checkSharedAccess(userID, mediaID)

    return attrs, nil
}
```

---

## 6. Database Schema

```sql
CREATE TABLE casbin_rule (
    id SERIAL PRIMARY KEY,
    ptype VARCHAR(100) NOT NULL,      -- p, p2, g, g2
    v0 VARCHAR(100),                   -- Subject/User
    v1 VARCHAR(100),                   -- Domain/Role
    v2 VARCHAR(100),                   -- Object/Group
    v3 VARCHAR(100),                   -- Action
    v4 VARCHAR(100),                   -- Effect
    v5 VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_casbin_rule_ptype ON casbin_rule(ptype);
CREATE INDEX idx_casbin_rule_v0_v1 ON casbin_rule(v0, v1);
```

---

## 7. Migration Strategy

### Phase 1: Foundation (Week 1)
- Add Casbin dependencies (`casbin/v2`, `gorm-adapter/v3`)
- Create `casbin_rule` migration
- Create `internal/authz/` package
- Seed base policies
- **Keep legacy middleware active**

### Phase 2: System RBAC (Week 2)
- Migrate `RequireRole` → Casbin system policies
- Update admin-only routes: `/api/admin/*`, `/api/audit/*`
- Add feature flag for rollback

### Phase 3: Group Authorization (Week 3)
- Implement group role sync from `group_members`
- Migrate `RequireGroupMember/Moderator/Owner`
- Add `OnGroupMemberChange` hook for real-time sync

### Phase 4: Resource ABAC (Week 4)
- Implement `AttributeLoader`
- Create custom matcher functions
- Migrate media ownership/status checks
- Migrate request visibility rules

### Phase 5: Cleanup (Week 5)
- Remove legacy middleware
- Remove scattered handler checks
- Performance optimization
- Documentation

---

## 8. Critical Files to Modify

| File | Changes |
|------|---------|
| `backend/internal/middleware/auth.go` | Replace `RequireRole` with Casbin |
| `backend/internal/middleware/group_auth.go` | Replace group middlewares with Casbin |
| `backend/internal/handlers/media_handler.go` | Remove ownership/status checks |
| `backend/cmd/api/main.go` | Update middleware chains |
| `backend/internal/repositories/media_repository.go` | Reference for access patterns |

---

## 9. Performance Targets

| Check Type | Target |
|------------|--------|
| Simple RBAC | < 10μs |
| Group role check | < 20μs |
| ABAC with attributes | < 100μs |

**Mitigation:** Policy caching (in-memory), batch attribute loading for lists.

---

## 10. Testing Strategy

```go
// Policy unit tests
func TestMediaOwnershipCheck(t *testing.T) {
    e := setupTestEnforcer(t)
    attrs := `{"owner_id": 123}`

    // Owner can edit
    allowed, _ := e.Enforce("user:123", "system", "media:456", "write", attrs)
    assert.True(t, allowed)

    // Non-owner cannot
    allowed, _ = e.Enforce("user:999", "system", "media:456", "write", attrs)
    assert.False(t, allowed)
}

// Migration parity tests
func TestLegacyVsCasbinParity(t *testing.T) {
    // Verify identical behavior between old and new
}
```

---

## 11. Success Criteria

- [ ] All existing authorization checks pass with Casbin
- [ ] < 10% latency increase on protected endpoints
- [ ] 95%+ test coverage on authz code
- [ ] All authorization decisions logged
- [ ] Policies configurable without code deploy
- [ ] Legacy authorization code removed

---

## Dependencies

```go
// go.mod additions
require (
    github.com/casbin/casbin/v2 v2.82.0
    github.com/casbin/gorm-adapter/v3 v3.21.0
)
```

---

## References

- [Casbin Documentation](https://casbin.org/docs/overview)
- [Casbin GORM Adapter](https://github.com/casbin/gorm-adapter)
- [PERM Model](https://casbin.org/docs/supported-models)
