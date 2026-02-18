# PRD Review Examples

Real-world examples of PRD reviews demonstrating different quality levels and feedback patterns.

---

## Example 1: Strong PRD - E-Commerce Shipping Calculator

### Original PRD Excerpt

```markdown
# Shipping Cost Transparency - PRD

## Problem Statement
Shoppers abandon their carts at a 23% rate when they reach the shipping
step and see unexpected costs. User research (n=156) shows 67% of users
want to see shipping costs before committing to checkout. This results
in an estimated $2.4M in lost annual revenue.

## User Stories

### US-1: View Shipping Cost on Product Page
As a shopper,
I want to see estimated shipping cost on the product page,
so that I know the total cost before adding to cart.

Acceptance Criteria:
Given I am on a product page with items in stock
And I have entered my zip code
When I click "Calculate Shipping"
Then I see shipping options within 2 seconds
And each option shows carrier name, price, and delivery estimate

### US-2: Compare Shipping Options
As a shopper,
I want to compare shipping options side-by-side,
so that I can choose between speed and cost.

[Additional stories...]

## Scope

### In Scope
- Real-time shipping calculation on product pages
- Integration with UPS, FedEx, USPS APIs
- Zip code-based estimation for logged-out users

### Out of Scope
- International shipping (pending carrier contracts)
- Multi-package calculations (low frequency use case)
- Shipping insurance options (separate initiative)

## Success Metrics

| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| Cart abandonment at shipping | 23% | 18% | Analytics |
| Calculator usage rate | N/A | 40% | Event tracking |
| Time to shipping decision | 45s | 20s | Session recording |
```

### Review

```markdown
# PRD Review: Shipping Cost Transparency

**Reviewer:** mriley
**Review Date:** 2024-01-15
**PRD Version:** 1.2
**PRD Author:** Product Team

---

## Summary

**Status:** APPROVE WITH CHANGES

**Overall Assessment:**
Excellent PRD with clear problem statement backed by research data.
User stories are well-structured and acceptance criteria are testable.
Minor gaps in edge case handling for acceptance criteria. Ready for
engineering review after addressing minor items.

---

## Findings by Severity

### Blockers (Must Fix Before Approval)
None identified.

### Critical (Should Fix Before Implementation)
None identified.

### Major (Fix Soon)
- [ ] **US-1 Acceptance Criteria:** Missing timeout/error handling scenario.
  What happens if carrier API takes > 5 seconds or fails?
  → Add error state acceptance criteria

- [ ] **Dependencies:** UPS API integration shows "In Progress" but
  no target completion date.
  → Add expected date and contingency plan

### Minor (Nice to Have)
- [ ] **Scope:** Consider explicitly excluding "free shipping threshold
  display" or add as future consideration.

- [ ] **US-2:** Could add acceptance criteria for mobile responsive
  comparison view.

- [ ] **Metrics:** Consider adding a guardrail for checkout conversion
  rate to ensure it doesn't decrease.

---

## Section Ratings

| Section | Rating | Notes |
|---------|--------|-------|
| Problem Statement | Strong | Quantified, research-backed |
| User Stories | Strong | INVEST compliant, well-sized |
| Acceptance Criteria | Adequate | Missing error scenarios |
| Scope | Strong | Clear boundaries |
| Success Metrics | Adequate | Could add guardrails |

---

## Strengths
- Research-backed problem with clear ROI justification ($2.4M)
- User stories are independent and appropriately sized
- Explicit out-of-scope with rationale for each item
- Measurable success metrics with baselines

## Risks Identified
1. **Carrier API reliability** - If APIs are slow/unavailable, user
   experience degrades. → Mitigation: Add fallback messaging and
   consider caching strategy.

2. **Zip code accuracy** - Logged-out users may enter wrong zip.
   → Consider: Address validation before calculation.

---

## Questions for Author
1. Should shipping be recalculated if cart contents change?
2. How should we handle items with variable shipping (oversized)?
3. Is there a cache strategy for shipping rates? TTL?

---

## Recommendation

Approve after addressing the two Major items:
1. Add error handling acceptance criteria to US-1
2. Get confirmed date for UPS API integration

Minor items can be addressed during implementation.
```

---

## Example 2: Needs Revision - SaaS Team Permissions

### Original PRD Excerpt

```markdown
# Team Permissions - PRD

## Problem Statement
We need to add role-based access control so enterprise customers
can manage what their team members can access.

## User Stories

### US-1: Manage Roles
As an admin, I want to manage team roles, so that I can control access.

Acceptance Criteria:
- Admin can create roles
- Admin can edit roles
- Admin can delete roles
- Roles control access

### US-2: Assign Users
As an admin, I want to assign users to roles.

### US-3: Audit Log
As an admin, I want to see who changed what.

## Scope
### In Scope
- Role management
- User assignment
- Audit logging

## Success Metrics
- More enterprise customers
- Fewer support tickets
```

### Review

```markdown
# PRD Review: Team Permissions

**Reviewer:** mriley
**Review Date:** 2024-01-15
**PRD Version:** 0.5
**PRD Author:** Product Team

---

## Summary

**Status:** NEEDS REVISION

**Overall Assessment:**
PRD has good structure but significant gaps that would cause
implementation ambiguity. Problem statement is solution-focused.
Acceptance criteria lack specificity. Metrics are not measurable.
Recommend revision and re-review before approval.

---

## Findings by Severity

### Blockers (Must Fix Before Approval)
- [ ] **Problem Statement:** "We need to add RBAC" is a solution, not
  a problem. What user pain does this solve? What's the business impact?
  → Rewrite focusing on user/business pain. Include:
    - Who is affected (enterprise admins, compliance teams)
    - What pain they experience (compliance audit failures, security risk)
    - Impact (blocked deals, compliance violations, churn)

### Critical (Should Fix Before Implementation)
- [ ] **US-1 Acceptance Criteria:** "Roles control access" is not
  testable. What access? To what resources? What happens when denied?
  → Expand with specific Given/When/Then scenarios

- [ ] **US-2:** No acceptance criteria at all.
  → Add criteria covering assignment flow, confirmation, and validation

- [ ] **US-3:** "See who changed what" - too vague.
  → Specify: what events are logged, what data captured, retention period

- [ ] **Success Metrics:** "More enterprise customers" and "fewer
  support tickets" are not measurable without baselines and targets.
  → Add: "Increase enterprise deal close rate from X% to Y%" and
  "Reduce permission-related tickets from N/week to M/week"

### Major (Fix Soon)
- [ ] **Scope:** No out-of-scope section. What about:
  - Attribute-based access control (ABAC)?
  - SSO/SAML integration?
  - Permission inheritance?
  - External identity providers?
  → Add explicit out-of-scope with rationale

- [ ] **Dependencies:** No dependencies listed. This likely requires:
  - Authentication service changes
  - Database schema changes
  - Frontend permission checking
  → Identify and document dependencies

- [ ] **User Stories:** "Manage roles" is epic-sized. Should be split:
  - Create role with permissions
  - View role details
  - Edit role permissions
  - Delete role (with user reassignment)

### Minor (Nice to Have)
- [ ] Add user personas (IT Admin vs. Team Lead vs. Security Officer)
- [ ] Include mockups or wireframes for role management UI
- [ ] Add timeline and milestones

---

## Section Ratings

| Section | Rating | Notes |
|---------|--------|-------|
| Problem Statement | Weak | Solution-focused, no quantification |
| User Stories | Weak | Epic-sized, vague benefits |
| Acceptance Criteria | Weak | Not testable |
| Scope | Missing | No out-of-scope defined |
| Success Metrics | Missing | Not measurable |

---

## Strengths
- Correct intuition that RBAC is needed for enterprise
- Basic user story format attempted
- Audit logging included (often forgotten)

## Risks Identified
1. **Scope creep** - Without clear boundaries, this could expand to
   full identity management platform.

2. **Integration complexity** - Permission checking must be implemented
   across all features, not just new ones.

3. **Migration risk** - How do existing users get migrated to new role
   system? Not addressed.

---

## Questions for Author
1. What specific compliance requirements drive this? (SOC2, HIPAA, etc.)
2. How many enterprise deals are blocked by this gap?
3. What's the minimum viable permission model for v1?
4. How should existing users be migrated?

---

## Recommendation

**Do not approve in current state.**

Required before re-review:
1. Rewrite problem statement with user pain and business impact
2. Add measurable success metrics with baselines
3. Expand acceptance criteria to be testable
4. Split epic-sized stories
5. Add out-of-scope section
6. Identify dependencies

Schedule follow-up review after revisions (suggest 1 week).
```

---

## Example 3: Major Revision Required - Dashboard Redesign

### Original PRD Excerpt

```markdown
# New Dashboard - PRD

## Overview
Users have been asking for a new dashboard. We should build a modern
dashboard with charts, widgets, and customization.

## Requirements
1. New modern UI design
2. Drag-and-drop widgets
3. Custom chart types
4. Real-time data updates
5. Mobile responsive
6. Dark mode
7. Export to PDF
8. Shareable links
9. Scheduled reports
10. AI-powered insights
11. Natural language queries
12. Integration with Slack
13. Custom alerts
14. Historical comparisons
15. Benchmark data

## Timeline
Q2 2024

## Success
Users will like the new dashboard better.
```

### Review

```markdown
# PRD Review: New Dashboard

**Reviewer:** mriley
**Review Date:** 2024-01-15
**PRD Version:** 0.1
**PRD Author:** Product Team

---

## Summary

**Status:** MAJOR REVISION REQUIRED

**Overall Assessment:**
This document describes a solution wishlist, not a product requirements
document. There is no problem statement, no user stories, no acceptance
criteria, and no measurable success criteria. The scope is unbounded
(15+ features) and timeline is unrealistic. Recommend starting over
with user research to identify the actual problem.

---

## Findings by Severity

### Blockers (Must Fix Before Approval)

- [ ] **No Problem Statement:** Document starts with "users have been
  asking for" but doesn't identify what problem they're trying to solve.
  - What task can't users complete today?
  - What decisions can't they make?
  - What's the business impact of the current state?
  → Conduct user research to identify actual pain points

- [ ] **No User Stories:** Requirements list is feature-focused, not
  user-value focused. "Drag-and-drop widgets" - who needs this and why?
  → Convert each requirement to "As a [user], I want [goal], so that [value]"

- [ ] **No Acceptance Criteria:** How do we know when "new modern UI"
  is complete? What defines "real-time"?
  → Add testable criteria for each requirement

- [ ] **Success Metric Untestable:** "Users will like the new dashboard
  better" is not measurable.
  → Define specific metrics: task completion time, feature adoption, NPS

### Critical (Should Fix Before Implementation)

- [ ] **Scope Creep Risk:** 15 features listed with no prioritization.
  This is 6+ months of work labeled as Q2.
  → Prioritize with MoSCoW, define MVP

- [ ] **No Out-of-Scope:** Without boundaries, scope will expand further.
  → Explicitly exclude features for v1

- [ ] **No Dependencies:** Major feature list with no mention of:
  - Data pipeline for real-time updates
  - AI/ML infrastructure for insights
  - Mobile development resources
  → Identify all dependencies

### Major (Fix Soon)

- [ ] **No User Research:** "Users have been asking" - which users?
  How many? What specifically do they need?
  → Link to research or conduct interviews

- [ ] **No Prioritization:** Are AI insights and dark mode equally
  important? Unlikely.
  → Stack rank features by user value and effort

- [ ] **No Timeline Breakdown:** "Q2 2024" for 15 features is not a plan.
  → Break into milestones with specific deliverables

### Minor (Nice to Have)
- Document metadata (author, version, date)
- Stakeholder identification

---

## Section Ratings

| Section | Rating | Notes |
|---------|--------|-------|
| Problem Statement | Missing | No problem identified |
| User Stories | Missing | Feature list only |
| Acceptance Criteria | Missing | No criteria defined |
| Scope | Missing | Unbounded feature list |
| Success Metrics | Missing | "Users will like it" not measurable |

---

## Strengths
- Enthusiasm for improving user experience
- Comprehensive feature brainstorm (though needs focus)

## Risks Identified
1. **Building wrong thing** - Without understanding the problem, we may
   build features nobody uses.

2. **Infinite scope** - 15+ features will keep expanding without bounds.

3. **Technical debt** - "Real-time updates" and "AI insights" require
   significant infrastructure investment.

4. **Resource mismatch** - Q2 timeline for this scope is 3-4x underestimated.

---

## Questions for Author
1. What specific user problem are we solving?
2. Which 3 features would deliver 80% of the value?
3. What does success look like in measurable terms?
4. What's the budget and team allocation for this?
5. Have we validated any of these features with users?

---

## Recommendation

**Do not proceed. Return to discovery phase.**

This PRD needs to be restarted with a problem-first approach:

1. **User Research (2 weeks)**
   - Interview 10+ users about dashboard usage
   - Identify top 3 pain points
   - Validate proposed solutions

2. **Problem Definition (1 week)**
   - Write problem statement with quantified impact
   - Define target users/personas
   - Establish success metrics with baselines

3. **Scoped PRD (1 week)**
   - Focus on solving ONE problem well
   - Write user stories with acceptance criteria
   - Define realistic MVP scope

4. **Re-Review**
   - Submit new PRD for review

Estimated timeline to approvable PRD: 4 weeks
```

---

## Review Quality Checklist

After writing a review, verify:

- [ ] Every finding has a severity level
- [ ] Every finding has a specific recommendation
- [ ] Strengths are acknowledged (not just criticism)
- [ ] Questions are clarifying, not leading
- [ ] Recommendation is actionable
- [ ] Next steps are clear for the author
