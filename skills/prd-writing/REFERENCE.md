# PRD Writing Reference

Detailed guidance for writing effective Product Requirements Documents.

---

## Table of Contents

1. [Problem Statement Deep Dive](#1-problem-statement-deep-dive)
2. [User Story Mastery](#2-user-story-mastery)
3. [Acceptance Criteria Patterns](#3-acceptance-criteria-patterns)
4. [Scope Management](#4-scope-management)
5. [Metrics That Matter](#5-metrics-that-matter)
6. [Anti-Patterns in Detail](#6-anti-patterns-in-detail)
7. [Stakeholder Management](#7-stakeholder-management)
8. [PRD Evolution](#8-prd-evolution)

---

## 1. Problem Statement Deep Dive

### The 5 Whys Technique

Dig past surface-level problems to find root causes:

```
Problem: Users are abandoning checkout

Why? → They're surprised by shipping costs
Why? → Shipping costs aren't shown until checkout
Why? → The system calculates shipping after address entry
Why? → Original design assumed all users knew shipping costs
Why? → We never did user research on checkout flow

Root Problem: Users lack cost transparency before commitment
```

### Problem Statement Formula

```
[USER SEGMENT] experiences [PAIN POINT] when [CONTEXT],
resulting in [MEASURABLE IMPACT].
```

**Examples:**

```
✅ Good:
"Enterprise customers experience compliance anxiety when sharing
sensitive data, resulting in 40% of deals stalling at security review."

✅ Good:
"Mobile shoppers abandon carts 3x more than desktop users because
product images load slowly on cellular connections."

❌ Bad:
"We need a better dashboard." (Solution, not problem)

❌ Bad:
"Users don't like the current flow." (Vague, not measurable)
```

### Problem Validation Checklist

Before writing the PRD, validate the problem:

- [ ] Have we talked to 5+ affected users?
- [ ] Can we quantify the impact (revenue, time, satisfaction)?
- [ ] Is this problem getting worse, stable, or improving?
- [ ] What happens if we don't solve it?
- [ ] Who else has this problem? (Market size)

---

## 2. User Story Mastery

### INVEST Criteria Explained

| Criterion | Meaning | Test |
|-----------|---------|------|
| **I**ndependent | Can be delivered alone | No "must do X before Y" |
| **N**egotiable | Details can change | Not a technical spec |
| **V**aluable | Delivers user value | Answers "so what?" |
| **E**stimable | Team can size it | Clear enough to estimate |
| **S**mall | Fits in a sprint | Can split if too big |
| **T**estable | Has clear criteria | QA can verify |

### Story Splitting Patterns

When a story is too large, split it:

**By User Type:**
```
Original: As a user, I want to manage my account

Split:
- As a new user, I want to create my account
- As an existing user, I want to update my profile
- As an admin, I want to manage user accounts
```

**By Workflow Step:**
```
Original: As a user, I want to complete checkout

Split:
- As a shopper, I want to enter shipping address
- As a shopper, I want to select shipping method
- As a shopper, I want to enter payment details
- As a shopper, I want to review and confirm order
```

**By Data Variation:**
```
Original: As a user, I want to search for products

Split:
- As a user, I want to search by keyword
- As a user, I want to filter by category
- As a user, I want to filter by price range
- As a user, I want to sort results
```

**By Operation (CRUD):**
```
Original: As an admin, I want to manage roles

Split:
- As an admin, I want to create a new role
- As an admin, I want to view role details
- As an admin, I want to edit role permissions
- As an admin, I want to delete unused roles
```

### Story Sizing Guide

| Size | Description | Example |
|------|-------------|---------|
| **XS** | Simple change, clear path | Change button color |
| **S** | Single component, known pattern | Add form field with validation |
| **M** | Multiple components, some unknowns | New page with API integration |
| **L** | Cross-system, significant complexity | New feature with 3rd party API |
| **XL** | Should probably be split | Complete subsystem |

---

## 3. Acceptance Criteria Patterns

### Given-When-Then Best Practices

**Structure:**
```gherkin
Given [precondition/context]
And [additional context]
When [user action/system event]
Then [expected outcome]
And [additional expected outcome]
But [negative case if applicable]
```

**Example - Complete Scenario Set:**

```gherkin
Feature: Shipping Cost Calculator

Scenario: Successful shipping calculation
  Given I am on a product page
  And I am logged in with a saved address
  When I click "Calculate Shipping"
  Then I see shipping options within 2 seconds
  And each option shows carrier, price, and delivery date
  And the cheapest option is highlighted

Scenario: New user without saved address
  Given I am on a product page
  And I am not logged in
  When I click "Calculate Shipping"
  Then I see a zip code input field
  When I enter a valid zip code
  Then I see shipping options within 2 seconds

Scenario: Invalid address
  Given I am on a product page
  When I enter an invalid zip code "00000"
  Then I see an error message "Please enter a valid zip code"
  And the calculate button remains disabled

Scenario: Carrier API unavailable
  Given I am on a product page
  And the shipping API is unavailable
  When I click "Calculate Shipping"
  Then I see a message "Shipping will be calculated at checkout"
  And I can still add to cart
```

### Criteria Categories

Cover these categories for completeness:

| Category | Questions to Answer |
|----------|---------------------|
| **Happy Path** | What happens when everything works? |
| **Validation** | What inputs are valid/invalid? |
| **Error Handling** | What happens when things fail? |
| **Edge Cases** | What about unusual situations? |
| **Performance** | How fast should it be? |
| **Security** | Who can do this? What's logged? |
| **Accessibility** | Can all users access this? |

### Testability Checklist

For each criterion, verify:

- [ ] Contains a specific, measurable outcome
- [ ] Uses concrete values (not "quickly" but "< 2 seconds")
- [ ] Can be verified by QA without ambiguity
- [ ] Doesn't require reading minds ("user is happy")

---

## 4. Scope Management

### MoSCoW Prioritization

| Priority | Meaning | Implication |
|----------|---------|-------------|
| **Must Have** | Critical for launch | No launch without this |
| **Should Have** | Important but not blocking | Can launch without, add soon |
| **Could Have** | Nice to have | If time permits |
| **Won't Have** | Explicitly excluded | Not this release |

### Scope Creep Prevention

**Document "Why Not" for each exclusion:**

```markdown
## Out of Scope

| Item | Why Not Now | Future Consideration |
|------|-------------|---------------------|
| International shipping | Carrier contracts not ready, 5% of users | Q3 |
| Multiple packages | Complex edge case, low frequency | Backlog |
| Shipping insurance | Low demand in research | Evaluate in 6 months |
| Gift wrapping | Different feature, own PRD | Separate initiative |
```

**Use explicit decision log:**

```markdown
## Decisions Made

| Decision | Date | Rationale | Decider |
|----------|------|-----------|---------|
| Start with 3 carriers only | 2024-01-15 | Covers 95% of shipments | PM |
| No international v1 | 2024-01-15 | Contract negotiations ongoing | Legal |
| Cache rates for 1 hour | 2024-01-18 | Balance freshness vs. API costs | Eng |
```

---

## 5. Metrics That Matter

### Metrics Hierarchy

```
Business Metrics (Lagging)
    ↑ influenced by
User Behavior Metrics (Leading)
    ↑ influenced by
Product Metrics (Immediate)
```

**Example:**
```
Revenue (lagging)
    ↑
Conversion Rate (leading)
    ↑
Shipping Calculator Usage (immediate)
```

### Good vs. Bad Metrics

| Bad (Vanity) | Good (Actionable) |
|--------------|-------------------|
| Page views | Conversion rate |
| Total users | Active users (DAU/MAU) |
| Features shipped | Feature adoption rate |
| App downloads | Retention after 30 days |
| Support ticket count | Time to resolution |

### Metric Definition Template

For each key metric:

```markdown
### [Metric Name]

**Definition:** [Exactly what we're measuring]

**Calculation:** [Formula or method]

**Current Baseline:** [Today's value with date]

**Target:** [Goal value with timeline]

**Measurement Tool:** [Analytics platform, query, etc.]

**Update Frequency:** [Real-time / Daily / Weekly]

**Owner:** [Who monitors this]
```

---

## 6. Anti-Patterns in Detail

### Anti-Pattern 1: Solution in Disguise

**The Problem:**
PRD describes what to build instead of why.

**Before:**
```
We need to add a shipping calculator widget to the product page
that shows real-time rates from UPS, FedEx, and USPS.
```

**After:**
```
Problem: Users abandon checkout at 23% rate when they see
unexpected shipping costs. Research shows 67% want shipping
transparency before committing to checkout.

Solution: Display shipping cost estimates earlier in the
shopping journey.
```

### Anti-Pattern 2: Kitchen Sink Scope

**The Problem:**
PRD tries to solve everything at once.

**Before:**
```
This feature will include:
- Shipping calculator
- Package tracking
- Delivery notifications
- Returns management
- International shipping
- Shipping insurance
- Gift wrap options
```

**After:**
```
This PRD focuses on shipping cost transparency (calculator).
Related features are tracked separately:
- Package tracking (PRD-234)
- Returns management (PRD-456)
- International shipping (Blocked - pending contracts)
```

### Anti-Pattern 3: Vague Success Criteria

**The Problem:**
No way to know if we succeeded.

**Before:**
```
Success: Users will be happier with shipping.
```

**After:**
```
Success Metrics:
| Metric | Current | Target |
|--------|---------|--------|
| Cart abandonment (shipping step) | 23% | 18% |
| CSAT score (post-purchase) | 3.2 | 4.0 |
| Support tickets (shipping questions) | 200/week | 100/week |
```

### Anti-Pattern 4: Missing Edge Cases

**The Problem:**
Only happy path is documented.

**Before:**
```
Acceptance Criteria:
- User sees shipping cost
```

**After:**
```
Acceptance Criteria:
- User sees shipping options within 2 seconds
- User sees error message for invalid address
- User sees fallback message if API unavailable
- User sees "Free shipping" badge above threshold
- User sees international shipping message for non-US
```

### Anti-Pattern 5: Assumed Context

**The Problem:**
PRD assumes reader knows background.

**Before:**
```
This feature addresses the Q2 feedback.
```

**After:**
```
This feature addresses feedback from Q2 user research where
78% of surveyed users (n=156) reported frustration with
shipping cost surprises. Full research report: [link]
```

---

## 7. Stakeholder Management

### Stakeholder Identification

For each PRD, identify:

| Role | Responsibility | Sign-off Authority |
|------|---------------|-------------------|
| **Sponsor** | Business justification, priority | Final approval |
| **Product** | Requirements, scope | Feature scope |
| **Engineering** | Feasibility, timeline | Technical approach |
| **Design** | User experience | UX decisions |
| **QA** | Test strategy | Quality criteria |
| **Legal/Compliance** | Regulatory requirements | Compliance |
| **Support** | Training, documentation | Rollout readiness |

### Review Cadence

```
Draft → Product Review → Eng Review → Cross-functional → Approval
  ↓         ↓              ↓              ↓
Day 1    Day 2-3        Day 4-5        Day 6-7
```

### Feedback Incorporation

Track all feedback with resolution:

| Feedback | From | Resolution | Status |
|----------|------|------------|--------|
| "Add carrier preference" | User Research | Added as Should Have | Done |
| "Consider caching rates" | Engineering | Added to Open Questions | Pending |
| "GDPR for address storage" | Legal | Added to Dependencies | Done |

---

## 8. PRD Evolution

### Version Control

| Version | Status | Purpose |
|---------|--------|---------|
| 0.1 | Draft | Initial ideas, internal feedback |
| 0.5 | Draft | Reviewed by product team |
| 1.0 | In Review | Ready for stakeholder review |
| 1.5 | Approved | Signed off, ready for implementation |
| 2.0 | Updated | Changes during implementation |

### Living Document Guidelines

**Do Update:**
- Open questions when resolved
- Scope changes (with approval note)
- Metric baselines with new data
- Timeline changes with reasons

**Don't Update:**
- Original problem statement (if it changes, new PRD)
- Success criteria after launch (creates moving target)
- Historical decisions (preserve for context)

### Post-Launch Review

After launch, update PRD with:

```markdown
## Post-Launch Results

**Launch Date:** [Date]

**Actual vs. Target:**
| Metric | Target | Actual | Notes |
|--------|--------|--------|-------|
| Cart abandonment | 18% | 19.2% | Close, continuing to monitor |
| Calculator usage | 50% | 62% | Exceeded expectations |

**Lessons Learned:**
1. [What worked well]
2. [What we'd do differently]
3. [Unexpected findings]

**Follow-up Actions:**
- [ ] [Action item 1]
- [ ] [Action item 2]
```

---

## Quick Reference Card

### Problem Statement
```
[WHO] experiences [WHAT] when [WHEN], resulting in [IMPACT].
```

### User Story
```
As a [USER], I want [GOAL], so that [VALUE].
```

### Acceptance Criteria
```gherkin
Given [CONTEXT]
When [ACTION]
Then [OUTCOME]
```

### Scope
```
In Scope: [What we will do]
Out of Scope: [What we won't do + why]
```

### Metrics
```
| Metric | Current | Target | How Measured |
```
