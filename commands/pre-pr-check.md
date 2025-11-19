---
allowed-tools: Bash(git:*, npm:*, go:*, pytest:*, cargo:*), Read, Grep, Glob, Skill
argument-hint: [quick|full]
description: Complete pre-PR validation (security, quality, tests)
---

# Pre-PR Check: Complete Validation

You are performing a comprehensive pre-PR validation to ensure all changes are ready for review and merge.

This command composes multiple skills to provide a complete readiness assessment.

## Step 1: Determine Check Mode

The user may have specified a mode: `quick` or `full`.

- **quick**: Security scan + linting only (fast, ~2-5 min)
- **full**: Security + quality + tests + coverage (thorough, ~5-15 min)

If no argument provided, default to `full`.

## Step 2: Show Current State

Execute these commands to understand what will be checked:

```bash
!git status --short
!git diff --stat
!git branch --show-current
```

Show user:
- Current branch
- Files changed (staged + unstaged)
- Lines added/removed

## Step 3: Invoke Security Scan Skill

**ALWAYS run security scan regardless of mode (quick or full).**

Invoke the `security-scan` skill:

```
Skill: security-scan
```

The skill will:
1. Scan for secrets (API keys, passwords, tokens, private keys)
2. Check for hardcoded credentials
3. Detect SQL injection risks
4. Check for XSS vulnerabilities
5. Verify dependency vulnerabilities
6. Check for weak cryptography
7. Validate authentication mechanisms

**If security scan finds P0 issues: STOP and report. Do not proceed with PR creation.**

## Step 4: Invoke Quality Check Skill

Invoke the `quality-check` skill:

```
Skill: quality-check
```

The skill will:
1. Run language-specific linting (ESLint, golangci-lint, flake8, etc.)
2. Check code formatting (Prettier, black, gofmt)
3. Run static analysis (go vet, mypy)
4. Auto-fix when possible
5. Invoke language-specific deep audits:
   - **Go projects**: `control-flow-check` + `error-handling-audit`
   - **TypeScript projects**: `type-safety-audit`
   - **TypeScript + GraphQL**: `n-plus-one-detection` + `type-safety-audit`

**If quality check finds P0 issues: Report but continue (user can decide).**

## Step 5: Invoke Test Suite (Full Mode Only)

**If mode is `full`, invoke the `run-tests` skill:**

```
Skill: run-tests
```

The skill will:
1. Run unit tests (requires 90%+ coverage)
2. Run integration tests
3. Run E2E tests (requires 100% pass rate)
4. Generate coverage reports
5. Identify coverage gaps

**If tests fail or coverage is below threshold: Report but continue (user can decide).**

## Step 6: Generate Readiness Report

After all checks complete, generate a comprehensive readiness report:

```
═══════════════════════════════════════════════════════════════
                    PRE-PR READINESS REPORT
═══════════════════════════════════════════════════════════════

Branch: [current-branch]
Base: origin/main (or origin/master)

Changed Files: X
Lines Added: +XXX
Lines Removed: -XXX

───────────────────────────────────────────────────────────────
                        CHECK RESULTS
───────────────────────────────────────────────────────────────

✅/❌ Security Scan
  - Secrets detected: X
  - Vulnerabilities: X
  - P0 issues: X (BLOCKING if > 0)
  - P1 issues: X
  - Status: PASS / FAIL

✅/❌ Code Quality
  - Linter errors: X
  - Linter warnings: X
  - Formatting issues: X (auto-fixed)
  - P0 issues: X
  - P1 issues: X
  - Status: PASS / FAIL / PASS WITH WARNINGS

✅/❌ Language-Specific Audits
  [Go Projects]
  - Control flow issues: X
  - Error handling issues: X

  [TypeScript Projects]
  - Type safety violations: X
  - N+1 query problems: X (if GraphQL)

  Status: PASS / FAIL / PASS WITH WARNINGS

✅/❌ Test Suite (if full mode)
  - Unit tests: XXX/XXX passed (XX% coverage)
  - Integration tests: XXX/XXX passed
  - E2E tests: XXX/XXX passed
  - Coverage: XX% (threshold: 90%)
  - Status: PASS / FAIL

───────────────────────────────────────────────────────────────
                      OVERALL ASSESSMENT
───────────────────────────────────────────────────────────────

Status: READY / NEEDS FIXES / BLOCKED

[If READY]
✅ All checks passed
✅ No blocking issues found
✅ Tests pass with adequate coverage
✅ Ready to create PR

Next steps:
1. Run: /review-branch (optional - for detailed code review)
2. Run: Skill: create-pr (to create the PR)

[If NEEDS FIXES]
⚠️  Non-blocking issues found
⚠️  Fix recommended before PR creation

Next steps:
1. Address P1 issues (see details below)
2. Re-run: /pre-pr-check
3. Or proceed with PR if issues are acceptable

[If BLOCKED]
❌ Blocking issues found - DO NOT CREATE PR

BLOCKING ISSUES:
[List all P0 issues that must be fixed]

Next steps:
1. Fix all P0 security issues
2. Fix all P0 quality issues
3. Ensure tests pass (if full mode)
4. Re-run: /pre-pr-check

───────────────────────────────────────────────────────────────
                        DETAILED ISSUES
───────────────────────────────────────────────────────────────

[If issues found, list them grouped by priority]

P0 - CRITICAL (MUST FIX):
1. [Issue description] - [file:line]
2. ...

P1 - HIGH (SHOULD FIX):
1. [Issue description] - [file:line]
2. ...

P2 - MEDIUM (NICE TO HAVE):
1. [Issue description] - [file:line]
2. ...

═══════════════════════════════════════════════════════════════
```

## Step 7: Provide Next Steps

Based on overall assessment:

### If READY:
```
Your code is ready for PR creation! 🎉

Optional next steps:
- Run `/review-branch` for detailed code review
- Run `Skill: create-pr` to create the pull request

Or commit manually:
- Run `Skill: safe-commit` to commit changes (requires approval)
```

### If NEEDS FIXES:
```
Your code has non-blocking issues that should be addressed.

Recommended actions:
1. Review P1 issues above
2. Fix issues or document why they're acceptable
3. Re-run `/pre-pr-check` to verify fixes

Or proceed anyway:
- Run `Skill: create-pr` (issues will be visible in PR)
```

### If BLOCKED:
```
Your code has blocking issues that MUST be fixed before PR creation.

Required actions:
1. Fix all P0 security issues (secrets, vulnerabilities)
2. Fix all P0 quality issues (critical bugs, breaking changes)
3. Ensure all tests pass with adequate coverage
4. Re-run `/pre-pr-check` to verify fixes

DO NOT create a PR until all blocking issues are resolved.
```

## Notes

- This command does NOT commit or create PRs
- This is a validation check only
- Security scan is ALWAYS run (both quick and full modes)
- Tests are only run in full mode (default)
- All skills provide detailed output for debugging
- Can be run multiple times until all checks pass
- Composes: `security-scan`, `quality-check`, `run-tests` skills
