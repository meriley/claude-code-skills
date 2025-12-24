# Admin Button Access Control

## Requirement
Implement proper access control for Dashboard admin buttons:
1. **Quarantine** - RBAC: Only site admins (`user.role === 'admin'`)
2. **Approval Queue** - ABAC: Only users who can approve a group's requests (owner/moderator of any group)

## Current State
Both buttons currently show for any admin (`user?.role === 'admin'`). This is:
- ✅ Correct for Quarantine
- ❌ Wrong for Approval Queue (should be ABAC based on group role)

---

## Step 1: Update Product Specs (PREREQUISITE)

The backend access control is documented, but **frontend UI visibility is missing**. Add documentation before implementing.

### File: `/docs/product-specs/authentication-spec.md`

Add new section after "6.3 Middleware Implementation" (around line 407):

```markdown
### 6.4 Frontend Access Control

Dashboard button visibility is controlled by role and group membership:

| UI Element | Control Type | Visibility Rule |
|------------|--------------|-----------------|
| **Quarantine Button** | RBAC | `user.role === 'admin'` |
| **Approval Queue Button** | ABAC | User is `owner` or `moderator` of any group |

**Rationale**:
- Quarantine is a system-wide admin function (malware management)
- Approval Queue is group-context-specific (approve requests for groups you moderate)

**Implementation**:
```typescript
// Quarantine: RBAC (admin only)
const canViewQuarantine = user?.role === 'admin'

// Approval Queue: ABAC (group owner/moderator)
const canApproveRequests = groups.some(
  g => g.user_role === 'owner' || g.user_role === 'moderator'
)
```
```

### File: `/docs/product-specs/groups-system-spec.md`

The `canApproveRequests` function is already documented in lines 695-700. Add cross-reference to frontend visibility:

After line 722 (Security & Validation section), add:

```markdown
### Dashboard Integration

Users who can approve requests (determined by `canApproveRequests()`) see the **Approval Queue** button on the Dashboard. This provides quick access to pending requests across all groups they moderate.

See [authentication-spec.md](./authentication-spec.md#64-frontend-access-control) for complete frontend access control matrix.
```

---

## Step 2: Implement Frontend Changes

### File: `/frontend/src/routes/Dashboard.tsx`

**Current code (lines 152-175):**
```typescript
{user?.role === 'admin' && (
  <>
    <Button ... >Approval Queue</Button>
    <Button ... >Quarantine</Button>
  </>
)}
```

**Change to:**
```typescript
{/* ABAC: Show Approval Queue if user can approve for any group */}
{canApproveRequests && (
  <Button
    onClick={() => navigate('/admin/approval')}
    leftSection={<IconShieldCheck size={16} />}
    size="sm"
    variant="light"
    color="grape"
    data-testid="dashboard-admin-approval-button"
  >
    Approval Queue
  </Button>
)}

{/* RBAC: Quarantine is admin-only */}
{user?.role === 'admin' && (
  <Button
    onClick={() => navigate('/admin/quarantine')}
    leftSection={<IconShieldX size={16} />}
    size="sm"
    variant="light"
    color="red"
    data-testid="dashboard-admin-quarantine-button"
  >
    Quarantine
  </Button>
)}
```

**Add state for groups and derive permission:**
```typescript
const [groups, setGroups] = useState<Group[]>([])

// In fetchData:
const groupsRes = await groupService.listGroups()
setGroups(groupsRes.groups || [])

// Derived permission:
const canApproveRequests = groups.some(
  (g) => g.user_role === 'owner' || g.user_role === 'moderator'
)
```

---

## Verification
1. `npm run build` - TypeScript compiles
2. Test as regular user - neither button shows
3. Test as group owner/moderator (non-admin) - only Approval Queue shows
4. Test as site admin who is also group moderator - both buttons show
5. Test as site admin with no group roles - only Quarantine shows

---

## Step 3: Update Audit Logging Spec

### File: `/docs/product-specs/audit-logging-spec.md`

Add new event types for admin access control (after existing event types section):

```markdown
### Admin Access Events

| Event | Action | Details |
|-------|--------|---------|
| `admin.approval_queue_accessed` | Admin accessed approval queue | `{filters: {content_type, search}}` |
| `admin.quarantine_accessed` | Admin accessed quarantine list | `{filters: {scan_status, limit}}` |

### Quarantine Events

| Event | Action | Details |
|-------|--------|---------|
| `quarantine.list_accessed` | Listed quarantined files | `{count, filters}` |
| `quarantine.details_viewed` | Viewed quarantine details | `{media_id, threat_name}` |
| `quarantine.deleted` | Deleted quarantine record | `{media_id, threat_name, filename}` |

### Media Events (User Actions)

| Event | Action | Details |
|-------|--------|---------|
| `media.downloaded` | User downloaded media | `{media_id, filename}` |
| `media.updated` | User updated metadata | `{media_id, fields_changed}` |
| `media.deleted` | User deleted media | `{media_id, filename}` |
| `media.thumbnail_accessed` | Thumbnail URL generated | `{media_id}` |
```

---

## Step 4: Implement Backend Audit Logging

### File: `/backend/internal/handlers/quarantine_handler.go`

Add audit logging to all 4 endpoints using existing `createAuditLog()` pattern:

**ListQuarantined** (after successful response):
```go
createAuditLog(h.db, userID, "quarantine.list_accessed", "quarantine", nil,
    map[string]interface{}{"count": len(quarantined), "filters": filters}, r)
```

**GetQuarantineDetails** (after successful response):
```go
createAuditLog(h.db, userID, "quarantine.details_viewed", "media", &mediaID,
    map[string]interface{}{"threat_name": media.ThreatName}, r)
```

**DeleteQuarantined** (CRITICAL - after successful deletion):
```go
createAuditLog(h.db, userID, "quarantine.deleted", "media", &mediaID,
    map[string]interface{}{"threat_name": media.ThreatName, "filename": media.Filename}, r)
```

**GetQuarantineStats** (after successful response):
```go
createAuditLog(h.db, userID, "quarantine.stats_accessed", "quarantine", nil, nil, r)
```

### File: `/backend/internal/handlers/approval.go`

Add audit logging to `ListPendingForApproval`:

```go
createAuditLog(ctx.DB, userID, "admin.approval_queue_accessed", "approval", nil,
    map[string]interface{}{"count": len(media), "filters": filters}, r)
```

### File: `/backend/internal/handlers/media_handler.go`

Add audit logging to user-initiated actions:

**GetDownloadURL**:
```go
createAuditLog(h.db, userID, "media.downloaded", "media", &mediaID,
    map[string]interface{}{"filename": media.Filename}, r)
```

**UpdateMedia**:
```go
createAuditLog(h.db, userID, "media.updated", "media", &mediaID,
    map[string]interface{}{"fields_changed": changedFields}, r)
```

**DeleteMedia**:
```go
createAuditLog(h.db, userID, "media.deleted", "media", &mediaID,
    map[string]interface{}{"filename": media.Filename}, r)
```

---

## Verification

### Frontend (Steps 1-2)
1. `npm run build` - TypeScript compiles
2. Test as regular user - neither button shows
3. Test as group owner/moderator (non-admin) - only Approval Queue shows
4. Test as site admin who is also group moderator - both buttons show
5. Test as site admin with no group roles - only Quarantine shows

### Backend Audit Logging (Steps 3-4)
1. `go build ./...` - Go compiles
2. `go test ./...` - Tests pass
3. Test quarantine actions - verify audit logs created
4. Test approval queue access - verify audit logs created
5. Query audit_logs table to confirm event capture

---

## Files to Modify

| File | Change |
|------|--------|
| `docs/product-specs/authentication-spec.md` | Add section 6.4 Frontend Access Control |
| `docs/product-specs/groups-system-spec.md` | Add Dashboard Integration cross-reference |
| `docs/product-specs/audit-logging-spec.md` | Add admin/quarantine/media event types |
| `frontend/src/routes/Dashboard.tsx` | Separate RBAC/ABAC button visibility |
| `backend/internal/handlers/quarantine_handler.go` | Add audit logging to all endpoints |
| `backend/internal/handlers/approval.go` | Add audit logging to queue access |
| `backend/internal/handlers/media_handler.go` | Add audit logging to user actions |
