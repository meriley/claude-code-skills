# Skill Template

Use this template as a starting point for creating new Claude Code skills. Copy this template, replace placeholders with your content, and remove instructional comments.

---

```markdown
---
name: [verb]-[noun]-ing                  # Example: processing-pdfs, analyzing-spreadsheets
description: [What it does] [When to use]. Use when [key triggers].  # Max 1024 chars, third person
version: 1.0.0                           # SemVer format
dependencies: package>=version           # Optional: list required packages
---

# [Skill Title]

## Purpose
[One clear sentence describing what this skill accomplishes]

## When to Use This Skill
- [Specific scenario 1 that triggers this skill]
- [Specific scenario 2 that triggers this skill]
- [Specific scenario 3 that triggers this skill]

## Quick Start

### Step 1: [First Action]
```bash
# Concrete command or code example
```

[Brief explanation if needed]

### Step 2: [Second Action]
```[language]
# Code example showing the action
```

**Expected output:**
```
[What should happen]
```

### Step 3: [Third Action]
[Instructions]

## Core Workflow

### [Workflow Name]

**Step 1: [Action]**
```[language]
[Concrete code or command]
```

**Step 2: [Action]**
[Instructions with any necessary context]

**Step 3: [Validation]**
- [ ] [Check 1]
- [ ] [Check 2]
- [ ] [Check 3]

## Examples

### Example 1: [Common Use Case]
**Input:**
```
[Sample input]
```

**Output:**
```
[Expected output with correct format]
```

**Explanation:**
[Brief note about what happened]

### Example 2: [Edge Case or Alternative]
**Input:**
```
[Sample input]
```

**Output:**
```
[Expected output]
```

## Common Patterns

### [Pattern Name]
```[language]
# Code demonstrating the pattern
```

**When to use:**
- [Scenario 1]
- [Scenario 2]

### [Another Pattern]
```[language]
# Code example
```

## Error Handling

### [Error Type 1]
**Symptom:**
```
[Error message]
```

**Solution:**
```[language]
# Fix code
```

### [Error Type 2]
**Symptom:** [Description]

**Solution:** [Steps to resolve]

## Validation

### Output Validation
- [ ] [Required field 1 present]
- [ ] [Required field 2 correct format]
- [ ] [No errors in logs]
- [ ] [Results match expectations]

### Testing Commands
```bash
# Command to verify functionality
```

## Advanced Usage

### [Advanced Topic]
[Description]

```[language]
# Advanced code example
```

For complete details, see REFERENCE.md

## Common Issues

### Issue: [Problem Description]
**Solution:** [How to fix]

### Issue: [Another Problem]
**Solution:** [Resolution steps]

## Resources

- [Link to external documentation if relevant]
- [Link to related skills if applicable]
- See REFERENCE.md for detailed API documentation (if applicable)
```

---

## Template Notes

### Filling Out the Template

**Frontmatter:**
- `name`: Use gerund form (verb + -ing), lowercase-with-hyphens, max 64 chars
- `description`: Third person, include WHAT and WHEN, max 1024 chars
- `version`: Start with 1.0.0, follow SemVer
- `dependencies`: Only if you use specific packages

**Purpose:**
- One sentence, clear and direct
- What problem does this solve?

**When to Use:**
- 3-5 specific scenarios
- Use concrete triggers that help Claude decide when to invoke

**Examples:**
- Minimum 2-3 examples required
- Show input AND output
- Cover common case + edge case

**Workflow:**
- Sequential steps (Step 1, Step 2, etc.)
- Include validation checkpoints
- Show expected outputs

**Keep Under 500 Lines:**
- If content exceeds 500 lines, move details to REFERENCE.md
- Keep core workflow in Skill.md
- Use progressive disclosure

### File Structure

If your skill needs additional files:

```
my-skill/
├── Skill.md          # Main file (this template) - keep under 500 lines
├── REFERENCE.md      # Optional: Detailed API docs, advanced topics
├── TEMPLATE.md       # Optional: Output format templates
├── EXAMPLES.md       # Optional: More examples
└── scripts/          # Optional: Helper scripts
    └── helper.py
```

### What to Include vs Exclude

**Include:**
- ✅ Domain-specific knowledge Claude doesn't have
- ✅ Exact procedures for error-prone tasks
- ✅ Output format templates
- ✅ Concrete examples (2-3 minimum)
- ✅ Validation steps

**Exclude:**
- ❌ General programming knowledge (Claude knows this)
- ❌ Common library usage (Claude can figure this out)
- ❌ Obvious information
- ❌ Too many options (pick one default)
- ❌ Time-sensitive information

### Testing Your Skill

1. **Create evaluations** - 3+ test scenarios
2. **Test baseline** - Can Claude do this without the skill?
3. **Write minimal skill** - Just enough to pass evaluations
4. **Fresh instance test** - New Claude session
5. **Observe usage** - What files does Claude access?
6. **Iterate** - Add only what's missing

### Quality Checks

Before using your skill:
- [ ] Description is specific and in third person
- [ ] Under 500 lines (or uses progressive disclosure)
- [ ] 2-3 concrete examples included
- [ ] Sequential workflow documented
- [ ] Tested with fresh Claude instance
- [ ] No vague language or too many options

---

## Quick Start

```bash
# 1. Copy this template
cp ~/.claude/skills/skill-writing/TEMPLATE.md ~/.claude/skills/my-skill/Skill.md

# 2. Edit the file
# - Replace all [placeholders]
# - Fill in your content
# - Remove instructional comments
# - Keep under 500 lines

# 3. Test
# - Open fresh Claude Code session
# - Try task that should trigger skill
# - Observe and iterate
```
