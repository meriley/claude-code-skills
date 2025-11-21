# Skill Writing Examples

This document provides concrete examples of good vs bad skill implementations to guide skill creation.

## Table of Contents
1. [Description Examples](#description-examples)
2. [Structure Examples](#structure-examples)
3. [Before/After Improvements](#beforeafter-improvements)
4. [Real-World Examples](#real-world-examples)

---

## Description Examples

### Good Description Example

```yaml
---
name: analyzing-spreadsheets
description: Analyze Excel and CSV files, create pivot tables, generate charts, and compute statistical summaries. Use when working with tabular data, spreadsheets, or data analysis tasks.
version: 1.0.0
---
```

**Why this is good:**
- ✅ Third person: "Analyze" not "I can analyze"
- ✅ Specific capabilities: "Excel and CSV files, create pivot tables, generate charts"
- ✅ Clear trigger words: "spreadsheets", "tabular data", "data analysis"
- ✅ WHEN to use: "Use when working with..."
- ✅ Concise but informative (under 1024 chars)

### Bad Description Examples

#### Example 1: Vague and First Person
```yaml
---
name: data-helper
description: I can help you work with different types of data files and perform various operations on them.
version: 1.0.0
---
```

**Problems:**
- ❌ First person: "I can help you"
- ❌ Too vague: "different types of data files", "various operations"
- ❌ No specific capabilities listed
- ❌ Missing trigger words
- ❌ No clear WHEN to use

#### Example 2: Too Generic
```yaml
---
name: file-processor
description: Processes files efficiently and quickly.
version: 1.0.0
---
```

**Problems:**
- ❌ Extremely vague: "Processes files"
- ❌ Marketing language: "efficiently and quickly" (no value)
- ❌ No specific file types
- ❌ No capabilities listed
- ❌ No trigger words

#### Example 3: Second Person
```yaml
---
name: pdf-tool
description: You can use this skill when you need to extract text from PDF documents or convert them to other formats.
version: 1.0.0
---
```

**Problems:**
- ❌ Second person: "You can use"
- ❌ Awkward phrasing
- ❌ Should be direct: "Extracts text from PDFs..."

### Improvement Pattern

**Before:**
```yaml
description: I help with document processing tasks.
```

**After:**
```yaml
description: Extract text, tables, and forms from PDF files including scanned documents. Use when working with PDFs or document extraction tasks.
```

---

## Structure Examples

### Good Structure Example

```
analyzing-spreadsheets/
├── Skill.md                    # 387 lines - under 500 ✅
├── REFERENCE.md                # API documentation
└── EXAMPLES.md                 # Additional examples

Skill.md structure:
├─ Purpose (1 paragraph)
├─ When to Use (5 bullets)
├─ Quick Start Workflow (3 steps)
├─ Common Operations (4 scenarios)
├─ Output Formats (templates)
└─ Troubleshooting (common issues)
```

**Why this is good:**
- ✅ Main file under 500 lines
- ✅ Progressive disclosure (details in REFERENCE.md)
- ✅ One level deep references
- ✅ Clear organization
- ✅ Concrete examples throughout

### Bad Structure Example

```
data-processor/
├── skill.md                    # 1,247 lines - too long ❌
├── advanced-features.md        # Referenced by skill.md
│   └── references → expert-guide.md  # Two levels deep ❌
├── api_docs.txt                # Wrong extension ❌
└── helper_scripts/             # Underscore instead of hyphen ❌
    └── process.py

skill.md structure:
├─ History of Data Processing (not needed)
├─ 47 different approaches (too many options)
├─ Installation (Claude knows this)
├─ Python basics (Claude knows this)
└─ Configuration (no examples)
```

**Problems:**
- ❌ Main file way over 500 lines
- ❌ Nested references (Skill.md → advanced.md → expert-guide.md)
- ❌ Wrong file naming (lowercase, underscore, .txt)
- ❌ Too many options (47 approaches)
- ❌ Includes general knowledge Claude already has
- ❌ No concrete examples

---

## Before/After Improvements

### Example 1: Bloated to Focused

#### Before: 847 lines, unfocused
```markdown
---
name: pdf-helper
description: Helps process PDF documents.
version: 1.0.0
---

# PDF Helper

## History of PDF Format
PDF (Portable Document Format) was developed by Adobe in 1993...
[200 lines of PDF history]

## Python Installation
Python is a programming language. To install Python, visit...
[100 lines of Python basics]

## Available Libraries
There are many PDF libraries available:
- pypdf (basic operations)
- pypdf2 (deprecated but still used)
- pypdf3 (fork of pypdf2)
- pdfplumber (text and tables)
- PyMuPDF (fast and feature-rich)
- camelot (table extraction)
- tabula (another table tool)
- pdfminer.six (low-level parsing)
- slate (simple wrapper)
- pdfrw (PDF manipulation)
[300 lines listing every possible library]

## Configuration
You can configure many settings...
[200 lines of generic config info without examples]

## Usage
Use this skill when you need to process PDFs.
```

#### After: 342 lines, focused
```markdown
---
name: processing-pdfs
description: Extract text, tables, and forms from PDF files including scanned documents. Use when working with PDFs or document extraction tasks.
version: 1.0.0
dependencies: pdfplumber>=0.9.0, pdf2image>=1.16.0, pytesseract>=0.3.10
---

# PDF Processing

## Purpose
Extract structured data from PDF files including text, tables, and forms.

## When to Use
- Extracting text from standard PDFs
- Parsing tables from financial or data reports
- Processing scanned documents (OCR)
- Extracting form data
- Batch processing multiple PDFs

## Workflow

### Step 1: Identify PDF Type
```bash
# Check if PDF is text-based or scanned
pdfinfo document.pdf | grep "Page size"
```

### Step 2: Extract Content

**For text-based PDFs:**
```python
import pdfplumber

with pdfplumber.open('document.pdf') as pdf:
    text = pdf.pages[0].extract_text()
    print(text)
```

**For scanned PDFs:**
```python
from pdf2image import convert_from_path
import pytesseract

images = convert_from_path('scanned.pdf', dpi=300)
text = pytesseract.image_to_string(images[0])
```

### Step 3: Validate Output
```python
# Verify extraction
assert text is not None, "Extraction failed"
assert len(text) > 0, "Empty result"
```

## Common Operations

### Extract Tables
```python
with pdfplumber.open('data.pdf') as pdf:
    table = pdf.pages[0].extract_table()
    # Returns: [['Header1', 'Header2'], ['Row1Col1', 'Row1Col2']]
```

### Extract Forms
```python
from PyPDF2 import PdfReader

reader = PdfReader('form.pdf')
fields = reader.get_fields()
# Returns: {'field_name': 'field_value', ...}
```

## Output Format
```json
{
  "filename": "document.pdf",
  "pages": 5,
  "text": "extracted content...",
  "tables": [
    [["Col1", "Col2"], ["Val1", "Val2"]]
  ],
  "forms": {
    "field1": "value1"
  }
}
```

## Troubleshooting

**Empty text extraction:**
- Check if PDF is scanned → Use OCR workflow
- Try `layout=True` parameter for complex layouts

**Table extraction issues:**
- Adjust `table_settings` for better detection
- See REFERENCE.md for advanced table configuration

**OCR accuracy problems:**
- Increase DPI to 300-400 for better quality
- Pre-process images (contrast, denoise)

## Reference
For advanced configuration and API details, see REFERENCE.md
```

**Improvements made:**
- ✅ Reduced from 847 to 342 lines
- ✅ Removed PDF history (Claude knows this)
- ✅ Removed Python installation (Claude knows this)
- ✅ Chose ONE default library per task (pdfplumber for text/tables)
- ✅ Added concrete examples with actual code
- ✅ Added validation steps
- ✅ Included expected output formats
- ✅ Added troubleshooting for common issues
- ✅ Moved detailed docs to REFERENCE.md

---

### Example 2: Vague to Specific

#### Before: Too vague
```markdown
---
name: helper
description: Helps with various tasks.
version: 1.0.0
---

# Helper

## What It Does
This skill can help you with different things.

## How to Use
1. Do the thing
2. Check the result
3. Fix if needed

## Examples
Here are some examples of how to use it.
```

#### After: Clear and specific
```markdown
---
name: validating-apis
description: Verify REST API responses match OpenAPI schemas, validate status codes, check authentication headers, and test error handling. Use when testing APIs or validating HTTP responses.
version: 1.0.0
dependencies: jsonschema>=4.17.0, requests>=2.28.0
---

# API Validation

## Purpose
Validate REST API responses against OpenAPI specifications and verify correct error handling.

## When to Use
- Testing API endpoints against schema definitions
- Verifying API responses match documentation
- Validating error responses and status codes
- Checking authentication and authorization headers
- Integration testing API contracts

## Workflow

### Step 1: Load OpenAPI Schema
```python
import json

with open('openapi.yaml') as f:
    schema = yaml.safe_load(f)
```

### Step 2: Make API Request
```python
import requests

response = requests.get(
    'https://api.example.com/users/123',
    headers={'Authorization': 'Bearer token123'}
)
```

### Step 3: Validate Response
```python
from jsonschema import validate

# Validate status code
assert response.status_code == 200, f"Expected 200, got {response.status_code}"

# Validate response body against schema
user_schema = schema['components']['schemas']['User']
validate(instance=response.json(), schema=user_schema)
```

## Examples

### Example 1: Validate Success Response
**Input:**
```json
GET /users/123
Response: {"id": 123, "name": "John", "email": "john@example.com"}
```

**Validation:**
```python
validate(instance=response.json(), schema={
    "type": "object",
    "required": ["id", "name", "email"],
    "properties": {
        "id": {"type": "integer"},
        "name": {"type": "string"},
        "email": {"type": "string", "format": "email"}
    }
})
# ✅ Passes - all fields present and correct types
```

### Example 2: Validate Error Response
**Input:**
```json
GET /users/99999
Response: {"error": "User not found", "code": "USER_NOT_FOUND"}
Status: 404
```

**Validation:**
```python
assert response.status_code == 404
assert 'error' in response.json()
assert response.json()['code'] == 'USER_NOT_FOUND'
# ✅ Passes - error response correct
```

## Output Format
```json
{
  "endpoint": "/users/123",
  "method": "GET",
  "status_code": 200,
  "validation": {
    "schema_valid": true,
    "required_fields": ["id", "name", "email"],
    "missing_fields": [],
    "type_errors": []
  }
}
```

## Common Validations

### Status Codes
```python
# Success responses
assert 200 <= response.status_code < 300

# Specific codes
assert response.status_code == 201  # Created
assert response.status_code == 204  # No Content

# Error responses
assert response.status_code == 400  # Bad Request
assert response.status_code == 401  # Unauthorized
assert response.status_code == 404  # Not Found
```

### Headers
```python
# Check content type
assert response.headers['Content-Type'] == 'application/json'

# Check authentication
assert 'Authorization' in request.headers

# Check CORS
assert 'Access-Control-Allow-Origin' in response.headers
```

## Troubleshooting

**Schema validation fails:**
- Check field names match exactly (case-sensitive)
- Verify all required fields present
- Confirm data types match schema

**Unexpected status code:**
- Verify authentication token valid
- Check request parameters
- Review API rate limits

For more advanced scenarios, see REFERENCE.md
```

**Improvements made:**
- ✅ Specific name: "validating-apis" vs "helper"
- ✅ Detailed description with trigger words
- ✅ Clear use cases
- ✅ Concrete code examples
- ✅ Expected outputs
- ✅ Multiple real-world examples
- ✅ Specific troubleshooting steps

---

## Real-World Examples

### Example: Good Skill (helm-chart-expert)

```markdown
---
name: helm-chart-expert
description: Master Helm workflow orchestrator for comprehensive chart development, review, ArgoCD integration, and production deployment. Use for complex Helm tasks or when you need guidance on which Helm skill to apply.
version: 1.0.0
---

# Helm Chart Expert

## Purpose
Orchestrate comprehensive Helm chart development, review, and deployment workflows.

## When to Use
- Creating production-ready Helm charts from scratch
- Reviewing existing charts for security and quality
- Setting up ArgoCD-based GitOps deployments
- Implementing advanced deployment strategies
- Not sure which Helm skill to use

## Workflow Selection

This skill helps you choose the right Helm skill:

| Task | Use Skill |
|------|-----------|
| Create new chart | `helm-chart-writing` |
| Review existing chart | `helm-chart-review` |
| Setup ArgoCD | `helm-argocd-gitops` |
| Production deployment | `helm-production-patterns` |

## Quick Start

### Creating a New Chart
```bash
# 1. Invoke helm-chart-writing skill
# 2. Follow Chart.yaml structure
# 3. Organize values hierarchically
# 4. Use recommended templates
```

### Reviewing a Chart
```bash
# 1. Invoke helm-chart-review skill
# 2. Run security checks
# 3. Validate best practices
# 4. Generate report
```

[... continues with focused, actionable content ...]
```

**Why this is good:**
- ✅ Acts as orchestrator for related skills
- ✅ Clear decision tree for which skill to use
- ✅ Quick start for common scenarios
- ✅ Links to specialized skills
- ✅ Under 500 lines (delegates details)

---

### Example: Poor Skill (data-processor)

```markdown
---
name: data-processor
description: Process data.
version: 1.0.0
---

# Data Processor

## About
This skill helps with data processing tasks. You can use it when you need to process data.

## Installation
First, install Python from python.org. Python is a programming language...
[50 lines of Python installation]

## Libraries
There are many ways to process data. You could use:
- pandas (most popular)
- numpy (for arrays)
- polars (faster than pandas)
- dask (for big data)
- vaex (out-of-core DataFrames)
- modin (parallelized pandas)
- cudf (GPU-accelerated)
- datatable (R-style syntax)
[... lists 30 more libraries]

Choose whichever one you prefer!

## Usage
Process your data however you want. Here's an example:
```python
# Do some data processing
import library
result = library.process(data)
```

## Tips
- Make sure your data is clean
- Check for errors
- Validate your results
- Be careful with large files
```

**Problems:**
- ❌ Vague description: "Process data"
- ❌ Vague name: "data-processor"
- ❌ Second person: "You can use it"
- ❌ Installation info Claude already knows
- ❌ Lists 30+ libraries with no guidance
- ❌ No concrete examples
- ❌ No specific workflows
- ❌ Generic tips without actionable guidance
- ❌ No validation steps
- ❌ No output format examples

---

## Key Takeaways

### Descriptions
- ✅ Third person, specific, includes triggers
- ❌ First/second person, vague, no context

### Structure
- ✅ Under 500 lines, progressive disclosure, one level deep
- ❌ Over 500 lines, nested references, no organization

### Content
- ✅ Concrete examples, one default approach, validation
- ❌ Vague instructions, too many options, no examples

### Naming
- ✅ Gerund form, specific, lowercase-with-hyphens
- ❌ Generic names, vague, inconsistent format

### Testing
- ✅ Create evaluations first, test with fresh instances
- ❌ No testing, assume it works

**Remember:** Skills should be focused, specific, and actionable. If you're listing more than 3-4 options for any task, you need to pick a default approach and move alternatives to a reference file.
