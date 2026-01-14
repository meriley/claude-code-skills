---
title: SPARC Planning Document Templates
---

# SPARC Planning Templates

Copy-paste ready templates for creating implementation plans using the SPARC framework.

## Table of Contents

1. [Complete Planning Document Template](#complete-planning-document-template)
2. [Specification Template](#specification-template)
3. [Task List Template](#task-list-template)
4. [Risk Assessment Matrix Template](#risk-assessment-matrix-template)
5. [Security Plan Template](#security-plan-template)
6. [Performance Plan Template](#performance-plan-template)

---

## Complete Planning Document Template

Use this for medium-to-large features (8-40+ hours of work).

```markdown
# Implementation Plan: [Feature Name]

**Date:** [YYYY-MM-DD]
**Author:** [Your Name]
**Estimated Effort:** [X-Y hours]
**Target Completion:** [Date or Sprint]

---

## Summary

[1-2 paragraphs describing the feature, its purpose, and key decisions]

---

## Phase 1: Specification

### Problem Statement
**What problem are we solving?**
- Current pain point: [Description]
- Impact of not solving: [Business/user impact]
- Expected benefit: [Value delivered]

### Functional Requirements

#### Core Features
1. **[Feature 1]**: [Description]
   - Input: [What data/parameters]
   - Processing: [What happens]
   - Output: [What's returned]
   - Edge cases: [How to handle unusual inputs]

2. **[Feature 2]**: [Description]
   - [Same structure as above]

### User Stories
- As a [user type], I want to [action], so that [benefit]
- As a [user type], I want to [action], so that [benefit]

### API/Interface Contract

#### Endpoints (if REST API)
```
POST /api/[resource]
Request:
{
  "field": "type"
}

Response (200):
{
  "result": "data"
}

Response (400):
{
  "error": "message"
}
```

#### Function Signatures (if library/package)
```language
function doSomething(param: Type): ReturnType
```

### Non-Functional Requirements

**Performance:**
- Response time: [< Xms pY]
- Throughput: [N requests/second]
- Resource usage: [< XMB memory]
- Database query time: [< Xms pY]

**Security:**
- Authentication: [Method]
- Authorization: [RBAC, permissions, etc.]
- Data encryption: [TLS 1.3 in transit, AES-256 at rest]
- Input validation: [Strategy]
- Audit logging: [What to log]

**Scalability:**
- Expected load: [N users/requests]
- Growth projection: [X% per year]
- Scaling strategy: [Horizontal/vertical, caching, etc.]

**Reliability:**
- Uptime requirement: [99.X%]
- Error handling strategy: [Fail fast, retry, fallback]
- Monitoring: [Key metrics]

### Constraints
- Technology stack: [What we must use]
- Compatibility requirements: [Existing systems, APIs]
- Timeline: [Hard deadlines]
- Resources: [Team size, budget]
- Regulatory/Compliance: [GDPR, SOC2, etc.]

### Success Criteria
- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]
- [ ] [Measurable criterion 3]

---

## Phase 2: Pseudocode

### Main Algorithm

```pseudocode
function mainWorkflow(input):
    1. Validate input
       - Check required fields
       - Check format/types
       - Return error if invalid

    2. Fetch dependencies
       - Query database for entity
       - Call external API if needed
       - Handle not found case

    3. Process data
       - Transform input
       - Apply business logic
       - Aggregate results

    4. Persist changes
       - Begin transaction
       - Update database
       - Commit or rollback

    5. Return result
       - Format response
       - Include metadata
       - Log success
```

### Component Interfaces

```pseudocode
interface ServiceA:
    method doAction(param: Type) -> Result<Data, Error>
    method validateInput(input: Type) -> Result<void, ValidationError>

interface ServiceB:
    method processData(data: Type) -> Result<Output, Error>
```

---

## Phase 3: Architecture

### Component Breakdown

**Components:**
1. **Component A**: [Responsibility]
   - Dependencies: [What it needs]
   - Provides: [What it exposes]

2. **Component B**: [Responsibility]
   - Dependencies: [What it needs]
   - Provides: [What it exposes]

[Continue for all components]

### Architecture Patterns
- **Pattern 1**: [e.g., Repository pattern for data access]
  - Rationale: [Why this pattern]
- **Pattern 2**: [e.g., Factory pattern for object creation]
  - Rationale: [Why this pattern]

### Data Models

```language
type Entity struct {
    ID           string    `json:"id"`
    Name         string    `json:"name"`
    CreatedAt    time.Time `json:"created_at"`
    UpdatedAt    time.Time `json:"updated_at"`
}
```

### Component Interactions

```
User Request → Handler → Validator → Service → Repository → Database
                   ↓          ↓          ↓          ↓
               Middleware  Schema   Business   Data Layer
```

### Technology Choices

**Technology A**: [Name and version]
- **Why:** [Rationale - performance, security, familiarity]
- **Alternatives considered:** [Other options and why not chosen]

**Technology B**: [Name and version]
- **Why:** [Rationale]
- **Alternatives considered:** [Other options]

### Security Architecture
- Authentication: [How users are authenticated]
- Authorization: [How permissions are checked]
- Data encryption: [At rest, in transit]
- Input validation: [Where and how]
- Audit logging: [What's logged, where]

### Performance Architecture
- Caching strategy: [What to cache, TTL, invalidation]
- Database indexing: [Which indexes needed]
- Query optimization: [N+1 prevention, batching]
- Resource pooling: [Connection pools, worker pools]

---

## Phase 4: Refinement Plan

### Code Quality
- Linting: [Tool and rules]
- Code review: [Process and checklist]
- Refactoring: [Technical debt to address]
- Documentation: [Inline comments, API docs]

### Performance Optimization
- Profiling: [Tool and approach]
- Bottleneck identification: [How to find]
- Optimization targets: [What to optimize]
- Benchmarks: [Performance goals]

### Security Review
- [ ] OWASP Top 10 checklist complete
- [ ] Dependency vulnerabilities scanned
- [ ] Authentication mechanism reviewed
- [ ] Authorization tested
- [ ] Input validation verified
- [ ] Secrets management reviewed
- [ ] Audit logging tested

### Test Coverage
- Unit tests: [Target: 90%+]
- Integration tests: [All integration points]
- E2E tests: [Critical user flows]
- Performance tests: [Load testing plan]

---

## Phase 5: Completion Criteria

### Completion Checklist
- [ ] All functional requirements implemented
- [ ] All tests passing (90%+ unit coverage, 100% E2E pass)
- [ ] All linter issues resolved
- [ ] Security scan passed
- [ ] Performance requirements met
- [ ] Documentation complete
- [ ] Code reviewed and approved
- [ ] Deployed to staging environment
- [ ] User acceptance testing passed
- [ ] Production deployment plan approved

### Documentation Requirements
- [ ] API documentation complete
- [ ] User guide updated
- [ ] README updated
- [ ] Architecture decision records created
- [ ] Runbook for operations

### Deployment Plan

**Pre-deployment:**
- [ ] Database migration scripts ready
- [ ] Configuration updates documented
- [ ] Rollback procedure tested
- [ ] Monitoring dashboards created
- [ ] Alerts configured

**Deployment steps:**
1. [Step 1 with validation]
2. [Step 2 with validation]
3. [Step 3 with validation]

**Post-deployment:**
- [ ] Smoke tests pass
- [ ] Metrics flowing
- [ ] Logs accessible
- [ ] No critical alerts
- [ ] Rollback plan ready

---

## Task Breakdown

### Phase 1: Foundation (Priority: CRITICAL)
**Duration:** [X hours]

1. [ ] **Task 1**: [Description]
   - **Estimated:** [X hours]
   - **Dependencies:** None
   - **Owner:** [Name]
   - **Validation:** [How to verify complete]

2. [ ] **Task 2**: [Description]
   - **Estimated:** [X hours]
   - **Dependencies:** Task 1
   - **Owner:** [Name]
   - **Validation:** [How to verify complete]

### Phase 2: Core Logic (Priority: HIGH)
**Duration:** [X hours]

3. [ ] **Task 3**: [Description]
   - **Estimated:** [X hours]
   - **Dependencies:** Task 2
   - **Owner:** [Name]
   - **Validation:** [How to verify complete]

[Continue with all tasks...]

---

## Dependency Graph

```
Task 1 (Foundation)
  └─> Task 2 (Data model)
       ├─> Task 3 (Service A)
       ├─> Task 4 (Service B)
       └─> Task 5 (Integration)
            └─> Task 6 (Testing)
```

**Critical Path:** Tasks 1 → 2 → 5 → 6 (estimated [X] hours)

---

## Risk Assessment

### Risk 1: [Risk Name]
- **Likelihood:** High / Medium / Low
- **Impact:** High / Medium / Low
- **Description:** [What could go wrong]
- **Mitigation:** [How to prevent]
- **Contingency:** [What to do if it happens]

### Risk 2: [Risk Name]
- **Likelihood:** High / Medium / Low
- **Impact:** High / Medium / Low
- **Description:** [What could go wrong]
- **Mitigation:** [How to prevent]
- **Contingency:** [What to do if it happens]

[Continue for all major risks...]

---

## Security Plan

### Threat Model
- **Threat 1:** [Type of attack]
  - **Attack vector:** [How]
  - **Impact:** [Damage if successful]
  - **Mitigation:** [Prevention strategy]

- **Threat 2:** [Type of attack]
  - **Attack vector:** [How]
  - **Impact:** [Damage if successful]
  - **Mitigation:** [Prevention strategy]

### Security Checkpoints

**Design Phase:**
- [ ] Threat modeling completed
- [ ] Authentication mechanism selected and reviewed
- [ ] Authorization strategy defined
- [ ] Data encryption plan verified

**Implementation Phase:**
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (proper escaping)
- [ ] CSRF protection (tokens)
- [ ] Rate limiting implemented

**Testing Phase:**
- [ ] Security scan passed (no secrets)
- [ ] Dependency vulnerabilities checked
- [ ] Penetration testing completed
- [ ] Security code review done

---

## Performance Plan

### Performance Targets

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| Response time | < Xms pY | API monitoring |
| Throughput | N req/sec | Load testing |
| Database query | < Xms pY | Query profiling |
| Memory usage | < XMB | Resource monitoring |

### Measurement Points
1. After initial implementation (baseline)
2. After query optimization
3. After caching implementation
4. Before production deployment

### Optimization Strategy
1. Profile with [tool]
2. Identify bottlenecks
3. Optimize [specific areas]
4. Benchmark against targets
5. Iterate until targets met

---

## Rollout Plan

### Incremental Delivery Strategy

**Milestone 1**: [MVP - Core functionality]
- **Scope:** [What's included]
- **Duration:** [X weeks]
- **Value:** [What users get]

**Milestone 2**: [Enhanced features]
- **Scope:** [What's added]
- **Duration:** [X weeks]
- **Value:** [Additional benefits]

**Milestone 3**: [Advanced features]
- **Scope:** [What's added]
- **Duration:** [X weeks]
- **Value:** [Full feature set]

### Canary Deployment

**Phase 1: Internal (1 week)**
- Deploy to internal environment
- Team testing only
- Monitor metrics closely
- Fix critical issues

**Phase 2: Beta (2 weeks)**
- Deploy to 5% of users
- Monitor error rates, performance
- Collect user feedback
- Iterate on issues

**Phase 3: Gradual Rollout (2 weeks)**
- Week 1: 25% of users
- Week 2: 50% of users
- Week 3: 100% of users

**Rollback Criteria:**
- Error rate > [X]%
- Performance degradation > [Y]%
- Critical bug discovered
- User feedback overwhelmingly negative

---

## Monitoring & Alerts

### Key Metrics
- **Metric 1:** [Name] - [What it measures]
  - **Target:** [Value]
  - **Alert threshold:** [When to alert]

- **Metric 2:** [Name] - [What it measures]
  - **Target:** [Value]
  - **Alert threshold:** [When to alert]

### Dashboards
- **Dashboard 1:** [Name] - [What it shows]
- **Dashboard 2:** [Name] - [What it shows]

### Alerts
- **Critical:** [Conditions that page on-call]
- **Warning:** [Conditions that notify team]
- **Info:** [Conditions that log only]

---

## Next Steps

1. **Review this plan** with stakeholders
2. **Get approval** on approach and timeline
3. **Create branch**: `mriley/feat/[feature-name]`
4. **Begin Phase 1**: [First task]
5. **Regular check-ins**: [Frequency]

---

**Plan documents saved to:** `docs/planning/[feature-name]/`

**Ready to begin implementation?**
```

---

## Specification Template

Use for documenting requirements in detail.

```markdown
# [Feature Name] Specification

**Date:** [YYYY-MM-DD]
**Status:** Draft / Approved / In Progress / Complete
**Owner:** [Name]

## Overview
[1-2 paragraphs describing the feature]

## Problem Statement
- **Current state:** [What exists today]
- **Pain points:** [What's broken or missing]
- **Impact:** [Cost of not solving]
- **Proposed solution:** [High-level approach]

## Functional Requirements

### Requirement 1: [Name]
- **Description:** [What it does]
- **Input:** [Data needed]
- **Processing:** [What happens]
- **Output:** [What's produced]
- **Success criteria:** [How to verify]
- **Edge cases:**
  - [Edge case 1 and handling]
  - [Edge case 2 and handling]

### Requirement 2: [Name]
[Same structure as above]

## Non-Functional Requirements

**Performance:**
- [Specific measurable targets]

**Security:**
- [Security requirements]

**Scalability:**
- [Scale expectations]

**Reliability:**
- [Uptime and error handling]

**Usability:**
- [User experience requirements]

## Constraints
- [Technical constraints]
- [Business constraints]
- [Timeline constraints]

## Success Criteria
- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]
- [ ] [Measurable criterion 3]

## Open Questions
- [ ] [Question 1 that needs answering]
- [ ] [Question 2 that needs answering]
```

---

## Task List Template

Use for breaking down work into actionable tasks.

```markdown
# [Feature Name] Task List

## Phase 1: [Phase Name] (Priority: CRITICAL/HIGH/MEDIUM)

### Task 1: [Task Name]
- **Description:** [What needs to be done]
- **Estimated time:** [X hours]
- **Dependencies:** None / Task N
- **Owner:** [Name]
- **Status:** Not Started / In Progress / Blocked / Complete
- **Validation:**
  - [ ] [How to verify complete - criterion 1]
  - [ ] [How to verify complete - criterion 2]

### Task 2: [Task Name]
[Same structure]

## Phase 2: [Phase Name] (Priority: HIGH/MEDIUM)

### Task 3: [Task Name]
[Same structure]

---

## Summary

- **Total tasks:** [N]
- **Estimated total time:** [X hours]
- **Critical path:** [Task numbers] ([X hours])
- **Parallel work:** [Task numbers that can run in parallel]
- **Dependencies:** [External dependencies that could block]
```

---

## Risk Assessment Matrix Template

Use for identifying and mitigating risks.

```markdown
# [Feature Name] Risk Assessment

| # | Risk | Likelihood | Impact | Score | Mitigation | Contingency | Owner |
|---|------|------------|--------|-------|------------|-------------|-------|
| 1 | [Risk name] | H/M/L | H/M/L | [1-9] | [Prevention] | [If it happens] | [Name] |
| 2 | [Risk name] | H/M/L | H/M/L | [1-9] | [Prevention] | [If it happens] | [Name] |

**Risk Score:** Likelihood × Impact (High=3, Medium=2, Low=1)

---

## Top Risks (Score ≥ 6)

### Risk 1: [Name] (Score: [N])
- **Description:** [Detailed description of risk]
- **Likelihood:** [High/Medium/Low] - [Why]
- **Impact:** [High/Medium/Low] - [What would happen]
- **Mitigation:**
  1. [Action to reduce likelihood]
  2. [Action to reduce impact]
- **Contingency:**
  1. [What to do if risk occurs]
  2. [Fallback plan]
- **Owner:** [Name]
- **Status:** [Not Started / In Progress / Mitigated]
```

---

## Security Plan Template

Use for planning security measures.

```markdown
# [Feature Name] Security Plan

## Threat Model

### Threat 1: [Attack Type]
- **Attack vector:** [How attacker might exploit]
- **Impact:** [Damage if successful]
- **Likelihood:** [High/Medium/Low]
- **Mitigation:** [How to prevent]

### Threat 2: [Attack Type]
[Same structure]

## Security Controls

### Authentication
- **Method:** [JWT, OAuth2, etc.]
- **Token lifetime:** [Duration]
- **Refresh strategy:** [How tokens are refreshed]

### Authorization
- **Model:** [RBAC, ABAC, etc.]
- **Permissions:** [List of permissions]
- **Enforcement:** [Where checks happen]

### Data Protection
- **At rest:** [Encryption method]
- **In transit:** [TLS version]
- **Sensitive fields:** [Which fields need extra protection]

### Input Validation
- **Strategy:** [Whitelist/schema validation]
- **Sanitization:** [How to clean input]
- **Rate limiting:** [Limits per endpoint]

### Audit Logging
- **What to log:** [Events to capture]
- **Retention:** [How long to keep]
- **Access:** [Who can view logs]

## OWASP Top 10 Checklist

- [ ] **A01:2021 – Broken Access Control:** [How addressed]
- [ ] **A02:2021 – Cryptographic Failures:** [How addressed]
- [ ] **A03:2021 – Injection:** [How addressed]
- [ ] **A04:2021 – Insecure Design:** [How addressed]
- [ ] **A05:2021 – Security Misconfiguration:** [How addressed]
- [ ] **A06:2021 – Vulnerable Components:** [How addressed]
- [ ] **A07:2021 – Authentication Failures:** [How addressed]
- [ ] **A08:2021 – Software and Data Integrity:** [How addressed]
- [ ] **A09:2021 – Security Logging Failures:** [How addressed]
- [ ] **A10:2021 – Server-Side Request Forgery:** [How addressed]

## Security Testing

### Testing Approach
- **Static analysis:** [Tool]
- **Dependency scanning:** [Tool]
- **Penetration testing:** [Scope and schedule]
- **Code review:** [Security-focused checklist]

### Test Cases
1. [ ] **Authentication bypass:** [Test description]
2. [ ] **Authorization bypass:** [Test description]
3. [ ] **SQL injection:** [Test description]
4. [ ] **XSS:** [Test description]
5. [ ] **CSRF:** [Test description]
```

---

## Performance Plan Template

Use for planning performance optimization.

```markdown
# [Feature Name] Performance Plan

## Performance Targets

| Metric | Target | Measurement | Tool |
|--------|--------|-------------|------|
| API response time | < Xms p95 | API monitoring | [Tool name] |
| Database query time | < Xms p95 | Query profiling | [Tool name] |
| Throughput | N req/sec | Load testing | [Tool name] |
| Memory usage | < XMB | Resource monitoring | [Tool name] |
| CPU usage | < X% | Resource monitoring | [Tool name] |

## Baseline Performance

| Metric | Current | Target | Gap |
|--------|---------|--------|-----|
| [Metric 1] | [Value] | [Target] | [Difference] |
| [Metric 2] | [Value] | [Target] | [Difference] |

## Optimization Strategy

### Phase 1: Profiling
- **Tool:** [pprof, clinic.js, etc.]
- **Approach:** [How to profile]
- **What to measure:** [Specific metrics]

### Phase 2: Bottleneck Identification
- **CPU hotspots:** [Where CPU time spent]
- **Memory allocations:** [Where memory allocated]
- **Database queries:** [Slow queries]
- **Network calls:** [External API latency]

### Phase 3: Optimization
1. **Database optimization:**
   - Add indexes: [Which tables/columns]
   - Query optimization: [N+1 prevention, batching]
   - Connection pooling: [Pool size]

2. **Caching:**
   - What to cache: [Data types]
   - Cache duration: [TTL]
   - Invalidation strategy: [How to invalidate]

3. **Code optimization:**
   - Algorithm improvements: [Where]
   - Resource pooling: [What to pool]
   - Async operations: [What to make async]

### Phase 4: Validation
- **Load testing:** [Scenario and tool]
- **Benchmark:** [How to measure]
- **Comparison:** [Before vs after]

## Monitoring

### Metrics to Track
- **Response time:** [p50, p95, p99]
- **Error rate:** [Percentage]
- **Throughput:** [Requests/second]
- **Resource usage:** [CPU, memory]

### Alerts
- **Critical:** Response time > [X]ms p95
- **Warning:** Response time > [Y]ms p95
- **Info:** Response time > [Z]ms p50
```

---

**Use these templates to jumpstart your planning. Customize based on project size and complexity.**
