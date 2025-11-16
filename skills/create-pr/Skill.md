---
name: Create Pull Request
description: Complete PR creation workflow (ONLY auto-commit scenario). Creates/validates mriley/ branch, commits changes, pushes, creates PR. Triggered ONLY by 'raise/create/draft PR'.
version: 1.0.0
---

# ⚠️ MANDATORY: Create Pull Request Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. When user explicitly says "raise a PR" or "create a PR"
2. When user says "draft PR" or "open a PR"
3. When user says "create pull request"
4. When user says "raise pull request"

**This skill is MANDATORY because:**
- Only auto-commit scenario allowed (ALL other commits require user approval)
- Ensures complete PR workflow with all safety checks
- Enforces proper branch naming and PR creation
- Prevents incomplete/partial PRs from reaching remote
- Maintains clear user intent tracking (explicit trigger required)

**ENFORCEMENT:**

**P0 Violations (Critical - Immediate Failure):**
- Invoking this skill without explicit "raise/create/draft PR" trigger (authorization violation)
- Creating PR without invoking safe-commit (safety check bypass)
- Creating branch NOT following mriley/ prefix convention (standards violation)
- Pushing to remote without completed safe-commit workflow (process violation)
- Creating PR without generated description (documentation failure)
- Not returning PR URL to user (verification failure)

**P1 Violations (High - Quality Failure):**
- Skipping step 1 (check-history) for context
- Failing to validate branch name before proceeding
- Not showing PR description to user for verification
- Unclear PR title or description
- Missing test coverage information in PR description

**P2 Violations (Medium - Efficiency Loss):**
- Running git commands sequentially instead of parallel
- Not suggesting draft vs final based on code maturity
- Failing to link related issues in PR description

**Blocking Conditions:**
- User must explicitly say "raise/create/draft PR" (no alternatives)
- Branch must have mriley/ prefix
- All safe-commit checks must PASS (security, quality, tests)
- All changes must be committed
- Branch must be pushed to remote before PR creation
- PR description must be generated and verified

---

## Purpose
Complete, safe pull request creation workflow that handles branch management, committing, pushing, and PR creation in one go.

## CRITICAL: When to Use

**This skill is invoked ONLY when user explicitly says:**
- "raise a PR"
- "create a PR"
- "draft PR"
- "open a PR"
- "create pull request"

**This is the ONLY scenario where automatic committing is allowed without user approval.**

## What This Skill Does

1. Validates or creates branch with `mriley/` prefix
2. Commits all changes (invokes `safe-commit` without user approval)
3. Pushes to remote repository
4. Creates pull request (draft or final)
5. Returns PR URL to user

## Workflow

### Step 1: Understand Current State

Invoke `check-history` skill to understand:
```
Invoke: check-history skill
```

**Gather:**
- Current branch name
- Uncommitted changes
- Recent commit history
- Base branch (main/master)

### Step 2: Validate or Create Branch

Check if current branch follows `mriley/` naming convention.

#### Scenario A: Already on Valid Branch

```bash
git branch --show-current
# Output: mriley/feat/jwt-authentication
```

**If valid:**
- ✅ Use current branch
- Note branch name for PR

#### Scenario B: On Invalid Branch (e.g., main, master, or non-mriley/ branch)

```
⚠️ Current branch doesn't follow convention

Current: main
Need: mriley/<type>/<description>

Will create new branch for this PR.
```

**Invoke `manage-branch` skill:**
```
Invoke: manage-branch skill
Operation: create
Type: [infer from changes, or ask user]
Description: [generate from changes or ask user]
```

**Example:**
```bash
git checkout -b mriley/feat/jwt-authentication
```

### Step 3: Analyze Changes for PR Description

Review all changes since diverging from base branch:

```bash
git diff main...HEAD --stat
git log main...HEAD --oneline
```

**Analyze:**
- What files changed
- What features/fixes implemented
- What tests added
- Breaking changes (if any)
- Related issues/tickets

**Build context for PR description**

### Step 4: Commit All Changes

**This is the only auto-commit scenario - NO user approval needed**

Invoke `safe-commit` skill with auto-commit flag:
```
Invoke: safe-commit skill
Mode: auto-commit (skip user approval)
```

**The safe-commit skill will:**
- Run security-scan
- Run quality-check
- Run run-tests
- Create conventional commit
- No user approval required (PR creation exception)

**If safe-commit fails (security/quality/tests):**
- STOP the PR creation
- Report failures to user
- User must fix issues
- Restart PR creation when ready

### Step 5: Push to Remote

Check if remote branch exists and push:

```bash
# Check remote
git ls-remote --heads origin mriley/feat/jwt-authentication
```

**If branch doesn't exist on remote:**
```bash
git push -u origin mriley/feat/jwt-authentication
```

**If branch exists on remote:**
```bash
git push origin mriley/feat/jwt-authentication
```

**If push fails (e.g., not up to date):**
```
❌ Push failed: Remote has changes

Your branch is behind the remote.

Options:
1. Pull and rebase: git pull --rebase origin mriley/feat/jwt-authentication
2. Pull and merge: git pull origin mriley/feat/jwt-authentication
3. Force push (DANGEROUS): git push --force origin mriley/feat/jwt-authentication

What would you like to do?
```

**STOP and wait for user decision.**

### Step 6: Generate PR Description

**Invoke the `pr-description-writer` skill to create a verified PR description:**

```bash
/skill pr-description-writer
```

**What the skill does:**
1. Discovers project PR template in `.github/` directory
2. Analyzes git diff and commit history for this branch
3. Generates description following template structure
4. Verifies all claims against actual code changes
5. Applies zero fabrication policy and technical documentation standards
6. Returns verified PR description markdown

**Input provided to skill:**
- Base branch (e.g., `main`)
- Current branch (e.g., `mriley/feat/jwt-authentication`)
- Commit range for analysis
- PR template (if found)

**Output received from skill:**
- Complete PR description in markdown format
- All template sections populated
- All claims verified against git diff
- Ready for use in `gh pr create --body`

**Example output from pr-description-writer:**
```markdown
## Summary
- Add JWT token validation middleware
- Implement token refresh logic
- Add comprehensive unit and integration tests

## Changes
Implements JWT-based authentication with proper token validation,
expiry checking, and refresh token support.

**Files Modified**:
- `src/middleware/auth.ts` - JWT validation middleware
- `src/services/token.ts` - Token refresh logic
- `tests/auth.test.ts` - Unit and integration tests

## Testing
**Unit Tests**:
- Coverage: 96.4%
- New tests: 42 tests added
- All tests passing

**Integration Tests**:
- 8 tests for full auth flow
- All tests passing

**Manual Testing**:
- Verified with Postman collection
- Tested token refresh flow

## Related Issues
Closes #156

## Checklist
- [x] Tests passing (coverage: 96.4%)
- [x] Linters passing
- [x] Security scan passing
- [x] Documentation updated
```

**Note**: The pr-description-writer skill ensures:
- ✅ No fabricated features or claims
- ✅ All files mentioned exist in git diff
- ✅ Test coverage numbers verified
- ✅ No marketing language or buzzwords
- ✅ Technical descriptions only

### Step 7: Create Pull Request

Use GitHub CLI to create PR:

**For draft PR:**
```bash
gh pr create --draft --title "<title>" --body "$(cat <<'EOF'
[PR description from Step 6]
EOF
)"
```

**For final PR:**
```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
[PR description from Step 6]
EOF
)"
```

**Title format:**
Use the commit message subject as PR title:
```
feat(auth): add JWT token validation
```

### Step 8: Get PR URL and Report Success

```bash
# Get PR URL from gh output or:
gh pr view --web
```

**Report to user:**
```
✅ Pull Request created successfully

PR: #47
URL: https://github.com/user/repo/pull/47
Title: feat(auth): add JWT token validation
Branch: mriley/feat/jwt-authentication → main
Status: Draft

Changes committed: 1 commit
Files changed: 3 files (+142, -8)
Tests: ✅ PASSED (coverage: 96.4%)

You can view and edit the PR at the URL above.
```

---

## PR Title Generation

**Use commit message as PR title:**

If single commit:
- Use commit subject as-is

If multiple commits:
- Analyze all commit subjects
- Generate title that encompasses all changes
- Follow conventional commit format
- Use most significant change type

**Examples:**

Single commit:
```
Commit: feat(auth): add JWT validation
PR Title: feat(auth): add JWT validation
```

Multiple related commits:
```
Commits:
- feat(auth): add JWT validation
- feat(auth): implement refresh tokens
- test(auth): add integration tests

PR Title: feat(auth): implement JWT authentication system
```

Mixed commit types (use most significant):
```
Commits:
- feat(auth): add JWT validation
- fix(auth): handle expired tokens
- test(auth): add tests

PR Title: feat(auth): add JWT authentication with token handling
```

---

## Error Handling

### Error: gh CLI not installed
```
❌ GitHub CLI not found

GitHub CLI is required to create pull requests.

Install:
- macOS: brew install gh
- Linux: See https://github.com/cli/cli#installation
- Windows: See https://github.com/cli/cli#installation

After installing, authenticate:
gh auth login
```

### Error: Not authenticated with gh
```
❌ Not authenticated with GitHub

Please authenticate GitHub CLI:
gh auth login

Then retry PR creation.
```

### Error: No commits to PR
```
❌ No commits to create PR from

Your branch has no commits ahead of main.

Please make changes and commit them first, then create PR.
```

### Error: Commit failed (security/quality/tests)
```
❌ Cannot create PR: Pre-commit checks failed

[Details from failed skill]

Please fix the issues and try again:
1. Fix reported issues
2. Re-run: "create PR"
```

### Error: Push failed
```
❌ Push failed: [error message]

Please resolve the push issue and retry.

Common solutions:
- Pull remote changes: git pull --rebase origin <branch>
- Check permissions: Ensure you have write access
- Check network: Verify GitHub is accessible
```

---

## Integration with Other Skills

This skill invokes:
- **`check-history`** - Step 1 (understand current state)
- **`manage-branch`** - Step 2 (if branch invalid)
- **`safe-commit`** - Step 4 (auto-commit mode)
- **`pr-description-writer`** - Step 6 (generate PR description)

---

## PR Draft vs Final

**Default to draft PR unless user specifies final:**

User says | Action
----------|--------
"draft PR" | Create draft (`--draft`)
"create PR" | Create draft (`--draft`)
"raise PR" | Create draft (`--draft`)
"final PR" | Create final (no `--draft`)
"ready PR" | Create final (no `--draft`)

**Draft PRs are safer** - allows for review/CI before marking ready.

---

## Multi-Commit PRs

If branch already has commits:

1. **Don't re-commit** - Skip safe-commit if HEAD is clean
2. **Analyze all commits** - Review entire branch history
3. **Generate comprehensive description** - Cover all changes
4. **Create PR with all commits**

**Check for clean state:**
```bash
git status
```

If clean and commits exist:
- Skip to Step 5 (push)
- Use all commits in PR description

---

## Best Practices

1. **Always draft first** - Unless user explicitly wants final
2. **Comprehensive descriptions** - Help reviewers understand changes
3. **Link issues** - Use "Closes #123" or "Fixes #123"
4. **Highlight breaking changes** - Call out backwards-incompatible changes
5. **Show test coverage** - Demonstrate quality
6. **No AI attribution** - PR description is human-authored

---

## After PR Creation

**Suggest next steps:**
```
PR created successfully!

Next steps:
1. Review the PR description and edit if needed
2. Wait for CI/CD checks to complete
3. Request reviews from team members
4. Address any review feedback
5. Mark as "Ready for review" when ready (if draft)

To view: gh pr view --web
To update: gh pr edit
```

---

## Emergency Handling

If user needs to cancel during PR creation:

1. Check what stage we're at
2. If commit created but not pushed:
   - Commit is local only
   - Can be amended or reset
3. If pushed but PR not created:
   - Branch exists remotely
   - Can create PR manually later
4. If PR created:
   - Can close: `gh pr close <number>`
   - Can delete branch: `git push origin --delete <branch>`

---

## Anti-Patterns

### ❌ Anti-Pattern: Creating PR Without Explicit Trigger

**Wrong approach:**
```
User: "The code looks good"
Assistant: *immediately invokes create-pr skill without user saying "raise/create/draft PR"*
```

**Why wrong:**
- Violates explicit trigger requirement
- User may not intend to create PR yet
- Assumes intent without confirmation
- Only "raise/create/draft PR" phrase grants permission

**Correct approach:** Wait for explicit trigger
```
User: "The code looks good"
Assistant: *Code review complete, but does NOT invoke create-pr*
Assistant: "Code review looks solid. Ready to create a PR?"

User: "Yes, create a PR"
Assistant: *NOW invokes create-pr skill*
```

---

### ❌ Anti-Pattern: Skipping Branch Name Validation

**Wrong approach:**
```
User: "raise a PR"
Assistant: *immediately commits without checking branch name follows mriley/ prefix*
```

**Why wrong:**
- Non-compliant branches pollute repository
- Makes git history harder to parse
- Violates branch naming standards
- Future work harder to organize

**Correct approach:** Validate or create proper branch
```
User: "raise a PR"
Assistant: *checks current branch: "main"*
Assistant: *invokes manage-branch to create mriley/feat/... branch*
Assistant: *then proceeds with safe-commit and PR creation*
```

---

### ❌ Anti-Pattern: PR Without Description

**Wrong approach:**
```
User: "raise a PR"
Assistant: *creates PR with minimal/auto-generated description*
```

**Why wrong:**
- Reviewers lack context
- No test coverage information
- No explanation of changes
- Low quality PR record in history

**Correct approach:** Generate comprehensive description
```
User: "raise a PR"
Assistant: *invokes pr-description-writer skill*
*generates verified description with all sections*
*shows description to user for verification*
*creates PR with complete information*
```

---

### ❌ Anti-Pattern: Skipping Test Checks

**Wrong approach:**
```
User: "raise a PR"
Assistant: *invokes safe-commit but skips run-tests*
```

**Why wrong:**
- PR gets created with failing tests
- CI/CD blocks merge
- Wastes reviewer time
- Violates 100% E2E pass requirement

**Correct approach:** ALL checks must pass
```
User: "raise a PR"
Assistant: *invokes safe-commit with all checks*
*security-scan, quality-check, run-tests ALL PASS*
*THEN creates PR*
```

---

## References

**Based on:**
- CLAUDE.md Section 1 (Core Policies - Git Commit Permission Rules)
- CLAUDE.md Section 3 (Available Skills Reference - create-pr)
- CLAUDE.md Section 3 (Available Skills Reference - pr-description-writer)
- Project instructions: PR creation explicit trigger only

**Related skills:**
- `check-history` - Context gathering
- `manage-branch` - Branch creation and validation
- `safe-commit` - Auto-commit with all safety checks
- `pr-description-writer` - PR description generation
