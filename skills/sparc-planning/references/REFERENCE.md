---  
title: SPARC Framework Reference Guide
---

# SPARC Framework Detailed Reference

This reference provides detailed templates and examples for each phase of the SPARC framework.

## Table of Contents

1. [Specification Phase](#specification-phase)
2. [Pseudocode Phase](#pseudocode-phase)
3. [Architecture Phase](#architecture-phase)
4. [Refinement Phase](#refinement-phase)
5. [Completion Phase](#completion-phase)

---

## Specification Phase

### Purpose
Define WHAT needs to be built and WHY, without getting into HOW.

### Template

```markdown
# [Feature Name] Specification

## Overview
[1-2 paragraph description of the feature and its purpose]

## Problem Statement
What problem does this solve?
- Current pain point:
- Impact of not solving:
- Expected benefit:

## Functional Requirements

### Core Features
1. **[Feature 1]**: Description of what it does
   - Input: What data/parameters needed
   - Processing: What happens
   - Output: What's returned/displayed
   - Edge cases: How to handle unusual inputs

2. **[Feature 2]**: ...

### User Stories
- As a [user type], I want to [action], so that [benefit]
- As a [user type], I want to [action], so that [benefit]

### API/Interface Contract

#### REST Endpoints (if applicable)
```
POST /api/auth/login
Request:
{
  "username": "string",
  "password": "string"
}

Response (200):
{
  "token": "string",
  "expires_at": "timestamp",
  "user": { ... }
}

Response (401):
{
  "error": "Invalid credentials"
}
```

#### Function Signatures (if library/package)
```go
func Authenticate(username, password string) (*Session, error)
```

### Edge Cases and Error Handling
- What if input is empty?
- What if user doesn't exist?
- What if database is unavailable?
- What if service times out?
- What if data is malformed?

## Non-Functional Requirements

### Performance
- Response time: < 100ms p95
- Throughput: 1000 requests/second
- Resource usage: < 50MB memory per request
- Database query time: < 50ms p95

### Security
- Authentication: JWT with RS256
- Authorization: Role-based access control (RBAC)
- Data encryption: TLS 1.3 in transit, AES-256 at rest
- Input validation: Sanitize all user inputs
- Audit logging: Log all authentication attempts
- Secret management: Environment variables, no hardcoded secrets

### Scalability
- Expected load: 10,000 concurrent users
- Growth projection: 2x per year
- Horizontal scaling: Stateless service design
- Database: Connection pooling, read replicas

### Reliability
- Uptime target: 99.9% (43.8 minutes downtime/month)
- Error rate: < 0.1%
- Graceful degradation: Fallback mechanisms
- Circuit breakers: For external service calls

### Maintainability
- Code coverage: 90%+ unit tests, 100% E2E
- Documentation: API docs, architecture docs
- Code quality: Pass all linters, code review
- Monitoring: Metrics, logging, alerting

## Constraints

### Technical Constraints
- Must use Go 1.21+
- Must be compatible with PostgreSQL 14+
- Must support Redis for caching
- Must work with existing Docker infrastructure

### Business Constraints
- Timeline: 3 weeks
- Resources: 1 developer (mriley)
- Budget: No new tools/services

### Compatibility Constraints
- Must maintain backwards compatibility with v1 API
- Must support migration from existing auth system
- Must integrate with existing user database

## Success Criteria

### Definition of Done
- [ ] All functional requirements implemented
- [ ] All tests passing (coverage thresholds met)
- [ ] Security scan passed
- [ ] Performance requirements met
- [ ] Documentation complete
- [ ] Code reviewed and approved

### Acceptance Tests
1. User can log in with valid credentials
2. User cannot log in with invalid credentials
3. Token expires after specified duration
4. Refresh token generates new access token
5. Rate limiting prevents brute force attacks

### Metrics
- Authentication success rate: > 99%
- Average response time: < 50ms
- Error rate: < 0.1%
- User satisfaction: Positive feedback on speed and reliability

## Out of Scope (for this iteration)
- OAuth integration (future feature)
- Multi-factor authentication (future feature)
- Biometric authentication (out of scope)
- Password reset via email (separate feature)

## Dependencies
- PostgreSQL database (existing)
- Redis cache (needs setup)
- JWT library (github.com/golang-jwt/jwt)
- Bcrypt library (golang.org/x/crypto/bcrypt)

## Risks and Mitigation

### Technical Risks
1. **Database performance under load**
   - Risk: Medium
   - Impact: High
   - Mitigation: Connection pooling, query optimization, indexes

2. **JWT token size**
   - Risk: Low
   - Impact: Medium
   - Mitigation: Minimize claims, use short-lived tokens

### Business Risks
1. **Timeline pressure**
   - Risk: Medium
   - Impact: Medium
   - Mitigation: Start with MVP, iterate features

## References
- JWT Best Practices: https://...
- OWASP Authentication Guide: https://...
- Existing auth system: docs/old-auth.md
```

---

## Pseudocode Phase

### Purpose
Create high-level algorithm descriptions and logic flow without language-specific syntax.

### Template

```markdown
# [Feature Name] Pseudocode

## High-Level Flow

```
Main Authentication Flow:
1. Receive user credentials (username, password)
2. Validate input format
   - IF invalid: return 400 error
3. Query user from database
   - IF not found: return 401 error
   - IF database error: return 500 error
4. Verify password hash
   - IF mismatch: log attempt, return 401 error
5. Generate JWT token
   - Create token with user claims
   - Set expiration time
   - Sign with secret key
6. Store session in cache (Redis)
7. Return token and user profile
```

## Detailed Algorithm Pseudocode

### Algorithm 1: User Authentication

```
function authenticate(username, password):
    // Input validation
    if username is empty or password is empty:
        return Error("Invalid input: username and password required")
    
    if length(password) < 8:
        return Error("Password too short")
    
    // Database query
    user = database.query("SELECT * FROM users WHERE username = ?", username)
    if user is null:
        // Don't reveal whether user exists (security)
        log.info("Authentication failed: user not found", username)
        return Error("Invalid credentials")
    
    // Password verification (constant-time comparison)
    passwordMatch = bcrypt.compare(password, user.passwordHash)
    if not passwordMatch:
        log.warning("Authentication failed: invalid password", username)
        incrementFailedAttempts(username)
        
        // Rate limiting check
        if failedAttempts(username) > 5 in last 15 minutes:
            return Error("Too many failed attempts, try again later")
        
        return Error("Invalid credentials")
    
    // Generate JWT token
    token = generateJWT({
        userId: user.id,
        username: user.username,
        roles: user.roles,
        expiresIn: "1 hour"
    })
    
    refreshToken = generateRefreshToken({
        userId: user.id,
        expiresIn: "30 days"
    })
    
    // Store session in cache
    session = {
        userId: user.id,
        token: hash(token),
        createdAt: now(),
        expiresAt: now() + 1 hour
    }
    cache.set("session:" + user.id, session, ttl=1 hour)
    
    // Log successful authentication
    log.info("Authentication successful", username)
    
    // Return success response
    return {
        token: token,
        refreshToken: refreshToken,
        expiresAt: now() + 1 hour,
        user: {
            id: user.id,
            username: user.username,
            email: user.email
            // Don't return sensitive fields (passwordHash, etc.)
        }
    }
```

### Algorithm 2: Token Validation

```
function validateToken(token):
    // Parse token
    try:
        claims = jwt.parse(token, secretKey)
    catch JWTError as e:
        log.warning("Invalid token format", error=e)
        return Error("Invalid token")
    
    // Check expiration
    if claims.expiresAt < now():
        log.info("Token expired", userId=claims.userId)
        return Error("Token expired")
    
    // Verify token hasn't been revoked
    isRevoked = cache.exists("revoked:" + hash(token))
    if isRevoked:
        log.warning("Revoked token used", userId=claims.userId)
        return Error("Token revoked")
    
    // Verify session exists in cache
    session = cache.get("session:" + claims.userId)
    if session is null:
        log.warning("Session not found", userId=claims.userId)
        return Error("Session expired")
    
    // Verify token hash matches
    if session.token != hash(token):
        log.error("Token hash mismatch", userId=claims.userId)
        return Error("Invalid token")
    
    // Success - return user info
    user = database.query("SELECT * FROM users WHERE id = ?", claims.userId)
    return user
```

### Algorithm 3: Refresh Token

```
function refreshAccessToken(refreshToken):
    // Validate refresh token
    try:
        claims = jwt.parse(refreshToken, secretKey)
    catch JWTError:
        return Error("Invalid refresh token")
    
    // Check if refresh token is expired
    if claims.expiresAt < now():
        return Error("Refresh token expired")
    
    // Check if refresh token is revoked
    if cache.exists("revoked:" + hash(refreshToken)):
        return Error("Refresh token revoked")
    
    // Generate new access token
    user = database.query("SELECT * FROM users WHERE id = ?", claims.userId)
    if user is null:
        return Error("User not found")
    
    newAccessToken = generateJWT({
        userId: user.id,
        username: user.username,
        roles: user.roles,
        expiresIn: "1 hour"
    })
    
    // Update session in cache
    session = cache.get("session:" + user.id)
    session.token = hash(newAccessToken)
    session.expiresAt = now() + 1 hour
    cache.set("session:" + user.id, session, ttl=1 hour)
    
    return {
        token: newAccessToken,
        expiresAt: now() + 1 hour
    }
```

## Control Flow Diagrams

```
User Authentication Flow:
START
  ↓
[Validate Input] → Invalid? → Return 400
  ↓ Valid
[Query User] → Not Found? → Log + Return 401
  ↓ Found
[Verify Password] → Mismatch? → Check Rate Limit
  ↓ Match                          ↓
[Generate Tokens]              Exceeded? → Return 429
  ↓                                ↓ No
[Store Session]                Log + Return 401
  ↓
[Return Success 200]
END
```

## Error Handling Flow

```
Error Handling Strategy:

1. Input Validation Errors (400)
   - Return immediately
   - Don't log sensitive data
   - Provide helpful error messages

2. Authentication Errors (401)
   - Log attempt (for security monitoring)
   - Don't reveal if user exists
   - Generic "Invalid credentials" message
   - Track for rate limiting

3. Rate Limiting Errors (429)
   - Log source IP
   - Return retry-after header
   - Consider CAPTCHA for repeated attempts

4. Server Errors (500)
   - Log full error details
   - Return generic message to user
   - Alert operations team
   - Never expose internal errors to user
```

## Edge Case Handling

```
Edge Case 1: Concurrent Login Attempts
    Problem: User tries to log in from multiple devices simultaneously
    Solution:
        - Allow multiple sessions per user
        - Each session has unique token
        - Track sessions in cache with composite key: "session:{userId}:{deviceId}"

Edge Case 2: Clock Skew
    Problem: Server time differs from token issuer time
    Solution:
        - Add 5-minute leeway for expiration checks
        - Use UTC consistently
        - Implement NTP sync on servers

Edge Case 3: Database Connection Loss During Auth
    Problem: Database becomes unavailable mid-authentication
    Solution:
        - Catch database errors
        - Return 503 Service Unavailable
        - Implement circuit breaker pattern
        - Retry with exponential backoff

Edge Case 4: Redis Cache Miss
    Problem: Session exists but cache entry is evicted
    Solution:
        - Gracefully handle cache miss
        - Re-validate against database
        - Regenerate session if valid
        - Monitor cache hit rate
```
```

---

## Architecture Phase

### Purpose
Design the system structure, components, and their interactions.

### Template

```markdown
# [Feature Name] Architecture

## System Context

```
┌─────────────────────────────────────────────────────┐
│                   External Systems                   │
├─────────────────────────────────────────────────────┤
│  User (Browser/App) → API Gateway → Auth Service    │
│                          ↓              ↓            │
│                      Rate Limiter   PostgreSQL       │
│                                         ↓            │
│                                      Redis Cache     │
└─────────────────────────────────────────────────────┘
```

## Component Diagram

```
┌──────────────────────────────────────────────────────┐
│                  Auth Service                        │
├──────────────────────────────────────────────────────┤
│                                                      │
│  ┌────────────┐  ┌──────────────┐  ┌────────────┐  │
│  │  HTTP      │  │  Middleware  │  │  Validator │  │
│  │  Handlers  │→ │  (Auth,      │→ │  (Input)   │  │
│  └────────────┘  │   Rate Limit)│  └────────────┘  │
│        ↓         └──────────────┘         ↓         │
│  ┌────────────────────────────────────────────────┐ │
│  │            Auth Service (Business Logic)       │ │
│  └────────────────────────────────────────────────┘ │
│        ↓                          ↓                  │
│  ┌────────────┐            ┌─────────────┐          │
│  │    User    │            │   Session   │          │
│  │ Repository │            │  Repository │          │
│  └────────────┘            └─────────────┘          │
│        ↓                          ↓                  │
└────────┼──────────────────────────┼──────────────────┘
         ↓                          ↓
  ┌─────────────┐            ┌────────────┐
  │ PostgreSQL  │            │   Redis    │
  │  (Users)    │            │  (Sessions)│
  └─────────────┘            └────────────┘
```

## Layered Architecture

```
┌─────────────────────────────────────────────┐
│         Presentation Layer                  │
│  - HTTP Handlers                            │
│  - Request/Response DTOs                    │
│  - API Documentation                        │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│         Application Layer                   │
│  - Business Logic                           │
│  - Service Orchestration                    │
│  - Transaction Management                   │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│         Domain Layer                        │
│  - Business Entities (User, Session)        │
│  - Domain Logic                             │
│  - Validation Rules                         │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│         Infrastructure Layer                │
│  - Database Access (Repositories)           │
│  - External Services (Redis, etc.)          │
│  - Cross-cutting Concerns (Logging, etc.)   │
└─────────────────────────────────────────────┘
```

## Component Responsibilities

### HTTP Handler Layer
**Purpose**: Handle HTTP requests/responses, routing

**Responsibilities**:
- Parse HTTP requests
- Validate HTTP-specific constraints (headers, etc.)
- Route to appropriate service
- Format responses
- Handle HTTP status codes

**Dependencies**: Auth Service, Validator

**Example**:
```go
type AuthHandler struct {
    authService AuthService
    validator   Validator
}

func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
    var req LoginRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "Invalid request", 400)
        return
    }
    
    if err := h.validator.Validate(req); err != nil {
        http.Error(w, err.Error(), 400)
        return
    }
    
    session, err := h.authService.Authenticate(req.Username, req.Password)
    if err != nil {
        http.Error(w, "Authentication failed", 401)
        return
    }
    
    json.NewEncoder(w).Encode(session)
}
```

### Auth Service Layer
**Purpose**: Implement business logic for authentication

**Responsibilities**:
- User authentication logic
- Token generation and validation
- Session management
- Business rule enforcement

**Dependencies**: User Repository, Session Repository, JWT Service, Password Service

**Example**:
```go
type AuthService interface {
    Authenticate(username, password string) (*Session, error)
    ValidateToken(token string) (*User, error)
    RefreshToken(refreshToken string) (*Session, error)
    Logout(sessionID string) error
}
```

### Repository Layer
**Purpose**: Data access abstraction

**Responsibilities**:
- Database CRUD operations
- Query building
- Transaction management
- Connection management

**Dependencies**: Database connection

**Example**:
```go
type UserRepository interface {
    FindByUsername(username string) (*User, error)
    FindByID(id string) (*User, error)
    Create(user *User) error
    Update(user *User) error
}

type SessionRepository interface {
    Store(session *Session) error
    Get(sessionID string) (*Session, error)
    Delete(sessionID string) error
    DeleteExpired() error
}
```

## Data Models

### User Entity
```go
type User struct {
    ID           string    `db:"id" json:"id"`
    Username     string    `db:"username" json:"username"`
    Email        string    `db:"email" json:"email"`
    PasswordHash string    `db:"password_hash" json:"-"`
    Roles        []string  `db:"roles" json:"roles"`
    CreatedAt    time.Time `db:"created_at" json:"created_at"`
    UpdatedAt    time.Time `db:"updated_at" json:"updated_at"`
    LastLoginAt  *time.Time `db:"last_login_at" json:"last_login_at"`
}
```

### Session Entity
```go
type Session struct {
    ID           string    `json:"id"`
    UserID       string    `json:"user_id"`
    Token        string    `json:"token"`
    RefreshToken string    `json:"refresh_token"`
    CreatedAt    time.Time `json:"created_at"`
    ExpiresAt    time.Time `json:"expires_at"`
    Device       string    `json:"device"`
    IPAddress    string    `json:"ip_address"`
}
```

### Database Schema
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    roles TEXT[] NOT NULL DEFAULT '{}',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMP,
    
    INDEX idx_users_username (username),
    INDEX idx_users_email (email)
);

CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    refresh_token_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP NOT NULL,
    device VARCHAR(255),
    ip_address INET,
    
    INDEX idx_sessions_user_id (user_id),
    INDEX idx_sessions_expires_at (expires_at)
);
```

## Technology Stack

### Programming Language
- **Go 1.21+**
- Why: Performance, concurrency, strong typing
- Alternatives considered: Node.js (slower), Python (slower)

### Web Framework
- **net/http (stdlib)** with **gorilla/mux** for routing
- Why: Lightweight, well-tested, no unnecessary overhead
- Alternatives: Gin (more features than needed), Echo (similar)

### Database
- **PostgreSQL 14+**
- Why: ACID compliance, JSON support, performance
- Alternatives: MySQL (weaker JSON), MongoDB (no transactions)

### Caching
- **Redis 7+**
- Why: Fast, TTL support, widely used
- Alternatives: Memcached (no persistence), In-memory (no scaling)

### JWT Library
- **github.com/golang-jwt/jwt/v5**
- Why: Actively maintained, secure, feature-complete
- Alternatives: github.com/dgrijalva/jwt-go (abandoned)

### Password Hashing
- **golang.org/x/crypto/bcrypt**
- Why: Industry standard, adjustable cost
- Alternatives: Argon2 (newer, more complex)

## Security Architecture

### Authentication Flow
```
1. User submits credentials
2. Rate limiting check (Redis)
3. Input validation
4. Database lookup (PostgreSQL)
5. Password verification (bcrypt, constant-time)
6. Token generation (JWT with RS256)
7. Session storage (Redis with TTL)
8. Return token to user
```

### Token Strategy
- **Access Token**: Short-lived (1 hour), JWT, stateless
- **Refresh Token**: Long-lived (30 days), stored in Redis, revocable
- **Signing Algorithm**: RS256 (RSA public/private key)
- **Claims**: user_id, username, roles, exp, iat, jti

### Security Measures
1. **Password Storage**: Bcrypt with cost factor 12
2. **Token Storage**: Hash tokens before storing in Redis
3. **Rate Limiting**: 5 attempts per 15 minutes per IP
4. **Input Validation**: Sanitize all inputs, validate formats
5. **HTTPS Only**: Enforce TLS 1.3
6. **Audit Logging**: Log all authentication attempts
7. **Secret Management**: Environment variables, never commit secrets

## Performance Architecture

### Caching Strategy
```
Cache Layer (Redis):
- Session data (TTL: 1 hour)
- User profile (TTL: 5 minutes, cache-aside pattern)
- Rate limit counters (TTL: 15 minutes)
- Blacklisted tokens (TTL: token expiry)

Cache Key Patterns:
- "session:{user_id}" → Session
- "user:{user_id}" → User profile
- "rate:{ip}" → Rate limit counter
- "revoked:{token_hash}" → Blacklisted token flag
```

### Database Optimization
```
Indexes:
- users(username) - For login lookup
- users(email) - For email lookup
- sessions(user_id) - For user session queries
- sessions(expires_at) - For cleanup queries

Connection Pooling:
- Min connections: 5
- Max connections: 20
- Connection lifetime: 1 hour
- Connection timeout: 5 seconds

Query Optimization:
- Prepare statements for repeated queries
- Use EXPLAIN ANALYZE to verify query plans
- Monitor slow query log
```

### Load Handling
```
Concurrency:
- goroutines for request handling
- Connection pool for database
- Redis pipeline for bulk operations

Scaling:
- Stateless service design (horizontal scaling)
- Load balancer distributes requests
- Database read replicas for read queries
- Redis cluster for cache scaling
```

## Deployment Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Load Balancer                      │
│                  (nginx/HAProxy)                    │
└────────┬────────────────────┬───────────────────────┘
         │                    │
    ┌────┴────┐          ┌────┴────┐
    │  Auth   │          │  Auth   │
    │ Service │          │ Service │
    │Instance1│          │Instance2│
    └────┬────┘          └────┬────┘
         │                    │
         └────────┬───────────┘
                  │
         ┌────────┴────────┐
         │                 │
    ┌────┴────┐       ┌────┴────┐
    │PostgreSQL        │  Redis  │
    │ (Primary)│       │ Cluster │
    └────┬────┘       └─────────┘
         │
    ┌────┴────┐
    │PostgreSQL
    │ (Replica)│
    └─────────┘
```

## Monitoring & Observability

### Metrics to Track
- Authentication success/failure rate
- Response time (p50, p95, p99)
- Active sessions count
- Token generation rate
- Database query time
- Cache hit/miss ratio
- Rate limit triggers

### Logging Strategy
- **Info**: Successful authentication, session creation
- **Warning**: Failed authentication, rate limit hit
- **Error**: Database errors, token validation failures
- **Audit**: All authentication attempts (success and failure)

### Alerting
- Alert if error rate > 1%
- Alert if p95 response time > 200ms
- Alert if database connection pool > 80% utilized
- Alert if cache hit rate < 80%
```

---

## Refinement Phase

### Purpose
Iteratively improve code quality, performance, and security.

### Checklist Template

```markdown
# [Feature Name] Refinement Checklist

## Code Quality Improvements

### Linting
- [ ] All linter issues resolved
- [ ] No unused imports or variables
- [ ] Consistent naming conventions
- [ ] Proper error handling everywhere
- [ ] No commented-out code (remove or document)

### Code Structure
- [ ] DRY principle followed (no duplication)
- [ ] Single Responsibility Principle (each function does one thing)
- [ ] Functions are < 50 lines
- [ ] Cyclomatic complexity < 10
- [ ] Deep nesting avoided (< 4 levels)

### Refactoring Opportunities
- [ ] Extract complex logic into named functions
- [ ] Replace magic numbers with named constants
- [ ] Consolidate similar code paths
- [ ] Improve variable/function names
- [ ] Add helper functions for repeated patterns

## Performance Optimization

### Profiling Results
```
Before Optimization:
- Authentication: 250ms p95
- Token validation: 45ms p95
- Memory: 120MB per 1000 requests

Bottlenecks Identified:
1. Database query taking 180ms (no index on username)
2. Bcrypt cost factor too high (14 → 12)
3. Generating new Redis connection per request
```

### Optimization Tasks
- [ ] Add database indexes for query optimization
- [ ] Implement connection pooling (database and Redis)
- [ ] Cache frequently accessed data
- [ ] Reduce bcrypt cost factor to 12
- [ ] Use prepared statements for repeated queries
- [ ] Minimize allocations in hot paths
- [ ] Implement batch operations where possible

### After Optimization
```
After Optimization:
- Authentication: 85ms p95 (✓ < 100ms target)
- Token validation: 8ms p95 (✓ < 10ms target)
- Memory: 40MB per 1000 requests (66% reduction)
```

### Benchmark Results
```
BenchmarkAuthenticate-8   5000   285432 ns/op   12384 B/op   89 allocs/op
BenchmarkValidateToken-8  50000   31245 ns/op   2048 B/op   15 allocs/op
```

## Security Review

### Security Scanning
- [ ] No secrets in code (API keys, passwords, tokens)
- [ ] No dependency vulnerabilities (npm audit / go list)
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (proper escaping)
- [ ] CSRF protection (tokens)

### Authentication & Authorization
- [ ] Password strength requirements enforced
- [ ] Passwords properly hashed (bcrypt cost 12+)
- [ ] Tokens properly signed (RS256, not HS256)
- [ ] Token expiry enforced
- [ ] Session management secure (no session fixation)
- [ ] Rate limiting implemented

### Data Protection
- [ ] Sensitive data never logged (passwords, tokens)
- [ ] Sensitive data encrypted at rest
- [ ] Sensitive data encrypted in transit (TLS 1.3)
- [ ] Proper access controls on data
- [ ] Audit logging for sensitive operations

### Code Review Checklist
- [ ] No hardcoded credentials
- [ ] No weak cryptography (MD5, SHA1)
- [ ] Using crypto/rand for random numbers (not math/rand)
- [ ] Constant-time comparison for secrets
- [ ] Error messages don't leak sensitive information

## Test Coverage Improvements

### Current Coverage
```
Unit Tests: 82% (target: 90%)
Integration Tests: 100% (target: 100%)
E2E Tests: 100% (target: 100%)

Coverage Gaps:
- pkg/auth/service.go: 75% (missing error path tests)
- pkg/auth/validator.go: 80% (missing edge case tests)
```

### Tests to Add
- [ ] Error path: Database connection failure during auth
- [ ] Error path: Redis unavailable during session storage
- [ ] Edge case: Concurrent login attempts from same user
- [ ] Edge case: Token expiry exactly at boundary
- [ ] Edge case: Malformed JWT token
- [ ] Edge case: Very long username (> 255 chars)
- [ ] Performance test: 1000 concurrent authentications
- [ ] Load test: Sustained 10000 requests/minute

### Test Quality
- [ ] All tests are deterministic (no flaky tests)
- [ ] Tests use proper mocking (not real database)
- [ ] Tests have clear arrange-act-assert structure
- [ ] Test names describe what they test
- [ ] Tests cover happy path and error paths
- [ ] Tests verify exact error messages

## Documentation Updates

- [ ] API documentation updated (OpenAPI/Swagger)
- [ ] README updated with setup instructions
- [ ] Architecture diagrams updated
- [ ] Inline code comments for complex logic
- [ ] Change log updated
- [ ] Migration guide (if breaking changes)

## Pre-Completion Review

### Functionality
- [ ] All requirements from specification met
- [ ] All edge cases handled
- [ ] All error scenarios handled gracefully
- [ ] User feedback incorporated

### Quality Gates
- [ ] All tests passing
- [ ] Coverage thresholds met (90%+ unit, 100% E2E)
- [ ] All linter issues resolved
- [ ] Security scan passed
- [ ] Performance targets met
- [ ] Code review approved
```

---

## Completion Phase

### Purpose
Finalize the implementation and prepare for deployment.

### Checklist Template

```markdown
# [Feature Name] Completion Checklist

## Functional Completeness

- [ ] All functional requirements implemented and verified
- [ ] All acceptance criteria met
- [ ] All user stories completed
- [ ] All edge cases handled
- [ ] All error scenarios handled
- [ ] User feedback incorporated (if applicable)

## Quality Assurance

### Testing
- [ ] Unit tests: 90%+ coverage
- [ ] Integration tests: 100% pass rate
- [ ] E2E tests: 100% pass rate
- [ ] Performance tests passed
- [ ] Load tests passed
- [ ] Security tests passed
- [ ] Regression tests passed

### Code Quality
- [ ] All linter issues resolved
- [ ] Code review completed and approved
- [ ] No technical debt introduced (or documented)
- [ ] Refactoring completed
- [ ] Dead code removed

### Security
- [ ] Security scan passed (no secrets in code)
- [ ] Dependency audit passed (no vulnerabilities)
- [ ] Penetration testing completed (if applicable)
- [ ] Security code review completed
- [ ] Threat modeling updated

### Performance
- [ ] Performance targets met
  - Authentication: < 100ms p95 ✓
  - Token validation: < 10ms p95 ✓
- [ ] Resource usage within limits
  - Memory: < 50MB per request ✓
- [ ] Database queries optimized
- [ ] Caching effective (> 80% hit rate)

## Documentation

- [ ] API documentation complete and accurate
- [ ] User documentation updated (if user-facing)
- [ ] Developer documentation (setup, architecture)
- [ ] Inline code comments (for complex logic)
- [ ] Change log updated
- [ ] Migration guide (if breaking changes)
- [ ] Architecture Decision Records updated

## Deployment Preparation

### Environment Setup
- [ ] Development environment tested
- [ ] Staging environment tested
- [ ] Production environment prepared
- [ ] Environment variables configured
- [ ] Secrets properly managed

### Database
- [ ] Migration scripts tested
- [ ] Rollback scripts prepared
- [ ] Database backup verified
- [ ] Indexes created
- [ ] Performance tested with production-like data

### Monitoring
- [ ] Metrics collection configured
- [ ] Logging configured
- [ ] Alerts configured
- [ ] Dashboards created
- [ ] On-call runbook updated

### Deployment
- [ ] Deployment plan documented
- [ ] Rollback plan documented
- [ ] Feature flags configured (if using)
- [ ] Staged rollout plan (if applicable)
- [ ] Deployment tested in staging

## Sign-Off

- [ ] Product owner approval
- [ ] Technical lead approval
- [ ] Security team approval (if required)
- [ ] Compliance team approval (if required)

## Post-Deployment

- [ ] Smoke tests passed in production
- [ ] Monitoring confirmed working
- [ ] No critical errors in logs
- [ ] Performance metrics within targets
- [ ] User acceptance testing passed (if applicable)

## Lessons Learned

### What Went Well
- [Document successes and good practices]

### What Could Be Improved
- [Document challenges and areas for improvement]

### Action Items for Future
- [Document specific improvements for next time]
```

---

## Quick Reference

### When to Use Each Phase

- **Specification**: Always start here - defines the problem
- **Pseudocode**: For algorithmic logic and complex workflows
- **Architecture**: For system design and component interaction
- **Refinement**: Throughout implementation, especially before completion
- **Completion**: Final checklist before considering work "done"

### Minimum Viable Documentation

For smaller features, you can simplify:
- Specification: 1 page (requirements, constraints, success criteria)
- Pseudocode: Main algorithm only
- Architecture: Component list and data models
- Refinement: Standard checklist
- Completion: Standard checklist

### Time Allocation Guide

For a typical feature:
- Specification: 10% of time
- Pseudocode: 5% of time
- Architecture: 15% of time
- Implementation: 50% of time
- Refinement: 10% of time
- Completion: 10% of time

---

## Additional Resources

### External References
- [Conventional Commits](https://www.conventionalcommits.org/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [12 Factor App](https://12factor.net/)
- [Google Engineering Practices](https://google.github.io/eng-practices/)

### Internal References
- CLAUDE.md - Main development guidelines
- Security best practices: /docs/security-guidelines.md
- Performance standards: /docs/performance-standards.md
