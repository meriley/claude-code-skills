# Review Patterns and Examples

Common review scenarios, approval decision guidance, and real feedback patterns for RMS Backend Design Documents.

---

## Approval Decision Guide

| Status                      | When to Use                                                                     |
| --------------------------- | ------------------------------------------------------------------------------- |
| **APPROVE**                 | No blockers, no critical issues. Minor items only.                              |
| **APPROVE WITH CHANGES**    | Minor/major items that can be fixed in parallel with implementation.            |
| **NEEDS REVISION**          | Critical issues that must be resolved before proceeding. Re-review required.    |
| **MAJOR REVISION REQUIRED** | Blockers present, or fundamental design problems. Architecture re-think needed. |

---

## Scenario Examples

### Scenario 1: Strong Doc — Minor Gaps

**Context:** A well-written doc for a new Kafka consumer that processes task events. All sections present. RMS Questionnaire fully answered. Architecture diagram clear. One list API missing pagination.

**Status:** NEEDS REVISION (pagination is a BLOCKER)

**Findings:**

- BLOCKER: `ListTaskRules` RPC has no `page_size` or `page_token` — could return unbounded results
- MINOR: Success criteria says "low latency" — recommend adding specific P99 target

**Section Ratings:**

| Section           | Rating   |
| ----------------- | -------- |
| Problem Summary   | Strong   |
| APIs              | Weak     |
| RMS Questionnaire | Strong   |
| Launch Plan       | Adequate |

---

### Scenario 2: Missing Questionnaire Responses

**Context:** Doc submitted for review with 5 rows still showing "Not Answered" in the RMS Questionnaire.

**Status:** NEEDS REVISION

**Findings:**

- BLOCKER: Audit row "Not Answered" — this service writes task records, must define audit strategy
- BLOCKER: Security row "Not Answered" — task data may contain CJI, must address
- BLOCKER: Authorization row "Not Answered" — new task operations require privilege checks
- CRITICAL: Sealing/Expungements row "Not Answered" — new entity type added, Entity Graph Squad review required
- CRITICAL: Breaking Changes row "Not Answered" — existing API params are renamed

**Recommendation:** Complete questionnaire before re-submitting. Invite Entity Graph Squad and InfoSec as approvers.

---

### Scenario 3: ZekeDB Changes Without Diagram

**Context:** Doc describes adding a new `task_rule` node type to ZekeDB and edges to `agency` and `task`. No Node/Edge diagram is present.

**Status:** NEEDS REVISION

**Findings:**

- BLOCKER: ZekeDB changes documented in text but no Node/Edge diagram provided
- CRITICAL: New etypes listed but submodule assignment not stated
- MAJOR: No description of branching paradigm for `task_rule` nodes
- MAJOR: Post-finalize modification not addressed — can task rules be edited after finalization?

---

### Scenario 4: Good Failure Modes Missing Kafka

**Context:** Doc describes a Kafka consumer for audit events. Failure modes table has DB and service-down scenarios but no Kafka-specific coverage.

**Status:** APPROVE WITH CHANGES

**Findings:**

- MAJOR: Kafka consumer failure modes not addressed — need DLQ strategy, retry policy, idempotency guarantee, and cron recovery
- MAJOR: No DLQ topic name defined
- MINOR: `AuditEventConsumer` retry count set to 3 — recommend justifying why 3 vs 5

**Recommendation:** Add Kafka failure section before implementation begins. Rest of doc is solid.

---

### Scenario 5: Vague Rollback

**Context:** Launch Plan has three phases documented. Each phase has rollback as "disable feature flag". The feature writes a new table and ZekeDB nodes.

**Status:** APPROVE WITH CHANGES

**Findings:**

- MAJOR: Phase 3 (Production) rollback says "disable feature flag" but new ZekeDB nodes and MySQL records will exist — need cleanup migration named
- MAJOR: No notification strategy if production rollback required for agencies already using the feature
- MINOR: AG1 validation steps say "check logs" — recommend specific Splunk query link

---

## Questionnaire Quick-Decision Guide

### "Not Answered" is Always a Blocker

Never approve a doc with "Not Answered" rows. Even if the answer is N/A, the author must state why.

### Audit Row

**Yes (tracking required):**

- Any service that creates, updates, or deletes records
- Answer must name the audit mechanism: Activity Log Service, direct audit table, or ZekeDB audit edges

**No (not required):**

- Read-only services
- Internal cache or compute layers
- Must still justify why no audit trail is needed

### Sealing/Expungements Row

**Yes (Entity Graph Squad required):**

- Adding new entity types (new etypes)
- Adding edges to container entities (case, incident, report)
- New modules that hold subject data

**No (not required):**

- Pure infrastructure (queues, caches, routing)
- Config/rule tables not tied to subjects

### Security Row (CJI Data)

**Yes (detailed answer required):**

- Any data that could be CJI (arrest records, criminal history, biometrics)
- Must state: not logged, not in query params, encrypted at rest, not in session/local storage

**No (not required):**

- Config and metadata without PII
- Internal operational data

### Authorization/Privileges Row

**Yes:**

- New RPC methods that need permission checks
- Must state: static privileges vs config-generated, which UAC policies affected

**No:**

- Internal-only services with no direct user access
- Must justify why no permissions apply

---

## Failure Mode Coverage Reference

### Minimum Required Scenarios

| Category       | Scenario                                | Expected Mitigation Pattern                     |
| -------------- | --------------------------------------- | ----------------------------------------------- |
| Database       | Primary DB unavailable                  | Circuit breaker, retry, fallback read replica   |
| Dependency     | Dependent service returns 5xx           | Retry with exponential backoff, circuit breaker |
| Concurrency    | Concurrent writes to same record        | Optimistic locking, database-level constraint   |
| Data integrity | Partial failure in multi-step operation | Saga pattern, idempotent operations, DLQ        |

### Kafka Consumer Minimum

```markdown
**Failure Recovery for [ConsumerName]:**

- Retry strategy: Exponential backoff, max N retries
- DLQ topic: `[topic-name]-dlq`
- DLQ processing: Cron every N minutes
- Idempotency: All operations idempotent — safe to replay
- Alerting: PagerDuty if DLQ depth > N
```

---

## Launch Plan Rollback Patterns

### Feature Flag Only (No Data Written)

Acceptable when: Feature is purely additive and no new records are created.

```markdown
Rollback: Disable `enable_[feature]` feature flag. No data cleanup required.
```

### Feature Flag + Data Cleanup

Required when: New MySQL rows, ZekeDB nodes/edges, or S3 objects are written.

```markdown
Rollback:

1. Disable `enable_[feature]` feature flag
2. Run cleanup migration: `V[version]__rollback_[feature_name].sql`
3. Delete ZekeDB nodes of type `task_rule` created after [timestamp]
4. Notify affected agencies: [list criteria for notification]
```

### Migration-Based Rollout

Required for schema migrations or dual-write periods:

```markdown
Rollback from Phase 2 (Records Service Primary):

1. Set `enableAtomicTaskOperations = false` to re-enable RQ path
2. Verify RQ task endpoint responds correctly
3. Monitor error rate for 30 minutes before declaring stable
4. File incident if data inconsistencies found — do NOT auto-fix
```

---

## Common Review Comment Templates

### Pagination Missing

> **BLOCKER — [RPC Name]:** This list API has no pagination. Add `page_size` (max 100) and `page_token` to the request, and `next_page_token` to the response. Without this, the API can return unbounded results and cause service instability at scale.

### Not Answered in Questionnaire

> **BLOCKER — RMS Questionnaire, [Row Name] row:** This row is still "Not Answered". Based on the design ([specific reason]), this feature [likely/possibly] requires [Yes/No]. Please answer and add justification. If Yes, add [reviewer/squad] as an approver.

### Vague Not in Scope

> **MAJOR — Requirements, Not in Scope:** "[Vague item]" is too broad. Specify what exactly is excluded. For example: "Latency optimization for the `ListTasks` query is not in scope for this iteration."

### Vague Rollback

> **MAJOR — Launch Plan, Phase [N] Rollback:** This phase writes [describe data]. "Disable feature flag" alone is not sufficient. Add: (1) cleanup migration name, (2) whether data written before rollback needs deletion, and (3) agency notification criteria if any.

### Missing Failure Scenario

> **MAJOR — Failure Modes:** No scenario for [failure type, e.g., "Kafka consumer lag causing delayed processing"]. Add the impact (e.g., "notifications delayed up to N minutes") and mitigation (e.g., "auto-scale consumers when lag > threshold, PagerDuty alert").
