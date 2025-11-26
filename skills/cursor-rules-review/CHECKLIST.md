# Cursor Rules Review Checklist

Copy-paste ready checklist for reviewing Cursor .mdc rule files.

---

## Quick Review Checklist

```markdown
# Rule Review: [rule-name.mdc]
**Reviewer:** [Your Name]
**Date:** [YYYY-MM-DD]

## Frontmatter ✓
- [ ] Valid YAML syntax (starts and ends with ---)
- [ ] description field present
- [ ] Description is specific (not vague)
- [ ] Description uses third person
- [ ] Description includes "when to use"
- [ ] Appropriate trigger (always/file-based/manual)
- [ ] alwaysApply only for universal context
- [ ] globs array for file-based rules
- [ ] Correct field types

## Glob Patterns ✓
- [ ] Valid glob syntax
- [ ] Patterns use **/ for recursion
- [ ] Appropriately specific (not too broad)
- [ ] Adequate coverage (no gaps)
- [ ] Negations correct (if used)
- [ ] Patterns tested and verified

## Content ✓
- [ ] Has Overview section
- [ ] Cross-references related rules
- [ ] Logical organization
- [ ] Sections separated with ---
- [ ] Concrete code examples (not abstract)
- [ ] Good vs bad patterns (✅/❌)
- [ ] Cross-references validated
- [ ] Actionable guidance

## File Length ✓
- [ ] Under 500 lines OR justified
- [ ] No clear splitting opportunities
- [ ] Appropriate content density

## Functionality ✓
- [ ] Rule loads correctly
- [ ] Globs match expected files
- [ ] Cross-references work
- [ ] Context is helpful
- [ ] No conflicts with other rules
- [ ] No performance issues

## Issues Found
**BLOCKER:** [count]
**CRITICAL:** [count]
**MAJOR:** [count]
**MINOR:** [count]

## Status
- [ ] ✅ APPROVED
- [ ] ⚠️ NEEDS WORK
- [ ] 🚫 BLOCKED
```

---

## Comprehensive 5-Gate Checklist

### Gate 1: Frontmatter Review

```markdown
## Gate 1: Frontmatter Review

### YAML Syntax
- [ ] Frontmatter starts with ---
- [ ] Frontmatter ends with ---
- [ ] All strings properly quoted
- [ ] Arrays use bracket syntax []
- [ ] Boolean values lowercase (true/false)
- [ ] No YAML syntax errors

### Required Fields
- [ ] description field present
- [ ] Description non-empty
- [ ] Description under 1024 characters

### Description Quality
- [ ] Description is specific
- [ ] Uses third person (not I/you)
- [ ] Explains WHAT context provided
- [ ] Explains WHEN to apply
- [ ] Includes key terms/technologies
- [ ] Actionable and clear

### Triggering Configuration
- [ ] Has appropriate trigger
- [ ] alwaysApply true only for universal
- [ ] File-based rules have globs
- [ ] Manual rules have neither
- [ ] Not both globs and alwaysApply true

### Field Validation
- [ ] description is string
- [ ] globs is array (if present)
- [ ] alwaysApply is boolean (if present)
- [ ] No extra/unknown fields

### Issues:
- BLOCKER: [list]
- CRITICAL: [list]
- MAJOR: [list]
- MINOR: [list]
```

### Gate 2: Glob Patterns Review

```markdown
## Gate 2: Glob Patterns Review

### Pattern Syntax
- [ ] Patterns use **/ for recursion
- [ ] Target specific file types
- [ ] Multiple extensions use {ext1,ext2}
- [ ] Patterns in array format
- [ ] No bare patterns

### Pattern Specificity
- [ ] Appropriately specific
- [ ] Not matching all files (**/*)
- [ ] Not overly broad
- [ ] Targets relevant files only

### Pattern Coverage
- [ ] Covers all relevant files
- [ ] Doesn't miss nested directories
- [ ] Covers related file types
- [ ] No gaps in coverage

### Negation Patterns (if used)
- [ ] Negations after inclusions
- [ ] Negation syntax correct (!)
- [ ] Negations necessary

### Pattern Testing
- [ ] Tested with find/fd
- [ ] Matches actual project files
- [ ] No false positives
- [ ] No false negatives

### Issues:
- BLOCKER: [list]
- CRITICAL: [list]
- MAJOR: [list]
- MINOR: [list]
```

### Gate 3: Content Quality Review

```markdown
## Gate 3: Content Quality Review

### Overview Section
- [ ] Has Overview section
- [ ] Explains rule purpose
- [ ] Includes cross-references
- [ ] Uses --- separator

### Content Organization
- [ ] Logical section organization
- [ ] Sections separated with ---
- [ ] Clear section headings
- [ ] Progressive flow
- [ ] Resources section at bottom

### Examples Quality
- [ ] Contains concrete code examples
- [ ] Examples are project-specific
- [ ] Shows good AND bad patterns
- [ ] Examples are realistic
- [ ] At least 2-3 substantial examples
- [ ] Demonstrates key concepts

### Good vs Bad Patterns
- [ ] Uses ✅ for good
- [ ] Uses ❌ for bad
- [ ] Shows both patterns
- [ ] Explains why

### Cross-References
- [ ] References related rules
- [ ] Uses @filename.mdc syntax
- [ ] Cross-references relevant
- [ ] Referenced files exist
- [ ] Descriptive text provided

### Actionable Guidance
- [ ] Specific and actionable
- [ ] Includes "how to"
- [ ] Provides concrete steps
- [ ] Avoids vague phrases

### Issues:
- BLOCKER: [list]
- CRITICAL: [list]
- MAJOR: [list]
- MINOR: [list]
```

### Gate 4: File Length Review

```markdown
## Gate 4: File Length Review

### Line Count
- [ ] Line count: [X] lines
- [ ] Under 500 lines (ideal)
- [ ] 500-700 with justification
- [ ] Over 700 requires splitting

### Justification (if over 500)
- [ ] Justification documented
- [ ] Justification is valid
- [ ] Alternative splitting considered

### Splitting Opportunities
- [ ] Distinct topics identified
- [ ] Could separate into focused rules
- [ ] Splitting would improve maintainability
- [ ] Cross-references would connect

### Content Density
- [ ] Content is dense
- [ ] No repetitive patterns
- [ ] No excessive whitespace
- [ ] Each section adds value

### Issues:
- BLOCKER: [list]
- CRITICAL: [list]
- MAJOR: [list]
- MINOR: [list]
```

### Gate 5: Functionality Review

```markdown
## Gate 5: Functionality Review

### Rule Loading Test
- [ ] Always-apply loads in every chat
- [ ] File-based loads for matching files
- [ ] File-based doesn't load for non-matching
- [ ] Manual loads when @-mentioned
- [ ] No error messages in Cursor

### Glob Pattern Verification
- [ ] Patterns match actual files
- [ ] Tested with find/fd
- [ ] No unexpected matches
- [ ] No missed files

### Cross-Reference Validation
- [ ] All @-mentions verified
- [ ] Referenced files exist
- [ ] No broken links
- [ ] @-mentions work in Cursor

### Context Quality Test
- [ ] Provides relevant context
- [ ] Context is helpful
- [ ] No conflicts with other rules
- [ ] Improves Cursor responses

### Performance Impact
- [ ] Always-apply rules concise
- [ ] Total context load reasonable
- [ ] No performance degradation
- [ ] File-based targeting works

### Issues:
- BLOCKER: [list]
- CRITICAL: [list]
- MAJOR: [list]
- MINOR: [list]
```

---

## Issue Tracking Template

```markdown
## Issues Summary

### BLOCKER Issues (Must fix immediately)
1. [Issue description]
   - **Impact:** [Why it blocks]
   - **Fix:** [How to resolve]
   - **Example:** [Code example]

### CRITICAL Issues (Must fix before production)
1. [Issue description]
   - **Impact:** [Why it's critical]
   - **Fix:** [How to resolve]
   - **Example:** [Code example]

### MAJOR Issues (Should fix soon)
1. [Issue description]
   - **Impact:** [Impact on quality]
   - **Fix:** [Recommended solution]

### MINOR Issues (Nice to have)
1. [Issue description]
   - **Suggestion:** [Improvement idea]
```

---

## Severity Guidelines

### BLOCKER (Fix immediately - prevents rule from working)
- Missing or invalid YAML frontmatter
- Invalid glob pattern syntax
- Rule doesn't load at all
- Referenced files don't exist (broken links)
- Rule file not in .cursor/rules/ directory

### CRITICAL (Fix before production - causes serious issues)
- Overly broad glob patterns (`**/*`)
- Inappropriate `alwaysApply: true` (context bloat)
- No code examples (only abstract advice)
- Rule loads when it shouldn't
- Rule doesn't load when it should
- Conflicts with other rules
- Performance degradation

### MAJOR (Should fix - impacts quality significantly)
- Vague description
- Missing "when to use" context
- Glob patterns missing recursive `**/`
- Missing obvious cross-references
- No good vs bad pattern examples
- Poor content organization
- File over 500 lines without justification
- Mostly vague guidance

### MINOR (Nice to have - improvements)
- Description could be more specific
- Missing ✅/❌ visual indicators
- Could add more examples
- Cross-references missing descriptive text
- Minor organizational improvements
- Whitespace/formatting issues

---

## Quick Commands Reference

```bash
# Check frontmatter
head -n 10 .cursor/rules/rule-name.mdc

# Validate YAML
# (paste frontmatter into https://www.yamllint.com/)

# Check line count
wc -l .cursor/rules/rule-name.mdc

# Test glob patterns
find . -path "**/Chart.yaml"
fd --glob "**/*.ts"

# Check cross-references
grep -o "@[a-z-]*.mdc" .cursor/rules/rule-name.mdc

# Verify referenced files
for ref in $(grep -o "@[a-z-]*.mdc" .cursor/rules/rule-name.mdc); do
  file=".cursor/rules/${ref#@}"
  if [ -f "$file" ]; then
    echo "✅ $ref exists"
  else
    echo "❌ $ref missing"
  fi
done

# List all rules
ls -la .cursor/rules/*.mdc

# Check for broken always-apply
grep -l "alwaysApply: true" .cursor/rules/*.mdc

# Find large rules
find .cursor/rules -name "*.mdc" -exec wc -l {} \; | sort -n
```

---

## Review Workflow

### Step 1: Initial Scan (5 minutes)
```markdown
- [ ] Open rule file
- [ ] Quick scan for obvious issues
- [ ] Check frontmatter exists
- [ ] Check file length
- [ ] Note initial impressions
```

### Step 2: Gate 1 - Frontmatter (5 minutes)
```markdown
- [ ] Validate YAML syntax
- [ ] Check required fields
- [ ] Review description quality
- [ ] Verify triggering config
- [ ] Document issues
```

### Step 3: Gate 2 - Glob Patterns (5 minutes)
```markdown
- [ ] Review pattern syntax
- [ ] Check specificity
- [ ] Verify coverage
- [ ] Test patterns
- [ ] Document issues
```

### Step 4: Gate 3 - Content (10 minutes)
```markdown
- [ ] Review structure
- [ ] Check examples
- [ ] Verify cross-references
- [ ] Assess actionability
- [ ] Document issues
```

### Step 5: Gate 4 - File Length (3 minutes)
```markdown
- [ ] Count lines
- [ ] Check justification (if needed)
- [ ] Identify splitting opportunities
- [ ] Document issues
```

### Step 6: Gate 5 - Functionality (10 minutes)
```markdown
- [ ] Test rule loading
- [ ] Verify glob matching
- [ ] Validate cross-references
- [ ] Assess context quality
- [ ] Document issues
```

### Step 7: Write Report (5 minutes)
```markdown
- [ ] Summarize findings
- [ ] List issues by severity
- [ ] Provide recommendations
- [ ] Make approval decision
```

**Total time: ~40-45 minutes per rule**

---

## Approval Criteria

### ✅ APPROVED
- No BLOCKER issues
- No CRITICAL issues
- MAJOR issues acceptable or have plan to fix
- All 5 gates pass
- Ready for production use

### ⚠️ NEEDS WORK
- No BLOCKER issues
- CRITICAL or MAJOR issues need fixing
- Rule works but needs improvements
- Resubmit after fixes

### 🚫 BLOCKED
- BLOCKER issues present
- Rule doesn't work
- Must fix before any approval
- Cannot proceed to production

---

**This checklist follows the cursor-rules-review skill best practices and should be used for all rule reviews.**
