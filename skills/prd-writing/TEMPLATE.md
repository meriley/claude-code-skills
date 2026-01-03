# PRD Template

Copy and fill in this template when creating a new PRD.

---

````markdown
# [Feature Name] - Product Requirements Document

## Document Info

| Field              | Value                                                   |
| ------------------ | ------------------------------------------------------- |
| **Author**         | [Name]                                                  |
| **Date**           | [YYYY-MM-DD]                                            |
| **Version**        | [1.0]                                                   |
| **Status**         | [Draft / In Review / Approved / In Progress / Complete] |
| **Stakeholders**   | [Product, Engineering, Design, etc.]                    |
| **Target Release** | [Quarter/Sprint]                                        |

---

## Executive Summary

[2-3 sentences describing what we're building and why. Should be understandable by anyone in the organization.]

---

## Problem Statement

### The Problem

[Clear description of the user problem we're solving. Focus on the pain point, not the solution.]

**Key insight:** [One sentence capturing the core insight]

### Who is Affected

| Persona          | Description         | Impact                 |
| ---------------- | ------------------- | ---------------------- |
| [Primary User]   | [Brief description] | [How they're affected] |
| [Secondary User] | [Brief description] | [How they're affected] |

### Current State

[How do users currently handle this? What workarounds exist?]

### Impact of Not Solving

| Impact Type      | Description                | Quantification                    |
| ---------------- | -------------------------- | --------------------------------- |
| User Impact      | [Pain description]         | [X users affected, Y% frustrated] |
| Business Impact  | [Revenue/cost description] | [$X lost, Y% churn]               |
| Technical Impact | [Debt/risk description]    | [If applicable]                   |

---

## Proposed Solution

### Overview

[High-level description of the solution in 2-3 sentences. What are we building?]

### User Stories

#### US-1: [Primary Story Title]

**As a** [user type]
**I want** [goal/desire]
**So that** [benefit/value]

**Acceptance Criteria:**

```gherkin
Scenario: [Happy path name]
  Given [context/precondition]
  And [additional context if needed]
  When [action/trigger]
  Then [expected outcome]
  And [additional outcome if needed]

Scenario: [Edge case name]
  Given [context]
  When [action]
  Then [outcome]
```
````

**Priority:** [Must Have / Should Have / Nice to Have]
**Estimated Size:** [S / M / L / XL]

---

#### US-2: [Secondary Story Title]

**As a** [user type]
**I want** [goal/desire]
**So that** [benefit/value]

**Acceptance Criteria:**

```gherkin
Scenario: [Scenario name]
  Given [context]
  When [action]
  Then [outcome]
```

**Priority:** [Must Have / Should Have / Nice to Have]
**Estimated Size:** [S / M / L / XL]

---

#### US-3: [Additional Story Title]

[Repeat format as needed...]

---

### User Journey

[Optional: Visual flow of user experience]

```
[Entry Point] → [Step 1] → [Step 2] → [Outcome]
                    ↓
               [Alt Path] → [Recovery]
```

---

## Scope

### In Scope

| Item                   | Description         | Priority     |
| ---------------------- | ------------------- | ------------ |
| [Feature/capability 1] | [Brief description] | Must Have    |
| [Feature/capability 2] | [Brief description] | Should Have  |
| [Feature/capability 3] | [Brief description] | Nice to Have |

### Out of Scope

| Item              | Reason        | Future Consideration |
| ----------------- | ------------- | -------------------- |
| [Excluded item 1] | [Why not now] | [Yes/No - when]      |
| [Excluded item 2] | [Why not now] | [Yes/No - when]      |

### Dependencies

| Dependency         | Owner         | Status                      | Risk              |
| ------------------ | ------------- | --------------------------- | ----------------- |
| [External API]     | [Team/Vendor] | [Ready/In Progress/Blocked] | [Low/Medium/High] |
| [Internal Service] | [Team]        | [Ready/In Progress/Blocked] | [Low/Medium/High] |

### Assumptions

- [Assumption 1 - what we believe to be true]
- [Assumption 2 - what we believe to be true]
- [Assumption 3 - what we believe to be true]

### Open Questions

- [ ] [Question 1 requiring decision] - Owner: [Name]
- [ ] [Question 2 requiring research] - Owner: [Name]
- [ ] [Question 3 requiring stakeholder input] - Owner: [Name]

---

## Success Metrics

### Key Results

| Metric             | Current State | Target | Timeline | Measurement Method |
| ------------------ | ------------- | ------ | -------- | ------------------ |
| [Primary Metric]   | [Baseline]    | [Goal] | [When]   | [How measured]     |
| [Secondary Metric] | [Baseline]    | [Goal] | [When]   | [How measured]     |
| [Tertiary Metric]  | [Baseline]    | [Goal] | [When]   | [How measured]     |

### Leading Indicators (Early Signals)

| Indicator     | Target   | Why It Matters           |
| ------------- | -------- | ------------------------ |
| [Indicator 1] | [Target] | [Correlation to success] |
| [Indicator 2] | [Target] | [Correlation to success] |

### Guardrails (Don't Break These)

| Guardrail  | Threshold   | Action if Breached    |
| ---------- | ----------- | --------------------- |
| [Metric 1] | [Threshold] | [Rollback/Alert/etc.] |
| [Metric 2] | [Threshold] | [Rollback/Alert/etc.] |

---

## Timeline & Milestones

| Milestone         | Target Date | Description            | Success Criteria         |
| ----------------- | ----------- | ---------------------- | ------------------------ |
| PRD Approved      | [Date]      | Requirements finalized | Stakeholder sign-off     |
| Design Complete   | [Date]      | UX/UI designs approved | Design review passed     |
| Development Start | [Date]      | Engineering begins     | Tickets created          |
| Alpha/Internal    | [Date]      | Internal testing ready | Core functionality works |
| Beta/Limited      | [Date]      | Limited user rollout   | No P0 bugs               |
| GA/Full Release   | [Date]      | Full availability      | All stories complete     |

---

## Risks & Mitigations

| Risk     | Likelihood | Impact  | Mitigation                 | Owner  |
| -------- | ---------- | ------- | -------------------------- | ------ |
| [Risk 1] | [H/M/L]    | [H/M/L] | [How we'll prevent/handle] | [Name] |
| [Risk 2] | [H/M/L]    | [H/M/L] | [How we'll prevent/handle] | [Name] |

---

## Appendix

### Mockups / Wireframes

[Links to design files or embedded images]

### Research / Data

| Source                 | Summary        | Link   |
| ---------------------- | -------------- | ------ |
| [User Research]        | [Key findings] | [Link] |
| [Analytics Data]       | [Key metrics]  | [Link] |
| [Competitive Analysis] | [Key insights] | [Link] |

### Related Documents

| Document       | Description          | Link   |
| -------------- | -------------------- | ------ |
| Technical Spec | System design        | [Link] |
| Design Doc     | UX/UI specifications | [Link] |
| Previous PRD   | Earlier iteration    | [Link] |

---

## Approval

| Role        | Name   | Status                     | Date   |
| ----------- | ------ | -------------------------- | ------ |
| Product     | [Name] | [ ] Pending / [x] Approved | [Date] |
| Engineering | [Name] | [ ] Pending / [x] Approved | [Date] |
| Design      | [Name] | [ ] Pending / [x] Approved | [Date] |
| [Other]     | [Name] | [ ] Pending / [x] Approved | [Date] |

---

## Implementation Plan

> **Note:** This section is added by the `prd-implementation-planning` skill after PRD approval.

### Skill Requirements

| Domain   | Skills Required | Purpose              |
| -------- | --------------- | -------------------- |
| [Domain] | `[skill-name]`  | [What it's used for] |

### Implementation Tasks

| #   | Task               | User Story | Skill          | Priority | Dependencies | Est. |
| --- | ------------------ | ---------- | -------------- | -------- | ------------ | ---- |
| 1   | [Task description] | US-1       | `[skill-name]` | P0       | None         | M    |
| 2   | [Task description] | US-1       | `[skill-name]` | P0       | 1            | L    |

### Implementation Notes

- [Prerequisites, blockers, or special considerations]

---

## Implementation Progress

| #   | Task               | Status  | Started | Completed | Commit |
| --- | ------------------ | ------- | ------- | --------- | ------ |
| 1   | [Task description] | Pending | -       | -         | -      |
| 2   | [Task description] | Pending | -       | -         | -      |

### Progress Summary

- **Total Tasks:** N
- **Completed:** 0 (0%)
- **In Progress:** 0
- **Blocked:** 0
- **Pending:** N
- **Last Updated:** YYYY-MM-DD

---

## Document History

| Version | Date   | Author | Changes        |
| ------- | ------ | ------ | -------------- |
| 1.0     | [Date] | [Name] | Initial draft  |
| 1.1     | [Date] | [Name] | [Changes made] |

```

---

## Template Usage Notes

### Required Sections
- Document Info
- Problem Statement
- User Stories with Acceptance Criteria
- Scope (In/Out)
- Success Metrics

### Optional Sections (based on complexity)
- User Journey (for complex flows)
- Mockups (if design is ready)
- Appendix (supporting data)

### Filling Tips

1. **Problem Statement**: Resist the urge to describe the solution. Focus only on the user pain.

2. **User Stories**: Start with 3-5 stories. More can be added as feature specs.

3. **Acceptance Criteria**: Write as if you're telling QA exactly what to test.

4. **Out of Scope**: Be explicit. Unclear boundaries lead to scope creep.

5. **Metrics**: Include current baseline. "Improve conversion" is meaningless without "from X% to Y%".

6. **Open Questions**: Don't hide uncertainty. Surface it for resolution.
```
