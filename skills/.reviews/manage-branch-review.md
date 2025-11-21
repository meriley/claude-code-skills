# Skill Review: manage-branch
**Reviewer:** Claude Code
**Date:** 2025-01-21
**Version Reviewed:** 1.0.0

## Summary
Skill has BLOCKER frontmatter issues (name doesn't match directory, uses spaces). File is 410 lines (under 500 limit). Description is acceptable but could be more specific. Content quality is good with clear workflows and examples.

**Recommendation:** ❌ **FAIL**

## Findings by Category

### Structure [✅ PASS]
- [x] Directory structure correct
- [x] File naming conventions followed
- [x] Under 500 lines (410 lines) ✓

**Line count:** 410 lines

**Issues:**
None

**Positive highlights:**
- Good line count (410 lines - comfortably under 500)
- Clean file structure
- Well-organized operations (Create, Switch, Validate)
- No supporting files needed (appropriate for size)

---

### Frontmatter [❌ FAIL]
- [x] Valid YAML
- [ ] Name field INCORRECT
- [x] Description acceptable but could be more specific
- [ ] Missing version note

**Frontmatter:**
```yaml
---
name: Manage Branch
description: Creates and manages git branches with enforced mriley/ prefix naming convention. Validates branch names, switches branches safely, and handles branch creation with proper base branch selection.
version: 1.0.0
---
```

**Issues:**
1. [BLOCKER] Name "Manage Branch" doesn't match directory name "manage-branch"
2. [BLOCKER] Name uses spaces and capital letters (should be "manage-branch")
3. [MAJOR] Description could include WHEN triggers for better discoverability

**Required rewrite:**
```yaml
---
name: manage-branch
description: Creates and manages git branches with enforced mriley/ prefix naming convention. Validates branch names, switches branches safely, handles branch creation with proper base branch selection. Use when creating feature/fix branches, switching branches, or as part of PR creation workflow.
version: 1.0.0
---
```

---

### Content Quality [✅ PASS]
- [x] Clear purpose and workflows
- [x] Concrete examples provided
- [x] Consistent terminology
- [x] One default approach per operation

**Issues:**
1. [MINOR] Could add troubleshooting section for common branch issues

**Positive highlights:**
- Clear three-operation structure (Create, Switch, Validate)
- Excellent branch naming examples (correct and incorrect)
- Good handling of uncommitted changes
- Strong validation rules with examples
- Good error handling sections
- Clear integration points documented

---

### Instruction Clarity [✅ PASS]
- [x] Clear sequential steps
- [x] Code examples complete and runnable
- [x] Expected outputs documented
- [x] Validation checkpoints provided

**Issues:**
None

**Positive highlights:**
- Step-by-step workflows for each operation
- Concrete bash commands
- Good examples of branch name patterns
- Clear error scenarios with solutions
- Good use of options when user needs to decide

---

### Testing [⚠️ UNKNOWN]
- [ ] Test scenarios not documented
- [ ] Fresh instance testing not documented
- [ ] Multi-model testing not done

**Issues:**
1. [CRITICAL] No documented test scenarios
2. [CRITICAL] No testing documentation provided

**Required before release:**
- Test scenario 1: Create branch with valid name
- Test scenario 2: Create branch with invalid name (correction)
- Test scenario 3: Switch branch with uncommitted changes
- Test scenario 4: Validate and rename existing branch
- Document across models

---

## Blockers (must fix)
1. Name field "Manage Branch" must be changed to "manage-branch" to match directory
2. Name field uses spaces and capitals - must use lowercase-with-hyphens

## Critical Issues (should fix)
1. No documented test scenarios or testing matrix

## Major Issues (fix soon)
1. Description missing WHEN triggers for discoverability

## Minor Issues (nice to have)
1. Could add troubleshooting section for common branch errors
2. Could add more examples of branch naming scenarios

## Positive Highlights
- Clean three-operation structure (Create, Switch, Validate)
- Excellent branch naming examples and validation rules
- Good handling of uncommitted changes with user options
- Clear error handling for common scenarios
- Strong integration documentation
- Good quick reference section
- Appropriate line count (410 lines)

## Recommendations

### Priority 1 (Required before release - BLOCKERS)
1. **Fix name field immediately** - Change from "Manage Branch" to "manage-branch"
   ```yaml
   name: manage-branch  # Must match directory name exactly
   ```

2. **Fix name format** - Use lowercase-with-hyphens only
   - Current: "Manage Branch"
   - Required: "manage-branch"

### Priority 2 (Required before release - CRITICAL)
1. **Complete testing documentation**:
   - Create 4+ test scenarios
   - Test branch creation/validation/switching
   - Test error handling
   - Document across models

2. **Improve description** - Add WHEN triggers:
   ```yaml
   description: Creates and manages git branches with enforced mriley/ prefix naming convention. Validates branch names, switches branches safely, handles branch creation with proper base branch selection. Use when creating feature/fix branches, switching branches, or as part of PR creation workflow.
   ```

### Priority 3 (Nice to have)
1. Add troubleshooting section:
   ```markdown
   ## Troubleshooting

   **Branch name rejected:**
   - Check for mriley/ prefix
   - Use lowercase-with-hyphens format
   - Avoid special characters

   **Cannot switch branches:**
   - Commit or stash uncommitted changes
   - Check for merge conflicts
   ```

2. Add more branch naming examples for edge cases

## Next Steps
- [ ] Address blocker: Fix name field
- [ ] Address blocker: Fix name format
- [ ] Address critical: Complete testing
- [ ] Consider adding troubleshooting section
- [ ] Re-review after fixes
- [ ] Approve for merge

**Estimated effort:** 1-2 hours (mostly testing documentation)

---

## Overall Assessment

**Total Issues:**
- Blockers: 2
- Critical: 1
- Major: 1
- Minor: 2

**Reasoning:**
This skill has good content quality and structure with a comfortable 410-line length. However, two BLOCKER frontmatter issues prevent release - the name field MUST match "manage-branch" exactly using lowercase-with-hyphens format.

The three-operation structure (Create, Switch, Validate) is clear and well-documented. Branch naming examples are excellent with both correct and incorrect patterns shown. Error handling is good with user options provided.

Once frontmatter is fixed and testing is documented, this skill will be ready for release. The core workflows and validation logic are already solid.
