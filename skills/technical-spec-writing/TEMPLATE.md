# Technical Spec Template

Copy and fill in this template when creating a new technical specification.

---

```markdown
# [Feature/System Name] - Technical Specification

## Document Info

| Field | Value |
|-------|-------|
| **Spec ID** | [TS-YYYY-NNN] |
| **Author** | [Name] |
| **Date** | [YYYY-MM-DD] |
| **Version** | [1.0] |
| **Status** | [Draft / In Review / Approved / In Progress / Complete] |
| **Parent PRD** | [PRD-ID] |
| **Feature Spec** | [FS-ID or "N/A"] |

---

## System Overview

### Problem Statement

[What technical problem are we solving? Why can't we use existing solutions?]

### Proposed Solution

[High-level approach in 2-3 sentences. What are we building?]

### Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| [Decision area] | [What we chose] | [Why we chose it] |
| [Decision area] | [What we chose] | [Why we chose it] |
| [Decision area] | [What we chose] | [Why we chose it] |

### Scope

**In Scope:**
- [What this spec covers]
- [What this spec covers]

**Out of Scope:**
- [What's excluded] - [Why excluded]
- [What's excluded] - [Why excluded]

---

## Component Architecture

### System Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │────▶│                 │────▶│                 │
│   [Component]   │     │   [Component]   │     │   [Component]   │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                      │                       │
         ▼                      ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│   [Component]   │     │   [Component]   │     │   [Component]   │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### Component Details

#### [Component Name]

| Aspect | Description |
|--------|-------------|
| **Responsibility** | [What this component does] |
| **Inputs** | [What it receives] |
| **Outputs** | [What it produces] |
| **Dependencies** | [What it needs] |
| **Location** | [Where it lives - service, package, module] |

#### [Component Name]

| Aspect | Description |
|--------|-------------|
| **Responsibility** | [What this component does] |
| **Inputs** | [What it receives] |
| **Outputs** | [What it produces] |
| **Dependencies** | [What it needs] |
| **Location** | [Where it lives] |

### Component Interactions

| From | To | Protocol | Data | Purpose |
|------|----|----------|------|---------|
| [Component A] | [Component B] | [HTTP/gRPC/Event] | [Data type] | [Why] |

---

## API Design

### Endpoints Overview

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| [GET/POST/PUT/DELETE] | [/api/v1/resource] | [Brief description] | [Required/Optional] |

### Endpoint Details

#### [HTTP Method] [Path]

**Description:** [What this endpoint does]

**Authentication:** [Required/Optional, method: JWT, API Key, etc.]

**Authorization:** [Required permissions/roles]

**Rate Limit:** [Requests per minute/hour]

**Request Headers:**
| Header | Required | Description |
|--------|----------|-------------|
| `Authorization` | Yes | Bearer token |
| `Content-Type` | Yes | application/json |
| `X-Request-ID` | No | Correlation ID for tracing |

**Request Parameters:**
| Parameter | Type | Required | Description | Validation |
|-----------|------|----------|-------------|------------|
| [name] | [string/number/boolean] | [Yes/No] | [Description] | [Rules] |

**Request Body:**
```json
{
  "field_name": "type (description)",
  "nested_object": {
    "inner_field": "type (description)"
  },
  "array_field": [
    {
      "item_field": "type"
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "data": {
    "id": "string (UUID)",
    "field": "type (description)",
    "created_at": "string (ISO8601)"
  },
  "meta": {
    "request_id": "string",
    "timestamp": "string (ISO8601)"
  }
}
```

**Error Responses:**

| Status | Error Code | Description | Resolution |
|--------|------------|-------------|------------|
| 400 | `INVALID_INPUT` | [When this occurs] | [How to fix] |
| 401 | `UNAUTHORIZED` | [When this occurs] | [How to fix] |
| 403 | `FORBIDDEN` | [When this occurs] | [How to fix] |
| 404 | `NOT_FOUND` | [When this occurs] | [How to fix] |
| 409 | `CONFLICT` | [When this occurs] | [How to fix] |
| 422 | `UNPROCESSABLE` | [When this occurs] | [How to fix] |
| 429 | `RATE_LIMITED` | [When this occurs] | [How to fix] |
| 500 | `INTERNAL_ERROR` | [When this occurs] | [How to fix] |
| 503 | `SERVICE_UNAVAILABLE` | [When this occurs] | [How to fix] |

**Example Request:**
```bash
curl -X POST https://api.example.com/v1/resource \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "field": "value"
  }'
```

**Example Response:**
```json
{
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "field": "value",
    "created_at": "2024-01-15T10:30:00Z"
  },
  "meta": {
    "request_id": "req_abc123",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

---

## Data Model

### Entity Relationship Diagram

```
┌───────────────────┐       ┌───────────────────┐
│     Entity A      │       │     Entity B      │
├───────────────────┤       ├───────────────────┤
│ id (PK)           │──────▶│ id (PK)           │
│ name              │  1:N  │ entity_a_id (FK)  │
│ status            │       │ field             │
│ created_at        │       │ created_at        │
│ updated_at        │       │ updated_at        │
└───────────────────┘       └───────────────────┘
         │
         │ N:M
         ▼
┌───────────────────┐
│  Junction Table   │
├───────────────────┤
│ entity_a_id (FK)  │
│ entity_c_id (FK)  │
│ metadata          │
└───────────────────┘
```

### Entity: [Name]

**Table:** `table_name`

**Description:** [What this entity represents]

| Column | Type | Constraints | Default | Description |
|--------|------|-------------|---------|-------------|
| `id` | UUID | PK | gen_random_uuid() | Primary identifier |
| `field_name` | VARCHAR(255) | NOT NULL | - | [Description] |
| `status` | ENUM | NOT NULL | 'pending' | Status: pending, active, archived |
| `foreign_id` | UUID | FK, NOT NULL | - | Reference to [other table] |
| `metadata` | JSONB | - | '{}' | Flexible metadata storage |
| `created_at` | TIMESTAMP | NOT NULL | NOW() | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | NOW() | Last update timestamp |
| `deleted_at` | TIMESTAMP | - | NULL | Soft delete timestamp |

**Indexes:**

| Name | Columns | Type | Purpose |
|------|---------|------|---------|
| `idx_table_field` | (field_name) | BTREE | Lookup by field |
| `idx_table_status_created` | (status, created_at) | BTREE | Status filtering with time order |
| `idx_table_foreign` | (foreign_id) | BTREE | Foreign key lookup |

**Constraints:**

| Name | Type | Definition | Purpose |
|------|------|------------|---------|
| `chk_status_valid` | CHECK | status IN ('pending', 'active', 'archived') | Validate status values |

**Relationships:**

| Relation | Target | Type | On Delete |
|----------|--------|------|-----------|
| Has many | [Entity B] | 1:N | CASCADE |
| Belongs to | [Entity C] | N:1 | RESTRICT |
| Has many through | [Entity D] | N:M | CASCADE |

### Migration Scripts

**Up Migration:**
```sql
-- Migration: create_[table_name]
-- Created: [Date]

CREATE TYPE [status_enum] AS ENUM ('pending', 'active', 'archived');

CREATE TABLE [table_name] (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    field_name VARCHAR(255) NOT NULL,
    status [status_enum] NOT NULL DEFAULT 'pending',
    foreign_id UUID NOT NULL REFERENCES [other_table](id),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE INDEX idx_[table]_field ON [table_name](field_name);
CREATE INDEX idx_[table]_status_created ON [table_name](status, created_at);
CREATE INDEX idx_[table]_foreign ON [table_name](foreign_id);

-- Trigger for updated_at
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON [table_name]
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

**Down Migration:**
```sql
-- Rollback: create_[table_name]

DROP TABLE IF EXISTS [table_name];
DROP TYPE IF EXISTS [status_enum];
```

---

## Implementation Approach

### Algorithm: [Name]

**Purpose:** [What this algorithm accomplishes]

**Complexity:** O([time]) time, O([space]) space

**Pseudocode:**
```
function processRequest(input):
    // Step 1: Validation
    validate(input) or throw ValidationError

    // Step 2: Fetch dependencies
    dependencies = fetchFromCacheOrDB(input.id)

    // Step 3: Business logic
    result = applyBusinessRules(input, dependencies)

    // Step 4: Persist changes
    transaction:
        save(result)
        updateRelated(result)

    // Step 5: Side effects
    emitEvent('resource.updated', result)
    invalidateCache(input.id)

    // Step 6: Return
    return formatResponse(result)
```

**Key Considerations:**
| Consideration | How We Handle It |
|---------------|------------------|
| [Concurrency] | [Use optimistic locking with version field] |
| [Idempotency] | [Use request ID for deduplication] |
| [Partial failure] | [Use saga pattern with compensation] |

### Design Patterns Used

| Pattern | Location | Purpose |
|---------|----------|---------|
| Repository | Data access layer | Decouple business logic from persistence |
| Factory | Object creation | Encapsulate complex instantiation |
| Strategy | [Feature] | Allow swappable algorithms |
| Observer | Events | Decouple components via events |
| Circuit Breaker | External calls | Handle external service failures |

### Sequence Diagram

```
Client          API Gateway      Service         Database        Cache
  │                  │              │                │              │
  │─── Request ─────▶│              │                │              │
  │                  │─── Auth ────▶│                │              │
  │                  │              │─── Check ─────▶│              │
  │                  │              │◀── Hit/Miss ───│              │
  │                  │              │                │              │
  │                  │              │─── Query ──────────────────▶│ (cache miss)
  │                  │              │◀── Data ───────────────────│
  │                  │              │                │              │
  │                  │              │─── Update ─────────────────▶│
  │                  │              │◀── ACK ────────────────────│
  │                  │◀── Response─│                │              │
  │◀── Response ─────│              │                │              │
```

---

## Testing Strategy

### Unit Tests

| Component | What to Test | Coverage Target |
|-----------|--------------|-----------------|
| [Service] | Business logic, edge cases | 90%+ |
| [Repository] | Query construction, mapping | 85%+ |
| [Validators] | All validation rules | 100% |
| [Transformers] | Data transformation | 90%+ |

### Integration Tests

| Test Area | Scope | Dependencies |
|-----------|-------|--------------|
| API endpoints | Request/response flow | Test database |
| Database operations | CRUD, transactions | Test database |
| External services | Contract compliance | Mock services |
| Event handling | Publish/subscribe | Test queue |

### E2E Tests

| Scenario | Steps | Expected Outcome |
|----------|-------|------------------|
| [Happy path flow] | [Step-by-step] | [Success state] |
| [Error flow] | [Step-by-step] | [Error handled gracefully] |

### Test Data Strategy

| Data Type | Source | Refresh |
|-----------|--------|---------|
| Seed data | Fixtures | Each test run |
| Generated data | Factories | Per test |
| Production samples | Anonymized exports | Weekly |

---

## Performance Considerations

### Targets

| Metric | Target | Measurement | Alert Threshold |
|--------|--------|-------------|-----------------|
| API Response Time | < 200ms p95 | APM | > 500ms p95 |
| Database Query | < 50ms p95 | Query logging | > 100ms p95 |
| Throughput | 1000 req/s | Load testing | < 500 req/s |
| Error Rate | < 0.1% | Error tracking | > 1% |
| CPU Utilization | < 70% | Infrastructure | > 85% |
| Memory Usage | < 80% | Infrastructure | > 90% |

### Caching Strategy

| Data | Cache Location | TTL | Invalidation |
|------|----------------|-----|--------------|
| [Frequently read data] | Redis | 5 minutes | On update |
| [Static config] | In-memory | 1 hour | On deploy |
| [Session data] | Redis | 30 minutes | On logout |
| [API responses] | CDN | 1 minute | Cache-Control headers |

### Database Optimization

| Optimization | Implementation | Expected Impact |
|--------------|----------------|-----------------|
| Connection pooling | [Pool size: 20, min: 5] | Reduce connection overhead |
| Query optimization | [Specific indexes] | < 50ms query time |
| Read replicas | [N replicas] | Scale read traffic |
| Partitioning | [Strategy] | Manage large tables |

### Async Processing

| Operation | Why Async | Queue | Timeout |
|-----------|-----------|-------|---------|
| [Email sending] | External API latency | emails | 30s |
| [Report generation] | CPU intensive | reports | 5m |
| [Webhook delivery] | Unreliable endpoints | webhooks | 10s |

---

## Security Considerations

### Authentication

| Aspect | Implementation |
|--------|----------------|
| Method | [JWT / OAuth2 / API Key] |
| Token Location | [Authorization header / Cookie] |
| Token Lifetime | [Access: 15m, Refresh: 7d] |
| Token Storage | [HttpOnly cookie / Secure storage] |
| Rotation | [On refresh / On suspicious activity] |

### Authorization

| Aspect | Implementation |
|--------|----------------|
| Model | [RBAC / ABAC / Policy-based] |
| Enforcement Point | [API Gateway / Service layer] |
| Permission Granularity | [Resource-level / Field-level] |

**Permission Matrix:**

| Role | Create | Read | Update | Delete | Admin |
|------|--------|------|--------|--------|-------|
| User | Own | Own | Own | Own | No |
| Manager | Team | Team | Team | Team | No |
| Admin | All | All | All | All | Yes |

### Data Protection

| Data Type | At Rest | In Transit | Notes |
|-----------|---------|------------|-------|
| PII | AES-256 | TLS 1.3 | Encrypted columns |
| Credentials | bcrypt/argon2 | TLS 1.3 | Never logged |
| API Keys | SHA-256 hash | TLS 1.3 | Show once on creation |
| Sessions | N/A | TLS 1.3 | Redis with encryption |

### Input Validation

| Input Type | Validation | Sanitization |
|------------|------------|--------------|
| Text fields | Max length, pattern | HTML escape |
| Numbers | Range, type | Type coercion |
| File uploads | Type, size, scan | Rename, isolate |
| URLs | Allowlist domains | URL encode |

### Security Checklist

- [ ] OWASP Top 10 addressed
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output encoding)
- [ ] CSRF protection (tokens)
- [ ] Rate limiting implemented
- [ ] Audit logging for sensitive operations
- [ ] Secrets management (no hardcoded credentials)
- [ ] Dependency vulnerability scanning
- [ ] Security headers configured

---

## Observability

### Logging

| Log Level | When to Use | Example |
|-----------|-------------|---------|
| ERROR | Unexpected failures | Unhandled exception, external service down |
| WARN | Recoverable issues | Retry succeeded, deprecated API used |
| INFO | Business events | User action, state change |
| DEBUG | Development details | Request/response bodies, timing |

**Structured Log Format:**
```json
{
  "timestamp": "ISO8601",
  "level": "INFO",
  "service": "service-name",
  "trace_id": "abc123",
  "span_id": "def456",
  "message": "User created",
  "context": {
    "user_id": "uuid",
    "action": "create",
    "duration_ms": 45
  }
}
```

### Metrics

| Metric | Type | Labels | Alert |
|--------|------|--------|-------|
| `api_requests_total` | Counter | method, path, status | Error rate > 1% |
| `api_request_duration_seconds` | Histogram | method, path | p95 > 500ms |
| `db_query_duration_seconds` | Histogram | query_type | p95 > 100ms |
| `cache_hits_total` | Counter | cache_name | Hit rate < 80% |
| `queue_depth` | Gauge | queue_name | Depth > 1000 |

### Tracing

| Span | Parent | Attributes |
|------|--------|------------|
| HTTP Request | Root | method, path, status |
| Database Query | HTTP Request | query, duration |
| Cache Lookup | HTTP Request | cache_name, hit |
| External Call | HTTP Request | service, endpoint |

### Alerting

| Alert | Condition | Severity | Action |
|-------|-----------|----------|--------|
| High Error Rate | > 1% errors for 5m | Critical | Page oncall |
| High Latency | p95 > 500ms for 5m | Warning | Notify channel |
| Service Down | No requests for 2m | Critical | Page oncall |
| Database Slow | p95 > 100ms for 10m | Warning | Notify channel |

---

## Migration & Rollout

### Migration Steps

| Step | Action | Validation | Rollback |
|------|--------|------------|----------|
| 1 | [Database migration] | [Verify schema] | [Down migration] |
| 2 | [Deploy new version] | [Health checks] | [Deploy previous] |
| 3 | [Enable feature flag] | [Smoke tests] | [Disable flag] |
| 4 | [Data backfill] | [Verify counts] | [Delete backfilled] |

### Database Migrations

**Pre-deployment migrations (backward compatible):**
```sql
-- Add new nullable column
ALTER TABLE [table] ADD COLUMN new_field VARCHAR(255);

-- Create new table
CREATE TABLE [new_table] (...);

-- Add index concurrently
CREATE INDEX CONCURRENTLY idx_new ON [table](field);
```

**Post-deployment migrations (cleanup):**
```sql
-- Remove old column (after code no longer uses it)
ALTER TABLE [table] DROP COLUMN old_field;

-- Drop old table
DROP TABLE [old_table];
```

### Feature Flags

| Flag | Description | Default | Rollout |
|------|-------------|---------|---------|
| `feature_[name]_enabled` | Enable new [feature] | false | Percentage |
| `feature_[name]_v2` | Use v2 implementation | false | User segment |

### Rollout Plan

| Phase | Target | Duration | Success Criteria | Rollback Trigger |
|-------|--------|----------|------------------|------------------|
| 0 | Internal only | 2 days | No errors | Any P0 bug |
| 1 | 5% of users | 3 days | Error rate < 0.1% | Error rate > 0.5% |
| 2 | 25% of users | 3 days | No regression | Error rate > 0.3% |
| 3 | 50% of users | 2 days | Performance stable | p95 latency increase |
| 4 | 100% of users | - | All metrics green | - |

### Rollback Plan

**Automated rollback triggers:**
- Error rate > [X]% for [Y] minutes
- p95 latency > [X]ms for [Y] minutes
- Health check failures

**Manual rollback steps:**
1. Disable feature flag
2. Deploy previous version
3. Run down migrations (if safe)
4. Verify system stability
5. Notify stakeholders

---

## Dependencies & Risks

### External Dependencies

| Dependency | Type | SLA | Fallback |
|------------|------|-----|----------|
| [Service name] | Internal | 99.9% | [Cache/Queue] |
| [Third-party API] | External | 99.5% | [Graceful degradation] |
| [Database] | Internal | 99.99% | [Read replica] |

### Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| [External API downtime] | Medium | High | Circuit breaker, queue |
| [Data inconsistency] | Low | High | Transactions, idempotency |
| [Performance degradation] | Medium | Medium | Caching, async processing |
| [Security breach] | Low | Critical | Encryption, audit logs |

---

## Open Questions

| Question | Owner | Due Date | Status |
|----------|-------|----------|--------|
| [Question 1] | [Name] | [Date] | Open/Resolved |
| [Question 2] | [Name] | [Date] | Open/Resolved |

---

## Appendix

### Glossary

| Term | Definition |
|------|------------|
| [Term] | [Definition] |

### References

- [Link to PRD]
- [Link to Feature Spec]
- [Link to related documentation]
- [Link to external resources]

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | [Date] | [Name] | Initial draft |
| 1.1 | [Date] | [Name] | [What changed] |
```

---

## Template Usage Notes

### Required Sections

For ALL technical specs:
- Document Info
- System Overview (problem, solution, decisions)
- Component Architecture
- API Design (for services)
- Data Model (for data changes)
- Testing Strategy
- Security Considerations
- Migration & Rollout

### Optional Sections (based on scope)

- Implementation Approach (for complex algorithms)
- Performance Considerations (for performance-critical features)
- Observability (for new services)
- Dependencies & Risks (for external integrations)

### Section Depth Guidelines

| Project Size | Recommended Depth |
|--------------|-------------------|
| Small (< 1 week) | Overview, API, Data Model, Testing |
| Medium (1-4 weeks) | All required sections |
| Large (> 1 month) | All sections, detailed appendices |

### Quick Tips

1. **Diagrams over paragraphs**: A good diagram replaces 500 words
2. **Be specific**: "< 200ms p95" not "fast"
3. **Show your work**: Include rationale for decisions
4. **Plan for failure**: Every external call can fail
5. **Think about migration**: How do we get from here to there?
6. **Security is not optional**: Address it explicitly
