# Cursor Rules Review - Test Scenarios

This file provides validation scenarios for testing the cursor-rules-review skill.

---

## Scenario 1: Review Well-Written Rule (APPROVED)

**Objective:** Validate that the review skill correctly identifies a high-quality Cursor rule and approves it.

### Setup

Create a sample rule file: **react-components.mdc**

```markdown
---
description: React component patterns including props typing with TypeScript, hooks usage, and component structure. Apply when creating or modifying React components.
globs: ["**/*.tsx", "**/components/**/*.ts", "**/hooks/**/*.ts"]
alwaysApply: false
---

# React Component Patterns

## Overview

This rule provides React component best practices for the project. It covers props typing, hooks usage, and component structure patterns.

**Related rules:** See @typescript-patterns.mdc for general TypeScript patterns and @testing-patterns.mdc for testing React components.

---

## Props Typing

Always use explicit interfaces for props:

```typescript
// ✅ Good - Explicit props interface
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

export function Button({ label, onClick, variant = 'primary', disabled = false }: ButtonProps) {
  return (
    <button
      onClick={onClick}
      className={`btn btn-${variant}`}
      disabled={disabled}
    >
      {label}
    </button>
  );
}

// ❌ Bad - No props interface
export function Button({ label, onClick, variant, disabled }: any) {
  return <button onClick={onClick}>{label}</button>;
}
```

---

## Hooks Usage

Use custom hooks for shared logic:

```typescript
// ✅ Good - Custom hook for auth
function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    authService.getCurrentUser()
      .then(setUser)
      .finally(() => setLoading(false));
  }, []);

  return { user, loading };
}

// Usage in component
function Dashboard() {
  const { user, loading } = useAuth();

  if (loading) return <Spinner />;
  if (!user) return <Login />;

  return <DashboardContent user={user} />;
}
```

---

## Component Structure

Follow consistent component organization:

```typescript
// ✅ Good - Well-organized component
import { useState, useEffect } from 'react';
import { UserService } from '@/services';
import type { User } from '@/types';

interface UserProfileProps {
  userId: string;
}

export function UserProfile({ userId }: UserProfileProps) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    UserService.getUser(userId)
      .then(setUser)
      .finally(() => setLoading(false));
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  if (!user) return <div>User not found</div>;

  return (
    <div className="user-profile">
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}
```

---

## Resources

- Project TypeScript style guide
- React component testing guide
```

### Expected Behavior

#### Gate 1: Frontmatter Review ✓
- [ ] Valid YAML syntax (starts/ends with ---)
- [ ] Description field present and non-empty
- [ ] Description is specific ("props typing with TypeScript, hooks usage, component structure")
- [ ] Description uses third person
- [ ] Description includes "when to use" ("Apply when creating or modifying")
- [ ] File-based triggering (`alwaysApply: false`)
- [ ] Globs array present with appropriate patterns
- [ ] Globs use recursive patterns (`**/`)

**Result:** ✅ PASS - No issues

#### Gate 2: Glob Patterns Review ✓
- [ ] Patterns use `**/` for recursion
- [ ] Target specific file types (`.tsx`, `.ts`)
- [ ] Appropriately specific (components, hooks)
- [ ] Not overly broad (not matching all files)
- [ ] Adequate coverage (components + hooks)

**Result:** ✅ PASS - No issues

#### Gate 3: Content Quality Review ✓
- [ ] Has Overview section
- [ ] Cross-references present (`@typescript-patterns.mdc`, `@testing-patterns.mdc`)
- [ ] Logical organization (Props → Hooks → Structure)
- [ ] Sections separated with `---`
- [ ] Concrete code examples (TypeScript/React code)
- [ ] Good vs bad patterns (✅/❌)
- [ ] Actionable guidance (specific patterns)
- [ ] Resources section at bottom

**Result:** ✅ PASS - No issues

#### Gate 4: File Length Review ✓
- [ ] Line count: 106 lines
- [ ] Under 500 lines (✓)
- [ ] Appropriate content density
- [ ] No clear splitting opportunities

**Result:** ✅ PASS - No issues

#### Gate 5: Functionality Review ✓
- [ ] Rule would load for `.tsx` files
- [ ] Rule would load for files in `components/` directory
- [ ] Rule would load for files in `hooks/` directory
- [ ] Cross-references are valid (assuming files exist)
- [ ] Context is relevant for React development
- [ ] No conflicts expected

**Result:** ✅ PASS - No issues

### Review Report

```markdown
# Rule Review: react-components.mdc
**Reviewer:** Claude (cursor-rules-review skill)
**Date:** 2025-11-21

## Issues Found
**BLOCKER:** 0
**CRITICAL:** 0
**MAJOR:** 0
**MINOR:** 0

## Status
- [x] ✅ APPROVED

**Summary:** This rule follows all best practices. Frontmatter is well-structured with specific description and appropriate glob patterns. Content is well-organized with concrete examples showing both good and bad patterns. File length is optimal at 106 lines. The rule would load correctly for TypeScript React files and provide valuable context.

**Recommendation:** Approve for production use.
```

### Success Criteria

**Must have:**
- ✅ All 5 gates PASS
- ✅ Zero issues found
- ✅ Review report indicates APPROVED
- ✅ No false positives (incorrect issues flagged)
- ✅ Recognizes quality patterns correctly

---

## Scenario 2: Review Problematic Rule (BLOCKED)

**Objective:** Validate that the review skill correctly identifies multiple issues and assigns appropriate severity levels.

### Setup

Create a sample rule file: **api-stuff.mdc**

```markdown
---
description: API stuff
globs: ["**/*"]
alwaysApply: true
---

Some API patterns.

## Endpoints

You should create good endpoints.

## Authentication

Make sure to use authentication.

## Error Handling

Handle errors properly.

## Testing

Test your APIs.
```

### Expected Behavior

#### Gate 1: Frontmatter Review ⚠️
**Issues found:**
- ❌ **CRITICAL:** Description is vague ("API stuff")
- ❌ **MAJOR:** Description missing "when to use" context
- ❌ **MAJOR:** Description doesn't use third person
- ❌ **CRITICAL:** `alwaysApply: true` for specific context (should be file-based)
- ❌ **CRITICAL:** Globs pattern `**/*` matches ALL files (overly broad)
- ❌ **MAJOR:** Both globs and alwaysApply present (conflicting)

**Impact:** Rule will load 100% of the time with vague API context, bloating context for non-API files.

#### Gate 2: Glob Patterns Review ⚠️
**Issues found:**
- ❌ **CRITICAL:** Pattern `**/*` is overly broad (matches everything)
- ❌ **MAJOR:** Doesn't target specific file types
- ❌ **MAJOR:** No specificity (would match config, tests, docs, etc.)

**Impact:** If file-based triggering used, would load for every file.

#### Gate 3: Content Quality Review ⚠️
**Issues found:**
- ❌ **MAJOR:** No Overview section
- ❌ **MAJOR:** No cross-references to related rules
- ❌ **CRITICAL:** No concrete code examples (only abstract advice)
- ❌ **MAJOR:** No good vs bad pattern examples
- ❌ **MAJOR:** No ✅/❌ visual indicators
- ❌ **MAJOR:** Guidance is vague ("create good endpoints", "use authentication")
- ❌ **CRITICAL:** Not actionable (no specific patterns or code)
- ❌ **MAJOR:** No sections separated with `---`
- ❌ **MAJOR:** No Resources section

**Impact:** Rule provides no useful context. Too vague to guide development.

#### Gate 4: File Length Review ⚠️
- [ ] Line count: 22 lines
- [ ] Under 500 lines (✓)
- [ ] Content is too sparse (not dense enough)

**Issues found:**
- ⚠️ **MINOR:** Content is too sparse for topic (could be more comprehensive)

**Impact:** Minimal - file is short but lacks substance.

#### Gate 5: Functionality Review ⚠️
**Issues found:**
- ❌ **CRITICAL:** Rule loads for ALL files due to `alwaysApply: true` + broad globs
- ❌ **CRITICAL:** Context is not helpful (too vague)
- ❌ **CRITICAL:** Would bloat context without providing value
- ❌ **MAJOR:** No way to validate if context improves responses

**Impact:** Performance degradation, context pollution, no value added.

### Review Report

```markdown
# Rule Review: api-stuff.mdc
**Reviewer:** Claude (cursor-rules-review skill)
**Date:** 2025-11-21

## Issues Found
**BLOCKER:** 0
**CRITICAL:** 7
**MAJOR:** 13
**MINOR:** 1

## Status
- [x] 🚫 BLOCKED

**Summary:** This rule has multiple critical issues that prevent it from being useful. The frontmatter uses vague description, overly broad glob patterns, and conflicting triggering configuration. The content lacks concrete examples, actionable guidance, and proper organization. The rule would load for all files and provide minimal value while bloating context.

**Critical issues requiring immediate attention:**

### Frontmatter Issues
1. **CRITICAL:** Description is too vague ("API stuff")
   - **Fix:** Use specific description: "REST API design patterns for endpoints, authentication, error handling, and validation. Apply when creating or modifying API routes."

2. **CRITICAL:** `alwaysApply: true` inappropriate for API-specific content
   - **Fix:** Change to `alwaysApply: false` and use file-based triggering

3. **CRITICAL:** Globs pattern `**/*` matches all files
   - **Fix:** Use specific patterns: `globs: ["**/api/**/*.ts", "**/routes/**/*.ts", "**/controllers/**/*.ts"]`

### Content Issues
4. **CRITICAL:** No concrete code examples
   - **Fix:** Add TypeScript/Node.js code examples for each pattern

5. **CRITICAL:** Guidance is not actionable
   - **Fix:** Replace vague advice with specific patterns showing implementation

6. **CRITICAL:** Rule provides no useful context
   - **Fix:** Complete rewrite with examples, good/bad patterns, and cross-references

### Functionality Issues
7. **CRITICAL:** Would bloat context without value
   - **Fix:** After fixing frontmatter and content issues, retest functionality

**Recommendation:** Complete rewrite required. Use @api-patterns.mdc template as starting point.
```

### Success Criteria

**Must have:**
- ✅ Identifies all critical issues correctly
- ✅ Assigns appropriate severity levels
- ✅ Review report indicates BLOCKED
- ✅ Provides actionable fixes for each issue
- ✅ Explains impact of issues
- ✅ No false negatives (missed issues)

---

## Scenario 3: Review Borderline Rule (NEEDS WORK)

**Objective:** Validate that the review skill correctly applies nuanced judgment for rules needing minor improvements.

### Setup

Create a sample rule file: **typescript-utils.mdc**

```markdown
---
description: TypeScript utility patterns
globs: ["**/utils/**/*.ts", "**/helpers/**/*.ts"]
alwaysApply: false
---

# TypeScript Utilities

## Overview

This rule covers utility function patterns for the project.

---

## Type Guards

```typescript
// Good
function isString(value: unknown): value is string {
  return typeof value === 'string';
}

// Bad
function isString(value: any) {
  return typeof value === 'string';
}
```

---

## Array Utilities

```typescript
function uniqueBy<T>(arr: T[], key: keyof T): T[] {
  const seen = new Set();
  return arr.filter(item => {
    const k = item[key];
    if (seen.has(k)) return false;
    seen.add(k);
    return true;
  });
}
```

---

## Object Utilities

```typescript
function pick<T, K extends keyof T>(obj: T, keys: K[]): Pick<T, K> {
  return keys.reduce((acc, key) => {
    acc[key] = obj[key];
    return acc;
  }, {} as Pick<T, K>);
}
```
```

### Expected Behavior

#### Gate 1: Frontmatter Review ⚠️
**Issues found:**
- ⚠️ **MAJOR:** Description is vague ("utility patterns")
- ⚠️ **MAJOR:** Description missing "when to use" context
- ⚠️ **MINOR:** Description could mention specific utilities (type guards, array helpers, object utilities)

**Impact:** Moderate - frontmatter functional but could be clearer.

#### Gate 2: Glob Patterns Review ✓
- [ ] Patterns use `**/` for recursion
- [ ] Target specific file types (`.ts`)
- [ ] Appropriately specific (utils, helpers directories)
- [ ] Adequate coverage

**Result:** ✅ PASS - No issues

#### Gate 3: Content Quality Review ⚠️
**Issues found:**
- ⚠️ **MINOR:** Overview is sparse (could explain more)
- ⚠️ **MAJOR:** No cross-references to related rules
- ⚠️ **MINOR:** Missing ✅/❌ visual indicators (uses "Good/Bad" text)
- ⚠️ **MINOR:** No Resources section

**Strengths:**
- ✓ Has concrete code examples
- ✓ Shows good vs bad patterns
- ✓ Sections separated with `---`
- ✓ Code is actionable and specific

**Impact:** Minor - content is useful but could be improved.

#### Gate 4: File Length Review ✓
- [ ] Line count: 57 lines
- [ ] Under 500 lines (✓)
- [ ] Appropriate content density

**Result:** ✅ PASS - No issues

#### Gate 5: Functionality Review ✓
- [ ] Rule would load for files in `utils/` directory
- [ ] Rule would load for files in `helpers/` directory
- [ ] Context is relevant for utility functions
- [ ] No conflicts expected

**Result:** ✅ PASS - No issues

### Review Report

```markdown
# Rule Review: typescript-utils.mdc
**Reviewer:** Claude (cursor-rules-review skill)
**Date:** 2025-11-21

## Issues Found
**BLOCKER:** 0
**CRITICAL:** 0
**MAJOR:** 2
**MINOR:** 3

## Status
- [x] ⚠️ NEEDS WORK

**Summary:** This rule is functional and provides useful context with concrete examples. However, it has some areas for improvement including vague description, missing cross-references, and inconsistent visual indicators.

**Issues to address:**

### MAJOR Issues (Should fix)

1. **Description is vague**
   - **Current:** "TypeScript utility patterns"
   - **Fix:** "TypeScript utility functions including type guards, array helpers, and object manipulation utilities. Apply when creating or modifying utility functions."
   - **Impact:** Users may not understand when to use this rule

2. **Missing cross-references**
   - **Fix:** Add references to related rules in Overview section
   - **Example:** "See @typescript-patterns.mdc for general TypeScript patterns and @testing-patterns.mdc for testing utilities."
   - **Impact:** Reduces discoverability of related context

### MINOR Issues (Nice to have)

3. **Overview is sparse**
   - **Fix:** Expand overview to explain utility function best practices
   - **Impact:** Minimal - current overview is functional

4. **Missing ✅/❌ visual indicators**
   - **Fix:** Replace "Good/Bad" comments with ✅/❌ symbols
   - **Impact:** Minimal - pattern comparison is clear

5. **No Resources section**
   - **Fix:** Add Resources section with links to TypeScript docs
   - **Impact:** Minimal - examples are self-contained

**Recommendation:** Fix MAJOR issues and consider addressing MINOR improvements. After fixes, rule will be ready for approval.

**Estimated time to fix:** 10-15 minutes
```

### Success Criteria

**Must have:**
- ✅ Correctly identifies MAJOR and MINOR issues
- ✅ Doesn't flag functional aspects as problems
- ✅ Review report indicates NEEDS WORK
- ✅ Provides actionable fixes with priority
- ✅ Acknowledges strengths (concrete examples, structure)
- ✅ Nuanced judgment (not overly harsh or lenient)

---

## Baseline Comparison Methodology

### Without cursor-rules-review Skill

**Test:** Ask Claude to review a Cursor rule without the skill.

**Expected issues:**
- May not know about .mdc format requirements
- May miss YAML frontmatter validation
- May not check glob pattern syntax
- May not validate cross-references
- May miss file length considerations
- May not apply severity levels consistently
- May provide vague feedback

**Typical review quality: 4/10**

Example output without skill:
```
This rule looks okay. The description could be more specific.
The code examples are helpful. Maybe add more details?
```

### With cursor-rules-review Skill

**Test:** Same request with skill loaded.

**Expected improvements:**
- Validates YAML frontmatter syntax
- Checks all required fields
- Validates glob pattern syntax and specificity
- Verifies cross-reference format
- Checks file length against target
- Applies 5-gate review process systematically
- Assigns severity levels (BLOCKER, CRITICAL, MAJOR, MINOR)
- Provides actionable fixes for each issue
- Follows standardized review report format

**Expected review quality: 9/10**

Example output with skill:
```markdown
# Rule Review: example.mdc
**Reviewer:** Claude
**Date:** 2025-11-21

## Gate 1: Frontmatter Review
**Status:** ⚠️ ISSUES
- ❌ CRITICAL: Description is vague ("stuff")
- ❌ MAJOR: Missing "when to use" context
**Fix:** Rewrite as "Specific patterns for X. Apply when..."

## Gate 2: Glob Patterns Review
**Status:** ✅ PASS

[... comprehensive review ...]

## Status
- [x] ⚠️ NEEDS WORK
```

### Measurable Improvements

| Metric | Without Skill | With Skill |
|--------|---------------|------------|
| Frontmatter validation | 30% | 100% |
| Glob pattern check | 20% | 100% |
| Severity level assignment | 10% | 95% |
| Actionable fixes provided | 40% | 95% |
| Standardized report format | 0% | 100% |
| Cross-reference validation | 5% | 90% |
| File length consideration | 30% | 100% |
| Functionality testing | 10% | 85% |

---

## Multi-Model Testing

### Test Across Claude Models

**Haiku (Fast model):**
- Should follow 5-gate structure
- May produce shorter issue descriptions
- Should still catch critical issues
- Expected: 7/10 review quality

**Sonnet (Balanced model):**
- Should produce comprehensive reviews
- Good balance of detail and thoroughness
- Proper use of all severity levels
- Expected: 9/10 review quality

**Opus (Highest quality):**
- Should produce exemplary reviews
- Perfect gate-by-gate analysis
- Excellent issue descriptions and fixes
- Expected: 10/10 review quality

### Consistency Check

Test same problematic rule across models:
- All should use 5-gate structure
- All should flag critical issues
- All should provide actionable fixes
- All should use standard report format
- Variations in detail level are acceptable

---

## Real-World Validation

### Validation 1: Review Existing Helm Rules

**Task:** Use cursor-rules-review skill to audit the 5 existing Helm rules.

**Success criteria:**
- Identifies that helm-expert-skill.mdc (824 lines) exceeds 500-line target
- Recognizes appropriate `alwaysApply: true` for core skill
- Validates glob patterns for file-based rules
- Checks cross-references between rules
- Provides actionable recommendations

### Validation 2: Review Rules Created by cursor-rules-writing

**Task:** Create a rule using cursor-rules-writing skill, then review with cursor-rules-review skill.

**Success criteria:**
- Review confirms rule follows best practices
- Few or no issues found (rules created by writing skill should be high quality)
- Creates virtuous cycle: writing → reviewing → improving writing
- Validates that writing skill produces quality output

### Validation 3: Team Usage

**Task:** Have multiple team members review the same rule file.

**Success criteria:**
- All reviewers use 5-gate structure
- Consistent issue identification across reviewers
- Similar severity level assignments
- Comparable review quality
- Standard report format maintained

### Validation 4: Performance Impact

**Task:** Measure time to conduct reviews with vs without skill.

**Success criteria:**
- Skill-based reviews are systematic (all gates covered)
- Review time: ~40-45 minutes per rule (as documented in CHECKLIST.md)
- Higher quality reviews (fewer missed issues)
- Actionable recommendations provided
- Consistent application of standards

---

## Edge Cases to Test

### Edge Case 1: Rule with No Frontmatter

**File:** missing-frontmatter.mdc
```markdown
# Some Rule

This is content without frontmatter.
```

**Expected result:**
- ❌ **BLOCKER:** No YAML frontmatter present
- Review status: 🚫 BLOCKED
- Cannot proceed to other gates without frontmatter

---

### Edge Case 2: Rule with Invalid YAML

**File:** invalid-yaml.mdc
```markdown
---
description: "Unclosed quote
globs: [invalid
---
```

**Expected result:**
- ❌ **BLOCKER:** Invalid YAML syntax
- Review status: 🚫 BLOCKED
- Provide YAML validation error details

---

### Edge Case 3: Rule with Both alwaysApply and Globs

**File:** conflicting-triggers.mdc
```markdown
---
description: Some patterns
globs: ["**/*.ts"]
alwaysApply: true
---
```

**Expected result:**
- ❌ **MAJOR:** Both globs and alwaysApply present (conflicting configuration)
- **Fix:** Choose one triggering mechanism
- Review status: ⚠️ NEEDS WORK

---

### Edge Case 4: Rule Exactly 500 Lines

**File:** exactly-500-lines.mdc (500 lines)

**Expected result:**
- ✅ File length acceptable (at target limit)
- No file length issues
- Note in report: "At 500-line target limit - monitor for growth"

---

### Edge Case 5: Rule with Broken Cross-References

**File:** broken-refs.mdc
```markdown
---
description: Some patterns
globs: ["**/*.ts"]
---

See @non-existent-rule.mdc for details.
Also check @another-missing.mdc.
```

**Expected result:**
- ❌ **BLOCKER:** Cross-reference to non-existent file (@non-existent-rule.mdc)
- ❌ **BLOCKER:** Cross-reference to non-existent file (@another-missing.mdc)
- **Fix:** Remove broken references or create referenced files
- Review status: 🚫 BLOCKED

---

## Continuous Improvement

### Skill Iteration Based on Testing

**After running test scenarios:**
1. Identify any confusion or false positives/negatives
2. Check if Skill.md gate definitions need refinement
3. Verify CHECKLIST.md covers all validation points
4. Update EXAMPLES.md with new patterns discovered
5. Add new test scenarios for edge cases found
6. Refine severity level guidelines if needed

### Success Metrics for Skill Itself

**Target metrics:**
- 95%+ correct issue identification (no false negatives)
- 90%+ correct severity assignment
- 85%+ actionable fixes provided
- 100% consistent report format
- <5% false positives (issues flagged incorrectly)

### Feedback Loop

```
cursor-rules-writing skill
          ↓ creates rules
cursor-rules-review skill
          ↓ reviews & finds issues
Pattern analysis
          ↓ identifies common mistakes
cursor-rules-writing skill
          ↓ updated to prevent issues
Better rules created
```

### Common Improvements Discovered Through Testing

Track patterns in review findings to improve writing skill:

1. **If many rules have vague descriptions:**
   - Update cursor-rules-writing/TEMPLATE.md with better examples
   - Add more emphasis on "when to use" in Skill.md

2. **If glob patterns frequently too broad:**
   - Enhance glob pattern guidance in writing skill
   - Add more specific pattern examples

3. **If cross-references often missing:**
   - Add cross-reference checklist to writing skill
   - Emphasize in Quick Start workflow

4. **If file length frequently exceeded:**
   - Strengthen progressive disclosure guidance
   - Add splitting strategies to writing skill

---

## Test Automation Opportunities

### Automated Checks (Could be scripted)

```bash
# Check frontmatter exists
head -5 rule.mdc | grep -c "^---$"

# Validate YAML syntax
# (extract frontmatter and pipe to yamllint)

# Check line count
wc -l rule.mdc

# Test glob patterns
# (extract globs and test with find/fd)

# Validate cross-references
grep -o "@[a-z-]*.mdc" rule.mdc | while read ref; do
  file="${ref#@}"
  [ -f ".cursor/rules/$file" ] || echo "Missing: $ref"
done
```

### Manual Review Required

These aspects require human judgment:
- Description quality and specificity
- Content actionability
- Example relevance
- Cross-reference appropriateness
- Overall context usefulness

---

## Integration with cursor-rules-writing Skill

### Workflow Integration

**Creating new rules:**
```
1. User: "Create a rule for X"
2. Invoke cursor-rules-writing skill
3. Create rule following best practices
4. Invoke cursor-rules-review skill
5. Review created rule
6. Fix any issues found
7. Deliver final rule to user
```

**Improving existing rules:**
```
1. User: "Review my Cursor rule"
2. Invoke cursor-rules-review skill
3. Conduct 5-gate review
4. Identify issues
5. Invoke cursor-rules-writing skill (for fixes)
6. Apply fixes following best practices
7. Re-review to confirm improvements
```

### Quality Assurance

Both skills working together ensure:
- ✅ Rules created follow best practices
- ✅ Rules are systematically reviewed
- ✅ Issues are identified and fixed
- ✅ Continuous improvement cycle
- ✅ Consistent quality standards

---

**These test scenarios follow the meta skill testing best practices and should be used to validate the cursor-rules-review skill effectiveness.**
