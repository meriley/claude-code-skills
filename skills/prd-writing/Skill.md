---
name: prd-writing
description: Creates lean Product Requirements Documents from scratch or refines rough product ideas into actionable PRDs. Follows Agile methodology with user stories, acceptance criteria, and scope boundaries. Use when starting new features, documenting product ideas, or formalizing requirements.
version: 1.0.0
---

# PRD Writing

## Purpose

Creates lightweight, actionable Product Requirements Documents that bridge product and engineering, focusing on user value rather than implementation details.

## When to Use This Skill

- Starting a new feature or product initiative
- Formalizing a rough product idea into requirements
- Documenting user needs before implementation planning
- Creating shared understanding between product and engineering
- User requests: "write a PRD", "document requirements for X", "create spec for feature Y"

## When NOT to Use This Skill

- Technical implementation planning (use `sparc-planning` instead)
- API documentation (use `api-doc-writer` instead)
- Bug fixes or minor enhancements (no PRD needed)
- Already have detailed PRD, need review (use `prd-reviewing` instead)
- Single feature detail with edge cases (use `feature-spec-writing` instead)

## Workflow

### Step 1: Context Gathering

Invoke `check-history` to understand project context, then ask clarifying questions:

```markdown
Questions to ask:
1. What problem are we solving? (Focus on user pain, not solution)
2. Who experiences this problem? (Target users/personas)
3. What's the business impact? (Revenue, retention, efficiency)
4. What constraints exist? (Timeline, technology, resources)
5. What's already been tried? (Previous solutions, why they failed)
```

### Step 2: Problem Definition

Define the user problem clearly. Focus on the problem, not the solution.

**Good problem statement:**
```
Users abandon checkout when shipping costs are unclear,
resulting in 23% cart abandonment rate.
```

**Bad problem statement:**
```
We need to add a shipping calculator widget.
(This is a solution, not a problem)
```

### Step 3: User Stories Creation

Write user stories following the standard format and INVEST criteria:

```markdown
**Format:**
As a [user type], I want [goal], so that [benefit]

**INVEST Criteria:**
- Independent: Can be delivered separately
- Negotiable: Details can be discussed
- Valuable: Delivers user value
- Estimable: Can be sized by engineering
- Small: Fits in a sprint (or can be split)
- Testable: Has clear acceptance criteria
```

**Example:**
```markdown
As a **shopper**,
I want **to see shipping costs before checkout**,
so that **I can make an informed purchase decision**.
```

### Step 4: Acceptance Criteria Definition

Define "done" for each user story using Given/When/Then format:

```gherkin
Given I am on the product page
And I have entered my shipping address
When I click "Calculate Shipping"
Then I see the shipping cost within 2 seconds
And I see the estimated delivery date
And I can proceed to checkout with the selected option
```

**Include edge cases:**
- What happens if address is invalid?
- What if shipping is unavailable to that location?
- What about free shipping thresholds?

### Step 5: Scope Definition

Explicitly define scope boundaries:

```markdown
## In Scope
- Real-time shipping cost calculation on product page
- Integration with 3 carriers (UPS, FedEx, USPS)
- Address validation before calculation

## Out of Scope (v1)
- International shipping (future consideration)
- Shipping insurance options (nice to have)
- Multiple package calculations (complexity)

## Dependencies
- Carrier API integrations (external)
- Address validation service (internal)
- Cart service updates (internal)

## Assumptions
- Carriers provide real-time API access
- 95% of orders are domestic
- Users have valid US addresses

## Open Questions
- [ ] Should we cache shipping rates? For how long?
- [ ] What's the fallback if carrier API is down?
```

### Step 6: Success Metrics

Define measurable success criteria with leading and lagging indicators:

```markdown
## Key Results

| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| Cart abandonment | 23% | 18% | Analytics |
| Shipping page views | 0 | 50K/month | Analytics |
| Support tickets (shipping) | 200/week | 100/week | Zendesk |

## Leading Indicators (measure early)
- Shipping calculator usage rate
- Address validation success rate
- Time to calculate shipping

## Guardrails (don't break these)
- Page load time < 3s
- Checkout conversion rate >= current
- Error rate < 1%
```

### Step 7: Output Generation

Generate the PRD using the template in TEMPLATE.md. Ensure:

- [ ] Problem is clearly defined (user-focused, not solution-focused)
- [ ] User stories follow format and INVEST criteria
- [ ] Acceptance criteria are testable and unambiguous
- [ ] Scope has explicit in/out boundaries
- [ ] Success metrics are measurable
- [ ] Open questions are documented
- [ ] Stakeholders are identified

## Examples

### Example 1: E-Commerce - Shipping Calculator

**Input:** "Users are abandoning checkout because they don't know shipping costs"

**Problem Statement:**
```
Users abandon checkout when shipping costs are unclear, resulting in
23% cart abandonment at the shipping step. User research shows 67%
want to see costs before reaching checkout.
```

**User Stories:**
```
US-1: As a shopper, I want to see shipping costs on the product page,
      so that I know total cost before adding to cart.

US-2: As a shopper, I want to compare shipping options,
      so that I can choose between speed and cost.

US-3: As a shopper, I want to save my shipping preference,
      so that I don't have to select it every time.
```

**Acceptance Criteria (US-1):**
```gherkin
Given I am on a product page
And I enter my zip code
When I click "Calculate Shipping"
Then I see shipping options within 2 seconds
And each option shows carrier, price, and delivery estimate
```

---

### Example 2: SaaS - Team Permissions

**Input:** "Admins need to control what team members can access"

**Problem Statement:**
```
Organizations cannot control access granularly, forcing all-or-nothing
permissions. This blocks enterprise sales where security compliance
requires role-based access. 15 deals ($2.4M) blocked by this gap.
```

**User Stories:**
```
US-1: As an admin, I want to create custom roles,
      so that I can match our organization's structure.

US-2: As an admin, I want to assign users to roles,
      so that they have appropriate access.

US-3: As an admin, I want to audit role changes,
      so that I can demonstrate compliance.
```

**Scope:**
```
In Scope:
- Role creation with granular permissions
- User-to-role assignment
- Audit log of permission changes

Out of Scope:
- Attribute-based access control (ABAC)
- External identity provider integration
- Permission inheritance across teams
```

---

### Example 3: Fintech - Transaction Alerts

**Input:** "Users want to know immediately when money moves"

**Problem Statement:**
```
Users discover unauthorized transactions too late, averaging 3 days
to notice fraudulent charges. Real-time alerts could reduce fraud
losses by 40% based on industry benchmarks.
```

**User Stories:**
```
US-1: As a cardholder, I want instant notifications for transactions,
      so that I can spot fraud immediately.

US-2: As a cardholder, I want to set spending thresholds,
      so that I'm only alerted for significant transactions.

US-3: As a cardholder, I want to dispute directly from alerts,
      so that I can act quickly on suspicious activity.
```

**Success Metrics:**
```
| Metric | Current | Target |
|--------|---------|--------|
| Time to fraud detection | 3 days | < 1 hour |
| Fraud loss per incident | $450 | $200 |
| User alert engagement | N/A | 80% open rate |
```

## Anti-Patterns to Avoid

### Solution-First Thinking
```
❌ "We need to build a widget that shows shipping"
✅ "Users abandon checkout when shipping costs are unclear"
```

### Epic-Sized Stories
```
❌ "As a user, I want a complete shipping experience"
✅ "As a user, I want to see shipping costs before checkout"
```

### Vague Acceptance Criteria
```
❌ "Shipping should be fast"
✅ "Shipping calculation completes within 2 seconds (p95)"
```

### Missing Scope Boundaries
```
❌ [No out-of-scope section]
✅ "Out of Scope: International shipping, insurance options"
```

### Vanity Metrics
```
❌ "Increase page views"
✅ "Reduce cart abandonment from 23% to 18%"
```

## Integration with Other Skills

**Invokes:**
- `check-history` - Gather project context before writing

**Works With:**
- `prd-reviewing` - Review and validate completed PRDs
- `feature-spec-writing` - Break PRD into detailed feature specs

**Followed By:**
- `sparc-planning` - Create technical implementation plan
- `technical-spec-writing` - Design system architecture

## Output Validation

Before finalizing the PRD:

- [ ] Problem statement focuses on user pain, not solution
- [ ] All user stories follow As a/I want/So that format
- [ ] Each story has testable acceptance criteria
- [ ] Scope explicitly states what's in AND out
- [ ] Success metrics are measurable with current/target
- [ ] Open questions are documented
- [ ] Stakeholders identified for approval

## Resources

- See TEMPLATE.md for the complete PRD output format
- See REFERENCE.md for detailed guidance and examples
