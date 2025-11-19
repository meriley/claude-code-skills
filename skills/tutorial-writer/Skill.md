---
name: Tutorial Writer
description: Creates beginner-friendly, learning-oriented tutorials following Diátaxis Tutorial pattern. Step-by-step guides with success criteria, time estimates, and complete working examples. Zero tolerance for fabricated APIs - all code verified against source.
version: 1.0.0
---

# Tutorial Writer Skill

## Purpose

Create comprehensive, beginner-friendly tutorials that take learners from zero to a working result. Follows the Diátaxis Tutorial pattern for learning-oriented documentation. Verifies all APIs against source code before documenting, with complete working examples that have been tested.

## When to Use This Skill

- **New developer onboarding** - Help new team members get started
- **New major feature** - Teach users how to use new capabilities
- **Complex system** - Guide beginners through first steps
- **Users struggling** - When existing docs assume too much knowledge
- **Getting started missing** - No beginner path exists
- **User requests** - "tutorial for X" or "how do I get started with X"
- **After major API redesign** - Teach new patterns from scratch

## Diátaxis Framework: Tutorial

**Tutorial Type Characteristics:**
- **Learning-oriented** - Teaching, not just documenting
- **Beginner-focused** - Takes learner from zero to working result
- **Step-by-step** - Explicit, numbered steps with clear progression
- **Success criteria** - Learner can verify each step worked
- **Minimal explanations** - WHAT to do, not WHY it works (link to explanations)
- **Safe environment** - No production concerns, focus on learning
- **Confidence building** - Early steps are very simple to build momentum
- **Complete examples** - Everything needed to succeed included

**What NOT to Include:**
- ❌ Complete API reference - Link to api-doc-writer docs
- ❌ Problem-solving patterns - That's migration-guide-writer territory
- ❌ Deep explanations of WHY - Link to explanation docs
- ❌ Production deployment - Keep focus on learning basics

## Critical Rules (Zero Tolerance)

### P0 - CRITICAL Violations (Must Fix)
1. **Fabricated APIs** - Methods that don't exist in source code
2. **Wrong Signatures** - Incorrect parameter types or names
3. **Invalid Code** - Examples that won't compile or run
4. **Missing Success Criteria** - Steps without verification method
5. **Untested Examples** - Code you haven't actually run

### P1 - HIGH Violations (Should Fix)
6. **Too Advanced** - Assumes knowledge beginner doesn't have
7. **No Prerequisites** - Doesn't state what's needed before starting
8. **Missing Expected Output** - Doesn't show what success looks like
9. **No Time Estimates** - Learner doesn't know how long it takes

### P2 - MEDIUM Violations
10. **Too Much Explanation** - Getting into WHY when should focus on WHAT
11. **Marketing Language** - Buzzwords instead of clear instructions

## Step-by-Step Workflow

### Step 1: Goal Definition Phase (5-10 minutes)

**Define the learning outcome:**

```markdown
## Tutorial Goal Definition

**What they'll learn**: [Specific skill or capability]

**Target audience**:
- Experience level: [Complete beginner | Some experience | etc.]
- Prerequisites: [What they need to know already]
- Time to complete: [Realistic estimate]

**Success criteria**:
By the end, learner will be able to:
- ✅ [Specific concrete outcome 1]
- ✅ [Specific concrete outcome 2]
- ✅ [Specific concrete outcome 3]

**What they'll build**:
[Concrete thing - "a working task manager API" not "understanding of tasks"]
```

### Step 2: Source Code Research Phase (10-15 minutes)

**Read and verify all APIs you'll teach:**

```bash
# Read relevant source code
Read [source_files_for_apis]

# Extract exact signatures
# Verify imports
# Find or create working example
# Check test files for usage patterns
```

**Create API verification checklist:**
```markdown
## APIs to Use in Tutorial

- [ ] `APIMethod1` - Verified in [source_file.ext:MethodName]
- [ ] `APIMethod2` - Verified in [source_file.ext:MethodName]
- [ ] `ConfigOption1` - Verified in [config_file.ext]
- [ ] `Type1` - Verified in [types_file.ext:Type1]

All signatures copied exactly ✅
All imports verified ✅
```

**Test the example yourself:**
```bash
# Create a test file with your tutorial code
# Actually run it
# Verify it produces the result you'll document
# This is REQUIRED - don't guess!
```

### Step 3: Step Breakdown Phase (10-15 minutes)

**Break working example into logical steps:**

**Principles for step breakdown:**
1. **Start absurdly simple** - First step should be trivial (builds confidence)
2. **One concept per step** - Don't introduce multiple new things at once
3. **Clear success criteria** - Each step has verifiable outcome
4. **Realistic time estimates** - Be honest about time needed
5. **Progressive complexity** - Each step slightly harder than previous

**Example step breakdown:**
```markdown
## Step Breakdown

**Step 1**: Install and verify installation (5 min)
- Success: See version number output
- Introduces: Installation command

**Step 2**: Create project structure (3 min)
- Success: See project files created
- Introduces: Project initialization

**Step 3**: Write "Hello World" (5 min)
- Success: See "Hello World" output
- Introduces: Basic API usage

**Step 4**: Add basic configuration (7 min)
- Success: See configuration applied
- Introduces: Config file

**Step 5**: Add error handling (10 min)
- Success: See graceful error message
- Introduces: Error patterns

[Continue building up to final goal]
```

### Step 4: Writing Phase (20-30 minutes)

**Tutorial structure:**

```markdown
# Getting Started with [System/Feature]

[Brief introduction - what they'll accomplish in 2-3 sentences]

## Prerequisites

**Before you start, you need:**

- [Tool/Language] version [X.Y] or higher
- [Dependency] installed ([link to installation])
- Basic understanding of [concept] (see [explanation link])
- [Any other requirements]

**Check your setup:**
```bash
# Verify installations
[command to check version]
# Expected output:
[what they should see]
```

## What You'll Build

By the end of this tutorial, you'll have:

- ✅ [Concrete outcome 1]
- ✅ [Concrete outcome 2]
- ✅ [Concrete outcome 3]

**Total time**: [Realistic estimate] minutes

## Step 1: [Action] ([time] minutes)

[Very brief context - WHAT not WHY. 1-2 sentences max.]

### Create [Thing]

```[language]
// VERIFIED code from source - exact imports and signatures
import "[actual/import/path]"

[exact code with real APIs]
```

**Run it:**
```bash
[exact command to run the code]
```

**Expected output:**
```
[EXACT output they should see - copy from when you tested it]
```

✅ **Success check**: [How to verify this step worked]

**What you just did**: [1 sentence explaining the step - still WHAT not WHY]

---

## Step 2: [Next Action] ([time] minutes)

[Repeat step structure]

### [Substep if needed]

[Code example with verified APIs]

**Run it:**
```bash
[command]
```

**Expected output:**
```
[output]
```

✅ **Success check**: [Verification]

---

## Step 3: [Continue Building]

[Continue progressive steps to final goal]

---

## Complete Working Code

[Full, complete, tested code that includes everything from all steps]

```[language]
// Complete working example - VERIFIED
import "[all/real/imports]"

[Complete code from your testing - this MUST work]
```

**Run the complete example:**
```bash
[command to run]
```

**Expected output:**
```
[complete output]
```

## What You Learned

In this tutorial, you:

- ✅ [Learned skill 1]
- ✅ [Learned skill 2]
- ✅ [Learned skill 3]

## Next Steps

Now that you have the basics:

- **Explore more features**: See [API Reference link]
- **Solve specific problems**: See [How-To Guides link]
- **Understand the design**: See [Explanation docs link]
- **Try these exercises**:
  1. [Extension exercise 1]
  2. [Extension exercise 2]

## Troubleshooting

[Common issues learners encounter]

### Problem: [Common Issue]

**What you see:**
```
[Error message or behavior]
```

**Fix:**
```[language]
[Solution code]
```

---

**Tutorial Metadata**

**Last Updated**: [YYYY-MM-DD]
**System Version**: [Version this tutorial is for]
**Verified**: ✅ Tutorial tested and working
**Test Date**: [YYYY-MM-DD]

**Verification**:
- ✅ All code examples tested
- ✅ All APIs verified against source
- ✅ Expected outputs confirmed
- ✅ Time estimates realistic
- ✅ Success criteria clear

**Source files verified**:
- `path/to/source/file1.ext`
- `path/to/source/file2.ext`
```

### Step 5: Testing Phase (15-20 minutes)

**CRITICAL: Actually run through the tutorial yourself**

This is NOT optional. You MUST test the tutorial.

```bash
# Create fresh environment
# Follow your own tutorial exactly
# Do NOT skip any steps
# Do NOT assume things work
```

**As you test, verify:**
- [ ] Each command produces stated output
- [ ] Success criteria are achievable
- [ ] Time estimates are realistic (add 50% buffer for beginners)
- [ ] No steps are confusing or ambiguous
- [ ] Prerequisites are sufficient
- [ ] Complete code at end works
- [ ] Code examples compile/run
- [ ] All imports are real
- [ ] All APIs work as shown

**If ANY step fails during testing:**
- ❌ Do NOT publish tutorial
- Fix the step
- Test again from beginning
- Only publish after complete successful run-through

### Step 6: Verification Phase (5-10 minutes)

**Verification checklist:**

```markdown
## Tutorial Verification Checklist

### Testing (P0 - CRITICAL)
- [ ] Tutorial tested start-to-finish
- [ ] All commands run successfully
- [ ] All outputs match documentation
- [ ] Complete code tested and works
- [ ] Time estimates verified realistic

### API Verification (P0 - CRITICAL)
- [ ] All APIs verified against source
- [ ] All signatures exact
- [ ] All imports real
- [ ] No fabricated methods
- [ ] Code examples compile/run

### Learning Structure (P1 - HIGH)
- [ ] Success criteria for each step
- [ ] Time estimates for each step
- [ ] Prerequisites clearly stated
- [ ] Expected outputs documented
- [ ] Progressive complexity (simple → complex)

### Quality (P2 - MEDIUM)
- [ ] Minimal explanations (WHAT not WHY)
- [ ] No marketing language
- [ ] Clear, simple language
- [ ] Confidence-building progression
- [ ] Troubleshooting section included
```

## Integration with Other Skills

### Works With:
- **api-doc-writer** - Link to API reference for deeper info
- **migration-guide-writer** - After tutorial, guide to migrate existing code
- **api-documentation-verify** - Verify tutorial code accuracy

### Invokes:
- None (standalone skill)

### Invoked By:
- User (manual invocation)
- When onboarding documentation needed
- After major feature releases

## Output Format

**Primary Output**: Markdown file with structured tutorial

**File Location**:
- `docs/tutorials/getting-started-with-[feature].md`
- `TUTORIAL.md` in project root
- `docs/getting-started/[feature].md`

## Common Pitfalls to Avoid

### 1. Assuming Too Much Knowledge
```markdown
❌ BAD - Assumes knowledge
## Step 1: Configure the service
Set up your gRPC interceptors and middleware chain

✅ GOOD - Teaches from zero
## Step 1: Install the service (5 minutes)
First, install the service package:
```bash
npm install @company/service
```
```

### 2. Missing Expected Output
```markdown
❌ BAD - No output shown
Run the program:
```bash
node app.js
```

✅ GOOD - Shows exact output
Run the program:
```bash
node app.js
```
Expected output:
```
Starting service...
Service ready on port 3000
Waiting for requests...
```
```

### 3. No Success Verification
```markdown
❌ BAD - Can't verify success
## Step 2: Configure the database
[Configuration code]

✅ GOOD - Clear verification
## Step 2: Configure the database (7 minutes)
[Configuration code]

✅ **Success check**: Run `npm run db:test`. You should see:
```
Database connection: OK
Tables initialized: OK
```
```

### 4. Too Many Concepts Per Step
```markdown
❌ BAD - Multiple new concepts
## Step 3: Add authentication, logging, and error handling
[Complex code introducing 3 concepts]

✅ GOOD - One concept at a time
## Step 3: Add basic authentication (10 minutes)
[Code for auth only]

## Step 4: Add logging (7 minutes)
[Code for logging only]

## Step 5: Add error handling (8 minutes)
[Code for errors only]
```

### 5. Fabricated or Untested Code
```markdown
❌ BAD - Not tested
```typescript
// This should work
const result = await service.processTask()
```
[Code was never actually run - might not work!]

✅ GOOD - Tested and verified
```typescript
// VERIFIED working code
import { TaskService } from '@company/service'

const service = new TaskService()
const result = await service.processTask({
  id: 'task-123',
  title: 'Example Task'
})
console.log('Task processed:', result.id)
```
[This code was actually run and produced expected output]
```

### 6. Too Much Explanation
```markdown
❌ BAD - Deep explanation interrupts learning
## Step 2: Initialize the service

The service uses a sophisticated dependency injection container based on the inversion of control pattern. This architectural choice allows for better testability and loose coupling between components...

[3 more paragraphs of architecture discussion]

✅ GOOD - Minimal explanation, link for more
## Step 2: Initialize the service (5 minutes)

Create a new service instance:
```typescript
const service = new TaskService(config)
```

This sets up the service with your configuration. [Why this design?](link-to-explanation)
```

### 7. Unrealistic Time Estimates
```markdown
❌ BAD - Too optimistic
## Complete Tutorial (15 minutes)
[Actually takes 1-2 hours]

✅ GOOD - Realistic for beginners
## Complete Tutorial (60-90 minutes)
[Tested with beginner, added 50% buffer]
```

## Time Estimates

**Simple Tutorial** (< 5 steps, single concept): 1-2 hours to create
**Medium Tutorial** (5-10 steps, multiple concepts): 2-4 hours to create
**Complex Tutorial** (10+ steps, advanced concepts): 4-8 hours to create

**Include testing time!** Testing often takes as long as writing.

## Example Usage

```bash
# Manual invocation
/skill tutorial-writer

# User request
User: "I need a getting started guide for new developers"
Assistant: "I'll use tutorial-writer to create a beginner-friendly tutorial"

# After testing
User: "Create a tutorial for the TaskService API"
Assistant: "I'll create a step-by-step tutorial, test it, and verify all APIs"
```

## Success Criteria

Tutorial is complete when:
- ✅ Tested start-to-finish successfully
- ✅ All APIs verified against source code
- ✅ All code examples work
- ✅ All commands produce documented output
- ✅ Success criteria clear for each step
- ✅ Time estimates realistic for beginners
- ✅ Prerequisites clearly stated
- ✅ Progressive complexity (simple → complex)
- ✅ Complete working code at end
- ✅ No fabricated APIs
- ✅ No marketing language
- ✅ Minimal explanations (WHAT not WHY)

## Special Considerations for Tutorials

### Emoji Usage (Exception to No-Emoji Rule)

Tutorials ARE allowed to use structural emojis for clarity:

✅ **Allowed** (structural/functional):
- ✅ Success checkmarks for verification
- ❌ Error indicators
- ⚠️ Warning symbols
- 📝 Note indicators
- 🔧 Configuration steps

❌ **Not Allowed** (decorative/marketing):
- 🚀 "Blazing fast"
- 💯 "Perfect"
- 🔥 "Hot new feature"
- 🎉 "Exciting"

### Language Style

**Use clear, direct language:**
- "Create a file" not "Let's create a file"
- "Run the command" not "Now we'll run the command"
- "Install the package" not "You need to install the package"

**Be encouraging but factual:**
- ✅ "You've successfully created your first task"
- ❌ "Amazing! You're doing great!"

### Beginner-Friendly Practices

1. **No jargon without explanation**
2. **Link to prerequisite concepts**
3. **Show exact commands, not descriptions**
4. **Include complete context (imports, setup)**
5. **Verify each step immediately**
6. **Build confidence with early wins**
7. **Keep explanations minimal**
8. **Link to deeper explanations**

## References

- Diátaxis Framework: https://diataxis.fr/tutorials/
- Technical Documentation Expert Agent
- API Documentation Writer skill (for linking to API details)
- Tutorial Theory: https://documentation.divio.com/tutorials/
