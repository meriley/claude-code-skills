---
name: Migration Guide Writer
description: Creates migration guides following Diátaxis How-To pattern. Maps old/new APIs with before/after examples, documents breaking changes. Zero fabrication tolerance.
version: 1.0.0
---

# ⚠️ MANDATORY: Migration Guide Writer Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. After breaking changes to public APIs
2. During major version releases
3. When migrating to new libraries/frameworks
4. System replacements or rewrites
5. Significant architecture changes affecting users
6. User requests: "write migration guide for v2"

**This skill is MANDATORY because:**
- Helps users transition to new APIs (critical for adoption)
- Prevents frustration from breaking changes
- Documents mapping between old and new systems
- Provides working before/after examples
- Reduces support burden for migration questions

**ENFORCEMENT:**

**P0 Violations (Critical - Immediate Failure):**
- Documenting APIs that don't actually exist (FABRICATION)
- Incorrect before/after examples (won't work)
- Unverified performance claims
- Missing breaking changes documentation
- Example code that references non-existent methods

**P1 Violations (High - Quality Failure):**
- Incomplete migration path (missing key changes)
- Missing troubleshooting section
- Unclear problem-oriented structure
- No step-by-step instructions
- Missing deprecation timeline

**P2 Violations (Medium - Efficiency Loss):**
- Not organized by problem/use case
- Missing common migration patterns
- Unclear error messages or solutions

**Blocking Conditions:**
- ALL code examples must be verified and tested
- EVERY API reference must exist in source
- Breaking changes must be explicitly documented
- Migration path must be complete and working

---

## Purpose

Create problem-oriented migration guides following the Diátaxis How-To pattern. Maps old APIs to new APIs with before/after examples, documents breaking changes, provides troubleshooting.

## When to Use This Skill

- **After breaking changes** - Help users migrate to new API
- **Major version releases** - Document upgrade path
- **System replacements** - Guide transition to new system
- **Architecture changes** - Explain impact and migration
- **Library upgrades** - Show upgrade and usage changes

## Guide Structure (Diátaxis How-To Pattern)

### 1. Overview
- What's changing and why
- Impact assessment
- Timeline for migration
- Support duration for old version

### 2. Before/After API Mapping
```
## Migration: Task API v1 to v2

### Creating Tasks
**Before (v1):**
```go
task := CreateTask(title, description)
```

**After (v2):**
```go
task, err := taskService.Create(ctx, &CreateTaskRequest{
    Title: title,
    Description: description,
})
```

**Why changed:** Added context support, better error handling, request structuring
```

### 3. Step-by-Step Migration Guide
1. Update imports
2. Update function calls
3. Handle new error patterns
4. Update configurations
5. Test thoroughly

### 4. Breaking Changes Document
- What changed and why
- How to fix it
- Deprecation timeline
- Compatibility matrix

### 5. Common Issues & Troubleshooting
```
## Common Issues

**Issue: "function Create not found"**
- **Cause**: v1 function no longer exists
- **Solution**: Update to `taskService.Create()` with new signature
- **Reference**: See [Before/After](#beforeafter) section
```

### 6. Working Examples
- Complete before/after code
- All examples must be verified
- Test examples before documenting

## Integration Points

Works with:
- **api-doc-writer** - New API reference (guide links to this)
- **tutorial-writer** - Getting started with new system
- **api-documentation-verify** - Verify examples work

## Anti-Patterns

### ❌ Anti-Pattern: Fabricated APIs in Examples

**Wrong approach:**
```
Old Code:
taskService.CreateTask(params)

New Code:
taskService.createNewTask(newParams) // This method doesn't exist!
```

**Correct approach:** Verify all APIs exist
```
Old Code:
CreateTask(title, description)

New Code:
taskService.Create(ctx, &CreateTaskRequest{Title: title, Description: description})
// ✅ Verified against source code
```

---

### ❌ Anti-Pattern: Incomplete Breaking Changes

**Wrong approach:**
```
"Breaking changes: API structure updated"
(Doesn't explain what changed or how to fix)
```

**Correct approach:** Explicit detailed breaking changes
```
**Breaking Changes:**

1. Function signature changed
   - Old: `CreateTask(title, description)`
   - New: `taskService.Create(ctx, *CreateTaskRequest)`
   - Fix: Add context parameter, use request struct

2. Error handling changed
   - Old: Returns bool for success
   - New: Returns error for failures
   - Fix: Check err != nil instead of bool result
```

---

## Success Criteria

Migration guide is complete when:
- ✅ All code examples verified and tested
- ✅ Breaking changes explicitly documented
- ✅ Before/after examples for all major changes
- ✅ Step-by-step migration instructions
- ✅ Common issues and troubleshooting
- ✅ Migration timeline/deprecation info
- ✅ All APIs referenced actually exist
- ✅ Examples use real, correct imports

## References

**Based on:**
- CLAUDE.md Section 3 (Available Skills Reference - migration-guide-writer)
- Diátaxis Framework: https://diataxis.fr/how-to-guides/

**Related skills:**
- `api-doc-writer` - Reference for new APIs
- `tutorial-writer` - Getting started with new system
- `api-documentation-verify` - Verify example accuracy
