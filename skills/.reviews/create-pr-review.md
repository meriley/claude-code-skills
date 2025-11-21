# Skill Review: create-pr
**Reviewer:** Claude Code
**Date:** 2025-01-21
**Version Reviewed:** 1.0.1

## Summary
Skill has BLOCKER frontmatter issues (name doesn't match directory, uses spaces). File exceeds 500 line recommendation at 541 lines. Description is excessively verbose. Content is comprehensive but needs significant refactoring. Good PR description integration.

**Recommendation:** ❌ **FAIL**

## Findings by Category

### Structure [❌ FAIL]
- [x] Directory structure correct
- [x] File naming conventions followed
- [ ] Exceeds 500 line limit (541 lines) ✗

**Line count:** 541 lines

**Issues:**
1. [BLOCKER] File is 541 lines (exceeds 500 line optimal limit by 41 lines)

**Justification:**
The skill orchestrates branch management, commits, and PR creation. However, 541 lines is too long. Error handling (lines 372-431), PR title generation (lines 331-370), and multi-commit handling (lines 461-478) should be extracted to REFERENCE.md.

**Recommended refactoring:**
- Main file: 380 lines (core workflow + key examples)
- REFERENCE.md: Extended error handling, title generation rules, multi-commit scenarios

---

### Frontmatter [❌ FAIL]
- [x] Valid YAML
- [ ] Name field INCORRECT
- [ ] Description excessively long and verbose

**Frontmatter:**
```yaml
---
name: Create Pull Request
description: ⚠️ MANDATORY - YOU MUST invoke this skill ONLY when user says "raise/create/draft PR". ONLY auto-commit scenario. Creates/validates branch with mriley/ prefix, commits all changes (invokes safe-commit), pushes to remote, creates PR with proper format. NEVER create PRs manually.
version: 1.0.1
---
```

**Issues:**
1. [BLOCKER] Name "Create Pull Request" doesn't match directory name "create-pr"
2. [BLOCKER] Name uses spaces and capital letters (should be "create-pr")
3. [CRITICAL] Description is 338 characters and excessively verbose
4. [MAJOR] Description has multiple enforcement statements and all caps warnings

**Required rewrite:**
```yaml
---
name: create-pr
description: Complete pull request creation workflow. Creates/validates branch with mriley/ prefix, commits changes via safe-commit (auto-commit mode), pushes to remote, creates PR with verified description. Invokes pr-description-writer for accurate PR content. Use when user says "raise/create/draft PR".
version: 1.0.1
---
```

---

### Content Quality [⚠️ NEEDS WORK]
- [x] Clear purpose and workflows
- [x] Concrete examples provided
- [x] Consistent terminology
- [x] Integration with pr-description-writer documented

**Issues:**
1. [BLOCKER] File exceeds 500 lines (should extract to REFERENCE.md)
2. [MAJOR] Error handling section too detailed (60 lines) - extract to REFERENCE.md
3. [MAJOR] PR title generation section (40 lines) - extract to REFERENCE.md
4. [MAJOR] Multi-commit section (20 lines) - extract to REFERENCE.md
5. [MINOR] Repetitive skill guard patterns

**Positive highlights:**
- Excellent integration with pr-description-writer skill (Step 6)
- Clear workflow with check-history, manage-branch, safe-commit
- Good handling of PR draft vs final
- Strong error scenarios covered
- Good examples of PR title generation

---

### Instruction Clarity [✅ PASS]
- [x] Clear sequential steps
- [x] Code examples complete and runnable
- [x] Expected outputs documented

**Issues:**
None

**Positive highlights:**
- Step-by-step workflow is very clear
- Good use of heredoc for PR body
- Clear integration points with other skills
- Excellent pr-description-writer integration explanation
- Good examples of gh pr create commands

---

### Testing [⚠️ UNKNOWN]
- [ ] Test scenarios not documented
- [ ] Fresh instance testing not documented
- [ ] Multi-model testing not done

**Issues:**
1. [CRITICAL] No documented test scenarios
2. [CRITICAL] No testing documentation provided

**Required before release:**
- Test scenario 1: Normal PR creation with valid branch
- Test scenario 2: PR creation requiring new branch
- Test scenario 3: PR creation with uncommitted changes
- Test scenario 4: PR description verification
- Document across models

---

## Blockers (must fix)
1. Name field "Create Pull Request" must be changed to "create-pr" to match directory
2. Name field uses spaces and capitals - must use lowercase-with-hyphens
3. File is 541 lines - MUST reduce to under 500 by extracting to REFERENCE.md

## Critical Issues (should fix)
1. No documented test scenarios or testing matrix
2. Description too long (338 chars) with excessive enforcement language

## Major Issues (fix soon)
1. Error handling section (60 lines) should be extracted to REFERENCE.md
2. PR title generation section (40 lines) should be extracted to REFERENCE.md
3. Multi-commit handling (20 lines) should be extracted to REFERENCE.md
4. Description uses multiple all caps warnings

## Minor Issues (nice to have)
1. Repetitive skill guard sections could be consolidated
2. Could add more examples of PR descriptions

## Positive Highlights
- Excellent integration with pr-description-writer skill for verified descriptions
- Clear workflow orchestrating multiple dependent skills
- Strong branch validation with manage-branch
- Good handling of draft vs final PR distinction
- Comprehensive error handling for all failure scenarios
- Good PR title generation logic
- Clear auto-commit exception documentation

## Recommendations

### Priority 1 (Required before release - BLOCKERS)
1. **Fix name field immediately** - Change from "Create Pull Request" to "create-pr"
   ```yaml
   name: create-pr  # Must match directory name exactly
   ```

2. **Fix name format** - Use lowercase-with-hyphens only
   - Current: "Create Pull Request"
   - Required: "create-pr"

3. **Reduce file length to under 500 lines** - Extract to REFERENCE.md:
   - Lines 372-431: Extended error handling → REFERENCE.md
   - Lines 331-370: PR title generation rules → REFERENCE.md
   - Lines 461-478: Multi-commit handling → REFERENCE.md
   - Lines 489-520: Best practices → REFERENCE.md
   - Keep core workflow (Steps 1-8) in main file
   - Add signposts to REFERENCE.md
   - Target: 380-400 lines in Skill.md

### Priority 2 (Required before release - CRITICAL)
1. **Improve description** - Remove enforcement language, reduce to ~250 chars:
   ```yaml
   description: Complete pull request creation workflow. Creates/validates branch with mriley/ prefix, commits changes via safe-commit (auto-commit mode), pushes to remote, creates PR with verified description. Invokes pr-description-writer for accurate PR content. Use when user says "raise/create/draft PR".
   ```

2. **Complete testing documentation**:
   - Test normal PR creation workflow
   - Test branch creation/validation
   - Test PR description generation and verification
   - Test error handling scenarios
   - Document across models

### Priority 3 (Recommended)
1. **Create REFERENCE.md** with extracted content:
   ```markdown
   # Extended Error Handling
   [60 lines from current Skill.md]

   # PR Title Generation Rules
   [40 lines from current Skill.md]

   # Multi-Commit PR Scenarios
   [20 lines from current Skill.md]

   # Best Practices
   [30 lines from current Skill.md]
   ```

2. **Add signposting in main file**:
   ```markdown
   For detailed error handling, see REFERENCE.md.
   For PR title generation rules, see REFERENCE.md.
   ```

## Next Steps
- [ ] Address blocker: Fix name field
- [ ] Address blocker: Fix name format
- [ ] Address blocker: Extract content to REFERENCE.md to get under 500 lines
- [ ] Address critical: Complete testing
- [ ] Address critical: Improve description
- [ ] Re-review after fixes
- [ ] Approve for merge

**Estimated effort:** 3-4 hours (extraction + testing)

---

## Overall Assessment

**Total Issues:**
- Blockers: 3
- Critical: 2
- Major: 4
- Minor: 2

**Reasoning:**
This is a critical coordinator skill with excellent workflow design and strong integration with pr-description-writer. However, three BLOCKER issues prevent release:

1. Name field must be changed to "create-pr"
2. Name must use lowercase-with-hyphens format
3. File must be under 500 lines (currently 541)

The 541-line length is NOT justified - the skill should extract detailed error handling, title generation rules, and multi-commit scenarios to REFERENCE.md. This will make the main file focused on the core workflow while keeping detailed references accessible.

The integration with pr-description-writer in Step 6 is excellent and demonstrates good skill composition. Once blockers are fixed and testing is documented, this skill will be ready for release.
