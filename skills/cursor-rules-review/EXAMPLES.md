# Cursor Rules Review Examples

This file provides sample review reports demonstrating the 5-gate review process for both good and problematic rules.

---

## Example 1: Well-Written Rule (APPROVED)

### Rule File: react-components.mdc

```markdown
---
description: React component patterns including props typing, hooks usage, and component structure. Apply when creating or modifying React components.
globs: ["**/*.tsx", "**/components/**/*.ts", "**/hooks/**/*.ts"]
alwaysApply: false
---

# React Component Patterns

## Overview
This rule provides guidance for writing React components following team conventions and TypeScript best practices.

**Related rules:** See @typescript-patterns.mdc for general TypeScript guidance, @testing.mdc for component testing patterns.

---

## Props Typing

### Interface Pattern

\`\`\`typescript
// ✅ Good - Explicit props interface
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

export function Button({
  label,
  onClick,
  variant = 'primary',
  disabled = false
}: ButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={\`btn btn-\${variant}\`}
    >
      {label}
    </button>
  );
}

// ❌ Bad - No type safety
export function Button({ label, onClick, variant }) {
  return <button onClick={onClick}>{label}</button>;
}
\`\`\`

---

## Hooks Usage

### useState Pattern

\`\`\`typescript
// ✅ Good - Type-safe state
function Counter() {
  const [count, setCount] = useState<number>(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}

// ❌ Bad - Implicit any
function Counter() {
  const [count, setCount] = useState(0);  // type could be number | string
  return <button onClick={() => setCount('wrong')}>{count}</button>;
}
\`\`\`

---

## Resources

- [React TypeScript Cheatsheet](https://react-typescript-cheatsheet.netlify.app/)
- [Team Component Guidelines](./docs/components.md)
```

### Review Report

```markdown
# Cursor Rule Review: react-components.mdc

**Reviewed by:** Senior Engineer
**Date:** 2024-11-21
**Overall Status:** ✅ APPROVED

---

## Summary

Excellent rule that provides clear React component patterns with proper TypeScript typing. Well-structured with concrete examples and appropriate triggering.

---

## Gate 1: Frontmatter Review

**Status:** ✅ PASS

- ✅ Valid YAML syntax
- ✅ Description is specific and clear
- ✅ Uses third person ("provides guidance")
- ✅ Includes "when" context ("when creating or modifying")
- ✅ Appropriate file-based triggering
- ✅ Glob patterns target React files
- ✅ alwaysApply correctly set to false

**Issues:** None

---

## Gate 2: Glob Patterns Review

**Status:** ✅ PASS

- ✅ Patterns use **/ for recursion
- ✅ Covers .tsx files (components)
- ✅ Covers component utilities (.ts in components/)
- ✅ Covers custom hooks
- ✅ Appropriately specific

**Verified with:**
```bash
find . -path "**/*.tsx" | head -5
# src/components/Button.tsx ✓
# src/components/Modal.tsx ✓
# src/pages/Home.tsx ✓
```

**Issues:** None

---

## Gate 3: Content Quality Review

**Status:** ✅ PASS

- ✅ Has Overview with cross-references
- ✅ Well-organized sections
- ✅ Concrete TypeScript/React examples
- ✅ Shows good AND bad patterns (✅/❌)
- ✅ Cross-references to @typescript-patterns.mdc and @testing.mdc
- ✅ Actionable guidance with code
- ✅ Resources section included

**Issues:** None

---

## Gate 4: File Length Review

**Status:** ✅ PASS

**Line count:** 85 lines
**Target:** Under 500 lines ✅

- ✅ Well under target
- ✅ Concise and focused
- ✅ Appropriate content density

**Issues:** None

---

## Gate 5: Functionality Review

**Status:** ✅ PASS

**Tests performed:**
1. Opened `Button.tsx` → Rule loaded ✅
2. Opened `utils.ts` (non-component) → Rule didn't load ✅
3. Verified @typescript-patterns.mdc exists ✅
4. Verified @testing.mdc exists ✅
5. Used in Cursor chat → Relevant context provided ✅

**Issues:** None

---

## Recommendations

### Must Fix (BLOCKER/CRITICAL)
None

### Should Fix (MAJOR)
None

### Nice to Have (MINOR)
1. Could add example of useEffect with cleanup
2. Could mention memo/useMemo for performance

---

## Overall Assessment

This is an exemplary Cursor rule that demonstrates all best practices:
- Clear, specific frontmatter
- Appropriate glob patterns
- Concrete, realistic examples
- Proper cross-references
- Concise length
- Valuable context for React development

**Approve?** ✅ YES

**Conditions:** None

---

**Review complete.**
```

---

## Example 2: Problematic Rule (NEEDS WORK)

### Rule File: api-stuff.mdc

```markdown
---
description: API stuff
globs: ["**/*"]
alwaysApply: true
---

# API Helper

This helps you with APIs.

You should use good patterns when working with APIs. Make sure to handle errors properly and follow best practices.

See other-rule.mdc for more info.

Here's an example:

\`\`\`
function api() {
  // do API stuff
}
\`\`\`

Remember to be careful with security!
```

### Review Report

```markdown
# Cursor Rule Review: api-stuff.mdc

**Reviewed by:** Senior Engineer
**Date:** 2024-11-21
**Overall Status:** 🚫 BLOCKED

---

## Summary

This rule has multiple BLOCKER and CRITICAL issues that prevent it from being effective. Requires significant rework before approval.

---

## Gate 1: Frontmatter Review

**Status:** ⚠️ ISSUES

Issues found:
- ❌ **CRITICAL:** Description is vague ("API stuff") - doesn't explain what context is provided
- ❌ **MAJOR:** Description missing "when to use" context
- ❌ **CRITICAL:** `alwaysApply: true` for API-specific content (should be file-based)
- ❌ **CRITICAL:** Globs pattern `**/*` matches ALL files (extreme context bloat)

**Recommendations:**
1. Rewrite description: "REST API design patterns including endpoint structure, request/response formats, and error handling. Apply when working with API routes and controllers."
2. Change to file-based triggering: `alwaysApply: false`
3. Use specific globs: `globs: ["**/api/**/*", "**/routes/**/*", "**/controllers/**/*"]`

---

## Gate 2: Glob Patterns Review

**Status:** ⚠️ ISSUES

Issues found:
- ❌ **BLOCKER:** Pattern `**/*` matches ALL files
- ❌ **CRITICAL:** Will load API context for tests, docs, configs, everything
- ❌ **CRITICAL:** Causes massive context pollution
- ❌ **MAJOR:** No specificity whatsoever

**Test results:**
```bash
find . -path "**/*" | wc -l
# 15,432 files (!!)
```

**Recommendations:**
Replace with specific patterns:
```yaml
globs: [
  "**/api/**/*",
  "**/routes/**/*",
  "**/controllers/**/*"
]
```

---

## Gate 3: Content Quality Review

**Status:** ⚠️ ISSUES

Issues found:
- ❌ **CRITICAL:** No concrete code examples (only abstract advice)
- ❌ **CRITICAL:** Vague guidance ("use good patterns", "be careful")
- ❌ **CRITICAL:** Placeholder example that doesn't show real patterns
- ❌ **MAJOR:** No Overview section
- ❌ **MAJOR:** No section organization (no `---` separators)
- ❌ **MAJOR:** Cross-reference broken: "other-rule.mdc" doesn't use @ syntax
- ❌ **MAJOR:** No good vs bad patterns
- ❌ **MAJOR:** No Resources section

**Current example:**
```javascript
function api() {
  // do API stuff  ← Not helpful
}
```

**Should be:**
```typescript
// ✅ Good - Complete error handling
app.get('/api/users/:id', async (req, res) => {
  try {
    const user = await userService.findById(req.params.id);
    if (!user) {
      return res.status(404).json({
        error: 'User not found'
      });
    }
    res.json({ data: user });
  } catch (error) {
    logger.error('Failed to fetch user', { error });
    res.status(500).json({
      error: 'Internal server error'
    });
  }
});
```

**Recommendations:**
1. Add proper Overview with cross-references
2. Add 3+ concrete, realistic API examples
3. Show good AND bad patterns with ✅/❌
4. Organize into sections separated by `---`
5. Fix cross-reference: `@error-handling.mdc`
6. Add Resources section

---

## Gate 4: File Length Review

**Status:** ✅ PASS

**Line count:** 25 lines
**Target:** Under 500 lines ✅

Issues found:
- ℹ️ **MINOR:** Could add more content once core issues fixed

---

## Gate 5: Functionality Review

**Status:** ⚠️ ISSUES

Issues found:
- ❌ **BLOCKER:** Loads in every chat (alwaysApply true)
- ❌ **BLOCKER:** Loads for non-API files due to glob `**/*`
- ❌ **CRITICAL:** Broken cross-reference (no @ syntax, file doesn't exist)
- ❌ **CRITICAL:** Context not helpful (too vague)

**Test results:**
```bash
# Opened README.md → API rule loaded (WRONG)
# Opened package.json → API rule loaded (WRONG)
# Opened api/users.ts → API rule loaded (correct, but unhelpful)
```

**Recommendations:**
1. Fix frontmatter (remove alwaysApply, add specific globs)
2. Verify cross-referenced files exist
3. Add substantial, helpful content
4. Test that rule only loads for API files

---

## Recommendations

### Must Fix (BLOCKER/CRITICAL)

1. **Fix frontmatter description:**
   ```yaml
   description: REST API design patterns including endpoint structure, request/response formats, and error handling. Apply when working with API routes and controllers.
   ```

2. **Fix triggering - remove alwaysApply, add specific globs:**
   ```yaml
   globs: ["**/api/**/*", "**/routes/**/*", "**/controllers/**/*"]
   alwaysApply: false
   ```

3. **Add concrete code examples:**
   - Complete API endpoint example
   - Error handling pattern
   - Request validation
   - Response formatting
   - Show ✅ good and ❌ bad for each

4. **Fix cross-reference:**
   ```markdown
   **Related rules:** See @error-handling.mdc for error patterns.
   ```

5. **Add proper structure:**
   ```markdown
   ## Overview
   ...

   **Related rules:** ...

   ---

   ## Endpoint Patterns
   ...

   ---

   ## Error Handling
   ...

   ---

   ## Resources
   ...
   ```

### Should Fix (MAJOR)
None (focus on blockers/critical first)

### Nice to Have (MINOR)
1. Add authentication patterns once core fixed
2. Add validation examples once core fixed

---

## Overall Assessment

This rule has fundamental issues that make it ineffective and potentially harmful:

**Problems:**
- Vague description provides no useful context
- `alwaysApply: true` with `globs: ["**/*"]` creates massive context bloat
- Loads API context for every file type (tests, docs, configs)
- No concrete examples - only abstract advice
- Broken cross-references
- Poor organization

**Impact:**
- Wastes token budget
- Pollutes context unnecessarily
- Provides no actionable guidance
- Makes Cursor slower

**Required changes:**
1. Complete frontmatter rewrite
2. Add specific glob patterns
3. Add substantial, concrete content
4. Fix organization and structure

**Approve?** 🚫 NO - BLOCKED

**Conditions:**
- Must fix all BLOCKER issues
- Must fix all CRITICAL issues
- Must add concrete examples
- Must retest after fixes

**Estimated rework:** 2-3 hours

---

**Review complete. Please address all BLOCKER and CRITICAL issues before resubmitting.**
```

---

## Example 3: Rule Needing Minor Improvements (APPROVED with suggestions)

### Rule File: typescript-patterns.mdc

```markdown
---
description: TypeScript type safety patterns and best practices. Apply when working with TypeScript code.
globs: ["**/*.ts", "**/*.tsx"]
alwaysApply: false
---

# TypeScript Patterns

## Overview
This rule provides TypeScript-specific guidance for type safety and best practices.

Related rules: typescript-advanced.mdc has more details.

---

## Type Safety

Always use explicit types:

\`\`\`typescript
// ✅ Good
interface User {
  id: string;
  name: string;
}

function getUser(id: string): User {
  // implementation
}

// ❌ Bad
function getUser(id) {
  // implementation
}
\`\`\`

---

## Resources

- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
```

### Review Report

```markdown
# Cursor Rule Review: typescript-patterns.mdc

**Reviewed by:** Senior Engineer
**Date:** 2024-11-21
**Overall Status:** ✅ APPROVED (with minor suggestions)

---

## Summary

Good rule with solid fundamentals. A few minor improvements would make it excellent, but it's ready for production use as-is.

---

## Gate 1: Frontmatter Review

**Status:** ✅ PASS

- ✅ Valid YAML syntax
- ✅ Description is specific
- ✅ Uses third person
- ✅ Includes "when" context
- ✅ Appropriate file-based triggering
- ✅ Glob patterns correct

**Issues:** None

---

## Gate 2: Glob Patterns Review

**Status:** ✅ PASS

- ✅ Patterns use **/ recursively
- ✅ Covers both .ts and .tsx
- ✅ Appropriately specific

**Issues:** None

---

## Gate 3: Content Quality Review

**Status:** ✅ PASS (with minor notes)

- ✅ Has Overview section
- ✅ Concrete code example
- ✅ Shows good AND bad patterns
- ✅ Resources section

Issues found:
- ℹ️ **MINOR:** Cross-reference missing @ syntax: "typescript-advanced.mdc" should be "@typescript-advanced.mdc"
- ℹ️ **MINOR:** Could add more examples (only 1 substantial example)
- ℹ️ **MINOR:** Missing `---` separator before Resources section

**Recommendations:**
1. Fix cross-reference:
   ```markdown
   **Related rules:** See @typescript-advanced.mdc for advanced patterns.
   ```

2. Add separator before Resources:
   ```markdown
   ---

   ## Resources
   ```

3. Consider adding 1-2 more examples:
   - Type guards
   - Branded types
   - Generic constraints

---

## Gate 4: File Length Review

**Status:** ✅ PASS

**Line count:** 52 lines
**Target:** Under 500 lines ✅

Issues found:
- ℹ️ **MINOR:** Has room for additional examples if desired

---

## Gate 5: Functionality Review

**Status:** ✅ PASS

- ✅ Rule loads for .ts files
- ✅ Rule loads for .tsx files
- ✅ Doesn't load for non-TypeScript files
- ✅ Context is helpful
- ✅ No performance issues

Issues found:
- ℹ️ **MINOR:** Should verify typescript-advanced.mdc exists after fixing reference

---

## Recommendations

### Must Fix (BLOCKER/CRITICAL)
None

### Should Fix (MAJOR)
None

### Nice to Have (MINOR)

1. **Fix cross-reference syntax:**
   ```markdown
   **Related rules:** See @typescript-advanced.mdc for advanced patterns.
   ```

2. **Add section separator:**
   ```markdown
   ---

   ## Resources
   ```

3. **Consider adding more examples:**
   - Type guards example
   - Branded types for type-safe IDs
   - Generic constraints

4. **Verify referenced rule exists:**
   ```bash
   ls .cursor/rules/typescript-advanced.mdc
   ```

---

## Overall Assessment

This is a solid, functional rule that follows best practices. The issues found are all minor and cosmetic - the rule works well as-is.

**Strengths:**
- Clear frontmatter
- Appropriate triggering
- Concrete examples
- Good vs bad patterns
- Concise and focused

**Minor improvements:**
- Fix cross-reference syntax for consistency
- Add section separators for better organization
- Could expand with more examples

**Approve?** ✅ YES

**Conditions:** None (suggestions are optional improvements)

**Priority:** Minor improvements can be addressed in future PR or at team's discretion.

---

**Review complete. Approved for production with optional minor improvements.**
```

---

## Common Review Patterns

### Pattern 1: Missing Frontmatter
```markdown
**Status:** 🚫 BLOCKED

**Issue:** No YAML frontmatter

**Fix:**
\`\`\`yaml
---
description: [Specific description of what this rule provides and when to use it]
globs: ["**/*.ext"]
alwaysApply: false
---
\`\`\`

**Severity:** BLOCKER
```

### Pattern 2: Overly Broad Globs
```markdown
**Status:** ⚠️ CRITICAL

**Issue:** Pattern `**/*` or `**/*.yaml` too broad

**Current:**
\`\`\`yaml
globs: ["**/*.yaml"]
\`\`\`

**Should be:**
\`\`\`yaml
globs: ["**/Chart.yaml", "**/values*.yaml", "**/templates/**/*.yaml"]
\`\`\`

**Severity:** CRITICAL
```

### Pattern 3: No Concrete Examples
```markdown
**Status:** ⚠️ CRITICAL

**Issue:** Only abstract advice, no code examples

**Current:**
"Make sure to use proper error handling."

**Should be:**
\`\`\`typescript
// ✅ Good - Complete error handling
try {
  const result = await operation();
  return result;
} catch (error) {
  logger.error('Operation failed', { error });
  throw new CustomError('Failed', error);
}

// ❌ Bad - No error handling
const result = await operation();
return result;
\`\`\`

**Severity:** CRITICAL
```

### Pattern 4: Broken Cross-References
```markdown
**Status:** ⚠️ CRITICAL

**Issue:** Cross-reference syntax incorrect or file doesn't exist

**Current:**
"See other-rule.mdc for more info"

**Should be:**
"See @api-patterns.mdc for API design patterns"

**Verify:**
\`\`\`bash
ls .cursor/rules/api-patterns.mdc  # Must exist
\`\`\`

**Severity:** CRITICAL
```

### Pattern 5: File Too Long
```markdown
**Status:** ⚠️ MAJOR/CRITICAL

**Issue:** File is 850 lines (over 700 limit)

**Recommendation:** Split into focused rules:
- core-overview.mdc (200 lines, always-apply)
- patterns-basic.mdc (400 lines, file-based)
- patterns-advanced.mdc (350 lines, manual)

**Severity:** CRITICAL (over 700 lines)
```

---

## Quick Reference Summary

| Issue | Severity | Typical Fix Time |
|-------|----------|------------------|
| Missing frontmatter | BLOCKER | 5 minutes |
| Invalid YAML syntax | BLOCKER | 2 minutes |
| Glob too broad | CRITICAL | 5 minutes |
| No code examples | CRITICAL | 20-30 minutes |
| Vague description | CRITICAL/MAJOR | 5 minutes |
| Broken cross-ref | CRITICAL | 2 minutes |
| File too long | CRITICAL/MAJOR | 1-2 hours |
| Missing @ syntax | MINOR | 1 minute |
| Missing separators | MINOR | 2 minutes |
| Could add examples | MINOR | 15 minutes |

---

**These examples follow the cursor-rules-review skill best practices and demonstrate real-world review scenarios.**
