# Skill Review: n-plus-one-detection
**Reviewer:** Claude Code
**Date:** 2025-01-21
**Version Reviewed:** 1.0.0

## Summary
Excellent performance audit skill with comprehensive N+1 pattern documentation and clear examples. Strong technical depth and good structure. Main weaknesses are abstract execution steps and missing test documentation.

**Recommendation:** ⚠️ **NEEDS WORK**

## Findings by Category

### Structure [✅ PASS]
- [x] Directory structure correct
- [x] File naming conventions followed
- [x] Under 500 lines (454 lines)

**Issues:** None

**Positive highlights:**
- Under the 500-line limit
- Clean single-file structure
- Comprehensive scope appropriate for complexity

---

### Frontmatter [✅ PASS]
- [x] Valid YAML
- [x] Name matches directory
- [x] Description quality excellent

**Frontmatter:**
```yaml
---
name: N+1 Query Detection (GraphQL/TypeScript)
description: Detects N+1 query problems in GraphQL resolvers and TypeScript code. Checks for missing DataLoader usage, sequential database queries in loops, and resolver batching opportunities. Use before committing GraphQL resolvers or during performance reviews.
version: 1.0.0
---
```

**Issues:**
1. [MINOR] Name could use gerund form: "n-plus-one-detecting" but noun form is acceptable for detection skills
2. [MINOR] Name in parentheses could be cleaner: "n-plus-one-detection-graphql" but current form is clear

**Analysis:**
- ✅ Third person
- ✅ Specific capabilities (DataLoader, sequential queries, batching)
- ✅ Clear triggers ("before committing", "performance reviews")
- ✅ Key terms included (GraphQL, TypeScript, N+1, DataLoader)
- ✅ Max 1024 characters

**Recommendation:** PASS - excellent description

---

### Content Quality [✅ PASS]
- [x] Clear purpose and workflows
- [x] Concrete examples provided (excellent)
- [x] Progressive disclosure appropriate
- [x] Consistent terminology

**Issues:**
1. [MAJOR] Step-by-step execution lacks concrete tool usage
2. [MAJOR] Missing examples of actual code parsing

**Positive highlights:**
- Outstanding "What This Skill Checks" section with 6 detailed patterns
- Clear priority system (CRITICAL, HIGH, MEDIUM)
- Exceptional before/after code examples
- Excellent DataLoader implementation guidance
- Performance impact analysis section (great addition!)
- Covers both GraphQL resolvers and general TypeScript
- Good coverage of external service calls (gRPC/REST)
- Integration points documented

**Line count:** 454 lines (excellent, comprehensive but under limit)

**Content breakdown:**
- Purpose: Clear and specific
- When to Use: 5 specific scenarios
- What This Skill Checks: 6 detailed patterns with priorities
- Step-by-Step Execution: 7 steps
- Performance impact analysis: Excellent addition
- Integration points: Documented
- Exit criteria: Clear with blocker enforcement

---

### Instruction Clarity [⚠️ NEEDS WORK]
- [x] Clear sequential steps (conceptually)
- [ ] Code examples need implementation details
- [ ] Validation steps need specifics

**Issues:**
1. [MAJOR] Step 2 "Read Resolver Files" lacks parsing specifics
2. [MAJOR] Step 3 "Analyze for N+1 Patterns" describes what but not how to detect
3. [CRITICAL] Missing concrete patterns for finding DataLoader absence
4. [MAJOR] No examples of TypeScript AST parsing or regex patterns

**Good aspects:**
- Excellent conceptual breakdown of what to check
- Clear priorities for each pattern
- Outstanding before/after examples
- Great DataLoader implementation guidance
- Unique performance impact estimation

**Needs improvement:**
```markdown
# Current (too abstract):
**A. Field Resolvers Without DataLoader**
1. Identify all field resolver functions
2. Check if they make direct database/service calls

# Better (more concrete):
**A. Field Resolvers Without DataLoader**

Use Grep to find resolvers making direct DB calls:

\`\`\`bash
# Find field resolvers with direct DB calls
grep -n 'db\.\|\.find\|\.query' --include="*.resolver.ts" -r .

# Find resolvers NOT using context.loaders
grep -v 'context\.loaders\|ctx\.loaders' --include="*.resolver.ts" -r . | grep 'async.*parent'
\`\`\`

For each match:
1. Use Read tool to examine resolver
2. Check if it accesses `db.*`, `*Client.*`, or `fetch()`
3. Verify if `context.loaders.*.load()` is used instead
4. Flag any direct calls as CRITICAL N+1
```

---

### Testing [❌ NEEDS DOCUMENTATION]
- [ ] Test scenarios not documented
- [ ] Fresh instance testing not documented
- [ ] Multi-model testing not done

**Issues:**
1. [CRITICAL] No documented test scenarios
2. [CRITICAL] No testing matrix provided
3. [CRITICAL] No example execution on real GraphQL resolvers

**Required before final release:**
- Test scenario 1: Detect resolver without DataLoader
- Test scenario 2: Find sequential queries in loop
- Test scenario 3: Identify nested resolver chain
- Document real codebase results
- Test across models

---

## Blockers (must fix)
None

## Critical Issues (should fix)
1. No documented test scenarios
2. No testing matrix provided
3. Missing concrete detection patterns for finding N+1 issues

## Major Issues (fix soon)
1. Step-by-step execution lacks concrete implementation
2. Missing grep/search patterns for issue detection
3. No TypeScript AST parsing examples
4. Report generation template without population guidance

## Minor Issues (nice to have)
1. Could show TypeScript AST parsing for accurate detection
2. Could provide DataLoader generator script
3. Could add section on Apollo tracing integration

## Positive Highlights
- Outstanding pattern documentation (6 comprehensive patterns)
- Exceptional before/after code examples
- Excellent DataLoader implementation guidance
- Unique performance impact analysis section (estimates latency reduction)
- Clear priority system (CRITICAL/HIGH/MEDIUM)
- Covers both GraphQL and general TypeScript
- Good coverage of external service batching (gRPC/REST)
- DataLoader anti-patterns documented (cache scope, missing data handling)
- Nested resolver chain analysis included
- Integration points documented
- Clear exit criteria with blocker enforcement

## Recommendations

### Priority 1 (Required before release)
1. **Add concrete detection patterns**:
   ```markdown
   ### Step 3A: Detect Field Resolvers Without DataLoader

   Use Grep to identify potential N+1 in resolvers:

   \`\`\`bash
   # Find resolvers making database calls
   grep -n 'await.*db\.\|await.*\.find\|await.*\.query' *.resolver.ts

   # Find resolvers NOT using DataLoader
   grep -L 'context\.loaders\|ctx\.loaders' *.resolver.ts

   # Find awaits inside loops (sequential queries)
   grep -B2 'for.*of\|forEach' *.ts | grep 'await'
   \`\`\`

   For each match:
   1. Use Read tool to examine full resolver
   2. Check if accessing database/service directly
   3. Verify DataLoader usage or lack thereof
   4. Calculate query multiplication (N tasks = N+1 queries)
   ```

2. **Add testing documentation**:
   - Test case 1: Task.assignee resolver without DataLoader
   - Test case 2: for-loop with await db.users.find()
   - Test case 3: Nested Task -> User -> Team chain
   - Show expected skill output with performance impact
   - Multi-model testing results
   - Real Hermes codebase results (if applicable)

3. **Add concrete report example**:
   Show actual report from real GraphQL schema with:
   - Specific file and line numbers
   - Actual code snippets
   - Performance impact calculations

### Priority 2 (Nice to have)
1. Add TypeScript AST parsing examples for accurate detection
2. Provide DataLoader generator script
3. Show Apollo tracing integration for runtime detection
4. Consider REFERENCE.md for:
   - Advanced TypeScript AST patterns
   - Apollo tracing setup
   - DataLoader generator scripts
   - Integration with GraphQL Inspector

## Next Steps
- [ ] Add concrete grep/search patterns to execution steps
- [ ] Complete testing documentation with real examples
- [ ] Add example report from real GraphQL codebase
- [ ] Add TypeScript parsing examples
- [ ] Consider REFERENCE.md for advanced topics
- [ ] Re-review after fixes
- [ ] Approve for merge

**Estimated effort:** 5-6 hours

---

## Overall Assessment

**Total Issues:**
- Blockers: 0
- Critical: 3
- Major: 4
- Minor: 3

**Pass Criteria Analysis:**
- ✅ Zero blockers: YES
- ✅ Zero critical: NO (has 3)
- ✅ < 3 major: NO (has 4)

**Recommendation:** NEEDS WORK (Critical + Major issues need addressing)

**Strong Points:**
- Outstanding pattern documentation
- Exceptional before/after examples
- Excellent DataLoader guidance
- Unique performance impact analysis
- Comprehensive scope (GraphQL + TypeScript)
- Clear priorities
- Good anti-pattern coverage
- Strong technical depth

**Weak Points:**
- Too abstract in execution steps
- Missing concrete detection patterns
- No test documentation
- No example execution on real code
- Lacks parsing/AST examples
