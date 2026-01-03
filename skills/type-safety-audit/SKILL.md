---
name: type-safety-audit
description: Audits TypeScript code for type safety best practices - no any usage, branded types for IDs, runtime validation, proper type narrowing. Use before committing TypeScript code or during type system reviews.
version: 1.0.0
---

# TypeScript Type Safety Audit Skill

## Purpose

Audit TypeScript code for type safety best practices. This skill ensures the type system is leveraged correctly to catch bugs at compile-time, prevent runtime type errors, and maintain type safety across API boundaries.

## When to Use This Skill

- **Before committing TypeScript code** - Prevent type safety violations
- **Code review preparation** - Verify type hygiene before PRs
- **After TypeScript upgrades** - Ensure strict mode compliance
- **Debugging type-related bugs** - When runtime errors suggest type issues
- **API boundary reviews** - Verify external data validation

## What This Skill Checks

### 1. `any` Type Usage (Priority: CRITICAL)

**Golden Rule**: ZERO tolerance for `any` type. Use `unknown` for truly unknown types, proper types otherwise.

**Anti-Pattern**:

```typescript
// ❌ CRITICAL: Type safety escape hatch
function processData(data: any) {
  return data.value.nested.property; // No compile-time checking!
}

// ❌ Implicit any
function parseJSON(json) {
  // Parameter 'json' implicitly has 'any' type
  return JSON.parse(json);
}

// ❌ any in generic
const items: any[] = getItems();
```

**Correct Patterns**:

```typescript
// ✅ Use unknown for truly unknown types
function processData(data: unknown) {
  if (isValidData(data)) {
    return data.value.nested.property; // Type-safe after narrowing
  }
  throw new Error("Invalid data structure");
}

// ✅ Explicit types
function parseJSON(json: string): unknown {
  return JSON.parse(json);
}

// ✅ Proper generic constraint
const items: Item[] = getItems();

// ✅ Generic with constraint when type truly varies
function processItems<T extends { id: string }>(items: T[]) {
  return items.map((item) => item.id);
}
```

**Acceptable Exceptions** (must have comment explaining why):

```typescript
// Acceptable: Third-party library without types
// @ts-expect-error - legacy library lacks types, migration planned
const result = legacyLib.doSomething();

// Acceptable: Gradual migration comment
// TODO(TECH-123): Replace any with proper type after protobuf update
function processLegacyProto(proto: any) { ... }
```

### 2. Branded Types for IDs (Priority: HIGH)

**Golden Rule**: Use branded types for different ID types to prevent mixing task IDs with user IDs, etc.

**Anti-Pattern**:

```typescript
// ❌ All IDs are just strings - can mix them up
type TaskId = string;
type UserId = string;
type PartnerId = string;

function assignTask(taskId: TaskId, userId: UserId) {
  // BUG: Can accidentally pass userId as taskId
  return api.assign(userId, taskId); // Swapped! No compile error
}
```

**Correct with Branded Types**:

```typescript
// ✅ Branded types prevent mixing
type TaskId = string & { readonly __brand: "TaskId" };
type UserId = string & { readonly __brand: "UserId" };
type PartnerId = string & { readonly __brand: "PartnerId" };

// Type guard constructors
function taskId(id: string): TaskId {
  return id as TaskId;
}

function userId(id: string): UserId {
  return id as UserId;
}

function assignTask(taskId: TaskId, userId: UserId) {
  // Compile error if arguments swapped!
  return api.assign(userId, taskId); // TypeScript catches the swap
}

// Usage
const task = taskId("task-123");
const user = userId("user-456");
assignTask(task, user); // ✅ Correct
assignTask(user, task); // ❌ Compile error!
```

### 3. Runtime Validation at Boundaries (Priority: CRITICAL)

**Golden Rule**: Never trust external data. Validate at API boundaries, database reads, message queue consumers.

**Anti-Pattern**:

```typescript
// ❌ CRITICAL: Trusting external API response
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  const data = await response.json();
  return data as User; // Dangerous cast! No validation
}

// ❌ Trusting database result
async function getTask(id: string): Promise<Task> {
  const row = await db.query("SELECT * FROM tasks WHERE id = ?", [id]);
  return row as Task; // Assumes database schema matches type
}
```

**Correct with Runtime Validation**:

```typescript
// ✅ Runtime validation with Zod
import { z } from "zod";

const UserSchema = z.object({
  id: z.string(),
  email: z.string().email(),
  name: z.string(),
  role: z.enum(["admin", "user", "viewer"]),
});

type User = z.infer<typeof UserSchema>;

async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  const data = await response.json();

  // Runtime validation - throws if data doesn't match schema
  return UserSchema.parse(data);
}

// ✅ Alternative with io-ts
import * as t from "io-ts";
import { isRight } from "fp-ts/Either";

const TaskCodec = t.type({
  id: t.string,
  title: t.string,
  status: t.keyof({ open: null, closed: null, in_progress: null }),
});

type Task = t.TypeOf<typeof TaskCodec>;

async function getTask(id: string): Promise<Task> {
  const row = await db.query("SELECT * FROM tasks WHERE id = ?", [id]);
  const decoded = TaskCodec.decode(row);

  if (isRight(decoded)) {
    return decoded.right;
  }
  throw new Error(`Invalid task data: ${JSON.stringify(row)}`);
}
```

### 4. Type Narrowing and Guards (Priority: HIGH)

**Golden Rule**: Use proper type guards instead of type assertions. Let TypeScript infer narrowed types.

**Anti-Pattern**:

```typescript
// ❌ Unsafe type assertion
function processValue(value: string | number) {
  const str = value as string; // Unsafe! Could be number
  return str.toUpperCase();
}

// ❌ No type narrowing
function handleResponse(response: SuccessResponse | ErrorResponse) {
  if (response.success) {
    // TypeScript doesn't know this is SuccessResponse
    return response.data.value; // Error: data might not exist
  }
}
```

**Correct with Type Guards**:

```typescript
// ✅ Type guard function
function isString(value: unknown): value is string {
  return typeof value === "string";
}

function processValue(value: string | number) {
  if (isString(value)) {
    return value.toUpperCase(); // TypeScript knows it's string
  }
  return value.toString();
}

// ✅ Discriminated union
type SuccessResponse = { success: true; data: { value: string } };
type ErrorResponse = { success: false; error: string };
type Response = SuccessResponse | ErrorResponse;

function handleResponse(response: Response) {
  if (response.success) {
    // TypeScript narrows to SuccessResponse
    return response.data.value; // ✅ Type-safe
  } else {
    // TypeScript narrows to ErrorResponse
    throw new Error(response.error); // ✅ Type-safe
  }
}

// ✅ Built-in type guards
function processData(data: unknown) {
  if (Array.isArray(data)) {
    return data.length; // TypeScript knows it's array
  }
  if (data instanceof Error) {
    return data.message; // TypeScript knows it's Error
  }
}
```

### 5. Strict Null Checking (Priority: HIGH)

**Golden Rule**: Handle null/undefined explicitly. Use optional chaining and nullish coalescing.

**Anti-Pattern**:

```typescript
// ❌ Not handling null/undefined
function getUserName(user: User | undefined) {
  return user.name; // Error if user is undefined
}

// ❌ Loose equality
if (value == null) { ... } // Checks both null and undefined (can be confusing)
```

**Correct Null Handling**:

```typescript
// ✅ Optional chaining
function getUserName(user: User | undefined): string {
  return user?.name ?? "Anonymous";
}

// ✅ Explicit null check
function processUser(user: User | null) {
  if (user === null) {
    throw new Error("User not found");
  }
  // TypeScript knows user is not null here
  return user.name;
}

// ✅ Non-null assertion (only when you're certain)
function getConfigValue(key: string): string {
  const value = config.get(key);
  // Only use ! when you're absolutely certain it exists
  return value!; // Better: validate at config load time
}
```

### 6. Proper Generic Constraints (Priority: MEDIUM)

**Golden Rule**: Add constraints to generics to enable type-safe operations.

**Anti-Pattern**:

```typescript
// ❌ Unconstrained generic
function getId<T>(item: T) {
  return item.id; // Error: Property 'id' does not exist on type 'T'
}

// ❌ Too loose
function process<T extends any>(items: T[]) {
  return items.map((i) => i.value); // Error: value might not exist
}
```

**Correct with Constraints**:

```typescript
// ✅ Constrained generic
function getId<T extends { id: string }>(item: T): string {
  return item.id; // Type-safe
}

// ✅ Multiple constraints
function compare<T extends { id: string; timestamp: number }>(
  a: T,
  b: T,
): number {
  return a.timestamp - b.timestamp;
}

// ✅ Generic with branded type
function processTasks<T extends { id: TaskId }>(tasks: T[]): TaskId[] {
  return tasks.map((t) => t.id);
}
```

### 7. Enum Usage (Priority: LOW)

**Guidance**: Prefer union types or const assertions over enums for better type inference.

**Legacy Pattern (acceptable but not preferred)**:

```typescript
// ⚠️ Acceptable but prefer union types
enum TaskStatus {
  Open = "open",
  InProgress = "in_progress",
  Closed = "closed",
}
```

**Preferred Patterns**:

```typescript
// ✅ Union type (better type inference)
type TaskStatus = "open" | "in_progress" | "closed";

// ✅ Const assertion (when you need an object)
const TaskStatus = {
  Open: "open",
  InProgress: "in_progress",
  Closed: "closed",
} as const;

type TaskStatus = (typeof TaskStatus)[keyof typeof TaskStatus];
// Type is: 'open' | 'in_progress' | 'closed'
```

## Step-by-Step Execution

### Step 1: Identify TypeScript Files

```bash
# Find all TypeScript files (exclude declarations and tests initially)
find . -name "*.ts" -not -name "*.d.ts" -not -name "*.test.ts" -not -path "*/node_modules/*"
```

### Step 2: Read TypeScript Files

Use Read tool to examine files, focusing on:

- Type annotations
- Generic usage
- API boundary functions
- Type assertions and guards
- null/undefined handling

### Step 3: Analyze Type Safety

For each file, check:

**A. `any` Type Usage**

1. Search for explicit `any` keyword
2. Check for implicit `any` (functions without parameter types)
3. Verify `any[]` usage
4. Flag all instances with context
5. Suggest `unknown` or proper types

**B. Branded Type Opportunities**

1. Find type aliases for strings used as IDs
2. Identify functions accepting multiple ID parameters
3. Check if IDs can be accidentally mixed
4. Suggest branded type implementation

**C. Runtime Validation**

1. Find API boundary functions (fetch, API routes, DB queries)
2. Check for validation libraries (Zod, io-ts, Joi)
3. Identify type assertions without validation
4. Flag missing validation at boundaries

**D. Type Guards vs Assertions**

1. Find all `as` type assertions
2. Find all `!` non-null assertions
3. Check if type guard would be safer
4. Verify discriminated unions use type narrowing

**E. Null Handling**

1. Check for optional chaining usage
2. Verify null/undefined checks before access
3. Flag potential null reference errors
4. Suggest nullish coalescing where appropriate

**F. Generic Constraints**

1. Find generic type parameters
2. Check if constraints would enable operations
3. Verify constraint completeness
4. Suggest additional constraints

### Step 4: Generate Report

```markdown
## Type Safety Audit: [file_path]

### ✅ Type-Safe Code

- `fetchUser()` ([file:line]) - Runtime validation with Zod
- `TaskId` type ([file:line]) - Branded type implementation

### 🚨 CRITICAL Issues

#### `any` Type Usage

- **Location**: `processData` function ([file:line])
  - **Issue**: `any` parameter disables type checking
  - **Code**: `function processData(data: any)`
  - **Risk**: Runtime errors from accessing non-existent properties
  - **Fix**: Use `unknown` with type guard or define specific type

#### Missing Runtime Validation

- **Location**: `fetchExternalAPI` function ([file:line])
  - **Issue**: Casting external API response without validation
  - **Code**: `return await response.json() as User`
  - **Risk**: Runtime errors if API returns unexpected structure
  - **Fix**: Add Zod schema validation

#### Unsafe Type Assertion

- **Location**: `getUserId` function ([file:line])
  - **Issue**: Type assertion without validation
  - **Code**: `const id = value as string`
  - **Risk**: Runtime error if value is not string
  - **Fix**: Use type guard: `if (typeof value === 'string')`

### ⚠️ HIGH Priority Issues

#### Missing Branded Types for IDs

- **Location**: Type definitions ([file:line])
  - **Issue**: TaskId and UserId both typed as `string`
  - **Risk**: Can accidentally swap IDs in function calls
  - **Fix**: Implement branded types for ID discrimination

#### Improper Null Handling

- **Location**: `getUser` function ([file:line])
  - **Issue**: Accessing property without null check
  - **Code**: `user.name` where user might be undefined
  - **Risk**: Runtime error: "Cannot read property 'name' of undefined"
  - **Fix**: Use optional chaining: `user?.name ?? 'default'`

### ℹ️ MEDIUM Priority Issues

#### Missing Generic Constraint

- **Location**: `processItems` function ([file:line])
  - **Issue**: Generic `T` has no constraints
  - **Code**: `function processItems<T>(items: T[])`
  - **Impact**: Cannot safely access item properties
  - **Fix**: Add constraint: `<T extends { id: string }>`

#### Enum Usage

- **Location**: TaskStatus enum ([file:line])
  - **Issue**: Using enum instead of union type
  - **Impact**: Less optimal type inference
  - **Suggestion**: Consider union type: `type TaskStatus = 'open' | 'closed'`
```

### Step 5: Provide Fix Examples

For each critical issue:

````markdown
#### Example Fix: Replace `any` with `unknown`

**Before** (no type safety):

```typescript
function processData(data: any) {
  // ❌
  return data.value.nested.property;
}
```
````

**After** (type-safe with guard):

```typescript
interface DataStructure {
  // ✅
  value: {
    nested: {
      property: string;
    };
  };
}

function isDataStructure(data: unknown): data is DataStructure {
  return (
    typeof data === "object" &&
    data !== null &&
    "value" in data &&
    typeof (data as any).value === "object"
    // Add more thorough checks...
  );
}

function processData(data: unknown) {
  if (!isDataStructure(data)) {
    throw new Error("Invalid data structure");
  }
  return data.value.nested.property; // Type-safe!
}
```

**Why**: Catches type errors at compile-time, provides clear error messages, enables autocomplete.

````

### Step 6: TypeScript Config Verification

Check `tsconfig.json` for strict mode:

```json
{
  "compilerOptions": {
    "strict": true,                  // ✅ Required
    "noImplicitAny": true,          // ✅ Required
    "strictNullChecks": true,       // ✅ Required
    "strictFunctionTypes": true,    // ✅ Required
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "noUnusedLocals": true,         // Recommended
    "noUnusedParameters": true,     // Recommended
    "noImplicitReturns": true       // Recommended
  }
}
````

### Step 7: Summary Statistics

```markdown
## Summary

- Files audited: X
- Functions checked: Y
- Type safety issues: Z
  - CRITICAL (any usage): A
  - CRITICAL (missing validation): B
  - HIGH (null handling): C
  - MEDIUM (generic constraints): D
- Type-safe functions: W
- tsconfig.json strict mode: [✅/❌]
```

## Integration Points

This skill is invoked by:

- **`quality-check`** skill for TypeScript projects
- **`safe-commit`** skill (via quality-check)
- Directly when reviewing type safety

## Exit Criteria

- All TypeScript files analyzed
- Report generated with specific type safety violations
- Fix examples provided for all critical issues
- tsconfig.json verified for strict mode
- CRITICAL issues should block commit

## Example Usage

```bash
# Manual invocation
/skill type-safety-audit

# Automatic invocation via quality-check
/skill quality-check  # Detects TypeScript, invokes type-safety-audit
```

## References

- TypeScript Handbook: https://www.typescriptlang.org/docs/handbook/
- Branded Types: https://egghead.io/blog/using-branded-types-in-typescript
- Zod Validation: https://zod.dev/
- io-ts: https://github.com/gcanti/io-ts
- TypeScript Strict Mode: https://www.typescriptlang.org/tsconfig#strict
- Hermes Code Reviewer: Type Safety Patterns
