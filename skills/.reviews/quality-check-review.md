# Skill Review: quality-check
**Reviewer:** Claude Code
**Date:** 2025-01-21
**Version Reviewed:** 1.0.1

## Summary
Skill has BLOCKER frontmatter issues (name doesn't match directory, uses spaces). File exceeds 500 line recommendation at 510 lines. Description is verbose with enforcement language. Content is comprehensive but needs refactoring to extract language-specific details.

**Recommendation:** ❌ **FAIL**

## Findings by Category

### Structure [❌ FAIL]
- [x] Directory structure correct
- [x] File naming conventions followed
- [ ] Exceeds 500 line limit (510 lines) ✗

**Line count:** 510 lines

**Issues:**
1. [BLOCKER] File is 510 lines (exceeds 500 line optimal limit by 10 lines)

**Justification:**
The skill covers multiple languages with language-specific checks and deep audits. However, 510 lines is too long. Language-specific configurations (lines 98-267) should be extracted to REFERENCE.md or split into language-specific reference files.

**Recommended refactoring:**
- Main file: 350 lines (workflow, detection logic, integration)
- REFERENCE.md: Language-specific tool commands and configurations

---

### Frontmatter [❌ FAIL]
- [x] Valid YAML
- [ ] Name field INCORRECT
- [ ] Description too long and verbose

**Frontmatter:**
```yaml
---
name: Code Quality Check
description: ⚠️ MANDATORY - Automatically invoked by safe-commit. Runs language-specific linting, formatting, static analysis, and type checking. Treats linter issues as build failures that MUST be fixed before commit. Auto-fixes when possible. NEVER run linters manually.
version: 1.0.1
---
```

**Issues:**
1. [BLOCKER] Name "Code Quality Check" doesn't match directory name "quality-check"
2. [BLOCKER] Name uses spaces and capital letters (should be "quality-check")
3. [CRITICAL] Description is 308 characters and overly verbose
4. [MAJOR] Description has marketing-style urgency ("⚠️ MANDATORY", all caps)

**Required rewrite:**
```yaml
---
name: quality-check
description: Language-specific linting, formatting, static analysis, and type checking. Detects project type and runs appropriate tools (ESLint, golangci-lint, black, etc.). Invokes specialized audits (control-flow-check, error-handling-audit, type-safety-audit, n-plus-one-detection). Automatically invoked by safe-commit.
version: 1.0.1
---
```

---

### Content Quality [⚠️ NEEDS WORK]
- [x] Clear purpose and workflows
- [x] Concrete examples for multiple languages
- [x] Consistent terminology
- [x] Integration with language-specific audit skills

**Issues:**
1. [BLOCKER] File exceeds 500 lines (should extract to REFERENCE.md)
2. [MAJOR] Language-specific sections (170 lines) should be in REFERENCE.md
3. [MAJOR] Tool installation/configuration sections could be condensed
4. [MINOR] Repetitive structure across languages

**Positive highlights:**
- Excellent multi-language support
- Strong integration with specialized audit skills
- Clear detection logic for project types
- Good auto-fix emphasis
- Comprehensive language coverage
- Good deep audit integration (control-flow, error-handling, type-safety, n-plus-one)

---

### Instruction Clarity [✅ PASS]
- [x] Clear sequential steps
- [x] Code examples complete and runnable
- [x] Expected outputs documented

**Issues:**
None

**Positive highlights:**
- Clear workflow structure
- Concrete commands for each language
- Good parallel execution guidance
- Clear integration with deep audit skills
- Strong reporting formats

---

### Testing [⚠️ UNKNOWN]
- [ ] Test scenarios not documented
- [ ] Fresh instance testing not documented
- [ ] Multi-model testing not done

**Issues:**
1. [CRITICAL] No documented test scenarios
2. [CRITICAL] No testing documentation provided

**Required before release:**
- Test scenario 1: Single language project (Go, TypeScript, Python)
- Test scenario 2: Multi-language project
- Test scenario 3: Auto-fixable issues
- Test scenario 4: Manual fix required
- Test scenario 5: Deep audit integration (Go, TypeScript)
- Document across models

---

## Blockers (must fix)
1. Name field "Code Quality Check" must be changed to "quality-check" to match directory
2. Name field uses spaces and capitals - must use lowercase-with-hyphens
3. File is 510 lines - MUST reduce to under 500 by extracting to REFERENCE.md

## Critical Issues (should fix)
1. No documented test scenarios or testing matrix
2. Description too long (308 chars) with excessive enforcement language

## Major Issues (fix soon)
1. Language-specific sections (170 lines) should be extracted to REFERENCE.md
2. Tool installation/configuration sections could be condensed
3. Description uses marketing-style urgency markers and all caps

## Minor Issues (nice to have)
1. Repetitive structure across languages could be templatized
2. Could add more examples of auto-fix scenarios

## Positive Highlights
- Excellent multi-language support (Node.js, Go, Python, Rust, Java)
- Strong integration with specialized audit skills (control-flow-check, error-handling-audit, type-safety-audit, n-plus-one-detection)
- Clear project type detection logic
- Good auto-fix emphasis with re-verification
- Comprehensive language coverage
- Strong deep audit integration section
- Good combined reporting format

## Recommendations

### Priority 1 (Required before release - BLOCKERS)
1. **Fix name field immediately** - Change from "Code Quality Check" to "quality-check"
   ```yaml
   name: quality-check  # Must match directory name exactly
   ```

2. **Fix name format** - Use lowercase-with-hyphens only
   - Current: "Code Quality Check"
   - Required: "quality-check"

3. **Reduce file length to under 500 lines** - Extract to REFERENCE.md:
   - Lines 98-267: Language-specific tool commands → REFERENCE.md
   - Lines 460-510: Tool installation/configuration → REFERENCE.md
   - Keep workflow, detection, integration in main file
   - Add signposts to REFERENCE.md
   - Target: 350-380 lines in Skill.md

### Priority 2 (Required before release - CRITICAL)
1. **Improve description** - Remove enforcement language, reduce to ~300 chars:
   ```yaml
   description: Language-specific linting, formatting, static analysis, and type checking. Detects project type and runs appropriate tools (ESLint, golangci-lint, black, etc.). Invokes specialized audits (control-flow-check, error-handling-audit, type-safety-audit, n-plus-one-detection). Automatically invoked by safe-commit.
   ```

2. **Complete testing documentation**:
   - Test single and multi-language projects
   - Test auto-fix scenarios
   - Test deep audit integration
   - Document across models

### Priority 3 (Recommended)
1. **Create REFERENCE.md** with extracted content:
   ```markdown
   # Language-Specific Quality Checks

   ## Node.js / TypeScript
   [Commands and configuration]

   ## Go
   [Commands and configuration]

   ## Python
   [Commands and configuration]

   ## Rust
   [Commands and configuration]

   ## Java
   [Commands and configuration]

   # Tool Installation Guide
   [Installation instructions]
   ```

2. **Add signposting in main file**:
   ```markdown
   For language-specific commands, see REFERENCE.md.
   For tool installation, see REFERENCE.md.
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
- Major: 3
- Minor: 2

**Reasoning:**
This skill provides excellent multi-language support with strong integration of specialized audit skills. However, three BLOCKER issues prevent release:

1. Name field must be changed to "quality-check"
2. Name must use lowercase-with-hyphens format
3. File must be under 500 lines (currently 510)

The 510-line length is NOT justified - language-specific tool commands and configurations should be extracted to REFERENCE.md. This will make the main file focused on workflow and integration while keeping language specifics easily accessible.

The deep audit integration (control-flow-check, error-handling-audit, type-safety-audit, n-plus-one-detection) is excellent and shows good skill composition. Once blockers are fixed and testing is documented, this skill will be excellent.
