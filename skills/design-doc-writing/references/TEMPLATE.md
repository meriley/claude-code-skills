# Backend Design Doc Template

Full template for RMS Backend Design Documents. Copy this structure for new docs.

---

````markdown
# [Feature Name] Design Document

> \*First Design Document? Start Here → [Intro to Design Documents](https://axon.quip.com/q7YIARdAnvIR),
>
> Process Overview: [Productivity JIRA-Based Design Review Process](https://axon.quip.com/MrzVAJbDK3Ck)
>
> Additional Resources: [Design Document Guidelines](https://axon.quip.com/c9lXAVrMuwzz)
>
> Remove this section and all other sections in block quotes prior to the design review.\*

**Author:** Change-Me
**Document Jira Link:** Change-Me

## Approvers

**Important:** Please ensure the Approved column is filled out before moving forward with implementation. A review from your team's EM and one of our L10+ engineers is **required** before proceeding. A review from dependent/stakeholder teams is also required, or teams that own the domains this design impacts, see [Services Master List / Owners - Productivity (Records/Transcription)](https://axon.quip.com/5tmpALbAKw8Y).

**Important:** Please ensure the design document is kept up-to-date. If any design changes are made post-approval, request another approval from reviewers before proceeding.

Please also post in [#rms-design-doc-review](https://axon.slack.com/archives/CUM2W7LKH) for team visibility.

| Squad                         | Approver | Approver Jira | Approved | Notes                                             |
| ----------------------------- | -------- | ------------- | -------- | ------------------------------------------------- |
| Architecture (required)       |          |               |          | Review from an L10+ engineer or explicit delegate |
| ---                           | ---      | ---           | ---      | ---                                               |
| Team EM (required)            |          |               |          |                                                   |
| PM (required)                 |          |               |          |                                                   |
| Team Engineer (required)      |          |               |          |                                                   |
| Dependent Squad X Engineer(s) |          |               |          |                                                   |
| Mobile Reviewer               |          |               |          |                                                   |
| Internationalization Reviewer |          |               |          |                                                   |
| InfoSec                       |          |               |          |                                                   |
| Cross-pillar Staff            |          |               |          |                                                   |
| SME                           |          |               |          |                                                   |
| Observer                      |          |               |          |                                                   |

### Changes

> _Track design evolution. Add a row each time a significant section is revised post-review._

| Summary | Link |
| ------- | ---- |
|         |      |

## Problem Summary and Background

> Write a paragraph or two describing the problem. Include relevant background context needed to understand it. If the problem has been solved before, explain why the prior solution will not work.

## Requirements

> Copy requirements from the product spec or 1-pager. Run by PM and EM if not sourced from a spec.

1. Requirement one
2. Requirement two

### Not in Scope

> List items explicitly excluded. Focus on areas with complexity where edge cases could be misunderstood.

1. Not in scope item one

## Architecture/System Overview (High Level Design)

> List all key dependent services. Describe new services being created. Include an architecture diagram with all dependent services, new services, and new infrastructure.

### Dependent Services

- **[Service Name]**: [Why this service is involved]

### New Services / Infrastructure

- **[Service Name]**: [What it does and why it's new]

## Design Details

### APIs

> New APIs or changes to existing APIs. Use proto3 (gRPC), OpenAPI (REST), or GraphQL typedef format. Kafka consumer messages in proto3 wrapped in CloudEvent. Identify all batch APIs and verify they have pagination, limits, and no unbounded operations.

#### [Service Name] gRPC API

```proto
service ExampleService {
  rpc ExampleMethod(ExampleRequest) returns (ExampleResponse);
}

message ExampleRequest {
  string id = 1;
}

message ExampleResponse {
  string result = 1;
}
```
````

### Data Visibility and Ownership

> Which modules own the data? What isolation is required? How is isolation enforced at the API layer?

### Data Storage

> How will data be stored? Why this storage solution? Read/write characteristics. Indexes and query patterns. Use DML/SQL for all new/updated tables.

For ZekeDB: provide Node/Edge diagram, submodule usage, branching paradigms, new etypes/atypes. If data needs to be modified after finalization, describe how (Revert Finalize, Supplements, Direct Modification).

```sql
CREATE TABLE example_table (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  agency_id  VARCHAR(36)  NOT NULL,
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX idx_agency_id (agency_id)
);
```

### Low Level Design

> General overview of the solution, then detail each key component. Include call flows, error scenarios, and edge cases. Call out any fundamental limitations that shaped the design. No code snippets unless algorithm is critical to the design.

### Failure Modes and Recovery

> What can go wrong? DB crash, dependent service down, increased latency. How is data consistency maintained across systems? How are concurrency/race conditions prevented?

For Kafka consumers: DLQ strategy, retry policy, cron job recovery, failure frequency.

| Failure Scenario           | Impact   | Mitigation   |
| -------------------------- | -------- | ------------ |
| Database unavailable       | [impact] | [mitigation] |
| Dependent service down     | [impact] | [mitigation] |
| Duplicate event processing | [impact] | [mitigation] |

### Traffic and Cost Estimates

> Basic traffic load and data storage estimates for year one. Assume all customers. Does the solution scale? Estimate yearly cost.

| Metric               | Estimate | Notes                   |
| -------------------- | -------- | ----------------------- |
| Requests/day         |          | Based on Splunk: [link] |
| Storage growth/month |          |                         |
| Yearly cost          |          |                         |

## RMS Specific Questionnaire

> Every row must update the `Required?` column to Yes or No. Additional reviewers or justification may be required.

| Feature Area                      | Description                                                                                                                                  | Required?    | Required Reviewer           | Justification/Response |
| --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | ------------ | --------------------------- | ---------------------- |
| Audit                             | How will change/modifications be tracked? Justification required if not auditing.                                                            | Not Answered |                             |                        |
| Sealing and Expungements          | Will this be included in Sealing/Expungements workflow? Required if building new module, container entity, or edges to container entities.   | Not Answered | Entity Graph Squad          |                        |
| Internationalization              | Is your feature localizable? Do not store user-facing strings in DB. Call out unit-sensitive data (dates, weights, measurements).            | Not Answered | Internationalization Squad  |                        |
| Mobile Support                    | Does this need mobile support? If yes, describe and include mobile team stakeholder as approver.                                             | Not Answered |                             |                        |
| Integrations and Conversions      | Does this involve net-new data users will enter? Consider automated Integration or bulk legacy Conversion.                                   | Not Answered | Integrations and CSP Squads |                        |
| Security                          | Does this involve sensitive (e.g. CJI) data? How will it be handled (redacted from logs, not in query params, not in session/local storage)? | Not Answered |                             |                        |
| Public APIS                       | Impact on public APIs exposed to 3rd parties? Specify new public APIs for feature parity.                                                    | Not Answered |                             |                        |
| Search                            | Dependencies on search? New entity or new filters in search?                                                                                 | Not Answered | Discovery Squad             |                        |
| Metrics                           | What metrics captured? OPS metrics (latency, load) and usability metrics (feature adoption)?                                                 | Not Answered |                             |                        |
| Authorization/Privileges          | New permissions needed? Static or config-generated privileges?                                                                               | Not Answered |                             |                        |
| Breaking Changes                  | Removed/renamed/new required API params? New required fields in core data model? Backfill strategy for data model changes?                   | Not Answered |                             |                        |
| Automated Tests                   | Any scenarios not coverable by unit, API, or automated E2E/Checkly tests?                                                                    | Not Answered |                             |                        |
| Multi Jurisdictional Data Sharing | Does this allow sharing across multiple agencies? Handles multi-juris context and permissions?                                               | Not Answered |                             |                        |

## Test Plan

> Describe how this feature will be tested. Unit tests, integration tests, E2E tests. Include specific test scenarios for complex flows.

### Unit Tests

- [Component]: [What is tested]

### Integration Tests

- [Scenario]: [Expected behavior]

### E2E / Manual Tests

- [Scenario]: [Steps and expected outcome]

## Launch Plan

> Phase-by-phase rollout strategy. Include feature flag names, environment progression, and rollback steps.

### Phase 1: AG1 (Internal Testing)

- Feature flag: `enable_[feature_name]`
- Validation: [What to verify]
- Rollback: Disable feature flag

### Phase 2: US2 (Staging)

- Feature flag: `enable_[feature_name]`
- Validation: [What to verify]
- Rollback: Disable feature flag

### Phase 3: Production

- Feature flag: `enable_[feature_name]`
- Rollout: Gradual percentage rollout or per-agency
- Validation: [Key metrics to monitor]
- Rollback: Disable feature flag, [any data cleanup needed]

### Success Criteria

- **Operational**: No service degradation, error rates within baseline
- **Functional**: [Specific feature behaviors working correctly]
- **Performance**: [Latency targets, throughput targets]

## Appendix

### Other Design Alternatives

> Alternatives explored, their pros/cons, and why the chosen design was selected.

### Open Questions

> Unresolved questions requiring further investigation or stakeholder input.

### Other Notes

> Anything else needed for the success of this project.

---

[[Backend Design Doc Template]](https://axon.quip.com/KRD3AE5fBuXG)

```

```
