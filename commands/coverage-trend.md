---
allowed-tools: Bash(git:*), Bash(npm:*), Bash(go:*), Bash(pytest:*), Read, Glob
argument-hint: [commits=5]
description: Track test coverage changes across recent commits
---

# Coverage Trend

Track test coverage changes over time to catch regressions before PR.

## Usage

```
/coverage-trend              # Coverage for last 5 commits
/coverage-trend 10           # Coverage for last 10 commits
/coverage-trend main         # Compare current to main branch
```

## Step 1: Detect Test Framework

```bash
ls -1 package.json go.mod requirements.txt pytest.ini jest.config.* vitest.config.* 2>/dev/null
```

Determine coverage command:
- **Jest**: `npx jest --coverage --coverageReporters=json-summary`
- **Vitest**: `npx vitest run --coverage`
- **Go**: `go test ./... -coverprofile=coverage.out && go tool cover -func=coverage.out`
- **pytest**: `pytest --cov=. --cov-report=json`

## Step 2: Get Commit History

```bash
# Get last N commits
git log -${COMMITS:-5} --format="%H|%h|%s|%ad" --date=short
```

## Step 3: Run Coverage at Each Commit

For each commit (starting from oldest):

```bash
# Stash current changes
git stash push -m "coverage-trend-temp"

# Checkout commit
git checkout <commit-hash> --quiet

# Run coverage (framework-specific)
<coverage-command>

# Extract coverage percentage
<parse-coverage-output>

# Return to original branch
git checkout - --quiet

# Restore stash
git stash pop --quiet
```

## Step 4: Calculate Deltas

Compare each commit's coverage to the previous:
- **Positive delta**: Coverage increased (+X.X%)
- **Negative delta**: Coverage decreased (-X.X%)
- **Baseline**: First commit in range (no delta)

## Step 5: Output Format

```
╔══════════════════════════════════════════════════════════════╗
║                    COVERAGE TREND REPORT                      ║
╠══════════════════════════════════════════════════════════════╣
║  Project: my-app                                             ║
║  Framework: Jest                                             ║
║  Threshold: 90%                                              ║
╠══════════════════════════════════════════════════════════════╣

## Coverage History (Last 5 Commits)

| Commit  | Date       | Coverage | Delta  | Status | Message                    |
|---------|------------|----------|--------|--------|----------------------------|
| abc1234 | 2024-01-20 | 92.3%    | +0.5%  | ✅     | feat(auth): add OAuth      |
| def5678 | 2024-01-19 | 91.8%    | -1.2%  | ⚠️     | refactor: extract utils    |
| ghi9012 | 2024-01-18 | 93.0%    | +0.3%  | ✅     | test: add user tests       |
| jkl3456 | 2024-01-17 | 92.7%    | +2.1%  | ✅     | test: improve coverage     |
| mno7890 | 2024-01-16 | 90.6%    | base   | ✅     | initial baseline           |

## Trend Analysis

```
Coverage %
   94 ┤
   93 ┤          ╭─╮
   92 ┤    ╭─────╯ ╰──╮
   91 ┤    │          ╰──╮
   90 ┼────╯              ╰──
      └─────────────────────────
        Jan16  17   18   19   20
```

## Status Legend
- ✅ Above threshold (90%)
- ⚠️ Coverage decreased
- ❌ Below threshold

## Flagged Commits

### ⚠️ def5678 (2024-01-19): Coverage dropped 1.2%

Files with reduced coverage:
- `src/utils/helpers.ts`: 95% → 82% (-13%)
- `src/api/client.ts`: 88% → 85% (-3%)

Possible causes:
- New code added without tests
- Existing tests removed or disabled
- Refactoring changed code paths

╚══════════════════════════════════════════════════════════════╝
```

## Step 6: Recommendations

Based on trend, suggest actions:

```
RECOMMENDATIONS
═══════════════════════════════════════

Current: 92.3% (above 90% threshold ✅)
Trend: Slight decrease over last 5 commits

Action Items:
1. Review def5678 - coverage dropped 1.2%
2. Add tests for src/utils/helpers.ts
3. Consider increasing threshold to 93%

Run `/test-coverage detailed` for full coverage report.
```

## Notes

- This temporarily checks out each commit to run tests
- Original working directory is restored after analysis
- Stashed changes are preserved
- For large test suites, this can take several minutes
- Use fewer commits for faster results
- Integrates with `run-tests` skill coverage data
