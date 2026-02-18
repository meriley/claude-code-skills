# Section-by-Section Review Checklist

Detailed checks and anti-pattern examples for each section of an RMS Backend Design Document.

---

## Document Header

### Checks

| Check                | Pass                                                 | Fail                                   |
| -------------------- | ---------------------------------------------------- | -------------------------------------- |
| Author name          | Present                                              | Blank or "Change-Me"                   |
| Jira Link            | Valid `taserintl.atlassian.net/browse/RMS-XXXXX` URL | Missing, placeholder, or wrong project |
| Block quotes removed | None present                                         | "Remove this section..." still visible |

---

## Approvers Table

### Required Rows

Every doc must have at minimum:

| Row                      | Requirement                        |
| ------------------------ | ---------------------------------- |
| Architecture (required)  | L10+ engineer or explicit delegate |
| Team EM (required)       | Engineering manager                |
| PM (required)            | Product manager                    |
| Team Engineer (required) | Engineer from owning team          |
| Dependent Squad X        | One row per impacted service       |

### Anti-patterns

**Missing dependent squads:**
A doc touching ZekeDB with no Entity Graph Squad approver, or UAC changes with no UAC squad row.

**Empty Approver column:**
Rows exist but no one is named. This is ok before sending for review — but all rows must be filled before approval.

**Wrong L10 delegate:**
"Architecture (required)" row has a non-L10 engineer with no delegation note.

---

## Problem Summary and Background

### Strong Pattern

Lead with current state → gap/failure mode → historical context → why prior approach fails:

```
Current: RQ and Records Service handle task mutations independently.
Gap: When RQ succeeds but Records Service fails, data desynchronizes.
History: In 2024 we migrated tasks to the Entity Graph to speed delivery.
Why prior approach fails: The hybrid approach now creates transactional inconsistencies at scale.
```

### Anti-patterns

| Anti-pattern           | What to Flag                                            |
| ---------------------- | ------------------------------------------------------- |
| Starts with solution   | "We will build a new service that..."                   |
| No historical context  | Jumps from problem to solution without "why now"        |
| Too short              | One sentence that doesn't give reviewers enough context |
| Too long and unfocused | Multiple problems conflated into one doc                |

---

## Requirements

### Strong Pattern

Requirements grouped by category, sourced from product spec, written as outcomes not implementations:

```
_Atomic Transaction Handling:_
1. All updates to a Task and its corresponding Entity must occur within one transaction.
2. In the event of any failure, both changes must be rolled back.
```

### Anti-patterns

| Anti-pattern               | Example                           | Fix                                                      |
| -------------------------- | --------------------------------- | -------------------------------------------------------- |
| Implementation requirement | "Use a PostgreSQL transaction"    | "Ensure data consistency across Task and Entity updates" |
| Vague Not in Scope         | "Performance optimizations"       | "P99 latency optimization for task search queries"       |
| Missing Not in Scope       | No section at all                 | Add section listing known edge cases excluded            |
| No PM confirmation         | Custom requirements not from spec | Flag: "Verify these requirements are confirmed with PM"  |

---

## Architecture / System Overview

### Checks

- Does the diagram include ALL services mentioned in the text?
- Are new services labeled with what they do (not just a name)?
- Is the data flow direction shown (not just boxes)?
- Are infra components (Kafka, Redis, S3) shown if used?

### Anti-patterns

| Anti-pattern                                | Signal                               |
| ------------------------------------------- | ------------------------------------ |
| Diagram is a single box                     | Service name with no context         |
| Text mentions service X but diagram doesn't | Inconsistency                        |
| "Dependent Services" list is empty          | Every service has dependencies       |
| New service described vaguely               | "A new microservice to handle logic" |

---

## APIs

### Proto3 Checks

- First field value in each enum must be `_UNSPECIFIED = 0`
- `agency_id` always included where multi-tenancy applies
- Timestamps use `google.protobuf.Timestamp`, not `string`
- Repeated fields used for lists, not single fields with JSON blobs
- Pagination fields: `page_size` (max N), `page_token` (cursor), `next_page_token`

### Common Violations

**Missing pagination on list method:**

```proto
// BAD
rpc ListTasks(ListTasksRequest) returns (ListTasksResponse);
message ListTasksRequest {
  string agency_id = 1;
  // No page_size, no page_token!
}

// GOOD
message ListTasksRequest {
  string agency_id = 1;
  int32 page_size = 2;   // max 100
  string page_token = 3;
}
message ListTasksResponse {
  repeated Task tasks = 1;
  string next_page_token = 2;
}
```

**Enum missing UNSPECIFIED:**

```proto
// BAD
enum TaskAction {
  TASK_ACTION_CREATED = 0;  // Reserved value misused
}

// GOOD
enum TaskAction {
  TASK_ACTION_UNSPECIFIED = 0;
  TASK_ACTION_CREATED = 1;
}
```

**Kafka message missing CloudEvent wrapper:**

```proto
// BAD - inner payload only
message TaskUpdatedEvent {
  string task_id = 1;
}

// GOOD - CloudEvent wrapper required
message CloudEvent {
  string id = 1;
  string type = 4;
  bytes data = 5;  // serialized TaskUpdatedEvent
}
```

---

## Data Storage

### MySQL / Relational Table Checks

- `id BIGINT NOT NULL AUTO_INCREMENT` as primary key
- `agency_id` column present and indexed for multi-tenant data
- `created_at` and `updated_at` timestamps present
- Every index is justified (comment or note explaining why)
- JSON columns: confirm they aren't being used for queryable/filterable data

**Anti-pattern — JSON column used for queried fields:**

```sql
-- BAD: rule_type is queried but buried in JSON
rule_definition JSON NOT NULL  -- contains {"rule_type": "auto_approve"}

-- GOOD: extract queryable fields as columns
rule_type VARCHAR(50) NOT NULL,
rule_definition JSON NOT NULL,  -- remaining config only
INDEX idx_rule_type (agency_id, rule_type)
```

### ZekeDB Checks

- Is this a new entity type (etype)? → Must show Node entry
- Is this a new attribute type (atype)? → Must list all new atypes with type and required/optional
- Is this a new edge between existing etypes? → Must show edge direction and cardinality
- Which submodule? → Must be stated
- Branching paradigm? → Must be stated (standard / custom)
- Can finalized data change? → Must describe Revert Finalize, Supplements, or Direct Modification

---

## Low Level Design

### Checks

- Is there a call flow for each key operation (create, update, delete, read)?
- Are external service calls shown (gRPC call to UAC, Kafka publish, etc.)?
- Are error paths described (what happens on each failure type)?
- Are any fundamental limitations called out?

### Anti-patterns

| Anti-pattern              | Signal                       |
| ------------------------- | ---------------------------- |
| Code snippet              | Actual code, not pseudo-code |
| "Standard implementation" | No detail provided           |
| Only happy path           | No error scenarios           |
| Circular call flows       | Service A calls B calls A    |

---

## Failure Modes

### Required Scenarios (Minimum)

Every doc must address:

1. Database unavailable
2. At least one dependent service down
3. Concurrency / race conditions (if any writes)

### Kafka Consumer Minimum Coverage

For any Kafka consumer:

- Retry strategy (attempts, backoff)
- DLQ topic name
- DLQ processing cadence
- Idempotency guarantee (safe to replay?)
- Alerting trigger

### Anti-patterns

| Anti-pattern                       | Signal                                        |
| ---------------------------------- | --------------------------------------------- |
| "Handle gracefully"                | No specific mitigation                        |
| Missing concurrency                | Doc has writes but no race condition analysis |
| No DLQ for Kafka consumer          | Consumer failure = data loss                  |
| Mitigation is "alert on-call" only | No automated recovery                         |

---

## RMS Specific Questionnaire

### Row-by-Row Review

| Row                  | "Yes" requires                                                  | "No" requires                           | Common mistake                                    |
| -------------------- | --------------------------------------------------------------- | --------------------------------------- | ------------------------------------------------- |
| Audit                | How changes tracked, what audit trail exists                    | Why no audit needed                     | Vague: "standard audit logging"                   |
| Sealing/Expungements | Entity Graph Squad approver                                     | Why new module isn't subject to sealing | Missing when adding new entity types              |
| Internationalization | No user-facing strings in DB, unit-sensitive data called out    | Why feature has no i18n impact          | Missing when adding UI-visible text               |
| Mobile Support       | Mobile reviewer added as approver                               | Why no mobile impact                    | Missing when backend change affects mobile client |
| Integrations         | Integration/CSP squad approver                                  | Why no integration impact               | Missing when adding new user-entered data         |
| Security             | CJI handling described, redacted from logs, not in query params | Why no sensitive data involved          | Vague: "follows security guidelines"              |
| Public APIs          | New public API described, 3rd party impact assessed             | Why no public API impact                | Missing when Hermes layer is modified             |
| Search               | New entity or filter described, Discovery squad approver        | Why no search impact                    | Missing when adding searchable entities           |
| Metrics              | OPS metrics (latency, load) AND usability metrics (adoption)    | Why no metrics needed                   | Only OPS metrics, missing feature adoption        |
| Authorization        | New permissions described, static vs config-generated           | Why no new auth needed                  | Vague: "uses existing permissions"                |
| Breaking Changes     | Backfill strategy for data model changes, migration plan        | Why no breaking changes                 | Missing when removing/renaming fields             |
| Automated Tests      | Why scenarios can't be covered by unit/API/E2E                  | Why all scenarios are covered           | Vague: "standard test coverage"                   |
| Multi-Juris          | How multi-jurisdictional permissions handled                    | Why feature is single-agency            | Missing when data can cross agency boundaries     |

---

## Test Plan

### Checks

- Is each component covered by unit tests?
- Are integration tests for cross-service flows?
- Are E2E tests for user-facing flows?
- Are complex failure scenarios in the test plan (not just happy path)?

### Anti-patterns

| Anti-pattern                   | Signal                             |
| ------------------------------ | ---------------------------------- |
| "Unit tests for all code"      | No specific scenarios listed       |
| Only happy path E2E            | No failure scenario tests          |
| No integration tests for Kafka | Consumer logic untested end-to-end |

---

## Launch Plan

### Phase Validation

Each phase (AG1, US2, Production) must have:

1. **Feature flag name** — exact string, not "a feature flag"
2. **Validation steps** — what to check and how (not just "monitor logs")
3. **Rollback procedure** — what to do if validation fails

### Rollback Depth

For data-writing features, "disable feature flag" is insufficient. Must also state:

- Whether written data must be cleaned up
- Migration name if a cleanup migration is needed
- Whether agencies need notification

### Success Criteria Anti-patterns

| Anti-pattern      | Example                                    | Fix                                           |
| ----------------- | ------------------------------------------ | --------------------------------------------- |
| Vague performance | "Low latency"                              | "P99 < 200ms"                                 |
| Only operational  | Error rates only                           | Add functional and adoption metrics           |
| No baseline       | "Within baseline" without stating baseline | Link Splunk query that shows current baseline |
