---
name: design-doc-writing
description: Write Backend Design Documents following RMS/Axon team patterns. Covers Problem Statement, Requirements, Architecture, APIs (gRPC/REST/GraphQL), Data Storage, Failure Modes, RMS Questionnaire, Launch Plan, and Approvers table. Use when creating or updating a design doc for an RMS backend service or feature.
version: 1.0.0
---

# Design Doc Writing

## Purpose

Guide writing of Backend Design Documents that align with the RMS/Axon team process, from first draft through approval. Produces docs that follow the team's established template and pass design review.

## When to Use

- Creating a net-new design document for a backend service or feature
- Updating an existing design doc after scope changes
- Reviewing a draft doc for completeness before sharing

## When NOT to Use

- Documenting a decision already made without review (use ADR instead)
- Frontend-only feature changes with no backend impact
- Bug fixes with no architectural changes

---

## Workflow

### Step 1: Gather Context

Before writing, collect:

1. **Jira ticket** - Document Jira Link required in header
2. **Problem description** - What is broken, missing, or inefficient?
3. **Impacted services** - Which services are involved or affected?
4. **Scale signals** - Splunk metrics, request rates, or storage estimates
5. **Stakeholder squads** - Who owns the domains this design touches?

### Step 2: Draft Core Sections in Order

Write sections in this order (prevents writers block, each builds on prior):

```
1. Problem Summary and Background
2. Requirements (+ Not in Scope)
3. Glossary
4. Architecture/System Overview
5. Design Details (APIs → Data Storage → Low Level Design)
6. Failure Modes and Recovery
7. Traffic and Cost Estimates
8. RMS Specific Questionnaire
9. Test Plan
10. Launch Plan
11. Approvers (fill in stakeholders last)
```

### Step 3: APIs First in Design Details

Always define APIs before describing implementation logic:

- **gRPC services** → proto3 format (see WRITING-PATTERNS.md)
- **REST** → OpenAPI format
- **GraphQL** → Typedef format
- **Kafka consumers** → proto3 wrapped in CloudEvent

Identify all batch APIs and confirm they have pagination and limits.

### Step 4: Data Storage Decisions

For each data store, document:

- Why this store (relational vs document vs blob vs graph)?
- Read/write patterns and load characteristics
- Schema (DML/SQL for relational tables, including indexes)
- For ZekeDB: Node/Edge diagram, submodule usage, new etypes/atypes

### Step 5: Fill in RMS Questionnaire

Every row requires `Yes` / `No` / `N/A` with justification. Key areas:
Audit, Sealing/Expungements, i18n, Mobile, Integrations, Security, Public APIs, Search, Metrics, Authorization, Breaking Changes, Tests, Multi-Jurisdictional.

See `references/TEMPLATE.md` for the full questionnaire table.

### Step 6: Launch Plan

Structure rollout by environment:

- `AG1` → `US2` → `Prod`
- Feature flags for each phase
- Rollback procedure
- Success criteria (operational + functional + performance)

---

## Key Quality Checks

Before sharing for review:

- [ ] Approvers table populated with correct squads and Jira links
- [ ] "Not in Scope" section is specific about edge cases excluded
- [ ] Every API has pagination/limits identified
- [ ] All `Not Answered` rows in RMS Questionnaire replaced with Yes/No + justification
- [ ] ZekeDB changes have Node/Edge diagram
- [ ] Failure modes cover: DB down, dependent service down, concurrency/race conditions
- [ ] Launch plan includes rollback steps
- [ ] Doc posted to [#rms-design-doc-review](https://axon.slack.com/archives/CUM2W7LKH)

---

## Document Header Pattern

```markdown
# [Feature Name] Design Document

**Author:** [Name]
**Document Jira Link:** https://taserintl.atlassian.net/browse/RMS-XXXXX
```

## Approvers Table Pattern

```markdown
| Squad               | Approver | Approver Jira | Approved | Notes                  |
| ------------------- | -------- | ------------- | -------- | ---------------------- |
| Architecture (req)  |          |               |          | L10+ engineer required |
| Team EM (required)  |          |               |          |                        |
| PM (required)       |          |               |          |                        |
| Team Engineer (req) |          |               |          |                        |
| [Dependent Squad]   |          |               |          |                        |
```

Required reviewers: Architecture (L10+), Team EM, PM, Team Engineer.
Add dependent squad engineers for any service this design impacts.

---

## Changes Tracking Table

Track design evolution with a changes table after Approvers:

```markdown
### Changes

| Summary               | Link       |
| --------------------- | ---------- |
| Why X over Y approach | [doc link] |
| Updated rollout plan  | [doc link] |
```

---

## Reference Files

**Full template with all sections and RMS Questionnaire:**

```
Read `~/.claude/skills/design-doc-writing/references/TEMPLATE.md`
```

Use when: Drafting a new doc from scratch or verifying all required sections are present.

**Writing patterns, proto3 examples, and real doc conventions:**

```
Read `~/.claude/skills/design-doc-writing/references/WRITING-PATTERNS.md`
```

Use when: Writing APIs, data models, scale estimates, or launch plans. Includes examples from real RMS design docs.
