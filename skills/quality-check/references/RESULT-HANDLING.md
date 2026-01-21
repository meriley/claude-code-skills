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

### If Auto-Fixable Issues (ANY Language):

1. Run auto-fix commands for the language
2. Show what was fixed:

   ```
   🔧 Auto-fixed code quality issues:

   - [Tool]: Fixed N issues
   - [Tool]: Formatted N files

   ⚠️ VERIFYING FIXES - DO NOT SKIP THIS STEP
   ```

3. **CRITICAL: Re-run ALL checks that had issues**
   - This step is MANDATORY, not optional
   - Assuming fixes worked is FORBIDDEN
   - Must see clean output before proceeding
   - Applies to ALL languages, ALL tools

4. **If rerun still shows issues:**
   - Report remaining issues
   - Fix them (manually if needed)
   - **RERUN AGAIN** - repeat until clean
   - DO NOT proceed to commit until clean pass
   - DO NOT assume "it's probably fine"

5. **Only after clean rerun:** Proceed to next step

### If Manual Fixes Applied:

**CRITICAL: Manual fixes ALSO require rerun verification.**

1. Fix the reported issues in code
2. **MUST rerun quality check** - not optional
3. If rerun shows new/remaining issues → fix and rerun again
4. Repeat until clean pass
5. **Commits blocked until latest run shows zero issues**

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
