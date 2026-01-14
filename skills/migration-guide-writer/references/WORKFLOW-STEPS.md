
### Step 1: Systems Analysis Phase (10-15 minutes)

**Understand both old and new systems:**

```bash
# Read old system documentation
Read [old_system_docs]
Read [old_system_source] # If available

# Read new system source code (REQUIRED)
Read [new_system_source]

# Find equivalent operations
# For each old API, identify corresponding new API
```

**Create mapping checklist:**

```markdown
## API Mapping Checklist

### Old System: [OldSystemName]

- [ ] All old APIs identified
- [ ] Old API signatures verified (if source available)
- [ ] Old patterns documented

### New System: [NewSystemName]

- [ ] All new APIs read from source
- [ ] New API signatures verified
- [ ] New patterns understood
- [ ] Breaking changes identified

### Mapping

- [ ] CRUD operations mapped
- [ ] Authentication mapped
- [ ] Error handling mapped
- [ ] Configuration mapped
- [ ] No-direct-equivalent cases noted
```

**Search for benchmarks:**

```bash
# Look for benchmark files
find . -name "*bench*" -o -name "*benchmark*"

# If comparing systems, need benchmarks for performance claims
# If no benchmarks exist, DO NOT make performance claims
```

### Step 2: Pattern Identification Phase (15-20 minutes)

**Identify common migration patterns:**

1. **CRUD Operations** - Create, Read, Update, Delete mappings
2. **Authentication** - Auth pattern changes
3. **Configuration** - Config format changes
4. **Error Handling** - Error pattern changes
5. **Async Operations** - Callback → Promise → Async/Await
6. **Data Access** - Database query changes
7. **API Calls** - HTTP client changes
8. **State Management** - State pattern changes

**For each pattern:**

```markdown
## Pattern: [PatternName]

### Old System Approach

[Verified old code]

### New System Approach

[Verified new code from source]

### Breaking Changes

- [Specific change 1]
- [Specific change 2]

### Migration Steps

1. [Step 1]
2. [Step 2]
```

**Identify breaking changes explicitly:**

- Method renamed
- Parameter added/removed/reordered
- Return type changed
- Behavior changed
- Configuration format changed
- Dependencies changed

### Step 3: Documentation Phase (20-30 minutes)

**Use this structure:**

````markdown
# How to Migrate from [Old System] to [New System]

## Goal

[Specific migration outcome - what they'll achieve]

## Prerequisites

**Before starting:**

- [Old System] version: [X.Y.Z or range]
- [New System] version: [A.B.C or range]
- [Required dependency 1]: version [X.Y]
- [Required dependency 2]: version [A.B]
- [Required knowledge]: Understanding of [concept]

**Installation:**

```bash
# Install new system
[verified installation command]
```
````

## Overview of Changes

**Major Breaking Changes:**

1. **[Change 1]**: [What changed and impact]
2. **[Change 2]**: [What changed and impact]
3. **[Change 3]**: [What changed and impact]

**New Capabilities:**

- [Feature 1] - [Brief description]
- [Feature 2] - [Brief description]

**Removed/Deprecated:**

- [Old Feature 1] - [Replacement or workaround]
- [Old Feature 2] - [Replacement or workaround]

## Migration Patterns

### Pattern 1: [Common Task Name]

#### Before (Old System)

```[language]
// Old system code - verified against old docs/source
import "[old/import/path]"

[verified old code demonstrating the pattern]
```

**What this does**: [Brief explanation]

#### After (New System)

```[language]
// New system code - VERIFIED against source
import "[new/import/path]"

[verified new code from source demonstrating the pattern]
```

**What changed**:

- [Specific change 1]: [Old approach] → [New approach]
- [Specific change 2]: [Technical reason if architectural]

**Why This Works**: [Brief factual explanation - no marketing]

---

### Pattern 2: [Another Common Task]

[Repeat Before/After structure]

---

## Step-by-Step Migration

[Optional: If there's a specific sequence to follow]

### Step 1: [First Action] ([time estimate])

**What to do:**

```[language]
[Specific code or commands]
```

**Verification:**

```bash
# How to verify this step worked
[verification command]
# Expected output:
[expected result]
```

### Step 2: [Next Action] ([time estimate])

[Continue step pattern]

## Architecture Comparison

[Only factual architectural statements - no unverified performance claims]

### Old System Architecture

- [Architectural fact 1]: [e.g., "Network-based RPC calls"]
- [Architectural fact 2]: [e.g., "Separate process communication"]

### New System Architecture

- [Architectural fact 1]: [e.g., "In-process function calls"]
- [Architectural fact 2]: [e.g., "Direct memory access"]

**Implications:**

- ✅ **Factual**: "Eliminates network overhead between processes"
- ✅ **Factual**: "Reduces database round-trips through batching"
- ❌ **UNVERIFIED**: "10x faster" [Need benchmarks!]
- ❌ **UNVERIFIED**: "Reduces latency from 50ms to 5ms" [Need measurements!]

[If benchmarks exist, reference them]:
**Performance Characteristics**: See `benchmarks/old-vs-new.bench.ts` for measurements

## Troubleshooting

### Issue: [Common Problem 1]

**Symptom**: [What the developer sees/experiences]

```
[Error message or behavior]
```

**Cause**: [Why this happens - technical explanation]

**Solution**:

```[language]
// How to fix
[verified solution code]
```

---

### Issue: [Common Problem 2]

[Repeat troubleshooting pattern]

---

### Issue: Compilation Errors After Migration

**Symptom**: Code doesn't compile after changing imports

**Common Causes**:

1. [Type import changed]: [Old import] → [New import]
2. [Method signature changed]: [Old signature] → [New signature]

**Solution**: Check [link to API reference] for updated signatures

---

## Configuration Migration

[If configuration format changed]

### Old Configuration

```[format]
# Old config format
[verified old config]
```

### New Configuration

```[format]
# New config format - verified against source
[verified new config]
```

**Mapping**:

- `old.setting1` → `new.setting_one` (renamed)
- `old.setting2` → `new.setting_two` (type changed: string → number)
- `old.setting3` → (removed - no longer needed)
- (new) → `new.setting_four` (new required setting)

## Breaking Changes Reference

**Complete list of breaking changes:**

1. **[Module/Package Name]**
   - `OldMethod()` renamed to `NewMethod()`
   - `MethodWithChange(param1)` now requires `param2`
   - `RemovedMethod()` removed - use `NewApproach()` instead

2. **[Another Module]**
   - [List all breaking changes]

3. **Configuration**
   - [Config changes]

4. **Dependencies**
   - [Dependency changes]

## Complete Example

[Full before/after example of a real use case]

### Old System - Complete Working Example

```[language]
// Complete old system code
[verified old code if possible]
```

### New System - Complete Working Example

```[language]
// Complete new system code - VERIFIED against source
import "[actual/new/import]"

[complete verified new code showing full migration]
```

## Migration Checklist

Use this checklist to track your migration:

- [ ] Prerequisites installed
- [ ] Old code backed up
- [ ] Dependencies updated
- [ ] Imports updated
- [ ] [Pattern 1] migrated
- [ ] [Pattern 2] migrated
- [ ] [Pattern 3] migrated
- [ ] Configuration migrated
- [ ] Tests updated
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Peer review completed

## Additional Resources

- **API Reference**: [Link to api-doc-writer docs for new system]
- **Tutorial**: [Link to tutorial-writer docs for new system]
- **Explanation**: [Link to architecture explanation docs]
- **Old System Docs**: [Link to old documentation]
- **Changelog**: [Link to official changelog]

---

**Migration Guide Metadata**

**Last Updated**: [YYYY-MM-DD]
**Old System Version**: [Version range covered]
**New System Version**: [Version range covered]
**Verification Status**: ✅ All APIs verified against source code

**Source Files Verified**:

- New system: `path/to/new/source/*.ext`
- Old system: [If source available] `path/to/old/source/*.ext`

---

**Verification Checklist**

### Source Code Verification (P0 - CRITICAL)

- [ ] All new system APIs verified against source
- [ ] All new system signatures exact
- [ ] Old system APIs verified (if source available) or checked against docs
- [ ] No fabricated methods in either system
- [ ] Before/After examples use real imports

### Performance Claims (P0 - CRITICAL)

- [ ] No unverified "Nx faster" claims
- [ ] No fabricated timing numbers
- [ ] Any performance claims backed by benchmarks
- [ ] Only factual architectural statements

### Completeness (P1 - HIGH)

- [ ] All breaking changes documented
- [ ] Common migration patterns covered
- [ ] Troubleshooting for typical issues
- [ ] Configuration changes documented
- [ ] Prerequisites clearly stated

### Quality (P2 - MEDIUM)

- [ ] No marketing language
- [ ] Technical descriptions only
- [ ] Consistent Before/After structure
- [ ] Source references included

````

### Step 4: Troubleshooting Phase (10-15 minutes)

**Anticipate common migration errors:**

1. **Compilation Errors**
   - Type mismatches
   - Missing imports
   - Method signature changes

2. **Runtime Errors**
   - Null pointer exceptions from changed behavior
   - Configuration errors
   - Dependency conflicts

3. **Logical Errors**
   - Changed default behavior
   - Different error handling
   - Changed return values

**For each anticipated error:**
```markdown
### Issue: [Error Type]
**Symptom**: [What appears]
**Cause**: [Why it happens]
**Solution**: [How to fix with verified code]
````

### Step 5: Verification Phase (5-10 minutes)

**Verification checklist:**

```bash
# For new system APIs
Read [new_source_files]
# Verify every "After" code block uses real APIs

# For performance claims
find . -name "*bench*"
# If making performance claims, verify benchmarks exist
# If no benchmarks, REMOVE performance claims

# For code examples
# Check imports are real
# Check methods exist
# Check signatures match
```

**Critical checks:**

- [ ] Every "After" code block verified against source
- [ ] No fabricated new APIs
- [ ] No unverified performance claims removed
- [ ] All imports are real
- [ ] Breaking changes list is complete
- [ ] Troubleshooting covers common issues

