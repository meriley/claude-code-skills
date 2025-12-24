# Plan: PRD and TDD Document Violations Fix

## Summary

Reviewed `chat-tracker-prd.md` (PRD) and `tdd-implementation.md` (TDD) using skill-based review criteria. Found **3 critical**, **10 major**, and **4 minor** violations requiring fixes.

---

## Document Locations

- **PRD:** `/home/mriley/projects/chat-tracker/docs/chat-tracker-prd.md`
- **TDD:** `/home/mriley/projects/chat-tracker/docs/tdd-implementation.md`

---

## PRD Review Findings

### Status: APPROVE WITH CHANGES

| Section | Rating | Notes |
|---------|--------|-------|
| Problem Statement | Adequate | Exists but lacks evidence/research |
| User Stories | Adequate | Good format, but generic "user" type |
| Acceptance Criteria | Strong | Mostly testable, specific values |
| Scope | Adequate | Goals/Non-Goals exist, lacks rationale |
| Success Metrics | Weak | No baselines, measurement methods unclear |

### PRD Violations

| # | Severity | Location | Issue | Fix |
|---|----------|----------|-------|-----|
| P1 | MAJOR | Missing | No stakeholders section | Add Section 1.1: Stakeholders with roles |
| P2 | MAJOR | Section 6 | Generic "user" in all stories | Define personas (e.g., "relationship tracker", "content creator") |
| P3 | MAJOR | Section 2 | No evidence/research for problem | Add research links or user feedback |
| P4 | MAJOR | Section 10 | Dependencies lack owners | Add dependency table with owners/status |
| P5 | MAJOR | Section 13 | Metrics lack baselines | Add current baseline for each metric |
| P6 | MAJOR | Section 13 | Measurement method unclear | Specify how each metric is measured |
| P7 | MINOR | Section 4 | Out-of-scope lacks rationale | Add brief reason for each exclusion |

---

## TDD Review Findings

### Status: NEEDS REVISION

| Section | Rating | Notes |
|---------|--------|-------|
| Test Philosophy | Strong | Clear TDD approach |
| Test Stack | Strong | Comprehensive tooling |
| Test Structure | Strong | Well-organized phases |
| Parser Tests | Strong | Thorough coverage |
| Storage Tests | Adequate | Good integration tests |
| Security Tests | **Missing** | No security testing section |
| Performance Tests | **Missing** | No performance testing section |
| Operational Tests | **Missing** | No operational testing section |

### TDD Violations

| # | Severity | Location | Issue | Fix |
|---|----------|----------|-------|-----|
| T1 | CRITICAL | Missing | No security testing section | Add Phase 7: Security Tests |
| T2 | CRITICAL | Missing | No input validation tests | Add tests for sanitization, injection prevention |
| T3 | CRITICAL | Missing | No authentication tests | Add tests for MCP auth, API auth |
| T4 | MAJOR | Missing | No performance testing section | Add Phase 8: Performance Tests |
| T5 | MAJOR | Missing | No load testing approach | Add load test specifications |
| T6 | MAJOR | Missing | No operational testing | Add health check, logging, metrics tests |
| T7 | MAJOR | Section 4-6 | Error handling tests incomplete | Add error/edge case tests per component |
| T8 | MAJOR | Missing | No migration testing | Add database migration rollback tests |
| T9 | MINOR | Missing | No failure mode tests | Add circuit breaker, timeout tests |
| T10 | MINOR | Section 2.2 | Coverage target only 80% | Align with CLAUDE.md requirement (90%+) |

---

## Implementation Plan

### Phase 1: Fix PRD Violations (P1-P7)

**File:** `docs/chat-tracker-prd.md`

1. **Add Stakeholders Section** (after Executive Summary)
   ```markdown
   ## 1.1 Stakeholders
   | Role | Name | Responsibility |
   |------|------|----------------|
   | Product Owner | Mark | Requirements, prioritization |
   | Engineering Lead | TBD | Technical decisions |
   | User Researcher | TBD | Validation |
   ```

2. **Define User Personas** (new Section 5.1)
   - Persona 1: "Relationship Tracker" - personal conversation analysis
   - Persona 2: "Content Creator" - OnlyFans message management
   - Update all user stories to reference specific personas

3. **Add Evidence to Problem Statement**
   - Add user quotes or pain points
   - Reference comparable solutions and gaps

4. **Create Dependencies Table** (Section 10.1)
   ```markdown
   | Dependency | Owner | Status | Required By |
   |------------|-------|--------|-------------|
   | Ollama Runtime | Infra | Available | Phase 1 |
   | PostgreSQL | Infra | Available | Phase 1 |
   | Qdrant | Infra | Available | Phase 1 |
   ```

5. **Enhance Success Metrics**
   - Add baseline column
   - Add measurement method column
   - Example: "Search Relevance | Current: N/A (new system) | Target: >80% | Measured by: Manual review of 100 sample queries"

6. **Add Rationale to Non-Goals**
   - Example: "Real-time sync - Out of scope due to API rate limits and privacy concerns"

### Phase 2: Fix TDD Violations (T1-T10)

**File:** `docs/tdd-implementation.md`

1. **Add Security Testing Section** (new Section 7)
   ```markdown
   ## 7. Phase 7: Security Layer Tests

   ### 7.1 Input Validation
   - Test HTML sanitization
   - Test SQL injection prevention
   - Test XSS prevention in stored content

   ### 7.2 Authentication
   - Test MCP server authentication
   - Test API key validation

   ### 7.3 Authorization
   - Test resource access controls
   ```

2. **Add Performance Testing Section** (new Section 8)
   ```markdown
   ## 8. Phase 8: Performance Tests

   ### 8.1 Latency Tests
   - Search endpoint < 500ms (p95)
   - Ingest 10k messages < 5 minutes

   ### 8.2 Load Tests
   - Concurrent search queries
   - Bulk ingestion performance
   ```

3. **Add Operational Testing Section** (new Section 9)
   ```markdown
   ## 9. Phase 9: Operational Tests

   ### 9.1 Health Checks
   - Test /health endpoint
   - Test dependency health (Qdrant, Postgres, Ollama)

   ### 9.2 Logging
   - Verify structured log output
   - Test log levels

   ### 9.3 Metrics
   - Test Prometheus endpoint
   ```

4. **Add Migration Testing** (new Section 10)
   ```markdown
   ## 10. Migration Tests

   ### 10.1 Schema Migrations
   - Test forward migration
   - Test rollback migration
   - Test data preservation
   ```

5. **Enhance Error Handling Tests**
   - Add error tests to each parser section
   - Add timeout handling tests
   - Add network failure tests

6. **Update Coverage Target**
   - Change "Minimum 80% target" to "Minimum 90% unit test coverage (per CLAUDE.md requirements)"

---

## Files to Modify

1. `/home/mriley/projects/chat-tracker/docs/chat-tracker-prd.md`
   - Add stakeholders section
   - Add personas section
   - Enhance problem statement
   - Add dependencies table
   - Enhance success metrics
   - Add rationale to non-goals

2. `/home/mriley/projects/chat-tracker/docs/tdd-implementation.md`
   - Add security testing section (Phase 7)
   - Add performance testing section (Phase 8)
   - Add operational testing section (Phase 9)
   - Add migration testing section (Phase 10)
   - Enhance error handling tests
   - Update coverage target to 90%

---

## Effort Estimate

| Task | Complexity |
|------|------------|
| PRD fixes (P1-P7) | Low - mostly additive content |
| TDD security tests (T1-T3) | Medium - new test specifications |
| TDD performance tests (T4-T5) | Medium - new test specifications |
| TDD operational tests (T6) | Low - standard patterns |
| TDD error/migration tests (T7-T8) | Medium - distributed across sections |
| TDD minor fixes (T9-T10) | Low - quick updates |

**Total: ~2 hours of document updates**
