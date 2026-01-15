
---

## Error Handling

### Error: gh CLI not installed

```
❌ GitHub CLI not found

GitHub CLI is required to create pull requests.

Install:
- macOS: brew install gh
- Linux: See https://github.com/cli/cli#installation
- Windows: See https://github.com/cli/cli#installation

After installing, authenticate:
gh auth login
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

