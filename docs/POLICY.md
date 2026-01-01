# Core Policies

## NO AI ATTRIBUTION - ZERO TOLERANCE

**NEVER add ANY of these to commits, code, or GitHub activity:**

- `Co-authored-by: Claude <noreply@anthropic.com>`
- `Generated with [Claude Code]`
- "Generated with Claude", "AI-suggested", "Claude recommends"
- Any reference to being an AI assistant

**Pre-commit verification:**
1. No Co-authored-by signatures
2. No AI attribution in commit message
3. No Claude references in code comments
4. Only human attribution (Pedro)

**User's name is Pedro.**

---

## DESTRUCTIVE COMMAND SAFEGUARDS

**NEVER run without explicit user confirmation:**

| Command | Risk |
|---------|------|
| `git reset --hard` | Destroys uncommitted changes |
| `git clean -fd` | Permanently deletes untracked files |
| `rm -rf` | Permanently deletes files/directories |
| `git checkout -- .` | Discards working directory changes |
| `git restore .` | Discards working directory changes |
| `docker system prune -a` | Removes all unused Docker data |
| `kubectl delete` | Deletes Kubernetes resources |

**Use `safe-destroy` skill before ANY destructive operation.**

---

## Git Commit Permission

### Auto-commit Allowed (ONLY scenario)

When user says: **"raise a PR"**, **"create a PR"**, **"draft PR"**

This grants permission to:
1. Stage all changes
2. Create commit with conventional format
3. Create branch with `mriley/` prefix
4. Push to remote
5. Create pull request

**Use `create-pr` skill.**

### Explicit Approval Required

ALL other commits require explicit approval.

**Before ANY commit:**
1. Show diff: `git status & git diff`
2. Ask: "Should I commit these changes?"
3. **WAIT** for "yes", "commit", "go ahead"

**Phrases that DO NOT grant permission:**
- "looks good" (code approval ≠ commit approval)
- "correct", "that's right"
- "fix the bug" (instruction, not permission)

**Use `safe-commit` skill for all commits.**

---

## Branch Naming

**ALL branches MUST use `mriley/` prefix**

| Correct | Incorrect |
|---------|-----------|
| `mriley/feat/new-feature` | `feat/new-feature` |
| `mriley/fix/race-condition` | `fix-bug` |

**Use `manage-branch` skill.**

---

## Testing Thresholds

| Type | Requirement |
|------|-------------|
| Unit Tests | 90%+ coverage (REQUIRED) |
| Integration Tests | All points tested |
| E2E Tests | 100% pass rate (no mocks) |

---

## Security Requirements

1. **Secrets**: Never commit API keys, passwords, tokens
2. **Dependencies**: Check for known vulnerabilities
3. **Injection**: Validate all user inputs
4. **Authentication**: Verify proper mechanisms
5. **Data**: Ensure sensitive data handled properly

---

## Code Quality

**Treat all linter issues as build failures.**

- All linter issues MUST be resolved
- Code must be properly formatted
- Type checks must pass
- Static analysis must be clean

---

## ESLint Disable Policy

**NEVER use `eslint-disable` to silence errors.**

Acceptable exceptions (rare, with explanation):
1. `react-refresh/only-export-components` in test files
2. Context+hook co-location patterns

If lint error occurs: understand WHY, fix the code, don't disable.
