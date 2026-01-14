---
name: cursor-rules-review
description: Audit Cursor IDE rules (.mdc files) against quality standards using a 5-gate review process. Validates frontmatter (YAML syntax, required fields, description quality, triggering configuration), glob patterns (specificity, performance, correctness), content quality (focus, organization, examples, cross-references), file length (under 500 lines recommended), and functionality (triggering, cross-references, maintainability). Use when reviewing pull requests with Cursor rule changes, conducting periodic rule quality audits, validating new rules before committing, identifying improvement opportunities, preparing rules for team sharing, or debugging why rules aren't working as expected.
version: 1.0.0
---

# Cursor Rules Review

## Quick Start

**5-Gate Review Process:**

```
Rule File (.mdc)
    ↓
Gate 1: Frontmatter Review
    ↓ PASS
Gate 2: Glob Patterns Review
    ↓ PASS
Gate 3: Content Quality Review
    ↓ PASS
Gate 4: File Length Review
    ↓ PASS
Gate 5: Functionality Review
    ↓ PASS
✅ APPROVED
```

**Severity Levels:**

- **BLOCKER** - Must fix before merge (prevents rule from working)
- **CRITICAL** - Must fix before production (causes issues)
- **MAJOR** - Should fix (impacts quality significantly)
- **MINOR** - Nice to have (improvements)

---

## When to Load Additional References

The 5-gate review process below provides core checks. Load these references for detailed examples and checklists:

**For detailed examples of good and bad patterns:**

```
Read `~/.claude/skills/cursor-rules-review/references/EXAMPLES.md`
```

Use when: You need concrete examples of violations, want to see before/after comparisons, or need reference patterns

**For copy-paste review checklist:**

```
Read `~/.claude/skills/cursor-rules-review/references/CHECKLIST.md`
```

Use when: Performing systematic review, want a comprehensive checklist, or need to document findings

**For test scenarios and edge cases:**

```
Read `~/.claude/skills/cursor-rules-review/references/test-scenarios.md`
```

Use when: Testing rules, validating fixes, or handling complex edge cases

---

## Gate 1: Frontmatter Review

### 1.1 YAML Syntax Validation

**Check:**

- [ ] Frontmatter starts with `---`
- [ ] Frontmatter ends with `---`
- [ ] All strings properly quoted if needed
- [ ] Arrays use bracket syntax `[]`
- [ ] Boolean values are lowercase (`true`/`false`)

**Severity if missing:** BLOCKER (rule won't parse)

**Valid example:**

```yaml
---
description: Clear description here.
globs: ["**/*.ts"]
alwaysApply: false
---
```

---

### 1.2 Required Fields

**Check:**

- [ ] `description` field present
- [ ] Description is non-empty
- [ ] Description under 1024 characters

**Severity if missing:** BLOCKER (required field)

---

### 1.3 Description Quality

**Good description pattern:**

```yaml
description: React component patterns including props typing, hooks usage, and component structure. Apply when creating or modifying React components.
```

**Check:**

- [ ] Description is specific (not vague)
- [ ] Description uses third person (not "I" or "you")
- [ ] Description explains WHAT context is provided
- [ ] Description explains WHEN to apply the rule
- [ ] Description includes key terms/technologies

**Severity:**

- Vague/unclear: MAJOR
- Wrong person: MINOR
- Missing "when" context: MAJOR

---

### 1.4 Triggering Configuration

**Three triggering modes:**

1. **Always apply** (universal context):

   ```yaml
   alwaysApply: true
   ```

2. **File-based triggering** (most common):

   ```yaml
   globs: ["**/*.ts", "**/*.tsx"]
   alwaysApply: false
   ```

3. **Manual only** (no automatic trigger):
   ```yaml
   # No globs, no alwaysApply
   ```

**Check:**

- [ ] Has appropriate trigger for content type
- [ ] `alwaysApply: true` only for universal context
- [ ] File-based rules have `globs` array
- [ ] No redundant combination (both globs and alwaysApply)

**Severity:**

- Inappropriate `alwaysApply: true`: CRITICAL (context bloat)
- Missing globs for file-specific content: MAJOR

---

## Gate 2: Glob Patterns Review

### 2.1 Pattern Specificity

**Good patterns** (specific):

```yaml
globs: ["**/*.test.ts", "**/*.spec.ts"]  # Test files only
globs: ["**/src/components/**/*.tsx"]    # Component files only
globs: ["**/Chart.yaml"]                  # Helm charts only
```

**Bad patterns** (too broad):

```yaml
globs: ["**/*"]           # Matches everything (use alwaysApply instead)
globs: ["**/*.ts"]        # Too broad if rule is component-specific
```

**Check:**

- [ ] Patterns are as specific as needed
- [ ] Patterns match intended files only
- [ ] No overly broad patterns that bloat context

**Severity:**

- Overly broad patterns: CRITICAL (performance/context bloat)
- Insufficiently specific: MAJOR (incorrect triggering)

---

### 2.2 Pattern Performance

**Efficient patterns:**

```yaml
globs: ["**/src/**/*.ts"]      # Scoped to src/ directory
globs: ["**/*.test.ts"]         # Specific file extension
```

**Inefficient patterns:**

```yaml
globs: ["**/*.ts", "**/*.js", "**/*.tsx", "**/*.jsx", "**/*.mjs", ...]
# Too many patterns - consider simplification
```

**Check:**

- [ ] Patterns are efficient (not excessive)
- [ ] Use `**` sparingly (matches any depth)
- [ ] Combine similar patterns where possible

**Severity:**

- Excessive pattern count (>10): MAJOR
- Inefficient wildcards: MINOR

---

### 2.3 Pattern Correctness

**Test patterns:**

```bash
# Test if pattern matches intended files
find . -path "**/Chart.yaml"
find . -path "**/*.test.ts"
```

**Check:**

- [ ] Patterns use correct glob syntax
- [ ] Patterns match intended files
- [ ] Patterns exclude unintended files
- [ ] Test patterns with `find` command

**Severity:**

- Pattern doesn't match: BLOCKER (rule won't trigger)
- Pattern syntax error: BLOCKER

---

## Gate 3: Content Quality Review

### 3.1 Single Responsibility

**Check:**

- [ ] Rule focuses on single concern/domain
- [ ] No mixing of unrelated topics (e.g., API + UI in one rule)
- [ ] Split multi-topic rules into separate files

**Severity:**

- Multiple unrelated topics: MAJOR

---

### 3.2 Content Organization

**Recommended structure:**

```markdown
# Title matching description

## Core Patterns

[Main content]

## Common Issues

[Troubleshooting]

## Examples

[Code examples]

## Related Rules

[@cross-references]
```

**Check:**

- [ ] Content has clear structure
- [ ] Sections have descriptive headings
- [ ] Information flows logically
- [ ] No redundancy or repetition

**Severity:**

- Poor organization: MAJOR
- Missing structure: MINOR

---

### 3.3 Example Quality

**Good examples:**

- Show both good (✅) and bad (❌) patterns
- Include brief explanations
- Use realistic code snippets
- Highlight key differences

**Check:**

- [ ] Examples demonstrate key concepts
- [ ] Examples show good and bad patterns
- [ ] Examples are realistic (not trivial)
- [ ] Examples are concise (not walls of code)

**Severity:**

- Missing examples: MAJOR
- Poor example quality: MINOR

---

### 3.4 Cross-References

**Good cross-references:**

```markdown
For React component structure, see @react-component-patterns
For TypeScript types, see @typescript-types
```

**Check:**

- [ ] Cross-references use `@` syntax
- [ ] Referenced rules exist
- [ ] Cross-references are relevant
- [ ] No circular references

**Severity:**

- Broken cross-references: CRITICAL
- Missing beneficial cross-references: MINOR

---

## Gate 4: File Length Review

### Recommended Limits

- **Optimal:** <300 lines
- **Good:** 300-500 lines
- **Acceptable:** 500-750 lines
- **Needs splitting:** >750 lines

**Check:**

- [ ] File length is appropriate for content
- [ ] Consider splitting if >500 lines
- [ ] Split if multiple distinct topics

**Severity:**

- > 1000 lines: MAJOR (must split)
- > 750 lines: MINOR (should split)

**Action:**
Split large rules into:

- Base rule (core patterns)
- Advanced rule (edge cases, advanced patterns)
- Examples rule (detailed code examples)

---

## Gate 5: Functionality Review

### 5.1 Triggering Test

**Test triggering:**

```bash
# Create test file
touch test.ts

# Open in Cursor
cursor test.ts

# Check if rule appears in context
# Rule should trigger if globs match "**/*.ts"
```

**Check:**

- [ ] Rule triggers when expected
- [ ] Rule doesn't trigger when not expected
- [ ] Glob patterns work correctly
- [ ] `alwaysApply` rules always load

**Severity:**

- Rule doesn't trigger: BLOCKER
- Rule triggers incorrectly: CRITICAL

---

### 5.2 Cross-Reference Validation

**Validate cross-references:**

```bash
# Check referenced files exist
grep "@" .cursor/rules/my-rule.mdc
ls .cursor/rules/referenced-rule.mdc
```

**Check:**

- [ ] All cross-referenced rules exist
- [ ] Cross-references use correct syntax
- [ ] No circular dependencies

**Severity:**

- Broken cross-references: CRITICAL
- Circular references: MAJOR

---

### 5.3 Maintainability Review

**Check:**

- [ ] Rule is easy to understand
- [ ] Rule follows naming conventions
- [ ] Rule has clear ownership (if team-shared)
- [ ] Rule documented in README/index (if part of collection)

**Severity:**

- Poor maintainability: MINOR
- Unclear ownership: MINOR

---

## Review Output Format

### Comprehensive Report Structure

```markdown
# Cursor Rule Review: [rule-name.mdc]

**Status:** ❌ FAILED (2 BLOCKER, 3 MAJOR, 1 MINOR)
**Date:** 2024-01-16
**Reviewer:** Claude/Pedro

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

---

## Best Practices

### 1. Start with Frontmatter

Always validate frontmatter first - if it's broken, nothing else matters.

### 2. Test Triggering Early

Create test files and verify the rule triggers as expected.

### 3. Use Consistent Severity

Apply severity levels consistently across reviews.

### 4. Provide Actionable Fixes

Every issue should have a clear fix recommendation.

### 5. Re-Review After Fixes

Always run review again after fixes to confirm resolution.

---

## Common Issues & Solutions

### Issue: Rule Not Triggering

**Symptoms:**

- Rule should trigger but doesn't appear
- Glob patterns look correct

**Debug:**

```bash
# Test glob pattern
find . -path "**/*.test.ts"

# Check frontmatter syntax
head -n 10 .cursor/rules/rule-name.mdc

# Verify Cursor settings
cat .cursor/settings.json
```

**Solutions:**

- Fix glob pattern syntax
- Ensure frontmatter is valid YAML
- Check file is in `.cursor/rules/` directory
- Restart Cursor IDE

---

### Issue: Context Bloat

**Symptoms:**

- Too much context loaded
- Slow Cursor performance
- Responses include irrelevant information

**Debug:**

```bash
# Check for overly broad patterns
grep "globs:" .cursor/rules/*.mdc | grep "\*\*/\*"

# Check for too many alwaysApply rules
grep "alwaysApply: true" .cursor/rules/*.mdc
```

**Solutions:**

- Make glob patterns more specific
- Use `alwaysApply: true` sparingly
- Split large rules into smaller, focused rules
- Consider file-based triggering over alwaysApply

---

### Issue: Broken Cross-References

**Symptoms:**

- `@referenced-rule` doesn't load
- Error in Cursor logs

**Debug:**

```bash
# Find all cross-references
grep "@" .cursor/rules/my-rule.mdc

# Check if referenced files exist
ls .cursor/rules/referenced-rule.mdc
```

**Solutions:**

- Fix filename (case-sensitive)
- Ensure referenced rule exists
- Use correct `@filename` syntax (without `.mdc`)

---

## Quick Validation Commands

```bash
# Check frontmatter
head -n 10 .cursor/rules/rule-name.mdc

# Check file length
wc -l .cursor/rules/rule-name.mdc

# Test glob patterns
find . -path "**/Chart.yaml"

# Verify cross-references
grep "@" .cursor/rules/rule-name.mdc
ls .cursor/rules/referenced-rule.mdc

# For complete checklist, read references/CHECKLIST.md
```

---

## Related Skills

- **cursor-rules-writing**: Create new Cursor rules following best practices
- **skill-review**: Review Claude Code skills (different from Cursor rules)

---

**This skill should be reviewed quarterly for updates to align with latest Cursor IDE features.**
