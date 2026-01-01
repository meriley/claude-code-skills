# Conventions & Standards

## Conventional Commit Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

**Scope is REQUIRED for all commits.**

## Commit Types

| Type | Purpose |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Code style (formatting) |
| `refactor` | Neither fix nor feature |
| `perf` | Performance improvement |
| `test` | Adding/updating tests |
| `build` | Build system/dependencies |
| `ci` | CI/CD configuration |
| `chore` | Other changes |
| `revert` | Reverts previous commit |

## Common Scopes

| Scope | Area |
|-------|------|
| `auth` | Authentication |
| `api` | API endpoints |
| `db` | Database |
| `ui` | User interface |
| `core` | Core functionality |
| `utils` | Utility functions |
| `config` | Configuration |
| `deps` | Dependencies |
| `security` | Security changes |
| `*` | Truly global changes |

## Examples

**Good commits:**
```bash
feat(auth): add OAuth2 integration for GitHub
fix(parser): handle empty input gracefully
refactor(metadata): extract to dedicated package
docs(api): update endpoint documentation
test(utils): add test cases for string helpers
security(auth): implement rate limiting
```

**Bad commits (NEVER use):**
```bash
refactor: extract metadata functionality  # Missing scope!
Updated code
Fixed stuff
WIP
```

## Breaking Changes

Mark with `!` after type/scope:

```
feat(api)!: change response format for /users endpoint
```

## Subject Guidelines

- Imperative mood ("add", not "added")
- No capital first letter
- No period at end
- Max 50 characters
- Describe WHAT and WHY, not HOW
