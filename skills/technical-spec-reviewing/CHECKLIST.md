# Technical Spec Review Checklist

Comprehensive checklist for reviewing technical specifications.

---

## Quick Review (5 minutes)

Use for initial assessment:

- [ ] System overview with problem/solution
- [ ] Component architecture diagram exists
- [ ] APIs documented with request/response
- [ ] Data model defined
- [ ] Security section exists
- [ ] Migration plan included

**If 2+ items unchecked:** Flag for revision before deep review.

---

## Complete Review Checklist

### 1. System Overview

**Problem Statement (Severity: BLOCKER/CRITICAL)**
- [ ] Technical problem clearly stated [BLOCKER if missing]
- [ ] Explains why existing solutions don't work [CRITICAL]
- [ ] Scope of the problem defined [MAJOR]

**Solution (Severity: CRITICAL/MAJOR)**
- [ ] High-level approach described [CRITICAL]
- [ ] Solution addresses stated problem [BLOCKER]
- [ ] Approach is feasible with current tech stack [CRITICAL]

**Design Decisions (Severity: CRITICAL/MAJOR)**
- [ ] Key decisions documented [CRITICAL]
- [ ] Rationale provided for each decision [CRITICAL]
- [ ] Alternatives considered [MAJOR]
- [ ] Trade-offs acknowledged [MAJOR]

**Scope (Severity: MAJOR)**
- [ ] In-scope items listed
- [ ] Out-of-scope items with reasoning
- [ ] Scope aligns with requirements

---

### 2. Component Architecture

**Diagram Quality (Severity: CRITICAL/MAJOR)**
- [ ] Architecture diagram present [CRITICAL]
- [ ] All components shown [CRITICAL]
- [ ] Data flow arrows indicate direction [MAJOR]
- [ ] External systems clearly marked [MAJOR]

**Component Definition (Severity: CRITICAL)**
For each component:
- [ ] Responsibility clearly defined
- [ ] Inputs documented
- [ ] Outputs documented
- [ ] Dependencies listed

**Architecture Principles (Severity: CRITICAL/MAJOR)**
- [ ] Single responsibility per component [MAJOR]
- [ ] Loose coupling between components [CRITICAL]
- [ ] Clear boundaries [CRITICAL]
- [ ] No circular dependencies [BLOCKER]

**Scalability (Severity: CRITICAL/MAJOR)**
- [ ] Horizontal scaling considered [CRITICAL for high-traffic]
- [ ] Stateless design where possible [MAJOR]
- [ ] Bottlenecks identified [CRITICAL]
- [ ] Scaling strategy defined [MAJOR]

**Reliability (Severity: CRITICAL)**
- [ ] Single points of failure identified
- [ ] Redundancy planned for critical paths
- [ ] Failure modes documented
- [ ] Graceful degradation strategy

---

### 3. API Design

**Endpoint Coverage (Severity: BLOCKER/CRITICAL)**
- [ ] All endpoints listed [BLOCKER]
- [ ] HTTP methods appropriate [CRITICAL]
- [ ] URL structure follows conventions [MAJOR]
- [ ] Versioning strategy defined [MAJOR]

**Request Specification (Severity: CRITICAL)**
For each endpoint:
- [ ] Request schema documented
- [ ] All parameters listed with types
- [ ] Required vs optional marked
- [ ] Validation rules specified
- [ ] Example request provided

**Response Specification (Severity: CRITICAL)**
For each endpoint:
- [ ] Success response schema
- [ ] Response codes listed
- [ ] Error responses with codes
- [ ] Example responses provided

**Error Handling (Severity: CRITICAL/MAJOR)**
- [ ] Error code catalog exists [CRITICAL]
- [ ] Error messages user-friendly [MAJOR]
- [ ] Resolution guidance provided [MAJOR]
- [ ] All failure scenarios covered [CRITICAL]

**API Security (Severity: BLOCKER/CRITICAL)**
- [ ] Authentication required defined [BLOCKER]
- [ ] Authorization requirements per endpoint [CRITICAL]
- [ ] Rate limiting defined [CRITICAL]
- [ ] CORS policy (if applicable) [MAJOR]

**API Best Practices (Severity: MAJOR)**
- [ ] Pagination for list endpoints
- [ ] Filtering/sorting documented
- [ ] Idempotency for mutations
- [ ] Request tracing (correlation IDs)

---

### 4. Data Model

**Entity Definition (Severity: BLOCKER/CRITICAL)**
- [ ] All entities defined [BLOCKER]
- [ ] Table names specified [CRITICAL]
- [ ] All columns documented [CRITICAL]
- [ ] Data types specified [CRITICAL]
- [ ] Constraints defined [MAJOR]

**Relationships (Severity: CRITICAL/MAJOR)**
- [ ] Entity relationships documented [CRITICAL]
- [ ] Foreign keys defined [CRITICAL]
- [ ] Cardinality specified (1:1, 1:N, N:M) [MAJOR]
- [ ] Cascade behavior defined [MAJOR]

**Indexing Strategy (Severity: CRITICAL/MAJOR)**
- [ ] Indexes defined [CRITICAL]
- [ ] Index rationale provided [MAJOR]
- [ ] Covers common query patterns [CRITICAL]
- [ ] No over-indexing [MINOR]

**Data Lifecycle (Severity: MAJOR)**
- [ ] Data retention policy
- [ ] Archival strategy
- [ ] Soft vs hard delete decision
- [ ] GDPR/compliance considerations

**Migration (Severity: CRITICAL)**
- [ ] Up migration scripts
- [ ] Down migration scripts (rollback)
- [ ] Migration is backward compatible
- [ ] Data backfill strategy (if needed)

---

### 5. Implementation Approach

**Algorithm Design (Severity: MAJOR)**
- [ ] Key algorithms described
- [ ] Pseudocode or flow provided
- [ ] Complexity analyzed (time/space)
- [ ] Edge cases identified

**Design Patterns (Severity: MAJOR)**
- [ ] Patterns identified and justified
- [ ] Consistent with codebase
- [ ] Not over-engineered

**Concurrency (Severity: CRITICAL)**
- [ ] Race conditions identified
- [ ] Locking strategy (if needed)
- [ ] Idempotency guarantees
- [ ] Eventual consistency handled

---

### 6. Testing Strategy

**Test Coverage (Severity: CRITICAL/MAJOR)**
- [ ] Unit test scope defined [CRITICAL]
- [ ] Integration test approach [CRITICAL]
- [ ] E2E test scenarios [MAJOR]
- [ ] Coverage targets set [MAJOR]

**Test Data (Severity: MAJOR)**
- [ ] Test data strategy defined
- [ ] Fixtures/factories planned
- [ ] Production data handling

**Performance Testing (Severity: MAJOR)**
- [ ] Load testing approach
- [ ] Expected results documented
- [ ] Breaking point identification

---

### 7. Performance

**Targets (Severity: CRITICAL)**
- [ ] Latency targets (p50, p95, p99) [CRITICAL]
- [ ] Throughput targets [CRITICAL]
- [ ] Resource limits (CPU, memory) [MAJOR]
- [ ] Measurement method defined [MAJOR]

**Caching (Severity: MAJOR)**
- [ ] What to cache identified
- [ ] Cache location (Redis, in-memory, CDN)
- [ ] TTL values specified
- [ ] Invalidation strategy
- [ ] Cache hit ratio expectations

**Database Optimization (Severity: CRITICAL/MAJOR)**
- [ ] Query optimization planned [CRITICAL]
- [ ] Connection pooling configured [MAJOR]
- [ ] Read replicas (if needed) [MAJOR]
- [ ] Query analysis planned [MAJOR]

**Async Processing (Severity: MAJOR)**
- [ ] Long operations identified
- [ ] Queue strategy defined
- [ ] Timeout values set
- [ ] Retry policy defined

---

### 8. Security

**Authentication (Severity: BLOCKER)**
- [ ] Auth mechanism specified [BLOCKER]
- [ ] Token management defined [CRITICAL]
- [ ] Session handling (if applicable) [CRITICAL]
- [ ] Refresh token strategy [MAJOR]

**Authorization (Severity: BLOCKER/CRITICAL)**
- [ ] Auth model (RBAC/ABAC) defined [BLOCKER]
- [ ] Permission matrix documented [CRITICAL]
- [ ] Enforcement points identified [CRITICAL]
- [ ] Admin access controlled [MAJOR]

**Data Protection (Severity: BLOCKER/CRITICAL)**
- [ ] Encryption at rest [CRITICAL for PII]
- [ ] Encryption in transit (TLS) [BLOCKER]
- [ ] Sensitive field handling [CRITICAL]
- [ ] Key management [MAJOR]

**Input Validation (Severity: BLOCKER/CRITICAL)**
- [ ] All inputs validated [BLOCKER]
- [ ] Validation rules documented [CRITICAL]
- [ ] Sanitization approach [CRITICAL]
- [ ] File upload security (if applicable) [BLOCKER]

**OWASP Top 10 (Severity: CRITICAL)**
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] CSRF protection
- [ ] Broken authentication addressed
- [ ] Security misconfiguration avoided
- [ ] Sensitive data exposure prevented
- [ ] XXE prevention
- [ ] Broken access control addressed
- [ ] Security logging
- [ ] SSRF prevention

**Secrets Management (Severity: BLOCKER)**
- [ ] No hardcoded secrets [BLOCKER]
- [ ] Secrets storage defined [CRITICAL]
- [ ] Rotation strategy [MAJOR]

---

### 9. Observability

**Logging (Severity: CRITICAL/MAJOR)**
- [ ] Log levels defined [CRITICAL]
- [ ] Structured logging format [MAJOR]
- [ ] What to log documented [MAJOR]
- [ ] PII not logged [BLOCKER]

**Metrics (Severity: CRITICAL/MAJOR)**
- [ ] Key metrics identified [CRITICAL]
- [ ] Metric types (counter, gauge, histogram) [MAJOR]
- [ ] Dashboard requirements [MAJOR]

**Alerting (Severity: CRITICAL/MAJOR)**
- [ ] Alert conditions defined [CRITICAL]
- [ ] Severity levels [MAJOR]
- [ ] Escalation path [MAJOR]
- [ ] Alert thresholds [MAJOR]

**Tracing (Severity: MAJOR)**
- [ ] Distributed tracing planned
- [ ] Span structure defined
- [ ] Correlation ID propagation

---

### 10. Operations

**Deployment (Severity: CRITICAL)**
- [ ] Deployment strategy defined [CRITICAL]
- [ ] Environment configuration [CRITICAL]
- [ ] Infrastructure requirements [MAJOR]
- [ ] CI/CD integration [MAJOR]

**Health Checks (Severity: MAJOR)**
- [ ] Liveness probe defined
- [ ] Readiness probe defined
- [ ] Dependency health checks

**Runbook Items (Severity: MAJOR)**
- [ ] Common issues documented
- [ ] Troubleshooting steps
- [ ] Recovery procedures

---

### 11. Migration & Rollout

**Migration Steps (Severity: CRITICAL)**
- [ ] Steps clearly ordered [CRITICAL]
- [ ] Each step validated [CRITICAL]
- [ ] Dependencies identified [MAJOR]
- [ ] Estimated duration [MAJOR]

**Rollback Plan (Severity: BLOCKER/CRITICAL)**
- [ ] Rollback steps documented [BLOCKER]
- [ ] Automated triggers defined [CRITICAL]
- [ ] Data rollback considered [CRITICAL]
- [ ] Time to rollback estimated [MAJOR]

**Feature Flags (Severity: MAJOR)**
- [ ] Flags defined for gradual rollout
- [ ] Flag default values
- [ ] Cleanup plan for flags

**Rollout Phases (Severity: MAJOR)**
- [ ] Phases defined (internal, beta, GA)
- [ ] Success criteria per phase
- [ ] Percentage rollout plan
- [ ] Monitoring per phase

---

### 12. Dependencies & Risks

**Dependencies (Severity: CRITICAL/MAJOR)**
- [ ] Internal dependencies listed [CRITICAL]
- [ ] External dependencies listed [CRITICAL]
- [ ] SLA/availability documented [MAJOR]
- [ ] Fallback strategies [MAJOR]

**Risks (Severity: MAJOR)**
- [ ] Risks identified
- [ ] Probability assessed
- [ ] Impact evaluated
- [ ] Mitigations planned

---

## Review Decision Matrix

| Blockers | Critical | Major | Decision |
|----------|----------|-------|----------|
| 0 | 0 | 0-3 | APPROVE |
| 0 | 0-1 | 4-6 | APPROVE WITH CHANGES |
| 0 | 2-3 | Any | NEEDS REVISION |
| 1+ | Any | Any | MAJOR REVISION |

---

## Quick Reference Card

### Must Have (Blockers if Missing)
- System overview with problem/solution
- Component architecture with responsibilities
- API documentation with error responses
- Security (auth, authorization, encryption)
- Rollback plan

### Should Have (Critical if Missing)
- Design decision rationale
- Performance targets with measurement
- Input validation strategy
- Migration plan with steps
- Observability (logging, metrics)

### Good to Have (Major if Missing)
- Scalability strategy
- Caching approach
- Feature flags for rollout
- Alerting thresholds
- Runbook items

### Nice to Have (Minor)
- Alternative approaches considered
- Additional examples
- Capacity planning details
- Chaos testing approach

---

## Section-Specific Deep Dives

### Security Deep Dive

When reviewing security-critical specs:

```markdown
Security Audit Checklist:
□ Threat model documented
□ Trust boundaries identified
□ Attack vectors considered
□ Data classification defined
□ Compliance requirements met
□ Third-party security review needed?
□ Penetration testing planned
```

### Performance Deep Dive

When reviewing performance-critical specs:

```markdown
Performance Audit Checklist:
□ Current baseline measured
□ Target improvement quantified
□ Bottleneck analysis done
□ Optimization approaches compared
□ Trade-offs documented
□ Monitoring plan for validation
□ Rollback if degradation
```

### Migration Deep Dive

When reviewing complex migrations:

```markdown
Migration Audit Checklist:
□ Zero-downtime possible?
□ Data integrity verification
□ Parallel run period planned
□ Cutover procedure documented
□ Communication plan
□ Support plan during migration
□ Success verification criteria
```

---

## Common Issues by Section

### Architecture Issues

| Issue | Symptom | Fix |
|-------|---------|-----|
| God component | One component does everything | Split responsibilities |
| Circular dependencies | A → B → C → A | Introduce abstraction layer |
| Missing boundaries | Components share DB tables | Define clear data ownership |
| Tight coupling | Changes cascade across components | Use interfaces/events |

### API Issues

| Issue | Symptom | Fix |
|-------|---------|-----|
| Chatty API | Many calls for one operation | Add batch endpoint |
| Missing versioning | Breaking changes unclear | Add version strategy |
| Incomplete errors | "Error occurred" | Error catalog with codes |
| No pagination | Unbounded lists | Add pagination parameters |

### Security Issues

| Issue | Symptom | Fix |
|-------|---------|-----|
| Auth bypass | Some endpoints unprotected | Add auth to all endpoints |
| Overpermission | Users can access others' data | Add resource-level authz |
| Injection risk | User input to queries | Parameterized queries |
| Secret exposure | Credentials in code | Use secrets manager |

### Performance Issues

| Issue | Symptom | Fix |
|-------|---------|-----|
| N+1 queries | Loop with DB calls | Batch queries, caching |
| No caching | Same data fetched repeatedly | Add cache layer |
| Sync blocking | API waits for slow ops | Make async |
| Missing indexes | Slow queries | Add appropriate indexes |
