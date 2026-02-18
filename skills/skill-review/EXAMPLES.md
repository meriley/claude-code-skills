# Skill Review Examples

This document provides concrete examples of skill reviews at different quality levels: PASS, NEEDS WORK, and FAIL.

---

## Table of Contents
1. [PASS Example](#pass-example)
2. [NEEDS WORK Example](#needs-work-example)
3. [FAIL Example](#fail-example)
4. [Before/After Improvements](#beforeafter-improvements)

---

## PASS Example

# Skill Review: processing-pdfs
**Reviewer:** mriley
**Date:** 2025-01-15
**Version Reviewed:** 1.0.0

## Summary
High-quality skill with clear structure, excellent documentation, and comprehensive testing. Ready for release with only minor suggestions for improvement.

**Recommendation:** ✅ **PASS**

## Findings by Category

### Structure [✅ PASS]
- [x] Directory structure correct
- [x] File naming conventions followed
- [x] Under 500 lines (342 lines)

**Issues:** None

**Positive highlights:**
- Clean directory structure with clear separation
- Progressive disclosure pattern used effectively
- All supporting files properly named

---

### Frontmatter [✅ PASS]
- [x] Valid YAML
- [x] All required fields present
- [x] Description quality excellent

**Frontmatter:**
```yaml
---
name: processing-pdfs
description: Extract text, tables, and forms from PDF files including scanned documents. Use when working with PDFs or document extraction tasks.
version: 1.0.0
dependencies: pdfplumber>=0.9.0, pdf2image>=1.16.0, pytesseract>=0.3.10
---
```

**Issues:** None

**Positive highlights:**
- Third person description
- Specific capabilities listed (text, tables, forms)
- Clear triggers (PDFs, document extraction)
- Includes dependencies with versions

---

### Content Quality [✅ PASS]
- [x] Clear purpose and workflows
- [x] Concrete examples provided (4 examples)
- [x] Progressive disclosure used
- [x] Consistent terminology

**Issues:** None

**Positive highlights:**
- Main file is 342 lines (well under 500)
- Provides ONE default library per task
- 4 concrete examples with input/output
- Excellent troubleshooting section
- Details moved to REFERENCE.md (280 lines)

**Content breakdown:**
- Purpose: Clear and concise
- When to Use: 5 specific scenarios
- Workflow: 3 clear steps with validation
- Common Operations: 3 operations with code
- Output Format: JSON template provided
- Troubleshooting: 3 common issues with solutions

---

### Instruction Clarity [✅ PASS]
- [x] Clear sequential steps
- [x] Code examples complete and runnable
- [x] Validation steps included

**Issues:** None

**Positive highlights:**
- Each step has concrete code example
- Expected outputs documented
- Validation checkpoints provided
- Error handling shown in examples

**Example quality:**
```python
# ✅ Complete, runnable code
import pdfplumber

with pdfplumber.open('document.pdf') as pdf:
    text = pdf.pages[0].extract_text()
    print(text)

# ✅ Validation step included
assert text is not None, "Extraction failed"
assert len(text) > 0, "Empty result"
```

---

### Testing [✅ PASS]
- [x] Test scenarios created (5 scenarios)
- [x] Fresh instance testing done
- [x] Multi-model testing done

**Test coverage:**
- Simple text extraction
- Table extraction
- Form extraction
- Scanned PDF (OCR)
- Batch processing

**Model testing results:**
| Scenario | Haiku | Sonnet | Opus |
|----------|-------|--------|------|
| Simple text | ✅ Pass | ✅ Pass | ✅ Pass |
| Tables | ⚠️ Partial | ✅ Pass | ✅ Pass |
| Forms | ✅ Pass | ✅ Pass | ✅ Pass |
| OCR | ❌ Fail | ✅ Pass | ✅ Pass |
| Batch | ⚠️ Partial | ✅ Pass | ✅ Pass |

**Issues:** None - appropriate skill-level complexity

**Positive highlights:**
- Comprehensive test scenarios
- Testing documented in TESTING.md
- Real-world validation with team
- Identified Haiku limitations (documented)

---

## Blockers (must fix)
None

## Critical Issues (should fix)
None

## Major Issues (fix soon)
None

## Minor Issues (nice to have)
1. [MINOR] Could add example for password-protected PDFs
2. [MINOR] Could add performance benchmarks to REFERENCE.md

## Positive Highlights
- Excellent progressive disclosure pattern
- Clear, actionable workflows
- Comprehensive testing across models
- One default approach per task (no option paralysis)
- Complete, runnable code examples
- Specific troubleshooting guidance
- Dependencies with versions specified
- Well-organized REFERENCE.md for advanced topics

## Recommendations
1. Consider adding password-protected PDF example in future version
2. Consider performance benchmarks for large files (nice to have)
3. Skill is ready for immediate release

## Next Steps
- [x] Approve for merge
- [ ] Add to skill marketplace
- [ ] Share with team

---

## NEEDS WORK Example

# Skill Review: analyzing-data
**Reviewer:** mriley
**Date:** 2025-01-15
**Version Reviewed:** 0.9.0

## Summary
Good foundation with clear purpose, but needs refinement before release. Description needs improvement, examples need expected outputs, and testing needs to be completed. Addressable issues - should be ready after revisions.

**Recommendation:** ⚠️ **NEEDS WORK**

## Findings by Category

### Structure [✅ PASS]
- [x] Directory structure correct
- [x] File naming conventions followed
- [x] Under 500 lines (412 lines)

**Issues:** None

---

### Frontmatter [⚠️ NEEDS WORK]
- [x] Valid YAML
- [x] All required fields present
- [ ] Description quality needs improvement

**Frontmatter:**
```yaml
---
name: analyzing-data
description: Analyzes data from various sources and formats. Use for data analysis tasks.
version: 0.9.0
---
```

**Issues:**
1. [CRITICAL] Description too vague - "various sources and formats" not specific
2. [CRITICAL] Missing key capabilities (what kind of analysis?)
3. [CRITICAL] Missing key terms for discovery
4. [MAJOR] Missing dependencies field

**Recommended fix:**
```yaml
---
name: analyzing-data
description: Analyze CSV and Excel files with statistical summaries, correlation analysis, and data quality checks. Generate reports with pandas, create visualizations, detect outliers. Use when analyzing tabular datasets or performing statistical analysis.
version: 0.9.0
dependencies: pandas>=1.5.0, numpy>=1.23.0, matplotlib>=3.6.0
---
```

---

### Content Quality [⚠️ NEEDS WORK]
- [x] Clear purpose and workflows
- [ ] Concrete examples need improvement
- [x] Progressive disclosure used
- [x] Consistent terminology

**Issues:**
1. [CRITICAL] Only 1 example provided (need 2-3 minimum)
2. [MAJOR] Examples missing expected outputs
3. [MAJOR] No validation steps shown
4. [MAJOR] Troubleshooting section too generic

**Example of incomplete example:**
```python
# ❌ CURRENT: No output shown
import pandas as pd
df = pd.read_csv('data.csv')
result = df.describe()
```

**Should be:**
```python
# ✅ IMPROVED: Shows expected output
import pandas as pd
df = pd.read_csv('data.csv')
result = df.describe()

# Expected output:
#        count      mean       std      min       25%       50%       75%       max
# sales  100.0  1000.45  250.30  500.00  800.00  1000.00  1200.00  1500.00
```

**Positive highlights:**
- Good file organization
- Clear workflow structure
- Progressive disclosure used
- Consistent terminology

---

### Instruction Clarity [✅ PASS]
- [x] Clear sequential steps
- [x] Code examples complete
- [ ] Validation steps need improvement

**Issues:**
1. [MAJOR] Validation steps missing from workflows
2. [MINOR] Could add more error handling examples

**Positive highlights:**
- Steps clearly numbered
- Code is runnable
- Workflows logical

---

### Testing [❌ NEEDS WORK]
- [ ] Test scenarios not documented
- [ ] Fresh instance testing not documented
- [ ] Multi-model testing not done

**Issues:**
1. [CRITICAL] No documented test scenarios
2. [CRITICAL] No testing matrix provided
3. [CRITICAL] No team feedback mentioned

**Required before release:**
- Create at least 3 test scenarios
- Test with fresh Claude instances
- Document results across models
- Get team feedback

---

## Blockers (must fix)
None

## Critical Issues (should fix)
1. Description too vague - needs specific capabilities and key terms
2. Only 1 example - need 2-3 with expected outputs
3. No documented test scenarios or testing matrix
4. Missing dependencies field in frontmatter

## Major Issues (fix soon)
1. Examples missing expected outputs
2. No validation steps in workflows
3. Troubleshooting section too generic
4. No error handling examples

## Minor Issues (nice to have)
1. Could add more examples for edge cases
2. Could add performance considerations

## Positive Highlights
- Good file organization and structure
- Clear workflow steps
- Consistent terminology
- Good use of progressive disclosure
- Code examples are complete and runnable

## Recommendations

### Priority 1 (Required before release)
1. **Improve description** - Add specific capabilities:
   - "CSV and Excel files"
   - "statistical summaries, correlation analysis"
   - "data quality checks"
   - Key terms: "tabular data", "statistical analysis", "pandas"

2. **Add more examples** - Minimum 2-3 total:
   - Statistical summary example
   - Correlation analysis example
   - Data quality check example
   - Include expected outputs for all

3. **Add validation steps** - Show how to verify results:
   ```python
   assert not df.empty, "DataFrame is empty"
   assert 'column_name' in df.columns, "Missing required column"
   ```

4. **Complete testing** - Document:
   - 3+ test scenarios
   - Fresh instance testing results
   - Multi-model testing matrix
   - Team feedback

5. **Add dependencies** - Specify versions:
   ```yaml
   dependencies: pandas>=1.5.0, numpy>=1.23.0, matplotlib>=3.6.0
   ```

### Priority 2 (Nice to have)
1. Add more error handling examples
2. Expand troubleshooting with specific solutions
3. Add performance benchmarks for large datasets

## Next Steps
- [ ] Address all critical issues
- [ ] Address major issues
- [ ] Complete testing documentation
- [ ] Re-review after fixes
- [ ] Approve for merge

**Estimated effort:** 4-6 hours

---

## FAIL Example

# Skill Review: data-helper
**Reviewer:** mriley
**Date:** 2025-01-15
**Version Reviewed:** 0.5.0

## Summary
Skill requires significant rework before it can be considered for release. Multiple blocker issues including first-person description, vague content, no concrete examples, and no testing. Not ready for review until fundamental issues are addressed.

**Recommendation:** ❌ **FAIL**

## Findings by Category

### Structure [⚠️ PARTIAL PASS]
- [x] Directory structure exists
- [ ] File naming needs fixes
- [ ] Over recommended line count

**Issues:**
1. [BLOCKER] Main file is 847 lines (way over 500 limit)
2. [CRITICAL] Supporting file named `reference.txt` (should be REFERENCE.md)
3. [MAJOR] Directory has `helper_scripts/` with underscores

**Required fixes:**
- Reduce Skill.md to under 500 lines
- Rename reference.txt to REFERENCE.md
- Rename helper_scripts/ to scripts/

---

### Frontmatter [❌ FAIL]
- [x] Valid YAML
- [ ] Name needs fixing
- [ ] Description completely inadequate

**Frontmatter:**
```yaml
---
name: data-helper
description: I can help you work with different types of data files and perform various operations.
version: 0.5.0
---
```

**Issues:**
1. [BLOCKER] First person description: "I can help you"
2. [BLOCKER] Generic name: "data-helper" (avoid "helper")
3. [BLOCKER] Completely vague: "different types", "various operations"
4. [CRITICAL] No specific capabilities mentioned
5. [CRITICAL] No trigger words for discovery
6. [CRITICAL] No WHEN to use guidance
7. [MAJOR] Missing dependencies field

**Required rewrite:**
```yaml
---
name: analyzing-tabular-data
description: Analyze CSV and Excel files, compute statistical summaries, generate correlation matrices, and detect outliers using pandas. Create visualizations with matplotlib. Use when analyzing spreadsheets, datasets, or performing statistical analysis.
version: 1.0.0
dependencies: pandas>=1.5.0, numpy>=1.23.0, matplotlib>=3.6.0, seaborn>=0.12.0
---
```

---

### Content Quality [❌ FAIL]
- [x] Has purpose section
- [ ] No concrete examples
- [ ] Way too long (847 lines)
- [ ] Includes general knowledge

**Issues:**
1. [BLOCKER] NO concrete examples provided anywhere
2. [BLOCKER] 847 lines in main file (should be < 500)
3. [CRITICAL] Lists 30+ libraries without guidance
4. [CRITICAL] Includes Python installation tutorial (200 lines)
5. [CRITICAL] Includes data processing history (150 lines)
6. [MAJOR] No default approach - presents too many options
7. [MAJOR] No validation steps
8. [MAJOR] Troubleshooting section too vague

**Content breakdown:**
- Lines 1-150: History of data processing (❌ NOT NEEDED)
- Lines 151-350: Python installation tutorial (❌ CLAUDE KNOWS THIS)
- Lines 351-650: Lists 30+ libraries (❌ TOO MANY OPTIONS)
- Lines 651-800: Generic configuration (❌ NO EXAMPLES)
- Lines 801-847: Vague usage tips (❌ NOT ACTIONABLE)

**Required fixes:**
- Remove all general knowledge (Python basics, installation)
- Remove data processing history
- Choose ONE default library per task
- Move alternatives to REFERENCE.md
- Add 2-3 concrete examples with input/output
- Add validation steps
- Reduce to under 500 lines

---

### Instruction Clarity [❌ FAIL]
- [ ] Steps too vague
- [ ] No concrete commands
- [ ] No expected outputs

**Current instructions:**
```markdown
## Usage
1. Do the thing
2. Check if it worked
3. Fix any issues
```

**Issues:**
1. [BLOCKER] Completely vague instructions
2. [CRITICAL] No concrete commands shown
3. [CRITICAL] No code examples
4. [CRITICAL] No expected outputs
5. [MAJOR] No validation steps

**Required fixes:**
```markdown
### Step 1: Load Data
\`\`\`python
import pandas as pd
df = pd.read_csv('data.csv')
\`\`\`

### Step 2: Compute Statistics
\`\`\`python
summary = df.describe()
print(summary)
\`\`\`

Expected output:
\`\`\`
       count      mean       std      min       25%       50%       75%       max
sales  100.0  1000.45  250.30  500.00  800.00  1000.00  1200.00  1500.00
\`\`\`

### Step 3: Validate Results
\`\`\`python
assert not df.empty, "DataFrame is empty"
assert summary.loc['count', 'sales'] == 100, "Unexpected row count"
\`\`\`
```

---

### Testing [❌ FAIL]
- [ ] No test scenarios
- [ ] No testing done
- [ ] No documentation

**Issues:**
1. [BLOCKER] No test scenarios created
2. [BLOCKER] No testing performed
3. [CRITICAL] No testing documentation
4. [CRITICAL] No baseline comparison
5. [CRITICAL] No multi-model testing

**Required before re-review:**
- Create 3+ test scenarios
- Test baseline (without skill)
- Test with skill implementation
- Test across models (Haiku, Sonnet, Opus)
- Document all results

---

## Blockers (must fix)
1. First person description: "I can help you"
2. Completely vague description
3. Generic skill name: "data-helper"
4. Main file 847 lines (should be < 500)
5. NO concrete examples anywhere
6. Completely vague instructions ("Do the thing")
7. No test scenarios created
8. No testing performed

## Critical Issues (should fix)
1. Includes 200 lines of Python installation (Claude knows this)
2. Includes 150 lines of data processing history (not needed)
3. Lists 30+ libraries without recommending a default
4. No specific capabilities in description
5. No trigger words for discovery
6. No validation steps
7. No expected outputs
8. Missing dependencies field

## Major Issues (fix soon)
1. Supporting file named reference.txt (should be REFERENCE.md)
2. Directory has helper_scripts/ with underscores
3. Troubleshooting too vague
4. No default approach chosen

## Minor Issues (nice to have)
N/A - Address blockers first

## Positive Highlights
- Has basic file structure
- Valid YAML syntax
- Has some section organization

## Recommendations

### DO NOT proceed with minor fixes - this skill needs fundamental rework

**Required before re-review:**

1. **Completely rewrite frontmatter**
   - Change to third person
   - Make description specific
   - Choose better name (not "helper")
   - Add specific capabilities
   - Add trigger keywords
   - Add dependencies

2. **Drastically reduce content (847 → < 500 lines)**
   - Remove Python installation tutorial
   - Remove data processing history
   - Remove library comparison (choose defaults)
   - Move details to REFERENCE.md

3. **Add concrete examples (minimum 3)**
   - Show actual input data
   - Show complete code
   - Show expected output
   - Include validation

4. **Make instructions actionable**
   - Replace vague steps with concrete commands
   - Add code examples
   - Document expected outputs
   - Include validation checkpoints

5. **Create and execute test scenarios**
   - Create 3+ test scenarios
   - Test without skill (baseline)
   - Test with skill
   - Document improvements
   - Test across models

6. **Fix structural issues**
   - Rename files correctly
   - Fix directory naming
   - Organize content properly

### Re-submit for review only after ALL blockers are addressed

## Next Steps
- [ ] Complete fundamental rework
- [ ] Address all 8 blocker issues
- [ ] Add concrete examples
- [ ] Complete testing
- [ ] Re-submit for fresh review

**Estimated effort:** 16-20 hours (significant rework required)

---

## Before/After Improvements

### Example: Description Improvement

#### Before (FAIL)
```yaml
---
name: data-helper
description: I can help you work with different types of data files and perform various operations.
version: 0.5.0
---
```

**Issues:**
- First person ("I can help you")
- Vague ("different types", "various operations")
- No specifics
- No triggers
- Generic name

#### After (PASS)
```yaml
---
name: analyzing-tabular-data
description: Analyze CSV and Excel files, compute statistical summaries, generate correlation matrices, and detect outliers using pandas. Create visualizations with matplotlib. Use when analyzing spreadsheets, datasets, or performing statistical analysis.
version: 1.0.0
dependencies: pandas>=1.5.0, numpy>=1.23.0, matplotlib>=3.6.0, seaborn>=0.12.0
---
```

**Improvements:**
- Third person
- Specific capabilities (CSV, Excel, statistics, correlations, outliers)
- Named tools (pandas, matplotlib)
- Clear triggers (spreadsheets, datasets, statistical analysis)
- Better name (analyzing-tabular-data)
- Dependencies listed

---

### Example: Content Improvement

#### Before (FAIL - 847 lines)
```markdown
# Data Helper

## History of Data Processing
Data processing has evolved over decades. In the 1960s...
[150 lines of history]

## Python Installation
Python is a programming language. To install Python...
[200 lines of installation]

## Available Libraries
There are many libraries you can use:
1. pandas - popular for data manipulation
2. numpy - numerical computing
3. polars - faster than pandas
4. dask - parallel computing
5. vaex - out-of-core DataFrames
[... continues listing 25 more libraries ...]
[300 lines comparing libraries]

## Configuration
You can configure various settings depending on your needs...
[100 lines of generic config info]

## Usage
Use this when you need to work with data.
```

#### After (PASS - 342 lines)
```markdown
# Analyzing Tabular Data

## Purpose
Analyze CSV and Excel files with statistical summaries and visualizations.

## When to Use
- Computing statistical summaries of datasets
- Analyzing correlations between variables
- Detecting outliers in numerical data
- Creating data visualizations
- Data quality checks

## Workflow

### Step 1: Load Data
\`\`\`python
import pandas as pd

# Load CSV
df = pd.read_csv('data.csv')

# Or load Excel
df = pd.read_excel('data.xlsx', sheet_name='Sheet1')

# Validate
assert not df.empty, "Empty dataset"
\`\`\`

### Step 2: Compute Statistics
\`\`\`python
summary = df.describe()
print(summary)
\`\`\`

Expected output:
\`\`\`
       count      mean       std      min       25%       50%       75%       max
sales  100.0  1000.45  250.30  500.00  800.00  1000.00  1200.00  1500.00
\`\`\`

### Step 3: Validate Results
\`\`\`python
assert summary.loc['count', 'sales'] == 100
assert summary.loc['mean', 'sales'] > 0
\`\`\`

## Examples

### Example 1: Statistical Summary
**Input:** `sales_data.csv` with columns: date, product, sales, revenue

**Code:**
\`\`\`python
import pandas as pd

df = pd.read_csv('sales_data.csv')
summary = df[['sales', 'revenue']].describe()
print(summary)
\`\`\`

**Output:**
\`\`\`json
{
  "sales": {"count": 100, "mean": 1000.45, "std": 250.30},
  "revenue": {"count": 100, "mean": 50000.25, "std": 12000.50}
}
\`\`\`

[... 2 more examples ...]

## Troubleshooting

**Empty DataFrame after loading:**
- Check file path is correct
- Verify file encoding: `pd.read_csv('file.csv', encoding='utf-8')`

**Memory error with large files:**
- Load in chunks: `chunks = pd.read_csv('large.csv', chunksize=10000)`
- Use column selection: `pd.read_csv('file.csv', usecols=['col1', 'col2'])`

For advanced analysis, see REFERENCE.md
```

**Improvements:**
- Reduced from 847 to 342 lines
- Removed history (not needed)
- Removed installation (Claude knows)
- Chose ONE default library (pandas)
- Added 3 concrete examples
- Added validation steps
- Added expected outputs
- Specific troubleshooting
- Moved advanced content to REFERENCE.md

---

## Key Patterns

### PASS Pattern
- ✅ Third person description with specifics and triggers
- ✅ Under 500 lines with progressive disclosure
- ✅ 2-3 concrete examples with input/output
- ✅ Clear workflows with validation
- ✅ One default approach
- ✅ Comprehensive testing documented

### NEEDS WORK Pattern
- ⚠️ Good foundation but missing key elements
- ⚠️ Description needs more specificity
- ⚠️ Examples need expected outputs
- ⚠️ Testing needs to be completed
- ⚠️ Addressable issues (4-6 hours work)

### FAIL Pattern
- ❌ First/second person description
- ❌ Way over 500 lines
- ❌ No concrete examples
- ❌ Vague instructions
- ❌ No testing done
- ❌ Includes general knowledge
- ❌ Requires fundamental rework (16-20 hours)
