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
