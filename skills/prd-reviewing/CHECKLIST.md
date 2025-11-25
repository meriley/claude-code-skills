# PRD Review Checklist

Comprehensive checklist for reviewing Product Requirements Documents.

---

## Quick Review (5 minutes)

Use this for initial assessment before deep review:

- [ ] Document has title, author, date, version
- [ ] Problem statement section exists and isn't a solution
- [ ] At least 3 user stories present
- [ ] Acceptance criteria exist for stories
- [ ] Scope section has both in-scope and out-of-scope
- [ ] Success metrics are defined with targets
- [ ] No obvious blockers visible

**If 3+ items unchecked:** Flag for major revision before deep review.

---

## Complete Review Checklist

### 1. Document Structure

**Metadata (All items Minor if missing)**
- [ ] Title clearly identifies the feature/product
- [ ] Author identified
- [ ] Date/version tracked
- [ ] Status indicated (Draft/Review/Approved)
- [ ] Stakeholders listed

**Completeness (Severity varies)**
- [ ] Problem Statement section present [BLOCKER if missing]
- [ ] User Stories section present [BLOCKER if missing]
- [ ] Acceptance Criteria present [BLOCKER if missing]
- [ ] Scope section present [CRITICAL if missing]
- [ ] Success Metrics present [CRITICAL if missing]
- [ ] Timeline/Milestones present [MAJOR if missing]
- [ ] Risks section present [MAJOR if missing]

---

### 2. Problem Statement

**Existence & Focus**
- [ ] Problem statement exists [BLOCKER]
- [ ] Focuses on user pain, not solution [BLOCKER if solution-focused]
- [ ] Written from user perspective [MAJOR]

**Clarity**
- [ ] Target users/personas identified [MAJOR]
- [ ] Problem is specific, not vague [MAJOR]
- [ ] Current state/workarounds described [MINOR]

**Evidence**
- [ ] Impact quantified (users, revenue, time) [MAJOR]
- [ ] Evidence cited (research, data, feedback) [MAJOR]
- [ ] Links to supporting research [MINOR]

**Scoring Guide:**
| Rating | Criteria |
|--------|----------|
| **Strong** | User-focused, quantified, evidence-backed |
| **Adequate** | Clear problem, some quantification |
| **Weak** | Vague or partially solution-focused |
| **Missing** | No problem statement or pure solution |

---

### 3. User Stories

**Format Compliance**
- [ ] Follows "As a... I want... So that..." format [CRITICAL]
- [ ] Each story has all three parts [CRITICAL]
- [ ] Consistent format across all stories [MINOR]

**Quality (per story)**
- [ ] User type is specific (not generic "user") [MAJOR]
- [ ] Goal is clear and achievable [MAJOR]
- [ ] Benefit explains the "why" [MAJOR]
- [ ] Story is independent (no hidden dependencies) [CRITICAL]
- [ ] Story is small enough for one sprint [CRITICAL]

**Coverage**
- [ ] Covers primary use case [BLOCKER if missing]
- [ ] Covers secondary use cases [MAJOR]
- [ ] Prioritized (Must/Should/Could Have) [MAJOR]
- [ ] Sized (S/M/L/XL) [MINOR]

**Red Flags:**
- [ ] No epic-sized stories (entire features as one story) [CRITICAL]
- [ ] No implementation-focused stories ("As a dev...") [MAJOR]
- [ ] No duplicate or overlapping stories [MAJOR]

---

### 4. Acceptance Criteria

**Format**
- [ ] Uses Given/When/Then or clear checklist [CRITICAL]
- [ ] Consistent format across all criteria [MINOR]

**Completeness (per story)**
- [ ] Happy path covered [BLOCKER if missing]
- [ ] Error states covered [CRITICAL]
- [ ] Edge cases considered [MAJOR]
- [ ] Validation rules specified [MAJOR]

**Testability**
- [ ] Each criterion is testable by QA [CRITICAL]
- [ ] Contains specific values (not "fast", "good") [CRITICAL]
- [ ] Measurable outcomes defined [MAJOR]

**Coverage Categories:**
- [ ] Functional requirements covered [BLOCKER]
- [ ] Performance expectations stated [MAJOR]
- [ ] Security requirements noted [MAJOR if applicable]
- [ ] Accessibility requirements noted [MAJOR if applicable]

**Testability Quick Test:**
For each criterion, ask: "Could I write an automated test from this?"

| Result | Action |
|--------|--------|
| Yes, clearly | Pass |
| Maybe, with assumptions | Flag as MAJOR |
| No, too vague | Flag as CRITICAL |

---

### 5. Scope Definition

**In Scope**
- [ ] In-scope items clearly listed [CRITICAL]
- [ ] Items are specific, not vague [MAJOR]
- [ ] Prioritization indicated [MAJOR]
- [ ] Aligns with user stories [MAJOR]

**Out of Scope**
- [ ] Out-of-scope section exists [CRITICAL]
- [ ] Exclusions are explicit [MAJOR]
- [ ] Reasons provided for exclusions [MAJOR]
- [ ] Future consideration noted where applicable [MINOR]

**Dependencies**
- [ ] Internal dependencies identified [MAJOR]
- [ ] External dependencies identified [MAJOR]
- [ ] Owners assigned to dependencies [MAJOR]
- [ ] Status indicated (Ready/In Progress/Blocked) [MAJOR]
- [ ] Risk level assessed [MINOR]

**Assumptions**
- [ ] Key assumptions documented [MAJOR]
- [ ] Assumptions are reasonable [MAJOR]
- [ ] High-risk assumptions flagged [CRITICAL]

**Open Questions**
- [ ] Open questions listed [MAJOR]
- [ ] Owners assigned [MAJOR]
- [ ] Timeline for resolution [MINOR]

**Scope Smell Tests:**
| Symptom | Indication | Severity |
|---------|------------|----------|
| Endless in-scope list | Scope creep risk | MAJOR |
| Empty out-of-scope | Poor boundary thinking | CRITICAL |
| Dependencies with no owners | Delivery risk | MAJOR |
| Many unvalidated assumptions | Rework risk | MAJOR |

---

### 6. Success Metrics

**Metric Quality**
- [ ] Metrics are specific and measurable [CRITICAL]
- [ ] Current baseline provided [CRITICAL]
- [ ] Target is specific and timebound [CRITICAL]
- [ ] Measurement method defined [MAJOR]

**Metric Alignment**
- [ ] Metrics relate to problem statement [CRITICAL]
- [ ] Leading indicators included [MAJOR]
- [ ] Lagging indicators included [MAJOR]
- [ ] Metrics are actionable (not vanity) [MAJOR]

**Guardrails**
- [ ] Guardrail metrics defined [MAJOR]
- [ ] Thresholds specified [MAJOR]
- [ ] Action if breached specified [MINOR]

**Metric Quality Matrix:**
| Type | Good Example | Bad Example |
|------|--------------|-------------|
| Specific | "Cart abandonment 23% → 18%" | "Reduce abandonment" |
| Measurable | "p95 latency < 200ms" | "Fast response" |
| Aligned | Problem: costs unclear, Metric: visibility rate | Problem: speed, Metric: page views |
| Actionable | "NPS score improvement" | "Total page views" |

---

### 7. Timeline & Milestones

**Presence**
- [ ] Timeline section exists [MAJOR]
- [ ] Key milestones identified [MAJOR]
- [ ] Target dates provided [MAJOR]

**Realism**
- [ ] Timeline seems achievable given scope [CRITICAL]
- [ ] Engineering input noted [MAJOR]
- [ ] Buffer for unknowns considered [MINOR]

**Milestones**
- [ ] Clear success criteria per milestone [MAJOR]
- [ ] Dependencies between milestones noted [MINOR]
- [ ] Rollout strategy defined [MAJOR for large features]

---

### 8. Risks

**Identification**
- [ ] Risks section exists [MAJOR]
- [ ] Technical risks identified [MAJOR]
- [ ] Timeline risks identified [MAJOR]
- [ ] Resource risks identified [MAJOR]
- [ ] Dependency risks identified [MAJOR]
- [ ] Market/adoption risks identified [MINOR]

**Mitigation**
- [ ] Mitigation strategies provided [MAJOR]
- [ ] Owners assigned [MINOR]
- [ ] Contingency plans noted [MINOR]

---

### 9. Overall Assessment

**Readiness Indicators**
- [ ] Problem is clear and validated
- [ ] Solution approach is sound
- [ ] Scope is well-bounded
- [ ] Success is measurable
- [ ] Risks are manageable
- [ ] Stakeholders are aligned

**Approval Decision Matrix:**

| Blockers | Critical | Major | Decision |
|----------|----------|-------|----------|
| 0 | 0 | 0-2 | APPROVE |
| 0 | 0-1 | 3-5 | APPROVE WITH CHANGES |
| 0 | 2-3 | Any | NEEDS REVISION |
| 1+ | Any | Any | MAJOR REVISION REQUIRED |

---

## Checklist Summary Card

### Must Check (Blockers if Missing)
- Problem statement (user-focused, not solution)
- User stories exist
- Acceptance criteria exist

### Should Check (Critical if Missing)
- Scope boundaries (in and out)
- Success metrics with baselines
- User story format compliance
- Testable acceptance criteria

### Good to Check (Major if Missing)
- Evidence/data for problem
- Edge case coverage
- Dependencies with owners
- Timeline realism
- Risk identification

### Nice to Check (Minor if Missing)
- Document metadata
- Formatting consistency
- Links to research
- Mockups/wireframes
