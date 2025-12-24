---
name: API Documentation Writer
description: Creates comprehensive API reference documentation following Diátaxis Reference pattern. Reads source code to verify every method signature, creates structured API docs with zero fabrication tolerance. Use when documenting APIs, packages, or public interfaces.
version: 1.0.0
---

# API Documentation Writer Skill

## Purpose

Create comprehensive, accurate API reference documentation by reading source code and extracting exact method signatures. Follows the Diátaxis Reference pattern for information-oriented documentation with zero tolerance for fabricated methods or incorrect signatures.

## When to Use This Skill

- **New package/module added** - Document public APIs
- **Major API refactor** - Update documentation to match changes
- **Existing docs outdated** - Refresh documentation from source
- **After breaking changes** - Document new API signatures
- **User requests** - "document the [package] API"
- **Before release** - Ensure complete API coverage

## Diátaxis Framework: Reference Documentation

**Reference Type Characteristics:**
- **Information-oriented** - Describes the machinery, not how to use it
- **Technical descriptions** - Facts about APIs, parameters, return types
- **Complete coverage** - Every public method and type documented
- **Structured consistently** - Same format for all entries
- **Exact signatures** - Verified against source code
- **Minimal examples** - Usage demonstrations, not step-by-step tutorials

**What NOT to Include:**
- ❌ Tutorials (learning-oriented) - Use tutorial-writer skill
- ❌ How-To guides (problem-oriented) - Use migration-guide-writer skill
- ❌ Explanations (understanding-oriented) - Link to separate explanation docs
- ❌ Marketing language - Technical descriptions only

## Critical Rules (Zero Tolerance)

### P0 - CRITICAL Violations (Must Fix)
1. **Fabricated Methods** - Methods that don't exist in source code
2. **Wrong Signatures** - Parameter types, names, or order don't match source
3. **Invalid Examples** - Code that won't compile or uses fake imports
4. **Unverified Performance Claims** - Numbers without benchmark evidence

### P1 - HIGH Violations (Should Fix)
5. **Missing Source References** - Not citing which file/method documented
6. **Incomplete Coverage** - Missing public methods
7. **Marketing Language** - Buzzwords instead of technical descriptions

### P2 - MEDIUM Violations
8. **Structural Issues** - Not following template consistently
9. **Redundancy** - Repeating information unnecessarily

## Step-by-Step Workflow

### Step 1: Discovery Phase (5-10 minutes)

**Identify what to document:**

```bash
# Find package structure
ls -la [package_path]/

# Find all Go public functions (example for Go)
grep -rn "^func [A-Z]" [package_path]/
grep -rn "^func (.*) [A-Z]" [package_path]/

# Find all TypeScript exports (example for TypeScript)
grep -rn "^export (function|class|interface|type)" [package_path]/

# Find all Python public classes/functions (example for Python)
grep -rn "^(class|def) [A-Z]" [package_path]/
```

**Create discovery checklist:**
```markdown
## Discovery Checklist
- [ ] Package name and purpose identified
- [ ] All public types/interfaces found
- [ ] All public functions/methods found
- [ ] All public constants found
- [ ] Test files located (for example extraction)
- [ ] Related documentation read (README, etc.)
```

### Step 2: Extraction Phase (10-20 minutes)

**Read source files completely:**

For each public API element:

1. **Read the complete source file** using Read tool
2. **Copy exact signature** - Do NOT paraphrase or simplify:
   ```go
   // ✅ CORRECT - Exact signature
   func (s *TaskService) Create(ctx rms.Ctx, params *CreateTaskParams) (*entity.Task, error)

   // ❌ WRONG - Simplified or paraphrased
   func Create(ctx context.Context, params CreateTaskParams) (Task, error)
   ```

3. **Extract inline documentation** from source comments
4. **Note error conditions** from code logic (not just comments)
5. **Identify parameter constraints** from validation code
6. **Record source location** - File path and method name (NOT line numbers)

**Example Extraction:**
```markdown
### Extracted from: services/task_service.go

**Method**: TaskService.Create
**Signature**:
```go
func (s *TaskService) Create(ctx rms.Ctx, params *CreateTaskParams) (*entity.Task, error)
```
**Source comment**: "Create creates a new task with the given parameters"
**Error conditions** (from code):
- Returns error if params.Title is empty (line 45 validates)
- Returns error if params.PartnerId is empty (line 48 validates)
- Returns database error if insert fails (line 62)
```

### Step 3: Documentation Phase (15-30 minutes)

**Use the REFERENCE.md template** (see REFERENCE.md file in this skill directory).

**For each API element, document:**

#### Types/Interfaces/Structs

```markdown
### Type: TypeName

```go
// EXACT definition from [source file]
type TypeName struct {
    Field1 Type1 `tags:"if,any"`  // Description of Field1
    Field2 Type2                   // Description of Field2
}
```

**Purpose**: [What this type represents]

**Fields**:
- `Field1` (Type1): [Detailed description, constraints, default values]
- `Field2` (Type2): [Detailed description]

**Source**: `path/to/file.go` (TypeName type)
```

#### Functions/Methods

```markdown
### Method: TypeName.MethodName

```go
// EXACT signature from [source file:MethodName]
func (t *TypeName) MethodName(param1 Type1, param2 Type2) (ReturnType, error)
```

**Description**: [What this method does - one clear sentence]

**Parameters**:
- `param1` (Type1): [Description, constraints, valid values]
- `param2` (Type2): [Description, nil handling if applicable]

**Returns**:
- `ReturnType`: [Description of return value]
- `error`: [Error conditions - when does it return error?]
  - Returns error if [condition 1]
  - Returns error if [condition 2]
  - Returns database error if [condition 3]

**Example**:
```go
// VERIFIED usage from test file or real usage
service := NewTaskService(db)
task, err := service.MethodName(value1, value2)
if err != nil {
    return fmt.Errorf("operation failed: %w", err)
}
// task now contains...
```

**Source**: `path/to/file.go` (MethodName method)
```

#### Constants/Enums

```markdown
### Constants: GroupName

```go
// EXACT definitions from [source file]
const (
    ConstantName1 = "value1"  // Description
    ConstantName2 = "value2"  // Description
)
```

**Purpose**: [What these constants represent]

**Values**:
- `ConstantName1`: [When to use this value]
- `ConstantName2`: [When to use this value]

**Source**: `path/to/file.go` (constants)
```

### Step 4: Example Creation (10-15 minutes)

**Create working examples:**

1. **Extract from test files** when possible:
   ```bash
   # Find test files
   find [package_path] -name "*_test.go" -o -name "*.test.ts" -o -name "test_*.py"

   # Read test files for real usage patterns
   ```

2. **Verify imports are correct**:
   ```go
   // ✅ CORRECT - Real imports
   import "github.com/yourorg/yourproject/pkg/services"

   // ❌ WRONG - Fake imports
   import "services" // Doesn't exist!
   ```

3. **Include complete context**:
   ```go
   // ✅ GOOD - Complete example
   import (
       "context"
       "github.com/yourorg/pkg/services"
   )

   func Example() {
       service := services.NewTaskService(db)
       task, err := service.Create(ctx, params)
       if err != nil {
           // Handle error
       }
       // Use task
   }

   // ❌ BAD - Missing context
   task, err := Create(params) // Where did Create come from?
   ```

4. **Test critical examples if possible**:
   - Copy example to a test file
   - Run it to verify it compiles
   - Verify it produces expected result
   - Only include if you've verified it works

### Step 5: Verification Phase (5-10 minutes)

**Run through verification checklist:**

```markdown
## API Documentation Verification Checklist

### Source Code Verification (P0 - CRITICAL)
- [ ] Every documented method exists in source code
- [ ] All method signatures exactly match source
- [ ] All parameter types match source
- [ ] All return types match source
- [ ] Parameter names match source (not changed for clarity)
- [ ] All type definitions exactly match source

### Example Verification (P0 - CRITICAL)
- [ ] All code examples use real imports
- [ ] All code examples use verified API signatures
- [ ] No fabricated methods in examples
- [ ] Examples would compile (tested if possible)

### Completeness (P1 - HIGH)
- [ ] All public methods documented
- [ ] All public types documented
- [ ] All public constants documented
- [ ] Source file references included
- [ ] Error conditions documented

### Quality (P2 - MEDIUM)
- [ ] No marketing language ("blazing fast", "enterprise-grade")
- [ ] No decorative emojis
- [ ] Consistent structure across entries
- [ ] Technical descriptions (not tutorials)
- [ ] Source references use method names (not line numbers)
```

**Cross-check against source:**

For each documented method, open the source file and verify:
1. Method name matches exactly
2. Parameter count matches
3. Parameter types match exactly
4. Parameter names match exactly
5. Return types match exactly
6. Receiver type matches (for methods)

**Flag any discrepancies** as P0 CRITICAL and fix immediately.

### Step 6: Organization and Structure (5-10 minutes)

**Organize documentation logically:**

```markdown
# [Package Name] API Reference

## Overview
[Brief description of package purpose - 1-2 sentences]

## Installation
[How to import/install - if relevant]

## Core Types
[Document main types/interfaces first]

### Type: MainType
...

### Type: SupportingType
...

## Primary Functions
[Document main API functions]

### Function: MainFunction
...

## Utility Functions
[Document helper/utility functions]

### Function: HelperFunction
...

## Constants
[Document constants and enums]

### Constants: GroupName
...

## Error Types
[Document custom errors]

### Type: CustomError
...

## Examples
[Comprehensive usage examples]

### Example: Common Use Case
...

---

**Verification**: All APIs verified against source code as of [date]
**Source**: `path/to/package/` directory
```

## Integration with Other Skills

### Works With:
- **api-documentation-verify** - Verify reference docs for accuracy
- **migration-guide-writer** - Reference docs show new API signatures
- **tutorial-writer** - Tutorials link to reference for detailed API info

### Invokes:
- None (standalone skill, but uses Read tool extensively)

### Invoked By:
- User (manual invocation)
- As part of documentation workflow

## Output Format

**Primary Output**: Markdown file with structured API reference

**File Location**:
- `docs/api/[package-name].md` for package documentation
- `API.md` in project root for main API
- `docs/reference/[module-name].md` for module documentation

**Include at end of document:**

```markdown
---

## Documentation Metadata

**Last Updated**: [Date]
**Source Code Version**: [Commit SHA or version]
**Verification Status**: ✅ All APIs verified against source code
**Source Files**:
- `path/to/file1.go`
- `path/to/file2.go`

## Verification Checklist Completed:
- ✅ All methods verified against source
- ✅ All signatures exactly match
- ✅ All examples use real imports
- ✅ No fabricated methods
- ✅ No marketing language
- ✅ Source references included
```

## Common Pitfalls to Avoid

### 1. Paraphrasing Signatures
```markdown
❌ BAD - Simplified signature
func Create(params CreateParams) (Task, error)

✅ GOOD - Exact signature from source
func (s *TaskService) Create(ctx rms.Ctx, params *CreateTaskParams) (*entity.Task, error)
```

### 2. Fabricating Methods
```markdown
❌ BAD - Method doesn't exist
### Method: TaskService.UpdateStatus
Updates the status of a task
[This method was never in the source code!]

✅ GOOD - Only document methods that exist
[Check source first, only document what exists]
```

### 3. Wrong Parameter Types
```markdown
❌ BAD - Wrong type
- `taskId` (string): Task identifier

✅ GOOD - Correct type from source
- `taskId` (TaskId): Task identifier (branded type)
```

### 4. Missing Error Conditions
```markdown
❌ BAD - Vague error description
Returns error if operation fails

✅ GOOD - Specific error conditions from code
Returns error if:
- taskId is empty string
- task not found in database
- user lacks permission (PermissionError)
```

### 5. Invalid Examples
```markdown
❌ BAD - Won't compile
```go
task := CreateTask(params)
```

✅ GOOD - Complete, working example
```go
import "github.com/org/pkg/services"

service := services.NewTaskService(db)
task, err := service.Create(ctx, params)
if err != nil {
    return fmt.Errorf("failed to create task: %w", err)
}
```

### 6. Using Line Numbers
```markdown
❌ BAD - Line numbers become outdated
**Source**: `services/task.go:145`

✅ GOOD - Use method names
**Source**: `services/task.go` (Create method)
```

### 7. Marketing Language
```markdown
❌ BAD - Marketing buzzwords
The TaskService provides blazing-fast, enterprise-grade task management

✅ GOOD - Technical description
The TaskService provides CRUD operations for task entities
```

## Time Estimates

**Small API** (< 10 public methods): 30-45 minutes
**Medium API** (10-30 public methods): 1-2 hours
**Large API** (30+ public methods): 2-4 hours
**Complex API with types** (many types and methods): 4-8 hours

## Example Usage

```bash
# Manual invocation
/skill api-doc-writer

# With specific package
/skill api-doc-writer pkg/services/task

# User request
User: "Document the TaskService API"
Assistant: "I'll use the api-doc-writer skill to create comprehensive API documentation"
```

## Success Criteria

Documentation is complete when:
- ✅ All public APIs discovered and documented
- ✅ All signatures verified against source code
- ✅ All examples use real imports and verified APIs
- ✅ No fabricated methods or wrong signatures
- ✅ Source references included for all entries
- ✅ Error conditions documented from code
- ✅ Verification checklist completed
- ✅ No marketing language or buzzwords
- ✅ Structured consistently using template

## References

- Diátaxis Framework: https://diataxis.fr/reference/
- Technical Documentation Expert Agent
- REFERENCE.md template in this skill directory


---

## Related Agent

For comprehensive documentation guidance that coordinates this and other documentation skills, use the **`documentation-coordinator`** agent.
