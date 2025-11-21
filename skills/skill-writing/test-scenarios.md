---
title: Skill Writing Test Scenarios
purpose: Validate that skill-writing skill improves Claude's ability to create high-quality skills
---

# Skill Writing Test Scenarios

## Overview

These test scenarios validate that the skill-writing skill helps Claude create better skills compared to baseline (no guidance). Each scenario includes:

- **Setup**: Initial context and requirements
- **Expected Behavior**: What Claude should do with the skill
- **Success Criteria**: Measurable outcomes
- **Validation Method**: How to verify success

---

## Scenario 1: Create Simple Skill (Basic Validation)

### Setup
**Context:** User needs a skill for processing CSV files (read, parse, validate, transform)

**User Request:** "Create a skill for CSV file processing"

**Baseline Expectation (No Skill):**
- Claude might create incorrect directory structure
- May use wrong naming convention (not gerund form)
- Frontmatter may have wrong format or missing fields
- Description likely too brief or too verbose
- Content may lack concrete examples
- No progressive disclosure consideration

### Expected Behavior (With skill-writing skill)

1. **Invoke skill-writing skill** - Claude recognizes this as a skill creation task
2. **Follow 5-step workflow**:
   - Step 1: Identify gap (CSV processing need)
   - Step 2: Create 3+ evaluations first (SKIP in test, acknowledge should do)
   - Step 3: Write minimal Skill.md following template
   - Step 4: Test with fresh instance (SKIP in test, explain what would test)
   - Step 5: Iterate based on feedback
3. **Produce skill with:**
   - Correct directory: `processing-csv/` (gerund, kebab-case)
   - Correct frontmatter: `name: processing-csv`, proper description (< 1024 chars, third person), version: 1.0.0
   - Clear "When to Use" and "When NOT to Use" sections
   - Concrete workflow with 5-8 steps
   - 2-3 working examples
   - Tool invocation patterns
   - Best practices section
   - Error handling guidance

### Success Criteria

**Structural (MUST PASS):**
- ✅ Directory name uses gerund + kebab-case (`processing-csv`)
- ✅ File named `Skill.md` (capital S)
- ✅ Frontmatter has all required fields (name, description, version)
- ✅ Frontmatter `name` field uses kebab-case (not Title Case)
- ✅ Description under 1024 characters, third person
- ✅ Skill.md under 500 lines (or justification if over)

**Content Quality (MUST PASS):**
- ✅ Clear "When to Use" section with 3+ triggers
- ✅ Clear "When NOT to Use" section
- ✅ Workflow with numbered steps (5-8 steps)
- ✅ At least 2 concrete examples with actual code
- ✅ Error handling section or troubleshooting

**Best Practices (SHOULD PASS):**
- ✅ Examples show input → process → output
- ✅ Tool invocation patterns shown
- ✅ Common pitfalls documented
- ✅ Integration with other skills noted (if applicable)

### Validation Method

**Automated Checks:**
```bash
# Directory name check
[[ $(basename "$skill_dir") =~ ^[a-z]+(-[a-z]+)*$ ]] && echo "✅ Directory name valid" || echo "❌ Directory name invalid"

# Gerund check (basic - ends in -ing or common gerund words)
[[ $(basename "$skill_dir") =~ ing$ ]] && echo "✅ Gerund form" || echo "⚠️  May not be gerund"

# Frontmatter check
grep -q "^name: [a-z-]*$" "$skill_dir/Skill.md" && echo "✅ Frontmatter name valid" || echo "❌ Name not kebab-case"
grep -q "^description:" "$skill_dir/Skill.md" && echo "✅ Description exists" || echo "❌ No description"
grep -q "^version: [0-9]" "$skill_dir/Skill.md" && echo "✅ Version exists" || echo "❌ No version"

# Line count check
line_count=$(wc -l < "$skill_dir/Skill.md")
[[ $line_count -lt 500 ]] && echo "✅ Under 500 lines ($line_count)" || echo "⚠️  Over 500 lines ($line_count)"

# Section checks
grep -q "## When to Use" "$skill_dir/Skill.md" && echo "✅ When to Use section" || echo "❌ Missing When to Use"
grep -q "## When NOT to Use" "$skill_dir/Skill.md" && echo "✅ When NOT to Use section" || echo "❌ Missing When NOT to Use"
grep -q "## Workflow" "$skill_dir/Skill.md" && echo "✅ Workflow section" || echo "❌ Missing Workflow"
```

**Manual Review Checklist:**
- [ ] Description clearly explains WHAT + WHEN triggers
- [ ] Examples are concrete and runnable (or clearly pseudocode)
- [ ] Steps are actionable (verbs: "Invoke", "Check", "Create", etc.)
- [ ] No vague language ("properly", "correctly", "as needed")
- [ ] Error handling or troubleshooting guidance present

### Expected Results

**Baseline (No Skill):**
- ❌ 40% chance of wrong directory name
- ❌ 60% chance of wrong frontmatter format
- ❌ 70% chance of missing "When NOT to Use"
- ❌ 50% chance of vague examples
- ⏱️ Time: 10-15 minutes

**With skill-writing Skill:**
- ✅ 95% chance of correct directory name
- ✅ 95% chance of correct frontmatter
- ✅ 90% chance of complete sections
- ✅ 85% chance of concrete examples
- ⏱️ Time: 5-8 minutes (faster due to template)

**Improvement:** 45-50 percentage points better compliance, 40% faster

---

## Scenario 2: Create Skill with REFERENCE.md (Progressive Disclosure)

### Setup
**Context:** User needs a comprehensive skill for Kubernetes troubleshooting (many sub-topics: pods, services, ingress, storage, networking)

**User Request:** "Create a skill for troubleshooting Kubernetes deployments"

**Baseline Expectation (No Skill):**
- Creates single 800+ line Skill.md file
- No progressive disclosure
- Hard to scan and find relevant information

### Expected Behavior (With skill-writing skill)

1. **Recognize scope is large** - Kubernetes troubleshooting has many sub-areas
2. **Apply progressive disclosure pattern**:
   - Main Skill.md: Overview, when to use, high-level workflow (< 500 lines)
   - REFERENCE.md: Detailed troubleshooting procedures, command references
   - EXAMPLES.md (optional): Extended examples for complex scenarios
3. **Structure for scannability**:
   - Skill.md: Quick reference, decision tree, invoke patterns
   - REFERENCE.md: Deep dives, comprehensive command lists

### Success Criteria

**Progressive Disclosure (MUST PASS):**
- ✅ Skill.md under 500 lines
- ✅ REFERENCE.md exists and referenced from Skill.md
- ✅ References use correct format: "See REFERENCE.md Section X"
- ✅ No broken references (all referenced sections exist)

**Organization (SHOULD PASS):**
- ✅ Skill.md is scannable (clear headings, short sections)
- ✅ REFERENCE.md is well-organized (TOC, clear sections)
- ✅ No duplication between files
- ✅ Logical split (overview vs details)

### Validation Method

```bash
# Progressive disclosure check
main_lines=$(wc -l < "troubleshooting-kubernetes/Skill.md")
[[ $main_lines -lt 500 ]] && echo "✅ Main file under 500 lines" || echo "❌ Main file too long ($main_lines)"

# REFERENCE.md exists
[[ -f "troubleshooting-kubernetes/REFERENCE.md" ]] && echo "✅ REFERENCE.md exists" || echo "❌ No REFERENCE.md"

# References are valid
grep -o "REFERENCE.md Section [0-9]" "troubleshooting-kubernetes/Skill.md" | sort -u > /tmp/refs.txt
grep -o "^## Section [0-9]:" "troubleshooting-kubernetes/REFERENCE.md" | sort -u > /tmp/sections.txt
diff /tmp/refs.txt /tmp/sections.txt && echo "✅ All references valid" || echo "❌ Broken references"
```

### Expected Results

**Baseline (No Skill):**
- ❌ 90% create single 800+ line file
- ❌ 10% attempt progressive disclosure but break references
- ⏱️ Difficult to use (poor scannability)

**With skill-writing Skill:**
- ✅ 85% correctly implement progressive disclosure
- ✅ 95% keep main file under 500 lines
- ✅ 80% have valid references
- ⏱️ Much easier to use (quick overview + deep dive option)

**Improvement:** 75 percentage points better progressive disclosure

---

## Scenario 3: Validate Skill Structure (Quality Review)

### Setup
**Context:** User has created a skill manually and wants it reviewed

**User Provides:** A `data-processing/Skill.md` file with several issues:
- Frontmatter: `name: Data Processing Helper` (should be kebab-case)
- Directory: `data-processing` (correct, but let's say skill is actually about analyzing data, not processing)
- No "When NOT to Use" section
- Examples are vague ("Process the data properly")
- 620 lines long, no REFERENCE.md

**User Request:** "Review this skill for quality"

### Expected Behavior (With skill-writing skill)

1. **Invoke skill-review skill** (related skill) or apply checklist from skill-writing
2. **Identify issues**:
   - ❌ Frontmatter name not kebab-case
   - ❌ Directory name doesn't match function (analyzing vs processing)
   - ❌ Missing "When NOT to Use"
   - ❌ Vague examples
   - ❌ Over 500 lines without progressive disclosure
3. **Provide specific fixes**:
   - Update frontmatter: `name: data-processing` or `name: analyzing-data`
   - Clarify skill purpose
   - Add "When NOT to Use" section
   - Make examples concrete
   - Extract to REFERENCE.md or trim content
4. **Prioritize by severity**: Blockers first, then major, then minor

### Success Criteria

**Issue Detection (MUST PASS):**
- ✅ Identifies frontmatter naming issue (BLOCKER)
- ✅ Identifies missing required section (MAJOR)
- ✅ Identifies vague examples (MAJOR)
- ✅ Identifies file length issue (MINOR with recommendation)

**Fix Quality (SHOULD PASS):**
- ✅ Provides exact corrections (not just "fix the name")
- ✅ Explains why each fix is needed
- ✅ Prioritizes fixes by severity
- ✅ Offers multiple solutions where applicable

### Validation Method

**Review Output Checklist:**
- [ ] Lists all 4 issues identified above
- [ ] Severity levels assigned (BLOCKER, MAJOR, MINOR)
- [ ] Specific fix provided for each issue
- [ ] Rationale explains why fix is needed
- [ ] Priority order suggests starting with BLOCKER

### Expected Results

**Baseline (No Skill):**
- ⚠️ 50% miss frontmatter kebab-case requirement
- ⚠️ 60% miss "When NOT to Use" requirement
- ⚠️ 70% identify vague examples but don't fix
- ⏱️ Time: 5-10 minutes, incomplete review

**With skill-writing Skill:**
- ✅ 95% catch all structural issues
- ✅ 90% catch content quality issues
- ✅ 85% provide actionable fixes
- ⏱️ Time: 3-5 minutes, comprehensive review

**Improvement:** 40-45 percentage points better issue detection

---

## Multi-Model Testing Plan

Test each scenario across Claude models to ensure consistency:

### Haiku Testing
- **Expected:** Follows templates closely, may be more literal
- **Focus:** Verify structural compliance (naming, frontmatter)
- **Acceptable:** Slightly less nuanced examples, shorter descriptions

### Sonnet Testing
- **Expected:** Balances structure and creativity well
- **Focus:** Verify content quality (examples, clarity)
- **Acceptable:** May add extra helpful sections

### Opus Testing
- **Expected:** Most comprehensive, may go beyond requirements
- **Focus:** Verify doesn't over-engineer (keeps under 500 lines)
- **Acceptable:** Richer examples, more context

---

## Baseline Comparison Methodology

### Step 1: Test Baseline (No Skill)
1. Use fresh Claude instance (no skill-writing skill)
2. Provide scenario setup exactly as written
3. Record time taken
4. Evaluate against success criteria
5. Count issues found

### Step 2: Test With Skill
1. Use fresh Claude instance WITH skill-writing skill loaded
2. Provide same scenario setup
3. Record time taken
4. Evaluate against same success criteria
5. Count issues found

### Step 3: Calculate Improvement
```
Improvement = (With Skill Score - Baseline Score) / Baseline Score * 100%

Example:
Baseline: 6/13 criteria met (46%)
With Skill: 12/13 criteria met (92%)
Improvement: +46 percentage points
```

### Step 4: Document Results
Record in table format:

| Scenario | Model | Baseline Score | With Skill Score | Improvement | Time Saved |
|----------|-------|----------------|------------------|-------------|------------|
| 1: Simple | Sonnet | 6/13 (46%) | 12/13 (92%) | +46pp | 40% faster |
| 1: Simple | Haiku | 5/13 (38%) | 11/13 (85%) | +47pp | 35% faster |
| ... | ... | ... | ... | ... | ... |

---

## Success Metrics Summary

**Skill-writing skill is successful if:**

1. **Structural Compliance:** 85%+ of skills have correct naming, frontmatter, file structure
2. **Content Quality:** 80%+ of skills have clear triggers, concrete examples, error handling
3. **Progressive Disclosure:** 75%+ of complex skills correctly use REFERENCE.md
4. **Review Quality:** 90%+ of issues detected and actionable fixes provided
5. **Time Efficiency:** 30-40% faster skill creation with skill
6. **Consistency:** < 10% variance across models (Haiku, Sonnet, Opus)

**Overall Grade:**
- A: 90%+ on all metrics
- B: 80-89% on all metrics
- C: 70-79% on all metrics
- F: < 70% on any metric

---

## Notes for Testers

- Always use **fresh instances** (no prior context)
- Use **identical prompts** for baseline vs with-skill tests
- Record **verbatim output** for comparison
- Test **multiple times** (3-5 runs per scenario) for statistical validity
- **Document edge cases** and unexpected behaviors
- **Update scenarios** if skill evolves

---

## Continuous Improvement

After each test cycle:
1. Identify which criteria are frequently missed
2. Update skill-writing skill to address gaps
3. Add new scenarios for newly discovered edge cases
4. Re-run tests to validate improvements
5. Update this document with lessons learned

**Target:** 95%+ success rate across all scenarios and models by version 2.0.0
