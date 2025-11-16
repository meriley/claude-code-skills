---
name: SPARC Implementation Planning
description: Creates comprehensive SPARC plans (Specification, Pseudocode, Architecture, Refinement, Completion) with tasks, dependencies, security/performance considerations for significant features.
version: 1.0.0
---

# ⚠️ MANDATORY: SPARC Implementation Planning Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Starting significant feature (> 8 hours of work)
2. Major refactoring affecting multiple components
3. Complex bug fixes requiring architectural changes
4. When user explicitly requests "create an implementation plan"
5. Before making breaking changes to public APIs
6. When work affects multiple services/components

**This skill is MANDATORY because:**
- Prevents ad-hoc implementation without design (reduces bugs)
- Ensures comprehensive consideration of security/performance
- Identifies blockers and dependencies early
- Creates implementation roadmap for complex work
- Documents architectural decisions for future reference

**ENFORCEMENT:**

**P1 Violations (High - Quality Failure):**
- Skipping planning for significant work (> 8 hours)
- Missing security considerations from plan
- Missing performance considerations from plan
- No task breakdown or dependencies identified
- Incomplete specification phase

**P2 Violations (Medium - Efficiency Loss):**
- Not invoking check-history for context
- Missing risk assessment
- Unclear task ordering or estimates

**When NOT to Use:**
- Trivial changes (single file, < 20 lines)
- Documentation-only updates
- Simple bug fixes
- Configuration changes

**Blocking Conditions:**
- For work > 8 hours: Must complete full SPARC planning
- For work 4-8 hours: Simplified planning (specification, architecture, task list)
- For work < 4 hours: Can skip formal planning

---

## Purpose
Create comprehensive, structured implementation plans for significant development work using the SPARC (Specification, Pseudocode, Architecture, Refinement, Completion) framework.

## SPARC Framework Overview

**SPARC** is a five-phase development methodology:

1. **Specification**: Define requirements, constraints, and success criteria
2. **Pseudocode**: Create high-level algorithm descriptions
3. **Architecture**: Design system structure and component interactions
4. **Refinement**: Iteratively improve and optimize
5. **Completion**: Finalize, document, and verify

## Workflow (Abbreviated)

### Step 1: Invoke check-history
```
Invoke: check-history skill
```
Gather context about existing work and patterns.

### Step 2: Create Specification
- Functional requirements
- Non-functional requirements (performance, security, scale)
- Constraints
- Success criteria
- User stories/use cases

### Step 3: Create Pseudocode
- Algorithm pseudocode
- Component interface definitions
- Workflow descriptions
- Error handling strategy

### Step 4: Create Architecture
- Component breakdown
- Architecture patterns
- Data models
- Component interactions
- Technology choices
- Security architecture
- Performance architecture

### Step 5: Create Refinement Plan
- Code quality checks
- Performance optimization approach
- Security review plan
- Test coverage improvements

### Step 6: Create Completion Criteria
- Completion checklist
- Documentation requirements
- Deployment plan

### Step 7: Generate Task List
- Break down into ordered tasks
- Identify dependencies
- Estimate time per task
- Assign owners

### Step 8: Identify Risks and Blockers
- List potential blockers
- Mitigation strategies
- Risk assessment matrix

### Step 9: Create Security & Performance Plans
- Security checkpoints
- Performance targets
- Measurement approach

### Step 10: Document and Present
Save planning documents, present summary to user.

## Output Artifacts

1. Specification document
2. Pseudocode for algorithms
3. Architecture design
4. Refinement plan
5. Completion checklist
6. Ranked task list (with dependencies and estimates)
7. Security plan
8. Performance plan

## Integration Points

Invokes:
- **`check-history`** - Gather context

Followed by:
- **`manage-branch`** - Create feature branch
- **`safe-commit`** - Commit planning documents

## Anti-Patterns

### ❌ Anti-Pattern: Starting Without Planning

**Wrong approach:**
```
User: "Add JWT authentication"
Assistant: *immediately starts coding without planning*
```

**Why wrong:**
- No architecture design
- Security considerations missed
- Performance implications unknown
- Dependencies not identified
- Incomplete or incorrect implementation

**Correct approach:** Create SPARC plan first
```
User: "Add JWT authentication"
Assistant: "This is significant work - let me create an implementation plan using SPARC framework"
*Invokes sparc-plan skill*
*Creates full specification, architecture, task list*
*User reviews and approves plan*
*Then implementation begins with clear roadmap*
```

---

### ❌ Anti-Pattern: Skipping for "Simple" Features

**Wrong approach:**
```
Feature seems straightforward, skip planning
Discover midway: need to migrate data, coordinate with other team, security implications
```

**Correct approach:** Assess complexity first
```
Evaluate: "How long will this take?"
> 4 hours? Create at least simplified plan
> 8 hours? Full SPARC planning required
Identify: dependencies, security, performance implications
```

---

## Success Criteria

Plan is complete when:
- ✅ Specification phase documented
- ✅ Architecture designed
- ✅ Tasks broken down with dependencies
- ✅ Time estimates provided
- ✅ Security considerations identified
- ✅ Performance targets defined
- ✅ Risk assessment completed
- ✅ User reviewed and approved plan

## References

**Based on:**
- CLAUDE.md Section 3 (Available Skills Reference - sparc-plan)
- SPARC Framework methodology

**Related skills:**
- `check-history` - Invoked in Step 1
- `manage-branch` - Create feature branch after planning
