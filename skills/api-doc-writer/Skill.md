---
name: API Documentation Writer
description: Creates API reference documentation following Diátaxis pattern. Verifies every method signature from source code with zero fabrication tolerance. For APIs, packages, public interfaces.
version: 1.0.0
---

# ⚠️ MANDATORY: API Documentation Writer Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. When documenting new package/module public APIs
2. When updating documentation for API changes
3. When refreshing outdated API documentation
4. Before product releases documenting public APIs
5. User requests: "document the [API/package]"

**This skill is MANDATORY because:**
- Prevents fabricated methods from documentation (ZERO TOLERANCE)
- Ensures signatures exactly match source code (CRITICAL)
- Creates comprehensive, verifiable API reference
- Maintains single source of truth (code)
- Enables users to understand APIs correctly

**ENFORCEMENT:**

**P0 Violations (Critical - Immediate Failure):**
- Documenting methods that don't exist in source code (FABRICATION)
- Using incorrect method signatures (type/parameter mismatch)
- Providing invalid code examples that won't compile
- Making unverified performance claims without benchmarks
- Not citing source file locations for documented methods

**P1 Violations (High - Quality Failure):**
- Incomplete API coverage (missing public methods)
- Using marketing language instead of technical descriptions
- Missing error condition documentation
- Unclear parameter descriptions
- Not verifying examples against source code

**P2 Violations (Medium - Efficiency Loss):**
- Not using consistent documentation structure
- Missing return type documentation
- No constraint documentation for parameters

**Blocking Conditions:**
- EVERY method signature must be verified against source
- EVERY example must use real imports
- NO fabricated methods (ever)
- NO marketing language or buzzwords
- Source file references required for all entries

---

## Purpose

Create comprehensive, accurate API reference documentation by reading source code and extracting exact method signatures. Follows the Diátaxis Reference pattern for information-oriented documentation with zero tolerance for fabricated methods or incorrect signatures.

## When to Use This Skill

- **New package/module added** - Document public APIs
- **Major API refactor** - Update documentation to match changes
- **Existing docs outdated** - Refresh documentation from source
- **After breaking changes** - Document new API signatures
- **User requests** - "document the [package] API"
- **Before release** - Ensure complete API coverage

[See full skill documentation in source for detailed workflow, templates, verification checklist, and examples]

## Critical Rules (Zero Tolerance)

### P0 - CRITICAL Violations (Must Fix Before Documentation Released)
1. **Fabricated Methods** - Methods that don't exist in source code
2. **Wrong Signatures** - Parameter types, names, or order don't match source
3. **Invalid Examples** - Code that won't compile or uses fake imports
4. **Unverified Performance Claims** - Numbers without benchmark evidence

### P1 - HIGH Violations (Should Fix)
5. **Missing Source References** - Not citing which file/method documented
6. **Incomplete Coverage** - Missing public methods
7. **Marketing Language** - Buzzwords instead of technical descriptions

### P2 - MEDIUM Violations
8. **Structural Issues** - Not following template consistently

## Integration with Other Skills

Works with:
- **api-documentation-verify** - Verify docs for accuracy
- **migration-guide-writer** - Reference docs show new API signatures
- **tutorial-writer** - Tutorials link to reference for detailed info

## Anti-Patterns

### ❌ Anti-Pattern: Paraphrasing Signatures

**Wrong approach:**
```
func Create(params CreateParams) (Task, error)
```

**Correct approach:** Exact signature from source
```
func (s *TaskService) Create(ctx rms.Ctx, params *CreateTaskParams) (*entity.Task, error)
```

---

### ❌ Anti-Pattern: Fabricating Methods

**Wrong approach:**
```
TaskService.UpdateStatus - Updates the status of a task
(This method never existed in source!)
```

**Correct approach:** Only document methods that exist in source code

---

### ❌ Anti-Pattern: Invalid Examples

**Wrong approach:**
```go
task := CreateTask(params) // Won't compile - import missing
```

**Correct approach:** Complete, working example
```go
import "github.com/org/pkg/services"

service := services.NewTaskService(db)
task, err := service.Create(ctx, params)
```

---

## Success Criteria

Documentation is complete when:
- ✅ All public APIs discovered and documented
- ✅ All signatures verified against source code
- ✅ All examples use real imports and verified APIs
- ✅ No fabricated methods or wrong signatures
- ✅ Source references included for all entries
- ✅ Error conditions documented from code
- ✅ Verification checklist completed
- ✅ No marketing language or buzzwords

## References

**Based on:**
- CLAUDE.md Section 3 (Available Skills Reference - api-doc-writer)
- Diátaxis Framework: https://diataxis.fr/reference/

**Related skills:**
- `api-documentation-verify` - Verify docs accuracy
- `tutorial-writer` - Learning-oriented tutorials
- `migration-guide-writer` - Migration guides
