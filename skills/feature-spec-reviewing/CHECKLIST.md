# Feature Spec Review Checklist

Comprehensive checklist for reviewing feature specifications.

---

## Quick Review (3 minutes)

Use for initial assessment:

- [ ] Single-sentence feature definition exists
- [ ] Primary user story in correct format
- [ ] At least 3 acceptance criteria present
- [ ] Error states section exists
- [ ] Definition of done checklist present

**If 2+ items unchecked:** Flag for revision before deep review.

---

## Complete Review Checklist

### 1. Feature Definition

**Clarity (Severity: BLOCKER/CRITICAL)**
- [ ] Feature has single-sentence definition [BLOCKER if missing]
- [ ] Follows format: [Verb] [what] for [whom] to [outcome] [CRITICAL]
- [ ] Scope is bounded (single feature, not bundle) [BLOCKER if bundled]
- [ ] Aligns with parent PRD (if applicable) [MAJOR]

**Scope Test:**
| Symptom | Issue | Action |
|---------|-------|--------|
| Definition has "and" | Multiple features | Split into separate specs |
| Can't explain in 1 sentence | Too complex | Decompose further |
| Multiple user types | Different features | Create separate specs |

---

### 2. User Story

**Format Compliance (Severity: CRITICAL/MAJOR)**
- [ ] Follows "As a... I want... So that..." format [CRITICAL]
- [ ] All three parts present [CRITICAL]
- [ ] User type is specific, not generic [MAJOR]
- [ ] Goal is concrete and actionable [MAJOR]
- [ ] Benefit explains real value [MAJOR]

**Story Sizing:**
- [ ] Story is not epic-sized [BLOCKER]
- [ ] Can be implemented in one sprint [CRITICAL]
- [ ] Has clear boundaries [MAJOR]

**Variants (if present):**
- [ ] Variants represent different user paths
- [ ] Each variant has clear differentiation
- [ ] Variants don't overlap or conflict

---

### 3. Acceptance Criteria

**Happy Path (Severity: BLOCKER/CRITICAL)**
- [ ] Primary success scenario defined [BLOCKER]
- [ ] Uses Given/When/Then or clear checklist [CRITICAL]
- [ ] Specific, measurable outcomes [CRITICAL]
- [ ] Covers complete user flow [MAJOR]

**Testability (Severity: CRITICAL)**
For each criterion, verify:
- [ ] QA can write test case from it
- [ ] Contains specific values (not "fast", "good")
- [ ] Has measurable outcomes
- [ ] Defines expected state changes

**Testability Quick Test:**
| Criterion Type | Good Example | Bad Example |
|----------------|--------------|-------------|
| Time | "within 300ms" | "quickly" |
| Behavior | "modal displays at 400x600px" | "modal appears" |
| Validation | "error: 'Email format invalid'" | "shows error" |
| State | "item added to cart, count = 1" | "updates cart" |

---

### 4. Edge Case Coverage

**Required Categories (Severity: CRITICAL/MAJOR)**

Each category should have at least one scenario:

- [ ] **Empty State** - No data, first-time user [CRITICAL]
- [ ] **Minimum Values** - 0, 1, empty string [CRITICAL]
- [ ] **Maximum Values** - Limits, overflow [CRITICAL]
- [ ] **Null/Undefined** - Missing optional data [MAJOR]
- [ ] **Concurrent Access** - Race conditions [MAJOR]
- [ ] **Timeout** - Slow responses [MAJOR]
- [ ] **Partial Failure** - Some succeed, some fail [MAJOR]
- [ ] **Network Conditions** - Offline, slow, reconnect [MAJOR]

**Coverage Scoring:**

| Categories Covered | Rating | Action |
|--------------------|--------|--------|
| 7-8 | Excellent | Approve |
| 5-6 | Good | Minor additions |
| 3-4 | Weak | Critical - add cases |
| 0-2 | Missing | Blocker - major gaps |

**Edge Case Prompts:**

Ask these questions to find missing cases:
- What if there's no data?
- What if there's too much data?
- What if two users do this simultaneously?
- What if the network is slow or drops?
- What if only part of the operation succeeds?
- What happens at exact boundaries (0, max, etc.)?

---

### 5. Error States

**Completeness (Severity: CRITICAL/MAJOR)**

- [ ] Error states matrix exists [CRITICAL]
- [ ] All API calls have failure handling [CRITICAL]
- [ ] User messages are helpful [MAJOR]
- [ ] Recovery paths defined [MAJOR]
- [ ] System actions appropriate [MAJOR]

**Error Categories to Verify:**

| Category | Examples | Severity if Missing |
|----------|----------|-------------------|
| Input Validation | Invalid format, missing field | CRITICAL |
| Network | Offline, timeout, partial response | CRITICAL |
| Server | 500, 503, rate limit | CRITICAL |
| Authorization | 401, 403 | MAJOR |
| Business Logic | Conflict, not found | MAJOR |
| External Systems | Third-party failures | MAJOR |

**Error State Quality:**

| Column | Good | Bad |
|--------|------|-----|
| Condition | "Network request times out after 30s" | "Network error" |
| Message | "Connection lost. Your changes are saved." | "Error occurred" |
| Action | "Retry 3x with backoff, then show retry button" | "Handle error" |
| Recovery | "User clicks retry, or changes auto-save for later" | "Fix it" |

---

### 6. UI/UX Considerations (for UI features)

**User Flow (Severity: MAJOR/MINOR)**
- [ ] Entry points documented [MAJOR]
- [ ] Key interactions defined [MAJOR]
- [ ] Exit points clear [MAJOR]
- [ ] Alternative paths shown [MINOR]

**Responsive Design (Severity: MAJOR)**
- [ ] Desktop behavior defined
- [ ] Tablet adaptations noted
- [ ] Mobile behavior specified
- [ ] Breakpoints identified

**States (Severity: MAJOR/MINOR)**
- [ ] Loading states defined [MAJOR]
- [ ] Empty states designed [MAJOR]
- [ ] Error states have UI [MAJOR]
- [ ] Success states clear [MINOR]

**Accessibility (Severity: MAJOR)**
- [ ] Keyboard navigation addressed
- [ ] Screen reader considerations
- [ ] Color contrast mentioned
- [ ] Focus management noted

---

### 7. Technical Constraints

**Dependencies (Severity: MAJOR)**
- [ ] Internal dependencies listed
- [ ] External dependencies listed
- [ ] Status of each dependency noted
- [ ] Owners identified

**Non-Functional Requirements (Severity: CRITICAL/MAJOR)**
- [ ] Performance targets specified [CRITICAL]
- [ ] Availability requirements noted [MAJOR]
- [ ] Throughput expectations [MAJOR]
- [ ] Data requirements clear [MAJOR]

**Feasibility Red Flags:**
| Flag | Issue | Severity |
|------|-------|----------|
| "TBD" dependencies | Undefined blockers | CRITICAL |
| No performance targets | Can't validate | CRITICAL |
| External APIs without SLA | Risk | MAJOR |
| "Should be fast" | Not measurable | MAJOR |

---

### 8. Definition of Done

**Checklist Quality (Severity: MAJOR)**
- [ ] Implementation items present
- [ ] Quality gates defined (tests, coverage)
- [ ] Documentation requirements
- [ ] Deployment criteria

**Completeness:**
| Category | Items to Include |
|----------|-----------------|
| Implementation | All AC implemented, edge cases, errors, loading |
| Quality | Unit tests, integration tests, E2E, code review |
| Documentation | API docs, help content, release notes |
| Deployment | Feature flag, monitoring, rollback plan |

---

### 9. Parent PRD Alignment (if applicable)

**Alignment (Severity: CRITICAL/MAJOR)**
- [ ] References specific PRD user story [MAJOR]
- [ ] Scope matches PRD boundaries [CRITICAL]
- [ ] Doesn't add out-of-scope items [CRITICAL]
- [ ] Success metrics support PRD goals [MAJOR]

---

## Review Decision Matrix

| Blockers | Critical | Major | Decision |
|----------|----------|-------|----------|
| 0 | 0 | 0-2 | APPROVE |
| 0 | 0-1 | 3-5 | APPROVE WITH CHANGES |
| 0 | 2-3 | Any | NEEDS REVISION |
| 1+ | Any | Any | MAJOR REVISION |

---

## Quick Reference Card

### Must Have (Blockers if Missing)
- Single-sentence feature definition
- Primary user story
- Happy path acceptance criteria
- At least 3 edge case categories

### Should Have (Critical if Missing)
- Testable acceptance criteria
- Error states matrix
- Performance requirements
- Definition of done

### Good to Have (Major if Missing)
- All 8 edge case categories
- UI/UX considerations (if UI)
- Technical dependencies
- Recovery paths for errors

### Nice to Have (Minor)
- Variants for user story
- Feature flags section
- Success metrics
- Rollout plan
