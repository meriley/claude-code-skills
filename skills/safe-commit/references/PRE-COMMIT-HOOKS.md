---

## Handling Pre-Commit Hooks

If pre-commit hooks modify files:

1. **First commit attempt** - May fail if hooks modify files
2. **Check for modifications:**
   ```bash
   git status
   ```
3. **If files modified by hooks:**
   - Show user what changed
   - Explain hooks modified files
   - Check if safe to amend:
     - Verify author is mriley: `git log -1 --format='%an %ae'`
     - Verify not pushed: `git status` shows "Your branch is ahead"
   - If safe: Amend commit
     ```bash
     git add .
     git commit --amend --no-edit
     ```
4. **Re-verify commit**

**NEVER amend if:**

- Author is not mriley
- Commit already pushed
- Multiple commits since (not HEAD)

