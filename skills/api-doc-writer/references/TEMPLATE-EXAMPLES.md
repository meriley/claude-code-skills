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
````

**Purpose**: [What this type represents]

**Fields**:

- `Field1` (Type1): [Detailed description, constraints, default values]
- `Field2` (Type2): [Detailed description]

**Source**: `path/to/file.go` (TypeName type)

````

#### Functions/Methods

```markdown
### Method: TypeName.MethodName

```go
// EXACT signature from [source file:MethodName]
func (t *TypeName) MethodName(param1 Type1, param2 Type2) (ReturnType, error)
````

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

````

#### Constants/Enums

```markdown
### Constants: GroupName

```go
// EXACT definitions from [source file]
const (
    ConstantName1 = "value1"  // Description
    ConstantName2 = "value2"  // Description
)
````

**Purpose**: [What these constants represent]

**Values**:

- `ConstantName1`: [When to use this value]
- `ConstantName2`: [When to use this value]

**Source**: `path/to/file.go` (constants)

````
