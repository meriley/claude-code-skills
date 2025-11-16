---
name: Git History Context
description: Reviews git history, status, and context before starting tasks. Runs parallel git commands to understand current state, recent changes, and related work.
version: 1.0.0
---

# ⚠️ MANDATORY: Git History Context Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. At the start of EVERY task or work session
2. Before implementing any feature or fixing any bug
3. Before creating implementation plans (sparc-plan invokes this)
4. When investigating bugs or understanding code behavior
5. Before committing changes (safe-commit may invoke this)

**This skill is MANDATORY because:**
- Prevents duplicate work by showing recent related changes
- Provides context about project conventions and patterns
- Identifies potential conflicts with ongoing work
- Ensures awareness of recent changes that might affect your task

**ENFORCEMENT:**

**P2 Violations (Medium - Efficiency Loss):**
- Starting a task without using this skill first
- Implementing features without checking for related previous work
- Missing context about recent changes in related areas

**Blocking Conditions:**
- This skill should complete before significant implementation work
- Output provides essential context for next steps

---

## Purpose
This skill gathers comprehensive git context before starting any work. It helps understand the current state of the repository, recent changes, and identify related previous work.

## When to Use
- **ALWAYS** at the start of any new task
- Before implementing features or fixing bugs
- Before creating implementation plans
- When investigating issues or understanding code behavior
- When user asks about recent changes or project history

## Workflow

### Step 1: Run Parallel Git Status Commands
Execute these commands in parallel for efficiency:

```bash
git status & git diff & git log --oneline -10 &
```

**What to look for:**
- Current branch name
- Uncommitted changes (staged or unstaged)
- Untracked files
- Recent commit messages and their scope
- Commit patterns and conventions in use

### Step 2: Analyze Current State
Based on the parallel command output:

1. **Branch Status:**
   - Verify branch name follows `mriley/` prefix convention
   - Check if branch is ahead/behind remote
   - Note if on main/master vs feature branch

2. **Working Directory State:**
   - Identify any uncommitted changes
   - Note files that might conflict with planned work
   - Check for untracked files that might be relevant

3. **Recent Work:**
   - Review last 10 commits for context
   - Identify patterns in commit messages
   - Note any related work or recent changes in relevant areas

### Step 3: Search for Related Work (If Applicable)
If the task relates to a specific feature, bug, or area:

```bash
git log --grep="<keyword>" --oneline -10
```

**Example keywords:**
- Feature names (e.g., "auth", "parser", "api")
- Bug identifiers (e.g., "fix", "bug", "issue")
- Scope identifiers from conventional commits

### Step 4: Get Detailed Context (If Needed)
For more detailed information about recent changes:

```bash
git show --name-only HEAD                  # Files changed in last commit
git diff --name-only origin/main           # Files changed vs main branch
git log --graph --oneline -10              # Visual commit graph
```

### Step 5: Generate Context Summary
Provide a concise summary including:

1. **Current State:**
   - Branch: `<branch-name>`
   - Status: Clean working directory / Has uncommitted changes
   - Position: Up to date / Ahead by N commits / Behind by N commits

2. **Recent Activity:**
   - Last 3-5 relevant commits with their scope and purpose
   - Any ongoing work that might be related

3. **Relevant History:**
   - Related previous work (if found via grep)
   - Patterns or conventions observed

4. **Recommendations:**
   - Any concerns or conflicts to address
   - Suggested next steps based on current state

## Example Output

```
Git Context Summary:
==================

Current State:
- Branch: mriley/feat/user-authentication
- Status: Clean working directory
- Position: Ahead of origin/main by 2 commits

Recent Activity:
1. feat(auth): add JWT token generation (3 hours ago)
2. feat(auth): implement user login endpoint (5 hours ago)
3. test(auth): add unit tests for password hashing (1 day ago)

Relevant History:
- Found 3 commits related to "auth" in past week
- Project consistently uses conventional commits with scope
- Security-focused: all auth changes include tests

Recommendations:
- Safe to proceed with auth-related work
- Follow existing pattern: feature + tests in same commit
- Consider reviewing recent auth commits for context
```

## Error Handling

### If git command fails:
- Verify we're in a git repository
- Check git is installed and accessible
- Report error to user with specific command that failed

### If not in a git repo:
- Note this is not a git repository
- Skip git-specific checks
- Proceed with file system context if needed

## Integration with Other Skills

This skill should be invoked by:
- **`sparc-plan`** - Before creating implementation plans
- **`safe-commit`** - To understand what's being committed
- **`create-pr`** - To generate meaningful PR descriptions

## Best Practices

1. **Always run parallel commands** - Don't run git commands sequentially
2. **Be concise** - Summarize, don't dump raw git output
3. **Focus on relevance** - Highlight information relevant to the current task
4. **Note patterns** - Identify conventions and patterns in commit history
5. **Flag concerns** - Highlight any potential conflicts or issues early

---

## Anti-Patterns

### ❌ Anti-Pattern: Starting Task Without Context

**Wrong approach:**
```
User: "Fix the authentication bug"
Assistant: *immediately starts editing code without checking history*
```

**Why wrong:**
- Might duplicate recent work
- Misses recent changes that could affect the fix
- Ignores existing conventions and patterns
- Wastes time discovering context mid-implementation

**Correct approach:** Use this skill first
```
User: "Fix the authentication bug"
Assistant: "Let me first use the check-history skill to understand recent changes and project state"
*Invokes check-history skill*
*Reviews output showing recent auth-related commits*
*Then proceeds with fix informed by context*
```

---

## References

**Based on:**
- CLAUDE.md Section 0a (Pre-Action Checklist)
- Git best practices for context gathering

**Related skills:**
- `sparc-plan` - Invokes this skill for planning context
- `safe-commit` - Uses git status/diff for commit context
- `create-pr` - Invokes this skill for PR description context
