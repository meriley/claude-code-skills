---
allowed-tools: Bash(npm:*, go:*, pytest:*, cargo:*), Read, Grep, Glob, Skill, Task
argument-hint: [summary|detailed|report]
description: Test quality and coverage analysis
---

# Test Coverage: Quality Analysis

You are performing a comprehensive test coverage and quality analysis, identifying gaps and improvement opportunities.

## Step 1: Determine Report Mode

The user may have specified a mode: `summary`, `detailed`, or `report`.

- **summary**: Quick coverage metrics only (~1-2 min)
- **detailed**: Summary + gap analysis + recommendations (~5-10 min)
- **report**: Detailed + quality assessment + improvement plan (~10-20 min)

If no argument provided, default to `detailed`.

## Step 2: Detect Test Framework

Execute these commands to identify test setup:

```bash
!ls -1 package.json go.mod requirements.txt Cargo.toml 2>/dev/null | head -1
!grep -r "jest\|vitest\|mocha\|jasmine" package.json 2>/dev/null | head -3
!grep -r "testing\|testify" go.mod 2>/dev/null | head -3
!grep -r "pytest\|unittest" requirements.txt setup.py 2>/dev/null | head -3
!find . -name "*test*" -o -name "*spec*" | grep -E "\.(ts|js|go|py)$" | head -10
```

Identify:
- Project language
- Test framework (Jest, Vitest, Go testing, pytest, etc.)
- Test file locations
- Test configuration files

## Step 3: Invoke Run-Tests Skill

**Run the full test suite with coverage:**

```
Skill: run-tests
```

This will:
1. Run unit tests with coverage (90%+ required)
2. Run integration tests
3. Run E2E tests (100% pass rate required)
4. Generate coverage reports

Collect all test results and coverage data.

## Step 4: Coverage Analysis

### Parse Coverage Report

Based on project type, locate and parse coverage report:

**For JavaScript/TypeScript (Jest/Vitest):**
```bash
!cat coverage/coverage-summary.json 2>/dev/null || echo "No coverage report"
!cat coverage/lcov.info 2>/dev/null | grep -E "SF:|DA:" | head -50
```

**For Go:**
```bash
!go test -coverprofile=coverage.out ./... 2>/dev/null
!go tool cover -func=coverage.out 2>/dev/null | tail -1
!go tool cover -func=coverage.out 2>/dev/null | grep -E "^[^/]" | head -20
```

**For Python:**
```bash
!coverage report 2>/dev/null || pytest --cov --cov-report=term 2>/dev/null
!coverage json 2>/dev/null && cat coverage.json | head -50
```

### Extract Key Metrics

Calculate:
- Overall coverage percentage
- Lines covered / total lines
- Branches covered / total branches
- Functions covered / total functions
- Files with 0% coverage
- Files with < 90% coverage

## Step 5: Identify Coverage Gaps (Detailed and Report modes)

**If mode is `detailed` or `report`, identify specific gaps:**

### Find Untested Files

```bash
!find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.go" -o -name "*.py" \) ! -path "./node_modules/*" ! -path "./.git/*" ! -path "./vendor/*" ! -path "./.venv/*" ! -path "*test*" ! -path "*spec*" | head -50
```

Cross-reference with coverage report to find files with no tests.

### Find Critical Untested Code

Search for critical code without tests:

```bash
!grep -r "async.*function\|export.*function\|func.*{" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" ! -path "./.venv/*" ! -path "*test*" ! -path "*spec*" | head -30
!grep -r "class.*{" --include="*.ts" --include="*.js" --include="*.py" ! -path "./node_modules/*" ! -path "./.venv/*" ! -path "*test*" ! -path "*spec*" | head -20
```

Identify:
- Exported functions without tests
- Classes without test files
- Public APIs without coverage
- Error handling paths without tests

### Analyze Test Type Distribution

Count test types:

```bash
!grep -r "describe\|test\|it(" --include="*.test.*" --include="*.spec.*" ! -path "./node_modules/*" | wc -l
!grep -r "integration\|Integration" --include="*.test.*" --include="*.spec.*" ! -path "./node_modules/*" | wc -l
!grep -r "e2e\|E2E\|end-to-end" --include="*.test.*" --include="*.spec.*" ! -path "./node_modules/*" | wc -l
```

Calculate distribution:
- Unit tests: X%
- Integration tests: Y%
- E2E tests: Z%

## Step 6: Test Quality Assessment (Report mode only)

**If mode is `report`, perform quality analysis:**

### Test Completeness Check

Invoke Task agent for quality analysis:

```
Task(
  subagent_type: "general-purpose",
  description: "Analyze test quality",
  prompt: "Analyze the test suite quality and completeness.

  Coverage data:
  [paste coverage metrics]

  Untested files:
  [list files with 0% coverage]

  For the codebase:
  1. Identify critical paths that lack tests
  2. Check for test quality issues:
     - Tests that don't assert (missing expect/assert)
     - Tests that are too broad (testing multiple concerns)
     - Missing edge case tests
     - Missing error path tests
     - Missing integration tests
     - Missing E2E tests for critical flows

  3. Analyze test organization:
     - Test file naming consistency
     - Test suite structure
     - Test isolation (no shared state)
     - Mock usage appropriateness

  4. Provide specific recommendations:
     - Which files need tests most urgently
     - What types of tests are missing
     - How to improve test quality

  Generate prioritized list of test improvements."
)
```

### Check for Test Anti-Patterns

Search for common test issues:

```bash
!grep -r "skip\|xdescribe\|xit\|disabled" --include="*.test.*" --include="*.spec.*" ! -path "./node_modules/*" | head -20
!grep -r "setTimeout\|sleep" --include="*.test.*" --include="*.spec.*" ! -path "./node_modules/*" | head -20
!grep -r "console\\.log" --include="*.test.*" --include="*.spec.*" ! -path "./node_modules/*" | head -20
```

Flag:
- Skipped/disabled tests
- Tests with arbitrary timeouts
- Debug console.log statements

## Step 7: Generate Test Coverage Report

```
═══════════════════════════════════════════════════════════════
                  TEST COVERAGE REPORT
═══════════════════════════════════════════════════════════════

Project: [detected from package.json/go.mod/etc]
Test Framework: [Jest/Vitest/Go testing/pytest/etc]
Report Date: [current date]
Report Mode: [summary|detailed|report]

───────────────────────────────────────────────────────────────
                    COVERAGE METRICS
───────────────────────────────────────────────────────────────

Overall Coverage: XX.X%  [✅ >= 90% / ⚠️  >= 70% / ❌ < 70%]

Lines:      XXXX / XXXX (XX.X%)
Branches:   XXXX / XXXX (XX.X%)
Functions:  XXXX / XXXX (XX.X%)
Statements: XXXX / XXXX (XX.X%)

Coverage Trend: [↗️ Improving / → Stable / ↘️ Declining]

Status: EXCELLENT / GOOD / NEEDS IMPROVEMENT / POOR

[If >= 90%]
✅ Coverage meets the 90% threshold requirement

[If 70-89%]
⚠️  Coverage below 90% threshold - additional tests needed

[If < 70%]
❌ Coverage significantly below threshold - major testing effort required

───────────────────────────────────────────────────────────────
                    TEST DISTRIBUTION
───────────────────────────────────────────────────────────────

Total Test Files: XXX
Total Test Cases: XXX

Test Types:
- Unit Tests:        XXX (XX%)  [✅ >= 80% / ⚠️  >= 60% / ❌ < 60%]
- Integration Tests: XXX (XX%)  [✅ >= 15% / ⚠️  >= 10% / ❌ < 10%]
- E2E Tests:         XXX (XX%)  [✅ >= 5%  / ⚠️  >= 3%  / ❌ < 3%]

Test Results:
- Passed:  XXX (XX%)
- Failed:  XXX (XX%)  [❌ if > 0]
- Skipped: XXX (XX%)  [⚠️  if > 0]

───────────────────────────────────────────────────────────────
                    COVERAGE GAPS
───────────────────────────────────────────────────────────────

Files with 0% Coverage: XXX
[If > 0, list critical files]

Files Below 90% Coverage: XXX
[If in detailed/report mode, show top 10]

Top Uncovered Files:
1. [file] - 0% coverage (XXX lines uncovered)
2. [file] - XX% coverage (XXX lines uncovered)
3. ...

Critical Untested Code:
- Exported APIs: XXX functions without tests
- Error Handlers: XXX error paths without tests
- Public Classes: XXX classes without test files
- Async Functions: XXX async functions without tests

───────────────────────────────────────────────────────────────
                    TEST QUALITY ISSUES
───────────────────────────────────────────────────────────────

P0 - CRITICAL (FIX IMMEDIATELY):

1. [Critical path without tests]
   File: [file]
   Issue: [No test coverage for production-critical code]
   Impact: [Bugs could reach production undetected]
   Recommendation: [Add unit + integration tests]

2. ...

P1 - HIGH (SHOULD FIX):

1. [Missing error path tests]
   Files: [list]
   Issue: [Error handling not tested]
   Recommendation: [Add tests for error scenarios]

2. [Skipped tests]
   Count: XXX tests skipped
   Issue: [Tests disabled, coverage artificially inflated]
   Recommendation: [Re-enable or remove skipped tests]

3. ...

P2 - MEDIUM (SHOULD ADDRESS):

1. [Low integration test coverage]
   Current: XX%
   Target: >= 15%
   Recommendation: [Add integration tests for API endpoints, database interactions]

2. [Missing E2E tests]
   Current: XX%
   Target: >= 5%
   Recommendation: [Add E2E tests for critical user flows]

3. ...

P3 - LOW (NICE TO HAVE):

1. [Test organization]
   Issue: [Inconsistent test file naming]
   Recommendation: [Standardize test file naming]

2. ...

───────────────────────────────────────────────────────────────
                    RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Immediate Actions (This Week):
1. Add tests for critical uncovered code
2. Fix or remove all skipped tests
3. Achieve 90%+ coverage for core modules
4. Target coverage: XX% → 90%+

Short-term (This Month):
1. Add integration tests for all API endpoints
2. Add E2E tests for critical user flows
3. Address test quality issues (assertions, isolation)
4. Target: 100% test pass rate

Medium-term (This Quarter):
1. Establish test coverage gates in CI/CD
2. Regular coverage monitoring
3. Test quality reviews in code reviews
4. Maintain 90%+ coverage on all new code

Test Files to Create:
1. [file].test.ts - Unit tests for [module]
2. [file].integration.test.ts - Integration tests for [feature]
3. [file].e2e.test.ts - E2E tests for [user flow]
...

───────────────────────────────────────────────────────────────
                    COVERAGE IMPROVEMENT PLAN
───────────────────────────────────────────────────────────────

Current Coverage: XX.X%
Target Coverage: 90.0%
Gap: XX.X%

Estimated effort to reach 90%:
- Lines to cover: ~XXXX lines
- Test files to create: ~XX files
- Estimated time: ~XX hours

Priority Areas (in order):
1. [Module/Feature] - Currently XX%, need XX% more
   - Add unit tests for [specific functions]
   - Add integration tests for [specific flows]
   - Estimated impact: +XX% overall coverage

2. [Module/Feature] - Currently XX%, need XX% more
   - ...
   - Estimated impact: +XX% overall coverage

3. ...

Quick Wins (High Coverage Impact, Low Effort):
1. [Specific file/function] - +XX% coverage, ~30 min
2. ...

═══════════════════════════════════════════════════════════════
```

## Step 8: Provide Next Steps

Based on coverage level:

### If >= 90%:
```
✅ EXCELLENT TEST COVERAGE

Your test suite meets the 90% coverage requirement.

MAINTENANCE RECOMMENDATIONS:
- Run tests before every commit (use `safe-commit` skill)
- Monitor coverage in CI/CD
- Address P1/P2 test quality issues when convenient
- Keep coverage above 90% for all new code

Continue with: Skill: create-pr or Skill: safe-commit
```

### If 70-89%:
```
⚠️  COVERAGE BELOW THRESHOLD

Your test suite needs additional tests to reach 90% requirement.

REQUIRED ACTIONS:
1. Add tests for critical uncovered code (see Priority Areas above)
2. Target the Quick Wins for fast coverage improvements
3. Re-run `/test-coverage` to verify progress
4. Aim for 90%+ before creating PR

Estimated time to reach 90%: ~XX hours

Continue with test creation following the improvement plan above.
```

### If < 70%:
```
❌ INSUFFICIENT TEST COVERAGE

Your test suite has significant coverage gaps.

CRITICAL ACTIONS REQUIRED:
1. Review the Coverage Improvement Plan above
2. Prioritize testing critical paths and exported APIs
3. Create missing test files (see "Test Files to Create")
4. Run `/test-coverage report` for detailed quality analysis
5. Aim for 90%+ coverage before production deployment

DO NOT create PR until coverage is above 70% minimum.

Estimated effort: ~XX hours to reach 90%
```

## Step 9: Export Coverage Report (Report mode)

**If mode is `report`, offer to export detailed report:**

```
Coverage report generated.

Options:
1. View HTML report (if available):
   - JavaScript/TypeScript: open coverage/lcov-report/index.html
   - Go: go tool cover -html=coverage.out
   - Python: coverage html && open htmlcov/index.html

2. Export coverage badge:
   - Coverage: XX.X%
   - Badge: ![Coverage](https://img.shields.io/badge/coverage-XX.X%25-{color})

3. Save report to file (for documentation or PR description)
```

## Notes

- This command runs tests and may take several minutes
- Composes the `run-tests` skill
- Provides detailed gap analysis in detailed/report modes
- Report mode includes quality assessment and improvement plan
- Can be run regularly to track coverage trends
- Coverage threshold: 90% for unit tests (REQUIRED)
- Use before creating PRs to ensure adequate test coverage
