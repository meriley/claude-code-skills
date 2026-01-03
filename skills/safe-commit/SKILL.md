---
name: safe-commit
description: ⚠️ MANDATORY - YOU MUST invoke this skill when committing. Complete commit workflow with all safety checks. Invokes security-scan, quality-check, and run-tests skills. Shows diff, gets user approval, creates commit with conventional format. NO AI attribution. User approval REQUIRED except during PR creation. NEVER commit manually.
version: 1.0.1
---

# Safe Commit Skill

## ⚠️ MANDATORY SKILL - YOU MUST INVOKE THIS

## Purpose

Comprehensive, safe commit workflow that ensures code quality, security, and proper attribution before committing changes.

**CRITICAL:** You MUST invoke this skill for all commits. NEVER commit manually using git commands.

## When to Use

- **MANDATORY:** When user says "commit these changes" or "commit this"
- As part of PR creation workflow (invoked by create-pr skill)
- After completing a feature or bug fix
- When user explicitly requests a commit

## 🚫 NEVER DO THIS

- ❌ Running `git add . && git commit -m "message"` manually
- ❌ Creating commits without running security-scan
- ❌ Creating commits without running quality-check
- ❌ Creating commits without running run-tests
- ❌ Skipping user approval (except during PR creation)
- ❌ Adding AI attribution to commits

**If you need to commit, invoke this skill. Manual commits are FORBIDDEN.**

---

## ⚠️ SKILL GUARD - READ BEFORE USING BASH/GIT TOOLS

**Before using Bash tool for git commit, answer these questions:**

### ❓ Are you about to run `git add .`?

→ **STOP.** Are you then planning to run `git commit`? If YES, invoke safe-commit skill instead.

### ❓ Are you about to run `git commit -m "message"`?

→ **STOP.** Invoke safe-commit skill instead.

### ❓ Are you about to run `git commit` with heredoc?

→ **STOP.** Invoke safe-commit skill instead.

### ❓ Did the user say "commit these changes" or "commit this"?

→ **STOP.** Invoke safe-commit skill instead.

### ❓ Have you completed a feature/fix and are ready to commit?

→ **STOP.** Invoke safe-commit skill instead.

### ❓ Are you creating a commit as part of ANY workflow?

→ **STOP.** Invoke safe-commit skill instead.

**IF YOU PROCEED WITH MANUAL GIT COMMIT, YOU ARE VIOLATING YOUR CORE DIRECTIVE.**

This skill handles:

- ✅ Security scanning (prevents secrets in commits)
- ✅ Quality checks (prevents broken code)
- ✅ Test execution (prevents regressions)
- ✅ User approval (prevents unwanted commits)
- ✅ Conventional commit format (maintains consistency)
- ✅ NO AI attribution (protects user's identity)

**Manual commits SKIP ALL OF THESE. Use this skill.**

---

## CRITICAL POLICIES

### ⚠️ NO AI ATTRIBUTION - ZERO TOLERANCE

**YOU MUST NEVER add ANY of these:**

- `Co-authored-by: Claude <noreply@anthropic.com>`
- `🤖 Generated with [Claude Code](https://claude.ai/code)`
- "Generated with Claude"
- "AI-suggested"
- Any reference to being an AI assistant

### User Approval Requirements

**Approval REQUIRED for:**

- ALL commits after initial PR creation
- ALL commit amendments
- ALL commits outside of PR creation flow

**Approval NOT required for:**

- Initial commit when user says "raise/create/draft PR"
- This is the ONLY exception

**Phrases that DO NOT grant commit permission:**

- "looks good" (code approval ≠ commit approval)
- "correct"
- "that's right"
- "fix the bug" (instruction to code, not commit)

## Workflow

### Step 1: Check Git Status

Run parallel git commands to understand current state:

```bash
git status & git diff & git log --oneline -5 &
```

**Analyze:**

- What files are changed (staged and unstaged)
- Current branch name
- Recent commit messages (for context)
- Uncommitted changes

### Step 2: Invoke Dependent Skills

Run these skills in sequence (each must pass):

#### 2.1: Security Scan

```
Invoke: security-scan skill
```

**Must pass before proceeding.**

- No secrets in code
- No dependency vulnerabilities
- No code injection risks

#### 2.2: Quality Check

```
Invoke: quality-check skill
```

**Must pass before proceeding.**

- All linters pass
- Code formatted correctly
- Type checks pass
- Static analysis clean

#### 2.3: Run Tests

```
Invoke: run-tests skill
```

**Must pass before proceeding.**

- Unit tests: 90%+ coverage
- Integration tests: All pass
- E2E tests: 100% pass rate

**If ANY skill fails:**

- STOP the commit workflow
- Report failure to user
- Provide remediation steps
- Wait for user to fix issues
- Restart from Step 1 when ready

### Step 3: Show Diff to User

Display what will be committed:

```bash
git status
echo "---"
git diff --stat
echo "---"
git diff
```

**Present to user:**

```
Ready to commit the following changes:

Files changed:
- src/api/handlers.go (modified)
- src/api/handlers_test.go (modified)
- pkg/auth/validator.go (new file)

Summary:
M  src/api/handlers.go          | 45 ++++++++++++++++++++++++++++++
M  src/api/handlers_test.go     | 28 +++++++++++++++++++
A  pkg/auth/validator.go        | 67 ++++++++++++++++++++++++++++++++++++++++++

All safety checks passed:
✅ Security scan: PASSED
✅ Quality check: PASSED
✅ Tests: PASSED (coverage: 94.2%)

Changes add JWT token validation with comprehensive tests.
```

### Step 4: Request User Approval

**CRITICAL: You MUST ask and WAIT for approval (except during PR creation)**

```
Should I commit these changes?
```

**STOP and WAIT for user response.**

**Proceed only if user says:**

- "yes"
- "commit"
- "go ahead"
- "proceed"
- "approve"

**DO NOT proceed if user says:**

- "looks good" (ambiguous - ask for clarification)
- "correct" (not explicit permission)
- Provides no response (wait)

### Step 5: Generate Commit Message

Use Conventional Commits format with REQUIRED scope:

```
<type>(<scope>): <subject>

[optional body]
```

**Commit Type Selection:**

- `feat`: New feature added
- `fix`: Bug fix
- `refactor`: Code restructuring (no functionality change)
- `perf`: Performance improvement
- `test`: Adding/updating tests only
- `docs`: Documentation only
- `style`: Code style/formatting only
- `build`: Build system or dependencies
- `ci`: CI/CD configuration
- `chore`: Other changes (config, tooling)

**Scope Selection:**
Analyze the files changed and determine scope:

- Single area (e.g., `auth`, `api`, `parser`) → Use specific scope
- Multiple related areas (e.g., `api` and `api_test`) → Use primary area
- Truly global changes → Use `*`

**Subject Guidelines:**

- Use imperative mood ("add", not "added" or "adds")
- No capital first letter
- No period at end
- Max 50 characters
- Describe WHAT and WHY, not HOW

**Body Guidelines (optional):**

- Provide additional context if needed
- Explain motivation for changes
- Note any breaking changes
- Reference issues/tickets: "Closes #123"

**Example Commit Messages:**

```
feat(auth): add JWT token validation

Implement JWT token validation middleware with expiry
checking and refresh token support. Includes comprehensive
unit tests and integration tests.

Closes #156
```

```
fix(parser): handle empty input gracefully

Previously panicked on empty input. Now returns
appropriate error with helpful message.
```

```
refactor(api): extract validation logic to dedicated package

Move validation code from handlers to pkg/validation
for better testability and reusability.
```

### Step 6: Create Commit

Stage all changes and create commit:

```bash
git add .
```

**Create commit with heredoc for proper formatting:**

```bash
git commit -m "$(cat <<'EOF'
feat(auth): add JWT token validation

Implement JWT token validation middleware with expiry
checking and refresh token support. Includes comprehensive
unit tests and integration tests.

Closes #156
EOF
)"
```

**CRITICAL: NO AI attribution in commit message or Co-authored-by tags**

### Step 7: Verify Commit Success

```bash
git show --stat HEAD
```

**Confirm:**

- Commit created successfully
- Correct files included
- Commit message formatted correctly
- NO AI attribution present
- Author is Pedro (mriley)

**Report to user:**

```
✅ Commit created successfully

Commit: a1b2c3d
Author: Pedro
Message: feat(auth): add JWT token validation

Files committed:
- src/api/handlers.go
- src/api/handlers_test.go
- pkg/auth/validator.go

Working directory: clean
```

### Step 8: Post-Commit Status Check

```bash
git status
```

Confirm working directory is clean.

### Step 9: PRD Task Auto-Update (Optional)

If the commit message contains a PRD task reference, update the progress tracker.

**Pattern Detection:**
Look for these patterns in the commit message:

- `[PRD Task N]` - e.g., `[PRD Task 2]`
- `[Task N]` - e.g., `[Task 2]`

**If pattern detected:**

1. **Get commit info:**

   ```bash
   git log -1 --format='%H %cs' HEAD
   ```

   Extract: short hash (first 7 chars), date (YYYY-MM-DD)

2. **Find associated PRD file:**
   - Look for PRD files in `docs/`, `specs/`, or project root
   - Search for file containing "Implementation Progress" section

3. **Update progress tracker:**
   - Find task row matching task number
   - Update `Status` to `Done`
   - Fill in `Completed` date
   - Add commit hash (short form, e.g., `abc1234`)
   - Update Progress Summary counts

4. **Report to user:**
   ```
   📋 PRD Task 2 marked as completed
   - Completed: 2024-01-16
   - Commit: abc1234
   - Updated: docs/shipping-feature-prd.md
   ```

**If PRD file not found:**

- Skip silently (task reference may be manual tracking)
- No error needed

**Example:**

```
feat(orders): add createOrder mutation [PRD Task 2]
```

After commit, the PRD progress tracker updates automatically:

```markdown
| 2 | Add createOrder mutation | Done | 2024-01-15 | 2024-01-16 | abc1234 |
```

---

## Handling Pre-Commit Hooks

If pre-commit hooks modify files:

1. **First commit attempt** - May fail if hooks modify files
2. **Check for modifications:**
   ```bash
   git status
   ```
3. **If files modified by hooks:**
   - Show user what changed
   - Explain hooks modified files
   - Check if safe to amend:
     - Verify author is Pedro: `git log -1 --format='%an %ae'`
     - Verify not pushed: `git status` shows "Your branch is ahead"
   - If safe: Amend commit
     ```bash
     git add .
     git commit --amend --no-edit
     ```
4. **Re-verify commit**

**NEVER amend if:**

- Author is not Pedro
- Commit already pushed
- Multiple commits since (not HEAD)

---

## Integration with Other Skills

This skill invokes:

- **`security-scan`** - Step 2.1
- **`quality-check`** - Step 2.2
- **`run-tests`** - Step 2.3

This skill is invoked by:

- **`create-pr`** - As part of PR creation workflow

---

## Exception: PR Creation Flow

When invoked by `create-pr` skill:

- Skip Step 4 (user approval)
- Proceed directly to commit
- This is the ONLY time auto-commit is allowed

**The `create-pr` skill is only invoked when user explicitly says "raise/create/draft PR"**

---

## Error Handling

### If security scan fails:

```
❌ Cannot commit: Security issues detected

[Details from security-scan skill]

Please fix security issues and try again.
```

### If quality check fails:

```
❌ Cannot commit: Code quality issues detected

[Details from quality-check skill]

Please fix linter/formatter issues and try again.
```

### If tests fail:

```
❌ Cannot commit: Tests failing or coverage below threshold

[Details from run-tests skill]

Please fix failing tests and improve coverage, then try again.
```

### If git commit fails:

```
❌ Commit failed

Error: [git error message]

Possible causes:
- Pre-commit hook failure
- Git configuration issue
- File system permissions

Please investigate and retry.
```

---

## Best Practices

1. **Always run in order** - Security → Quality → Tests → Commit
2. **No skipping checks** - All must pass
3. **Get explicit approval** - Don't assume permission (except PR creation)
4. **Descriptive messages** - Help future you understand why
5. **Proper scopes** - Never omit scope from commit message
6. **Verify attribution** - Always ensure Pedro is sole author
7. **Clean commits** - Stage all changes, commit once

---

## Commit Message Quality Checklist

Before committing, verify message has:

- ✅ Type and scope in format: `type(scope):`
- ✅ Imperative mood in subject
- ✅ Subject ≤ 50 characters
- ✅ Body explains why (if needed)
- ✅ References issues/tickets (if applicable)
- ✅ NO AI attribution anywhere
- ✅ NO Co-authored-by tags

---

## Emergency Override

If user explicitly states "force commit" or "skip checks":

**YOU MUST:**

1. Warn about risks
2. List which checks are being skipped
3. Get explicit re-confirmation
4. Document in commit message what was skipped
5. Create follow-up ticket for remediation

**This should be EXTREMELY RARE.**
