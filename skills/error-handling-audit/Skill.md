---
name: Go Error Handling Audit
description: Audits Go code for error handling best practices - proper wrapping with %w, preserved context, meaningful messages, no error swallowing. Use before committing Go code or during error handling reviews.
version: 1.0.0
---

# ⚠️ MANDATORY: Go Error Handling Audit Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Before committing Go code (as part of quality-check)
2. After modifying error handling logic
3. During debugging error-related issues
4. Before creating pull requests with Go changes
5. When investigating lost error context in logs

**This skill is MANDATORY because:**
- Prevents error chain loss through improper wrapping (CRITICAL)
- Ensures meaningful error messages for debugging (CRITICAL)
- Catches error swallowing that hides bugs (CRITICAL)
- Enforces RMS Go standards (non-negotiable)
- Improves production debugging and incident response

**ENFORCEMENT:**

**P0 Violations (Critical - Immediate Failure):**
- Using `%v` or `%s` instead of `%w` for error wrapping (DESTROYS error chain)
- Silent error ignoring without comment or justification
- Panic in non-initialization code (CRITICAL risk)
- Error returned without any context (impossible to debug)

**P1 Violations (High - Quality Failure):**
- Insufficient error context (missing IDs or relevant information)
- Inconsistent error message formatting
- Unwrapped error returns (naked `return err`)
- Custom error types without justification
- Missing error checks (obvious unchecked errors)

**P2 Violations (Medium - Efficiency Loss):**
- Not suggesting error message improvements
- Missing suggestions for error chain preservation
- Unclear error wrapping explanation

**Blocking Conditions:**
- Errors must be wrapped with `%w` (not `%v`)
- Every error assignment must be checked or justified
- No panics outside initialization
- Error messages must include context

---

## Purpose

Audit Go code for error handling best practices based on RMS Go coding standards. This skill ensures errors are properly wrapped, context is preserved, and error handling follows idiomatic Go patterns.

## When to Use This Skill

- **Before committing Go code** - As part of quality checks
- **Debugging error-related issues** - When errors lack context
- **Code review preparation** - Before submitting PRs
- **Production error analysis** - When investigating lost error context

## What This Skill Checks

### 1. Error Wrapping with %w (Priority: CRITICAL)
**Golden Rule**: Always wrap errors with `fmt.Errorf(..., %w, err)` to preserve error chain.

**Good Pattern**:
```go
func FetchTask(ctx rms.Ctx, id string) (*Task, error) {
    task, err := db.GetTask(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("failed to fetch task %s: %w", id, err)
    }
    return task, nil
}
```

**Bad Patterns**:
```go
// ❌ Using %v (destroys error chain)
return nil, fmt.Errorf("failed to fetch task: %v", err)

// ❌ No wrapping at all
return nil, err
```

### 2. Error Context (Priority: HIGH)
**Golden Rule**: Error messages must provide enough context to debug without source code.

**Good Context**:
```go
return fmt.Errorf("failed to update task %s for partner %s: %w", taskID, partnerID, err)
```

**Bad Context**:
```go
return fmt.Errorf("operation failed: %w", err) // Too vague
```

### 3. Error Message Format (Priority: MEDIUM)
**Golden Rule**: Lowercase start, no trailing punctuation, present tense, include identifiers.

### 4. Error Swallowing (Priority: CRITICAL)
**Golden Rule**: Never silently ignore errors without comment.

**Unacceptable**:
```go
err := doSomething() // Silent ignore - NO!
```

**Acceptable**:
```go
if err != nil {
    return fmt.Errorf("operation failed: %w", err) // Return it
}

if err := cache.Set(key, value); err != nil {
    logger.Warn("cache set failed", "error", err) // Log it
}

_ = file.Close() // Error handled in defer - documented
```

### 5. Panic Usage (Priority: CRITICAL)
**Golden Rule**: No panics except during startup/initialization.

**Unacceptable**:
```go
func ProcessTask(task *Task) {
    if task == nil {
        panic("task is nil") // Return error instead!
    }
}
```

## Step-by-Step Execution

### Step 1: Identify Go Files to Audit
```bash
find . -name "*.go" -not -path "*/vendor/*" -not -path "*/mock*" -not -path "*_test.go"
```

### Step 2: Read Target Go Files
Examine files focusing on:
- Error handling blocks (`if err != nil`)
- Error creation (`errors.New`, `fmt.Errorf`)
- Function returns with error types
- Panic statements

### Step 3: Analyze Error Handling Patterns

**A. Error Wrapping**
1. Find all `fmt.Errorf` calls with error arguments
2. Check if using `%w` (good) or `%v/%s` (bad)
3. Flag all instances using `%v` or `%s` with error arguments

**B. Error Context**
1. Examine error message text
2. Verify it includes operation, resource IDs, state info
3. Flag vague messages like "error", "failed", "operation failed"

**C. Error Swallowing**
1. Find all error assignments (`err :=`, `err =`)
2. Verify every assigned error is checked
3. For `_`, verify explanatory comment exists
4. Flag any unchecked errors

**D. Panic Usage**
1. Find all `panic()` calls
2. Verify they only appear in init() or main() startup
3. Flag any panic in regular function bodies

### Step 4: Generate Report

```markdown
## Error Handling Audit: [file_path]

### 🚨 CRITICAL Issues

#### Error Wrapping with %v Instead of %w
- **Function**: `FetchTask` ([file:line])
  - **Location**: Line X: `fmt.Errorf("failed: %v", err)`
  - **Fix**: Change to `fmt.Errorf("failed: %w", err)`

#### Error Swallowing
- **Function**: `ProcessTask` ([file:line])
  - **Location**: Line X: `err := doSomething()`
  - **Fix**: Add error check or use `_` with comment

#### Panic in Runtime Code
- **Function**: `UpdateTask` ([file:line])
  - **Location**: Line X: `panic("task is nil")`
  - **Fix**: Return error instead

### ⚠️ HIGH Priority Issues

#### Insufficient Error Context
- **Function**: `SaveTask` ([file:line])
  - **Location**: Line X: `fmt.Errorf("save failed: %w", err)`
  - **Fix**: Add IDs: `fmt.Errorf("failed to save task %s: %w", taskID, err)`
```

### Step 5: Summary Statistics

```markdown
## Summary
- Files audited: X
- Issues found: Z
  - CRITICAL: A (must fix before commit)
  - HIGH: B (should fix before commit)
- Clean functions: W
```

## Integration Points

This skill is invoked by:
- **`quality-check`** skill for Go projects
- **`safe-commit`** skill (via quality-check)

## Anti-Patterns

### ❌ Anti-Pattern: Using %v for Error Wrapping

**Wrong approach:**
```go
err := operation()
if err != nil {
    return fmt.Errorf("failed: %v", err)  // ❌ Destroys error chain
}
```

**Why wrong:**
- Error chain lost (errors.Is/errors.As fail)
- Stack trace information lost
- Debugging becomes very difficult

**Correct approach:**
```go
err := operation()
if err != nil {
    return fmt.Errorf("operation context: %w", err)  // ✅ Preserves chain
}
```

---

### ❌ Anti-Pattern: Silently Ignoring Errors

**Wrong approach:**
```go
_ = file.Close() // ❌ No explanation
```

**Correct approach:**
```go
_ = file.Close() // Error already handled in defer
```

---

## References

**Based on:**
- CLAUDE.md Section 3 (Available Skills Reference - error-handling-audit)
- RMS Go Coding Standards: Error Handling
- Go Blog: Error Wrapping

**Related skills:**
- `quality-check` - Invokes this skill for Go projects
- `control-flow-check` - Companion skill for control patterns
