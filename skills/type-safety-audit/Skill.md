---
name: TypeScript Type Safety Audit
description: Audits TypeScript for type safety: no any usage, branded types for IDs, runtime validation, proper type narrowing. For TypeScript code reviews.
version: 1.0.0
---

# ⚠️ MANDATORY: TypeScript Type Safety Audit Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Before committing TypeScript code (as part of quality-check)
2. Before creating pull requests with TypeScript changes
3. When adding new API endpoints or resolvers
4. After TypeScript upgrades or config changes
5. When investigating type-related runtime bugs

**This skill is MANDATORY because:**
- Prevents type safety escape hatches from entering codebase (ZERO TOLERANCE)
- Ensures compile-time catching of bugs before runtime (CRITICAL)
- Enforces runtime validation at API boundaries (CRITICAL)
- Prevents ID mixing and type confusion bugs (HIGH)
- Maintains type system integrity across codebase

**ENFORCEMENT:**

**P0 Violations (Critical - Immediate Failure):**
- Use of `any` type anywhere in code (ZERO TOLERANCE)
- Missing runtime validation at API boundaries (CRITICAL RISK)
- Type assertions without validation (dangerous)
- Implicit `any` from missing type annotations
- Mixing different ID types without branded types

**P1 Violations (High - Quality Failure):**
- Missing null/undefined checks before property access
- Improper type narrowing (assertions vs guards)
- Missing branded types for IDs (high bug risk)
- Unconstrained generics without safety
- Missing type guards in conditionals

**P2 Violations (Medium - Efficiency Loss):**
- Enum usage instead of union types
- Not using nullish coalescing for defaults
- Missing optional chaining usage

**Blocking Conditions:**
- ZERO `any` types allowed (refactor or justify with comment)
- All external data must be validated with Zod/io-ts
- All ID types must use branded types
- All generics must have proper constraints
- tsconfig.json must have `strict: true`

---

## Purpose

Audit TypeScript code for type safety best practices. This skill ensures the type system is leveraged correctly to catch bugs at compile-time, prevent runtime type errors, and maintain type safety across API boundaries.

## When to Use This Skill

- **Before committing TypeScript code** - Prevent type safety violations
- **Code review preparation** - Verify type hygiene before PRs
- **API boundary reviews** - Verify external data validation
- **Debugging type-related bugs** - When runtime errors suggest type issues

## What This Skill Checks

### 1. `any` Type Usage (Priority: CRITICAL)
**Golden Rule**: ZERO tolerance for `any` type. Use `unknown` for truly unknown types.

**Anti-Pattern**:
```typescript
// ❌ CRITICAL: Type safety escape hatch
function processData(data: any) {
  return data.value.nested.property; // No compile-time checking!
}

// ❌ Implicit any
function parseJSON(json) { // Parameter implicitly 'any'
  return JSON.parse(json);
}
```

**Correct Patterns**:
```typescript
// ✅ Use unknown with type guard
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
```

### 2. Runtime Validation at Boundaries (Priority: CRITICAL)
**Golden Rule**: Never trust external data. Validate at API boundaries, database reads, message consumers.

**Anti-Pattern**:
```typescript
// ❌ Trusting external API response
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  const data = await response.json();
  return data as User; // Dangerous cast! No validation
}
```

**Correct with Zod**:
```typescript
// ✅ Runtime validation
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string(),
  email: z.string().email(),
  role: z.enum(['admin', 'user'])
});

type User = z.infer<typeof UserSchema>;

async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  const data = await response.json();
  return UserSchema.parse(data); // Validation with error on invalid
}
```

### 3. Branded Types for IDs (Priority: HIGH)
**Golden Rule**: Use branded types to prevent mixing task IDs with user IDs.

**Anti-Pattern**:
```typescript
// ❌ All IDs are just strings
type TaskId = string;
type UserId = string;

function assignTask(taskId: TaskId, userId: UserId) {
  return api.assign(userId, taskId); // Swapped! No compile error
}
```

**Correct with Branded Types**:
```typescript
// ✅ Branded types prevent mixing
type TaskId = string & { readonly __brand: 'TaskId' };
type UserId = string & { readonly __brand: 'UserId' };

function taskId(id: string): TaskId {
  return id as TaskId;
}

function assignTask(taskId: TaskId, userId: UserId) {
  return api.assign(userId, taskId); // ❌ Compile error if swapped!
}
```

### 4. Type Narrowing and Guards (Priority: HIGH)
**Golden Rule**: Use proper type guards instead of assertions.

**Anti-Pattern**:
```typescript
// ❌ Unsafe assertion
function processValue(value: string | number) {
  const str = value as string; // Could be number!
  return str.toUpperCase();
}
```

**Correct with Type Guard**:
```typescript
// ✅ Type guard function
function isString(value: unknown): value is string {
  return typeof value === 'string';
}

function processValue(value: string | number) {
  if (isString(value)) {
    return value.toUpperCase(); // Type-safe
  }
  return value.toString();
}
```

### 5. Null/Undefined Handling (Priority: HIGH)
**Golden Rule**: Handle null/undefined explicitly with optional chaining.

**Anti-Pattern**:
```typescript
// ❌ Not handling undefined
function getUserName(user: User | undefined) {
  return user.name; // Error if user is undefined
}
```

**Correct**:
```typescript
// ✅ Optional chaining and nullish coalescing
function getUserName(user: User | undefined): string {
  return user?.name ?? 'Anonymous';
}
```

### 6. Generic Constraints (Priority: MEDIUM)
**Golden Rule**: Add constraints to generics for type-safe operations.

**Anti-Pattern**:
```typescript
// ❌ Unconstrained generic
function getId<T>(item: T) {
  return item.id; // Error: property doesn't exist on T
}
```

**Correct**:
```typescript
// ✅ Constrained generic
function getId<T extends { id: string }>(item: T): string {
  return item.id; // Type-safe
}
```

## Step-by-Step Execution

### Step 1: Identify TypeScript Files
```bash
find . -name "*.ts" -not -name "*.d.ts" -not -name "*.test.ts" -not -path "*/node_modules/*"
```

### Step 2: Read TypeScript Files
Examine files focusing on:
- Type annotations and signatures
- Generic usage and constraints
- Type assertions (as keyword)
- API boundary functions
- null/undefined handling

### Step 3: Analyze Type Safety

**A. `any` Type Usage**
1. Search for explicit `any` keyword
2. Check for implicit `any` (functions without type annotations)
3. Flag all instances with line numbers
4. Suggest `unknown` or proper types

**B. Runtime Validation**
1. Find API boundary functions (fetch, API routes, DB queries)
2. Check for validation libraries (Zod, io-ts)
3. Flag missing validation at boundaries
4. Suggest validation implementation

**C. Branded Type Opportunities**
1. Find type aliases for strings used as IDs
2. Identify functions with multiple ID parameters
3. Check for potential ID mixing
4. Suggest branded type implementation

**D. Type Guards vs Assertions**
1. Find all `as` type assertions
2. Find all `!` non-null assertions
3. Check if type guard would be safer
4. Suggest type guard implementation

**E. Null Handling**
1. Check for optional chaining usage
2. Verify null/undefined checks before access
3. Flag potential null reference errors
4. Suggest nullish coalescing

**F. Generic Constraints**
1. Find generic type parameters
2. Check if constraints would enable operations
3. Verify constraint completeness
4. Suggest additional constraints

### Step 4: Verify tsconfig.json
```json
{
  "compilerOptions": {
    "strict": true,                  // ✅ REQUIRED
    "noImplicitAny": true,          // ✅ REQUIRED
    "strictNullChecks": true,       // ✅ REQUIRED
    "noUnusedLocals": true,         // ✅ Recommended
    "noUnusedParameters": true,     // ✅ Recommended
    "noImplicitReturns": true       // ✅ Recommended
  }
}
```

### Step 5: Generate Report

```markdown
## Type Safety Audit: [file_path]

### 🚨 CRITICAL Issues

#### `any` Type Usage
- **Function**: `processData` ([file:line])
  - **Code**: `function processData(data: any)`
  - **Risk**: Runtime errors from accessing non-existent properties
  - **Fix**: Use `unknown` with type guard

#### Missing Runtime Validation
- **Function**: `fetchUser` ([file:line])
  - **Code**: `return await response.json() as User`
  - **Risk**: Runtime error if API returns unexpected structure
  - **Fix**: Add Zod schema validation

#### Unsafe Type Assertion
- **Function**: `getUserId` ([file:line])
  - **Code**: `const id = value as string`
  - **Risk**: Runtime error if value is not string
  - **Fix**: Use type guard: `if (typeof value === 'string')`

### ⚠️ HIGH Priority Issues

#### Missing Branded Types
- **Issue**: TaskId and UserId both typed as `string`
  - **Risk**: Can accidentally swap IDs
  - **Fix**: Implement branded types

#### Improper Null Handling
- **Function**: `getUser` ([file:line])
  - **Code**: `user.name` where user might be undefined
  - **Risk**: "Cannot read property 'name' of undefined"
  - **Fix**: Use optional chaining: `user?.name ?? 'default'`

### ℹ️ MEDIUM Priority Issues

#### Missing Generic Constraint
- **Function**: `processItems` ([file:line])
  - **Code**: `function processItems<T>(items: T[])`
  - **Impact**: Cannot safely access item properties
  - **Fix**: Add constraint: `<T extends { id: string }>`
```

### Step 6: Summary Statistics

```markdown
## Summary
- Files audited: X
- Type safety issues: Z
  - CRITICAL: A (must fix before commit)
  - HIGH: B (should fix before commit)
  - MEDIUM: C (fix during refactoring)
- Type-safe functions: W
- tsconfig strict mode: [✅/❌]
```

## Integration Points

This skill is invoked by:
- **`quality-check`** skill for TypeScript projects
- **`safe-commit`** skill (via quality-check)

## Anti-Patterns

### ❌ Anti-Pattern: Using `any` Type

**Wrong approach:**
```typescript
function process(data: any) {
  return data.value;
}
```

**Correct approach:**
```typescript
function process(data: unknown) {
  if (typeof data === 'object' && data !== null && 'value' in data) {
    return (data as any).value; // Only cast after validation
  }
  throw new Error('Invalid data');
}
```

---

### ❌ Anti-Pattern: Trusting External Data Without Validation

**Wrong approach:**
```typescript
const user = await fetch('/api/user').then(r => r.json()) as User;
```

**Correct approach:**
```typescript
const user = UserSchema.parse(
  await fetch('/api/user').then(r => r.json())
);
```

---

## References

**Based on:**
- CLAUDE.md Section 3 (Available Skills Reference - type-safety-audit)
- TypeScript Handbook: Strict Mode
- Branded Types: https://egghead.io/blog/using-branded-types-in-typescript
- Zod Validation: https://zod.dev/

**Related skills:**
- `quality-check` - Invokes this skill for TypeScript
- `n-plus-one-detection` - Works with TypeScript/GraphQL
