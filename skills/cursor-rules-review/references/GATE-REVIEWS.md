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

