---
allowed-tools: Bash(find:*), Bash(grep:*), Read, Glob, Grep, Task
argument-hint: [module|--cycles|--coupling]
description: Analyze module dependencies, detect cycles, and measure coupling
---

# Architecture Analysis

Visualize module dependencies, detect circular imports, and measure coupling.

## Usage

```
/architecture                    # Full architecture analysis
/architecture src/api            # Focus on specific module
/architecture --cycles           # Only check for circular dependencies
/architecture --coupling         # Only show coupling metrics
```

## Step 1: Detect Project Type

```bash
ls -1 package.json go.mod requirements.txt tsconfig.json 2>/dev/null
```

Determine import patterns:
- **TypeScript/JavaScript**: `import ... from`, `require()`
- **Go**: `import "..."`, `import (...)`
- **Python**: `import ...`, `from ... import`

## Step 2: Build Dependency Graph

### For TypeScript/JavaScript

```bash
# Find all source files
find src -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx"

# Extract imports from each file
grep -rh "^import.*from\|^export.*from" src/ | grep -oE "from ['\"]([^'\"]+)['\"]"
```

### For Go

```bash
# Find all Go files
find . -name "*.go" -not -path "./vendor/*"

# Extract imports
grep -rh "^import\|^\t\"" --include="*.go" | grep -oE "\"[^\"]+\""
```

### For Python

```bash
# Find all Python files
find . -name "*.py" -not -path "./.venv/*"

# Extract imports
grep -rh "^import\|^from.*import" --include="*.py"
```

## Step 3: Analyze Dependencies

### Module Structure

```
PROJECT STRUCTURE
═══════════════════════════════════════

src/
├── api/           (12 files, 8 dependencies)
│   ├── handlers/  (5 files)
│   ├── middleware/ (3 files)
│   └── routes/    (4 files)
├── core/          (8 files, 3 dependencies)
│   ├── auth/      (3 files)
│   └── config/    (2 files)
├── utils/         (6 files, 1 dependency)
└── models/        (4 files, 2 dependencies)
```

### Dependency Matrix

```
DEPENDENCY MATRIX
═══════════════════════════════════════

             api  core  utils  models
api           -    ✓      ✓      ✓
core          ✗    -      ✓      ✓
utils         ✗    ✗      -      ✗
models        ✗    ✗      ✓      -

Legend:
✓ = depends on (imports from)
✗ = no dependency
```

## Step 4: Detect Circular Dependencies

Check for import cycles:

```
CIRCULAR DEPENDENCY CHECK
═══════════════════════════════════════

⚠️ 2 CIRCULAR DEPENDENCIES DETECTED

Cycle 1 (Length: 2)
┌─────────────────────────────────────┐
│ src/api/handlers/user.ts            │
│         ↓                           │
│ src/core/auth/session.ts            │
│         ↓                           │
│ src/api/handlers/user.ts  ← CYCLE   │
└─────────────────────────────────────┘

Imports creating cycle:
- user.ts:5 → import { validateSession } from '@/core/auth/session'
- session.ts:8 → import { getUserById } from '@/api/handlers/user'

Suggested fix:
- Extract shared types to a separate module
- Use dependency injection instead of direct import
- Create an interface in a third module

Cycle 2 (Length: 3)
┌─────────────────────────────────────┐
│ src/services/payment.ts             │
│         ↓                           │
│ src/services/order.ts               │
│         ↓                           │
│ src/services/inventory.ts           │
│         ↓                           │
│ src/services/payment.ts  ← CYCLE    │
└─────────────────────────────────────┘
```

## Step 5: Calculate Coupling Metrics

```
COUPLING METRICS
═══════════════════════════════════════

## Afferent Coupling (Ca) - Who depends on this module?

| Module    | Dependents | Risk Level |
|-----------|------------|------------|
| utils/    | 12         | High       |
| models/   | 8          | Medium     |
| core/     | 6          | Medium     |
| api/      | 2          | Low        |

High Ca = Changes here affect many modules

## Efferent Coupling (Ce) - What does this module depend on?

| Module    | Dependencies | Risk Level |
|-----------|--------------|------------|
| api/      | 8            | High       |
| core/     | 4            | Medium     |
| models/   | 2            | Low        |
| utils/    | 1            | Low        |

High Ce = This module is fragile to changes elsewhere

## Instability Index (I = Ce / (Ca + Ce))

| Module    | Ca  | Ce  | I     | Stability    |
|-----------|-----|-----|-------|--------------|
| utils/    | 12  | 1   | 0.08  | Very Stable  |
| models/   | 8   | 2   | 0.20  | Stable       |
| core/     | 6   | 4   | 0.40  | Moderate     |
| api/      | 2   | 8   | 0.80  | Unstable     |

Ideal: Stable modules (low I) should be depended on
       Unstable modules (high I) should depend on stable ones
```

## Step 6: Visualize Graph (Text-Based)

```
DEPENDENCY GRAPH
═══════════════════════════════════════

                    ┌──────────┐
                    │  utils   │ (stable, many dependents)
                    └────┬─────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
         ▼               ▼               ▼
    ┌─────────┐    ┌──────────┐    ┌──────────┐
    │ models  │    │   core   │    │   api    │
    └────┬────┘    └────┬─────┘    └────┬─────┘
         │              │               │
         └──────────────┼───────────────┘
                        │
                        ▼
                   ┌─────────┐
                   │  main   │ (entry point)
                   └─────────┘

Arrow direction: depends on →
```

## Step 7: Recommendations

```
ARCHITECTURE RECOMMENDATIONS
═══════════════════════════════════════

1. FIX: Circular dependencies (2 found)
   Priority: HIGH
   These can cause runtime issues and make testing difficult

2. CONSIDER: Extract shared types from api/core cycle
   Create: src/types/session.ts
   This breaks the circular dependency

3. IMPROVE: High coupling in api/ module (Ce=8)
   The API layer depends on too many modules
   Consider using interfaces and dependency injection

4. GOOD: utils/ module is properly stable (I=0.08)
   Many modules depend on it, but it has few dependencies

5. MONITOR: models/ coupling is appropriate
   Used by many, depends on few - good design

Run /architecture --cycles periodically to catch new cycles.
```

## Notes

- This is a READ-ONLY analysis command
- Large codebases may take longer to analyze
- Focus on specific modules with `/architecture src/api`
- Circular dependencies are P0 issues - fix immediately
- High coupling isn't always bad, but monitor it
- Use with `go-code-reviewer` or `hermes-code-reviewer` for full review
