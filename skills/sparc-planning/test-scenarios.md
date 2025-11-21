---
title: SPARC Planning Test Scenarios
purpose: Validate that sparc-planning skill improves Claude's implementation planning compared to baseline
---

# SPARC Planning Test Scenarios

## Overview

These test scenarios validate that the sparc-planning skill helps Claude create better implementation plans compared to baseline (ad-hoc planning). Each scenario includes:

- **Setup**: Feature requirements and context
- **Expected Behavior**: What Claude should produce with the skill
- **Success Criteria**: Measurable plan quality metrics
- **Validation Method**: How to assess plan completeness and usefulness

---

## Scenario 1: Plan Small Feature (< 8 hours)

### Setup
**Context:** Existing Go web service needs a new API endpoint for health checks

**Requirements:**
- GET `/health` endpoint
- Returns JSON with status, uptime, version
- Should check database connectivity
- Return 200 if healthy, 503 if unhealthy

**Estimated Complexity:** 4-6 hours of work

**Baseline Expectation (No Skill):**
- Creates ad-hoc task list without structure
- Misses security or testing considerations
- No clear success criteria
- Skips dependency analysis
- No performance considerations

### Expected Behavior (With sparc-planning skill)

1. **Invokes check-history** - Gathers context about existing codebase patterns
2. **Gathers requirements** - Asks clarifying questions about:
   - What constitutes "healthy"? (DB only, or other services?)
   - Authentication required?
   - Rate limiting needed?
   - Monitoring/alerting setup?
3. **Creates lightweight SPARC plan** (adapted for small feature):
   - **Specification**: Brief requirements (1 paragraph)
   - **Pseudocode**: Simple handler logic
   - **Architecture**: Component list (handler, DB check, response model)
   - **Refinement**: Standard testing/security checklist
   - **Completion**: Basic completion criteria
4. **Generates ranked task list** with 4-6 tasks
5. **Identifies dependencies**: Database connection pool, existing models
6. **Security check**: Authentication requirements, rate limiting
7. **Performance target**: < 50ms response time

### Success Criteria

**Plan Completeness (MUST PASS):**
- ✅ All 5 SPARC phases present (even if brief)
- ✅ Specification includes success criteria
- ✅ Pseudocode shows handler logic
- ✅ Architecture lists components
- ✅ Task list has 4-6 actionable tasks
- ✅ Dependencies identified
- ✅ Security considerations documented
- ✅ Performance target defined

**Plan Quality (SHOULD PASS):**
- ✅ Tasks are ordered logically (foundation → core → testing)
- ✅ Each task has estimate (hours)
- ✅ Critical path identified
- ✅ Testing strategy included (unit + integration)
- ✅ Completion checklist is clear

**Appropriate Scope (MUST PASS):**
- ✅ Plan is concise (2-4 pages, not 20 pages)
- ✅ Doesn't over-engineer (no complex architecture for simple endpoint)
- ✅ Focuses on essentials, not edge cases

### Validation Method

**Automated Checks:**
```bash
# Check all 5 SPARC phases present
for phase in "Specification" "Pseudocode" "Architecture" "Refinement" "Completion"; do
    grep -q "## $phase" plan.md && echo "✅ $phase phase present" || echo "❌ Missing $phase"
done

# Check task count (should be 4-6 for small feature)
task_count=$(grep -c "^\[ \]" plan.md)
[[ $task_count -ge 4 && $task_count -le 8 ]] && echo "✅ Appropriate task count ($task_count)" || echo "⚠️  Task count unusual ($task_count)"

# Check for critical sections
grep -q "Success Criteria" plan.md && echo "✅ Success criteria defined" || echo "❌ No success criteria"
grep -q "Dependencies" plan.md && echo "✅ Dependencies identified" || echo "❌ No dependencies"
grep -q "Security" plan.md && echo "✅ Security considered" || echo "❌ No security section"
grep -q "Performance" plan.md && echo "✅ Performance target" || echo "❌ No performance target"
```

**Manual Review Checklist:**
- [ ] Specification answers: What, Why, Who, Success criteria
- [ ] Pseudocode is readable and covers main logic
- [ ] Architecture lists all needed components (handler, checker, model)
- [ ] Tasks are specific and actionable (not vague)
- [ ] Security considerations appropriate for endpoint type
- [ ] Performance target is reasonable (< 50ms for health check)
- [ ] Plan could be handed to another developer and implemented

### Expected Results

**Baseline (No Skill):**
- ⚠️ 30% create structured plan
- ❌ 50% miss security considerations
- ❌ 60% miss performance targets
- ❌ 70% have vague task descriptions
- ⏱️ Planning time: 5-10 minutes
- ⏱️ Implementation time: 6-8 hours (mistakes, rework)

**With sparc-planning Skill:**
- ✅ 95% create structured 5-phase plan
- ✅ 90% include security considerations
- ✅ 85% define performance targets
- ✅ 90% have specific, actionable tasks
- ⏱️ Planning time: 8-12 minutes (more thorough)
- ⏱️ Implementation time: 4-5 hours (fewer mistakes, less rework)

**Improvement:**
- +65 percentage points plan completeness
- 20-25% less implementation time (plan prevents mistakes)
- Higher quality outcome

---

## Scenario 2: Plan Medium Feature (8-40 hours)

### Setup
**Context:** E-commerce application needs user authentication system

**Requirements:**
- User registration with email verification
- Login with JWT tokens
- Password reset flow
- Session management
- OAuth2 integration (Google, GitHub)
- Rate limiting
- Audit logging

**Estimated Complexity:** 24-32 hours of work

**Baseline Expectation (No Skill):**
- Creates incomplete task list
- Misses critical security considerations (token expiry, refresh flow)
- No architecture design (just "build auth")
- Underestimates complexity
- No clear phases or milestones
- Missing dependencies (email service, Redis for sessions)

### Expected Behavior (With sparc-planning skill)

1. **Invokes check-history** - Checks for existing auth patterns in codebase
2. **Gathers requirements** - Extensive clarifying questions:
   - Password requirements? (complexity, expiry)
   - Token lifetime? (access vs refresh)
   - Multi-device support?
   - Existing user data to migrate?
   - Compliance requirements? (GDPR, SOC2)
3. **Creates full SPARC plan**:
   - **Specification**: Detailed functional and non-functional requirements
   - **Pseudocode**: Auth flow algorithms (register, login, refresh, reset)
   - **Architecture**: Component diagram, data models, technology choices
   - **Refinement**: Security review checklist, performance optimization plan
   - **Completion**: Comprehensive completion criteria, deployment plan
4. **Generates ranked task list** with 15-25 tasks organized in phases
5. **Identifies dependencies** and blockers:
   - Email service (SendGrid/SES)
   - Redis for session storage
   - Database schema migration
   - JWT library and key management
6. **Creates security plan**: Threat model, OWASP Top 10 checklist
7. **Creates performance plan**: Response time targets, load testing plan
8. **Risk assessment**: High-risk items and mitigation strategies

### Success Criteria

**Plan Completeness (MUST PASS):**
- ✅ All 5 SPARC phases with detailed content
- ✅ Specification covers functional + non-functional requirements
- ✅ Pseudocode for all major workflows (register, login, refresh, reset)
- ✅ Architecture includes:
  - Component breakdown (5-8 components)
  - Data models (User, Session, RefreshToken)
  - Technology choices with rationale
  - Security architecture (encryption, token signing)
  - Performance architecture (caching strategy)
- ✅ Task list has 15-25 tasks organized in 3-5 phases
- ✅ Dependencies clearly identified (external services, libraries)
- ✅ Security plan with specific checkpoints
- ✅ Performance plan with measurable targets

**Plan Quality (MUST PASS):**
- ✅ Tasks organized by logical phases (Foundation → Core → Advanced → Testing)
- ✅ Each task has:
  - Clear description
  - Time estimate
  - Dependencies
  - Owner/assignee
- ✅ Dependency graph shows critical path
- ✅ Potential blockers identified with mitigation
- ✅ Security checklist covers OWASP Top 10
- ✅ Performance targets are specific (< 100ms auth, < 10ms token validation)

**Appropriate Detail Level (MUST PASS):**
- ✅ Not too brief (has sufficient detail to implement)
- ✅ Not too verbose (doesn't specify every line of code)
- ✅ Focuses on architecture decisions, not implementation minutiae
- ✅ Plan is 8-15 pages (substantial but readable)

### Validation Method

**Comprehensive Checklist:**
```bash
# SPARC Phase Completeness
grep -q "## Specification" plan.md && grep -A 20 "## Specification" plan.md | grep -q "Functional Requirements" && echo "✅ Spec has functional reqs"
grep -q "## Specification" plan.md && grep -A 20 "## Specification" plan.md | grep -q "Non-Functional Requirements" && echo "✅ Spec has non-functional reqs"
grep -q "## Pseudocode" plan.md && echo "✅ Pseudocode phase present"
grep -q "## Architecture" plan.md && grep -A 30 "## Architecture" plan.md | grep -q "Component" && echo "✅ Architecture has components"
grep -q "## Architecture" plan.md && grep -A 30 "## Architecture" plan.md | grep -q "Data Model" && echo "✅ Architecture has data models"
grep -q "## Refinement" plan.md && echo "✅ Refinement phase present"
grep -q "## Completion" plan.md && echo "✅ Completion phase present"

# Task Organization
grep -c "^### Phase [0-9]" plan.md  # Should be 3-5 phases
grep -c "^\[ \]" plan.md  # Should be 15-25 tasks

# Security Plan
grep -q "## Security" plan.md && echo "✅ Security plan present"
grep -A 50 "## Security" plan.md | grep -q "OWASP" && echo "✅ OWASP mentioned"
grep -A 50 "## Security" plan.md | grep -q "authentication\|authorization\|encryption" && echo "✅ Security topics covered"

# Performance Plan
grep -q "## Performance" plan.md && echo "✅ Performance plan present"
grep -A 30 "## Performance" plan.md | grep -qE "[0-9]+ms" && echo "✅ Performance targets quantified"

# Dependency Tracking
grep -q "## Dependencies\|## Potential Blockers" plan.md && echo "✅ Dependencies identified"
```

**Expert Review Questions:**
- [ ] Could a competent developer implement this without significant clarification?
- [ ] Are security considerations appropriate for an auth system?
- [ ] Does architecture address scalability and performance?
- [ ] Are all major workflows covered? (register, login, logout, reset, refresh, OAuth)
- [ ] Is error handling strategy clear?
- [ ] Are external dependencies (email, Redis) documented?
- [ ] Does plan address data migration if needed?
- [ ] Is monitoring/observability included?

### Expected Results

**Baseline (No Skill):**
- ⚠️ 20% create structured 5-phase plan
- ❌ 40% miss critical security considerations
- ❌ 50% have incomplete architecture (no data models)
- ❌ 60% underestimate complexity (list 8-12 tasks for 30-hour feature)
- ❌ 70% miss external dependencies
- ⏱️ Planning time: 15-30 minutes (rushed)
- ⏱️ Implementation time: 40-50 hours (rework, security fixes)
- 💰 Risk: High (security vulnerabilities discovered in production)

**With sparc-planning Skill:**
- ✅ 90% create comprehensive 5-phase plan
- ✅ 95% include thorough security considerations
- ✅ 85% have complete architecture with data models
- ✅ 90% have realistic task breakdown (15-25 tasks)
- ✅ 95% identify all external dependencies
- ⏱️ Planning time: 60-90 minutes (thorough)
- ⏱️ Implementation time: 28-35 hours (fewer surprises, less rework)
- 💰 Risk: Low (security addressed in design)

**Improvement:**
- +70 percentage points plan completeness
- 20-30% less implementation time
- Significantly lower security risk
- Higher confidence in delivery

---

## Scenario 3: Plan Large Feature (> 40 hours)

### Setup
**Context:** Microservices architecture needs distributed tracing and observability platform

**Requirements:**
- Distributed tracing across 12 microservices (Go, Node.js, Python)
- Centralized logging aggregation
- Metrics collection and dashboards
- Service dependency mapping
- Performance profiling
- Alert management
- On-call rotation integration

**Estimated Complexity:** 80-120 hours of work (2-3 engineers for 3-4 weeks)

**Baseline Expectation (No Skill):**
- Overwhelming scope, unclear where to start
- Missing critical phases (e.g., service instrumentation strategy)
- No clear milestones or incremental delivery
- Underestimates integration complexity
- Missing non-functional requirements (data retention, query performance)
- No rollout strategy (big bang approach, risky)

### Expected Behavior (With sparc-planning skill)

1. **Invokes check-history** - Checks existing observability setup, service inventory
2. **Gathers requirements** - Deep dive into:
   - Current pain points (what's missing today?)
   - Data retention requirements
   - Query performance requirements
   - Budget constraints
   - Team expertise (OpenTelemetry, Jaeger, Prometheus, etc.)
   - Existing tools to integrate with
3. **Creates extensive SPARC plan** with milestone-based delivery:
   - **Specification**: Comprehensive requirements document
     - Functional: Tracing, logging, metrics, alerting, dashboards
     - Non-functional: Performance, scalability, reliability, cost
     - Constraints: Budget, timeline, team size, expertise
     - Success criteria: Measurable observability improvements
   - **Pseudocode**: Instrumentation patterns for each language/framework
   - **Architecture**: Multi-view architecture
     - System context: How observability platform fits in infrastructure
     - Component view: Collectors, storage, query engine, UI
     - Deployment view: Where components run, scaling strategy
     - Data flow: How traces/logs/metrics flow through system
     - Technology decisions: OpenTelemetry, Jaeger, Prometheus, Grafana (with rationale)
   - **Refinement**: Comprehensive quality plan
     - Security: Access control, data privacy, audit logs
     - Performance: Query optimization, data aggregation, retention policies
     - Reliability: High availability, disaster recovery
     - Cost optimization: Data sampling, retention tiers
   - **Completion**: Multi-milestone completion criteria
     - Milestone 1: Core tracing (3 services instrumented)
     - Milestone 2: Full service coverage
     - Milestone 3: Metrics and dashboards
     - Milestone 4: Alerting and on-call integration
4. **Generates phased task list** with 40-60 tasks organized in 5-8 phases
5. **Dependency graph** with critical path analysis
6. **Risk assessment** matrix (likelihood × impact)
7. **Rollout plan**: Incremental delivery, canary deployments, rollback procedures
8. **Team allocation**: Which engineer owns which phase

### Success Criteria

**Plan Comprehensiveness (MUST PASS):**
- ✅ All 5 SPARC phases with extensive detail
- ✅ Specification covers:
  - Functional requirements (all 7 requirement areas)
  - Non-functional requirements (performance, scale, cost, reliability)
  - Constraints and assumptions
  - Success criteria (measurable)
- ✅ Pseudocode/patterns for:
  - Instrumentation (each language/framework)
  - Data collection
  - Query patterns
- ✅ Architecture includes:
  - Multiple views (context, component, deployment, data flow)
  - Technology decisions with rationale
  - Scalability analysis (data volume projections)
  - Cost analysis (infrastructure costs)
- ✅ Refinement plan includes:
  - Security review plan
  - Performance testing plan
  - Reliability testing (chaos engineering)
  - Cost optimization strategy
- ✅ Completion criteria:
  - Multi-milestone structure (4+ milestones)
  - Each milestone is independently valuable
  - Clear definition of done for each milestone

**Task Organization (MUST PASS):**
- ✅ 40-60 tasks organized in 5-8 logical phases
- ✅ Each phase is 1-2 weeks of work
- ✅ Phases build incrementally (can ship after each phase)
- ✅ Each task has:
  - Clear description
  - Time estimate
  - Dependencies (references other tasks)
  - Owner/team assignment
  - Priority (Critical, High, Medium, Low)
- ✅ Dependency graph shows:
  - Critical path (longest path to completion)
  - Parallelizable work
  - Bottlenecks

**Risk Management (MUST PASS):**
- ✅ Risk assessment for major risks (5-10 risks identified)
- ✅ Each risk has:
  - Likelihood (High/Medium/Low)
  - Impact (High/Medium/Low)
  - Mitigation strategy
  - Contingency plan
- ✅ Rollout plan includes:
  - Incremental delivery strategy
  - Canary deployment approach
  - Rollback procedures
  - Monitoring during rollout

**Appropriate Detail (MUST PASS):**
- ✅ Plan is substantial (20-40 pages) but organized
- ✅ Has table of contents for navigation
- ✅ Architecture diagrams (even if ASCII)
- ✅ Doesn't specify every line of code (stays architectural)
- ✅ Balances detail vs readability

### Validation Method

**Comprehensive Quality Assessment:**
```bash
# Document structure
grep -q "^# Table of Contents" plan.md && echo "✅ Has table of contents"
page_count=$(wc -w plan.md | awk '{print int($1/300)}')  # ~300 words per page
[[ $page_count -ge 20 && $page_count -le 50 ]] && echo "✅ Appropriate length ($page_count pages)" || echo "⚠️  Length unusual ($page_count pages)"

# SPARC completeness
for phase in "Specification" "Pseudocode" "Architecture" "Refinement" "Completion"; do
    lines=$(sed -n "/## $phase/,/## [A-Z]/p" plan.md | wc -l)
    [[ $lines -gt 50 ]] && echo "✅ $phase phase substantial ($lines lines)" || echo "⚠️  $phase phase brief ($lines lines)"
done

# Requirements coverage
grep -q "Functional Requirements" plan.md && echo "✅ Functional requirements"
grep -q "Non-Functional Requirements" plan.md && echo "✅ Non-functional requirements"
grep -q "Constraints" plan.md && echo "✅ Constraints documented"
grep -q "Success Criteria" plan.md && echo "✅ Success criteria defined"

# Architecture views
grep -q "Component" plan.md && echo "✅ Component view"
grep -q "Deployment\|Infrastructure" plan.md && echo "✅ Deployment view"
grep -q "Data Flow\|Data Model" plan.md && echo "✅ Data flow"
grep -A 50 "Architecture" plan.md | grep -qE "Jaeger|Prometheus|Grafana|OpenTelemetry" && echo "✅ Technology choices documented"

# Task organization
phase_count=$(grep -c "^### Phase [0-9]" plan.md)
[[ $phase_count -ge 5 && $phase_count -le 10 ]] && echo "✅ Appropriate phase count ($phase_count)" || echo "⚠️  Unusual phase count ($phase_count)"

task_count=$(grep -c "^\[ \]" plan.md)
[[ $task_count -ge 40 && $task_count -le 70 ]] && echo "✅ Appropriate task count ($task_count)" || echo "⚠️  Unusual task count ($task_count)"

# Risk management
grep -q "## Risk" plan.md && echo "✅ Risk section present"
grep -A 100 "## Risk" plan.md | grep -qE "High.*Medium.*Low|Likelihood.*Impact" && echo "✅ Risk assessment structured"
grep -q "Mitigation\|Contingency" plan.md && echo "✅ Risk mitigation documented"

# Milestones
milestone_count=$(grep -cE "Milestone [0-9]" plan.md)
[[ $milestone_count -ge 3 ]] && echo "✅ Multi-milestone plan ($milestone_count milestones)" || echo "⚠️  Should have 3+ milestones"
```

**Expert Review Rubric (Score 1-5 each):**

**Planning Depth:**
- [ ] Specification completeness (all requirements captured)
- [ ] Architecture detail (multiple views, technology choices justified)
- [ ] Task breakdown (realistic, well-organized)
- [ ] Risk assessment (comprehensive, actionable)
- [ ] Scoring: 4-5 = Excellent, 3 = Good, 1-2 = Needs Work

**Feasibility:**
- [ ] Can this plan actually be implemented?
- [ ] Are estimates realistic?
- [ ] Are dependencies accurate?
- [ ] Is rollout strategy sound?
- [ ] Scoring: 4-5 = Highly feasible, 3 = Feasible with adjustments, 1-2 = Not feasible

**Usability:**
- [ ] Can team pick up plan and execute?
- [ ] Is navigation easy (TOC, clear sections)?
- [ ] Are next steps clear?
- [ ] Is plan maintainable (can update as work progresses)?
- [ ] Scoring: 4-5 = Very usable, 3 = Usable, 1-2 = Hard to use

**Risk Management:**
- [ ] Are major risks identified?
- [ ] Do mitigation strategies make sense?
- [ ] Is incremental delivery plan sound?
- [ ] Are rollback procedures clear?
- [ ] Scoring: 4-5 = Strong risk management, 3 = Adequate, 1-2 = Risky

**Overall Grade: Average of 4 categories (Depth, Feasibility, Usability, Risk)**

### Expected Results

**Baseline (No Skill):**
- ⚠️ 10% create comprehensive 5-phase plan (most get overwhelmed)
- ❌ 30% have detailed architecture (usually missing key views)
- ❌ 40% break down into realistic tasks (usually 10-20 tasks for 100-hour project)
- ❌ 50% identify major risks
- ❌ 10% have incremental rollout plan (most plan big bang)
- ⏱️ Planning time: 2-4 hours (still incomplete)
- ⏱️ Implementation time: 120-180 hours (3-4x rework, integration issues)
- 💰 Risk: Very high (scope creep, missed requirements, cost overruns)
- 📉 Success rate: 40% (many fail or are scaled back)

**With sparc-planning Skill:**
- ✅ 85% create comprehensive 5-phase plan
- ✅ 90% have detailed multi-view architecture
- ✅ 85% have realistic task breakdown (40-60 tasks, phased)
- ✅ 90% identify and mitigate major risks
- ✅ 80% have incremental rollout plan
- ⏱️ Planning time: 4-8 hours (thorough, but worth it)
- ⏱️ Implementation time: 85-100 hours (fewer surprises, less rework)
- 💰 Risk: Low-Medium (manageable scope, clear milestones)
- 📉 Success rate: 85% (high confidence in delivery)

**Improvement:**
- +75 percentage points plan completeness
- 25-35% less implementation time
- 2-3x higher success rate
- Significantly better risk management
- Enables incremental delivery (partial value delivered sooner)

---

## Multi-Model Testing Plan

Test each scenario across Claude models to ensure skill is effective for all users:

### Haiku Testing
- **Expected:** May create briefer plans, focus on templates
- **Focus:** Verify all 5 SPARC phases present (even if concise)
- **Acceptable:** Less detailed architecture, fewer examples
- **Scenario recommendations:** Test Scenarios 1-2 (small/medium), Scenario 3 may be challenging

### Sonnet Testing
- **Expected:** Balanced depth and breadth
- **Focus:** Verify plan quality and feasibility
- **Acceptable:** All scenarios should work well
- **Scenario recommendations:** Test all 3 scenarios

### Opus Testing
- **Expected:** Most comprehensive plans, may add extra depth
- **Focus:** Verify doesn't over-engineer (stays appropriate for feature size)
- **Acceptable:** Richer examples, more thorough risk analysis
- **Scenario recommendations:** Test all 3 scenarios, especially Scenario 3

---

## Baseline Comparison Methodology

### Step 1: Baseline Test (No Skill)
1. Fresh Claude instance (no sparc-planning skill)
2. Provide scenario requirements
3. Ask: "Create an implementation plan for this feature"
4. Record time taken
5. Evaluate against success criteria
6. Score using validation methods

### Step 2: With Skill Test
1. Fresh Claude instance WITH sparc-planning skill
2. Provide same scenario requirements
3. Skill should auto-invoke (or explicitly invoke)
4. Record time taken
5. Evaluate against same success criteria
6. Score using same validation methods

### Step 3: Calculate Improvements
```
Plan Completeness = (Criteria Met / Total Criteria) × 100%
Time Efficiency = (Baseline Time - Skill Time) / Baseline Time × 100%
Implementation Time Savings = (Baseline Impl Time - Skill Impl Time) / Baseline Impl Time × 100%

Example Scenario 2:
Baseline: 12/20 criteria (60%), 25 min planning, 45 hr implementation
With Skill: 19/20 criteria (95%), 75 min planning, 30 hr implementation
Completeness: +35pp, Planning: -50 min, Implementation: +33% faster
```

### Step 4: Track Over Time
Record in table:

| Scenario | Model | Baseline | With Skill | Improvement | Impl Time Saved |
|----------|-------|----------|------------|-------------|-----------------|
| 1: Small | Sonnet | 60% | 92% | +32pp | 20% |
| 2: Medium | Sonnet | 40% | 88% | +48pp | 25% |
| 3: Large | Sonnet | 25% | 85% | +60pp | 30% |
| ... | ... | ... | ... | ... | ... |

---

## Success Metrics Summary

**sparc-planning skill is successful if:**

1. **Plan Completeness:** 80%+ of plans have all 5 SPARC phases with appropriate detail
2. **Task Quality:** 85%+ of plans have well-organized, realistic task breakdowns
3. **Risk Management:** 75%+ of plans identify major risks with mitigation strategies
4. **Architecture Quality:** 80%+ of medium/large plans have multi-view architecture
5. **Implementation Time Savings:** 20-30% reduction in implementation time due to better planning
6. **Success Rate:** 85%+ of planned features successfully delivered
7. **Consistency:** < 15% variance across models

**Overall Grade:**
- A: 85%+ on all metrics
- B: 75-84% on all metrics
- C: 65-74% on all metrics
- F: < 65% on any metric

---

## Notes for Testers

- **Fresh instances:** Always test with fresh Claude instances (no prior context)
- **Identical setup:** Use same scenario wording for baseline vs with-skill tests
- **Multiple runs:** Test 3-5 times per scenario for statistical validity
- **Real implementation:** If possible, actually implement the plan to measure implementation time and success rate
- **Document surprises:** Record any unexpected behaviors or edge cases
- **Measure value:** Track "Did this plan help?" vs "Was plan followed exactly?"

---

## Real-World Validation

Beyond test scenarios, validate with real projects:

### Retrospective Analysis
After completing projects, ask:
1. Did we follow the plan?
2. What parts of the plan were most valuable?
3. What was missing from the plan?
4. Did planning save implementation time?
5. Would we do this differently next time?

### Metrics to Track
- Planned vs actual implementation time
- Scope creep (features added that weren't planned)
- Bugs found in areas that were/weren't planned
- Team confidence scores before/after planning
- Stakeholder satisfaction with delivery

---

## Continuous Improvement

After each test cycle:
1. Identify which SPARC phases are frequently weak
2. Update sparc-planning skill to strengthen weak areas
3. Add new scenarios for emerging patterns (e.g., "Plan microservice migration")
4. Re-run tests to validate improvements
5. Update REFERENCE.md with lessons learned
6. Refine time estimates based on actual data

**Target:** 90%+ success rate across all scenarios by version 2.0.0

---

## Appendix: Example Scoring

### Scenario 2 Baseline vs With Skill

**Baseline Plan (No Skill):**
```
Task List:
1. Create user table
2. Implement registration
3. Implement login
4. Add JWT tokens
5. Add password reset
6. Add OAuth
7. Test everything

Total: 7 tasks for 30-hour feature (unrealistic)
Missing: Security plan, performance targets, dependencies
Score: 9/20 criteria (45%)
```

**With Skill Plan:**
```
SPARC Plan:
Specification: Functional + non-functional requirements, success criteria ✅
Pseudocode: Register, login, refresh, reset workflows ✅
Architecture: 7 components, data models, tech choices with rationale ✅
Refinement: Security checklist (OWASP), performance targets (< 100ms) ✅
Completion: Phase-based completion criteria ✅

Task List:
Phase 1: Foundation (DB, models) - 6 tasks, 8 hours
Phase 2: Core Auth (register, login) - 7 tasks, 10 hours
Phase 3: Advanced (OAuth, reset) - 5 tasks, 8 hours
Phase 4: Testing & Refinement - 4 tasks, 6 hours

Total: 22 tasks, 32 hours, phased delivery ✅

Dependencies: Email (SendGrid), Redis, JWT library ✅
Security: OWASP Top 10 checklist ✅
Performance: < 100ms login, < 10ms token validation ✅

Score: 19/20 criteria (95%)
```

**Improvement:** +50 percentage points, 3x more tasks (realistic), phased delivery, comprehensive security/performance plans
