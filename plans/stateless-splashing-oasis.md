# Plan: Create Casbin Reviewer Skill

## Summary
Create a code review skill for Go code using Casbin authorization. Focuses on detecting common mistakes, security issues, and anti-patterns in RBAC/ABAC implementations.

## Skill Metadata
```yaml
name: reviewing-casbin
description: Review Go code using Casbin authorization for security issues, model correctness, policy design, and common anti-patterns. Use when reviewing PRs with Casbin code or auditing authorization implementations.
version: 1.0.0
```

## Target Directory
`/home/mriley/.claude/skills/reviewing-casbin/`

## Files to Create

### 1. SKILL.md (Main skill file, <500 lines)
**Structure (following mantine-reviewing pattern):**
- Purpose & When to Use / When NOT to Use
- Review Workflow (4 steps)
- Critical Review Areas (priority-ordered)
- Review Output Template
- Quick Commands
- Integration with Other Skills

### 2. CHECKLIST.md (Detailed review checklist)
**Categories:**
- Model Configuration
- Enforcer Setup
- Middleware Integration
- Policy Management
- Security
- Performance
- Testing

---

## Critical Review Areas

### 1. Model File Errors (CRITICAL)

**Check for:**
```ini
# ❌ FAIL: Missing role definition in RBAC
[request_definition]
r = sub, obj, act
[policy_definition]
p = sub, obj, act
# Missing: [role_definition] g = _, _
[matchers]
m = g(r.sub, p.sub) && ...  # g() won't work!

# ❌ FAIL: Wrong matcher function
m = r.sub == p.sub  # Doesn't use role inheritance

# ✅ PASS: Complete RBAC model
[role_definition]
g = _, _
[matchers]
m = g(r.sub, p.sub) && keyMatch2(r.obj, p.obj) && r.act == p.act
```

### 2. Enforcer Initialization (CRITICAL)

**Check for:**
```go
// ❌ FAIL: Ignoring errors
e, _ := casbin.NewEnforcer(modelPath, adapter)

// ❌ FAIL: No auto-save enabled
e, _ := casbin.NewEnforcer(modelPath, adapter)
// Missing: e.EnableAutoSave(true)

// ❌ FAIL: Hardcoded paths
e, _ := casbin.NewEnforcer("/app/model.conf", adapter)

// ✅ PASS: Proper error handling and config
e, err := casbin.NewEnforcer(cfg.ModelPath, adapter)
if err != nil {
    return nil, fmt.Errorf("create enforcer: %w", err)
}
e.EnableAutoSave(true)
```

### 3. Middleware Security (CRITICAL)

**Check for:**
```go
// ❌ FAIL: Missing authentication check
func Authorize(e *casbin.Enforcer) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            user := r.Context().Value("userID").(string)  // Panics if nil!
            // No check if user is authenticated...

// ❌ FAIL: Type assertion without check
user := r.Context().Value("userID").(string)  // Panic risk!

// ✅ PASS: Safe context extraction
user, ok := r.Context().Value("userID").(string)
if !ok || user == "" {
    http.Error(w, "Unauthorized", http.StatusUnauthorized)
    return
}
```

### 4. Error Handling in Enforce (HIGH)

**Check for:**
```go
// ❌ FAIL: Ignoring enforce errors
ok, _ := e.Enforce(user, obj, act)
if !ok {
    // What if there was an error?
}

// ❌ FAIL: Wrong HTTP status
if !allowed {
    http.Error(w, "Unauthorized", http.StatusUnauthorized)  // Should be 403
}

// ✅ PASS: Proper error handling
allowed, err := e.Enforce(user, obj, act)
if err != nil {
    http.Error(w, "Authorization error", http.StatusInternalServerError)
    return
}
if !allowed {
    http.Error(w, "Forbidden", http.StatusForbidden)  // 403, not 401
    return
}
```

### 5. Policy Thread Safety (HIGH)

**Check for:**
```go
// ❌ FAIL: Concurrent policy modification without lock
go func() { e.AddPolicy("alice", "/api", "GET") }()
go func() { e.RemovePolicy("bob", "/api", "GET") }()

// ✅ PASS: Use SyncedEnforcer for concurrent access
e, _ := casbin.NewSyncedEnforcer(model, adapter)
// Or: Ensure single-writer pattern
```

### 6. Missing Authorization Checks (HIGH)

**Check for:**
- Endpoints without authorization middleware
- Middleware applied inconsistently
- Resource-level authorization missing

### 7. Hardcoded Policies (MEDIUM)

**Check for:**
```go
// ❌ FAIL: Hardcoded policies in code
e.AddPolicy("admin", "/api/users/*", "GET")  // Should be in DB/file

// ✅ PASS: Policies loaded from adapter
// Policies defined in database via admin interface
```

### 8. Performance Issues (MEDIUM)

**Check for:**
```go
// ❌ FAIL: Enforce called in loop
for _, item := range items {
    if allowed, _ := e.Enforce(user, item.Path, "read"); allowed {
        result = append(result, item)
    }
}

// ✅ PASS: Batch enforcement
requests := make([][]interface{}, len(items))
for i, item := range items {
    requests[i] = []interface{}{user, item.Path, "read"}
}
results, _ := e.BatchEnforce(requests)
```

### 9. ABAC Nil Safety (MEDIUM)

**Check for:**
```go
// ❌ FAIL: No nil check for ABAC attributes
e.Enforce(user, resource, "read")  // If resource is nil, panic!

// ✅ PASS: Validate before enforce
if resource == nil {
    return false, errors.New("resource cannot be nil")
}
```

### 10. Test Coverage (LOW)

**Check for:**
- Missing unit tests for policies
- Missing middleware tests
- No table-driven tests for permission scenarios

---

## Review Workflow

### Step 1: Identify Casbin Files
```bash
grep -r "casbin" --include="*.go" -l
grep -r "Enforce\|AddPolicy\|NewEnforcer" --include="*.go" -l
```

### Step 2: Check Model Files
```bash
find . -name "*.conf" | xargs grep -l "request_definition"
```

### Step 3: Run Automated Checks
```bash
# Find ignored errors
grep -rn "NewEnforcer.*_\|Enforce.*_" --include="*.go"

# Find type assertions without check
grep -rn "\.Value.*\)\.\(string\|int\)" --include="*.go" | grep -v ", ok"

# Find hardcoded policies
grep -rn "AddPolicy\|AddRoleForUser" --include="*.go" | grep -v "_test.go"
```

### Step 4: Manual Review
Use CHECKLIST.md for comprehensive review.

---

## Review Output Template

```markdown
## Casbin Authorization Review: [File/PR]

### Summary
[1-2 sentence overview of findings]

### Critical Issues
- [ ] [Issue] - [file:line]

### High Priority
- [ ] [Issue] - [file:line]

### Medium Priority
- [ ] [Issue] - [file:line]

### Security Audit
- [ ] All endpoints have authorization middleware
- [ ] Authentication verified before authorization
- [ ] 401 vs 403 used correctly
- [ ] No hardcoded policies in code
- [ ] SyncedEnforcer used for concurrent access

### Model Audit
- [ ] Model file syntax correct
- [ ] Role definition present for RBAC
- [ ] Correct matcher function (keyMatch2/keyMatch3)
- [ ] Policy effect appropriate

### Code Quality
- [ ] All Enforce errors handled
- [ ] Context extraction is safe (type assertion with ok)
- [ ] Batch enforcement used for loops
- [ ] Tests cover policy scenarios

### Passed Checks
- [x] [What's good]
```

---

## Integration

**Related skills:**
- `implementing-casbin` - Development guidance
- `error-handling-audit` - Go error handling
- `quality-check` - General code quality

---

## Quality Checklist (per skill-writing)

- [ ] Name uses gerund form: `reviewing-casbin` ✅
- [ ] SKILL.md under 500 lines
- [ ] Third-person description ✅
- [ ] When to Use / When NOT to Use sections
- [ ] Concrete examples (good/bad patterns)
- [ ] Review workflow with steps
- [ ] Output template provided
- [ ] Quick commands for automation
