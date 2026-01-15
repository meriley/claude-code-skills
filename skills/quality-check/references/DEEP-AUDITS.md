---

## Step 2.5: Language-Specific Deep Audits

After standard linting/formatting, run specialized audits based on detected languages.

### For Go Projects

#### Invoke `control-flow-check` Skill

```bash
/skill control-flow-check
```

**What it audits:**

- Early return pattern usage
- Excessive nesting (> 2-3 levels)
- Large if/else blocks (> 10 lines)
- Guard clause placement
- Complex control flow refactoring opportunities

#### Invoke `error-handling-audit` Skill

```bash
/skill error-handling-audit
```

**What it audits:**

- Error wrapping with `%w` vs `%v`
- Error context sufficiency
- Error message formatting
- Error swallowing
- Panic usage outside initialization
- Error propagation patterns

**Report CRITICAL issues** from these audits - they should block commit.

---

### For TypeScript Projects

#### Invoke `type-safety-audit` Skill

```bash
/skill type-safety-audit
```

**What it audits:**

- `any` type usage (zero tolerance)
- Branded types for IDs
- Runtime validation at API boundaries
- Type guards vs type assertions
- Null/undefined handling
- Generic constraints
- tsconfig.json strict mode

**Report CRITICAL issues** from this audit - they should block commit.

---

### For TypeScript + GraphQL Projects

#### Invoke `n-plus-one-detection` Skill (in addition to type-safety-audit)

```bash
/skill n-plus-one-detection
```

**What it audits:**

- N+1 query problems in resolvers
- Missing DataLoader usage
- Sequential queries in loops
- Nested resolver chains
- Performance impact estimation

**Report CRITICAL N+1 problems** - they have severe performance impact.

---

### Audit Results Integration

After running language-specific audits:

1. **Collect all CRITICAL issues** from specialized audits
2. **Combine with linting/formatting results**
3. **Block commit if any CRITICAL issues found**
4. **Report HIGH/MEDIUM issues as warnings**

Example combined output:

```
📊 Quality Check Summary:

Standard Checks:
✅ Go formatting (gofmt)
✅ Go static analysis (go vet)
✅ Go linting (golangci-lint)

Deep Audits:
❌ Control Flow: 2 CRITICAL issues
  - TaskService.ProcessTask (line 45): Nesting depth 4 levels
  - UserService.ValidateUser (line 120): 15-line if block needs extraction
⚠️  Error Handling: 5 HIGH issues
  - Using %v instead of %w in 3 locations
  - Missing error context in 2 locations

RESULT: ❌ FAILED - Must fix 2 CRITICAL control flow issues before commit
```

