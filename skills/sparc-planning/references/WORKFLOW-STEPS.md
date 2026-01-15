
### Step 1: Invoke check-history

Gather context about existing work:

```
Invoke: check-history skill
```

**Understand:**

- Recent related commits
- Existing patterns and conventions
- Previous similar implementations
- Current codebase structure

### Step 2: Gather Requirements

**Ask user clarifying questions:**

- What problem are we solving?
- What are the functional requirements?
- What are the non-functional requirements (performance, security, scale)?
- Are there any constraints (time, resources, compatibility)?
- What's the expected user/API interface?
- Are there any existing solutions to reference?

**Document user responses.**

### Step 3: Research Dependencies (If Needed)

If external libraries or unfamiliar patterns needed:

```
Invoke Context7 for library documentation
```

Research:

- Best practices for the technology
- Security considerations
- Performance characteristics
- Integration patterns

### Step 4: Create Phase 1 - Specification

Generate detailed specification document covering:

#### Functional Requirements

- Core features and capabilities
- User stories / use cases
- Input/output specifications
- Edge cases to handle
- Error scenarios

#### Non-Functional Requirements

- **Performance**: Response time, throughput, resource usage
- **Security**: Authentication, authorization, data protection, audit
- **Scalability**: Expected load, growth projections
- **Reliability**: Uptime requirements, error handling
- **Maintainability**: Code quality, documentation needs

#### Constraints

- Technology stack limitations
- Compatibility requirements
- Timeline and resource constraints
- Regulatory or compliance requirements

#### Success Criteria

- How will we know when this is complete?
- What metrics define success?
- What testing is required?

**See references/REFERENCE.md Section 1 for detailed specification template.**

### Step 5: Create Phase 2 - Pseudocode

Generate structured pseudocode for key algorithms and workflows:

#### Algorithm Pseudocode

```
function processUserAuthentication(credentials):
    1. Validate input format
       - Check username not empty
       - Check password meets requirements

    2. Query user from database
       - Handle user not found
       - Handle database errors

    3. Verify password
       - Use bcrypt comparison
       - Constant-time comparison to prevent timing attacks

    4. Generate session token
       - Create JWT with claims
       - Set appropriate expiry
       - Sign with secret key

    5. Return success response
       - Include token
       - Include user profile (safe fields only)
```

#### Component Interface Definitions

```
interface AuthService:
    method authenticate(username: string, password: string) -> Result<Session, AuthError>
    method validateToken(token: string) -> Result<User, ValidationError>
    method refreshToken(refreshToken: string) -> Result<Session, AuthError>
    method logout(sessionId: string) -> Result<void, Error>
```

**See references/REFERENCE.md Section 2 for pseudocode examples.**

### Step 6: Create Phase 3 - Architecture

Design the system structure:

#### Component Breakdown

- List all components/modules needed
- Define responsibilities of each component
- Identify external dependencies
- Note shared utilities

#### Architecture Patterns

- Which design patterns apply? (e.g., Repository, Factory, Strategy)
- Layered architecture (presentation, business, data)
- Separation of concerns
- Dependency injection approach

#### Data Models

```go
type User struct {
    ID           string    `json:"id"`
    Username     string    `json:"username"`
    PasswordHash string    `json:"-"` // Never expose in JSON
    Email        string    `json:"email"`
    CreatedAt    time.Time `json:"created_at"`
    UpdatedAt    time.Time `json:"updated_at"`
}

type Session struct {
    ID        string
    UserID    string
    Token     string
    ExpiresAt time.Time
}
```

#### Component Interactions

```
User Request → Handler → Validator → Service → Repository → Database
                   ↓          ↓          ↓          ↓
               Middleware  Schema   Business   Data Layer
```

#### Technology Choices

- Which libraries/frameworks to use?
- Why these choices? (performance, security, familiarity)
- Any alternatives considered?

#### Security Architecture

- Authentication mechanism
- Authorization approach
- Data encryption (at rest, in transit)
- Input validation strategy
- Audit logging plan

#### Performance Architecture

- Caching strategy
- Database indexing plan
- Query optimization approach
- Resource pooling

**See references/REFERENCE.md Section 3 for architecture templates.**

### Step 7: Create Phase 4 - Refinement Plan

Outline the iterative improvement process:

#### Code Quality Checks

- Linting requirements
- Code review checklist
- Refactoring opportunities
- Technical debt to address

#### Performance Optimization

- Profiling approach
- Bottleneck identification
- Optimization targets
- Benchmark requirements

#### Security Review

- Security scanning checklist
- Penetration testing plan
- Compliance verification
- Vulnerability remediation

#### Test Coverage Improvements

- Current coverage gaps
- Target coverage (90%+ unit, 100% E2E)
- Test cases to add
- Integration test scenarios

**See references/REFERENCE.md Section 4 for refinement checklist.**

### Step 8: Create Phase 5 - Completion Criteria

Define what "done" means:

#### Completion Checklist

- [ ] All functional requirements implemented
- [ ] All tests passing (90%+ unit coverage, 100% E2E pass)
- [ ] All linter issues resolved
- [ ] Security scan passed
- [ ] Performance requirements met
- [ ] Documentation complete
- [ ] Code reviewed and approved
- [ ] Deployed to staging environment
- [ ] User acceptance testing passed

#### Documentation Requirements

- API documentation
- User guide / README updates
- Inline code comments (why, not what)
- Architecture decision records

#### Deployment Plan

- Migration scripts (if needed)
- Rollback plan
- Monitoring setup
- Alert configuration

**See references/REFERENCE.md Section 5 for completion templates.**

### Step 9: Generate Ranked Task List

Break down implementation into ordered tasks:

```markdown
## Implementation Task List

### Phase 1: Foundation (Priority: CRITICAL)

1. [ ] Set up database schema for users table
   - Estimated: 2 hours
   - Dependencies: None
   - Owner: Pedro

2. [ ] Implement User model with validation
   - Estimated: 1 hour
   - Dependencies: Task 1
   - Owner: Pedro

3. [ ] Create database repository layer
   - Estimated: 3 hours
   - Dependencies: Task 2
   - Owner: Pedro

### Phase 2: Core Logic (Priority: HIGH)

4. [ ] Implement password hashing service
   - Estimated: 2 hours
   - Dependencies: Task 2
   - Owner: Pedro

5. [ ] Implement JWT token generation
   - Estimated: 2 hours
   - Dependencies: Task 2
   - Owner: Pedro

[... continue with all tasks ...]

### Phase 5: Testing & Refinement (Priority: MEDIUM)

15. [ ] Add unit tests for all services (target: 95%)
    - Estimated: 6 hours
    - Dependencies: Tasks 4-10
    - Owner: Pedro

16. [ ] Add integration tests for auth flow
    - Estimated: 4 hours
    - Dependencies: Tasks 11-14
    - Owner: Pedro
```

### Step 10: Identify Dependencies and Blockers

Create dependency graph:

```markdown
## Task Dependencies

Task 1 (Database schema)
└─> Task 2 (User model)
├─> Task 3 (Repository)
├─> Task 4 (Password hashing)
└─> Task 5 (JWT generation)
└─> Task 6 (Auth service)
└─> Task 7 (HTTP handlers)

## Potential Blockers

1. **Database access**: Need database credentials and connection
   - Risk: HIGH
   - Mitigation: Set up local Docker database

2. **JWT secret key**: Need secure key generation
   - Risk: MEDIUM
   - Mitigation: Use crypto/rand for generation

3. **External auth provider**: If integrating OAuth
   - Risk: LOW (optional feature)
   - Mitigation: Implement basic auth first
```

### Step 11: Create Security & Performance Plans

#### Security Plan

```markdown
## Security Checkpoints

### Design Phase

- [ ] Threat modeling completed
- [ ] Authentication mechanism reviewed
- [ ] Authorization strategy defined
- [ ] Data encryption plan verified

### Implementation Phase

- [ ] Input validation on all endpoints
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (proper escaping)
- [ ] CSRF protection (tokens)
- [ ] Rate limiting implemented

### Testing Phase

- [ ] Security scan passed (no secrets)
- [ ] Dependency vulnerabilities checked
- [ ] Penetration testing completed
- [ ] Security code review done
```

#### Performance Plan

```markdown
## Performance Targets

### Requirements

- Authentication: < 100ms p95
- Token validation: < 10ms p95
- Database queries: < 50ms p95
- Memory usage: < 50MB per request

### Measurement Points

1. After initial implementation (baseline)
2. After query optimization
3. After caching implementation
4. Before production deployment

### Optimization Strategy

1. Profile with pprof (Go) / clinic.js (Node)
2. Identify bottlenecks
3. Optimize database queries (indexes, query optimization)
4. Add caching (Redis) for frequent reads
5. Use connection pooling
6. Benchmark against targets
```

### Step 12: Document and Present Plan

Save all planning documents to disk (don't commit yet):

```
Create directory: docs/planning/<feature-name>/
Files:
- specification.md
- pseudocode.md
- architecture.md
- refinement-plan.md
- completion-checklist.md
- task-list.md
- security-plan.md
- performance-plan.md
```

Present summary to user:

```markdown
# Implementation Plan: JWT Authentication System

## Summary

Comprehensive authentication system with JWT tokens, including user management,
session handling, and security best practices.

## Phases

1. **Specification**: Complete (see specification.md)
2. **Pseudocode**: Complete (see pseudocode.md)
3. **Architecture**: Complete (see architecture.md)
4. **Refinement**: Planned (see refinement-plan.md)
5. **Completion**: Criteria defined (see completion-checklist.md)

## Task Breakdown

- Total tasks: 22
- Estimated time: 40 hours
- Critical path: 18 tasks (28 hours)

## Key Decisions

- Technology: Go with JWT tokens
- Database: PostgreSQL
- Caching: Redis for session storage
- Testing: 95% unit coverage target

## Security Considerations

- Bcrypt password hashing (cost factor: 12)
- JWT with RS256 signing
- Token expiry: 1 hour (access), 30 days (refresh)
- Rate limiting: 5 attempts per minute per IP

## Performance Targets

- Authentication: < 100ms p95
- Token validation: < 10ms p95

## Risks

1. Database performance (Mitigation: Connection pooling, indexes)
2. Token storage size (Mitigation: Redis with TTL)

## Next Steps

1. Review plan and confirm approach
2. Create branch: mriley/feat/jwt-authentication
3. Begin Phase 1: Database schema
4. Implement tasks in order from task-list.md

Plan documents saved to: docs/planning/jwt-authentication/

Ready to begin implementation?
```
