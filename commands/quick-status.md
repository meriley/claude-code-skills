---
allowed-tools: Bash(git:*)
argument-hint:
description: Quick visual overview of current git repository state
---

# Quick Status

Visual dashboard showing current git state at a glance.

## Usage

```
/quick-status    # Show git dashboard
```

## Step 1: Gather Git Information (Parallel)

Execute these commands in parallel:

```bash
git branch --show-current &
git status --porcelain &
git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null &
git log -1 --format="%h %s (%ar)" &
git stash list | wc -l &
```

## Step 2: Parse Results

From the command outputs, extract:
- **Current branch**: From `git branch --show-current`
- **File status**: Parse `git status --porcelain`
  - `M` = modified
  - `A` = added/staged
  - `?` = untracked
  - `D` = deleted
- **Ahead/Behind**: From `git rev-list` (format: `behind<TAB>ahead`)
- **Last commit**: From `git log -1`
- **Stash count**: From `git stash list`

## Step 3: Generate Dashboard

Output a visual dashboard:

```
╔══════════════════════════════════════════════════════════════╗
║                      GIT STATUS DASHBOARD                     ║
╠══════════════════════════════════════════════════════════════╣
║  Branch:     mriley/feat/new-feature                         ║
║  Remote:     origin/mriley/feat/new-feature                  ║
╠══════════════════════════════════════════════════════════════╣
║  WORKING DIRECTORY                                            ║
║  ├── Modified:   3 files                                     ║
║  ├── Staged:     2 files                                     ║
║  ├── Untracked:  1 file                                      ║
║  └── Deleted:    0 files                                     ║
╠══════════════════════════════════════════════════════════════╣
║  SYNC STATUS                                                  ║
║  ├── Ahead:   2 commits (ready to push)                      ║
║  ├── Behind:  0 commits                                      ║
║  └── Stashes: 1 stash                                        ║
╠══════════════════════════════════════════════════════════════╣
║  LAST COMMIT                                                  ║
║  └── abc1234 feat(api): add user endpoint (2 hours ago)      ║
╚══════════════════════════════════════════════════════════════╝
```

## Step 4: Status Indicators

Add visual indicators for common states:

- **Clean working directory**: Show green checkmark
- **Uncommitted changes**: Show yellow warning
- **Unpushed commits**: Show "ready to push" hint
- **Behind remote**: Show "pull recommended" warning
- **Stashes present**: Show stash count

## Step 5: Quick Actions (Suggestions)

Based on state, suggest next actions:

```
SUGGESTED ACTIONS:
├── You have uncommitted changes → Consider: git add . && /safe-commit
├── 2 commits ahead → Consider: git push or /create-pr
└── 1 stash available → Consider: git stash pop
```

## Notes

- This is a READ-ONLY command - it makes no changes
- For full git context with analysis, use `check-history` skill
- For commit workflow, use `safe-commit` skill
- Shows relative time for last commit ("2 hours ago")
