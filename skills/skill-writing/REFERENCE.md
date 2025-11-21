---
title: Skill Writing Reference Guide
---

# Skill Writing Detailed Reference

This reference provides detailed anti-patterns, code guidance, and testing guidelines extracted from the main Skill.md to keep it under 500 lines.

## Table of Contents

1. [Common Pitfalls to Avoid](#section-1-common-pitfalls-to-avoid)
2. [Code and Script Guidance](#section-2-code-and-script-guidance)
3. [Testing Guidelines](#section-3-testing-guidelines)

---

## Section 1: Common Pitfalls to Avoid

### ❌ Offering Too Many Options

```markdown
# ❌ Bad - Overwhelming
"You can use pypdf, pdfplumber, PyMuPDF, pdf2image, camelot, tabula,
or pytesseract depending on your needs."

# ✅ Good - One default, alternatives for exceptions
"Use pdfplumber for text and tables. For scanned PDFs, use pdf2image
with pytesseract for OCR."
```

**Why this matters:**
- Too many options paralyze decision-making
- Claude spends time evaluating options instead of solving the problem
- Increases skill file size unnecessarily
- Makes maintenance harder (need to update multiple approaches)

**Best practice:**
- Pick ONE recommended approach
- Mention alternatives only for specific exceptions
- Justify why the default was chosen

---

### ❌ Vague Descriptions

```markdown
# ❌ Bad
"Helps with documents and files"

# ✅ Good
"Extract text, tables, and forms from PDF files including scanned documents"
```

**Why this matters:**
- Vague descriptions don't help Claude decide when to invoke skill
- Wastes tokens loading unnecessary skills
- Reduces user confidence in skill quality

**Best practice:**
- Be specific about WHAT the skill does
- Include key terms that trigger usage ("PDF", "extract", "tables")
- Mention formats/types handled

---

### ❌ Deeply Nested References

```markdown
# ❌ Bad - Three levels deep
Skill.md → REFERENCE.md → ADVANCED.md → EXAMPLES.md

# ✅ Good - One level deep
Skill.md → REFERENCE.md
Skill.md → EXAMPLES.md
```

**Why this matters:**
- Deep nesting makes navigation confusing
- Claude may not follow chains of references
- Harder to maintain
- Users get lost

**Best practice:**
- Maximum one level of reference from Skill.md
- Use flat structure: Skill.md references REFERENCE.md and EXAMPLES.md directly
- Never chain references (REFERENCE.md shouldn't reference other files)

---

### ❌ Inconsistent Terminology

```markdown
# ❌ Bad - Multiple terms for same concept
"Use the API endpoint to call the URL route at this path..."

# ✅ Good - Consistent terminology
"Use the API endpoint... Call the same endpoint... This endpoint returns..."
```

**Why this matters:**
- Confusion about whether "endpoint", "route", and "path" are different things
- Makes skill harder to understand
- Reduces trust in skill quality

**Best practice:**
- Choose ONE term for each concept
- Define term on first use if not obvious
- Use term consistently throughout skill
- Create a glossary if many domain-specific terms

---

### ❌ First/Second Person

```markdown
# ❌ Bad
"I can help you process PDFs"
"You should use this when..."

# ✅ Good
"Processes PDFs..."
"Use when working with PDFs"
```

**Why this matters:**
- Skills are reference documentation, not conversation
- Third person is more professional and objective
- Matches Claude's system prompt style
- Required by skill format guidelines

**Best practice:**
- Frontmatter description: Third person ("Processes...", "Extracts...", "Generates...")
- Body content: Imperative or third person ("Use when...", "This skill handles...")
- Never use "I", "me", "you", "we"

---

### ❌ Too Much Context

```markdown
# ❌ Bad - Claude already knows this
"Python is a programming language created in 1991..."

# ✅ Good - Only skill-specific info
"Use pdfplumber's extract_text() method with layout=True"
```

**Why this matters:**
- Wastes tokens on information Claude already knows
- Dilutes important skill-specific information
- Makes skill longer and harder to scan
- Reduces effectiveness

**Best practice:**
- Assume Claude knows: programming languages, common libraries, basic concepts
- Include only: domain-specific knowledge, non-obvious library usage, exact procedures
- Test: Would an experienced developer find this info useful?

---

### ❌ Missing "When NOT to Use"

```markdown
# ❌ Bad - Only positive triggers

## When to Use
- Processing PDF files
- Extracting text from documents

# ✅ Good - Clear boundaries

## When to Use
- Processing PDF files
- Extracting text and tables

## When NOT to Use
- Converting PDFs to other formats (use pdf-converting skill)
- Editing PDF content (use pdf-editing skill)
- Simple file reading (Claude can do this natively)
```

**Why this matters:**
- Prevents skill overuse (loading unnecessary context)
- Clarifies boundaries with other skills
- Helps Claude make better decisions about when to invoke
- Reduces token waste

**Best practice:**
- Always include "When NOT to Use" section
- List scenarios where OTHER skills are better
- List scenarios where skill isn't needed at all
- Mention simpler alternatives

---

### ❌ No Concrete Examples

```markdown
# ❌ Bad - Only abstract descriptions
"Extract text from PDFs using the appropriate library"

# ✅ Good - Concrete example with actual code
```python
import pdfplumber

with pdfplumber.open('invoice.pdf') as pdf:
    text = pdf.pages[0].extract_text()
    print(text)  # Output: "Invoice #12345\nAmount: $100.00"
```
```

**Why this matters:**
- Abstract descriptions are ambiguous
- Claude learns best from concrete examples
- Examples show exact API usage
- Users can copy-paste and adapt

**Best practice:**
- Minimum 2-3 concrete examples
- Show input + code + expected output
- Use realistic data (not "foo", "bar")
- Cover common case + one edge case

---

### ❌ Placeholder Values in Examples

```markdown
# ❌ Bad
```python
result = process_file('your_file_here.pdf')
config = {
    'setting1': 'value1',  # Replace with your value
    'setting2': 'value2'   # Configure as needed
}
```

# ✅ Good
```python
result = process_file('invoice.pdf')
config = {
    'dpi': 300,           # Required for OCR accuracy
    'timeout': 30,        # AWS Lambda limit
    'max_pages': 100      # Prevent memory issues
}
```
```

**Why this matters:**
- Placeholders require users to guess correct values
- "your_file_here" provides no useful information
- "Configure as needed" is vague and unhelpful
- Real values show appropriate ranges and formats

**Best practice:**
- Use realistic example values
- Show actual file names, not placeholders
- Include comments explaining WHY values are chosen
- Show ranges/limits where applicable

---

## Section 2: Code and Script Guidance

### Error Handling

```python
# ✅ Good - Explicit error handling
try:
    with pdfplumber.open(filename) as pdf:
        text = pdf.pages[0].extract_text()
except FileNotFoundError:
    print(f"Error: {filename} not found")
    return None
except Exception as e:
    print(f"Error processing PDF: {str(e)}")
    return None
```

**Why this matters:**
- File operations frequently fail (missing files, permissions, corruption)
- Generic exceptions hide specific problems
- Users need actionable error messages
- Silent failures are confusing

**Best practice:**
- Catch specific exceptions first (FileNotFoundError, PermissionError)
- Catch generic Exception as fallback
- Provide helpful error messages (include filename, actual error)
- Return None or raise custom exception (don't let it crash)
- Log errors for debugging

### Configuration Comments

```python
# ✅ Good - Explain WHY, not WHAT
MAX_PAGES = 100  # Prevent memory issues with large PDFs
TIMEOUT = 30     # AWS Lambda has 30s limit
DPI = 300        # Required for accurate OCR on scanned docs

# ❌ Bad - Obvious/unhelpful
MAX_PAGES = 100  # Maximum number of pages
```

**Why this matters:**
- "Maximum number of pages" is obvious from the variable name
- WHY 100? Why not 50 or 1000?
- Justifications help users decide if they need to change values
- Context prevents cargo-culting

**Best practice:**
- Explain WHY this value was chosen
- Mention constraints (memory, time, external limits)
- Reference requirements (OCR accuracy, API limits)
- Avoid stating the obvious

### Path Conventions

```python
# ✅ Good - Forward slashes (works everywhere)
import sys
sys.path.append('scripts/helpers.py')

# ❌ Bad - Backslashes (breaks on Unix)
sys.path.append('scripts\\helpers.py')
```

**Why this matters:**
- Backslashes only work on Windows
- Forward slashes work on all platforms (Windows, macOS, Linux)
- Skills should be cross-platform by default
- Raw strings don't solve this (still platform-specific)

**Best practice:**
- ALWAYS use forward slashes (/) in file paths
- Even on Windows, forward slashes work fine
- Use `pathlib.Path` for complex path manipulation
- Never use backslashes unless Windows-specific code

### Input Validation

```python
# ✅ Good - Validate inputs
def extract_text(filename, max_pages=None):
    if not filename:
        raise ValueError("filename cannot be empty")

    if not os.path.exists(filename):
        raise FileNotFoundError(f"File not found: {filename}")

    if max_pages is not None and max_pages < 1:
        raise ValueError("max_pages must be >= 1")

    # Proceed with extraction
```

**Why this matters:**
- Fail fast with clear errors
- Better error messages than cryptic library errors
- Prevents wasted processing time
- Easier to debug

**Best practice:**
- Validate required parameters are not None/empty
- Check file existence before processing
- Validate ranges and formats
- Raise descriptive exceptions

### Resource Cleanup

```python
# ✅ Good - Ensure cleanup
with pdfplumber.open(filename) as pdf:
    text = pdf.pages[0].extract_text()
# File automatically closed

# ❌ Bad - Manual cleanup
pdf = pdfplumber.open(filename)
text = pdf.pages[0].extract_text()
pdf.close()  # Easy to forget, especially if error occurs
```

**Why this matters:**
- File handles leak if not closed
- Memory leaks accumulate
- Context managers guarantee cleanup even on exceptions
- More Pythonic and idiomatic

**Best practice:**
- Always use context managers (`with` statement) for files
- Apply to: file I/O, database connections, network sockets
- If library doesn't support context manager, use try/finally
- Never rely on manual cleanup

---

## Section 3: Testing Guidelines

### Create Evaluations First

Before writing the skill documentation, create 3+ test scenarios that validate the skill works as intended.

**Example: PDF processing skill evaluations**

```python
# evaluations/test_pdf_processing.py

def test_text_extraction():
    """Test basic text extraction from PDF"""
    result = extract_text('test_files/invoice.pdf')
    assert 'Invoice Number' in result
    assert result['amount'] == '$100.00'

def test_table_extraction():
    """Test table extraction"""
    result = extract_table('test_files/data.pdf')
    assert len(result) == 10
    assert 'revenue' in result[0]

def test_scanned_pdf():
    """Test OCR on scanned documents"""
    result = extract_text('test_files/scanned.pdf', ocr=True)
    assert result is not None
    assert len(result) > 0
```

**Why evaluations first:**
- Clarifies what success looks like before writing docs
- Prevents scope creep (skill does exactly what tests validate)
- Ensures skill actually works
- Baseline for future improvements

**Test file requirements:**
- Use REAL test files (not mock/fake data)
- Cover common case + edge cases
- Include failure scenarios (corrupted file, missing file)
- Keep test files small (commit to repo)

---

### Test Across Models

Skills should work consistently across Claude models (Haiku, Sonnet, Opus).

**Testing matrix example:**

```markdown
## Testing Matrix

| Scenario | Haiku | Sonnet | Opus |
|----------|-------|--------|------|
| Simple text | ✅ Pass | ✅ Pass | ✅ Pass |
| Complex table | ❌ Fail | ✅ Pass | ✅ Pass |
| Scanned doc | ❌ Fail | ⚠️  Partial | ✅ Pass |

**Findings:**
- Haiku needs more explicit table instructions
- Sonnet handles most cases well
- Opus handles all scenarios
```

**Why test across models:**
- Users have different model access
- Haiku is faster/cheaper but may need more guidance
- Sonnet is balanced (most common use)
- Opus is most capable but more expensive

**Expectations by model:**
- **Haiku**: Follow templates closely, may need explicit steps
- **Sonnet**: Balance of following guidance and creativity
- **Opus**: Most flexible, may add helpful extras

**Acceptable differences:**
- Haiku: May need more explicit instructions, fewer advanced features
- Sonnet: Should handle 90%+ of scenarios well
- Opus: Can handle edge cases and complex scenarios

**Unacceptable:**
- Skill fails completely on any model
- Inconsistent output quality (Haiku produces garbage)
- Missing required information for Haiku

**If issues found:**
- Make instructions more explicit for Haiku
- Add examples showing expected output
- Simplify complex workflows
- Test again until all models work adequately

---

### Fresh Instance Testing

**Critical:** Always test skills with fresh Claude Code sessions (no prior context).

**Testing process:**

```markdown
## Fresh Instance Test Protocol

1. **Open NEW Claude Code session**
   - Clear any existing context
   - Don't reference prior conversations
   - Start clean

2. **Give task that should trigger skill**
   - Use realistic user language
   - Don't mention skill name
   - Let Claude decide whether to invoke

3. **Observe which files Claude accesses**
   - Does it find the skill?
   - Does it read the right files?
   - Does it follow the workflow?

4. **Note any confusion or missing info**
   - Where did Claude get stuck?
   - What information was missing?
   - What was unclear?

5. **Refine skill based on observations**
   - Add missing information
   - Clarify confusing sections
   - Improve triggering keywords

6. **Repeat with different scenarios**
   - Try edge cases
   - Try different phrasings
   - Test with different models
```

**Common issues found in fresh instance testing:**
- Skill not triggered (description doesn't match user language)
- Missing steps in workflow (Claude confused about order)
- Unclear examples (Claude interprets incorrectly)
- Missing error handling (Claude doesn't know what to do when things fail)

**Fix strategy:**
- Improve description with keywords from failed tests
- Add "When to Use" triggers matching failed scenarios
- Make examples more concrete and explicit
- Add troubleshooting section for common failures

---

### Baseline Comparison

Validate that the skill actually improves Claude's performance vs baseline (no skill).

**Comparison methodology:**

```markdown
## Baseline Test

### Without Skill (Baseline)
1. Fresh Claude instance WITHOUT skill loaded
2. Give same task
3. Record:
   - Time taken
   - Steps performed
   - Quality of output
   - Errors/issues

### With Skill
1. Fresh Claude instance WITH skill loaded
2. Give same task
3. Record:
   - Time taken
   - Steps performed
   - Quality of output
   - Errors/issues

### Comparison
| Metric | Baseline | With Skill | Improvement |
|--------|----------|------------|-------------|
| Time | 10 min | 5 min | 50% faster |
| Success rate | 60% | 95% | +35pp |
| Output quality | 3/5 | 5/5 | +40% |
```

**What to measure:**
- **Speed**: Time to complete task
- **Success rate**: % of times task completed correctly
- **Quality**: Accuracy, completeness, correctness of output
- **Consistency**: Variance across multiple runs

**Minimum improvement thresholds:**
- Speed: 20%+ faster OR no slower (if skill adds reliability)
- Success rate: 30+ percentage points better
- Quality: Noticeable improvement in accuracy/completeness
- Consistency: < 10% variance (skill should be consistent)

**If skill doesn't improve performance:**
- Skill may be unnecessary (Claude can already do this)
- Skill may be too vague (provide more specific guidance)
- Skill may be too complex (simplify workflow)
- Skill may target wrong use case (refine scope)

**Action:**
- Iterate on skill content
- Add missing information Claude needed
- Simplify overly complex workflows
- Consider if skill is actually needed

---

### Real-World Validation

After initial testing, validate with real user tasks.

**Validation approach:**

```markdown
## Real-World Test Plan

### Phase 1: Internal Testing (Week 1)
- Team members use skill for actual work
- Track: usage frequency, success rate, issues
- Collect feedback on clarity and usefulness

### Phase 2: Documentation Review (Week 2)
- Non-author reviews skill documentation
- Checks for: clarity, completeness, errors
- Tests with fresh instance

### Phase 3: User Testing (Week 3-4)
- Release to broader users
- Monitor skill invocations
- Collect feedback via surveys
- Track success metrics

### Success Criteria
- Used 10+ times by 3+ people
- 90%+ success rate
- No critical issues reported
- Positive feedback on usefulness
```

**Metrics to track:**
- **Invocation rate**: How often is skill used?
- **Success rate**: % of successful task completions
- **Time saved**: Compared to baseline
- **User satisfaction**: Feedback scores
- **Issues reported**: Bugs, unclear docs, missing features

**Red flags:**
- Skill rarely invoked (not useful or description doesn't match needs)
- Low success rate (workflow has gaps or errors)
- Negative feedback (frustrating to use)
- High issue rate (poor quality)

**Iteration based on real usage:**
- Add examples for scenarios users actually encounter
- Clarify sections users find confusing
- Add troubleshooting for common errors users hit
- Improve description to match how users phrase tasks

---

### Continuous Improvement

Skills should evolve based on usage and feedback.

**Improvement cycle:**

```markdown
## Monthly Review Process

1. **Collect usage data**
   - Invocation count
   - Success rate
   - Time metrics

2. **Review feedback**
   - User comments
   - Issue reports
   - Feature requests

3. **Identify improvements**
   - Common failure points
   - Missing scenarios
   - Unclear sections

4. **Update skill**
   - Add missing examples
   - Clarify confusing sections
   - Fix errors

5. **Test updates**
   - Run evaluation suite
   - Fresh instance test
   - Real-world validation

6. **Release new version**
   - Update version number (SemVer)
   - Document changes
   - Announce to users
```

**Version bumping guidelines:**
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, typo corrections, clarifications
- **MINOR** (1.0.0 → 1.1.0): New examples, additional scenarios, backward-compatible changes
- **MAJOR** (1.0.0 → 2.0.0): Breaking changes, workflow restructure, different approach

**When to deprecate:**
- Skill is rarely used (< 5 uses per month)
- Claude's built-in capabilities improved (skill no longer needed)
- Better skill covers this use case
- Maintenance burden too high

**Deprecation process:**
1. Mark skill as deprecated in description
2. Add notice pointing to alternative (if applicable)
3. Keep available for 3 months
4. Archive (don't delete - may be useful reference)

---

## Appendix: Testing Checklist

Use this checklist for thorough testing:

### Pre-Release Testing
- [ ] 3+ evaluation scenarios created and passing
- [ ] Tested with Haiku (works adequately)
- [ ] Tested with Sonnet (works well)
- [ ] Tested with Opus (works excellently)
- [ ] Fresh instance test completed (3+ sessions)
- [ ] Baseline comparison shows improvement (30%+ better success rate)
- [ ] Real-world validation with 3+ users
- [ ] Documentation reviewed by non-author
- [ ] No critical issues outstanding

### Content Quality
- [ ] All examples are concrete (no placeholders)
- [ ] Error handling documented
- [ ] Troubleshooting section exists
- [ ] Cross-platform (forward slashes in paths)
- [ ] No vague language ("properly", "as needed")
- [ ] Consistent terminology throughout

### Structure
- [ ] Under 500 lines (or uses progressive disclosure)
- [ ] References valid (REFERENCE.md sections exist)
- [ ] One level of nesting max
- [ ] Clear section headings
- [ ] Quick reference at end

### Release Readiness
- [ ] Version number set (1.0.0 for new skills)
- [ ] test-scenarios.md exists
- [ ] TEMPLATE.md exists (if applicable)
- [ ] EXAMPLES.md exists (if applicable)
- [ ] README updated (if project-level docs exist)

---

**This reference guide should be consulted when creating new skills or improving existing ones. All sections are designed to be used independently - jump to the section you need.**
