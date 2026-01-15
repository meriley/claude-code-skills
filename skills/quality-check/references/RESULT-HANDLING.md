---

## Step 3: Handle Check Results

### If All Checks Pass:

```
✅ Code Quality PASSED

All checks completed:
- [Language]: Formatting ✓
- [Language]: Linting ✓
- [Language]: Type checking ✓
- [Language]: Static analysis ✓

Code quality verified. Safe to commit.
```

### If Auto-Fixable Issues:

1. Run auto-fix commands
2. Show what was fixed:

   ```
   🔧 Auto-fixed code quality issues:

   - Formatted 5 files with prettier
   - Fixed 3 linting issues with eslint --fix
   - Sorted imports in 2 Python files

   Changes have been applied. Please review the fixes.
   ```

3. Re-run checks to verify
4. If still failing after auto-fix, report manual issues

### If Manual Fixes Required:

```
❌ Code Quality FAILED

Manual fixes required:

[TypeScript Type Errors]
src/utils/parser.ts:42:15 - error TS2339: Property 'value' does not exist on type '{}'.
src/api/handlers.ts:128:20 - error TS2345: Argument of type 'string' is not assignable to parameter of type 'number'.

[Python flake8]
app/models.py:56:80: E501 line too long (88 > 79 characters)
app/views.py:23:1: F401 'typing.Optional' imported but unused

[Go vet]
pkg/parser/parser.go:145: composite literal uses unkeyed fields

MUST fix these issues before commit.

Suggestions:
- Review type definitions in parser.ts
- Add type assertions where needed
- Break long lines or increase line length limit
- Remove unused imports
- Use keyed fields in Go structs
```

## Step 4: Verify All Languages

If project has multiple languages, ensure ALL languages pass before proceeding.

```
Multi-Language Check:
- Go: ✅ PASSED
- TypeScript: ❌ FAILED (3 type errors)
- Python: ✅ PASSED

Cannot proceed - TypeScript checks must pass.
```
