---
name: N+1 Query Detection (GraphQL/TypeScript)
description: Detects N+1 query problems in GraphQL resolvers. Checks for missing DataLoader usage, sequential queries in loops, and batching opportunities. For GraphQL performance reviews.
version: 1.0.0
---

# ⚠️ MANDATORY: N+1 Query Detection Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Before committing GraphQL resolvers (as part of quality-check)
2. When adding new field resolvers to schema
3. During performance investigation or optimization
4. Before creating pull requests with GraphQL changes
5. When reviewing nested resolver implementations

**This skill is MANDATORY because:**
- Prevents exponential query explosion in GraphQL (CRITICAL performance)
- Catches N+1 problems before they reach production
- Ensures proper batching with DataLoader (MANDATORY pattern)
- Prevents database/API overload from inefficient queries
- Maintains acceptable API response times

**ENFORCEMENT:**

**P0 Violations (Critical - Immediate Failure):**
- Field resolver with direct database query (not using DataLoader)
- Sequential database/service calls in loops
- Missing DataLoader for entity types in context
- Exponential nested resolver chains without batching
- gRPC/REST client calls in loops

**P1 Violations (High - Quality Failure):**
- DataLoader used incorrectly (caching scope, null handling)
- Missing batch fetch strategy for service calls
- No DataLoader for frequently accessed entities
- Inefficient batch function implementation

**P2 Violations (Medium - Efficiency Loss):**
- Not identifying all N+1 opportunities
- Unclear batching suggestions
- Missing performance impact estimates

**Blocking Conditions:**
- Field resolvers MUST use DataLoader
- No loops with async database/service calls
- All entity types MUST have DataLoaders
- DataLoader batch functions MUST match input array
- Nested resolvers MUST have DataLoaders at each level

---

## Purpose

Detect N+1 query anti-patterns in GraphQL resolvers and TypeScript code. This skill identifies situations where code makes sequential database/service calls in loops instead of batching requests, which causes severe performance degradation.

## When to Use This Skill

- **Before committing GraphQL resolvers** - Prevent N+1 before production
- **Performance investigation** - When APIs are slow
- **Code review preparation** - Before submitting resolver PRs
- **After adding new resolvers** - Verify batching is implemented
- **Debugging query performance** - When seeing repeated identical queries

## What This Skill Checks

### 1. Field Resolvers Without DataLoader (Priority: CRITICAL)
**Golden Rule**: Every field resolver loading related data MUST use DataLoader.

**N+1 Anti-Pattern**:
```typescript
// ❌ CRITICAL: Makes 1 query per task
const TaskResolver = {
  assignee: async (parent: Task, _args, context: Context) => {
    return await context.db.users.findById(parent.assigneeId); // N+1!
  }
};

// 100 tasks = 101 queries (1 task + 100 assignee)
```

**Correct with DataLoader**:
```typescript
// ✅ Batched - makes 2 queries total
const TaskResolver = {
  assignee: async (parent: Task, _args, context: Context) => {
    return await context.loaders.users.load(parent.assigneeId);
  }
};

// 100 tasks = 2 queries (1 task + 1 batched assignee)
```

### 2. Sequential Queries in Loops (Priority: CRITICAL)
**Golden Rule**: Never make database calls inside loops. Batch fetch all data first.

**Anti-Pattern**:
```typescript
// ❌ CRITICAL: N+1 problem
async function getTasksWithOwners(taskIds: string[]): Promise<TaskWithOwner[]> {
  const tasks = await db.tasks.findByIds(taskIds);
  const results = [];
  for (const task of tasks) {
    const owner = await db.users.findById(task.ownerId); // N+1!
    results.push({ ...task, owner });
  }
  return results;
}
```

**Correct Pattern**:
```typescript
// ✅ Batched fetch
async function getTasksWithOwners(taskIds: string[]): Promise<TaskWithOwner[]> {
  const tasks = await db.tasks.findByIds(taskIds);
  const ownerIds = [...new Set(tasks.map(t => t.ownerId))];
  const owners = await db.users.findByIds(ownerIds);
  const ownerMap = new Map(owners.map(o => [o.id, o]));
  return tasks.map(task => ({
    ...task,
    owner: ownerMap.get(task.ownerId)
  }));
}
```

### 3. Nested Resolver Chains (Priority: CRITICAL)
**Golden Rule**: Resolver chains compound N+1 exponentially. Use DataLoader at each level.

**Exponential N+1**:
```typescript
// ❌ CRITICAL: Exponential queries
const TaskResolver = {
  assignee: async (parent: Task) => {
    return await db.users.findById(parent.assigneeId); // N+1: 100 queries
  }
};

const UserResolver = {
  team: async (parent: User) => {
    return await db.teams.findById(parent.teamId); // N+1: 100 more
  }
};

// { tasks { assignee { team } } } with 100 tasks
// = 1 + 100 + 100 = 201 queries (TERRIBLE)
```

**Correct with DataLoaders**:
```typescript
// ✅ Batched at every level
// 100 tasks = 3 queries total (1 task + 1 assignees batch + 1 teams batch)
```

### 4. Missing DataLoader in Context (Priority: HIGH)
**Golden Rule**: Every entity type in resolvers must have a DataLoader.

### 5. External Service Calls in Loops (Priority: CRITICAL)
**Golden Rule**: Batch external service calls just like database queries.

**Anti-Pattern**:
```typescript
// ❌ CRITICAL: N service calls
async function enrichTasksWithUAC(tasks: Task[]) {
  const results = [];
  for (const task of tasks) {
    const perms = await uacClient.checkPermissions({ taskId: task.id });
    results.push({ ...task, permissions: perms });
  }
  return results;
}
```

**Correct**:
```typescript
// ✅ Single batched gRPC call
async function enrichTasksWithUAC(tasks: Task[]) {
  const taskIds = tasks.map(t => t.id);
  const permsResponse = await uacClient.batchCheckPermissions({ taskIds });
  const permsMap = new Map(permsResponse.results.map(r => [r.taskId, r]));
  return tasks.map(task => ({
    ...task,
    permissions: permsMap.get(task.id)
  }));
}
```

## Step-by-Step Execution

### Step 1: Identify GraphQL/TypeScript Files
```bash
find . -name "*.resolver.ts" -o -name "*Resolver.ts" -o -name "*.graphql.ts"
```

### Step 2: Read Resolver Files
Examine files focusing on:
- Field resolver implementations
- Context and DataLoader usage
- Loop constructs with async calls
- Service/database call patterns

### Step 3: Analyze for N+1 Patterns

**A. Field Resolvers Without DataLoader**
1. Identify all field resolvers
2. Check if they use `context.loaders.X.load()` pattern
3. Flag any direct calls: `db.*.find*`, `*Client.*`

**B. Sequential Queries in Loops**
1. Find all loops: `for`, `forEach`, `map` with async
2. Check for `await` with database/service calls
3. Flag any awaited queries inside loops

**C. Context DataLoader Completeness**
1. Extract all entity types from resolvers
2. Verify Context has DataLoader for each
3. Flag missing loaders

**D. External Service Calls**
1. Find gRPC client calls, fetch calls
2. Check if inside loops
3. Flag unbatched calls

### Step 4: Generate Report

```markdown
## N+1 Query Detection: [file_path]

### ✅ Resolvers With Correct Batching
- `Task.assignee` ([file:line]) - Uses DataLoader

### 🚨 CRITICAL N+1 Problems

#### Field Resolver Without DataLoader
- **Resolver**: `Task.assignee` ([file:line])
  - **Issue**: Direct database query in resolver
  - **Code**: `await db.users.findById(parent.assigneeId)`
  - **Impact**: 100 tasks = 100 queries
  - **Fix**: Use `context.loaders.users.load(parent.assigneeId)`

#### Sequential Queries in Loop
- **Function**: `getTasksWithOwners` ([file:line])
  - **Issue**: Database query inside for-loop
  - **Impact**: N+1 queries (1 + number of tasks)
  - **Fix**: Batch fetch owner IDs, then map in memory

#### Nested Resolver Chain Without Batching
- **Chain**: `Task.assignee.team.organization`
  - **Issue**: Missing DataLoader at User.team level
  - **Impact**: Exponential queries (100 tasks × team queries)
  - **Fix**: Add DataLoader for teams in context

#### External Service in Loop
- **Function**: `enrichTasksWithUAC` ([file:line])
  - **Issue**: gRPC call inside loop
  - **Impact**: N service calls (network overhead)
  - **Fix**: Use `uacClient.batchCheck()` with all IDs

### ⚠️ HIGH Priority Issues

#### Missing DataLoader
- **Entity Type**: `Team`
  - **Referenced In**: User.team resolver
  - **Fix**: Add `teams: new DataLoader(batchLoadTeams)`

### Performance Impact

**Current**: 100 tasks query
- 1 task query + 100 assignee queries + 100 team queries = **201 queries**
- Estimated: **2-5 seconds**

**After Fix**: Same query
- 1 task query + 1 assignee batch + 1 team batch = **3 queries**
- Estimated: **50-200ms**

**Improvement**: **90-96% latency reduction**
```

### Step 5: Summary Statistics

```markdown
## Summary
- Files checked: X
- Resolvers analyzed: Y
- N+1 problems: Z
  - CRITICAL field resolvers: A
  - CRITICAL loops: B
  - HIGH missing loaders: C
- Clean resolvers: W
```

## Integration Points

This skill is invoked by:
- **`quality-check`** skill for TypeScript/GraphQL projects
- **`safe-commit`** skill (via quality-check)

## Anti-Patterns

### ❌ Anti-Pattern: Field Resolver Without DataLoader

**Wrong approach:**
```typescript
const TaskResolver = {
  assignee: async (parent: Task) => {
    return await db.users.findById(parent.assigneeId); // ❌ N+1
  }
};
```

**Correct approach:**
```typescript
const TaskResolver = {
  assignee: async (parent: Task, _args, ctx: Context) => {
    return await ctx.loaders.users.load(parent.assigneeId); // ✅ Batched
  }
};
```

---

### ❌ Anti-Pattern: Database Query in Loop

**Wrong approach:**
```typescript
for (const task of tasks) {
  const owner = await db.users.findById(task.ownerId); // ❌ N+1
  // ...
}
```

**Correct approach:**
```typescript
const ownerIds = [...new Set(tasks.map(t => t.ownerId))];
const owners = await db.users.findByIds(ownerIds); // ✅ Single query
const ownerMap = new Map(owners.map(o => [o.id, o]));
// Use ownerMap for lookups
```

---

## References

**Based on:**
- CLAUDE.md Section 3 (Available Skills Reference - n-plus-one-detection)
- DataLoader: https://github.com/graphql/dataloader
- GraphQL N+1 Problem: https://www.apollographql.com/blog/optimizing-your-graphql-request-waterfalls

**Related skills:**
- `quality-check` - Invokes this skill for TypeScript/GraphQL
- `type-safety-audit` - Works with TypeScript code
