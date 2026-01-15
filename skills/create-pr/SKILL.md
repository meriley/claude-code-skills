---
name: create-pr
description: ⚠️ MANDATORY - YOU MUST invoke this skill ONLY when user says "raise/create/draft PR". ONLY auto-commit scenario. Creates/validates branch with mriley/ prefix, commits all changes (invokes safe-commit), pushes to remote, creates PR with proper format. NEVER create PRs manually.
version: 1.0.1
---

# Create Pull Request Skill

## ⚠️ MANDATORY SKILL - YOU MUST INVOKE THIS

## Purpose

Complete, safe pull request creation workflow that handles branch management, committing, pushing, and PR creation in one go.

**CRITICAL:** You MUST invoke this skill for PR creation. NEVER push and create PRs manually with git/gh commands.

## CRITICAL: When to Use

**This skill MUST be invoked ONLY when user explicitly says:**

- "raise a PR"
- "create a PR"
- "draft PR"
- "open a PR"
- "create pull request"

**This is the ONLY scenario where automatic committing is allowed without user approval.**

## 🚫 NEVER DO THIS

- ❌ Running `git push && gh pr create` manually
- ❌ Creating PRs through GitHub UI manually
- ❌ Committing and pushing without invoking safe-commit
- ❌ Creating PRs for phrases other than "raise/create/draft PR"

**If user wants to create a PR, invoke this skill. Manual PR creation is FORBIDDEN.**

---

## ⚠️ SKILL GUARD - READ BEFORE USING BASH/GH TOOLS

**Before using Bash/gh tools for PR creation, answer these questions:**

### ❓ Did the user say "raise a PR", "create a PR", or "draft PR"?

→ **STOP.** Invoke create-pr skill instead.

### ❓ Are you about to run `git push` followed by `gh pr create`?

→ **STOP.** Invoke create-pr skill instead.

### ❓ Are you about to commit changes and then push to remote?

→ **STOP.** Is this for a PR? If YES, invoke create-pr skill instead.

### ❓ Are you manually crafting a PR description?

→ **STOP.** Let create-pr skill handle it (invokes pr-description-writer).

**IF YOU PROCEED WITH MANUAL PR CREATION, YOU ARE VIOLATING YOUR CORE DIRECTIVE.**

This skill handles:

- ✅ Branch validation/creation (ensures mriley/ prefix)
- ✅ Auto-commit via safe-commit (runs all safety checks)
- ✅ Push to remote
- ✅ PR creation with verified description
- ✅ Returns PR URL

**Manual PR creation SKIPS ALL OF THESE. Use this skill.**

---

## What This Skill Does

1. Validates or creates branch with `mriley/` prefix
2. Commits all changes (invokes `safe-commit` without user approval)
3. Pushes to remote repository
4. Creates pull request (draft or final)
5. Returns PR URL to user

## Workflow (Quick Summary)

### Core Steps

1. **Understand State**: Invoke check-history (branch, changes, commits, base)
2. **Validate/Create Branch**: Ensure mriley/ prefix or create via manage-branch
3. **Analyze Changes**: Review diff and log since base branch
4. **Auto-Commit**: Invoke safe-commit (NO user approval - PR exception) with security/quality/test checks
5. **Push**: Push to remote with -u if needed, handle conflicts
6. **Generate Description**: Invoke pr-description-writer for verified PR description
7. **Create PR**: Use gh pr create (draft by default) with generated description
8. **Report Success**: Return PR URL and suggest next steps

**For detailed workflow with git commands and examples:**

```
Read `~/.claude/skills/create-pr/references/WORKFLOW-STEPS.md`
```

Use when: Performing PR creation, need specific git commands, or understanding each step

### PR Title Generation

**Single commit**: Use commit subject as-is
**Multiple commits**: Analyze all commits, generate encompassing title with most significant type

**For PR title generation patterns and examples:**

```
Read `~/.claude/skills/create-pr/references/PR-TITLE-GENERATION.md`
```

Use when: Generating titles for multi-commit PRs or complex scenarios

### Error Handling

Common errors: gh CLI not installed, not authenticated, no commits, checks failed, push failed

**For detailed error handling with messages and solutions:**

```
Read `~/.claude/skills/create-pr/references/ERROR-HANDLING.md`
```

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

---

## PR Draft vs Final

**Default to draft PR unless user specifies final:**

| User says   | Action                      |
| ----------- | --------------------------- |
| "draft PR"  | Create draft (`--draft`)    |
| "create PR" | Create draft (`--draft`)    |
| "raise PR"  | Create draft (`--draft`)    |
| "final PR"  | Create final (no `--draft`) |
| "ready PR"  | Create final (no `--draft`) |

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

