## Review Output Format

### Comprehensive Report Structure

```markdown
# Cursor Rule Review: [rule-name.mdc]

**Status:** ❌ FAILED (2 BLOCKER, 3 MAJOR, 1 MINOR)
**Date:** 2024-01-16
**Reviewer:** Claude/mriley

## Summary

| Gate                    | Status  | Blocker | Critical | Major | Minor |
| ----------------------- | ------- | ------- | -------- | ----- | ----- |
| Gate 1: Frontmatter     | ❌ FAIL | 1       | 0        | 1     | 0     |
| Gate 2: Glob Patterns   | ✅ PASS | 0       | 0        | 0     | 0     |
| Gate 3: Content Quality | ⚠️ WARN | 0       | 0        | 2     | 1     |
| Gate 4: File Length     | ✅ PASS | 0       | 0        | 0     | 0     |
| Gate 5: Functionality   | ❌ FAIL | 1       | 0        | 0     | 0     |
| **TOTAL**               | ❌ FAIL | **2**   | **0**    | **3** | **1** |

---

## 🚫 BLOCKER Issues (Must Fix Before Merge)

### Gate 1.1: Invalid YAML Syntax

- **Issue:** Missing closing `---` in frontmatter
- **Location:** Line 1-5
- **Fix:** Add `---` after line 5
- **Impact:** Rule will not parse at all

### Gate 5.1: Rule Doesn't Trigger

- **Issue:** Glob pattern `**/*.tsx` doesn't match test files
- **Expected:** Should trigger for `src/components/Button.tsx`
- **Actual:** No trigger
- **Fix:** Verify glob syntax and test with `find`

---

## 🚨 MAJOR Issues (Should Fix Soon)

### Gate 1.3: Vague Description

- **Current:** "Helps with components."
- **Issue:** Too vague, no context about WHAT or WHEN
- **Recommended:** "React component patterns including props typing and hooks usage. Apply when creating or modifying React components."

### Gate 3.1: Mixed Topics

- **Issue:** Rule mixes API design + UI components
- **Recommendation:** Split into:
  - `api-design-patterns.mdc`
  - `react-component-patterns.mdc`

### Gate 3.3: Missing Examples

- **Issue:** No code examples provided
- **Recommendation:** Add good/bad pattern examples

---

## ⚠️ MINOR Issues (Nice to Have)

### Gate 1.3: First-Person Description

- **Current:** "I provide patterns for..."
- **Recommendation:** "Provides patterns for..." (third person)

---

## Recommendations

**Immediate Actions (BLOCKER - Before Merge):**

1. Fix YAML frontmatter syntax
2. Fix glob pattern to trigger correctly

**Short-term Actions (MAJOR - This Week):**

1. Improve description quality
2. Split mixed-topic rule
3. Add code examples

**Long-term Actions (MINOR - When Convenient):**

1. Convert to third-person voice
```
