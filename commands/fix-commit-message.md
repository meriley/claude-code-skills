---
allowed-tools: Bash(git:*), Read, Task
argument-hint: [commit-ref]
description: Fix commit message to follow Conventional Commits format
---

# Fix Commit Message: Conventional Commits Format

You are helping fix a commit message to follow the Conventional Commits specification with **required scope**.

## Step 1: Determine Target Commit

The user may provide a commit reference (e.g., `HEAD`, `HEAD~1`, commit SHA).

If no argument provided, default to `HEAD` (most recent commit).

```bash
!git log -1 [COMMIT_REF] --format="%H %s"
!git log -1 [COMMIT_REF] --format="%B"
```

Show current commit:
```
Current commit: [SHA]
Message:
[current message]
```

## Step 2: Verify Commit Safety

**CRITICAL SAFETY CHECK** before allowing amend:

```bash
!git log -1 [COMMIT_REF] --format='%an %ae'
!git log --oneline -10
!git status --porcelain
```

Check:
1. **Authorship**: Is the commit by the current user (mriley)?
2. **Branch status**: Has the commit been pushed to remote?
3. **Working directory**: Are there uncommitted changes?

**BLOCK if**:
- Commit author is NOT the user (never amend other developers' commits)
- Commit has been pushed to shared branch (main/master/develop)
- Working directory has uncommitted changes (stage them first)

If blocked, show:
```
❌ CANNOT AMEND COMMIT

Reason: [specific reason]

[If different author]
This commit was authored by [author]. Never amend commits from other developers.
Instead, create a new commit with `git revert` or `git commit --fixup`.

[If pushed to remote]
This commit has been pushed to a shared branch. Amending would rewrite history.
Instead, create a new commit with the correct message.

[If uncommitted changes]
You have uncommitted changes. Stage or stash them first:
- git add . (to include in amended commit)
- git stash (to set aside temporarily)
```

## Step 3: Analyze Current Message

Parse the current commit message and check against Conventional Commits format:

**Required format**: `<type>(<scope>): <subject>`

### Check Type

Valid types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

**Issues**:
- Missing type
- Invalid type
- Type not lowercase

### Check Scope

**CRITICAL**: Scope is REQUIRED per CLAUDE.md policy.

**Issues**:
- Missing scope (e.g., `feat: add feature` instead of `feat(module): add feature`)
- Empty scope (e.g., `feat(): add feature`)
- Scope too generic (e.g., `feat(*): ...` should only be for truly global changes)

### Check Subject

**Rules**:
- Lowercase first letter (imperative mood)
- No period at end
- Concise (< 72 chars recommended)
- Describes what the change does

**Issues**:
- Uppercase first letter
- Period at end
- Too long (> 100 chars)
- Vague ("updated code", "fixed stuff")

### Check for AI Attribution

**CRITICAL**: Check for forbidden AI attribution (per CLAUDE.md zero tolerance policy):

```
Co-authored-by: Claude <noreply@anthropic.com>
🤖 Generated with [Claude Code](https://claude.ai/code)
Generated with Claude
AI-suggested
```

**If found**: Flag as CRITICAL issue that must be removed.

## Step 4: Analyze Changed Files

Suggest appropriate scope based on changed files:

```bash
!git show [COMMIT_REF] --name-only --format=
!git show [COMMIT_REF] --stat
```

Suggest scope based on file patterns:
- `src/auth/*` → `auth`
- `src/api/*` → `api`
- `src/db/*` → `db`
- `src/ui/*` → `ui`
- `tests/*` → scope of code being tested
- `docs/*` → `docs`
- `*.config.js` → `config`
- `package.json`, `go.mod` → `deps`

If files span multiple modules, suggest most appropriate scope or use parent module.

## Step 5: Generate Fixed Commit Message

Create a properly formatted commit message:

```
[type]([scope]): [subject]

[optional body - preserve original if exists and is good]

[optional footer - preserve original if exists, REMOVE AI attribution]
```

**Examples**:

Before:
```
Updated authentication
```

After:
```
feat(auth): add OAuth2 integration for GitHub

Implements OAuth2 authentication flow using GitHub as identity provider.
Includes token refresh and session management.
```

Before:
```
fix: handle empty input
```

After:
```
fix(parser): handle empty input gracefully

Adds validation to reject empty strings before parsing.
Prevents null pointer exceptions in downstream code.
```

Before:
```
refactor: extract metadata functionality

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

After:
```
refactor(metadata): extract functionality to dedicated package

Moves metadata parsing logic from core to separate package.
Improves code organization and testability.
```

## Step 6: Show Comparison

Display before and after side-by-side:

```
═══════════════════════════════════════════════════════════════
                    COMMIT MESSAGE ANALYSIS
═══════════════════════════════════════════════════════════════

Commit: [SHA]
Author: [author]
Files changed: XXX

───────────────────────────────────────────────────────────────
                        ISSUES FOUND
───────────────────────────────────────────────────────────────

❌ Missing scope (REQUIRED)
❌ Subject not in imperative mood
⚠️  Subject could be more descriptive
❌ AI attribution present (MUST REMOVE)

───────────────────────────────────────────────────────────────
                        BEFORE
───────────────────────────────────────────────────────────────

[Current commit message]

───────────────────────────────────────────────────────────────
                        AFTER
───────────────────────────────────────────────────────────────

[Fixed commit message]

───────────────────────────────────────────────────────────────
                    CHANGES SUMMARY
───────────────────────────────────────────────────────────────

✅ Added scope: ([scope])
✅ Fixed subject to imperative mood
✅ Removed AI attribution
✅ Added descriptive body
✅ Follows Conventional Commits specification

═══════════════════════════════════════════════════════════════
```

## Step 7: Request User Approval

**ALWAYS request explicit approval before amending**:

```
Would you like me to amend this commit with the fixed message?

⚠️  This will rewrite commit history.

Options:
1. Yes, amend the commit
2. No, keep current message
3. Let me edit the message first

Type your choice:
```

Wait for user response.

## Step 8: Amend Commit (if approved)

**Only if user approves**, amend the commit:

```bash
!git commit --amend -m "[fixed message]"
```

Confirm success:
```
✅ Commit message updated successfully

New commit: [new SHA]
Message:
[fixed message]

Next steps:
- Run `git log -1` to verify
- If this commit was already pushed, you'll need to force push:
  git push --force-with-lease origin [branch-name]
```

**If force push is needed, warn user**:
```
⚠️  WARNING: This commit was already pushed to remote.

To update the remote, you must force push:
  git push --force-with-lease origin [branch-name]

⚠️  Only do this if:
- You're working on a feature branch (not main/master)
- No one else has pulled this commit
- You understand the risks of rewriting history

Otherwise, consider creating a new commit instead.
```

## Step 9: Educational Feedback

Provide brief explanation to help user learn:

```
───────────────────────────────────────────────────────────────
                    CONVENTIONAL COMMITS
───────────────────────────────────────────────────────────────

Format: <type>(<scope>): <subject>

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation only
- style: Code style (formatting)
- refactor: Code restructuring
- perf: Performance improvement
- test: Adding/updating tests
- chore: Maintenance tasks

Scope: REQUIRED - indicates area of change
Examples: auth, api, db, ui, core, utils, config

Subject: Imperative mood, lowercase, no period
Good: "add user authentication"
Bad: "Added user authentication."

Body (optional): Explain what and why
Footer (optional): Breaking changes, issue references

For more info: https://www.conventionalcommits.org/
```

## Notes

- Always checks commit safety before amending
- Never amends commits from other developers
- Warns about force push if commit was already pushed
- Removes AI attribution (zero tolerance policy)
- Scope is REQUIRED (per CLAUDE.md policy)
- Provides educational feedback to help user learn
- Can be used on any commit reference (HEAD, HEAD~1, SHA)
- Requests explicit approval before rewriting history
