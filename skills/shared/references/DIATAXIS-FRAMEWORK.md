# Diátaxis Documentation Framework Reference

This reference provides comprehensive guidance on the Diátaxis framework for technical documentation. Load when creating or reviewing documentation that needs to follow proper Diátaxis structure.

---

## The Diátaxis Framework: Four Documentation Types

Diátaxis divides documentation into four distinct types based on user needs:

```
                Learning-oriented | Understanding-oriented
            ----------------------|-------------------------
Practical:  TUTORIALS            | HOW-TO GUIDES
            ----------------------|-------------------------
Theoretical: REFERENCE           | EXPLANATION
```

---

## 1. TUTORIALS (Learning-Oriented)

**Purpose**: Take a beginner from zero to a working result

**Characteristics:**

- Complete working example
- Step-by-step instructions
- Clear success criteria at each step
- Minimal explanations (focus on WHAT, not WHY)
- Safe environment for learning
- Repeatable results
- Confidence building through early simple steps
- Time estimates for each step

**Example Structure:**

```markdown
# Getting Started with TaskCore

## Prerequisites

- Go 1.23+
- Records Service access

## What You'll Build

By the end: ✅ Working task entity ✅ Persisted to database ✅ Retrieved successfully

## Step 1: Add Dependencies (2 minutes)

[Exact commands]

## Step 2: Initialize Factory (3 minutes)

[Complete code example]

## Step 3: Create Your First Task (5 minutes)

[Working code with verified APIs]
```

**What NOT to Include:**

- ❌ Deep explanations of WHY (that's for EXPLANATION)
- ❌ Multiple approaches or trade-offs (that's for HOW-TO)
- ❌ Complete API reference (that's for REFERENCE)
- ❌ Production deployment concerns (keep focus on learning)

---

## 2. HOW-TO GUIDES (Problem-Oriented)

**Purpose**: Solve specific practical problems

**Characteristics:**

- Assumes basic knowledge
- Focused on specific goal
- Series of steps to solution
- Multiple valid approaches okay
- Real-world scenarios
- Production-ready patterns
- Troubleshooting guidance

**Example Structure:**

```markdown
# How to Migrate from RQTask

## Goal

Replace RQTask service calls with TaskCore entities

## When to Use This

- Existing RQTask integration
- Want to eliminate service dependency
- Need better type safety

## Pattern 1: Create Task

[Before/After with verified APIs]

## Pattern 2: Update Task

[Before/After with verified APIs]

## Troubleshooting

[Common issues and solutions]
```

**What NOT to Include:**

- ❌ Teaching from zero (that's for TUTORIAL)
- ❌ Complete API documentation (that's for REFERENCE)
- ❌ Explaining architectural decisions (that's for EXPLANATION)

---

## 3. REFERENCE (Information-Oriented)

**Purpose**: Describe the machinery accurately

**Characteristics:**

- Technical descriptions
- Complete API coverage
- Exact method signatures (VERIFIED)
- Parameter descriptions
- Return type details
- Error conditions
- Examples of usage
- Structured consistently
- No step-by-step instructions

**Example Structure:**

````markdown
# Entity Package Reference

## Task Entity

### Method: ToNode

```go
func (t *Task) ToNode() (*types.Node, error)
```
````

**Description**: Converts task entity to graph node format.

**Returns**:

- `*types.Node`: Graph node representation
- `error`: Conversion error if validation fails

**Example**:
[Verified working code]

**Source**: `entity/task.go` (ToNode method)

````

**What NOT to Include:**
- ❌ Step-by-step tutorials (that's for TUTORIAL)
- ❌ Problem-solving patterns (that's for HOW-TO)
- ❌ Architectural explanations (that's for EXPLANATION)

---

## 4. EXPLANATION (Understanding-Oriented)

**Purpose**: Clarify and illuminate design

**Characteristics:**
- Discusses alternatives and trade-offs
- Explains WHY decisions were made
- Provides historical context
- Connects to broader concepts
- No step-by-step instructions
- Architectural perspective
- Design philosophy

**Example Structure:**
```markdown
# TaskCore Architecture

## Design Philosophy

### Entity-Driven Approach

**Decision**: Use entities instead of service calls

**Why**:
- Eliminates network overhead (factual architectural truth)
- Enables compile-time validation
- Simplifies testing

**Trade-offs**:
- ❌ Requires direct database access
- ✅ Removes service dependency
- ✅ Better type safety

**Alternative Approaches Considered**:
[Other approaches and why they weren't chosen]
````

**What NOT to Include:**

- ❌ Step-by-step instructions (that's for TUTORIAL/HOW-TO)
- ❌ Complete API reference (that's for REFERENCE)
- ❌ Specific performance claims without evidence

---

## Choosing the Right Type

### User Says: "I want to learn..."

→ **TUTORIAL** - Teach from zero with step-by-step guidance

### User Says: "How do I solve..."

→ **HOW-TO GUIDE** - Provide solution pattern for specific problem

### User Says: "What does X do?"

→ **REFERENCE** - Document exact API behavior

### User Says: "Why was it designed this way?"

→ **EXPLANATION** - Discuss architectural decisions

---

## Common Violations

### Mixed Tutorial + Reference

❌ Tutorial that dumps entire API documentation in the middle
✅ Tutorial with minimal API usage + link to reference docs

### How-To That Teaches From Zero

❌ How-To that assumes no knowledge and teaches basics
✅ How-To that assumes basic knowledge and solves specific problem

### Reference With Step-by-Step

❌ Reference docs with "Step 1, Step 2, Step 3"
✅ Reference docs with concise usage examples

### Explanation With Tutorials

❌ Explanation that includes complete step-by-step setup
✅ Explanation that discusses WHY, links to tutorial for HOW

---

## Documentation Quality Standards

### Factual Accuracy (P0 - Critical)

- ✅ Every API verified against source code
- ✅ Method signatures exactly match
- ✅ Code examples use real imports and types
- ❌ No fabricated methods
- ❌ No performance claims without benchmarks
- ❌ No statistics without data

### Code Validity (P1 - High)

- ✅ All code examples would compile
- ✅ Imports are correct
- ✅ Types exist and are used correctly
- ✅ Error handling present

### Structure (P2 - Medium)

- ✅ Correct Diátaxis type chosen
- ✅ No mixed purposes
- ✅ Cross-references accurate
- ✅ Navigation clear

### Style (P3 - Low)

- ✅ Clear, concise writing
- ✅ Consistent terminology
- ✅ Technical tone (no marketing buzzwords)
- ❌ No emojis in documentation text
- ❌ No sales language ("Key Features", "Benefits")

---

## Performance Claims Guidelines

### ❌ NEVER SAY (Without Evidence):

- "10x faster"
- "50ms → 5ms"
- "33x improvement"
- "90% reduction"
- ANY specific numbers or multipliers without benchmarks

### ✅ ALWAYS ACCEPTABLE (Factual Architecture):

- "Eliminates network overhead"
- "In-process execution"
- "Reduces database round-trips"
- "Single network call instead of multiple"
- "Removes service dependency"
- "Direct database access"

### 🔍 WHEN YOU CAN USE NUMBERS:

**Only if you have:**

1. Actual benchmark code comparing the systems
2. Real timing measurements from runs
3. Statistical analysis of results
4. Clear methodology documentation

**Format:**

````markdown
## Performance Characteristics

Based on benchmarks in `benchmark_file.go`:

```bash
BenchmarkOldSystem-8     1000  1250 ns/op
BenchmarkNewSystem-8     5000   235 ns/op
```
````

NewSystem shows approximately 5x improvement in this microbenchmark.

**Note**: Real-world performance depends on network latency,
database performance, and workload characteristics.

````

---

## Marketing Language to Avoid

### ❌ NEVER USE (Buzzwords):
- "enterprise", "world-class", "industry-leading", "best-in-class"
- "advanced", "powerful", "high-performance" (without evidence)
- "blazingly fast", "lightning-fast", "super fast"
- "robust", "comprehensive", "complete", "full-featured"
- "modern", "next-generation", "state-of-the-art", "cutting-edge"
- "revolutionary", "innovative", "game-changing"
- "seamless", "intuitive", "elegant", "beautiful"
- "first-class" (use specific technical terms instead)

### ❌ NEVER USE (Emojis):
Remove all decorative emojis from:
- Section headers (📚 Continue Learning)
- Feature lists (🏗️ Entity-Driven)
- Callouts (⚠️ Warning, ✅ Success)

**Exception**: Emojis are acceptable ONLY if they're part of actual program output being demonstrated.

### ❌ NEVER USE (Sales Language):
- "Key Features" → "Features"
- "Benefits Over X" → "Comparison with X"
- "Quick Start" → "Usage" or "Getting Started"
- "Why Choose X?" → "Design Rationale"

### ✅ ALWAYS USE (Factual Alternatives):

```markdown
❌ "TaskCore provides advanced metadata processing"
✅ "TaskCore processes metadata through a multi-stage pipeline with normalization, validation, and field promotion"

❌ "Enterprise-grade task management library"
✅ "Go library for task entity management"

❌ "Robust error handling"
✅ "Error handling with context propagation"

❌ "Modern replacement for RQTask"
✅ "Replacement for RQTask"

❌ "First-class integration with ZekeDB"
✅ "Native graph database integration with ZekeDB"
````

---

## Document Templates

### Tutorial Template

````markdown
---
title: "Getting Started with [System]"
description: "[Outcome] in [time]"
---

# Getting Started with [System]

[Intro: What they'll accomplish]

## Prerequisites

- [Requirement 1]
- [Requirement 2]

## What You'll Build

By the end:

- ✅ [Concrete outcome 1]
- ✅ [Concrete outcome 2]

---

## Step 1: [Action] ([time] minutes)

[Brief context]

```[language]
// VERIFIED API from [source file]
[exact code example]
```
````

**Run it:**

```bash
[exact command]
# Expected output:
[exact output]
```

✅ **Success**: [how to verify this step worked]

---

[Repeat for each step]

````

### How-To Template
```markdown
---
title: "How to [Accomplish Goal]"
description: "[Brief description]"
---

# How to [Accomplish Goal]

[Brief intro: the problem this solves]

## When to Use This
- [Scenario 1]
- [Scenario 2]

## Prerequisites
- [Assumed knowledge/setup]

---

## Pattern 1: [Approach Name]

**Goal**: [Specific outcome]

### Before (Old Way)
```[language]
[old code]
````

### After (New Way)

```[language]
// VERIFIED API from [source]
[new code with actual APIs]
```

**Why This Works**: [Brief explanation]

---

## Troubleshooting

### Issue: [Common Problem]

**Symptom**: [What user sees]
**Cause**: [Why it happens]
**Solution**: [How to fix]

````

### Reference Template
```markdown
---
title: "[Package] Package Reference"
description: "Complete API reference"
---

# [Package] Package Reference

[Brief package description]

---

## [Type Name]

### Type Definition
```[language]
// Copied from [source file]
[type definition]
````

**Source**: `[path/to/file]`

---

### Method: [MethodName]

```[language]
// EXACT signature from [source file]
[method signature]
```

**Description**: [What this method does]

**Parameters**:

- `param` (Type): [Description]

**Returns**:

- `ReturnType`: [Description]
- `error`: [Error conditions]

**Example**:

```[language]
// VERIFIED example
[working code]
```

**Source**: `[path/to/file]` ([MethodName] method)

````

### Explanation Template
```markdown
---
title: "[System] Architecture"
description: "Understanding the design"
---

# [System] Architecture

[High-level overview]

## Design Philosophy

### Principle 1: [Design Decision]

**Decision**: [What was chosen]

**Why**:
- [Factual reason 1]
- [Factual reason 2]

**Trade-offs**:
- ❌ [Downside]
- ✅ [Benefit - factual, no unverified numbers]

---

## Architecture Diagram

```mermaid
[diagram showing structure]
````

**Key Components**:

1. **Component 1**: [Purpose and responsibility]
2. **Component 2**: [Purpose and responsibility]

---

## Alternative Approaches Considered

### Approach: [Alternative]

**Why Not Chosen**: [Factual reasons]

```

---

## References

- **Diátaxis Official Site** - https://diataxis.fr/
- **Write The Docs** - https://www.writethedocs.org/
- **Google Developer Documentation Style Guide** - Technical writing best practices
```
