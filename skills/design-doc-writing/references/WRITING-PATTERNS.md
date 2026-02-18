# Design Doc Writing Patterns

Patterns extracted from real RMS design documents. Use these as reference when writing specific sections.

---

## Problem Statement Patterns

### Strong Problem Statement (from Transactional Task Operations doc)

Lead with the systemic issue, then explain historical context, then state the specific consequence:

```
It starts with the fact that our current system processes Task transactions using
two distinct services: Routing and Queuing (RQ) and Records Service. RQ handles
the task operations, while Records Service manages the updates to related entities.
However, when a Task transaction succeeds in RQ but fails to update its corresponding
entity in Records Service, the two become unsynchronized.

In 2024, during the Task Search project, we migrated Tasks to the Entity Graph managed
by Records Service. To expedite the project, the decision was made to allow RQ to
continue managing task actions... This hybrid approach, although effective temporarily,
is now insufficient because it creates the possibility of transactional inconsistencies.
```

**Pattern:**

1. Current state: what exists today
2. The gap/failure mode: what goes wrong
3. Historical context: why we got here
4. Why the prior approach no longer works

### Concise Problem Statement (from Rules Manager doc)

For smaller features, one focused sentence is enough:

```
BPD has requested a feature that would allow Records to automatically approve
reports for specific districts. RQ does not currently have the ability to support
conditionally automated task events.
```

---

## Requirements Patterns

### Grouped by Category (from Transactional Task Operations)

Group related requirements under clear category headers:

```markdown
_Atomic Transaction Handling:_

1. All updates to a Task and its corresponding Entity must occur within one single transaction.
2. In the event of any failure, both changes must be rolled back to maintain data integrity.

_Authorization and Privilege Checks:_

1. Transfer task privilege evaluation from RQ to Records Service by establishing UAC policies.
2. Update all Records Service endpoints to validate Task actions against these new checks.
```

### Not in Scope - Be Specific

Name the specific thing being excluded, not categories:

```markdown
### Not in Scope

1. Expungements for tasks - resolved by RMS-51430
2. Mobile client changes - no mobile impact for this backend migration
3. Historical data backfill for pre-migration tasks
```

---

## Scale Estimation Patterns

### With Splunk Reference (from Rules Manager doc)

```markdown
## Back Of Envelope Scale Estimation

This service will process roughly 8,230 requests daily, averaging about 343 requests
an hour. This is based on [Splunk charting](https://splunk.taservs.net/...) all
`updateTask` calls in a given day.
```

### Estimation Table Format

```markdown
| Metric              | Calculation       | Estimate  |
| ------------------- | ----------------- | --------- |
| Daily requests      | Splunk: [link]    | 8,230/day |
| Peak requests/hour  | daily ÷ 24        | 343/hr    |
| Storage per record  | avg payload size  | 2KB       |
| Storage growth/year | daily × 365 × 2KB | ~6GB      |
| Yearly cost (RDS)   | storage + compute | ~$X,XXX   |
```

---

## Glossary Pattern

Define all domain terms readers might not know. From real docs:

```markdown
## Glossary

- **Kafka** - Open-source distributed event streaming platform.
- **Debezium** - Open source project for change data capture. RMS uses Debezium to capture MySQL changes.
- **Stream Processors** - A Kafka service that listens for MySQL changes and publishes events.
- **Themis** - Rule storage service.
- **Routing and Queuing (RQ)** - An RMS service that manages tasks and workflows.
- **MIE** - Multiuser Incident Editing. Collaborative editing feature for incident reports.
- **CloudEvents** - A specification for describing event data in common formats for interoperability.
```

---

## API Definition Patterns

### gRPC / proto3

```proto
service DocumentService {
  rpc MergeDocument(MergeDocumentRequest) returns (MergeDocumentResponse);
  rpc GetDocument(GetDocumentRequest) returns (GetDocumentResponse);
}

message MergeDocumentRequest {
  string agency_id = 1;
  string primary_document_id = 2;
  repeated string source_document_ids = 3;
}

message MergeDocumentResponse {
  string merged_document_id = 1;
  DocumentStatus status = 2;
}

enum DocumentStatus {
  DOCUMENT_STATUS_UNSPECIFIED = 0;
  DOCUMENT_STATUS_MERGED = 1;
  DOCUMENT_STATUS_FAILED = 2;
}
```

### Kafka Consumer Message (CloudEvent wrapper)

```proto
// CloudEvent envelope
message CloudEvent {
  string id = 1;
  string source = 2;
  string spec_version = 3;
  string type = 4;
  bytes data = 5;  // serialized TaskEvent
}

// Inner payload
message TaskEvent {
  string task_id = 1;
  string agency_id = 2;
  TaskAction action = 3;
  google.protobuf.Timestamp occurred_at = 4;
}

enum TaskAction {
  TASK_ACTION_UNSPECIFIED = 0;
  TASK_ACTION_CREATED = 1;
  TASK_ACTION_UPDATED = 2;
  TASK_ACTION_APPROVED = 3;
}
```

### Pagination for Batch APIs

All list/batch APIs must include pagination:

```proto
message ListTasksRequest {
  string agency_id = 1;
  int32 page_size = 2;   // max 100
  string page_token = 3;  // cursor-based
}

message ListTasksResponse {
  repeated Task tasks = 1;
  string next_page_token = 2;  // empty = last page
  int32 total_count = 3;
}
```

---

## Data Storage Patterns

### MySQL Table with Indexes

```sql
CREATE TABLE task_rules (
  id              BIGINT        NOT NULL AUTO_INCREMENT,
  agency_id       VARCHAR(36)   NOT NULL,
  rule_name       VARCHAR(255)  NOT NULL,
  rule_definition JSON          NOT NULL,
  enabled         BOOLEAN       NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX idx_agency_enabled (agency_id, enabled),
  INDEX idx_created_at (created_at)
);
```

**Rules:**

- Always include `created_at` and `updated_at`
- `agency_id` almost always needs an index
- Explain why each index exists in a comment or note
- Use `BIGINT AUTO_INCREMENT` for PKs

### ZekeDB Node/Edge Pattern

When adding to the Entity Graph, document:

```markdown
### ZekeDB Changes

**New Node: TaskRule**

- Etype: `task_rule`
- Submodule: `rules`
- Branching: standard (no special branching)

**New Edges:**

- `agency → task_rule` (one-to-many): Agency owns its rules
- `task → task_rule` (many-to-many): Tasks matched by rules

**New Atypes:**

- `rule_name`: string, required
- `rule_definition`: json, required
- `enabled`: boolean, default true
```

---

## Failure Mode Patterns

### Failure Mode Table (from Notifications doc)

```markdown
| Failure Scenario                 | Impact                           | Mitigation                                            |
| -------------------------------- | -------------------------------- | ----------------------------------------------------- |
| Kafka consumer lag               | Delayed notifications            | Monitor consumer lag, auto-scale consumers            |
| Email provider (SendGrid) outage | Emails not delivered             | Retry with exponential backoff, DLQ after 3 retries   |
| Redis deduplication store down   | Duplicate notifications possible | Fallback to DB dedup check, alert on Redis down       |
| DB unavailable during write      | Event lost                       | Kafka DLQ, retry cron every 15min                     |
| Dependent service returns 5xx    | Operation fails                  | Exponential backoff, circuit breaker after 5 failures |
```

### Kafka Consumer Failure Pattern

```markdown
**Failure Recovery for [ConsumerName]:**

- **Retry strategy**: Exponential backoff, max 3 retries
- **DLQ**: Events that fail 3 retries go to `[topic]-dlq`
- **DLQ processing**: Cron job every 30 minutes reprocesses DLQ
- **Idempotency**: All operations are idempotent - safe to replay events
- **Alerting**: PagerDuty alert if DLQ depth > 100
```

---

## Dual-Write / Migration Patterns

From Transactional Task Operations (common RMS migration pattern):

```markdown
### Migration Strategy

**Phase 1: Dual Write**

- Both RQ and Records Service handle task mutations
- Feature flag: `enableAtomicTaskOperations = false`
- Validation: compare outputs from both paths

**Phase 2: Records Service Primary**

- Feature flag: `enableAtomicTaskOperations = true`
- Records Service is authoritative, RQ path deprecated
- Monitor error rates before proceeding

**Phase 3: RQ Cleanup**

- Disable RQ task endpoints
- Drop legacy RQ tables (after backup confirmed)
- Feature flag: removed (always on)
```

---

## Launch Plan Patterns

### Environment Progression

```markdown
## Launch Plan

### Phase 1: AG1 (Internal / Pre-prod)

- Enable: `enable_[feature]` flag for internal agency
- Duration: 2 weeks
- Validation:
  - [ ] No errors in service logs
  - [ ] Latency within baseline P99 < 200ms
  - [ ] Feature behaves as specified in requirements
- Rollback: disable feature flag, no data cleanup needed

### Phase 2: US2 (Staging)

- Enable: `enable_[feature]` flag for US2 agencies
- Duration: 1 week
- Validation: same as Phase 1 + load test results
- Rollback: disable feature flag

### Phase 3: Production

- Enable: gradual rollout 10% → 50% → 100% over 2 weeks
- Monitor: error rate, latency P99, feature adoption metric
- Rollback:
  1. Disable feature flag immediately
  2. Run cleanup migration if data was written: `[migration name]`
  3. Notify affected agencies if needed
```

### Success Criteria

```markdown
### Success Criteria

**Operational:**

- No increase in error rate (P99 latency stays < 200ms)
- Zero data inconsistencies detected post-migration

**Functional:**

- Tasks created through Records Service are identical to those created through RQ
- Authorization checks pass for all valid actions, fail for unauthorized ones

**Performance:**

- Atomic transaction adds < 10ms overhead vs prior dual-write
- Kafka consumer processes events within 5s of publish
```

---

## Common RMS Services Reference

| Service                  | Purpose                      | Protocol  |
| ------------------------ | ---------------------------- | --------- |
| Records Service          | Task and entity management   | gRPC      |
| Hermes                   | GraphQL API gateway          | GraphQL   |
| Routing and Queuing (RQ) | Legacy task workflow engine  | REST/gRPC |
| ZekeDB / Entity Graph    | Graph-based data storage     | gRPC      |
| Themis                   | Rules storage                | gRPC      |
| Stream Processors        | Kafka CDC from MySQL         | Kafka     |
| UAC                      | Authorization/access control | gRPC      |
| Activity Log Service     | Audit trail                  | gRPC      |
| Komrade                  | User attributes (extended)   | Thrift    |

---

## Anti-Patterns to Avoid

- **Vague Not in Scope**: "Performance optimizations" → be specific: "latency optimization for search queries is not in scope"
- **Missing pagination**: Any API returning a list must have `page_size` + `page_token`
- **Not Answered in Questionnaire**: Every RMS questionnaire row must be Yes/No with justification
- **No rollback steps**: Launch Plan must describe exactly how to revert each phase
- **Skipping Glossary**: Teams use many acronyms - define all of them
- **Code in design doc**: No code snippets unless the algorithm itself is the design (pseudo-code ok for call flows)
