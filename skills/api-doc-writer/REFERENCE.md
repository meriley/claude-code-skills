# API Reference Documentation Template

Use this template when creating API reference documentation. Follow the structure exactly and fill in all sections.

---

# [Package/Module Name] API Reference

## Overview

[Brief description of what this package/module does - 1-2 clear sentences]

**Package Path**: `import/path/to/package`
**Version**: [Version number if applicable]

---

## Installation

[How to install or import this package]

```[language]
// Installation command or import statement
```

---

## Core Types

[Document the main types/interfaces/classes that users will work with]

### Type: [TypeName]

```[language]
// EXACT definition from source code
type [TypeName] struct {
    [Field1] [Type1] `tags:"if,any"`  // Description
    [Field2] [Type2]                   // Description
}
```

**Purpose**: [What this type represents - clear, technical description]

**Fields**:
- `[Field1]` ([Type1]): [Detailed description, constraints, default values if any]
- `[Field2]` ([Type2]): [Detailed description, nil handling if applicable]

**Source**: `path/to/file.ext` ([TypeName] type)

---

### Interface: [InterfaceName]

```[language]
// EXACT definition from source code
type [InterfaceName] interface {
    [Method1]([params]) ([returns], error)
    [Method2]([params]) ([returns])
}
```

**Purpose**: [What this interface defines]

**Methods**: See implementation methods below

**Source**: `path/to/file.ext` ([InterfaceName] interface)

---

## Constructors / Factory Functions

[Document functions that create instances of types]

### Function: New[TypeName]

```[language]
// EXACT signature from source code
func New[TypeName]([param1] [Type1], [param2] [Type2]) *[TypeName]
```

**Description**: [What this constructor does]

**Parameters**:
- `[param1]` ([Type1]): [Description, purpose, constraints]
- `[param2]` ([Type2]): [Description, defaults if any]

**Returns**:
- `*[TypeName]`: [Description of the created instance]

**Example**:
```[language]
// VERIFIED example
instance := New[TypeName](value1, value2)
// instance is now ready to use
```

**Source**: `path/to/file.ext` (New[TypeName] function)

---

## Primary Methods

[Document the main API methods that users will call]

### Method: [TypeName].[MethodName]

```[language]
// EXACT signature from source code
func (t *[TypeName]) [MethodName]([param1] [Type1], [param2] [Type2]) ([ReturnType], error)
```

**Description**: [What this method does - one clear, technical sentence]

**Parameters**:
- `[param1]` ([Type1]): [Detailed description, constraints, valid values]
- `[param2]` ([Type2]): [Detailed description, nil handling if applicable]

**Returns**:
- `[ReturnType]`: [Description of return value, what it contains]
- `error`: [Error conditions - be specific]
  - Returns error if [specific condition 1]
  - Returns error if [specific condition 2]
  - Returns [ErrorType] if [specific condition 3]

**Example**:
```[language]
// VERIFIED usage pattern
result, err := instance.[MethodName](value1, value2)
if err != nil {
    // Handle error
    return fmt.Errorf("[operation] failed: %w", err)
}
// result now contains...
```

**Source**: `path/to/file.ext` ([MethodName] method)

---

## Utility Functions

[Document helper or utility functions]

### Function: [FunctionName]

```[language]
// EXACT signature from source code
func [FunctionName]([param1] [Type1]) ([ReturnType], error)
```

**Description**: [What this function does]

**Parameters**:
- `[param1]` ([Type1]): [Description]

**Returns**:
- `[ReturnType]`: [Description]
- `error`: [Error conditions]

**Example**:
```[language]
// VERIFIED example
result, err := [FunctionName](value)
```

**Source**: `path/to/file.ext` ([FunctionName] function)

---

## Constants

[Document public constants and enums]

### Constants: [GroupName]

```[language]
// EXACT definitions from source code
const (
    [ConstantName1] = [value1]  // Description
    [ConstantName2] = [value2]  // Description
    [ConstantName3] = [value3]  // Description
)
```

**Purpose**: [What these constants represent, when to use them]

**Values**:
- `[ConstantName1]`: [When to use this value, what it means]
- `[ConstantName2]`: [When to use this value, what it means]
- `[ConstantName3]`: [When to use this value, what it means]

**Source**: `path/to/file.ext` (constants)

---

## Error Types

[Document custom error types]

### Type: [ErrorType]

```[language]
// EXACT definition from source code
type [ErrorType] struct {
    [Field1] [Type1]
    [Field2] [Type2]
}
```

**Purpose**: [What error condition this represents]

**Fields**:
- `[Field1]` ([Type1]): [Description]
- `[Field2]` ([Type2]): [Description]

**When Returned**: [Which methods return this error and under what conditions]

**Handling**:
```[language]
// VERIFIED error handling pattern
err := SomeMethod()
if errors.Is(err, [ErrorType]{}) {
    // Handle this specific error
}
```

**Source**: `path/to/file.ext` ([ErrorType] type)

---

## Comprehensive Examples

[Provide complete, working examples of common use cases]

### Example: [Use Case Name]

**Scenario**: [What this example demonstrates]

```[language]
// COMPLETE, VERIFIED example
import (
    "[actual/import/path]"
    "[other/imports]"
)

func Example[UseCase]() {
    // Setup
    [setup code]

    // Main operation
    [usage code with error handling]

    // Result handling
    [result usage]
}
```

**Expected Output**:
```
[Actual output when example is run]
```

---

### Example: [Another Use Case]

[Repeat pattern for other common scenarios]

---

## Configuration

[If the package/module has configuration options]

### Type: [ConfigType]

```[language]
// EXACT definition from source code
type [ConfigType] struct {
    [Option1] [Type1] `tag:"value"` // Description
    [Option2] [Type2] `tag:"value"` // Description
}
```

**Configuration Options**:
- `[Option1]` ([Type1]): [Description, default value, valid range]
- `[Option2]` ([Type2]): [Description, default value]

**Example Configuration**:
```[language]
// VERIFIED configuration
config := &[ConfigType]{
    [Option1]: [value1],
    [Option2]: [value2],
}
```

**Source**: `path/to/file.ext` ([ConfigType] type)

---

## Best Practices

[Optional section for recommended usage patterns - keep technical, avoid marketing]

1. **[Practice 1]**: [Technical recommendation with rationale]
2. **[Practice 2]**: [Technical recommendation with rationale]
3. **[Practice 3]**: [Technical recommendation with rationale]

---

## Troubleshooting

[Optional section for common issues - link to more detailed how-to guides if available]

### Issue: [Problem Description]
**Symptom**: [What the user sees]
**Cause**: [Why it happens - technical explanation]
**Solution**: [How to fix - link to detailed how-to if available]

---

## Related Documentation

[Links to other documentation types - maintain Diátaxis separation]

- **Tutorials**: [Link to tutorial-writer created docs] - Learn how to get started
- **How-To Guides**: [Link to migration-guide-writer created docs] - Solve specific problems
- **Explanation**: [Link to explanation docs] - Understand the design and architecture

---

## Documentation Metadata

**Last Updated**: [YYYY-MM-DD]
**Source Code Version**: [Commit SHA or version tag]
**Verification Status**: ✅ All APIs verified against source code
**Verification Date**: [YYYY-MM-DD]

**Source Files**:
- `path/to/source/file1.ext`
- `path/to/source/file2.ext`
- `path/to/source/file3.ext`

---

## Verification Checklist

**Completed verification on [Date]:**

### Source Code Verification (P0 - CRITICAL)
- [ ] Every documented method exists in source code
- [ ] All method signatures exactly match source
- [ ] All parameter types match source
- [ ] All return types match source
- [ ] Parameter names match source
- [ ] All type definitions exactly match source

### Example Verification (P0 - CRITICAL)
- [ ] All code examples use real imports
- [ ] All code examples use verified API signatures
- [ ] No fabricated methods in examples
- [ ] Examples tested and work correctly

### Completeness (P1 - HIGH)
- [ ] All public methods documented
- [ ] All public types documented
- [ ] All public constants documented
- [ ] Source file references included
- [ ] Error conditions documented

### Quality (P2 - MEDIUM)
- [ ] No marketing language
- [ ] No decorative emojis
- [ ] Consistent structure across entries
- [ ] Technical descriptions only
- [ ] Source references use method names not line numbers

---

**Document created using**: `api-doc-writer` skill
