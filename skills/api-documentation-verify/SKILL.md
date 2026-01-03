---
name: api-documentation-verify
description: Verifies API documentation against source code to eliminate fabricated claims, ensure accuracy, and validate examples. Zero tolerance for unverified claims, marketing language, or non-runnable code examples. Use before committing API docs or during documentation reviews.
version: 1.0.0
---

# API Documentation Verification Skill

## Purpose

Verify API documentation accuracy against source code. This skill eliminates fabricated API methods, unverified performance claims, non-runnable code examples, and marketing language. Every documented feature must exist in the codebase.

## When to Use This Skill

- **Before committing API documentation** - Verify all claims are accurate
- **After code changes** - Ensure docs reflect current implementation
- **Documentation reviews** - Validate technical accuracy
- **Before releases** - Prevent shipping incorrect documentation
- **When debugging docs issues** - Find discrepancies between docs and code

## What This Skill Checks

### 1. API Method Existence (Priority: CRITICAL)

**Golden Rule**: Every documented API method, class, function, or endpoint MUST exist in source code.

**Fabricated Documentation (CRITICAL FAILURE)**:

```markdown
## UserService API

### Methods

- `getUser(id: string): Promise<User>` - Fetch user by ID
- `updateUserPreferences(userId: string, prefs: object)` - Update preferences
- `deleteUser(id: string): Promise<void>` - Delete user account
```

**Verification Process**:

1. Read source code for `UserService`
2. Extract actual method signatures
3. Compare documented methods against actual methods

**Example Findings**:

```markdown
❌ FABRICATED: `updateUserPreferences` - does not exist in UserService
✅ VERIFIED: `getUser` exists with matching signature
⚠️ MISMATCH: `deleteUser` documented as `Promise<void>`, actually returns `Promise<DeleteResult>`
```

### 2. Parameter and Return Type Accuracy (Priority: CRITICAL)

**Golden Rule**: Documented types must exactly match implementation.

**Inaccurate Documentation**:

```typescript
// Documentation says:
// fetchTasks(partnerId: string): Promise<Task[]>

// Actual implementation:
async fetchTasks(
  partnerId: string,
  filters?: TaskFilters,
  pagination?: Pagination
): Promise<PaginatedResult<Task>>
```

**Issues**:

- ❌ Missing optional parameters `filters` and `pagination`
- ❌ Wrong return type: documented as `Task[]`, actually `PaginatedResult<Task>`

**Verification**:

1. Extract actual function signature from source
2. Compare parameter names, types, and optionality
3. Verify return type matches
4. Flag any discrepancies as CRITICAL

### 3. Code Example Validity (Priority: CRITICAL)

**Golden Rule**: All code examples must be runnable and produce documented results.

**Non-Runnable Example**:

````markdown
## Example: Fetching Tasks

\```typescript
const tasks = await taskService.getTasks();
console.log(tasks);
\```
````

**Verification Issues**:

- ❌ `getTasks()` requires `partnerId` parameter (missing)
- ❌ `taskService` not defined - where does it come from?
- ❌ No error handling - what if API call fails?
- ❌ No type annotations - what type is `tasks`?

**Correct Runnable Example**:

```typescript
import { TaskService } from "./services/TaskService";
import { TaskFilters } from "./types";

async function fetchTasks() {
  const taskService = new TaskService();

  try {
    const result = await taskService.getTasks("partner-123", {
      status: "open",
    } as TaskFilters);

    console.log(`Fetched ${result.items.length} tasks`);
    return result.items;
  } catch (error) {
    console.error("Failed to fetch tasks:", error);
    throw error;
  }
}
```

**Verification Process**:

1. Extract all code examples from documentation
2. Check if examples use actual API signatures
3. Verify imports are correct
4. Test if example could actually run
5. Flag missing error handling, undefined variables

### 4. Performance Claims (Priority: CRITICAL)

**Golden Rule**: ZERO tolerance for unverified performance claims. Must have benchmark data.

**Unverified Claims (CRITICAL FAILURE)**:

```markdown
## Performance

TaskService is highly optimized and provides blazing-fast query performance.
Typical response times are under 10ms for most queries.
```

**Issues**:

- ❌ "Highly optimized" - marketing language, no evidence
- ❌ "Blazing-fast" - meaningless buzzword
- ❌ "Under 10ms" - no benchmark data to support claim
- ❌ "Most queries" - vague, undefined scope

**Acceptable Performance Documentation**:

```markdown
## Performance Characteristics

Based on benchmark tests (see `benchmarks/task-queries.bench.ts`):

| Operation                   | P50   | P95   | P99   | Test Conditions    |
| --------------------------- | ----- | ----- | ----- | ------------------ |
| getTasks (10 items)         | 45ms  | 78ms  | 120ms | Local DB, no cache |
| getTasks (100 items)        | 180ms | 320ms | 450ms | Local DB, no cache |
| getTasks (10 items, cached) | 2ms   | 5ms   | 8ms   | Redis cache hit    |

Benchmarks run on: MacBook Pro M1, 16GB RAM, PostgreSQL 14
See benchmark source for reproduction steps.
```

**Verification**:

1. Search for benchmark files referenced in docs
2. Verify benchmark code exists and is runnable
3. Check if claims match benchmark results
4. Flag any performance claim without benchmark reference

### 5. Configuration Documentation (Priority: HIGH)

**Golden Rule**: Documented configuration options must exist in code.

**Inaccurate Configuration Docs**:

````markdown
## Configuration

\```yaml
taskService:
maxRetries: 3
timeout: 5000
enableCache: true
cacheSize: 1000 # Maximum items in cache
\```
````

**Verification Against Code**:

```typescript
// Actual configuration interface
interface TaskServiceConfig {
  maxRetries: number;
  timeoutMs: number; // ⚠️ Docs say "timeout", code says "timeoutMs"
  enableCache: boolean;
  // ❌ "cacheSize" doesn't exist in config interface
}
```

**Findings**:

- ⚠️ MISMATCH: Field name is `timeoutMs`, not `timeout`
- ❌ FABRICATED: `cacheSize` option doesn't exist

### 6. Error Documentation (Priority: HIGH)

**Golden Rule**: Documented errors must match actual thrown errors.

**Incomplete Error Documentation**:

```markdown
## Errors

- `TaskNotFoundError` - Task with given ID doesn't exist
```

**Actual Code Review**:

```typescript
async function getTask(id: string): Promise<Task> {
  if (!id) {
    throw new ValidationError("Task ID required"); // ❌ Not documented
  }

  const task = await db.tasks.findById(id);
  if (!task) {
    throw new TaskNotFoundError(`Task ${id} not found`); // ✅ Documented
  }

  if (!hasPermission(task)) {
    throw new PermissionError("Insufficient permissions"); // ❌ Not documented
  }

  return task;
}
```

**Findings**:

- ❌ MISSING: `ValidationError` thrown but not documented
- ❌ MISSING: `PermissionError` thrown but not documented
- ✅ VERIFIED: `TaskNotFoundError` documented and thrown

### 7. Marketing Language & Buzzwords (Priority: MEDIUM)

**Golden Rule**: Technical documentation should be objective and precise.

**Unacceptable Language**:

```markdown
❌ "TaskService provides blazing-fast, enterprise-grade performance"
❌ "Our revolutionary API design makes development a breeze"
❌ "Industry-leading scalability and reliability"
❌ "Leverages cutting-edge technology for optimal results"
❌ "Seamlessly integrates with your existing workflow"
❌ "World-class developer experience"
```

**Acceptable Language**:

```markdown
✅ "TaskService implements connection pooling to reduce query latency"
✅ "The API follows REST conventions for HTTP method semantics"
✅ "Supports horizontal scaling via stateless design"
✅ "Compatible with Express, Fastify, and Koa frameworks"
✅ "Provides TypeScript types for compile-time safety"
```

**Banned Words/Phrases**:

- "Blazing fast" / "Lightning fast" / "Blazingly"
- "Revolutionary" / "Game-changing" / "Groundbreaking"
- "Enterprise-grade" / "Industry-leading" / "World-class"
- "Cutting-edge" / "State-of-the-art"
- "Seamlessly" / "Effortlessly"
- "Optimal" / "Best-in-class"
- "Next-generation"
- Unnecessary emojis (🚀 ⚡ 💯 🔥)

### 8. Dependency Version Accuracy (Priority: MEDIUM)

**Golden Rule**: Documented dependencies must match package.json versions.

**Check**:

```markdown
Documentation says:

- Requires Node.js 16+
- Depends on TypeScript ^4.5.0

package.json says:
{
"engines": { "node": ">=18.0.0" }, // ⚠️ Docs say 16+, package.json says 18+
"devDependencies": {
"typescript": "^5.0.0" // ⚠️ Docs say ^4.5.0, actually using ^5.0.0
}
}
```

## Step-by-Step Execution

### Step 1: Identify Documentation Files

```bash
# Find all documentation files
find . -name "*.md" -o -name "README*" -o -name "DOCS*" -o -name "API*"
find . -path "*/docs/*" -name "*.md"
```

### Step 2: Read Documentation Files

Use Read tool to examine documentation, focusing on:

- API method signatures
- Code examples
- Configuration options
- Error documentation
- Performance claims

### Step 3: Extract Claims to Verify

For each documentation file:

**A. API Methods/Functions**

1. Extract all documented methods: names, parameters, return types
2. Note the source file/class they should exist in
3. Create verification checklist

**B. Code Examples**

1. Extract all code blocks from documentation
2. Note expected imports and setup
3. Identify what needs verification

**C. Configuration**

1. Extract all configuration examples
2. Note expected config fields and types
3. List what needs verification

**D. Performance Claims**

1. Extract all statements about speed, latency, throughput
2. Note if benchmark reference provided
3. Flag unsupported claims

### Step 4: Verify Against Source Code

**A. Method Existence and Signatures**

```bash
# Find the source file mentioned in docs
Read [source_file_path]

# Extract actual method signatures
# Compare with documented signatures
```

For each documented method:

1. Search for method definition in source
2. Extract actual signature (parameters, return type)
3. Compare actual vs documented
4. Flag: FABRICATED, VERIFIED, or MISMATCH

**B. Code Example Validation**
For each code example:

1. Check if imports reference real modules
2. Verify API calls use actual signatures
3. Check if variables are properly defined
4. Verify error handling exists
5. Flag if example couldn't run

**C. Configuration Verification**

1. Find configuration interface/type in source
2. Extract actual config fields
3. Compare with documented options
4. Flag fabricated or misnamed options

**D. Error Verification**

1. Search source for `throw` statements
2. Extract all error types thrown
3. Compare with documented errors
4. Flag undocumented errors

**E. Performance Claim Verification**

1. Search for benchmark files
2. If claim has benchmark reference, verify file exists
3. If no benchmark, flag as UNVERIFIED
4. Check if benchmark results match claims

### Step 5: Check for Marketing Language

1. Scan documentation text for banned words/phrases
2. Flag marketing language instances
3. Suggest objective alternatives

### Step 6: Generate Report

```markdown
## API Documentation Verification: [doc_file]

### 🚨 CRITICAL Issues (Must Fix Before Commit)

#### Fabricated API Method

- **Documentation**: `updateUserPreferences(userId: string, prefs: object)`
  - **Location**: README.md:45
  - **Issue**: Method does not exist in UserService
  - **Fix**: Remove from documentation or implement the method

#### API Signature Mismatch

- **Documentation**: `getTasks(): Promise<Task[]>`
  - **Actual**: `getTasks(partnerId: string, filters?: TaskFilters): Promise<PaginatedResult<Task>>`
  - **Location**: API.md:120
  - **Issues**:
    - Missing required parameter `partnerId`
    - Missing optional parameter `filters`
    - Wrong return type: `Task[]` vs `PaginatedResult<Task>`
  - **Fix**: Update documentation to match actual signature

#### Non-Runnable Code Example

- **Location**: EXAMPLES.md:67-74
  - **Issues**:
    - `taskService` variable not defined
    - Missing required `partnerId` parameter
    - No import statements
    - No error handling
  - **Fix**: Provide complete, runnable example with imports and error handling

#### Unverified Performance Claim

- **Location**: README.md:89
  - **Claim**: "Response times under 10ms for most queries"
  - **Issue**: No benchmark data or reference provided
  - **Fix**: Either add benchmark reference or remove claim

### ⚠️ HIGH Priority Issues

#### Undocumented Error

- **Error**: `PermissionError`
  - **Thrown In**: TaskService.getTask() (line 45)
  - **Documentation**: Not mentioned in error documentation
  - **Fix**: Add to error documentation with conditions when thrown

#### Configuration Mismatch

- **Documented Field**: `timeout: 5000`
  - **Actual Field**: `timeoutMs: 5000`
  - **Location**: CONFIG.md:23
  - **Fix**: Update documentation to use `timeoutMs`

#### Fabricated Configuration Option

- **Documented**: `cacheSize: 1000`
  - **Issue**: Option doesn't exist in TaskServiceConfig interface
  - **Fix**: Remove from documentation

### ℹ️ MEDIUM Priority Issues

#### Marketing Language

- **Location**: README.md:12
  - **Text**: "blazing-fast, enterprise-grade performance"
  - **Issue**: Marketing buzzwords in technical documentation
  - **Fix**: Replace with objective description: "Uses connection pooling to reduce query latency"

#### Dependency Version Mismatch

- **Documentation**: "Requires Node.js 16+"
  - **package.json**: "node": ">=18.0.0"
  - **Location**: README.md:150
  - **Fix**: Update docs to "Requires Node.js 18+"

### ✅ Verified Accurate

- `getUser(id: string): Promise<User>` - Signature matches (UserService.ts:23)
- `TaskNotFoundError` - Error exists and is thrown (errors.ts:45)
- Code example at EXAMPLES.md:10-25 - Runnable and accurate
```

### Step 7: Provide Corrected Examples

For each critical issue, provide the correct version:

````markdown
#### Corrected Example: getTasks

**Incorrect Documentation**:
\```typescript
const tasks = await taskService.getTasks();
\```

**Correct Documentation**:
\```typescript
import { TaskService } from '@/services/TaskService';
import type { TaskFilters, PaginatedResult, Task } from '@/types';

async function example() {
const taskService = new TaskService();

const filters: TaskFilters = {
status: 'open'
};

const result: PaginatedResult<Task> = await taskService.getTasks(
'partner-123', // Required partnerId parameter
filters
);

console.log(`Found ${result.total} tasks, showing ${result.items.length}`);
return result.items;
}
\```
````

### Step 8: Summary Statistics

```markdown
## Summary

- Documentation files checked: X
- API methods verified: Y
- Issues found: Z
  - CRITICAL (fabricated/mismatch): A
  - HIGH (missing docs): B
  - MEDIUM (marketing language): C
- Code examples verified: W
- Accurate items: V
```

## Integration Points

This skill can be invoked:

- **Manually** when reviewing documentation
- **Before commits** that modify documentation
- **In CI/CD** as documentation linting step
- **Before releases** to ensure doc accuracy

## Exit Criteria

- All API methods verified against source code
- All code examples validated for runnability
- All performance claims checked for benchmark support
- All configuration options verified
- All errors documented
- Marketing language flagged
- Report generated with specific line numbers
- CRITICAL issues should block documentation commits

## Example Usage

```bash
# Manual invocation
/skill api-documentation-verify

# Verify specific doc file
/skill api-documentation-verify README.md

# Verify all docs in directory
/skill api-documentation-verify docs/
```

## Automation Opportunities

This skill can be automated in CI/CD:

```yaml
# .github/workflows/docs-verify.yml
name: Verify Documentation

on:
  pull_request:
    paths:
      - "**.md"
      - "docs/**"

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Verify API Documentation
        run: |
          # Run skill via Claude Code API
          claude-code skill api-documentation-verify
```

## References

- Diátaxis Framework: https://diataxis.fr/
- Technical Documentation Expert Agent
- Good Docs Project: https://thegooddocsproject.dev/
- API Documentation Best Practices: https://swagger.io/resources/articles/best-practices-in-api-documentation/

---

## Related Agent

For comprehensive documentation guidance that coordinates this and other documentation skills, use the **`documentation-coordinator`** agent.
