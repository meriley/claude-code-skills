---
name: reviewing-design-docs
description: Review RMS/Axon Backend Design Documents for completeness, correctness, and approval readiness. Validates all required sections including Problem Statement, APIs, Data Storage, RMS Questionnaire, Failure Modes, and Launch Plan. Use when reviewing a design doc before or during the design review process.
version: 1.0.0
---

# Design Doc Reviewing

## Purpose

Systematically audit RMS Backend Design Documents against the team's established template and patterns. Surfaces blockers, gaps, and anti-patterns before review approval so engineers don't waste reviewer time on fixable issues.

## When to Use

- Before sharing a doc in [#rms-design-doc-review](https://axon.slack.com/archives/CUM2W7LKH)
- During design review — as a structured reviewer checklist
- After scope changes to verify the doc is still accurate

## When NOT to Use

- Writing a design doc from scratch (use `design-doc-writing`)
- Reviewing technical specs (use `technical-spec-reviewing`)
- Reviewing PRDs (use `prd-reviewing`)

---

## Review Workflow

### Step 1: Read the Full Document

Read the entire doc before flagging issues. Understand the domain, then apply the checklist.

### Step 2: Check Document Header and Approvers

```markdown
Header Checklist:

- [ ] Author name present
- [ ] Document Jira Link is a valid taserintl.atlassian.net URL
- [ ] Approvers table has rows for: Architecture (L10+), Team EM, PM, Team Engineer
- [ ] Dependent squad engineers added for each impacted service
- [ ] Changes table present (even if empty)
```

**BLOCKER:** Missing Jira link or Architecture approver row.

### Step 3: Problem Summary and Background

```markdown
Problem Statement Checklist:

- [ ] Describes current state and what fails or is missing
- [ ] Explains why a prior approach (if any) no longer works
- [ ] Does NOT jump straight to the solution
- [ ] Sufficient context for a new team member to understand the problem
```

**Anti-pattern:** Opening with "We will build X" instead of describing the problem.

### Step 4: Requirements

```markdown
Requirements Checklist:

- [ ] Requirements are sourced from PM/product spec (or confirmed with PM/EM)
- [ ] "Not in Scope" section lists specific exclusions (not categories)
- [ ] No requirements that are actually implementation details
```

**Anti-pattern:** "Not in Scope: Performance optimizations" (too vague — must name the specific optimization).

### Step 5: Architecture / System Overview

```markdown
Architecture Checklist:

- [ ] All dependent services listed with reason for dependency
- [ ] New services/infrastructure described with purpose
- [ ] Architecture diagram present (all services, new infra, data flows)
- [ ] Diagram is not just a box labeled with the service name
```

### Step 6: APIs

```markdown
API Checklist:

- [ ] Every new or changed API is documented
- [ ] gRPC APIs in proto3 format
- [ ] REST APIs in OpenAPI format
- [ ] GraphQL in typedef format
- [ ] Kafka consumer messages in proto3 wrapped in CloudEvent
- [ ] All batch/list APIs have pagination (page_size + page_token or equivalent)
- [ ] No unbounded list operations
```

**BLOCKER:** Missing pagination on any list/batch API.

### Step 7: Data Storage

```markdown
Data Storage Checklist:

- [ ] Justification for storage choice (relational vs document vs blob vs graph)
- [ ] Read/write patterns and load described
- [ ] All new/updated tables have DML/SQL (with indexes)
- [ ] Indexes explained (why each exists)
- [ ] For ZekeDB: Node/Edge diagram, submodule, branching, new etypes/atypes
- [ ] For ZekeDB: Post-finalize modification strategy described (if data can change)
```

**BLOCKER:** ZekeDB changes without Node/Edge diagram.

### Step 8: Low Level Design and Failure Modes

```markdown
Low Level Design Checklist:

- [ ] Call flow described for each key operation
- [ ] Error scenarios and edge cases addressed
- [ ] No code snippets (pseudo-code ok for complex algorithms)

Failure Modes Checklist:

- [ ] Database unavailable scenario covered
- [ ] Dependent service down scenario covered
- [ ] Concurrency / race condition scenarios covered
- [ ] For Kafka consumers: DLQ strategy, retry policy, idempotency, cron recovery
- [ ] Failure modes table present with Impact + Mitigation columns
```

### Step 9: RMS Specific Questionnaire

```markdown
Questionnaire Checklist (ALL 13 rows):

- [ ] Audit
- [ ] Sealing and Expungements
- [ ] Internationalization
- [ ] Mobile Support
- [ ] Integrations and Conversions
- [ ] Security (CJI data handling)
- [ ] Public APIs
- [ ] Search
- [ ] Metrics
- [ ] Authorization/Privileges
- [ ] Breaking Changes
- [ ] Automated Tests
- [ ] Multi Jurisdictional Data Sharing

Rules:

- [ ] Every row is Yes / No / N/A — no "Not Answered" remaining
- [ ] Every row has a justification/response
- [ ] Rows marked Yes have the Required Reviewer filled in
```

**BLOCKER:** Any row still showing "Not Answered".

### Step 10: Test Plan

```markdown
Test Plan Checklist:

- [ ] Unit test scenarios listed per component
- [ ] Integration test scenarios listed
- [ ] E2E / Manual test scenarios with steps and expected outcomes
- [ ] Complex flows have specific test scenarios (not just "test the feature")
```

### Step 11: Launch Plan

```markdown
Launch Plan Checklist:

- [ ] AG1 phase documented (feature flag name, validation steps, rollback)
- [ ] US2 phase documented (feature flag name, validation steps, rollback)
- [ ] Production phase documented (gradual rollout %, monitoring, rollback)
- [ ] Rollback steps are specific (not just "disable feature flag" if data was written)
- [ ] Success criteria includes: Operational + Functional + Performance targets
- [ ] Performance targets are quantitative (e.g. "P99 < 200ms") not vague ("fast")
```

**BLOCKER:** No rollback procedure for any phase.

### Step 12: Generate Review Report

Use the output template below.

---

## Severity Levels

| Level        | Definition                              | Action                            |
| ------------ | --------------------------------------- | --------------------------------- |
| **BLOCKER**  | Cannot proceed to implementation safely | Must fix before approval          |
| **CRITICAL** | Will cause major issues or rework       | Should fix before approval        |
| **MAJOR**    | Weakens the design significantly        | Should fix before implementation  |
| **MINOR**    | Gaps or polish items                    | Can address during implementation |

### Common Blockers

- Missing Jira link in header
- Architecture (L10+) approver row absent from table
- Any "Not Answered" in RMS Questionnaire
- List/batch API without pagination
- ZekeDB changes without Node/Edge diagram
- No rollback steps in Launch Plan

---

## Review Output Template

```markdown
# Design Doc Review: [Feature Name]

**Reviewer:** [Name]
**Review Date:** [Date]
**Doc Link:** [Quip/Confluence URL]

---

## Status

**Decision:** [APPROVE / APPROVE WITH CHANGES / NEEDS REVISION / MAJOR REVISION REQUIRED]

**Assessment:**
[2-3 sentences on overall quality and readiness for implementation]

---

## Blockers (Must Fix Before Approval)

- [ ] [Issue] — [Section] — [Recommendation]

## Critical (Should Fix Before Approval)

- [ ] [Issue] — [Section] — [Recommendation]

## Major (Should Fix Before Implementation)

- [ ] [Issue] — [Section] — [Recommendation]

## Minor (Polish / Nice to Have)

- [ ] [Issue] — [Section] — [Recommendation]

---

## Section Ratings

| Section           | Rating                               | Notes |
| ----------------- | ------------------------------------ | ----- |
| Problem Summary   | [Strong / Adequate / Weak / Missing] |       |
| Requirements      | [Strong / Adequate / Weak / Missing] |       |
| Architecture      | [Strong / Adequate / Weak / Missing] |       |
| APIs              | [Strong / Adequate / Weak / Missing] |       |
| Data Storage      | [Strong / Adequate / Weak / Missing] |       |
| Low Level Design  | [Strong / Adequate / Weak / Missing] |       |
| Failure Modes     | [Strong / Adequate / Weak / Missing] |       |
| RMS Questionnaire | [Strong / Adequate / Weak / Missing] |       |
| Test Plan         | [Strong / Adequate / Weak / Missing] |       |
| Launch Plan       | [Strong / Adequate / Weak / Missing] |       |

---

## Strengths

- [What the doc does well]

## Open Questions

1. [Question for author]

---

## Recommendation

[Specific next steps before re-review or approval]
```

---

## Reference Files

**Detailed per-section checks with anti-pattern examples:**

```
Read `~/.claude/skills/reviewing-design-docs/references/SECTION-CHECKLIST.md`
```

Use when: Reviewing a specific section in depth or need anti-pattern examples with corrections.

**RMS Questionnaire row-by-row guidance and common approval scenarios:**

```
Read `~/.claude/skills/reviewing-design-docs/references/REVIEW-PATTERNS.md`
```

Use when: Evaluating RMS Questionnaire responses, assessing failure modes, or validating launch plan rollback steps.

---

## Related Skills

- **`design-doc-writing`** — Writing RMS backend design docs
- **`technical-spec-reviewing`** — Reviewing technical specifications
- **`prd-reviewing`** — Reviewing product requirements
