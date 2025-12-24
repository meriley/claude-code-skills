---
allowed-tools: Bash(git:*), Bash(rm:*), Bash(find:*), AskUserQuestion
argument-hint: [branches|artifacts|all]
description: Safe cleanup of merged branches, stale refs, and build artifacts
---

# Safe Cleanup

Repository hygiene with safety checks and confirmation.

## Usage

```
/cleanup                 # Interactive cleanup menu
/cleanup branches        # Clean merged branches only
/cleanup artifacts       # Clean build artifacts only
/cleanup all             # Full cleanup with confirmation
```

## SAFETY FIRST

**This command invokes `safe-destroy` skill patterns:**
- Always lists what will be deleted BEFORE deletion
- Requires explicit confirmation
- Never touches unmerged branches
- Preserves main/master and current branch
- Provides recovery hints

---

## Step 1: Analyze What Can Be Cleaned

### Merged Branches

```bash
# Find merged branches (excluding main/master/current)
git branch --merged | grep -vE "^\*|main|master" | wc -l

# List them
git branch --merged | grep -vE "^\*|main|master"
```

### Stale Remote Refs

```bash
# Find stale remote tracking branches
git remote prune origin --dry-run
```

### Build Artifacts

Common patterns to clean:
- `node_modules/` (can reinstall with npm install)
- `dist/`, `build/`, `out/` (can rebuild)
- `.next/`, `.nuxt/` (Next.js/Nuxt.js cache)
- `__pycache__/`, `*.pyc` (Python bytecode)
- `vendor/` (Go vendor, if using modules)
- `target/` (Rust/Java build output)
- `coverage/` (test coverage reports)
- `.cache/` (various caches)

```bash
# Calculate artifact sizes
du -sh node_modules dist build coverage .next 2>/dev/null
```

## Step 2: Present Cleanup Options

```
╔══════════════════════════════════════════════════════════════╗
║                      CLEANUP ANALYSIS                         ║
╠══════════════════════════════════════════════════════════════╣

## Merged Branches (5 branches, safe to delete)

| Branch                          | Merged Into | Age        |
|---------------------------------|-------------|------------|
| mriley/feat/old-feature         | main        | 3 weeks    |
| mriley/fix/typo                 | main        | 1 month    |
| mriley/refactor/cleanup         | main        | 2 months   |
| mriley/test/experiment          | main        | 2 months   |
| mriley/docs/readme-update       | main        | 3 months   |

## Stale Remote Refs (3 refs)

| Remote Ref                      | Reason           |
|---------------------------------|------------------|
| origin/mriley/feat/old-feature  | Branch deleted   |
| origin/mriley/fix/typo          | Branch deleted   |
| origin/feature/abandoned        | Branch deleted   |

## Build Artifacts (847 MB total)

| Path          | Size   | Recoverable?                    |
|---------------|--------|---------------------------------|
| node_modules/ | 650 MB | Yes - npm install               |
| dist/         | 120 MB | Yes - npm run build             |
| coverage/     | 45 MB  | Yes - npm test -- --coverage    |
| .next/        | 32 MB  | Yes - npm run build             |

╚══════════════════════════════════════════════════════════════╝
```

## Step 3: Request Confirmation

Use AskUserQuestion to confirm:

```
What would you like to clean up?

[ ] Merged branches (5 branches)
[ ] Stale remote refs (3 refs)
[ ] Build artifacts (847 MB)
[ ] All of the above
[ ] Cancel - do nothing
```

## Step 4: Execute Cleanup (After Confirmation)

### Delete Merged Branches

```bash
# Delete local merged branches
git branch --merged | grep -vE "^\*|main|master" | xargs -r git branch -d

# Prune remote tracking branches
git remote prune origin
```

### Delete Build Artifacts

```bash
# Remove common build directories
rm -rf node_modules dist build coverage .next .nuxt __pycache__ target vendor .cache

# Clean git ignored files (optional, with extra confirmation)
# git clean -Xfd
```

## Step 5: Report Results

```
╔══════════════════════════════════════════════════════════════╗
║                      CLEANUP COMPLETE                         ║
╠══════════════════════════════════════════════════════════════╣

## Actions Taken

✅ Deleted 5 merged branches
✅ Pruned 3 stale remote refs
✅ Removed 847 MB of build artifacts

## Recovery Commands (if needed)

# Restore node_modules
npm install

# Rebuild dist
npm run build

# Regenerate coverage
npm test -- --coverage

## Disk Space Freed: 847 MB

╚══════════════════════════════════════════════════════════════╝
```

## Protected Items (Never Deleted)

- `main` / `master` branches
- Current branch (checked out)
- Unmerged branches
- `.git/` directory
- Source code files
- Configuration files
- `.env` files

## Notes

- This command is READ-ONLY until explicit confirmation
- Uses `safe-destroy` skill patterns for safety
- Merged branches can be recovered from reflog for 90 days
- Build artifacts are always recoverable by rebuilding
- Run `/quick-status` after cleanup to verify state
