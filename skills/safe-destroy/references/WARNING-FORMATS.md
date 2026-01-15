
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
- tests/integration_test.go (28 lines changed)

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

