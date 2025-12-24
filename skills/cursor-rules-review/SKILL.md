---
name: cursor-rules-review
description: Audit Cursor IDE rules against quality standards using a 5-gate review process. Validates frontmatter, glob patterns, content quality, file length, and functionality. Use when reviewing .mdc rule files or conducting quality audits.
version: 1.0.0
---

# Cursor Rules Review

## Purpose
Audit Cursor IDE rules (.mdc files) against quality criteria to ensure optimal performance, maintainability, and effectiveness.

## When to Use This Skill
- Reviewing pull requests with Cursor rule changes
- Conducting periodic rule quality audits
- Validating new rules before committing
- Identifying improvement opportunities in existing rules
- Preparing rules for team sharing
- Debugging why rules aren't working as expected

## When NOT to Use This Skill
- Creating new rules (use cursor-rules-writing skill instead)
- General code review (not for .mdc files)
- Reviewing Claude Code skills (use skill-review skill instead)
- Cursor IDE settings configuration (not rules)

## Review Process Overview

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

## Quick Start

### Step 1: Identify Rule to Review
```bash
# List all rules
ls -la .cursor/rules/*.mdc

# Check rule to review
cat .cursor/rules/my-rule.mdc
```

### Step 2: Run 5-Gate Review
Work through each gate systematically (see detailed gates below).

### Step 3: Document Findings
Use severity levels to categorize issues:
- BLOCKER: Must fix immediately
- CRITICAL: Fix before production
- MAJOR: Should fix soon
- MINOR: Improve when possible

### Step 4: Provide Actionable Recommendations
For each issue, provide:
- What's wrong
- Why it matters
- How to fix it
- Example of correct pattern

### Step 5: Verify Fixes
After changes, re-run review to confirm resolution.

---

## Gate 1: Frontmatter Review

### What to Check

#### 1.1 YAML Syntax Validation
```yaml
# ✅ Valid YAML
---
description: Clear description here.
globs: ["**/*.ts"]
alwaysApply: false
---

# ❌ Invalid YAML - missing closing ---
---
description: Invalid description.
globs: ["**/*.ts"]

# ❌ Invalid YAML - unclosed quote
---
description: "Missing closing quote
globs: ["**/*.ts"]
---
```

**Check:**
- [ ] Frontmatter starts with `---`
- [ ] Frontmatter ends with `---`
- [ ] All strings properly quoted if needed
- [ ] Arrays use bracket syntax `[]`
- [ ] Boolean values are lowercase (`true`/`false`)

**Severity if missing:** BLOCKER (rule won't parse)

#### 1.2 Required Fields
```yaml
---
description: Required field explaining what this rule provides.
# Optional: globs or alwaysApply
---
```

**Check:**
- [ ] `description` field present
- [ ] Description is non-empty
- [ ] Description under 1024 characters (practical limit)

**Severity if missing:** BLOCKER (required field)

#### 1.3 Description Quality
```yaml
# ❌ Bad - Vague, no context
description: Helps with files.

# ❌ Bad - First person
description: I provide patterns for API design.

# ❌ Bad - Second person
description: You can use this for components.

# ✅ Good - Specific, third person, includes "when"
description: React component patterns including props typing, hooks usage, and component structure. Apply when creating or modifying React components.
```

**Check:**
- [ ] Description is specific (not vague)
- [ ] Description uses third person (not "I" or "you")
- [ ] Description explains WHAT context is provided
- [ ] Description explains WHEN to apply the rule
- [ ] Description includes key terms/technologies
- [ ] Description is actionable

**Severity:**
- Vague/unclear: MAJOR
- Wrong person: MINOR
- Missing "when" context: MAJOR

#### 1.4 Triggering Configuration
```yaml
# Option 1: Always apply
---
description: Universal project conventions.
alwaysApply: true
---

# Option 2: File-based triggering
---
description: TypeScript patterns.
globs: ["**/*.ts", "**/*.tsx"]
alwaysApply: false
---

# Option 3: Manual only
---
description: Advanced debugging guide.
# No globs, no alwaysApply
---
```

**Check:**
- [ ] Has appropriate trigger (always vs file-based vs manual)
- [ ] `alwaysApply: true` only for universal context
- [ ] File-based rules have `globs` array
- [ ] Manual rules have neither (or `alwaysApply: false`)

**Severity:**
- Inappropriate `alwaysApply: true`: CRITICAL (context bloat)
- Missing globs for file-specific content: MAJOR
- Both globs and alwaysApply true: MAJOR (redundant)

#### 1.5 Field Validation
```yaml
# ✅ Valid field types
description: "String value"
globs: ["array", "of", "strings"]
alwaysApply: false  # Boolean

# ❌ Invalid field types
globs: "**/*.ts"    # Should be array
alwaysApply: "false" # Should be boolean, not string
```

**Check:**
- [ ] `description` is string
- [ ] `globs` is array (if present)
- [ ] `alwaysApply` is boolean (if present)
- [ ] No extra/unknown fields

**Severity if wrong type:** BLOCKER (parsing error)

### Gate 1 Checklist
```
Frontmatter Review:
[ ] Valid YAML syntax
[ ] description field present and non-empty
[ ] Description is specific and includes "when to use"
[ ] Description uses third person
[ ] Appropriate triggering (always/file-based/manual)
[ ] alwaysApply only used for universal context
[ ] globs array for file-based rules
[ ] Correct field types
[ ] No unknown fields
```

---

## Gate 2: Glob Patterns Review

### What to Check

#### 2.1 Pattern Syntax Validation
```yaml
# ✅ Valid patterns
globs: [
  "**/*.ts",           # Recursive all .ts files
  "**/components/**/*", # Specific directory recursive
  "**/*.{ts,tsx}",     # Multiple extensions
  "**/{Chart,values}.yaml" # Multiple filenames
]

# ❌ Invalid patterns
globs: [
  "*.ts",              # Not recursive (misses nested)
  "components/*.tsx",  # Only matches root components/
  "**/*.ts"            # Missing comma or not in array
]
```

**Check:**
- [ ] Patterns use `**/` for recursive matching
- [ ] Patterns target specific file types
- [ ] Multiple extensions use `{ext1,ext2}` syntax
- [ ] Patterns are in array format
- [ ] No bare patterns (all should match expected files)

**Severity:**
- Missing `**/`: MAJOR (won't match nested files)
- Too broad (`**/*`): CRITICAL (matches everything)
- Invalid syntax: BLOCKER (won't work)

#### 2.2 Pattern Specificity
```yaml
# ❌ Too broad - matches all files
globs: ["**/*"]

# ❌ Still too broad - matches all YAML
globs: ["**/*.yaml"]

# ✅ Specific - targets Helm charts
globs: ["**/Chart.yaml", "**/values*.yaml", "**/templates/**/*.yaml"]
```

**Check:**
- [ ] Patterns are appropriately specific
- [ ] Not matching unrelated file types
- [ ] Not causing context pollution
- [ ] Targets actual files in project

**Severity:**
- Matches all files: CRITICAL
- Overly broad: MAJOR
- Could be more specific: MINOR

#### 2.3 Pattern Coverage
```yaml
# ❌ Too narrow - misses common cases
globs: ["components/*.tsx"]  # Only root components/

# ✅ Appropriate coverage
globs: [
  "**/*.tsx",              # All React components
  "**/components/**/*.ts", # Component utilities
  "**/hooks/**/*.ts"       # Custom hooks
]
```

**Check:**
- [ ] Patterns cover all relevant files
- [ ] Doesn't miss nested directories
- [ ] Covers related file types (e.g., .ts and .tsx)
- [ ] No gaps in coverage

**Severity:**
- Missing major file types: MAJOR
- Missing nested directories: MAJOR

#### 2.4 Negation Patterns (if used)
```yaml
# ✅ Correct - exclusion after inclusion
globs: [
  "**/*.ts",
  "!**/*.test.ts",      # Exclude tests
  "!**/node_modules/**" # Exclude dependencies
]

# ❌ Wrong order - tests will still match
globs: [
  "!**/*.test.ts",
  "**/*.ts"
]
```

**Check:**
- [ ] Negations come after inclusions
- [ ] Negation syntax correct (starts with `!`)
- [ ] Negations are necessary (not redundant)

**Severity:**
- Wrong order: MAJOR (won't work as intended)
- Invalid syntax: BLOCKER

#### 2.5 Pattern Testing
```bash
# Test patterns match expected files
find . -path "**/Chart.yaml"
fd --glob "**/*.ts"
ls **/*.tsx  # (requires globstar in bash)
```

**Check:**
- [ ] Patterns actually match files in project
- [ ] Can verify with `find` or `fd` commands
- [ ] No false positives
- [ ] No false negatives

**Severity:**
- Doesn't match any files: BLOCKER
- Matches wrong files: CRITICAL

### Gate 2 Checklist
```
Glob Patterns Review:
[ ] Valid glob syntax
[ ] Patterns use **/ for recursive matching
[ ] Patterns are appropriately specific
[ ] Coverage is adequate (no gaps)
[ ] Negations (if any) are correct
[ ] Patterns tested and verified
[ ] No overly broad patterns
[ ] Targets actual project files
```

---

## Gate 3: Content Quality Review

### What to Check

#### 3.1 Overview Section
```markdown
# ✅ Good overview
## Overview
This rule provides React component patterns including props typing and hooks usage.

**Related rules:** See @typescript-patterns.mdc for general TypeScript, @testing.mdc for test patterns.

---

# ❌ Missing overview
[Content starts directly without overview]
```

**Check:**
- [ ] Has Overview section
- [ ] Overview explains rule purpose (1-2 sentences)
- [ ] Includes cross-references to related rules
- [ ] Uses `---` separator after overview

**Severity:**
- Missing overview: MAJOR
- No cross-references: MINOR (if related rules exist)

#### 3.2 Content Organization
```markdown
# ✅ Good structure
## Overview
...

**Related rules:** ...

---

## Section 1
...

---

## Section 2
...

---

## Resources
...
```

**Check:**
- [ ] Logical section organization
- [ ] Sections separated with `---`
- [ ] Clear section headings
- [ ] Progressive flow (general to specific)
- [ ] Resources section at bottom

**Severity:**
- Poor organization: MAJOR
- Missing section separators: MINOR

#### 3.3 Examples Quality
```markdown
# ❌ Bad - Abstract advice
Make sure to handle errors properly.

# ✅ Good - Concrete code example
\`\`\`typescript
// ✅ Good - Complete error handling
try {
  const result = await api.call();
  return result;
} catch (error) {
  logger.error('API call failed', { error });
  throw new ApiError('Failed to fetch data', error);
}

// ❌ Bad - No error handling
const result = await api.call();
return result;
\`\`\`
```

**Check:**
- [ ] Contains concrete code examples (not just text)
- [ ] Examples are project-specific (not generic)
- [ ] Shows good AND bad patterns (✅/❌)
- [ ] Examples are runnable/realistic
- [ ] At least 2-3 substantial examples
- [ ] Examples demonstrate key concepts

**Severity:**
- No examples: CRITICAL
- Only abstract advice: MAJOR
- Generic examples: MINOR

#### 3.4 Good vs Bad Patterns
```markdown
# ✅ Includes both
\`\`\`typescript
// ✅ Good - Type-safe approach
interface Props { name: string; }
function Component({ name }: Props) { }

// ❌ Bad - Untyped props
function Component({ name }) { }
\`\`\`
```

**Check:**
- [ ] Uses ✅ for good patterns
- [ ] Uses ❌ for bad patterns
- [ ] Shows both (not just one)
- [ ] Explains why each is good/bad

**Severity:**
- Only shows good OR bad (not both): MAJOR
- No visual indicators (✅/❌): MINOR

#### 3.5 Cross-References
```markdown
# ✅ Good cross-references
**Related rules:** See @api-patterns.mdc for API design, @error-handling.mdc for error patterns.

For deployment procedures, see @deployment-guide.mdc.

# ❌ Missing cross-references
[No references to related rules despite clear relationships]
```

**Check:**
- [ ] References related rules with `@filename.mdc`
- [ ] Cross-references are relevant
- [ ] Referenced rules actually exist
- [ ] Uses descriptive text ("See @X for Y")

**Severity:**
- Missing obvious cross-references: MAJOR
- Broken references (file doesn't exist): CRITICAL
- No descriptive text: MINOR

#### 3.6 Actionable Guidance
```markdown
# ❌ Vague
Be careful with memory management.

# ✅ Actionable
## Memory Management

Always remove event listeners to prevent leaks:

\`\`\`javascript
// Setup
emitter.on('event', handler);

// Cleanup
emitter.off('event', handler);
\`\`\`

Check listener count in development:
\`\`\`javascript
console.log(emitter.listenerCount('event'));
\`\`\`
```

**Check:**
- [ ] Guidance is specific and actionable
- [ ] Includes "how to" not just "what to"
- [ ] Provides concrete steps
- [ ] Avoids vague phrases ("make sure", "be careful")

**Severity:**
- Mostly vague guidance: MAJOR
- Mix of vague and concrete: MINOR

### Gate 3 Checklist
```
Content Quality Review:
[ ] Has Overview section with cross-references
[ ] Logical section organization
[ ] Sections separated with ---
[ ] Contains concrete code examples
[ ] Shows good vs bad patterns (✅/❌)
[ ] Cross-references related rules
[ ] References are valid (files exist)
[ ] Guidance is actionable (not vague)
[ ] Examples are project-specific
[ ] At least 2-3 substantial examples
```

---

## Gate 4: File Length Review

### What to Check

#### 4.1 Line Count
```bash
# Check line count
wc -l .cursor/rules/my-rule.mdc

# Target: Under 500 lines
# Acceptable: 500-700 with justification
# Problem: Over 700 requires splitting
```

**Check:**
- [ ] Under 500 lines (ideal)
- [ ] 500-700 lines with justification
- [ ] If over 700, must split into multiple rules

**Severity:**
- Under 500: ✅ PASS
- 500-700 with justification: ✅ PASS (MINOR note)
- 500-700 without justification: MAJOR
- Over 700: CRITICAL (must split)

#### 4.2 Justification (if over 500)
```markdown
# Acceptable reasons for 500-700 lines:
- Comprehensive reference material (troubleshooting guide)
- Multiple complex examples required
- Cannot split without losing coherence
- Already extracted content to separate files

# NOT acceptable:
- "Didn't have time to split"
- Could easily separate into focused rules
- Mixed unrelated concerns
```

**Check:**
- [ ] If over 500 lines, justification documented
- [ ] Justification is valid
- [ ] Alternative splitting considered

**Severity:**
- Over 500 without justification: MAJOR
- Over 700 even with justification: CRITICAL

#### 4.3 Splitting Opportunities
```markdown
# Rule with 800 lines covering:
- Topic A (300 lines)
- Topic B (250 lines)
- Topic C (250 lines)

# Should split into:
1. core-overview.mdc (200 lines, always-apply)
2. topic-a.mdc (400 lines, file-based)
3. topic-b.mdc (350 lines, file-based)
4. topic-c.mdc (350 lines, manual)
```

**Check:**
- [ ] Identified distinct topics/concerns
- [ ] Each topic could be separate rule
- [ ] Splitting would improve maintainability
- [ ] Cross-references would connect them

**Severity:**
- Clear splitting opportunity missed: MAJOR
- Could potentially split: MINOR

#### 4.4 Content Density
```markdown
# ❌ Low density - lots of whitespace, repetition
[100 lines of repeated patterns]

# ✅ Good density - concise, no duplication
[Well-organized, each line adds value]
```

**Check:**
- [ ] Content is dense (not wasteful)
- [ ] No repetitive patterns
- [ ] No excessive whitespace
- [ ] Each section adds value

**Severity:**
- Lots of waste that could be removed: MAJOR

### Gate 4 Checklist
```
File Length Review:
[ ] Line count checked (wc -l)
[ ] Under 500 lines OR justified
[ ] If over 700, splitting is required
[ ] No clear splitting opportunities missed
[ ] Content is appropriately dense
[ ] No repetitive patterns
```

---

## Gate 5: Functionality Review

### What to Check

#### 5.1 Rule Loading Test
```bash
# Test always-apply rule
# 1. Start Cursor
# 2. Open any file
# 3. Start chat
# 4. Verify rule context is present

# Test file-based rule
# 1. Open file matching glob pattern
# 2. Start chat
# 3. Verify rule loads
# 4. Open non-matching file
# 5. Verify rule doesn't load

# Test manual rule
# 1. Start chat
# 2. Type @rule-name.mdc
# 3. Verify rule loads
```

**Check:**
- [ ] Always-apply rules load in every chat
- [ ] File-based rules load for matching files
- [ ] File-based rules don't load for non-matching files
- [ ] Manual rules load when @-mentioned
- [ ] No error messages in Cursor

**Severity:**
- Rule doesn't load at all: BLOCKER
- Loads when shouldn't: CRITICAL
- Doesn't load when should: CRITICAL

#### 5.2 Glob Pattern Verification
```bash
# Verify patterns match expected files
cd project-root

# Test pattern with find
find . -path "**/Chart.yaml"

# Test with fd
fd --glob "**/*.tsx"

# Verify matches project structure
```

**Check:**
- [ ] Glob patterns match actual project files
- [ ] Patterns tested with find/fd
- [ ] No unexpected matches
- [ ] No missed files

**Severity:**
- Patterns don't match anything: BLOCKER
- Pattern mismatches project structure: CRITICAL

#### 5.3 Cross-Reference Validation
```bash
# Check all @-mentions
grep -o "@[a-z-]*.mdc" .cursor/rules/my-rule.mdc

# Verify each referenced file exists
ls .cursor/rules/referenced-rule.mdc
```

**Check:**
- [ ] All `@filename.mdc` references verified
- [ ] Referenced files exist in `.cursor/rules/`
- [ ] No broken links
- [ ] @-mentions work in Cursor chat

**Severity:**
- Broken reference (file doesn't exist): CRITICAL
- Reference typo: MAJOR

#### 5.4 Context Quality Test
```markdown
# Test in actual Cursor chat:

Prompt: "Create an API endpoint for user registration"

Expected result:
- If API rule is present, context should be relevant
- Examples should be helpful
- Patterns should be followed

Not expected:
- Generic advice Cursor already knows
- Irrelevant context
- Contradictory guidance
```

**Check:**
- [ ] Rule provides relevant context
- [ ] Context is actually helpful
- [ ] No conflicts with other rules
- [ ] Improves Cursor's responses

**Severity:**
- Provides irrelevant context: MAJOR
- Conflicts with other rules: CRITICAL
- No measurable improvement: MAJOR

#### 5.5 Performance Impact
```markdown
# Check context size:
- Always-apply rules should be short (<300 lines)
- Total always-apply context should be reasonable
- File-based rules should target specific files
- No unnecessary loading
```

**Check:**
- [ ] Always-apply rules are concise
- [ ] Total context load is reasonable
- [ ] No performance degradation
- [ ] File-based targeting works correctly

**Severity:**
- Large always-apply rule: CRITICAL
- Excessive total context: MAJOR
- Performance issues: CRITICAL

### Gate 5 Checklist
```
Functionality Review:
[ ] Rule loads correctly (always/file-based/manual)
[ ] Glob patterns match expected files
[ ] Cross-references validated (files exist)
[ ] Context is relevant and helpful
[ ] No conflicts with other rules
[ ] Performance impact acceptable
[ ] Tested in actual Cursor chat
```

---

## Review Report Template

```markdown
# Cursor Rule Review: [rule-name.mdc]

**Reviewed by:** [Your Name]
**Date:** [Date]
**Overall Status:** [APPROVED / NEEDS WORK / BLOCKED]

---

## Summary

[1-2 sentence overview of review]

---

## Gate 1: Frontmatter Review

**Status:** [✅ PASS / ⚠️ ISSUES]

Issues found:
- [ ] BLOCKER: [Description]
- [ ] CRITICAL: [Description]
- [ ] MAJOR: [Description]
- [ ] MINOR: [Description]

---

## Gate 2: Glob Patterns Review

**Status:** [✅ PASS / ⚠️ ISSUES]

Issues found:
- [ ] BLOCKER: [Description]
- [ ] CRITICAL: [Description]
- [ ] MAJOR: [Description]
- [ ] MINOR: [Description]

---

## Gate 3: Content Quality Review

**Status:** [✅ PASS / ⚠️ ISSUES]

Issues found:
- [ ] BLOCKER: [Description]
- [ ] CRITICAL: [Description]
- [ ] MAJOR: [Description]
- [ ] MINOR: [Description]

---

## Gate 4: File Length Review

**Status:** [✅ PASS / ⚠️ ISSUES]

**Line count:** [X lines]
**Target:** Under 500 lines

Issues found:
- [ ] BLOCKER: [Description]
- [ ] CRITICAL: [Description]
- [ ] MAJOR: [Description]
- [ ] MINOR: [Description]

---

## Gate 5: Functionality Review

**Status:** [✅ PASS / ⚠️ ISSUES]

Issues found:
- [ ] BLOCKER: [Description]
- [ ] CRITICAL: [Description]
- [ ] MAJOR: [Description]
- [ ] MINOR: [Description]

---

## Recommendations

### Must Fix (BLOCKER/CRITICAL)
1. [Recommendation with example]
2. [Recommendation with example]

### Should Fix (MAJOR)
1. [Recommendation]
2. [Recommendation]

### Nice to Have (MINOR)
1. [Suggestion]
2. [Suggestion]

---

## Overall Assessment

[Detailed assessment paragraph]

**Approve?** [YES / NO / CONDITIONAL]

**Conditions (if any):**
- [Condition for approval]

---

**Review complete.**
```

---

## Quality Checklist

Use this comprehensive checklist for reviews:

```
Rule Review Checklist:

Frontmatter:
[ ] Valid YAML syntax
[ ] description present and specific
[ ] Description uses third person
[ ] Appropriate trigger (always/file/manual)
[ ] Correct field types

Glob Patterns:
[ ] Valid glob syntax
[ ] Patterns use **/ recursively
[ ] Appropriately specific
[ ] Tested and verified

Content:
[ ] Has Overview with cross-references
[ ] Logical organization
[ ] Concrete code examples
[ ] Good vs bad patterns (✅/❌)
[ ] Cross-references validated
[ ] Actionable guidance

File Length:
[ ] Under 500 lines OR justified
[ ] No clear splitting opportunities missed
[ ] Appropriate content density

Functionality:
[ ] Rule loads correctly
[ ] Globs match expected files
[ ] Cross-references work
[ ] Context is helpful
[ ] No performance issues

Overall:
[ ] No BLOCKER issues
[ ] No CRITICAL issues
[ ] MAJOR issues acceptable or addressed
[ ] Ready for approval
```

---

## Common Review Findings

### Finding 1: Missing Frontmatter Description
```yaml
# ❌ Problem
---
globs: ["**/*.ts"]
---

# ✅ Solution
---
description: TypeScript patterns for type safety and best practices. Apply when working with TypeScript code.
globs: ["**/*.ts"]
---
```

**Severity:** BLOCKER

### Finding 2: Overly Broad Glob Patterns
```yaml
# ❌ Problem - matches everything
globs: ["**/*"]

# ✅ Solution - specific targeting
globs: ["**/*.tsx", "**/components/**/*.ts"]
```

**Severity:** CRITICAL

### Finding 3: No Code Examples
```markdown
# ❌ Problem - abstract advice only
Make sure to use TypeScript types properly.

# ✅ Solution - concrete example
\`\`\`typescript
// ✅ Good - explicit typing
interface User { id: string; name: string; }
function getUser(id: string): User { }

// ❌ Bad - implicit any
function getUser(id) { }
\`\`\`
```

**Severity:** CRITICAL

### Finding 4: File Too Long Without Justification
```bash
# Problem
wc -l .cursor/rules/my-rule.mdc
# Output: 850 lines

# Solution: Split into focused rules
my-rule-core.mdc (200 lines)
my-rule-patterns.mdc (400 lines)
my-rule-advanced.mdc (350 lines)
```

**Severity:** CRITICAL (over 700 lines)

### Finding 5: Broken Cross-References
```markdown
# ❌ Problem
See @nonexistent-rule.mdc for details.

# ✅ Solution
# Verify file exists:
ls .cursor/rules/api-patterns.mdc

# Then reference:
See @api-patterns.mdc for API design patterns.
```

**Severity:** CRITICAL

---

## Resources

- cursor-rules-writing skill (for creating rules)
- [Cursor Documentation](https://cursor.com/docs/context/rules)
- [YAML Specification](https://yaml.org/spec/)
- CHECKLIST.md (copy-paste review checklist)
- EXAMPLES.md (sample review reports)

---

## Quick Reference

```bash
# Start review
cat .cursor/rules/rule-name.mdc

# Check frontmatter
head -n 10 .cursor/rules/rule-name.mdc

# Check file length
wc -l .cursor/rules/rule-name.mdc

# Test glob patterns
find . -path "**/Chart.yaml"

# Verify cross-references
grep "@" .cursor/rules/rule-name.mdc
ls .cursor/rules/referenced-rule.mdc

# Complete checklist
# See CHECKLIST.md for copy-paste version
```

---

**This skill follows cursor-rules-writing and skill-review best practices and should be reviewed quarterly for updates.**
