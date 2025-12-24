---
title: Casbin Authorization Reference
---

# Casbin Authorization Reference

Detailed reference for model syntax, built-in functions, API methods, and configuration options.

## Table of Contents

1. [Model Syntax](#model-syntax)
2. [Built-in Functions](#built-in-functions)
3. [Enforcer API](#enforcer-api)
4. [GORM Adapter Options](#gorm-adapter-options)
5. [Policy Formats](#policy-formats)
6. [Performance Optimization](#performance-optimization)

---

## Model Syntax

### Request Definition

Defines what parameters are passed to `Enforce()`.

```ini
[request_definition]
r = sub, obj, act           # Basic: subject, object, action
r = sub, dom, obj, act      # With domain: subject, domain, object, action
r = sub, obj, act, attrs    # With attributes for ABAC
```

### Policy Definition

Defines the structure of policy rules.

```ini
[policy_definition]
p = sub, obj, act                    # Basic policy
p = sub, dom, obj, act               # With domain
p = sub, obj, act, eft               # With effect (allow/deny)
p2 = sub, act                        # Second policy type
```

### Role Definition

Defines role inheritance relationships.

```ini
[role_definition]
g = _, _                    # User -> Role
g = _, _, _                 # User -> Role -> Domain
g2 = _, _                   # Second grouping (e.g., resource hierarchy)
```

### Policy Effect

Determines the final authorization decision.

```ini
[policy_effect]
# Allow if ANY matching rule allows
e = some(where (p.eft == allow))

# Allow if ANY matching rule allows AND no rule denies
e = some(where (p.eft == allow)) && !some(where (p.eft == deny))

# Deny if ANY matching rule denies
e = !some(where (p.eft == deny))

# Allow only if ALL matching rules allow
e = some(where (p.eft == allow)) && !some(where (p.eft == deny))
```

### Matchers

Defines how requests are matched against policies.

```ini
[matchers]
# Basic equality
m = r.sub == p.sub && r.obj == p.obj && r.act == p.act

# With role inheritance
m = g(r.sub, p.sub) && r.obj == p.obj && r.act == p.act

# With path matching
m = g(r.sub, p.sub) && keyMatch2(r.obj, p.obj) && r.act == p.act

# With domain
m = g(r.sub, p.sub, r.dom) && r.dom == p.dom && r.obj == p.obj && r.act == p.act

# ABAC with eval
m = eval(p.sub_rule) && eval(p.obj_rule) && r.act == p.act

# Multi-line (use \ for continuation)
m = g(r.sub, p.sub) && keyMatch2(r.obj, p.obj) \
    && r.act == p.act
```

---

## Built-in Functions

### String Matching

| Function | Description | Example |
|----------|-------------|---------|
| `keyMatch(key1, key2)` | URL path matching with `*` wildcard | `/foo/*` matches `/foo/bar` |
| `keyMatch2(key1, key2)` | URL path with `:param` patterns | `/users/:id` matches `/users/123` |
| `keyMatch3(key1, key2)` | URL path with `{param}` patterns | `/users/{id}` matches `/users/123` |
| `keyMatch4(key1, key2)` | Same as keyMatch3 but `{param}` must be whole segment | `/users/{id}` matches `/users/123` |
| `keyMatch5(key1, key2)` | Same as keyMatch2 but `*` matches zero segments | `/api/*` matches `/api` |
| `regexMatch(key1, key2)` | Regex matching | `^/users/[0-9]+$` matches `/users/123` |
| `globMatch(key1, key2)` | Glob pattern matching | `/foo/*.txt` matches `/foo/bar.txt` |

### IP Matching

| Function | Description | Example |
|----------|-------------|---------|
| `ipMatch(ip1, ip2)` | IP address/CIDR matching | `192.168.1.0/24` matches `192.168.1.5` |

### Time Functions

| Function | Description | Example |
|----------|-------------|---------|
| `timeMatch(time1, time2)` | Time range matching | Check business hours |

### Role Functions

| Function | Description | Example |
|----------|-------------|---------|
| `g(user, role)` | Check if user has role | `g("alice", "admin")` |
| `g(user, role, domain)` | Check role in domain | `g("alice", "admin", "tenant1")` |
| `g2(resource, parent)` | Resource hierarchy | `g2("/doc/1", "/docs")` |

### Custom Functions

```go
// Register custom function
e.AddFunction("isOwner", func(args ...interface{}) (interface{}, error) {
    userID := args[0].(string)
    resourceOwnerID := args[1].(string)
    return userID == resourceOwnerID, nil
})

// Use in matcher
// m = isOwner(r.sub.ID, r.obj.OwnerID) && r.act == p.act
```

---

## Enforcer API

### Initialization

```go
// From files
e, _ := casbin.NewEnforcer("model.conf", "policy.csv")

// From adapter
e, _ := casbin.NewEnforcer("model.conf", adapter)

// From model string
m, _ := model.NewModelFromString(modelText)
e, _ := casbin.NewEnforcer(m)

// Without policy (add later)
e, _ := casbin.NewEnforcer("model.conf")
```

### Enforcement

```go
// Single check
allowed, err := e.Enforce("alice", "/api/users", "GET")

// With context (for ABAC)
allowed, err := e.Enforce(userStruct, resourceStruct, "read")

// Batch enforcement
requests := [][]interface{}{
    {"alice", "/users", "GET"},
    {"bob", "/orders", "POST"},
}
results, err := e.BatchEnforce(requests)

// Get matched rule
allowed, explain, err := e.EnforceEx("alice", "/users", "GET")
// explain contains the matched policy rule

// With custom matcher
allowed, err := e.EnforceWithMatcher(customMatcher, "alice", "/users", "GET")
```

### Policy Management

```go
// Add policies
e.AddPolicy("alice", "/users", "GET")
e.AddPolicies([][]string{{"bob", "/orders", "GET"}, {"bob", "/orders", "POST"}})

// Remove policies
e.RemovePolicy("alice", "/users", "GET")
e.RemoveFilteredPolicy(0, "alice")  // Remove all policies for alice
e.RemovePolicies([][]string{{"bob", "/orders", "GET"}})

// Update policies
e.UpdatePolicy(
    []string{"alice", "/users", "GET"},      // old
    []string{"alice", "/users/*", "GET"},    // new
)

// Check policy exists
exists := e.HasPolicy("alice", "/users", "GET")
```

### Role Management

```go
// Add role
e.AddRoleForUser("alice", "admin")
e.AddRolesForUser("bob", []string{"viewer", "editor"})
e.AddRoleForUserInDomain("alice", "admin", "tenant1")

// Remove role
e.DeleteRoleForUser("alice", "admin")
e.DeleteRolesForUser("bob")
e.DeleteUser("alice")  // Remove from all roles
e.DeleteRole("admin")  // Remove role entirely

// Query roles
roles, _ := e.GetRolesForUser("alice")
users, _ := e.GetUsersForRole("admin")
hasRole, _ := e.HasRoleForUser("alice", "admin")

// Implicit (inherited) queries
roles, _ := e.GetImplicitRolesForUser("alice")
permissions, _ := e.GetImplicitPermissionsForUser("alice")
users, _ := e.GetImplicitUsersForRole("admin")
```

### Policy Persistence

```go
// Save to adapter
e.SavePolicy()

// Reload from adapter
e.LoadPolicy()

// Load filtered (for large datasets)
filter := &gormadapter.Filter{
    P: []string{"", "tenant1"},  // Filter by field index
}
e.LoadFilteredPolicy(filter)

// Auto-save on changes
e.EnableAutoSave(true)

// Clear in-memory policy
e.ClearPolicy()
```

### Configuration

```go
// Enable logging
e.EnableLog(true)

// Enable auto-load from adapter (watches for changes)
e.EnableAutoLoad(true)

// Set auto-load interval
e.StartAutoLoadPolicy(time.Minute)
e.StopAutoLoadPolicy()

// Enable enforce caching
e.EnableEnforce(true)  // Default: true
```

---

## GORM Adapter Options

### Basic Setup

```go
import (
    gormadapter "github.com/casbin/gorm-adapter/v3"
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
)

// PostgreSQL
dsn := "host=localhost user=app password=secret dbname=myapp port=5432 sslmode=disable"
db, _ := gorm.Open(postgres.Open(dsn), &gorm.Config{})
adapter, _ := gormadapter.NewAdapterByDB(db)

// MySQL
dsn := "user:password@tcp(localhost:3306)/myapp?charset=utf8mb4&parseTime=True"
db, _ := gorm.Open(mysql.Open(dsn), &gorm.Config{})
adapter, _ := gormadapter.NewAdapterByDB(db)
```

### Custom Table

```go
// Custom table name
adapter, _ := gormadapter.NewAdapterByDBWithCustomTable(db, nil, "authorization_rules")

// Custom table with prefix
adapter, _ := gormadapter.NewAdapterByDBWithCustomTable(db, nil, "app_casbin_rules")
```

### Filtered Adapter

```go
// Create filtered adapter for large datasets
adapter, _ := gormadapter.NewFilteredAdapter(db)

// Load only specific policies
filter := &gormadapter.Filter{
    P: []string{"alice"},           // Filter p rules
    G: []string{"", "admin"},       // Filter g rules
}
e.LoadFilteredPolicy(filter)
```

### Table Schema

The GORM adapter creates a `casbin_rule` table:

```sql
CREATE TABLE casbin_rule (
    id BIGSERIAL PRIMARY KEY,
    ptype VARCHAR(100),     -- Policy type: p, g, g2, etc.
    v0 VARCHAR(100),        -- Field 0 (subject)
    v1 VARCHAR(100),        -- Field 1 (object/role)
    v2 VARCHAR(100),        -- Field 2 (action)
    v3 VARCHAR(100),        -- Field 3 (optional)
    v4 VARCHAR(100),        -- Field 4 (optional)
    v5 VARCHAR(100)         -- Field 5 (optional)
);
```

---

## Policy Formats

### CSV Format

```csv
p, alice, /users, GET
p, alice, /users, POST
p, admin, /users/*, GET
p, admin, /users/*, DELETE

g, alice, admin
g, bob, viewer
```

### JSON Format

```json
{
  "p": [
    ["alice", "/users", "GET"],
    ["alice", "/users", "POST"],
    ["admin", "/users/*", "GET"]
  ],
  "g": [
    ["alice", "admin"],
    ["bob", "viewer"]
  ]
}
```

### Database Format (GORM)

| ptype | v0 | v1 | v2 | v3 | v4 | v5 |
|-------|----|----|----|----|----|----|
| p | alice | /users | GET | | | |
| p | admin | /users/* | GET | | | |
| g | alice | admin | | | | |
| g | bob | viewer | | | | |

---

## Performance Optimization

### Batch Enforcement

```go
// Instead of multiple Enforce calls
requests := make([][]interface{}, 0, len(items))
for _, item := range items {
    requests = append(requests, []interface{}{userID, item.Path, "read"})
}
results, _ := e.BatchEnforce(requests)
```

### Filtered Policy Loading

```go
// Load only relevant policies for the current tenant
filter := &gormadapter.Filter{
    P: []string{"", tenantID},  // Filter by domain field
}
e.LoadFilteredPolicy(filter)
```

### Caching

```go
// The enforcer caches policy internally
// For custom caching, wrap the enforcer
type CachedEnforcer struct {
    *casbin.Enforcer
    cache *sync.Map
}

func (c *CachedEnforcer) CachedEnforce(sub, obj, act string) (bool, error) {
    key := fmt.Sprintf("%s:%s:%s", sub, obj, act)
    if result, ok := c.cache.Load(key); ok {
        return result.(bool), nil
    }

    allowed, err := c.Enforce(sub, obj, act)
    if err == nil {
        c.cache.Store(key, allowed)
    }
    return allowed, err
}
```

### Connection Pooling

```go
sqlDB, _ := db.DB()
sqlDB.SetMaxIdleConns(10)        // Reuse connections
sqlDB.SetMaxOpenConns(100)       // Limit concurrent
sqlDB.SetConnMaxLifetime(time.Hour)  // Refresh connections
```

### Preloading Policies

```go
// For read-heavy workloads, preload all policies at startup
e.LoadPolicy()

// Disable auto-load if policies change rarely
e.EnableAutoSave(false)

// Use file adapter for static policies (fastest)
e, _ := casbin.NewEnforcer("model.conf", "policy.csv")
```

---

## Common Model Patterns

### Super Admin Bypass

```ini
[matchers]
m = r.sub == "superadmin" || (g(r.sub, p.sub) && keyMatch2(r.obj, p.obj) && r.act == p.act)
```

### Deny Override

```ini
[policy_effect]
e = some(where (p.eft == allow)) && !some(where (p.eft == deny))

[policy_definition]
p = sub, obj, act, eft
```

```go
// Allow by default
e.AddPolicy("viewer", "/public/*", "GET", "allow")
// Deny specific resource
e.AddPolicy("viewer", "/public/secret", "GET", "deny")
```

### Resource Ownership

```ini
[matchers]
m = r.sub == r.obj.OwnerID || (g(r.sub, p.sub) && r.obj.Type == p.obj && r.act == p.act)
```

### Time-Based Access

```go
// Custom time check function
e.AddFunction("inBusinessHours", func(args ...interface{}) (interface{}, error) {
    hour := time.Now().Hour()
    return hour >= 9 && hour < 17, nil
})

// Matcher
// m = g(r.sub, p.sub) && r.obj == p.obj && r.act == p.act && inBusinessHours()
```
