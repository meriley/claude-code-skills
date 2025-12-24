# [API/Module/Package Name] Reference

## Overview

[1-2 sentence description of what this API/module does. Technical description only - no marketing language.]

**Version**: [Specific version being documented]
**Source**: [Path to source files]
**Last Verified**: [Date when APIs were verified against source]

---

## When to Use

[Brief bulleted list of scenarios when this API should be used]

- Use when [scenario 1]
- Use when [scenario 2]
- Use when [scenario 3]

---

## Installation / Import

```[language]
// Complete import statement (verified against source)
import { ExactAPIName } from 'verified/module/path';

// OR for other languages:
// const { ExactAPIName } = require('verified/module/path');
// import verified.module.path.ExactAPIName
```

**Requirements**:
- [Dependency 1]: [Version]
- [Dependency 2]: [Version]

---

## Types / Interfaces

### `TypeName`

**Source**: `path/to/source.ts` → `TypeName` interface

```[language]
// Exact type definition from source (copy exactly)
interface TypeName {
  property1: string;           // [Description from source]
  property2: number;           // [Description from source]
  optionalProp?: boolean;      // [Description from source]
}
```

**Properties**:
- **`property1`** (`string`) - [Description extracted from source code or comments]
- **`property2`** (`number`) - [Description extracted from source code or comments]
- **`optionalProp`** (`boolean`, optional) - [Description extracted from source code or comments]

---

## Functions / Methods

### `functionName`

**Source**: `path/to/source.ts` → `functionName` function

**Signature**:
```[language]
// Exact signature from source (copy character-for-character)
function functionName<T extends Constraint>(
  param1: Type1,
  param2: Type2,
  options?: OptionsType
): ReturnType
```

**Type Parameters**:
- **`T extends Constraint`** - [Description of generic type constraint]

**Parameters**:
- **`param1`** (`Type1`) - [Description from source. Include constraints if any: "Must be non-empty", "Range: 0-100", etc.]
- **`param2`** (`Type2`) - [Description from source]
- **`options`** (`OptionsType`, optional) - [Description from source]
  - **`options.field1`** (`type`) - [Sub-field description]
  - **`options.field2`** (`type`) - [Sub-field description]

**Returns**: `ReturnType` - [Description of what is returned]

**Errors**: *(extracted from error handling in source)*
- **`ValidationError`** - Thrown when [condition from source code]
- **`ProcessingError`** - Thrown when [condition from source code]

**Example**:
```[language]
// Complete, tested example with all imports
import { functionName, Type1, Type2 } from 'verified/path';

// Minimal example showing basic usage
const param1: Type1 = /* ... */;
const param2: Type2 = /* ... */;

const result = functionName(param1, param2);
console.log(result); // Expected output: [actual output from testing]
```

**See Also**:
- [`relatedFunction`](#relatedfunction) - Related functionality
- [How to [accomplish task]](link-to-howto.md) - Problem-solving guide
- [Tutorial: Getting Started](link-to-tutorial.md) - Learning guide

---

### `anotherMethod`

**Source**: `path/to/source.ts` → `ClassName.anotherMethod` method

**Signature**:
```[language]
// For class methods, include receiver
class ClassName {
  anotherMethod(param: ParamType): ReturnType
}
```

**Parameters**:
- **`param`** (`ParamType`) - [Description]

**Returns**: `ReturnType` - [Description]

**Example**:
```[language]
// Complete example with setup
import { ClassName } from 'verified/path';

const instance = new ClassName();
const result = instance.anotherMethod(param);
```

---

## Classes

### `ClassName`

**Source**: `path/to/source.ts` → `ClassName` class

```[language]
// Exact class signature from source
class ClassName {
  constructor(config: ConfigType);

  // Public methods (from source)
  method1(param: Type): ReturnType;
  method2(param: Type): ReturnType;

  // Public properties (from source)
  property1: Type;
}
```

**Constructor**:
- **`config`** (`ConfigType`) - [Configuration object description]
  - **`config.field1`** (`type`) - [Description]
  - **`config.field2`** (`type`) - [Description]

**Properties**:
- **`property1`** (`Type`) - [Description from source]

**Methods**: (see individual method sections below)
- [`method1`](#classname-method1) - [Brief description]
- [`method2`](#classname-method2) - [Brief description]

**Example**:
```[language]
// Complete example showing instantiation and usage
import { ClassName, ConfigType } from 'verified/path';

const config: ConfigType = {
  field1: 'value',
  field2: 42
};

const instance = new ClassName(config);
const result = instance.method1(param);
```

---

## Constants / Enums

### `CONSTANT_NAME`

**Source**: `path/to/source.ts` → `CONSTANT_NAME` constant

```[language]
// Exact value from source
const CONSTANT_NAME = 'exact-value-from-source';
```

**Type**: `string`
**Value**: `'exact-value-from-source'`
**Description**: [Purpose of this constant from source comments]

---

### `EnumName`

**Source**: `path/to/source.ts` → `EnumName` enum

```[language]
// Exact enum from source
enum EnumName {
  VALUE_ONE = 'value-one',
  VALUE_TWO = 'value-two',
  VALUE_THREE = 'value-three'
}
```

**Values**:
- **`VALUE_ONE`** (`'value-one'`) - [Description from source]
- **`VALUE_TWO`** (`'value-two'`) - [Description from source]
- **`VALUE_THREE`** (`'value-three'`) - [Description from source]

**Example**:
```[language]
import { EnumName } from 'verified/path';

const status = EnumName.VALUE_ONE;
```

---

## Error Handling

### Error Types

This API can throw the following errors (extracted from source code error handling):

#### `ValidationError`

**Source**: `path/to/source.ts` → `ValidationError` class

**Thrown When**:
- [Condition 1 from source code]
- [Condition 2 from source code]

**Properties**:
- **`message`** (`string`) - Error description
- **`field`** (`string`) - Field that failed validation (if applicable)

**Example**:
```[language]
try {
  functionName(invalidParam);
} catch (error) {
  if (error instanceof ValidationError) {
    console.error(`Validation failed: ${error.message}`);
  }
}
```

#### `ProcessingError`

**Source**: `path/to/source.ts` → `ProcessingError` class

**Thrown When**:
- [Condition from source code]

**Properties**:
- **`message`** (`string`) - Error description
- **`code`** (`string`) - Error code for programmatic handling

---

## Advanced Usage

### [Advanced Pattern 1]

[Brief description of advanced usage pattern]

**Example**:
```[language]
// Complete, tested advanced example
import { /* verified imports */ } from 'verified/path';

// Advanced usage showing [pattern]
// [Step-by-step code with comments]
```

**When to Use**:
- [Scenario where this pattern is appropriate]

**Trade-offs**:
- Advantage: [Factual advantage from source/benchmarks]
- Disadvantage: [Factual limitation from source]

---

## Performance Considerations

[ONLY include this section if you have benchmark data]

### Complexity

- **Time Complexity**: O(n) *(from algorithm analysis in source)*
- **Space Complexity**: O(1) *(from algorithm analysis in source)*

### Benchmarks

[ONLY include benchmarks if you have actual benchmark results]

**Hardware**: [Specific hardware used for benchmarking]
**Methodology**: [How benchmark was performed]
**Date**: [When benchmark was run]

| Operation | Items | Time | Throughput |
|-----------|-------|------|------------|
| [operation] | 1,000 | [X]ms | [Y] ops/sec |
| [operation] | 10,000 | [X]ms | [Y] ops/sec |

**Source**: [Link to benchmark code/results]

---

## Migration Notes

[ONLY include if documenting a new version with breaking changes]

### Breaking Changes from v[X] to v[Y]

**[Change 1]**: [Description of breaking change from git diff]

```[language]
// OLD (v[X]) - Verified against old source
oldAPI(param1, param2);

// NEW (v[Y]) - Verified against new source
newAPI({ param1, param2 });
```

**Migration**: See [Migration Guide](link-to-migration-guide.md) for detailed steps.

---

## Related Documentation

- **Tutorial**: [Getting Started with [API]](link) - Learn from scratch
- **How-To**: [How to [accomplish task]](link) - Solve specific problems
- **Reference**: [Related API Reference](link) - Related APIs
- **Explanation**: [Understanding [concept]](link) - Design rationale

---

## Verification Metadata

**Last Updated**: [YYYY-MM-DD]
**Verification Status**: ✅ All APIs verified against source
**Source Files Verified**:
- `path/to/source1.ts` - [API elements verified]
- `path/to/source2.ts` - [API elements verified]

**Version Documented**: [Exact version, e.g., v2.3.1]
**Test Suite**: [Link to test files used for verification, if applicable]

---

## Verification Checklist

### P0 - CRITICAL (Must Pass)
- [ ] Every documented method/function exists in source code
- [ ] All signatures match source exactly (params, types, names, order)
- [ ] All return types match source exactly
- [ ] All code examples tested and working
- [ ] All imports are correct and complete
- [ ] No fabricated APIs or methods
- [ ] No unverified performance claims

### P1 - HIGH (Should Pass)
- [ ] Complete coverage of all public APIs
- [ ] All error conditions documented (from source)
- [ ] Source file references included for all APIs
- [ ] No marketing language or buzzwords
- [ ] Technical descriptions only
- [ ] Verification date documented
- [ ] All optional parameters marked as optional

### P2 - MEDIUM (Consider)
- [ ] Consistent structure across all API sections
- [ ] No redundancy between sections
- [ ] Proper cross-linking to related docs (Tutorial/How-To/Explanation)
- [ ] Adequate examples for common use cases
- [ ] Advanced usage patterns documented

---

## Template Usage Notes

**This is a TEMPLATE. Replace all bracketed placeholders with actual content.**

**Sections to include based on API type**:
- Functions-only API: Include "Functions/Methods" section, omit "Classes"
- Class-based API: Include both "Classes" and detailed method sections
- Type-heavy API: Emphasize "Types/Interfaces" section
- Module API: Include "Installation/Import" and organize by category

**Remember**:
1. ✅ Read source code FIRST, then fill in template
2. ✅ Copy signatures exactly (no paraphrasing)
3. ✅ Test all examples before including
4. ✅ Include source references for all APIs
5. ✅ Complete the verification checklist
6. ❌ NO marketing language
7. ❌ NO fabricated methods
8. ❌ NO unverified performance claims

**Diátaxis Type**: Reference (Information-oriented)
**Focus**: WHAT the API does (technical facts only)
**Do NOT include**: Tutorials (use tutorial-writer), How-To guides (use migration-guide-writer), WHY explanations (link to explanation docs)
