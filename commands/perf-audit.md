---
allowed-tools: Bash(git:*, npm:*, go:*), Read, Grep, Glob, Skill, Task
argument-hint: [quick|standard|deep]
description: Performance analysis (N+1 queries, algorithms, memory)
---

# Performance Audit: Comprehensive Analysis

You are performing a deep performance audit of the codebase, identifying bottlenecks, inefficiencies, and optimization opportunities.

## Step 1: Determine Audit Depth

The user may have specified a depth: `quick`, `standard`, or `deep`.

- **quick**: Pattern-based detection only (~3-5 min)
- **standard**: Quick + algorithm analysis + memory checks (~10-15 min)
- **deep**: Standard + profiling analysis + benchmark review (~20-40 min)

If no argument provided, default to `standard`.

## Step 2: Detect Project Type

Execute these commands:

```bash
!ls -1 package.json go.mod requirements.txt Cargo.toml 2>/dev/null | head -1
!find . -name "*.graphql" -o -name "*resolver*" | head -5
!find . -name "*.test.*" -o -name "*_test.*" -o -name "*.spec.*" | head -5
```

Determine:
- Project language (TypeScript/Go/Python/Rust)
- GraphQL presence (for N+1 detection)
- Test file locations (for benchmark analysis)

## Step 3: N+1 Query Detection (TypeScript + GraphQL)

**If TypeScript + GraphQL detected, invoke the `n-plus-one-detection` skill:**

```
Skill: n-plus-one-detection
```

This will detect:
- Missing DataLoader usage
- Sequential database queries in loops
- Nested resolver chains
- Resolver batching opportunities

Collect results for the final report.

## Step 4: Database Query Analysis

Search for database query patterns:

```bash
!grep -r "SELECT\|INSERT\|UPDATE\|DELETE\|findMany\|findAll" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" ! -path "./.venv/*" | head -30
!grep -r "for.*await\|for.*each" --include="*.ts" --include="*.js" ! -path "./node_modules/*" | head -20
!grep -r "while.*{" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | head -20
```

**Look for**:
- Queries inside loops
- Missing pagination
- SELECT * without field selection
- Missing indexes (comment analysis)
- Cartesian products (multiple FROM without JOIN)

## Step 5: Algorithm Efficiency Analysis (Standard and Deep modes)

**If mode is `standard` or `deep`, analyze algorithmic complexity:**

### Nested Loops Detection

```bash
!grep -B2 -A10 "for.*{" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" ! -path "./.venv/*" | grep -A10 "for.*{" | head -50
```

**Look for**:
- O(n²) or worse complexity (nested loops over same data)
- Inefficient sorting (bubble sort patterns)
- Linear search where hash/map could be used
- Repeated computations inside loops

### Data Structure Inefficiencies

```bash
!grep -r "indexOf\|includes\|find\|filter" --include="*.ts" --include="*.js" ! -path "./node_modules/*" | head -30
!grep -r "append\|push.*loop\|+=.*loop" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" ! -path "./node_modules/*" ! -path "./vendor/*" | head -20
```

**Look for**:
- Array.includes() in hot paths (use Set instead)
- Array.find() in loops (use Map instead)
- String concatenation in loops (use array join)
- Repeated array operations (filter + map + reduce chains)

### Synchronous Blocking Operations

```bash
!grep -r "readFileSync\|writeFileSync\|execSync" --include="*.ts" --include="*.js" ! -path "./node_modules/*" | head -20
!grep -r "time\\.Sleep\|Thread\\.sleep" --include="*.go" --include="*.py" ! -path "./vendor/*" ! -path "./.venv/*" | head -20
```

**Look for**:
- Synchronous file I/O in async contexts
- Blocking operations in event loop
- Missing concurrency/parallelism

## Step 6: Memory Leak Detection (Standard and Deep modes)

Search for common memory leak patterns:

```bash
!grep -r "setInterval\|addEventListener\|subscribe" --include="*.ts" --include="*.js" ! -path "./node_modules/*" | head -20
!grep -r "removeEventListener\|unsubscribe\|clearInterval\|close" --include="*.ts" --include="*.js" ! -path "./node_modules/*" | head -20
!grep -r "global\\..*=\|window\\..*=" --include="*.ts" --include="*.js" ! -path "./node_modules/*" | head -20
```

**Look for**:
- Event listeners without cleanup
- Intervals/timers without clear
- Global variable accumulation
- Unclosed connections/streams
- Large object retention

### Go-specific Memory Issues

```bash
!grep -r "go func" --include="*.go" ! -path "./vendor/*" | head -20
!grep -r "defer.*Close\|defer.*close" --include="*.go" ! -path "./vendor/*" | head -20
!grep -r "sync\\.WaitGroup\|context\\.Context" --include="*.go" ! -path "./vendor/*" | head -20
```

**Look for**:
- Goroutine leaks (missing context cancellation)
- Unclosed resources (file handles, connections)
- Missing defer statements
- Channel leaks

## Step 7: Deep Analysis (Deep mode only)

**If mode is `deep`, perform additional analysis:**

### Benchmark Analysis

Search for existing benchmarks:

```bash
!find . -name "*bench*" -o -name "*benchmark*" | grep -E "\.(ts|js|go|py)$"
!grep -r "benchmark\|Benchmark\|b\\.N" --include="*.go" --include="*.ts" --include="*.js" ! -path "./vendor/*" ! -path "./node_modules/*" | head -20
```

If benchmarks exist, suggest running them:

```
Run benchmarks:
- Go: go test -bench=. -benchmem ./...
- Node: npm run bench (if configured)
- Python: pytest --benchmark-only
```

### Profiling Analysis

Invoke Task agent for deep profiling guidance:

```
Task(
  subagent_type: "general-purpose",
  description: "Analyze performance hotspots",
  prompt: "Analyze this codebase for performance hotspots and bottlenecks.

  Focus on:
  1. Hot paths (frequently executed code)
  2. Database query patterns
  3. API endpoint performance
  4. Memory allocation patterns
  5. Concurrency opportunities

  For each file with performance concerns:
  1. Identify the performance issue
  2. Estimate impact (low/medium/high)
  3. Provide specific optimization recommendations
  4. Show before/after code examples

  Generate a prioritized list of performance improvements."
)
```

### Bundle Size Analysis (JavaScript/TypeScript)

If Node.js project:

```bash
!npm ls --depth=0 2>/dev/null | head -30
!du -sh node_modules 2>/dev/null
!find . -name "*.bundle.*" -o -name "dist/*" | head -10
```

**Analyze**:
- Large dependencies
- Unused dependencies
- Bundle splitting opportunities
- Tree-shaking effectiveness

## Step 8: Generate Performance Audit Report

```
═══════════════════════════════════════════════════════════════
                  PERFORMANCE AUDIT REPORT
═══════════════════════════════════════════════════════════════

Project: [detected from package.json/go.mod/etc]
Audit Date: [current date]
Audit Depth: [quick|standard|deep]

───────────────────────────────────────────────────────────────
                    EXECUTIVE SUMMARY
───────────────────────────────────────────────────────────────

Overall Performance Score: A / B / C / D / F

Critical Issues (P0): X (IMMEDIATE IMPACT)
High Issues (P1): X (SIGNIFICANT IMPACT)
Medium Issues (P2): X (MODERATE IMPACT)
Low Issues (P3): X (MINOR IMPACT)

Performance Risk: LOW / MEDIUM / HIGH / CRITICAL

[If CRITICAL or HIGH]
⚠️  This codebase has serious performance issues that will impact users.

[If MEDIUM]
⚠️  This codebase has performance issues that should be addressed for optimal UX.

[If LOW]
✅ This codebase has good performance characteristics with minor optimization opportunities.

───────────────────────────────────────────────────────────────
                PERFORMANCE CATEGORIES
───────────────────────────────────────────────────────────────

Database Queries           ✅ GOOD / ⚠️  ISSUES / ❌ POOR
Algorithm Efficiency       ✅ GOOD / ⚠️  ISSUES / ❌ POOR
Memory Management          ✅ GOOD / ⚠️  ISSUES / ❌ POOR
Concurrency                ✅ GOOD / ⚠️  ISSUES / ❌ POOR
Data Structures            ✅ GOOD / ⚠️  ISSUES / ❌ POOR
Bundle Size (if JS/TS)     ✅ GOOD / ⚠️  ISSUES / ❌ POOR

───────────────────────────────────────────────────────────────
                DETAILED FINDINGS
───────────────────────────────────────────────────────────────

P0 - CRITICAL (FIX IMMEDIATELY):

1. [Issue Title]
   Category: [Database/Algorithm/Memory/etc]
   Location: [file:line]
   Description: [detailed description]
   Impact: [performance impact - e.g., "500ms per request"]
   Current Complexity: [O(n²) / blocking / etc]
   Recommendation: [specific optimization with code example]
   Expected Improvement: [estimated improvement]

2. ...

P1 - HIGH (SIGNIFICANT IMPACT):

1. [Issue Title]
   Category: [category]
   Location: [file:line]
   Description: [detailed description]
   Impact: [performance impact]
   Recommendation: [specific fix]
   Expected Improvement: [estimated improvement]

2. ...

P2 - MEDIUM (MODERATE IMPACT):

1. [Issue Title]
   Category: [category]
   Location: [file:line]
   Description: [detailed description]
   Recommendation: [optimization suggestion]

2. ...

P3 - LOW (MINOR IMPACT):

1. [Issue Title]
   Category: [category]
   Recommendation: [micro-optimization]

2. ...

───────────────────────────────────────────────────────────────
                OPTIMIZATION OPPORTUNITIES
───────────────────────────────────────────────────────────────

Quick Wins (High Impact, Low Effort):
1. [Optimization with estimated impact]
2. ...

Recommended (High Impact, Medium Effort):
1. [Optimization with estimated impact]
2. ...

Long-term (Medium Impact, High Effort):
1. [Architectural improvements]
2. ...

───────────────────────────────────────────────────────────────
                BENCHMARKING RECOMMENDATIONS
───────────────────────────────────────────────────────────────

Missing Benchmarks:
- [List critical paths that should have benchmarks]

Existing Benchmarks:
- [List found benchmarks and suggest running them]

Profiling Suggestions:
- [How to profile this specific application]

───────────────────────────────────────────────────────────────
                PERFORMANCE BUDGET (if applicable)
───────────────────────────────────────────────────────────────

For Web Applications:
- Bundle Size: XXX KB (Target: < 200 KB)
- Initial Load: XXX ms (Target: < 1000 ms)
- Time to Interactive: XXX ms (Target: < 3000 ms)

For APIs:
- Avg Response Time: XXX ms (Target: < 200 ms)
- P95 Response Time: XXX ms (Target: < 500 ms)
- P99 Response Time: XXX ms (Target: < 1000 ms)

───────────────────────────────────────────────────────────────
                OPTIMIZATION ROADMAP
───────────────────────────────────────────────────────────────

Immediate (This Week):
- Fix all P0 issues
- [List specific P0 items with expected improvements]
- Estimated total improvement: XX%

Short-term (This Month):
- Address P1 issues
- [List specific P1 items]
- Estimated total improvement: XX%

Medium-term (This Quarter):
- Implement caching strategies
- Address P2 issues
- [List specific items]

Long-term (Ongoing):
- Regular performance testing
- Continuous profiling
- Performance budget enforcement

═══════════════════════════════════════════════════════════════
```

## Step 9: Provide Next Steps

Based on performance risk:

### If CRITICAL:
```
🚨 CRITICAL PERFORMANCE ISSUES FOUND

Your application has serious performance problems that will impact user experience.

IMMEDIATE ACTIONS REQUIRED:
1. Fix all P0 issues (N+1 queries, blocking operations, memory leaks)
2. Run benchmarks to measure improvements
3. Implement monitoring for performance regressions
4. Consider load testing before production deployment

DO NOT deploy to production without addressing P0 issues.
```

### If HIGH:
```
⚠️  SIGNIFICANT PERFORMANCE ISSUES FOUND

Your application has performance bottlenecks that should be addressed.

RECOMMENDED ACTIONS:
1. Prioritize P0 fixes this week
2. Address P1 issues before next release
3. Implement performance monitoring
4. Run `/perf-audit deep` with profiling for detailed analysis

Performance improvements will significantly enhance user experience.
```

### If MEDIUM:
```
⚠️  MODERATE PERFORMANCE ISSUES FOUND

Your application has optimization opportunities.

RECOMMENDED ACTIONS:
1. Address P0 issues before production
2. Plan P1 optimizations for next sprint
3. Implement benchmarking for critical paths

Can proceed with deployment after P0 fixes are applied.
```

### If LOW:
```
✅ GOOD PERFORMANCE CHARACTERISTICS

Your application is well-optimized with minor improvement opportunities.

OPTIONAL IMPROVEMENTS:
- Address P2/P3 micro-optimizations when convenient
- Implement performance budgets
- Regular benchmarking recommended

Safe to proceed with deployment.
```

## Notes

- This command does NOT modify files
- Provides comprehensive performance assessment
- Composes the `n-plus-one-detection` skill (if TypeScript + GraphQL)
- Algorithm and memory analysis in standard and deep modes
- Deep mode includes profiling guidance and benchmark review
- Can be run regularly as part of performance monitoring
- Use with load testing for complete performance picture
