
## Purpose

Verify API documentation accuracy against source code. This skill eliminates fabricated API methods, unverified performance claims, non-runnable code examples, and marketing language. Every documented feature must exist in the codebase.

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

