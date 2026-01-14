---
name: migration-guide-writer
description: Creates problem-oriented migration guides following Diátaxis How-To pattern. Maps old APIs to new APIs with before/after examples, documents breaking changes, provides troubleshooting. Zero tolerance for fabricated APIs or unverified performance claims. Use when new system replaces old, breaking API changes occur, major version upgrades needed, service decomposition happens, deprecation notices required, or architectural changes documented.
version: 1.0.0
---

# Migration Guide Writer Skill

## Purpose

Create comprehensive migration guides for moving from old systems/APIs to new ones. Follows the Diátaxis How-To pattern for problem-oriented documentation. Verifies all APIs in both old and new systems before documenting, with zero tolerance for fabrication.

## Diátaxis Framework: How-To Guide

**How-To Type Characteristics:**

- **Problem-oriented** - Focused on specific migration goal
- **Assumes knowledge** - Not teaching from zero (that's tutorials)
- **Series of steps** - Path from old to new
- **Multiple approaches** - May show different migration strategies
- **Real-world scenarios** - Production migration patterns
- **Troubleshooting** - Common issues and solutions

**What NOT to Include:**

- ❌ Tutorials (learning from zero) - Use tutorial-writer skill
- ❌ Complete API reference - Link to api-doc-writer docs
- ❌ Deep explanations of WHY - Link to explanation docs
- ❌ Marketing comparisons - Technical facts only

## Critical Rules (Zero Tolerance)

### P0 - CRITICAL Violations (Must Fix)

1. **Fabricated Old APIs** - Old methods that never existed
2. **Fabricated New APIs** - New methods that don't exist in source
3. **Wrong Signatures** - Before/After code with incorrect APIs
4. **Unverified Performance Claims** - "10x faster" without benchmarks
5. **Invalid Migration Code** - Code that won't compile

### P1 - HIGH Violations (Should Fix)

6. **Missing Troubleshooting** - No guidance for common errors
7. **Incomplete Breaking Changes** - Not documenting all changes
8. **Unverified Timing Claims** - Fabricated latency numbers

### P2 - MEDIUM Violations

9. **Marketing Language** - Buzzwords instead of technical facts
10. **Missing Prerequisites** - Not stating version requirements

## Step-by-Step Workflow

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

## Integration with Other Skills

### Works With:

- **api-doc-writer** - Link to new system API reference
- **tutorial-writer** - Link to getting started with new system
- **api-documentation-verify** - Verify migration guide accuracy

### Invokes:

- None (standalone skill)

### Invoked By:

- User (manual invocation)
- After major version releases
- When deprecating old systems

## Output Format

**Primary Output**: Markdown file with structured migration guide

**File Location**:

- `docs/migrations/[old]-to-[new].md`
- `MIGRATION.md` in project root
- `docs/how-to/migrate-from-[old].md`

## Common Pitfalls to Avoid

### 1. Unverified Performance Claims

```markdown
❌ BAD - No benchmark evidence
The new system is 10x faster than the old system

✅ GOOD - Factual architectural statement
The new system eliminates network overhead by using in-process calls
[If benchmarks exist]: See benchmarks/comparison.bench.ts for measurements
```

### 2. Fabricated New APIs

```markdown
❌ BAD - API doesn't exist
// After (New System)
await newSystem.easyMigrate(oldConfig) // This method was never implemented!

✅ GOOD - Real API from source
// After (New System)
const adapter = new ConfigAdapter(oldConfig)
await newSystem.initialize(adapter.transform())
```

### 3. Incomplete Breaking Changes

```markdown
❌ BAD - Missing changes
Major changes: Method renamed

✅ GOOD - Complete list
Breaking Changes:

1. CreateTask() renamed to Create()
2. Create() now requires ctx parameter
3. TaskParams.Owner changed from string to UserId type
4. UpdateTask() removed - use Patch() instead
5. Error type changed from string to TaskError
```

### 4. Missing Troubleshooting

```markdown
❌ BAD - No troubleshooting section
[Guide ends after migration patterns]

✅ GOOD - Comprehensive troubleshooting

## Troubleshooting

[Multiple common issues with solutions]
```

## Time Estimates

**Small Migration** (< 5 API changes): 45 minutes - 1.5 hours
**Medium Migration** (5-15 API changes): 1.5 - 3 hours
**Large Migration** (15+ changes): 3 - 6 hours
**System Replacement**: 4 - 8 hours

## Example Usage

```bash
# Manual invocation
/skill migration-guide-writer

# User request
User: "How do I migrate from the old TaskService to the new one?"
Assistant: "I'll use migration-guide-writer to create a comprehensive migration guide"
```

## Success Criteria

Migration guide is complete when:

- ✅ All new system APIs verified against source
- ✅ Before/After examples for all common patterns
- ✅ All breaking changes documented
- ✅ Troubleshooting section included
- ✅ No unverified performance claims
- ✅ No fabricated APIs
- ✅ Migration checklist provided
- ✅ Prerequisites clearly stated
- ✅ Configuration migration documented
- ✅ No marketing language

## References

- Diátaxis Framework: https://diataxis.fr/how-to-guides/
- Technical Documentation Expert Agent
- API Documentation Writer skill (for referencing APIs)

---

## Related Agent

For comprehensive documentation guidance that coordinates this and other documentation skills, use the **`documentation-coordinator`** agent.
