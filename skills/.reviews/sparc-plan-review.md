# Skill Review: sparc-plan

**Reviewer:** Claude Code (Skill Review System)
**Date:** 2025-11-21
**Version Reviewed:** 1.0.0

---

## 1. Structure Validation

### Directory Structure
- [x] Directory name matches skill name
- [ ] Directory name uses gerund form (verb + -ing)
- [x] Directory name lowercase-with-hyphens
- [x] Directory name max 64 characters
- [x] No spaces or underscores in directory name
- [x] No generic names (helper, utils, tool)

**Issues found:**
```
[BLOCKER] Directory name "sparc-plan" does not use gerund form (verb + -ing).
Should be "sparc-planning" to follow naming conventions.
This is a critical naming violation.
```

### File Structure
- [x] Skill.md exists (capital S)
- [N/A] Supporting files use ALL CAPS (REFERENCE.md, TEMPLATE.md)
- [x] No files named skill.md (lowercase s)
- [x] No .txt or other wrong extensions
- [x] No files with underscores
- [N/A] Scripts directory lowercase (if exists)

**Issues found:**
```
[MAJOR] Skill references REFERENCE.md multiple times but file doesn't exist:
  - Line 36: "See REFERENCE.md for detailed phase descriptions"
  - Line 109: "See REFERENCE.md Section 1 for detailed specification template"
  - Line 149: "See REFERENCE.md Section 2 for pseudocode examples"
  - Line 211: "See REFERENCE.md Section 3 for architecture templates"
  - Line 241: "See REFERENCE.md Section 4 for refinement checklist"
  - Line 270: "See REFERENCE.md Section 5 for completion templates"
```

### Organization
- [x] No deeply nested directories
- [x] Supporting files one level deep from Skill.md
- [x] Clear separation of concerns (main vs reference)

**Issues found:**
```
None
```

---

## 2. Frontmatter Audit

### YAML Validity
- [x] Has YAML frontmatter (between --- markers)
- [x] YAML is valid (no syntax errors)
- [x] Frontmatter at top of file

### Required Fields
- [x] `name` field present
- [ ] `name` matches directory name exactly
- [ ] `name` uses gerund form (verb + -ing)
- [x] `name` max 64 characters
- [x] `name` lowercase-with-hyphens only
- [x] `name` not generic (helper, utils, tool)
- [x] `description` field present
- [x] `description` max 1024 characters
- [x] `version` field present
- [x] `version` in SemVer format (X.Y.Z)

**Issues found:**
```
[BLOCKER] Frontmatter name is "SPARC Implementation Planning" but should match directory name pattern.
Should be "sparc-planning" (lowercase-with-hyphens, gerund form).

[CRITICAL] Inconsistency: Directory is "sparc-plan" but frontmatter says "SPARC Implementation Planning".
Neither follows gerund convention. Should be:
  - Directory: sparc-planning
  - Frontmatter name: sparc-planning
```

### Description Quality
- [x] Written in third person (not first/second)
- [x] Includes specific capabilities (WHAT it does)
- [x] Includes WHEN to use triggers
- [x] Includes key terms for discoverability
- [x] Specific, not vague
- [x] No marketing language
- [x] No confidence qualifiers ("might", "should", "try")

### Dependencies (if applicable)
- [N/A] `dependencies` field present if external packages needed
- [N/A] Dependencies include version numbers
- [N/A] Dependencies are available/installable

**Issues found:**
```
None (description quality is excellent despite naming issues)
```

---

## 3. Content Quality Check

### File Length
- [ ] Skill.md under 500 lines (optimal)
- [x] If 500-750 lines, has justification
- [x] If over 750 lines, needs refactoring

**Line count:** 553 lines

**Issues found:**
```
[MINOR] Skill.md is 553 lines (target: <500). Content is comprehensive but:
  - References REFERENCE.md 6 times but file doesn't exist
  - Could extract detailed templates/examples to REFERENCE.md
  - Would improve scannability and adherence to progressive disclosure
```

### Core Sections
- [x] Has "Purpose" section (1-2 paragraphs)
- [x] Has "When to Use" section with specific scenarios
- [x] Has workflow or quick start section
- [x] Has structured step-by-step instructions
- [ ] Has troubleshooting section
- [x] Has examples section

**Issues found:**
```
[MAJOR] Missing troubleshooting section. Should include:
  - What to do when requirements are unclear
  - How to handle incomplete information
  - What if check-history fails
  - How to adapt SPARC for different project sizes (this IS covered but not in troubleshooting format)
```

### Progressive Disclosure
- [x] Main concepts in Skill.md
- [ ] Detailed docs in REFERENCE.md (if needed)
- [N/A] Templates in TEMPLATE.md (if needed)
- [x] Examples in main file OR EXAMPLES.md
- [x] Reference files one level deep only
- [x] No nested references (Skill.md → REF1.md → REF2.md)
- [N/A] Large reference files have table of contents

**Issues found:**
```
[BLOCKER] Skill references REFERENCE.md 6+ times but file doesn't exist. This breaks progressive disclosure:
  - Users click references and find nothing
  - Can't access "detailed phase descriptions"
  - Can't see "specification template"
  - Can't view "pseudocode examples"
  - Missing "architecture templates"
  - Missing "refinement checklist"
  - Missing "completion templates"

This is a critical documentation gap.
```

### Content Focus
- [x] Only includes info Claude doesn't already know
- [x] No general programming language tutorials
- [x] No installation instructions for standard tools
- [x] No time-sensitive information
- [x] No marketing language
- [x] No vague confidence language

### Approach Clarity
- [x] Provides ONE default approach
- [x] Not too many options (< 4 per task)
- [x] Alternatives in reference files, not main file
- [x] Clear guidance on when to use alternatives

### Examples
- [x] At least 2-3 concrete examples provided
- [x] Examples show input AND expected output
- [x] Code examples are complete (not pseudocode)
- [x] Examples cover common use cases
- [x] Examples include validation steps
- [x] Examples use realistic data

### Terminology
- [x] Consistent terminology throughout
- [x] Same concept uses same term
- [x] No switching between synonyms
- [x] Technical terms used correctly
- [x] Terms defined before use

**Issues found:**
```
None
```

---

## 4. Instruction Clarity Audit

### Workflow Structure
- [x] Steps numbered clearly (Step 1, Step 2, etc.)
- [x] Each step has concrete action
- [x] Steps in logical sequence
- [x] Dependencies between steps clear

### Code Examples
- [x] Code blocks show exact commands
- [x] Code is complete and runnable
- [x] Code includes comments where needed
- [x] Code uses consistent style
- [x] Code has error handling
- [x] Forward slashes in paths (not backslashes)

### Expected Outputs
- [x] Expected outputs documented
- [x] Output formats specified (JSON, text, etc.)
- [x] Output examples provided
- [x] Error outputs documented

### Validation
- [x] Validation checkpoints provided
- [x] Validation commands shown
- [x] Expected validation results documented
- [ ] Error handling guidance provided

**Issues found:**
```
[MAJOR] Limited error handling guidance. Should add troubleshooting section for:
  - Incomplete user responses during requirements gathering
  - Missing git history
  - Unable to access Context7
  - Conflicting requirements
```

### Troubleshooting
- [ ] Common issues documented
- [ ] Solutions specific and actionable
- [ ] Error messages explained
- [ ] Links to reference docs for complex issues

**Issues found:**
```
[MAJOR] No dedicated troubleshooting section. Section "When to Skip Planning" helps but doesn't cover:
  - How to handle ambiguous requirements
  - What to do when user can't provide necessary information
  - How to recover from failed check-history
  - Adapting plan when constraints change mid-project
```

---

## 5. Testing Verification

### Test Scenarios
- [ ] Test scenarios created (at least 3)
- [ ] Scenarios cover common use cases
- [ ] Scenarios cover edge cases
- [ ] Scenarios have clear expected results
- [ ] Scenarios are repeatable

**Issues found:**
```
[CRITICAL] No test scenarios documented. Should include:
  - Creating plan for small feature (<8 hours)
  - Creating plan for medium feature (8-40 hours)
  - Creating plan for large feature (>40 hours)
  - Baseline: Claude planning without skill vs with skill
```

### Testing Coverage
- [N/A] Tested with fresh Claude instances
- [N/A] Tested baseline (without skill) first
- [N/A] Tested with skill implementation
- [N/A] Measured improvement vs baseline
- [N/A] Tested across models (Haiku, Sonnet, Opus)
- [N/A] Real-world validation completed
- [N/A] Team feedback collected and incorporated

**Issues found:**
```
[CRITICAL] No testing validation documented. Should show:
  - Baseline: Claude's natural planning ability
  - With skill: Improved structure, completeness, and consistency
  - Multi-model results showing which models benefit most
  - Real examples of plans generated using this skill
```

### Code Quality (if applicable)
- [N/A] Scripts have explicit error handling
- [N/A] Configuration values commented (WHY, not WHAT)
- [N/A] Required packages specified with versions
- [N/A] Required packages available/installable
- [N/A] Validation for critical operations
- [N/A] No hardcoded credentials or secrets
- [N/A] No temporary/debug code

**Issues found:**
```
None (N/A - no scripts)
```

---

## 6. Anti-Pattern Detection

### Too Many Options
- [x] NOT listing 5+ alternatives without guidance
- [x] NOT comparing 10+ libraries without recommendation
- [x] HAS clear default approach
- [x] Alternatives moved to reference files

### General Knowledge
- [x] NOT explaining basic programming concepts
- [x] NOT including installation instructions for standard tools
- [x] NOT documenting common language features
- [x] ONLY includes skill-specific information

### Vague Instructions
- [x] NOT using vague phrases ("do the thing", "check it")
- [x] NOT missing specific commands
- [x] HAS concrete, actionable steps
- [x] HAS explicit validation points

### Nested References
- [x] NOT deeply nested (Skill.md → REF1 → REF2 → REF3)
- [x] HAS flat structure (all refs one level from Skill.md)

### Bloated Main File
- [ ] NOT cramming everything into Skill.md
- [x] HAS progressive disclosure pattern
- [ ] Details extracted to reference files

**Issues found:**
```
[BLOCKER] Claims to use progressive disclosure (references REFERENCE.md 6 times)
but the reference file doesn't exist. This is misleading.

Either:
  1. Create REFERENCE.md with promised content, OR
  2. Remove all references and accept 700+ line main file

Current state is broken.
```

### Inconsistent Terminology
- [x] NOT switching terms (endpoint/route/path)
- [x] HAS consistent vocabulary
- [x] Terms defined in one place

**Issues found:**
```
None
```

---

## 7. Quality Gates

### Gate 1: Structure ✅
Must pass before proceeding:
- [ ] Directory/file naming correct
- [ ] Frontmatter valid and complete
- [x] Under 500 lines (or justified if over)

**Status:** FAIL (critical naming violations)

### Gate 2: Description ✅
Must pass before proceeding:
- [x] Third person
- [x] Specific capabilities
- [x] Clear triggers
- [x] Key terms included

**Status:** PASS

### Gate 3: Content ✅
Must pass before proceeding:
- [x] Clear purpose and workflows
- [x] 2-3 concrete examples
- [x] One default approach
- [ ] Validation steps

**Status:** NEEDS WORK (missing referenced REFERENCE.md)

### Gate 4: Clarity ✅
Must pass before proceeding:
- [x] Sequential steps
- [x] Complete code examples
- [x] Expected outputs
- [ ] Troubleshooting section

**Status:** NEEDS WORK (missing troubleshooting)

### Gate 5: Testing ✅
Must pass before proceeding:
- [ ] Test scenarios created (3+)
- [ ] Fresh instance testing done
- [ ] Multi-model validation done

**Status:** FAIL (no testing documentation)

---

## Issue Summary

### Blockers (MUST fix before release)
```
1. Directory name "sparc-plan" violates gerund convention. Should be "sparc-planning".

2. Frontmatter name "SPARC Implementation Planning" doesn't match directory name pattern.
   Should be "sparc-planning" (lowercase-with-hyphens).

3. REFERENCE.md does not exist but is referenced 6+ times throughout skill:
   - Line 36: "See REFERENCE.md for detailed phase descriptions"
   - Line 109: "See REFERENCE.md Section 1..."
   - Line 149: "See REFERENCE.md Section 2..."
   - Line 211: "See REFERENCE.md Section 3..."
   - Line 241: "See REFERENCE.md Section 4..."
   - Line 270: "See REFERENCE.md Section 5..."

   Must either create REFERENCE.md or remove all references.
```

### Critical (SHOULD fix before release)
```
1. No test scenarios documented. Need at least 3 scenarios showing:
   - Small feature planning
   - Medium feature planning
   - Large feature planning
   - Baseline vs with-skill comparison

2. No testing validation results. Should document:
   - Baseline performance
   - Multi-model testing
   - Real-world examples
```

### Major (Should fix soon)
```
1. Missing troubleshooting section. Add guidance for:
   - Incomplete requirements from user
   - Failed check-history invocation
   - Ambiguous or conflicting requirements
   - Adapting plans when constraints change

2. No dedicated error handling section for common workflow failures.

3. File length 553 lines suggests REFERENCE.md was planned but never created.
   Either create it or consolidate content properly.
```

### Minor (Nice to have)
```
1. Consider adding TEMPLATE.md with starter templates for:
   - specification.md
   - architecture.md
   - task-list.md
   - security-plan.md
   - performance-plan.md

2. Section "Adapting SPARC for Different Project Sizes" could be expanded
   with concrete examples at each size tier.
```

---

## Overall Assessment

**Total Issues:**
- Blockers: 3
- Critical: 2
- Major: 3
- Minor: 2

**Recommendation:** FAIL

**Reasoning:**
```
This skill has excellent content quality and provides comprehensive guidance for
implementation planning. The SPARC framework is well-explained with detailed
examples and concrete steps.

However, it has THREE BLOCKER issues that prevent release:

1. Naming convention violations (directory and frontmatter don't match pattern)
2. References non-existent REFERENCE.md file 6+ times (broken progressive disclosure)
3. No testing validation (fails Gate 5)

The missing REFERENCE.md is particularly problematic because:
- Users are directed to it throughout the skill
- It promises crucial templates and checklists
- Without it, users hit dead ends
- This breaks the progressive disclosure pattern

The naming issue is also critical because it violates fundamental conventions
that all skills must follow.

These are not minor issues - they're fundamental structural problems that make
the skill incomplete and non-functional in key areas.

Fix the blockers, add test scenarios, and create the missing REFERENCE.md to
move this to NEEDS WORK or PASS status.
```

**Positive Highlights:**
```
1. Excellent 12-step workflow that's comprehensive and actionable
2. Outstanding examples throughout (task lists, dependency graphs, security plans)
3. Clear phase-by-phase breakdown of SPARC methodology
4. Great guidance on when to use vs when to skip planning
5. Comprehensive Phase 3 architecture section with concrete patterns
6. Well-structured completion criteria and checklists
7. Good integration guidance showing how skill relates to other skills
8. Practical sizing guidance (small/medium/large features)
```

**Next Steps:**
```
PRIORITY 1 - BLOCKERS:
1. Rename directory from "sparc-plan" to "sparc-planning"
2. Update frontmatter name to "sparc-planning"
3. Create REFERENCE.md with all promised content:
   - Section 1: Specification template
   - Section 2: Pseudocode examples
   - Section 3: Architecture templates
   - Section 4: Refinement checklist
   - Section 5: Completion templates
   OR remove all REFERENCE.md references and keep content in main file

PRIORITY 2 - CRITICAL:
4. Create test-scenarios.md with 3+ concrete scenarios
5. Document testing validation results

PRIORITY 3 - MAJOR:
6. Add troubleshooting section
7. Add error handling guidance
8. Consider creating TEMPLATE.md for output artifacts
```

---

## Notes

```
This skill is close to being excellent but has critical structural issues. The content
demonstrates deep understanding of implementation planning and provides valuable guidance.

The missing REFERENCE.md is the most severe issue - it's referenced throughout as the
place to find detailed templates, but doesn't exist. This suggests the skill was either:
  1. Released before completion, OR
  2. Originally had REFERENCE.md but it was lost/deleted

Given the file size (553 lines), it's clear that REFERENCE.md was planned for progressive
disclosure but never created. This is a textbook example of why skills should follow their
own testing guidance.

The naming issue (sparc-plan vs sparc-planning) shows inconsistency with established
conventions. This is an easy fix but critical for consistency across the skill ecosystem.

Priority: Fix the naming and create REFERENCE.md ASAP. The skill is effectively broken
without these fixes.
```
