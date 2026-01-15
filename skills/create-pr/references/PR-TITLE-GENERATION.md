
---

## PR Title Generation

**Use commit message as PR title:**

If single commit:

- Use commit subject as-is

If multiple commits:

- Analyze all commit subjects
- Generate title that encompasses all changes
- Follow conventional commit format
- Use most significant change type

**Examples:**

Single commit:

```
Commit: feat(auth): add JWT validation
PR Title: feat(auth): add JWT validation
```

Multiple related commits:

```
Commits:
- feat(auth): add JWT validation
- feat(auth): implement refresh tokens
- test(auth): add integration tests

PR Title: feat(auth): implement JWT authentication system
```

Mixed commit types (use most significant):

```
Commits:
- feat(auth): add JWT validation
- fix(auth): handle expired tokens
- test(auth): add tests

PR Title: feat(auth): add JWT authentication with token handling
```
