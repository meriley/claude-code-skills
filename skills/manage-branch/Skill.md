---
name: Manage Branch
description: Creates and manages git branches with enforced mriley/ prefix naming convention. Validates branch names, switches branches safely, and handles branch creation with proper base branch selection.
version: 1.0.0
---

# ⚠️ MANDATORY: Manage Branch Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. When user explicitly requests branch creation
2. Before any work on a new feature, fix, or refactor
3. When invoked by create-pr skill
4. When validating existing branch names
5. When switching between branches

**This skill is MANDATORY because:**
- Enforces mriley/ prefix convention ACROSS ALL BRANCHES (ZERO TOLERANCE)
- Prevents polluting repository with non-compliant branch names
- Ensures git history is organized and searchable
- Validates branch state before operations
- Prevents work loss through safety checks on switching

**ENFORCEMENT:**

**P0 Violations (Critical - Immediate Failure):**
- Creating branch WITHOUT mriley/ prefix (ZERO TOLERANCE)
- Creating branch with wrong prefix (e.g., pedro/, user/, etc.)
- Switching branches with uncommitted changes without confirmation
- Creating branch with invalid characters or casing
- Creating duplicate branch names

**P1 Violations (High - Quality Failure):**
- Missing branch type designation (feat/fix/refactor/perf/etc)
- Unclear or non-descriptive branch names
- Not validating branch name against requirements
- Branch name exceeds 50 characters
- Using spaces or special characters instead of kebab-case

**P2 Violations (Medium - Efficiency Loss):**
- Not showing available branches when user uncertain
- Not suggesting corrections for invalid names
- Failing to verify branch creation success

**Blocking Conditions:**
- ALL branches MUST follow mriley/<type>/<name> pattern
- Branch names must use kebab-case (lowercase with hyphens)
- Branch names must be ≤ 50 characters total
- Working directory must be clean before switching (unless stashed)
- Branch must have proper type designation

---

## Purpose
Enforce branch naming conventions and provide safe branch creation/switching operations with proper validation.

## When to Use
- Creating new feature/fix/refactor branches
- Switching between branches
- As part of PR creation workflow
- When user requests branch operations

## CRITICAL POLICY

### Branch Naming Convention

**ALL branches MUST be prefixed with `mriley/`**

**Valid branch name patterns:**
- `mriley/feat/<descriptive-name>`
- `mriley/fix/<issue-description>`
- `mriley/refactor/<component-name>`
- `mriley/perf/<optimization-description>`
- `mriley/chore/<task-description>`
- `mriley/docs/<documentation-update>`
- `mriley/test/<testing-addition>`

**Examples of CORRECT names:**
- ✅ `mriley/feat/user-authentication`
- ✅ `mriley/fix/parser-null-handling`
- ✅ `mriley/refactor/api-validation`
- ✅ `mriley/perf/optimize-query-performance`

**Examples of INCORRECT names:**
- ❌ `feat/user-authentication` (missing mriley/ prefix)
- ❌ `user-authentication` (missing prefix and type)
- ❌ `fix-bug` (missing mriley/ prefix)
- ❌ `pedro/feat/something` (wrong user prefix)

## Workflow

### Operation 1: Create New Branch

#### Step 1.1: Determine Branch Type

Ask user or infer from context:
- **feat**: New feature
- **fix**: Bug fix
- **refactor**: Code restructuring
- **perf**: Performance improvement
- **chore**: Maintenance task
- **docs**: Documentation
- **test**: Test additions

#### Step 1.2: Generate Branch Name

Based on work description, generate name:

**Format:**
```
mriley/<type>/<short-descriptive-name>
```

**Naming guidelines:**
- Use kebab-case (lowercase with hyphens)
- Be descriptive but concise (2-4 words)
- Focus on WHAT, not HOW
- Avoid ticket numbers (unless no description)
- Max 50 characters total

**Examples:**
```
mriley/feat/jwt-authentication
mriley/fix/memory-leak-parser
mriley/refactor/split-monolithic-handler
mriley/perf/cache-database-queries
```

#### Step 1.3: Validate Branch Name

Check against requirements:
- ✅ Starts with `mriley/`
- ✅ Has type (feat/fix/refactor/etc)
- ✅ Has descriptive name
- ✅ Uses kebab-case
- ✅ Length ≤ 50 characters

#### Step 1.4: Check Current Git Status

```bash
git status
```

**If uncommitted changes exist:**
```
⚠️ Uncommitted changes detected

You have uncommitted changes in your working directory:
- src/api/handlers.go (modified)
- pkg/auth/validator.go (new file)

Options:
1. Commit changes first (recommended)
2. Stash changes: git stash
3. Discard changes: git restore . (DANGEROUS)

What would you like to do?
```

**STOP and wait for user decision.**

#### Step 1.5: Determine Base Branch

Check which branch to create from:

```bash
git branch --show-current
```

**Common scenarios:**
- On `main`/`master` → Create from current (typical)
- On feature branch → Ask if creating from current or from main
- On `develop` → Create from current (if using gitflow)

**If uncertain, ask user:**
```
Create branch from:
1. Current branch (main)
2. Different branch (specify)
```

#### Step 1.6: Create Branch

```bash
git checkout -b mriley/<type>/<name>
```

**Or if creating from specific base:**
```bash
git checkout -b mriley/<type>/<name> origin/main
```

#### Step 1.7: Verify Creation

```bash
git branch --show-current
```

**Report success:**
```
✅ Branch created successfully

Branch: mriley/feat/jwt-authentication
Base: main
Status: Clean working directory

You can now start working on this branch.
```

---

### Operation 2: Switch Branch

#### Step 2.1: Check Current Status

```bash
git status
```

**If uncommitted changes:**
```
⚠️ Uncommitted changes detected

Cannot switch branches with uncommitted changes.

Options:
1. Commit changes first (recommended)
2. Stash changes: git stash
3. Discard changes: git restore . (DANGEROUS)

What would you like to do?
```

**STOP and wait for user decision.**

#### Step 2.2: List Available Branches (Optional)

If user unsure which branch to switch to:

```bash
git branch -v
```

Show branches with descriptions:
```
Available branches:
* main                    a1b2c3d Last commit message
  mriley/feat/auth        d4e5f6g Add JWT validation
  mriley/fix/parser-bug   g7h8i9j Fix null pointer
```

#### Step 2.3: Switch Branch

```bash
git checkout <branch-name>
```

**Or fetch and checkout remote branch:**
```bash
git fetch origin
git checkout -b <branch-name> origin/<branch-name>
```

#### Step 2.4: Verify Switch

```bash
git branch --show-current
```

**Report success:**
```
✅ Switched to branch: mriley/feat/auth

Branch: mriley/feat/auth
Latest commit: d4e5f6g Add JWT validation
Status: Up to date with origin/mriley/feat/auth
```

---

### Operation 3: Validate Existing Branch Name

If checking/fixing existing branch that doesn't follow convention:

#### Step 3.1: Get Current Branch

```bash
git branch --show-current
```

#### Step 3.2: Validate Name

Check if matches `mriley/<type>/<name>` pattern.

**If invalid:**
```
⚠️ Branch name doesn't follow convention

Current: feat/user-authentication
Required: mriley/feat/user-authentication

This branch should be renamed to follow convention.

Options:
1. Rename current branch: git branch -m mriley/feat/user-authentication
2. Create new branch with correct name
3. Continue with current name (NOT recommended)

What would you like to do?
```

#### Step 3.3: Rename Branch (If Requested)

```bash
# Rename local branch
git branch -m mriley/<type>/<name>

# If already pushed, delete old remote and push new
git push origin --delete <old-name>
git push -u origin mriley/<type>/<name>
```

---

## Integration with Other Skills

This skill is invoked by:
- **`create-pr`** - When creating pull request

This skill may invoke:
- **`safe-commit`** - If user wants to commit before switching

---

## Error Handling

### Error: Branch already exists
```
❌ Branch already exists: mriley/feat/auth

Options:
1. Switch to existing branch: git checkout mriley/feat/auth
2. Use different name: mriley/feat/auth-v2
3. Delete existing branch (DANGEROUS - requires confirmation)

What would you like to do?
```

### Error: Invalid branch name
```
❌ Invalid branch name

Provided: pedro/feat/something
Issue: Must use 'mriley/' prefix, not 'pedro/'

Corrected: mriley/feat/something

Shall I use the corrected name?
```

### Error: Cannot switch (uncommitted changes)
```
❌ Cannot switch branches

Uncommitted changes in:
- src/api/handlers.go
- pkg/auth/validator.go

Please commit or stash changes first.
```

### Error: Branch doesn't exist
```
❌ Branch doesn't exist: mriley/feat/nonexistent

Available branches matching 'feat':
- mriley/feat/auth
- mriley/feat/parser

Did you mean one of these?
```

---

## Best Practices

1. **Always validate** - Check branch name follows convention
2. **Check git status** - Ensure clean state before operations
3. **Descriptive names** - Help future you understand the work
4. **Confirm with user** - When renaming or making destructive changes
5. **Report clearly** - Show before/after state
6. **Handle errors gracefully** - Provide options, not just errors

---

## Branch Naming Examples

### Good Examples

**Features:**
- `mriley/feat/oauth-integration`
- `mriley/feat/real-time-notifications`
- `mriley/feat/export-to-csv`

**Bug Fixes:**
- `mriley/fix/race-condition-handler`
- `mriley/fix/memory-leak-cache`
- `mriley/fix/null-pointer-parser`

**Refactoring:**
- `mriley/refactor/extract-validation-logic`
- `mriley/refactor/split-large-service`
- `mriley/refactor/improve-error-handling`

**Performance:**
- `mriley/perf/optimize-database-queries`
- `mriley/perf/add-response-caching`
- `mriley/perf/reduce-memory-allocation`

### Bad Examples (and corrections)

❌ `new-feature` → ✅ `mriley/feat/new-feature`
❌ `fix-bug-123` → ✅ `mriley/fix/authentication-timeout`
❌ `feat/auth` → ✅ `mriley/feat/auth`
❌ `mriley/UpdateCode` → ✅ `mriley/refactor/update-validation-code`
❌ `mriley/WIP` → ✅ `mriley/feat/descriptive-name-here`

---

## Anti-Patterns

### ❌ Anti-Pattern: Creating Branch Without mriley/ Prefix

**Wrong approach:**
```
User: "Create a branch for authentication"
Assistant: *creates `feat/authentication` or `authentication` branch*
```

**Why wrong:**
- Violates mriley/ prefix requirement (ZERO TOLERANCE)
- Repository gets cluttered with non-compliant branches
- Makes git history harder to organize and parse
- Prevents filtering and bulk operations on mriley branches

**Correct approach:** Always enforce mriley/ prefix
```
User: "Create a branch for authentication"
Assistant: *validates requirement and creates `mriley/feat/authentication`*
```

---

### ❌ Anti-Pattern: Switching Branches With Uncommitted Changes

**Wrong approach:**
```
User: "Switch to main branch"
Assistant: *executes `git checkout main` with uncommitted changes*
Result: Changes are lost or corrupted
```

**Why wrong:**
- User work is lost or moved unexpectedly
- Git may fail or leave repository in inconsistent state
- Violates safety-first principle

**Correct approach:** Check status and ask for confirmation
```
User: "Switch to main branch"
Assistant: *checks `git status`*
Assistant: "You have uncommitted changes. Options: commit, stash, or discard?"
*WAITS for user decision*
```

---

### ❌ Anti-Pattern: Unclear Branch Names

**Wrong approach:**
```
mriley/feat/stuff
mriley/fix/bug
mriley/work
mriley/wip-changes
```

**Why wrong:**
- Impossible to understand what branch is for
- Makes git history unintelligible
- Future work harder to organize
- Makes finding related branches impossible

**Correct approach:** Descriptive, specific names
```
mriley/feat/jwt-authentication
mriley/fix/null-pointer-parser
mriley/perf/optimize-database-queries
```

---

## Quick Reference

**Create branch:**
```bash
git checkout -b mriley/feat/descriptive-name
```

**Switch branch:**
```bash
git checkout mriley/feat/existing-branch
```

**Rename branch:**
```bash
git branch -m mriley/feat/new-name
```

**List branches:**
```bash
git branch -v
```

**Delete branch (local):**
```bash
git branch -d mriley/feat/old-branch
```

---

## References

**Based on:**
- CLAUDE.md Section 1 (Core Policies - Branch Naming Requirements)
- CLAUDE.md Section 3 (Available Skills Reference - manage-branch)

**Related skills:**
- `create-pr` - Uses this skill for branch validation
- `safe-commit` - Works with branches created by this skill
