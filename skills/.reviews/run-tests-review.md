# Skill Review: run-tests
**Reviewer:** Claude Code
**Date:** 2025-01-21
**Version Reviewed:** 1.0.1

## Summary
Skill has BLOCKER frontmatter issues (name doesn't match directory, uses spaces). File is 467 lines (under 500 but borderline). Description is excessively verbose with enforcement language. Content is comprehensive with good multi-language and multi-test-type coverage.

**Recommendation:** ❌ **FAIL**

## Findings by Category

### Structure [✅ PASS]
- [x] Directory structure correct
- [x] File naming conventions followed
- [x] Under 500 lines (467 lines) ✓

**Line count:** 467 lines

**Issues:**
None (borderline but acceptable)

**Positive highlights:**
- Acceptable line count (467 lines - under 500 limit)
- Clean file structure
- Well-organized by test type (Unit, Integration, E2E)
- No supporting files needed (appropriate for coordinator skill)

---

### Frontmatter [❌ FAIL]
- [x] Valid YAML
- [ ] Name field INCORRECT
- [ ] Description excessively long and verbose
- [x] Dependencies field present and appropriate

**Frontmatter:**
```yaml
---
name: Run Tests
description: ⚠️ MANDATORY - Automatically invoked by safe-commit. Executes comprehensive testing suite including unit tests (minimum 90% coverage), integration tests, and E2E tests (100% pass required). Reports coverage and failures. MUST pass before commit. NEVER run tests manually before commit.
version: 1.0.1
dependencies: Language-specific test frameworks (pytest, jest, go test, cargo test, etc.)
---
```

**Issues:**
1. [BLOCKER] Name "Run Tests" doesn't match directory name "run-tests"
2. [BLOCKER] Name uses spaces and capital letters (should be "run-tests")
3. [CRITICAL] Description is 336 characters and excessively verbose
4. [MAJOR] Description has marketing-style urgency ("⚠️ MANDATORY", all caps)

**Required rewrite:**
```yaml
---
name: run-tests
description: Comprehensive testing suite including unit tests (90%+ coverage required), integration tests (all integration points), and E2E tests (100% pass required). Reports coverage, identifies gaps, suggests fixes. Automatically invoked by safe-commit. Use when implementing features or fixing bugs.
version: 1.0.1
dependencies: Language-specific test frameworks (pytest, jest, go test, cargo test, etc.)
---
```

---

### Content Quality [✅ PASS]
- [x] Clear purpose and workflows
- [x] Concrete examples for multiple languages and test types
- [x] Consistent terminology
- [x] Coverage thresholds clearly documented

**Issues:**
1. [MINOR] Could add more examples of coverage gap analysis

**Positive highlights:**
- Clear three-tier test structure (Unit, Integration, E2E)
- Strong coverage threshold enforcement (90% unit, 100% E2E)
- Excellent multi-language support
- Good coverage parsing for each language
- Strong failure remediation guidance
- Good low coverage handling section
- Clear integration documentation

---

### Instruction Clarity [✅ PASS]
- [x] Clear sequential steps
- [x] Code examples complete and runnable
- [x] Expected outputs documented
- [x] Remediation steps provided

**Issues:**
None

**Positive highlights:**
- Clear workflow: Detect → Unit → Integration → E2E → Report
- Concrete commands for each language/framework
- Good coverage parsing examples
- Excellent failure report format
- Strong remediation guidance with categorization
- Good troubleshooting section

---

### Testing [⚠️ UNKNOWN]
- [ ] Test scenarios not documented
- [ ] Fresh instance testing not documented
- [ ] Multi-model testing not done

**Issues:**
1. [CRITICAL] No documented test scenarios
2. [CRITICAL] No testing documentation provided

**Required before release:**
- Test scenario 1: All tests passing with good coverage
- Test scenario 2: Failing unit tests
- Test scenario 3: Low coverage (< 90%)
- Test scenario 4: E2E test failure
- Test scenario 5: Multi-language project
- Document across models

---

## Blockers (must fix)
1. Name field "Run Tests" must be changed to "run-tests" to match directory
2. Name field uses spaces and capitals - must use lowercase-with-hyphens

## Critical Issues (should fix)
1. No documented test scenarios or testing matrix
2. Description too long (336 chars) with excessive enforcement language

## Major Issues (fix soon)
1. Description uses marketing-style urgency markers and all caps

## Minor Issues (nice to have)
1. Could add more examples of coverage gap analysis
2. Could expand troubleshooting for flaky tests

## Positive Highlights
- Excellent three-tier test structure (Unit, Integration, E2E)
- Strong coverage threshold enforcement (90% unit, 100% E2E pass)
- Comprehensive multi-language support
- Good coverage parsing for each language
- Excellent failure report format with specific file/line references
- Strong remediation guidance with issue categorization
- Good low coverage handling with gap identification
- Clear integration with safe-commit documented
- Good emergency override section
- Comprehensive troubleshooting section

## Recommendations

### Priority 1 (Required before release - BLOCKERS)
1. **Fix name field immediately** - Change from "Run Tests" to "run-tests"
   ```yaml
   name: run-tests  # Must match directory name exactly
   ```

2. **Fix name format** - Use lowercase-with-hyphens only
   - Current: "Run Tests"
   - Required: "run-tests"

### Priority 2 (Required before release - CRITICAL)
1. **Improve description** - Remove enforcement language, reduce to ~300 chars:
   ```yaml
   description: Comprehensive testing suite including unit tests (90%+ coverage required), integration tests (all integration points), and E2E tests (100% pass required). Reports coverage, identifies gaps, suggests fixes. Automatically invoked by safe-commit. Use when implementing features or fixing bugs.
   ```

2. **Complete testing documentation**:
   - Test all test types (unit, integration, E2E)
   - Test failure scenarios
   - Test coverage parsing
   - Test multi-language projects
   - Document across models

### Priority 3 (Nice to have)
1. Add more coverage gap examples:
   ```markdown
   ## Coverage Gap Analysis Examples

   **Missing error paths:**
   - Function has 3 branches but only 2 tested
   - Error handling code never executed in tests

   **Untested edge cases:**
   - Empty input handling
   - Boundary conditions (min/max values)
   - Null/undefined handling
   ```

2. Expand flaky test troubleshooting:
   ```markdown
   **Flaky test patterns:**
   - Tests pass locally but fail in CI
   - Tests fail intermittently
   - Tests depend on timing/order

   **Solutions:**
   - Add explicit waits for async operations
   - Use deterministic data generators
   - Ensure proper test isolation
   ```

## Next Steps
- [ ] Address blocker: Fix name field
- [ ] Address blocker: Fix name format
- [ ] Address critical: Complete testing
- [ ] Address critical: Improve description
- [ ] Consider adding more gap analysis examples
- [ ] Re-review after fixes
- [ ] Approve for merge

**Estimated effort:** 2-3 hours (mostly testing documentation)

---

## Overall Assessment

**Total Issues:**
- Blockers: 2
- Critical: 2
- Major: 1
- Minor: 2

**Reasoning:**
This skill provides excellent comprehensive testing coverage with clear three-tier structure (Unit, Integration, E2E) and strong threshold enforcement. However, two BLOCKER frontmatter issues prevent release - the name field MUST match "run-tests" exactly.

The 467-line length is acceptable given the skill's comprehensive scope covering multiple languages and test types. The coverage parsing, failure remediation, and gap identification sections are particularly strong.

The three-tier test philosophy (90% unit coverage, all integration points tested, 100% E2E pass) is excellent and well-documented. Once frontmatter is fixed and testing is documented, this skill will be ready for release.
