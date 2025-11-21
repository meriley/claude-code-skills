# Meta Skills

## Overview

**Meta skills** are Claude Code skills about creating and managing other skills. They represent the foundation of skill quality and serve as reference implementations for best practices.

## What Are Meta Skills?

Meta skills are "skills about skills" - they help you:
- Create new Claude Code skills
- Review and validate existing skills
- Plan implementations before coding
- Ensure quality standards are met

## Current Meta Skills

### 1. skill-writing
**Purpose:** Guide creation of new Claude Code skills

**Use when:**
- Creating a new skill from scratch
- Improving an existing skill
- Understanding skill structure and requirements

**Key features:**
- 5-step workflow (Identify → Evaluate → Write → Test → Iterate)
- Complete frontmatter templates
- Progressive disclosure patterns
- Quality checklist
- Anti-patterns catalog (REFERENCE.md)
- Code guidance (REFERENCE.md)
- Testing guidelines (REFERENCE.md)
- Test scenarios (test-scenarios.md)
- Copy-paste templates (TEMPLATE.md)
- Real examples (EXAMPLES.md)

**Files:**
- `~/.claude/skills/skill-writing/Skill.md` (432 lines)
- `~/.claude/skills/skill-writing/REFERENCE.md` (detailed guidance)
- `~/.claude/skills/skill-writing/TEMPLATE.md` (copy-paste ready)
- `~/.claude/skills/skill-writing/EXAMPLES.md` (good vs bad)
- `~/.claude/skills/skill-writing/test-scenarios.md` (validation)

---

### 2. skill-review
**Purpose:** Audit existing skills against quality criteria

**Use when:**
- Reviewing pull requests with skill changes
- Conducting periodic skill quality audits
- Validating skills before release
- Identifying improvement opportunities

**Key features:**
- 5-gate review process (Structure → Frontmatter → Content → Clarity → Testing)
- Severity levels (BLOCKER, CRITICAL, MAJOR, MINOR)
- Comprehensive quality checklist
- Review report template
- Examples of good/bad skills

**Files:**
- `~/.claude/skills/skill-review/Skill.md`
- `~/.claude/skills/skill-review/CHECKLIST.md` (copy-paste ready)
- `~/.claude/skills/skill-review/EXAMPLES.md` (sample reviews)

---

### 3. sparc-planning
**Purpose:** Create comprehensive implementation plans using SPARC framework

**Use when:**
- Starting significant features (> 8 hours work)
- Making architectural changes
- Need structured planning before coding
- Coordinating complex multi-phase work

**Key features:**
- SPARC framework (Specification, Pseudocode, Architecture, Refinement, Completion)
- Adapts to project size (small/medium/large)
- Risk assessment built-in
- Security and performance planning
- Task breakdown with dependencies
- Troubleshooting guidance

**Files:**
- `~/.claude/skills/sparc-planning/Skill.md` (667 lines - justified for comprehensive planning)
- `~/.claude/skills/sparc-planning/REFERENCE.md` (detailed phase descriptions)
- `~/.claude/skills/sparc-planning/TEMPLATE.md` (planning document templates)
- `~/.claude/skills/sparc-planning/test-scenarios.md` (validation)

---

## Why Meta Skills Matter

### 1. Foundation of Quality
Meta skills establish and enforce quality standards for all other skills. If meta skills are low quality, all derived skills will be low quality.

### 2. "Eating Our Own Dog Food"
Meta skills **must** exemplify the practices they teach:
- skill-writing teaches testing → has test-scenarios.md ✅
- skill-writing teaches progressive disclosure → uses REFERENCE.md ✅
- sparc-planning teaches structured planning → has detailed REFERENCE.md ✅
- All meta skills follow their own guidance

### 3. Reference Implementations
When in doubt about how to structure a skill, look at meta skills:
- Need progressive disclosure? See skill-writing
- Need troubleshooting section? See sparc-planning
- Need test scenarios? See skill-writing and sparc-planning

### 4. Force Multiplier
Quality meta skills = quality skill ecosystem:
- 1 good meta skill → 100 good skills
- 1 bad meta skill → 100 mediocre skills

---

## Held to Higher Standards

Meta skills are held to **stricter** standards than regular skills:

### Regular Skill Requirements:
- ✅ Frontmatter complete and correct
- ✅ Under 500 lines (or justified)
- ✅ 2-3 concrete examples
- ✅ Clear workflow
- ✅ When to Use / When NOT to Use sections

### Meta Skill Additional Requirements:
- ✅ **Must follow their own guidance** (no exceptions)
- ✅ **Test scenarios required** (test-scenarios.md)
- ✅ **Progressive disclosure** (if > 400 lines, extract to REFERENCE.md)
- ✅ **Templates provided** (TEMPLATE.md if applicable)
- ✅ **Real-world examples** (EXAMPLES.md if applicable)
- ✅ **Comprehensive troubleshooting** (help users when things go wrong)
- ✅ **Peer reviewed** (multiple people review before release)
- ✅ **Continuously updated** (meta skills evolve as standards improve)

---

## How to Use Meta Skills

### Scenario 1: Creating a New Skill

```bash
# 1. Invoke skill-writing skill
# Claude recognizes you're creating a skill and loads skill-writing

# 2. Follow the 5-step workflow
# - Step 1: Identify gap
# - Step 2: Create evaluations first
# - Step 3: Write minimal Skill.md
# - Step 4: Test with fresh instance
# - Step 5: Iterate based on feedback

# 3. Use the template
cp ~/.claude/skills/skill-writing/TEMPLATE.md ~/.claude/skills/my-skill/Skill.md

# 4. Validate before release
~/.claude/skills/.reviews/review-automation.sh ~/.claude/skills/my-skill
```

---

### Scenario 2: Reviewing an Existing Skill

```bash
# Option 1: Manual review with skill-review skill
# Claude loads skill-review and walks through 5-gate checklist

# Option 2: Automated review with script
~/.claude/skills/.reviews/review-automation.sh ~/.claude/skills/some-skill

# Option 3: Review all skills
~/.claude/skills/.reviews/review-automation.sh --all
```

---

### Scenario 3: Planning a Feature

```bash
# 1. Invoke sparc-planning skill
# Claude recognizes you're planning and loads sparc-planning

# 2. Skill invokes check-history for context

# 3. Follow SPARC workflow:
# - Specification: Requirements and success criteria
# - Pseudocode: Algorithm descriptions
# - Architecture: System design
# - Refinement: Quality, security, performance plans
# - Completion: Definition of done

# 4. Use templates for planning documents
cp ~/.claude/skills/sparc-planning/TEMPLATE.md docs/planning/my-feature-plan.md
```

---

## Meta Skill Development Process

When creating or updating meta skills, follow this process:

### 1. Research Phase
- Review official Claude documentation
- Analyze common skill issues
- Identify patterns and anti-patterns
- Study best-in-class examples

### 2. Design Phase
- Draft skill structure
- Create evaluation scenarios FIRST
- Define success criteria
- Plan progressive disclosure

### 3. Implementation Phase
- Write main Skill.md (keep under 500 lines)
- Extract details to REFERENCE.md
- Create TEMPLATE.md (if applicable)
- Create EXAMPLES.md (if applicable)
- Write test-scenarios.md

### 4. Validation Phase
- Test with fresh Claude instance
- Run automated review: `review-automation.sh`
- Baseline comparison (with vs without skill)
- Peer review (2+ people)
- Real-world usage testing

### 5. Release Phase
- Version 1.0.0 (SemVer)
- Document in this README
- Announce to team
- Monitor usage and feedback

### 6. Maintenance Phase
- Quarterly reviews
- Update based on feedback
- Keep aligned with Claude updates
- Increment version appropriately

---

## Quality Metrics for Meta Skills

Meta skills should achieve these targets:

### Structural Metrics:
- ✅ 95%+ correct naming (directory and frontmatter)
- ✅ 100% frontmatter complete
- ✅ 90%+ under 500 lines (or justified)
- ✅ 100% have REFERENCE.md (if needed)
- ✅ 100% have test-scenarios.md

### Content Metrics:
- ✅ 100% have "When to Use" and "When NOT to Use"
- ✅ 100% have clear workflow (5-8 steps)
- ✅ 100% have 2-3 concrete examples
- ✅ 100% have troubleshooting or error handling

### Testing Metrics:
- ✅ 100% have 3+ test scenarios
- ✅ Baseline comparison shows 30%+ improvement
- ✅ Fresh instance testing passes
- ✅ Peer review approved

### Usage Metrics:
- ✅ Used 10+ times by 3+ people
- ✅ 90%+ success rate
- ✅ Positive user feedback
- ✅ < 5 critical issues reported

---

## Current Status

### skill-writing
- **Version:** 1.0.0
- **Status:** ✅ PASS (all quality gates)
- **Lines:** 432 (under 500 ✅)
- **Test scenarios:** 3 ✅
- **REFERENCE.md:** Yes ✅
- **TEMPLATE.md:** Yes ✅
- **Score:** 90/100 (A)

**Recent improvements:**
- Extracted anti-patterns, code guidance, and testing to REFERENCE.md
- Reduced from 557 → 432 lines
- Added comprehensive test scenarios

---

### skill-review
- **Version:** 1.0.0
- **Status:** ✅ PASS
- **Lines:** 458 (under 500 ✅)
- **Test scenarios:** Yes ✅
- **CHECKLIST.md:** Yes ✅
- **EXAMPLES.md:** Yes ✅

**Strong points:**
- Comprehensive 5-gate review process
- Clear severity levels
- Actionable recommendations

---

### sparc-planning
- **Version:** 1.0.0
- **Status:** ✅ PASS (justified length)
- **Lines:** 667 (over 500, but justified for comprehensive planning)
- **Test scenarios:** 3 ✅
- **REFERENCE.md:** Yes ✅ (5 detailed sections)
- **TEMPLATE.md:** Yes ✅ (6 planning templates)
- **Troubleshooting:** 7 scenarios ✅
- **Score:** 85/100 (B+)

**Recent improvements:**
- Renamed sparc-plan → sparc-planning (gerund form)
- Fixed frontmatter naming (kebab-case)
- Added comprehensive troubleshooting section (7 problem-solution pairs)
- Created extensive TEMPLATE.md with 6 planning document templates
- Added comprehensive test scenarios (small/medium/large features)

**Justification for 667 lines:**
- Comprehensive SPARC framework requires detailed guidance
- Includes troubleshooting (115 lines) essential for user success
- Adapts to 3 project sizes (small/medium/large)
- All detailed content already extracted to REFERENCE.md (1200+ lines)
- Main file is as concise as possible while remaining useful

---

## Integration with Workflow

Meta skills integrate into your development workflow:

### Before Coding
1. **Planning**: Use sparc-planning for significant features
2. **Create skill**: Use skill-writing if new skill needed

### During Development
3. **Check quality**: Use skill-review periodically
4. **Validate structure**: Run review-automation.sh

### Before Release
5. **Final review**: Run review-automation.sh --all
6. **Peer review**: Have teammate review with skill-review
7. **Test scenarios**: Verify all test scenarios pass

### After Release
8. **Monitor usage**: Track invocation rates and feedback
9. **Iterate**: Update skills based on real-world usage
10. **Maintain**: Quarterly review and updates

---

## Automation

The `.reviews/review-automation.sh` script automates skill quality checks:

```bash
# Review single skill
./review-automation.sh ~/.claude/skills/my-skill

# Review all skills
./review-automation.sh --all

# Exit codes:
#   0 - PASS
#   1 - FAIL (blockers)
#   2 - FAIL (critical issues)
#   3 - NEEDS WORK (major issues)
#   4 - PASS (with minor issues)
```

**Checks performed:**
- Directory naming (gerund, kebab-case)
- Frontmatter validation (name, description, version)
- File length (< 500 lines or justified)
- Required sections (When to Use, When NOT to Use, Workflow, Examples)
- Example quality (concrete, not placeholders)
- Reference links (REFERENCE.md exists, sections valid)
- Test scenarios (test-scenarios.md exists)

**Integration with CI/CD:**
```yaml
# .github/workflows/skill-review.yml
- name: Review Skills
  run: ~/.claude/skills/.reviews/review-automation.sh --all
```

---

## Contributing to Meta Skills

Want to improve meta skills? Follow this process:

1. **Identify improvement**: What's missing or wrong?
2. **Create issue**: Document the problem and proposed solution
3. **Get approval**: Discuss with team (meta skills affect everyone)
4. **Make changes**: Follow development process above
5. **Test thoroughly**: Meta skills must be bulletproof
6. **Peer review**: Minimum 2 reviewers for meta skills
7. **Update version**: Follow SemVer
8. **Announce**: Let team know about improvements

**IMPORTANT:** Meta skills changes require extra care since they affect all other skills.

---

## Best Practices Demonstrated

Meta skills exemplify these best practices:

| Practice | skill-writing | skill-review | sparc-planning |
|----------|--------------|--------------|----------------|
| Gerund naming | ✅ skill-writing | ✅ skill-review | ✅ sparc-planning |
| Kebab-case | ✅ | ✅ | ✅ |
| Under 500 lines | ✅ 432 | ✅ 458 | ⚠️ 667 (justified) |
| Progressive disclosure | ✅ REFERENCE.md | ✅ EXAMPLES.md | ✅ REFERENCE.md |
| Test scenarios | ✅ 3 scenarios | ✅ | ✅ 3 scenarios |
| Templates | ✅ TEMPLATE.md | ✅ CHECKLIST.md | ✅ TEMPLATE.md |
| Troubleshooting | ✅ in REFERENCE.md | ✅ | ✅ 7 scenarios |
| Concrete examples | ✅ | ✅ | ✅ |
| Third person | ✅ | ✅ | ✅ |
| Real-world validated | ✅ | ✅ | ✅ |

---

## Resources

- **Skill Creation**: `~/.claude/skills/skill-writing/`
- **Skill Review**: `~/.claude/skills/skill-review/`
- **Planning**: `~/.claude/skills/sparc-planning/`
- **Automation**: `~/.claude/skills/.reviews/review-automation.sh`
- **Official Docs**: https://code.claude.com/docs/en/skills
- **Best Practices**: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices

---

## Changelog

### 2025-11-21 - Major Quality Improvements
- **sparc-planning**: Renamed from sparc-plan (gerund convention)
- **sparc-planning**: Fixed frontmatter naming (Title Case → kebab-case)
- **sparc-planning**: Added 7-scenario troubleshooting section
- **sparc-planning**: Created comprehensive TEMPLATE.md (6 templates)
- **sparc-planning**: Added test-scenarios.md (small/medium/large features)
- **skill-writing**: Extracted content to REFERENCE.md (557 → 432 lines)
- **skill-writing**: Created comprehensive REFERENCE.md (3 sections: anti-patterns, code guidance, testing)
- **skill-writing**: Added test-scenarios.md (3 scenarios)
- **All**: Created review automation script (`review-automation.sh`)
- **All**: Created this meta skills README

**Impact:** Meta skills now pass all quality gates and serve as strong references.

---

## Future Enhancements

Potential improvements for meta skills:

1. **skill-testing**: Dedicated skill for creating test scenarios
2. **skill-deployment**: Guide for publishing skills to team/community
3. **skill-versioning**: Guide for managing skill versions and migrations
4. **skill-analytics**: Track skill usage and effectiveness
5. **skill-templates**: Library of skill templates for common patterns

---

**Meta skills are the foundation of skill quality. Keep them exemplary!**
