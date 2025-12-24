---
allowed-tools: Bash(git:*)
argument-hint: [since-tag|since-commit|since-date]
description: Generate changelog from conventional commits
---

# Generate Changelog

Auto-generate changelog entries from conventional commits.

## Usage

```
/changelog                    # Changes since last tag
/changelog v1.2.0             # Changes since specific tag
/changelog abc1234            # Changes since specific commit
/changelog 2024-01-01         # Changes since date
/changelog HEAD~20            # Last 20 commits
```

## Step 1: Determine Starting Point

If argument provided:
- Tag format (v1.x.x) → Use tag as start
- Commit hash → Use commit as start
- Date format → Use date filter
- HEAD~N → Use relative reference

If no argument:
```bash
# Get most recent tag
git describe --tags --abbrev=0 2>/dev/null || echo "No tags found, using first commit"
```

## Step 2: Fetch Commits

Get all commits since starting point:

```bash
git log ${START_REF}..HEAD --format="%H|%s|%an|%ad" --date=short
```

## Step 3: Parse Conventional Commits

Parse commit messages following Conventional Commits format:
- `feat(scope): message` → Features
- `fix(scope): message` → Bug Fixes
- `perf(scope): message` → Performance
- `docs(scope): message` → Documentation
- `refactor(scope): message` → Refactoring
- `test(scope): message` → Tests
- `build(scope): message` → Build System
- `ci(scope): message` → CI/CD
- `chore(scope): message` → Maintenance
- `revert: message` → Reverts
- `feat(scope)!: message` or `BREAKING CHANGE:` → Breaking Changes

## Step 4: Group by Type

Organize commits by type with priority ordering:

1. **Breaking Changes** (highest priority, always first)
2. **Features**
3. **Bug Fixes**
4. **Performance**
5. **Refactoring**
6. **Documentation**
7. **Tests**
8. **Build/CI**
9. **Other**

## Step 5: Generate Changelog

Output in Keep a Changelog format:

```markdown
## [Unreleased] - YYYY-MM-DD

### Breaking Changes
- **api**: Change response format for /users endpoint (#123)

### Features
- **auth**: Add OAuth2 integration for GitHub (#120)
- **parser**: Support YAML configuration files (#118)
- **ui**: Add dark mode toggle (#115)

### Bug Fixes
- **parser**: Handle empty input gracefully (#119)
- **api**: Fix race condition in concurrent requests (#117)

### Performance
- **db**: Optimize query for user lookup (#116)

### Documentation
- **api**: Update endpoint documentation (#114)

### Refactoring
- **core**: Extract metadata to dedicated package (#113)

---

**Full Changelog**: https://github.com/org/repo/compare/v1.2.0...HEAD
```

## Step 6: Statistics

Provide summary statistics:

```
CHANGELOG SUMMARY
═══════════════════════════════════════
Commits analyzed:     25
Since:                v1.2.0 (2024-01-15)
Contributors:         3

By Type:
├── Features:         8 (32%)
├── Bug Fixes:        6 (24%)
├── Refactoring:      4 (16%)
├── Documentation:    3 (12%)
├── Tests:            2 (8%)
└── Other:            2 (8%)

Breaking Changes:     1 (requires major version bump)
═══════════════════════════════════════
```

## Step 7: Non-Conventional Commits

Handle commits that don't follow conventional format:

```
WARNING: 3 commits don't follow Conventional Commits format:
- abc1234: "Updated stuff" → Consider: fix(scope): description
- def5678: "WIP" → Consider: feat(scope): description
- ghi9012: "misc changes" → Consider: chore(scope): description

Use /fix-commit-message to fix these before release.
```

## Notes

- Requires commits to follow Conventional Commits format
- Use `/fix-commit-message` to correct non-conforming commits
- Breaking changes are detected from `!` suffix or `BREAKING CHANGE:` in body
- PR/issue references (#123) are preserved in output
- Scopes are preserved and highlighted in bold
- Output is ready to paste into CHANGELOG.md
