
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
