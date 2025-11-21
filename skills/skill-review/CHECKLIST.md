# Skill Review Checklist

Copy-paste ready checklist for comprehensive skill quality audits. Use this during PR reviews or before releasing skills.

---

## Quick Start

```bash
# Navigate to skill directory
cd ~/.claude/skills/[skill-name]

# Copy this checklist to a review file
cp ~/.claude/skills/skill-review/CHECKLIST.md review-[skill-name].md

# Check items as you audit
# Mark [BLOCKER], [CRITICAL], [MAJOR], or [MINOR] for any failures
```

---

## 1. Structure Validation

### Directory Structure
- [ ] Directory name matches skill name
- [ ] Directory name uses gerund form (verb + -ing)
- [ ] Directory name lowercase-with-hyphens
- [ ] Directory name max 64 characters
- [ ] No spaces or underscores in directory name
- [ ] No generic names (helper, utils, tool)

### File Structure
- [ ] Skill.md exists (capital S)
- [ ] Supporting files use ALL CAPS (REFERENCE.md, TEMPLATE.md)
- [ ] No files named skill.md (lowercase s)
- [ ] No .txt or other wrong extensions
- [ ] No files with underscores
- [ ] Scripts directory lowercase (if exists)

### Organization
- [ ] No deeply nested directories
- [ ] Supporting files one level deep from Skill.md
- [ ] Clear separation of concerns (main vs reference)

**Issues found:**
```
[SEVERITY] Issue description
[SEVERITY] Issue description
```

---

## 2. Frontmatter Audit

### YAML Validity
- [ ] Has YAML frontmatter (between --- markers)
- [ ] YAML is valid (no syntax errors)
- [ ] Frontmatter at top of file

### Required Fields
- [ ] `name` field present
- [ ] `name` matches directory name exactly
- [ ] `name` uses gerund form (verb + -ing)
- [ ] `name` max 64 characters
- [ ] `name` lowercase-with-hyphens only
- [ ] `name` not generic (helper, utils, tool)
- [ ] `description` field present
- [ ] `description` max 1024 characters
- [ ] `version` field present
- [ ] `version` in SemVer format (X.Y.Z)

### Description Quality
- [ ] Written in third person (not first/second)
- [ ] Includes specific capabilities (WHAT it does)
- [ ] Includes WHEN to use triggers
- [ ] Includes key terms for discoverability
- [ ] Specific, not vague
- [ ] No marketing language
- [ ] No confidence qualifiers ("might", "should", "try")

### Dependencies (if applicable)
- [ ] `dependencies` field present if external packages needed
- [ ] Dependencies include version numbers
- [ ] Dependencies are available/installable

**Issues found:**
```
[SEVERITY] Issue description
[SEVERITY] Issue description
```

---

## 3. Content Quality Check

### File Length
- [ ] Skill.md under 500 lines (optimal)
- [ ] If 500-750 lines, has justification
- [ ] If over 750 lines, needs refactoring

**Line count:** _____ lines

### Core Sections
- [ ] Has "Purpose" section (1-2 paragraphs)
- [ ] Has "When to Use" section with specific scenarios
- [ ] Has workflow or quick start section
- [ ] Has structured step-by-step instructions
- [ ] Has troubleshooting section
- [ ] Has examples section

### Progressive Disclosure
- [ ] Main concepts in Skill.md
- [ ] Detailed docs in REFERENCE.md (if needed)
- [ ] Templates in TEMPLATE.md (if needed)
- [ ] Examples in main file OR EXAMPLES.md
- [ ] Reference files one level deep only
- [ ] No nested references (Skill.md → REF1.md → REF2.md)
- [ ] Large reference files have table of contents

### Content Focus
- [ ] Only includes info Claude doesn't already know
- [ ] No general programming language tutorials
- [ ] No installation instructions for standard tools
- [ ] No time-sensitive information
- [ ] No marketing language
- [ ] No vague confidence language

### Approach Clarity
- [ ] Provides ONE default approach
- [ ] Not too many options (< 4 per task)
- [ ] Alternatives in reference files, not main file
- [ ] Clear guidance on when to use alternatives

### Examples
- [ ] At least 2-3 concrete examples provided
- [ ] Examples show input AND expected output
- [ ] Code examples are complete (not pseudocode)
- [ ] Examples cover common use cases
- [ ] Examples include validation steps
- [ ] Examples use realistic data

### Terminology
- [ ] Consistent terminology throughout
- [ ] Same concept uses same term
- [ ] No switching between synonyms
- [ ] Technical terms used correctly
- [ ] Terms defined before use

**Issues found:**
```
[SEVERITY] Issue description
[SEVERITY] Issue description
```

---

## 4. Instruction Clarity Audit

### Workflow Structure
- [ ] Steps numbered clearly (Step 1, Step 2, etc.)
- [ ] Each step has concrete action
- [ ] Steps in logical sequence
- [ ] Dependencies between steps clear

### Code Examples
- [ ] Code blocks show exact commands
- [ ] Code is complete and runnable
- [ ] Code includes comments where needed
- [ ] Code uses consistent style
- [ ] Code has error handling
- [ ] Forward slashes in paths (not backslashes)

### Expected Outputs
- [ ] Expected outputs documented
- [ ] Output formats specified (JSON, text, etc.)
- [ ] Output examples provided
- [ ] Error outputs documented

### Validation
- [ ] Validation checkpoints provided
- [ ] Validation commands shown
- [ ] Expected validation results documented
- [ ] Error handling guidance provided

### Troubleshooting
- [ ] Common issues documented
- [ ] Solutions specific and actionable
- [ ] Error messages explained
- [ ] Links to reference docs for complex issues

**Issues found:**
```
[SEVERITY] Issue description
[SEVERITY] Issue description
```

---

## 5. Testing Verification

### Test Scenarios
- [ ] Test scenarios created (at least 3)
- [ ] Scenarios cover common use cases
- [ ] Scenarios cover edge cases
- [ ] Scenarios have clear expected results
- [ ] Scenarios are repeatable

### Testing Coverage
- [ ] Tested with fresh Claude instances
- [ ] Tested baseline (without skill) first
- [ ] Tested with skill implementation
- [ ] Measured improvement vs baseline
- [ ] Tested across models (Haiku, Sonnet, Opus)
- [ ] Real-world validation completed
- [ ] Team feedback collected and incorporated

### Code Quality (if applicable)
- [ ] Scripts have explicit error handling
- [ ] Configuration values commented (WHY, not WHAT)
- [ ] Required packages specified with versions
- [ ] Required packages available/installable
- [ ] Validation for critical operations
- [ ] No hardcoded credentials or secrets
- [ ] No temporary/debug code

**Issues found:**
```
[SEVERITY] Issue description
[SEVERITY] Issue description
```

---

## 6. Anti-Pattern Detection

### Too Many Options
- [ ] NOT listing 5+ alternatives without guidance
- [ ] NOT comparing 10+ libraries without recommendation
- [ ] HAS clear default approach
- [ ] Alternatives moved to reference files

### General Knowledge
- [ ] NOT explaining basic programming concepts
- [ ] NOT including installation instructions for standard tools
- [ ] NOT documenting common language features
- [ ] ONLY includes skill-specific information

### Vague Instructions
- [ ] NOT using vague phrases ("do the thing", "check it")
- [ ] NOT missing specific commands
- [ ] HAS concrete, actionable steps
- [ ] HAS explicit validation points

### Nested References
- [ ] NOT deeply nested (Skill.md → REF1 → REF2 → REF3)
- [ ] HAS flat structure (all refs one level from Skill.md)

### Bloated Main File
- [ ] NOT cramming everything into Skill.md
- [ ] HAS progressive disclosure pattern
- [ ] Details extracted to reference files

### Inconsistent Terminology
- [ ] NOT switching terms (endpoint/route/path)
- [ ] HAS consistent vocabulary
- [ ] Terms defined in one place

**Issues found:**
```
[SEVERITY] Issue description
[SEVERITY] Issue description
```

---

## 7. Quality Gates

### Gate 1: Structure ✅
Must pass before proceeding:
- [ ] Directory/file naming correct
- [ ] Frontmatter valid and complete
- [ ] Under 500 lines (or justified if over)

### Gate 2: Description ✅
Must pass before proceeding:
- [ ] Third person
- [ ] Specific capabilities
- [ ] Clear triggers
- [ ] Key terms included

### Gate 3: Content ✅
Must pass before proceeding:
- [ ] Clear purpose and workflows
- [ ] 2-3 concrete examples
- [ ] One default approach
- [ ] Validation steps

### Gate 4: Clarity ✅
Must pass before proceeding:
- [ ] Sequential steps
- [ ] Complete code examples
- [ ] Expected outputs
- [ ] Troubleshooting section

### Gate 5: Testing ✅
Must pass before proceeding:
- [ ] Test scenarios created (3+)
- [ ] Fresh instance testing done
- [ ] Multi-model validation done

---

## Issue Summary

### Blockers (MUST fix before release)
```
1. [Issue description]
2. [Issue description]
```

### Critical (SHOULD fix before release)
```
1. [Issue description]
2. [Issue description]
```

### Major (Should fix soon)
```
1. [Issue description]
2. [Issue description]
```

### Minor (Nice to have)
```
1. [Issue description]
2. [Issue description]
```

---

## Overall Assessment

**Total Issues:**
- Blockers: ___
- Critical: ___
- Major: ___
- Minor: ___

**Recommendation:** [PASS | NEEDS WORK | FAIL]

**Reasoning:**
```
[Why you made this recommendation]
```

**Positive Highlights:**
```
1. [What the skill does well]
2. [What the skill does well]
```

**Next Steps:**
```
1. [Specific actionable recommendation]
2. [Specific actionable recommendation]
```

---

## Pass Criteria

### PASS
- ✅ Zero blockers
- ✅ Zero critical issues
- ✅ < 3 major issues
- ✅ Clear, high-quality skill ready for release

### NEEDS WORK
- ⚠️ Zero blockers
- ⚠️ 1-2 critical issues OR 3+ major issues
- ⚠️ Good foundation but needs refinement before release

### FAIL
- ❌ 1+ blocker issues
- ❌ 3+ critical issues
- ❌ Requires significant rework before re-review

---

## Notes

```
[Any additional observations, context, or recommendations]
```

---

**Reviewer:** _______________
**Date:** _______________
**Version Reviewed:** _______________
