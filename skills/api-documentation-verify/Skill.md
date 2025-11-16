---
name: API Documentation Verification
description: Verifies API documentation against source code: eliminates fabricated claims, validates examples. Zero tolerance for unverified claims or non-runnable code.
version: 1.0.0
---

# ⚠️ MANDATORY: API Documentation Verification Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Before committing any API documentation
2. During API documentation reviews
3. After updating API references
4. Before releasing new API versions
5. When verifying migration guides or tutorials

**This skill is MANDATORY because:**
- Prevents fabricated or incorrect documentation from reaching users (CRITICAL)
- Catches unverified claims and marketing language (ZERO TOLERANCE)
- Validates code examples actually work (CRITICAL)
- Ensures documentation matches source code exactly
- Builds user trust in documentation

**ENFORCEMENT:**

**P0 Violations (Critical - Immediate Failure):**
- Fabricated methods or APIs (ZERO TOLERANCE)
- Incorrect method signatures
- Code examples that won't compile/run
- Unverified performance claims
- Marketing language and buzzwords

**P1 Violations (High - Quality Failure):**
- Incomplete API coverage
- Missing error conditions
- Vague parameter descriptions
- No source code references

**P2 Violations (Medium - Efficiency Loss):**
- Inconsistent formatting
- Redundant descriptions
- Unclear examples

**Blocking Conditions:**
- ALL methods must exist in source code
- ALL signatures must match exactly
- ALL examples must be verified working
- NO unverified claims allowed

---

## Purpose

Verify API documentation against source code to eliminate fabricated claims, ensure accuracy, and validate examples. Zero tolerance for unverified claims, marketing language, or non-runnable code examples.

## Verification Checklist

### Source Code Verification (P0 - CRITICAL)
- ✅ Every documented method exists in source code
- ✅ All method signatures exactly match source
- ✅ All parameter types match source exactly
- ✅ All return types match source exactly
- ✅ Parameter names match source (not changed for clarity)
- ✅ All type definitions exactly match source

### Example Verification (P0 - CRITICAL)
- ✅ All code examples use real imports
- ✅ All examples use verified API signatures
- ✅ No fabricated methods in examples
- ✅ Examples tested to verify they work
- ✅ Examples produce expected output

### Completeness (P1 - HIGH)
- ✅ All public methods documented
- ✅ All public types documented
- ✅ All public constants documented
- ✅ Source file references included
- ✅ Error conditions documented

### Quality (P2 - MEDIUM)
- ✅ No marketing language ("blazing fast", "enterprise-grade")
- ✅ No decorative emojis
- ✅ Consistent structure across entries
- ✅ Technical descriptions (not tutorials)
- ✅ Source references use method names (not line numbers)

## Verification Workflow

### Step 1: Read Documentation
Examine documentation to understand what's being claimed.

### Step 2: Verify Each Claimed Method
For each documented method:
1. Find the exact method in source code
2. Copy exact signature
3. Compare with documentation
4. Flag any discrepancies

### Step 3: Test Code Examples
For each code example:
1. Extract complete example code
2. Verify all imports are real
3. Attempt to compile/run
4. Verify output matches documentation

### Step 4: Check for Claims
Identify any claims in documentation:
- Performance numbers
- Feature descriptions
- Behavior guarantees
- Error conditions

For each claim:
1. Verify against source code
2. If performance claim, verify benchmark exists
3. If behavior claim, verify in source logic
4. Flag unverified claims

### Step 5: Generate Report

**Pass Report:**
```
✅ Documentation Verification PASSED

- All 45 methods verified against source
- All 12 code examples tested and verified
- No fabricated methods or claims
- No marketing language detected
- Source references complete

Ready for release.
```

**Fail Report:**
```
❌ Documentation Verification FAILED

Critical Issues (P0):
1. Method "TaskService.UpdateStatus" doesn't exist in source
2. Code example in "Creating Tasks" won't compile (missing import)
3. Performance claim "10x faster" unverified (no benchmark)

High Priority Issues (P1):
4. Missing description for error condition
5. Signature mismatch in GetTask method

Fix these issues before release.
```

## Anti-Patterns

### ❌ Anti-Pattern: Trusting Documentation Without Verification

**Wrong approach:**
```
API documentation says "TaskService.UpdateStatus() exists"
Don't verify - just assume it's correct
Later: Method doesn't exist, users complain
```

**Correct approach:** Verify everything
```
Claim: "TaskService.UpdateStatus exists"
Action: Check source code
Result: Method doesn't exist - REMOVE from documentation
Action: Document only methods that actually exist
```

---

### ❌ Anti-Pattern: Code Examples Without Testing

**Wrong approach:**
```
Documentation example:
```go
user := User{Name: "John"}
user.Save() // Hope this works
```

**Correct approach:** Test examples
```
Documentation example:
```go
user := &User{Name: "John"}
err := service.Save(ctx, user)
if err != nil {
    return fmt.Errorf("failed: %w", err)
}
// ✅ Example tested and verified to work
```

---

## Success Criteria

Verification is complete when:
- ✅ All methods verified against source
- ✅ All signatures exactly match
- ✅ All examples tested and verified
- ✅ No fabricated methods
- ✅ No unverified claims
- ✅ No marketing language
- ✅ Source references complete
- ✅ Verification report generated

## References

**Based on:**
- CLAUDE.md Section 3 (Available Skills Reference - api-documentation-verify)
- Technical Documentation Expert verification patterns

**Related skills:**
- `api-doc-writer` - Creates documentation (this skill verifies)
- `tutorial-writer` - Creates tutorials (this skill verifies)
- `migration-guide-writer` - Creates guides (this skill verifies)
