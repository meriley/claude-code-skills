## Troubleshooting

### Problem: Requirements are incomplete or vague

**Symptoms:**

- User can't answer clarifying questions
- Specifications are too high-level
- Success criteria undefined

**Solution:**

1. Break down into smaller, well-defined pieces
2. Focus on MVP (Minimum Viable Product) first
3. Plan iteratively - start with what's known
4. Document assumptions explicitly
5. Schedule follow-up planning session when requirements clarify

---

### Problem: Too many dependencies or blockers identified

**Symptoms:**

- Critical path has many external dependencies
- Multiple high-risk items
- Implementation seems impossible

**Solution:**

1. Re-scope to remove/defer optional dependencies
2. Identify alternative approaches with fewer dependencies
3. Plan dependency resolution tasks first
4. Create contingency plans for each blocker
5. Consider splitting into multiple smaller features

---

### Problem: Estimated time is unrealistic or unknown

**Symptoms:**

- Tasks have wildly different estimates
- Total time is way over budget
- Can't estimate certain tasks

**Solution:**

1. Use time-boxing: "This task gets max 4 hours"
2. Add research spikes for unknown areas
3. Break large estimates into smaller measurable tasks
4. Use past similar work as reference
5. Build in buffer time (multiply estimates by 1.5x)

---

### Problem: Architecture phase reveals fundamental issues

**Symptoms:**

- Chosen technology can't meet requirements
- Performance targets are impossible
- Security requirements conflict with design

**Solution:**

1. **STOP** - Don't proceed with flawed plan
2. Go back to Specification phase
3. Revise requirements or constraints
4. Research alternative approaches
5. Get user approval for revised approach

---

### Problem: Plan is too detailed and taking too long

**Symptoms:**

- Planning session exceeds 2 hours
- Documents are 20+ pages
- Getting lost in minutiae

**Solution:**

1. **Simplify** - Remember: plan is a guide, not a contract
2. Focus on critical decisions only
3. Defer implementation details to coding phase
4. Use "good enough" approach for non-critical aspects
5. Time-box planning: "We have 90 minutes max"

---

### Problem: Plan doesn't match team conventions

**Symptoms:**

- Proposed architecture differs from existing code
- Technology choices conflict with stack
- Patterns don't match codebase style

**Solution:**

1. Review recent similar implementations (`check-history`)
2. Align with existing patterns and conventions
3. If change is justified, document rationale explicitly
4. Get team/stakeholder buy-in before proceeding
5. Consider creating architecture decision record (ADR)

---

### Problem: User rejects or significantly changes plan

**Symptoms:**

- Major revisions requested after presentation
- User had different expectations
- Plan doesn't solve actual problem

**Solution:**

1. Don't take it personally - iterate!
2. Clarify what specifically needs changing
3. Understand the gap: requirements, approach, or scope?
4. Revise and re-present (faster iteration)
5. Consider if requirements gathering was insufficient

---
