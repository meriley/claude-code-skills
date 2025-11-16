---
name: Tutorial Writer
description: Creates beginner-friendly tutorials following Diátaxis pattern. Step-by-step guides with success criteria, time estimates, and verified working examples. Zero fabrication.
version: 1.0.0
---

# ⚠️ MANDATORY: Tutorial Writer Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Creating getting started guides for new features
2. Onboarding documentation for new users
3. Teaching new features or capabilities
4. Creating step-by-step learning guides
5. User requests: "write a tutorial for [feature]"

**This skill is MANDATORY because:**
- Helps users learn new features progressively
- Builds confidence through successful outcomes
- Provides complete working examples
- Reduces support burden from confused users
- Ensures successful feature adoption

**ENFORCEMENT:**

**P0 Violations (Critical - Immediate Failure):**
- Code examples that don't work or won't compile
- Fabricated APIs or methods (ZERO TOLERANCE)
- Examples using fake imports
- Examples that produce incorrect output
- Unverified performance claims

**P1 Violations (High - Quality Failure):**
- Missing success criteria
- Unclear step descriptions
- Incomplete examples
- Missing prerequisites
- No time estimates

**P2 Violations (Medium - Efficiency Loss):**
- Poor progression (too fast/slow)
- Missing explanations for why steps are needed
- Redundant or unclear wording

**Blocking Conditions:**
- EVERY code example must run and produce expected output
- EVERY API reference must exist in source
- Steps must be clear and actionable
- Success criteria must be verifiable

---

## Purpose

Create beginner-friendly, learning-oriented tutorials following the Diátaxis Tutorial pattern. Step-by-step guides with success criteria, time estimates, and complete working examples.

## Tutorial Structure (Diátaxis Tutorial Pattern)

### 1. Introduction
- What you'll build
- What you'll learn
- Why it matters
- Target audience

### 2. Prerequisites
- Required knowledge
- Required software/tools
- Time estimate
- Difficulty level

### 3. Step-by-Step Instructions

Each step includes:
- **What to do**: Clear action
- **Why**: Explanation of why this step matters
- **Code/Example**: Complete, working code
- **Expected result**: What success looks like
- **Verification**: How to confirm it worked

### 4. Working Example
- Complete, runnable code
- All dependencies shown
- Tested and verified
- Produces expected output

### 5. Next Steps
- What to learn next
- Related tutorials
- Advanced topics
- Resources for further learning

### 6. Troubleshooting
- Common issues
- Solutions
- When to ask for help

## Integration Points

Works with:
- **api-doc-writer** - Links to API reference for details
- **migration-guide-writer** - Shows migration in tutorial format
- **tutorial-writer** - Can reference other tutorials

## Anti-Patterns

### ❌ Anti-Pattern: Code That Doesn't Work

**Wrong approach:**
```
Step 3: "Create a user with this code:"
```go
user := User{Name: "John"}
user.Save()  // Method doesn't exist!
```

**Correct approach:** Verified, working code
```
Step 3: "Create a user:"
```go
service := NewUserService(db)
user, err := service.Create(ctx, &CreateUserRequest{Name: "John"})
if err != nil {
    return fmt.Errorf("failed to create user: %w", err)
}
// user is now created and saved
```

### ❌ Anti-Pattern: Missing Context

**Wrong approach:**
```
Step 1: "Initialize the service"
service := NewService()
```

**Correct approach:** Complete context
```
Step 1: "Initialize the service"

Import the service package at the top of your file:
```go
import "github.com/org/project/services"
```

Then create the service:
```go
service := services.NewUserService(db)
```

The `db` parameter is your database connection from Step 0.
```

---

## Success Criteria

Tutorial is complete when:
- ✅ All code examples tested and verified
- ✅ Steps are clear and actionable
- ✅ Success criteria defined for each step
- ✅ Time estimate provided
- ✅ Prerequisites listed
- ✅ Expected output shown
- ✅ Troubleshooting section included
- ✅ Examples use real, correct imports
- ✅ User can complete tutorial independently

## References

**Based on:**
- CLAUDE.md Section 3 (Available Skills Reference - tutorial-writer)
- Diátaxis Framework: https://diataxis.fr/tutorials/

**Related skills:**
- `api-doc-writer` - API reference for details
- `migration-guide-writer` - Problem-solving guides
