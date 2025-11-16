---
name: Safe Destructive Operations
description: Safety protocol for destructive operations. Lists affected files, warns of data loss, suggests alternatives, requires explicit confirmation for git reset --hard, git clean, rm -rf.
version: 1.0.0
---

# ⚠️ MANDATORY: Safe Destructive Operations Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Before ANY `git reset --hard` command
2. Before ANY `git clean -fd` command
3. Before ANY `rm -rf <directory>` command
4. Before ANY `git checkout -- .` or `git restore .`
5. Before ANY `docker system prune -a`
6. Before ANY `kubectl delete` operations
7. Before ANY operation that permanently deletes data

**This skill is MANDATORY because:**
- Prevents permanent data loss from accidental commands (ZERO TOLERANCE)
- User work is irreversible once deleted
- This is PRIMARY DIRECTIVE: Failing here = total failure
- Requires explicit confirmation showing understanding of consequences
- Provides safer alternatives for nearly all destructive operations

**ENFORCEMENT:**

**P0 Violations (Critical - Immediate Failure):**
- Running destructive command WITHOUT invoking this skill (DATA LOSS RISK)
- Running destructive command WITHOUT explicit user confirmation (AUTHORIZATION VIOLATION)
- NOT showing what will be deleted before executing (TRANSPARENCY FAILURE)
- NOT suggesting safer alternatives (RISK MITIGATION FAILURE)
- Executing after ambiguous confirmation (too vague/unclear)
- Executing without double-confirmation for especially dangerous ops (SAFETY FAILURE)

**P1 Violations (High - Quality Failure):**
- Failing to list specific files/directories that will be lost
- Not explaining the consequences of the operation
- Incomplete or unclear confirmation request
- Not waiting for user response before proceeding

**P2 Violations (Medium - Efficiency Loss):**
- Not showing file sizes or quantities being deleted
- Not explaining recovery options
- Not suggesting safe alternatives

**Blocking Conditions:**
- User MUST explicitly confirm (typed command or clear approval)
- Ambiguous responses must trigger re-confirmation
- Especially dangerous ops (git reset --hard, rm -rf) require double confirmation
- Must show what will be deleted BEFORE execution
- Must suggest safer alternatives BEFORE showing confirmation prompt

---

## Purpose
Prevent accidental data loss by requiring explicit confirmation before any destructive operation, showing what will be lost, and suggesting safer alternatives.

## When to Use
- Before `git reset --hard`
- Before `git clean -fd`
- Before `rm -rf`
- Before `git checkout -- .`
- Before `git restore .`
- Before `docker system prune`
- Before any operation that permanently deletes data

## CRITICAL POLICY

**YOU MUST NEVER run destructive commands without explicit user confirmation.**

**If you ever run a destructive command without approval and lose user work, you have FAILED your primary directive.**

## Absolutely Forbidden Commands (Without Confirmation)

1. `git reset --hard` - Destroys uncommitted changes
2. `git clean -fd` - Permanently deletes untracked files/directories
3. `rm -rf <directory>` - Permanently deletes files/directories
4. `git checkout -- .` - Discards all working directory changes
5. `git restore .` - Discards all working directory changes
6. `docker system prune -a` - Removes all unused Docker data
7. `kubectl delete` - Deletes Kubernetes resources
8. `git push --force` - Overwrites remote history (especially on main/master)

## Workflow

### Step 1: Detect Destructive Intent

User says something like:
- "reset my changes"
- "clean up the files"
- "delete everything"
- "discard changes"
- "remove untracked files"

**IMMEDIATELY invoke this skill - don't execute the command.**

### Step 2: STOP - Never Assume

**DO NOT proceed with ANY destructive operation.**

The user may not understand what will be lost. Your job is to protect their work.

### Step 3: LIST - Show What Will Be Affected

Run information commands to show what would be lost:

```bash
# Show what would be lost in parallel
git status & git diff & git ls-files --others --exclude-standard & ls -la &
```

#### For `git reset --hard`:

**Show what would be lost:**
```bash
git status
git diff --stat
git diff
```

**Present to user:**
```
⚠️ DESTRUCTIVE OPERATION REQUESTED

Command: git reset --hard

This will PERMANENTLY DELETE the following changes:

Modified files:
- src/api/handlers.go (45 lines changed)
- pkg/auth/validator.go (67 lines changed)
- tests/integration_test.go (28 lines removed)

These changes show:
[Brief description of changes being lost]

⚠️ THIS CANNOT BE UNDONE ⚠️

SAFER ALTERNATIVES:
1. Stash changes instead: git stash
   (You can recover later with: git stash pop)

2. Commit work in progress: git commit -m "wip: save current work"
   (You can reset commit later with: git reset HEAD~1)

3. Create backup branch: git branch backup-$(date +%s)
   (Preserves current state before reset)

Do you want to:
A. Use safer alternative (stash/commit/backup)
B. Proceed with destructive reset (PERMANENT)
C. Cancel
```

**STOP and WAIT for explicit response.**

#### For `git clean -fd`:

**Show what would be deleted:**
```bash
git clean -fd --dry-run
```

**Present to user:**
```
⚠️ DESTRUCTIVE OPERATION REQUESTED

Command: git clean -fd

This will PERMANENTLY DELETE the following untracked files:

Directories to be removed:
- node_modules/ (3.2 GB)
- temp/ (contains 45 files)

Files to be removed:
- debug.log
- config.local.json
- notes.txt

⚠️ THIS CANNOT BE UNDONE ⚠️

SAFER ALTERNATIVES:
1. Review files first and delete selectively
2. Move to backup folder instead:
   mkdir ../backup-$(date +%s)
   mv <files> ../backup-$(date +%s)/

3. Add to .gitignore instead (if intentionally untracked)

Do you want to:
A. Use safer alternative (review/backup)
B. Proceed with permanent deletion
C. Cancel
```

**STOP and WAIT.**

#### For `rm -rf <directory>`:

**Show what would be deleted:**
```bash
du -sh <directory>
ls -la <directory>
find <directory> -type f | wc -l
```

**Present to user:**
```
⚠️ DESTRUCTIVE OPERATION REQUESTED

Command: rm -rf <directory>

This will PERMANENTLY DELETE:

Directory: <directory>
Size: 245 MB
Files: 1,247 files
Subdirectories: 34 directories

Recent modifications (last 7 days):
- file1.go (modified 2 days ago)
- file2.py (modified yesterday)

⚠️ THIS CANNOT BE UNDONE ⚠️

SAFER ALTERNATIVES:
1. Move to trash/backup:
   mkdir -p ~/.trash/$(date +%s)
   mv <directory> ~/.trash/$(date +%s)/

2. Rename with .deleted suffix:
   mv <directory> <directory>.deleted.$(date +%s)

3. Archive first:
   tar -czf <directory>-backup-$(date +%s).tar.gz <directory>

Do you want to:
A. Use safer alternative (backup/archive)
B. Proceed with permanent deletion
C. Cancel
```

**STOP and WAIT.**

#### For `git checkout -- .` or `git restore .`:

**Show what would be lost:**
```bash
git diff --stat
git diff
```

**Present to user:**
```
⚠️ DESTRUCTIVE OPERATION REQUESTED

Command: git restore .

This will DISCARD all uncommitted changes in:

- src/api/handlers.go (45 lines removed)
- pkg/auth/validator.go (67 lines removed)
- tests/integration_test.go (28 lines removed)

⚠️ THIS CANNOT BE UNDONE ⚠️

SAFER ALTERNATIVES:
1. Stash changes: git stash
2. Commit as WIP: git commit -m "wip: current work"
3. Create patch file: git diff > changes.patch

Do you want to:
A. Use safer alternative
B. Proceed with discard (PERMANENT)
C. Cancel
```

**STOP and WAIT.**

#### For `docker system prune -a`:

**Show what would be deleted:**
```bash
docker system df
docker images
docker ps -a
```

**Present to user:**
```
⚠️ DESTRUCTIVE OPERATION REQUESTED

Command: docker system prune -a

This will PERMANENTLY DELETE:

Images: 15 images (8.4 GB)
Containers: 3 stopped containers
Volumes: 2 volumes (1.2 GB)
Networks: 4 networks
Total reclaimed space: ~9.6 GB

⚠️ THIS WILL REQUIRE RE-DOWNLOADING IMAGES ⚠️

SAFER ALTERNATIVES:
1. Remove only stopped containers: docker container prune
2. Remove specific images: docker rmi <image>
3. Remove only dangling images: docker image prune

Do you want to:
A. Use safer alternative (selective removal)
B. Proceed with full prune
C. Cancel
```

**STOP and WAIT.**

---

### Step 4: ASK - Get Explicit Confirmation

**Required response:**
- User MUST type the specific command they want to execute
- OR explicitly say "proceed with [operation]"
- OR choose option B from the menu

**Examples of VALID confirmation:**
- "yes, run git reset --hard"
- "proceed with permanent deletion"
- "I understand, delete the files"
- "B" (from the menu)

**Examples of INVALID confirmation:**
- "ok" (too vague)
- "do it" (unclear what 'it' is)
- "sure" (not explicit enough)

**If confirmation ambiguous:**
```
Please explicitly confirm by typing:
"I want to run git reset --hard"

or select option B from the menu.
```

---

### Step 5: WAIT - Do Not Proceed Until Explicit Approval

**STOP all processing until user responds.**

Do not:
- Assume silence means approval
- Interpret "looks good" as approval
- Proceed after timeout

---

### Step 6: VERIFY - Confirm the Specific Command

Once user responds, verify they understand:

```
Confirming: You want to execute 'git reset --hard'

This will permanently delete:
- All uncommitted changes
- Cannot be recovered

Type 'CONFIRM' to proceed:
```

**Double confirmation for especially dangerous operations.**

---

### Step 7: Execute (Only After Explicit Approval)

If user confirms, execute the command:

```bash
git reset --hard
```

**Report result:**
```
✅ Operation completed

Executed: git reset --hard
HEAD is now at a1b2c3d Last commit message

Working directory has been reset.
All uncommitted changes have been discarded.
```

---

## Safe Alternatives Reference

### Instead of `git reset --hard`:

**Option 1: Stash**
```bash
git stash push -m "Saved before reset"
# To recover later:
git stash pop
```

**Option 2: Commit as WIP**
```bash
git add .
git commit -m "wip: save current work"
# To undo later:
git reset HEAD~1
```

**Option 3: Create backup branch**
```bash
git branch backup-$(date +%s)
git reset --hard
```

### Instead of `git clean -fd`:

**Option 1: Selective deletion**
```bash
# Review first
git clean -fd --dry-run
# Delete specific files
rm <specific-file>
```

**Option 2: Move to backup**
```bash
mkdir -p ../backup-$(date +%s)
git ls-files --others --exclude-standard | xargs -I {} mv {} ../backup-$(date +%s)/
```

### Instead of `rm -rf`:

**Option 1: Move to trash**
```bash
mkdir -p ~/.trash/$(date +%s)
mv <directory> ~/.trash/$(date +%s)/
```

**Option 2: Archive first**
```bash
tar -czf backup-$(date +%s).tar.gz <directory>
rm -rf <directory>
```

---

## Emergency Recovery

If destructive operation was accidentally executed:

### For `git reset --hard`:

```bash
# Check reflog for recent HEAD positions
git reflog

# Find the commit before reset (e.g., HEAD@{1})
git reset --hard HEAD@{1}

# Or cherry-pick specific commits
git cherry-pick <commit-hash>
```

### For `git clean`:

**No automatic recovery available.**

Possibly recover from:
- File system backups (Time Machine, etc.)
- IDE local history
- OS-level file recovery tools

### For `rm -rf`:

**Check if system has undelete:**
```bash
# macOS Time Machine
# Linux: check if trash-cli used
trash-list

# Otherwise: file recovery tools
# extundelete, testdisk, photorec, etc.
```

---

## Best Practices

1. **Always list first** - Show what will be affected
2. **Suggest alternatives** - Safer options exist for most operations
3. **Double confirm** - Especially dangerous operations get extra confirmation
4. **Be explicit** - Require exact command or clear approval
5. **Educate** - Explain what the operation does
6. **Provide recovery** - If possible, explain how to undo

---

## Anti-Patterns

### ❌ Anti-Pattern: Running Destructive Command Without Showing Impact

**Wrong approach:**
```
User: "reset my changes"
Assistant: *immediately runs `git reset --hard` without showing what will be deleted*
```

**Why wrong:**
- User doesn't see what's being lost
- No opportunity to reconsider
- No chance to use safer alternative
- Violates transparency principle

**Correct approach:** Show impact and get confirmation
```
User: "reset my changes"
Assistant: "Let me show you what will be permanently deleted..."
*shows git diff, modified files, sizes*
*suggests safer alternatives*
*waits for explicit confirmation*
```

---

### ❌ Anti-Pattern: Accepting Vague Confirmation

**Wrong approach:**
```
User: "ok"
Assistant: *runs `git reset --hard`*
```

**Why wrong:**
- "Ok" could mean anything
- User may not understand consequences
- No clear confirmation of intent
- Violates confirmation requirements

**Correct approach:** Require explicit confirmation
```
User: "ok"
Assistant: "Please explicitly type: 'I want to run git reset --hard'"
*WAITS for explicit confirmation*
```

---

### ❌ Anti-Pattern: Skipping Safer Alternatives

**Wrong approach:**
```
User: "delete these untracked files"
Assistant: *immediately runs `git clean -fd` without suggesting alternatives*
```

**Why wrong:**
- User doesn't know safer options exist
- Doesn't empower user to choose
- Violates risk mitigation principle

**Correct approach:** Always suggest alternatives first
```
User: "delete these untracked files"
Assistant: "SAFER ALTERNATIVES: 1. Move to backup, 2. Review first, 3. Add to .gitignore"
*shows what would be deleted*
*explains each alternative*
*gets explicit confirmation*
```

---

### ❌ Anti-Pattern: Proceeding Without Double Confirmation for High-Risk Ops

**Wrong approach:**
```
User: "I want to run git reset --hard"
Assistant: *immediately executes without re-confirming*
```

**Why wrong:**
- git reset --hard is especially dangerous
- User might have mistyped or changed mind
- No final safety check
- Violates protection principle

**Correct approach:** Double confirmation for dangerous ops
```
User: "I want to run git reset --hard"
Assistant: "FINAL CONFIRMATION: This will permanently delete all uncommitted changes and CANNOT be undone. Type 'CONFIRM' to proceed:"
*WAITS for explicit "CONFIRM"*
*THEN executes*
```

---

## Quick Reference

**Destructive command requested**
1. STOP - Don't execute
2. LIST - Show what will be lost
3. ASK - Suggest safer alternatives
4. WAIT - For explicit approval
5. VERIFY - Confirm understanding
6. EXECUTE - Only after approval

**Remember: It's better to annoy the user with confirmations than to lose their work.**

---

## References

**Based on:**
- CLAUDE.md Section 1 (Core Policies - DESTRUCTIVE COMMAND SAFEGUARDS, ZERO TOLERANCE)
- CLAUDE.md Section 3 (Available Skills Reference - safe-destroy)
- Project instructions: ABSOLUTELY FORBIDDEN Commands - explicit confirmation required

**Related skills:**
- `safe-commit` - Uses safe practices with git operations
