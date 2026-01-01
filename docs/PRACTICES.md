# Best Practices

## SPARC Framework

For significant projects (> 8 hours), use `sparc-plan` skill:

| Phase | Focus |
|-------|-------|
| **S**pecification | Requirements, constraints, success criteria |
| **P**seudocode | High-level algorithms |
| **A**rchitecture | System design, components, data models |
| **R**efinement | Iterative improvement |
| **C**ompletion | Definition of done, checklists |

## Workflow Summary

1. **Check History**: `check-history` skill (ALWAYS first)
2. **Plan**: `sparc-plan` skill (if significant work)
3. **Implement**: Build following the plan
4. **Commit**: `safe-commit` skill (requires approval)
5. **Create PR**: `create-pr` skill (only auto-commit scenario)

## Code Documentation

Write self-documenting code:

- **Descriptive naming**: Functions express purpose
- **Comments for WHY**: Not what (code shows what)
- **No obvious comments**: Avoid redundancy
- **Concise API docs**: Minimal, maintainable
- **Refactor over explain**: Extract to named functions

## Best Practices Checklist

1. Check git history before starting
2. Plan before implementing (significant work)
3. Security by design (never retrofit)
4. Performance awareness (profile early)
5. Start simple, enhance progressively
6. Test incrementally (TDD when appropriate)
7. Use descriptive naming
8. Follow language conventions
9. Handle errors gracefully
10. Get user approval for milestones
11. Batch tool calls for efficiency
12. Never commit secrets

## Tool Usage

### Parallel Operations

Use concurrent tool calls when:
- Reading multiple unrelated files
- Running independent bash commands
- Performing multiple searches
- Executing independent git operations

### Context7

Always check Context7 first for external libraries:
```
mcp__context7__resolve-library-id
mcp__context7__query-docs
```

### Memory Management

- Large codebases: Use targeted searches
- Long operations: Set appropriate timeouts
- Batch operations: Group related tasks

## Anti-Patterns (NEVER DO)

### Git Operations
- `git add && git commit` → Use `safe-commit`
- `git push && gh pr create` → Use `create-pr`
- `git reset --hard` → Use `safe-destroy`
- `git branch` → Use `manage-branch`

### Quality Checks
- Manual `npm test` → Let `safe-commit` run tests
- Manual `eslint` → Let `safe-commit` run linters
- Manual secret grep → Let `security-scan` handle

### Setup
- Manual `go mod tidy` → Use `setup-go`
- Manual `npm install` → Use `setup-node`
- Manual `pip install` → Use `setup-python` (with uv)
