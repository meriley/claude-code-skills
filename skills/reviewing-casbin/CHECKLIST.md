# Casbin Review Checklist

Comprehensive checklist for reviewing Casbin authorization implementations.

---

## Model Configuration

### Request Definition
- [ ] `r = sub, obj, act` for standard RBAC
- [ ] `r = sub, dom, obj, act` for multi-tenant (domains)
- [ ] All request parameters used in matcher

### Policy Definition
- [ ] Matches request definition structure
- [ ] ABAC: Uses `sub_rule, obj_rule` for dynamic rules

### Role Definition (RBAC Only)
- [ ] `g = _, _` present for user-role mapping
- [ ] `g = _, _, _` for domain-scoped roles
- [ ] `g2` defined if resource hierarchy needed

### Policy Effect
- [ ] `e = some(where (p.eft == allow))` for allow-based
- [ ] `e = !some(where (p.eft == deny))` for deny-based
- [ ] `e = some(where (p.eft == allow)) && !some(where (p.eft == deny))` for hybrid

### Matchers
- [ ] Role function `g(r.sub, p.sub)` used for RBAC
- [ ] Correct path matcher for URL patterns:
  - `keyMatch`: Glob patterns (`/api/*`)
  - `keyMatch2`: Param patterns (`/api/:id`)
  - `keyMatch3`: Brace patterns (`/api/{id}`)
- [ ] Domain matching for multi-tenant
- [ ] Action comparison correct (`r.act == p.act`)

---

## Enforcer Setup

### Initialization
- [ ] Error handling on `NewEnforcer()`
- [ ] Model path from configuration (not hardcoded)
- [ ] Adapter error handling

### Configuration
- [ ] `EnableAutoSave(true)` for persistent policies
- [ ] `EnableLog(true)` in development only
- [ ] Connection pooling for database adapter

### Thread Safety
- [ ] `SyncedEnforcer` for concurrent access
- [ ] Or mutex protection for policy modifications
- [ ] Single-writer pattern for high-read scenarios

### Lifecycle
- [ ] Enforcer created at startup
- [ ] Singleton or dependency injection pattern
- [ ] Graceful shutdown handling

---

## Middleware Integration

### HTTP Middleware
- [ ] Placed after authentication middleware
- [ ] Safe context value extraction with `, ok`
- [ ] Empty/nil user check returns 401
- [ ] Failed authorization returns 403 (not 401)
- [ ] Enforce errors return 500

### gRPC Interceptors
- [ ] Metadata extraction for user identity
- [ ] Method name extraction for resource
- [ ] Proper gRPC status codes:
  - `codes.Unauthenticated` (16) for no credentials
  - `codes.PermissionDenied` (7) for unauthorized

### Error Responses
- [ ] No sensitive information in error messages
- [ ] Consistent error format
- [ ] Logging of authorization failures

---

## Policy Management

### Storage
- [ ] Policies in database (not hardcoded)
- [ ] Adapter configured correctly
- [ ] Migration strategy for policy changes

### Operations
- [ ] Error handling on `AddPolicy()`
- [ ] Error handling on `RemovePolicy()`
- [ ] Batch operations for bulk changes
- [ ] `SavePolicy()` called if auto-save disabled

### Querying
- [ ] `GetPolicy()` for debugging
- [ ] `GetRolesForUser()` for user inspection
- [ ] `GetImplicitPermissionsForUser()` for full access list

### Maintenance
- [ ] Audit logging for policy changes
- [ ] Admin interface for policy management
- [ ] Policy backup strategy

---

## Security

### Authentication First
- [ ] Authentication verified before authorization
- [ ] User identity validated (not just present)
- [ ] Session/token validation complete

### Context Safety
- [ ] No unsafe type assertions (`.(string)` without check)
- [ ] Nil checks on all context values
- [ ] Input sanitization before enforce

### Status Codes
- [ ] 401 for missing/invalid authentication
- [ ] 403 for valid user, denied access
- [ ] Never expose internal errors

### Policy Security
- [ ] No wildcard permissions in production
- [ ] Principle of least privilege
- [ ] Regular policy audits scheduled

### ABAC Safety
- [ ] Nil checks before ABAC enforcement
- [ ] Attribute validation
- [ ] No injection in dynamic rules

---

## Performance

### Enforcement
- [ ] `BatchEnforce()` for multiple checks
- [ ] Caching for repeated checks (if applicable)
- [ ] Avoid enforce in loops

### Policy Loading
- [ ] `LoadFilteredPolicy()` for large policy sets
- [ ] Index on policy columns in database
- [ ] Connection pooling configured

### Monitoring
- [ ] Metrics on enforce latency
- [ ] Alerts on high failure rates
- [ ] Policy size monitoring

---

## Testing

### Unit Tests
- [ ] Policy rules tested individually
- [ ] Role inheritance tested
- [ ] Edge cases covered:
  - Empty user
  - Nil resource
  - Unknown action
  - Wildcard patterns

### Integration Tests
- [ ] Middleware tested end-to-end
- [ ] Database adapter tested
- [ ] Concurrent access tested

### Test Structure
- [ ] Table-driven tests for permissions
- [ ] In-memory enforcer for unit tests
- [ ] Isolated test database for integration

### Coverage
- [ ] All policy rules have tests
- [ ] All middleware paths covered
- [ ] Negative cases (denied access) tested

---

## Code Quality

### Error Handling
- [ ] All errors wrapped with context (`%w`)
- [ ] No ignored errors (`_, _`)
- [ ] Meaningful error messages

### Logging
- [ ] Authorization decisions logged
- [ ] No sensitive data in logs
- [ ] Correlation IDs included

### Documentation
- [ ] Model file commented
- [ ] Middleware documented
- [ ] Policy structure documented

---

## Quick Audit Commands

```bash
# Find all Casbin usage
grep -rn "casbin" --include="*.go"

# Find ignored errors
grep -rn "Enforce.*_\|NewEnforcer.*_" --include="*.go"

# Find unsafe type assertions
grep -rn "\.Value.*\)\.\(string\|int\)" --include="*.go" | grep -v ", ok"

# Find hardcoded policies
grep -rn "AddPolicy\|AddRoleForUser" --include="*.go" | grep -v "_test.go"

# Find status code issues
grep -rn "StatusUnauthorized.*Forbidden\|StatusForbidden.*Unauthorized" --include="*.go"

# Check model files exist
find . -name "*.conf" -exec grep -l "request_definition" {} \;

# Find enforce in loops
grep -rn "for.*{" --include="*.go" -A5 | grep "Enforce"
```

---

## Severity Reference

| Severity | Examples |
|----------|----------|
| CRITICAL | Missing role definition, ignored errors, unsafe type assertions |
| HIGH | Wrong status codes, no thread safety, missing auth check |
| MEDIUM | Hardcoded policies, enforce in loops, no batch operations |
| LOW | Missing tests, no logging, documentation gaps |
