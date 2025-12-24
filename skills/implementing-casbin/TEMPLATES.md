---
title: Casbin Authorization Templates
---

# Casbin Authorization Templates

Copy-paste ready templates for common Casbin configurations.

## Table of Contents

1. [Model Files](#model-files)
2. [Go Enforcer Setup](#go-enforcer-setup)
3. [Middleware Templates](#middleware-templates)
4. [Test Templates](#test-templates)
5. [Policy Migration](#policy-migration)

---

## Model Files

### rbac_model.conf (Standard RBAC)

```ini
[request_definition]
r = sub, obj, act

[policy_definition]
p = sub, obj, act

[role_definition]
g = _, _

[policy_effect]
e = some(where (p.eft == allow))

[matchers]
m = g(r.sub, p.sub) && keyMatch2(r.obj, p.obj) && r.act == p.act
```

### rbac_with_domains.conf (Multi-Tenant RBAC)

```ini
[request_definition]
r = sub, dom, obj, act

[policy_definition]
p = sub, dom, obj, act

[role_definition]
g = _, _, _

[policy_effect]
e = some(where (p.eft == allow))

[matchers]
m = g(r.sub, p.sub, r.dom) && r.dom == p.dom && keyMatch2(r.obj, p.obj) && r.act == p.act
```

### abac_model.conf (Attribute-Based)

```ini
[request_definition]
r = sub, obj, act

[policy_definition]
p = sub_rule, obj_rule, act

[policy_effect]
e = some(where (p.eft == allow))

[matchers]
m = eval(p.sub_rule) && eval(p.obj_rule) && r.act == p.act
```

### rbac_with_deny.conf (Allow/Deny)

```ini
[request_definition]
r = sub, obj, act

[policy_definition]
p = sub, obj, act, eft

[role_definition]
g = _, _

[policy_effect]
e = some(where (p.eft == allow)) && !some(where (p.eft == deny))

[matchers]
m = g(r.sub, p.sub) && keyMatch2(r.obj, p.obj) && r.act == p.act
```

---

## Go Enforcer Setup

### enforcer.go (Production Ready)

```go
package authz

import (
    "fmt"
    "sync"
    "time"

    "github.com/casbin/casbin/v2"
    gormadapter "github.com/casbin/gorm-adapter/v3"
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
    "gorm.io/gorm/logger"
)

var (
    enforcer     *casbin.Enforcer
    enforcerOnce sync.Once
)

// Config holds Casbin configuration
type Config struct {
    DSN       string
    ModelPath string
    TableName string
}

// NewEnforcer creates a production-ready Casbin enforcer
func NewEnforcer(cfg Config) (*casbin.Enforcer, error) {
    db, err := gorm.Open(postgres.Open(cfg.DSN), &gorm.Config{
        Logger: logger.Default.LogMode(logger.Silent),
    })
    if err != nil {
        return nil, fmt.Errorf("connect to database: %w", err)
    }

    // Configure connection pool
    sqlDB, err := db.DB()
    if err != nil {
        return nil, fmt.Errorf("get sql.DB: %w", err)
    }
    sqlDB.SetMaxIdleConns(10)
    sqlDB.SetMaxOpenConns(100)
    sqlDB.SetConnMaxLifetime(time.Hour)

    // Create adapter
    var adapter *gormadapter.Adapter
    if cfg.TableName != "" {
        adapter, err = gormadapter.NewAdapterByDBWithCustomTable(db, nil, cfg.TableName)
    } else {
        adapter, err = gormadapter.NewAdapterByDB(db)
    }
    if err != nil {
        return nil, fmt.Errorf("create adapter: %w", err)
    }

    // Create enforcer
    e, err := casbin.NewEnforcer(cfg.ModelPath, adapter)
    if err != nil {
        return nil, fmt.Errorf("create enforcer: %w", err)
    }

    // Enable auto-save
    e.EnableAutoSave(true)

    return e, nil
}

// GetEnforcer returns singleton enforcer instance
func GetEnforcer(cfg Config) (*casbin.Enforcer, error) {
    var initErr error
    enforcerOnce.Do(func() {
        enforcer, initErr = NewEnforcer(cfg)
    })
    return enforcer, initErr
}
```

### enforcer_test_helper.go

```go
package authz

import (
    "testing"

    "github.com/casbin/casbin/v2"
    "github.com/casbin/casbin/v2/model"
)

// NewTestEnforcer creates an in-memory enforcer for testing
func NewTestEnforcer(t *testing.T) *casbin.Enforcer {
    t.Helper()

    modelText := `
[request_definition]
r = sub, obj, act

[policy_definition]
p = sub, obj, act

[role_definition]
g = _, _

[policy_effect]
e = some(where (p.eft == allow))

[matchers]
m = g(r.sub, p.sub) && keyMatch2(r.obj, p.obj) && r.act == p.act
`
    m, err := model.NewModelFromString(modelText)
    if err != nil {
        t.Fatalf("create model: %v", err)
    }

    e, err := casbin.NewEnforcer(m)
    if err != nil {
        t.Fatalf("create enforcer: %v", err)
    }

    return e
}

// SetupTestPolicies adds common test policies
func SetupTestPolicies(t *testing.T, e *casbin.Enforcer) {
    t.Helper()

    // Roles
    e.AddRoleForUser("alice", "admin")
    e.AddRoleForUser("bob", "viewer")

    // Admin permissions
    e.AddPolicy("admin", "/api/users", "GET")
    e.AddPolicy("admin", "/api/users", "POST")
    e.AddPolicy("admin", "/api/users/:id", "GET")
    e.AddPolicy("admin", "/api/users/:id", "PUT")
    e.AddPolicy("admin", "/api/users/:id", "DELETE")

    // Viewer permissions
    e.AddPolicy("viewer", "/api/users", "GET")
    e.AddPolicy("viewer", "/api/users/:id", "GET")
}
```

---

## Middleware Templates

### chi_middleware.go

```go
package middleware

import (
    "context"
    "encoding/json"
    "net/http"

    "github.com/casbin/casbin/v2"
)

type contextKey string

const UserIDKey contextKey = "userID"

// ErrorResponse represents an error response
type ErrorResponse struct {
    Error   string `json:"error"`
    Message string `json:"message,omitempty"`
}

// Authorize creates Chi authorization middleware
func Authorize(e *casbin.Enforcer) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            userID, ok := r.Context().Value(UserIDKey).(string)
            if !ok || userID == "" {
                writeError(w, http.StatusUnauthorized, "unauthorized", "missing or invalid user identity")
                return
            }

            allowed, err := e.Enforce(userID, r.URL.Path, r.Method)
            if err != nil {
                writeError(w, http.StatusInternalServerError, "authorization_error", err.Error())
                return
            }

            if !allowed {
                writeError(w, http.StatusForbidden, "forbidden", "insufficient permissions")
                return
            }

            next.ServeHTTP(w, r)
        })
    }
}

// AuthorizeWithDomain creates domain-aware authorization middleware
func AuthorizeWithDomain(e *casbin.Enforcer, domainKey contextKey) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            userID, ok := r.Context().Value(UserIDKey).(string)
            if !ok || userID == "" {
                writeError(w, http.StatusUnauthorized, "unauthorized", "missing user identity")
                return
            }

            domain, ok := r.Context().Value(domainKey).(string)
            if !ok || domain == "" {
                writeError(w, http.StatusBadRequest, "bad_request", "missing domain/tenant")
                return
            }

            allowed, err := e.Enforce(userID, domain, r.URL.Path, r.Method)
            if err != nil {
                writeError(w, http.StatusInternalServerError, "authorization_error", err.Error())
                return
            }

            if !allowed {
                writeError(w, http.StatusForbidden, "forbidden", "insufficient permissions")
                return
            }

            next.ServeHTTP(w, r)
        })
    }
}

// WithUserID adds user ID to context (use after JWT validation)
func WithUserID(userID string) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            ctx := context.WithValue(r.Context(), UserIDKey, userID)
            next.ServeHTTP(w, r.WithContext(ctx))
        })
    }
}

func writeError(w http.ResponseWriter, status int, errCode, message string) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    json.NewEncoder(w).Encode(ErrorResponse{
        Error:   errCode,
        Message: message,
    })
}
```

### grpc_interceptor.go

```go
package interceptor

import (
    "context"
    "fmt"

    "github.com/casbin/casbin/v2"
    "google.golang.org/grpc"
    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/metadata"
    "google.golang.org/grpc/status"
)

const (
    userIDHeader = "x-user-id"
    domainHeader = "x-tenant-id"
)

// UnaryAuthorize creates unary server interceptor
func UnaryAuthorize(e *casbin.Enforcer) grpc.UnaryServerInterceptor {
    return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
        userID, err := extractUserID(ctx)
        if err != nil {
            return nil, status.Error(codes.Unauthenticated, "authentication required")
        }

        allowed, err := e.Enforce(userID, info.FullMethod, "call")
        if err != nil {
            return nil, status.Errorf(codes.Internal, "authorization error: %v", err)
        }

        if !allowed {
            return nil, status.Error(codes.PermissionDenied, "permission denied")
        }

        return handler(ctx, req)
    }
}

// UnaryAuthorizeWithDomain creates domain-aware unary interceptor
func UnaryAuthorizeWithDomain(e *casbin.Enforcer) grpc.UnaryServerInterceptor {
    return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
        userID, err := extractUserID(ctx)
        if err != nil {
            return nil, status.Error(codes.Unauthenticated, "authentication required")
        }

        domain, err := extractDomain(ctx)
        if err != nil {
            return nil, status.Error(codes.InvalidArgument, "tenant/domain required")
        }

        allowed, err := e.Enforce(userID, domain, info.FullMethod, "call")
        if err != nil {
            return nil, status.Errorf(codes.Internal, "authorization error: %v", err)
        }

        if !allowed {
            return nil, status.Error(codes.PermissionDenied, "permission denied")
        }

        return handler(ctx, req)
    }
}

// StreamAuthorize creates stream server interceptor
func StreamAuthorize(e *casbin.Enforcer) grpc.StreamServerInterceptor {
    return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
        userID, err := extractUserID(ss.Context())
        if err != nil {
            return status.Error(codes.Unauthenticated, "authentication required")
        }

        allowed, err := e.Enforce(userID, info.FullMethod, "call")
        if err != nil {
            return status.Errorf(codes.Internal, "authorization error: %v", err)
        }

        if !allowed {
            return status.Error(codes.PermissionDenied, "permission denied")
        }

        return handler(srv, ss)
    }
}

func extractUserID(ctx context.Context) (string, error) {
    md, ok := metadata.FromIncomingContext(ctx)
    if !ok {
        return "", fmt.Errorf("no metadata")
    }

    values := md.Get(userIDHeader)
    if len(values) == 0 {
        return "", fmt.Errorf("no user id in metadata")
    }

    return values[0], nil
}

func extractDomain(ctx context.Context) (string, error) {
    md, ok := metadata.FromIncomingContext(ctx)
    if !ok {
        return "", fmt.Errorf("no metadata")
    }

    values := md.Get(domainHeader)
    if len(values) == 0 {
        return "", fmt.Errorf("no domain in metadata")
    }

    return values[0], nil
}
```

---

## Test Templates

### enforcer_test.go

```go
package authz_test

import (
    "testing"

    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"

    "your-module/internal/authz"
)

func TestEnforcer_RBAC(t *testing.T) {
    e := authz.NewTestEnforcer(t)
    authz.SetupTestPolicies(t, e)

    tests := []struct {
        name    string
        sub     string
        obj     string
        act     string
        allowed bool
    }{
        // Admin tests
        {"admin can list users", "alice", "/api/users", "GET", true},
        {"admin can create users", "alice", "/api/users", "POST", true},
        {"admin can get user", "alice", "/api/users/123", "GET", true},
        {"admin can update user", "alice", "/api/users/123", "PUT", true},
        {"admin can delete user", "alice", "/api/users/123", "DELETE", true},

        // Viewer tests
        {"viewer can list users", "bob", "/api/users", "GET", true},
        {"viewer can get user", "bob", "/api/users/123", "GET", true},
        {"viewer cannot create users", "bob", "/api/users", "POST", false},
        {"viewer cannot delete users", "bob", "/api/users/123", "DELETE", false},

        // Unknown user tests
        {"unknown user cannot access", "charlie", "/api/users", "GET", false},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            allowed, err := e.Enforce(tt.sub, tt.obj, tt.act)
            require.NoError(t, err)
            assert.Equal(t, tt.allowed, allowed)
        })
    }
}

func TestEnforcer_RoleManagement(t *testing.T) {
    e := authz.NewTestEnforcer(t)

    // Add role
    added, err := e.AddRoleForUser("alice", "admin")
    require.NoError(t, err)
    assert.True(t, added)

    // Check role
    hasRole, err := e.HasRoleForUser("alice", "admin")
    require.NoError(t, err)
    assert.True(t, hasRole)

    // Get roles
    roles, err := e.GetRolesForUser("alice")
    require.NoError(t, err)
    assert.Contains(t, roles, "admin")

    // Remove role
    removed, err := e.DeleteRoleForUser("alice", "admin")
    require.NoError(t, err)
    assert.True(t, removed)

    // Verify removed
    hasRole, err = e.HasRoleForUser("alice", "admin")
    require.NoError(t, err)
    assert.False(t, hasRole)
}
```

### middleware_test.go

```go
package middleware_test

import (
    "context"
    "net/http"
    "net/http/httptest"
    "testing"

    "github.com/go-chi/chi/v5"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"

    "your-module/internal/authz"
    "your-module/internal/middleware"
)

func TestAuthorizeMiddleware(t *testing.T) {
    e := authz.NewTestEnforcer(t)
    authz.SetupTestPolicies(t, e)

    handler := chi.NewRouter()
    handler.Use(middleware.Authorize(e))
    handler.Get("/api/users", func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
        w.Write([]byte("ok"))
    })

    tests := []struct {
        name       string
        userID     string
        path       string
        method     string
        wantStatus int
    }{
        {"authorized admin", "alice", "/api/users", "GET", http.StatusOK},
        {"authorized viewer", "bob", "/api/users", "GET", http.StatusOK},
        {"unauthorized user", "charlie", "/api/users", "GET", http.StatusForbidden},
        {"no user", "", "/api/users", "GET", http.StatusUnauthorized},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            req := httptest.NewRequest(tt.method, tt.path, nil)
            if tt.userID != "" {
                ctx := context.WithValue(req.Context(), middleware.UserIDKey, tt.userID)
                req = req.WithContext(ctx)
            }

            rr := httptest.NewRecorder()
            handler.ServeHTTP(rr, req)

            assert.Equal(t, tt.wantStatus, rr.Code)
        })
    }
}
```

---

## Policy Migration

### migrate_policies.go

```go
package migrations

import (
    "fmt"

    "github.com/casbin/casbin/v2"
)

// SeedPolicies adds initial policies for a fresh installation
func SeedPolicies(e *casbin.Enforcer) error {
    policies := []struct {
        ptype string
        rule  []string
    }{
        // Roles
        {"g", []string{"superadmin", "admin"}},
        {"g", []string{"admin", "editor"}},
        {"g", []string{"editor", "viewer"}},

        // Admin permissions
        {"p", []string{"admin", "/api/admin/*", "GET"}},
        {"p", []string{"admin", "/api/admin/*", "POST"}},
        {"p", []string{"admin", "/api/admin/*", "PUT"}},
        {"p", []string{"admin", "/api/admin/*", "DELETE"}},

        // Editor permissions
        {"p", []string{"editor", "/api/content/*", "GET"}},
        {"p", []string{"editor", "/api/content/*", "POST"}},
        {"p", []string{"editor", "/api/content/*", "PUT"}},

        // Viewer permissions
        {"p", []string{"viewer", "/api/content/*", "GET"}},
        {"p", []string{"viewer", "/api/public/*", "GET"}},
    }

    for _, policy := range policies {
        var added bool
        var err error

        switch policy.ptype {
        case "p":
            added, err = e.AddPolicy(toInterface(policy.rule)...)
        case "g":
            added, err = e.AddGroupingPolicy(toInterface(policy.rule)...)
        }

        if err != nil {
            return fmt.Errorf("add policy %v: %w", policy.rule, err)
        }

        if added {
            fmt.Printf("Added %s: %v\n", policy.ptype, policy.rule)
        }
    }

    return e.SavePolicy()
}

func toInterface(s []string) []interface{} {
    result := make([]interface{}, len(s))
    for i, v := range s {
        result[i] = v
    }
    return result
}
```

### Example Usage in Main

```go
package main

import (
    "log"
    "os"

    "your-module/internal/authz"
    "your-module/internal/migrations"
)

func main() {
    cfg := authz.Config{
        DSN:       os.Getenv("DATABASE_URL"),
        ModelPath: "config/rbac_model.conf",
    }

    e, err := authz.NewEnforcer(cfg)
    if err != nil {
        log.Fatalf("create enforcer: %v", err)
    }

    // Run migrations on first run or with flag
    if os.Getenv("SEED_POLICIES") == "true" {
        if err := migrations.SeedPolicies(e); err != nil {
            log.Fatalf("seed policies: %v", err)
        }
        log.Println("Policies seeded successfully")
    }

    // Continue with application setup...
}
```
