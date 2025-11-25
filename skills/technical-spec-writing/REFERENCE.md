# Technical Spec Reference Guide

Detailed guidance on architecture patterns, API design, data modeling, and system design decisions.

---

## Architecture Patterns

### Service Architecture Patterns

#### Monolith

**When to Use:**
- Early-stage product with evolving requirements
- Small team (< 10 engineers)
- Simple domain with clear boundaries
- Need for rapid iteration

**Structure:**
```
┌─────────────────────────────────────────────────────────┐
│                      Monolith                           │
├──────────┬──────────┬──────────┬──────────┬────────────┤
│  Auth    │  Orders  │ Products │  Users   │  Payments  │
│  Module  │  Module  │  Module  │  Module  │   Module   │
├──────────┴──────────┴──────────┴──────────┴────────────┤
│                   Shared Database                       │
└─────────────────────────────────────────────────────────┘
```

**Pros:** Simple deployment, easy debugging, ACID transactions
**Cons:** Scaling limitations, deployment coupling, technology lock-in

---

#### Modular Monolith

**When to Use:**
- Monolith benefits with better boundaries
- Preparing for potential future decomposition
- Medium-sized team (10-30 engineers)

**Structure:**
```
┌─────────────────────────────────────────────────────────┐
│                   Modular Monolith                      │
├───────────────┬───────────────┬───────────────┬────────┤
│   Auth        │    Orders     │   Products    │  ...   │
│   Module      │    Module     │    Module     │        │
├───────────────┼───────────────┼───────────────┼────────┤
│  Auth DB      │  Orders DB    │  Products DB  │  ...   │
│  (schema)     │  (schema)     │  (schema)     │        │
└───────────────┴───────────────┴───────────────┴────────┘
         │               │               │
         └───────────────┼───────────────┘
                         ▼
              ┌─────────────────────┐
              │   Shared Database   │
              │   (separate schemas)│
              └─────────────────────┘
```

**Key Rules:**
- Modules communicate only through defined interfaces
- No direct database access across modules
- Each module owns its data schema

---

#### Microservices

**When to Use:**
- Large team requiring independent deployment
- Different scaling requirements per domain
- Polyglot technology needs
- Clear bounded contexts

**Structure:**
```
┌──────────┐     ┌──────────┐     ┌──────────┐
│   Auth   │     │  Orders  │     │ Products │
│  Service │     │  Service │     │  Service │
└────┬─────┘     └────┬─────┘     └────┬─────┘
     │                │                │
     ▼                ▼                ▼
┌─────────┐     ┌─────────┐     ┌─────────┐
│ Auth DB │     │Orders DB│     │Prods DB │
└─────────┘     └─────────┘     └─────────┘

         ┌───────────────────┐
         │   Message Queue   │
         │  (Events/Commands)│
         └───────────────────┘
```

**Pros:** Independent scaling, technology flexibility, team autonomy
**Cons:** Distributed complexity, eventual consistency, operational overhead

---

### Communication Patterns

#### Synchronous (Request/Response)

**REST:**
```
Client ──HTTP──▶ API Gateway ──HTTP──▶ Service
                                          │
                                          ▼
                                      Database
```

Best for: CRUD operations, real-time data needs, simple queries

**gRPC:**
```
Service A ──gRPC──▶ Service B
    │                   │
    └───Streaming───────┘
```

Best for: Service-to-service, high throughput, streaming

---

#### Asynchronous (Events)

**Event-Driven:**
```
Producer ──▶ Message Queue ──▶ Consumer
                 │
                 ├──▶ Consumer 2
                 │
                 └──▶ Consumer 3
```

**Patterns:**

| Pattern | Description | Use Case |
|---------|-------------|----------|
| Pub/Sub | Many consumers, same event | Notifications, audit |
| Queue | One consumer per message | Task processing |
| Event Sourcing | Events as source of truth | Audit trail, replay |
| CQRS | Separate read/write models | High read/write asymmetry |

---

### Data Patterns

#### Repository Pattern

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Handler    │────▶│   Service    │────▶│  Repository  │
│              │     │              │     │              │
└──────────────┘     └──────────────┘     └──────┬───────┘
                                                 │
                                                 ▼
                                          ┌──────────────┐
                                          │   Database   │
                                          └──────────────┘
```

**Benefits:**
- Abstracts data access from business logic
- Enables testing with mock repositories
- Simplifies switching data stores

**Interface Example:**
```go
type UserRepository interface {
    FindByID(ctx context.Context, id string) (*User, error)
    FindByEmail(ctx context.Context, email string) (*User, error)
    Create(ctx context.Context, user *User) error
    Update(ctx context.Context, user *User) error
    Delete(ctx context.Context, id string) error
}
```

---

#### Unit of Work Pattern

```
┌─────────────────────────────────────────────────────┐
│                   Unit of Work                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │   User      │  │   Order     │  │   Product   │  │
│  │   Repo      │  │   Repo      │  │   Repo      │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
│                                                      │
│  Commit() / Rollback()                               │
└─────────────────────────────────────────────────────┘
```

**Benefits:**
- Atomic operations across multiple repositories
- Single transaction boundary
- Clean rollback on failure

---

#### Saga Pattern (Distributed Transactions)

**Choreography:**
```
Order Service ──OrderCreated──▶ Payment Service
                                      │
                              PaymentCompleted
                                      │
                                      ▼
                              Inventory Service
                                      │
                              InventoryReserved
                                      │
                                      ▼
                              Shipping Service
```

**Orchestration:**
```
              ┌─────────────────┐
              │ Saga Orchestrator│
              └────────┬────────┘
                       │
    ┌──────────────────┼──────────────────┐
    ▼                  ▼                  ▼
┌────────┐       ┌──────────┐       ┌──────────┐
│ Order  │       │ Payment  │       │ Shipping │
│Service │       │ Service  │       │ Service  │
└────────┘       └──────────┘       └──────────┘
```

**Compensation:**
| Step | Action | Compensation |
|------|--------|--------------|
| 1 | Create order | Cancel order |
| 2 | Reserve inventory | Release inventory |
| 3 | Charge payment | Refund payment |
| 4 | Ship order | Return shipment |

---

## API Design Principles

### REST Best Practices

#### URL Structure

```
# Resources (nouns, not verbs)
GET    /api/v1/users              # List users
POST   /api/v1/users              # Create user
GET    /api/v1/users/{id}         # Get user
PUT    /api/v1/users/{id}         # Update user (full)
PATCH  /api/v1/users/{id}         # Update user (partial)
DELETE /api/v1/users/{id}         # Delete user

# Nested resources
GET    /api/v1/users/{id}/orders  # User's orders

# Filtering, sorting, pagination
GET    /api/v1/orders?status=pending&sort=-created_at&page=2&limit=20

# Actions (when CRUD doesn't fit)
POST   /api/v1/orders/{id}/cancel
POST   /api/v1/users/{id}/activate
```

#### Versioning Strategies

| Strategy | Example | Pros | Cons |
|----------|---------|------|------|
| URL Path | `/api/v1/users` | Clear, cacheable | URL pollution |
| Query Param | `/api/users?v=1` | Easy to implement | Cache issues |
| Header | `Accept: application/vnd.api+json;v=1` | Clean URLs | Less visible |

**Recommendation:** Use URL path versioning for clarity.

---

#### Response Format

**Success:**
```json
{
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "type": "user",
    "attributes": {
      "email": "user@example.com",
      "name": "John Doe",
      "created_at": "2024-01-15T10:30:00Z"
    }
  },
  "meta": {
    "request_id": "req_abc123"
  }
}
```

**Collection with Pagination:**
```json
{
  "data": [
    { "id": "1", "type": "order", "attributes": {...} },
    { "id": "2", "type": "order", "attributes": {...} }
  ],
  "meta": {
    "total": 150,
    "page": 2,
    "per_page": 20,
    "total_pages": 8
  },
  "links": {
    "self": "/api/v1/orders?page=2",
    "first": "/api/v1/orders?page=1",
    "prev": "/api/v1/orders?page=1",
    "next": "/api/v1/orders?page=3",
    "last": "/api/v1/orders?page=8"
  }
}
```

**Error:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Email must be a valid email address"
      }
    ]
  },
  "meta": {
    "request_id": "req_abc123"
  }
}
```

---

### HTTP Status Codes

| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid request body/params |
| 401 | Unauthorized | Missing/invalid authentication |
| 403 | Forbidden | Authenticated but not authorized |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | State conflict (duplicate, version) |
| 422 | Unprocessable | Validation failed |
| 429 | Too Many Requests | Rate limited |
| 500 | Internal Error | Unexpected server error |
| 503 | Service Unavailable | Maintenance/overload |

---

### Idempotency

**Problem:** Network failures can cause duplicate requests.

**Solution:** Idempotency keys

```
POST /api/v1/payments
Idempotency-Key: pay_abc123
Content-Type: application/json

{
  "amount": 100,
  "currency": "USD"
}
```

**Implementation:**
```
┌─────────────────────────────────────────────────────────┐
│                   Idempotency Flow                      │
│                                                         │
│  Request ──▶ Check Key ──▶ Key Exists? ──▶ Return Cache │
│                              │                          │
│                              ▼ No                       │
│                         Process Request                 │
│                              │                          │
│                              ▼                          │
│                      Store Result + Key                 │
│                              │                          │
│                              ▼                          │
│                        Return Result                    │
└─────────────────────────────────────────────────────────┘
```

---

## Data Modeling

### Schema Design Principles

#### Normalization vs Denormalization

| Approach | Pros | Cons | Use When |
|----------|------|------|----------|
| Normalized | No duplication, consistent | More joins | Write-heavy, data integrity critical |
| Denormalized | Faster reads, simpler queries | Data duplication | Read-heavy, can tolerate inconsistency |

**Example - Normalized:**
```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255) UNIQUE
);

-- Orders table (references users)
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    total DECIMAL(10,2)
);

-- Query requires JOIN
SELECT o.*, u.name, u.email
FROM orders o
JOIN users u ON o.user_id = u.id;
```

**Example - Denormalized:**
```sql
-- Orders table (with embedded user info)
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    user_id UUID,
    user_name VARCHAR(255),    -- Denormalized
    user_email VARCHAR(255),   -- Denormalized
    total DECIMAL(10,2)
);

-- Simpler query, no JOIN
SELECT * FROM orders;
```

---

#### Soft Delete vs Hard Delete

**Soft Delete:**
```sql
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMP;

-- "Delete" user
UPDATE users SET deleted_at = NOW() WHERE id = ?;

-- Query active users
SELECT * FROM users WHERE deleted_at IS NULL;
```

**Pros:** Audit trail, recovery, referential integrity
**Cons:** Query complexity, storage, index bloat

**Hard Delete:**
```sql
DELETE FROM users WHERE id = ?;
```

**Pros:** Clean data, simpler queries
**Cons:** No recovery, FK constraints

---

#### Temporal Data Patterns

**Effective Dating:**
```sql
CREATE TABLE price_history (
    id UUID PRIMARY KEY,
    product_id UUID,
    price DECIMAL(10,2),
    effective_from TIMESTAMP NOT NULL,
    effective_to TIMESTAMP,  -- NULL = current
    CONSTRAINT no_overlap EXCLUDE USING gist (
        product_id WITH =,
        tsrange(effective_from, effective_to) WITH &&
    )
);

-- Get current price
SELECT price FROM price_history
WHERE product_id = ?
  AND effective_from <= NOW()
  AND (effective_to IS NULL OR effective_to > NOW());
```

**Event Sourcing:**
```sql
CREATE TABLE events (
    id UUID PRIMARY KEY,
    aggregate_id UUID NOT NULL,
    aggregate_type VARCHAR(100),
    event_type VARCHAR(100),
    event_data JSONB,
    version INT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(aggregate_id, version)
);

-- Rebuild state from events
SELECT * FROM events
WHERE aggregate_id = ?
ORDER BY version;
```

---

### Index Strategy

#### Index Types

| Type | Use Case | Example |
|------|----------|---------|
| B-tree | Default, equality, range | `CREATE INDEX idx ON t(col)` |
| Hash | Equality only | `CREATE INDEX idx ON t USING hash(col)` |
| GIN | Array, JSONB, full-text | `CREATE INDEX idx ON t USING gin(data)` |
| GiST | Geometric, ranges | `CREATE INDEX idx ON t USING gist(range)` |

#### Index Design Rules

1. **Index columns in WHERE, JOIN, ORDER BY**
2. **Put selective columns first in composite indexes**
3. **Cover queries with covering indexes when beneficial**
4. **Monitor and remove unused indexes**

**Example - Composite Index:**
```sql
-- Query pattern
SELECT * FROM orders
WHERE user_id = ? AND status = ?
ORDER BY created_at DESC;

-- Optimal index (matches query pattern)
CREATE INDEX idx_orders_user_status_created
ON orders(user_id, status, created_at DESC);
```

---

## Performance Patterns

### Caching Strategies

#### Cache-Aside (Lazy Loading)

```
Application ──Read──▶ Cache ──Miss──▶ Database
      │                                  │
      │◀─────Hit─────┘                   │
      │◀─────────────Data────────────────┘
      │
      └──Write──▶ Cache
```

```go
func GetUser(id string) (*User, error) {
    // Try cache
    if user := cache.Get("user:" + id); user != nil {
        return user, nil
    }

    // Cache miss - load from DB
    user, err := db.FindUser(id)
    if err != nil {
        return nil, err
    }

    // Populate cache
    cache.Set("user:" + id, user, 5*time.Minute)
    return user, nil
}
```

---

#### Write-Through

```
Application ──Write──▶ Cache ──Write──▶ Database
                         │
                    (synchronous)
```

**Pros:** Cache always consistent
**Cons:** Higher write latency

---

#### Write-Behind (Write-Back)

```
Application ──Write──▶ Cache ──Async Write──▶ Database
                         │
                    (async batch)
```

**Pros:** Lower write latency
**Cons:** Risk of data loss, complexity

---

### Rate Limiting

#### Token Bucket

```
┌─────────────────────────────────────┐
│           Token Bucket               │
│  ┌─────────────────────────────┐    │
│  │ ● ● ● ● ●  [tokens]         │    │
│  └─────────────────────────────┘    │
│                                      │
│  Refill rate: 10 tokens/second       │
│  Bucket size: 100 tokens             │
└─────────────────────────────────────┘
```

**Implementation:**
```go
type TokenBucket struct {
    tokens     float64
    maxTokens  float64
    refillRate float64  // tokens per second
    lastRefill time.Time
}

func (b *TokenBucket) Allow() bool {
    now := time.Now()
    elapsed := now.Sub(b.lastRefill).Seconds()

    // Refill tokens
    b.tokens = min(b.maxTokens, b.tokens + elapsed*b.refillRate)
    b.lastRefill = now

    // Check if request allowed
    if b.tokens >= 1 {
        b.tokens--
        return true
    }
    return false
}
```

---

#### Sliding Window

```
Time:  |----|----|----|----|----|----|
       0    1    2    3    4    5    6

Window at t=5: [2, 5] = 4 requests
Limit: 5 requests per 3 seconds

Request at t=5: Allowed (4 < 5)
Request at t=5.1: Denied (5 >= 5)
```

---

### Circuit Breaker

```
         ┌───────────────────────────────────────────┐
         │                                           │
         ▼                                           │
    ┌─────────┐     ┌─────────┐     ┌─────────┐     │
    │ CLOSED  │────▶│  OPEN   │────▶│HALF-OPEN│─────┘
    │         │     │         │     │         │
    └────┬────┘     └────┬────┘     └────┬────┘
         │               │               │
    Failures <          After            Success:
    threshold           timeout          → CLOSED
         │               │               │
         └───────────────┴───────────────┘
                         │
                    Failure:
                    → OPEN
```

**States:**
| State | Behavior | Transition |
|-------|----------|------------|
| Closed | Normal operation | → Open on N failures |
| Open | Reject all requests | → Half-Open after timeout |
| Half-Open | Allow limited requests | → Closed on success, Open on failure |

---

## Security Patterns

### Authentication Flows

#### JWT Authentication

```
┌────────┐     ┌────────────┐     ┌──────────┐
│ Client │     │ Auth Server│     │ Resource │
└───┬────┘     └─────┬──────┘     └────┬─────┘
    │                │                  │
    │──Credentials──▶│                  │
    │                │                  │
    │◀──JWT Token────│                  │
    │                │                  │
    │──Request + JWT────────────────────▶│
    │                │                  │
    │                │◀─Verify JWT──────│
    │                │                  │
    │◀──Response─────────────────────────│
```

**JWT Structure:**
```
Header.Payload.Signature

{
  "alg": "RS256",
  "typ": "JWT"
}
.
{
  "sub": "user_123",
  "iat": 1704067200,
  "exp": 1704153600,
  "roles": ["user", "admin"]
}
.
[Signature]
```

---

#### OAuth 2.0 Authorization Code

```
┌────────┐     ┌────────────┐     ┌──────────────┐
│ Client │     │ Auth Server│     │Resource Owner│
└───┬────┘     └─────┬──────┘     └──────┬───────┘
    │                │                    │
    │──Redirect─────▶│                    │
    │                │──Login Prompt─────▶│
    │                │◀──Credentials──────│
    │                │                    │
    │◀──Auth Code────│                    │
    │                │                    │
    │──Code + Secret▶│                    │
    │◀──Access Token─│                    │
```

---

### Authorization Patterns

#### RBAC (Role-Based Access Control)

```
┌─────────┐     ┌─────────┐     ┌─────────────┐
│  User   │────▶│  Role   │────▶│ Permission  │
└─────────┘  N:M└─────────┘  N:M└─────────────┘

User: john@example.com
  └─▶ Roles: [admin, editor]
         └─▶ Permissions: [read, write, delete, manage_users]
```

---

#### ABAC (Attribute-Based Access Control)

```
Policy:
  IF user.department = "engineering"
  AND resource.type = "code"
  AND action = "read"
  AND time.hour BETWEEN 9 AND 17
  THEN ALLOW
```

---

### Input Validation

#### Validation Layers

```
┌─────────────────────────────────────────────────────────┐
│                    Validation Layers                     │
├─────────────────────────────────────────────────────────┤
│ Layer 1: Transport   │ JSON schema, content-type        │
├──────────────────────┼──────────────────────────────────┤
│ Layer 2: API         │ Required fields, formats, ranges │
├──────────────────────┼──────────────────────────────────┤
│ Layer 3: Business    │ Business rules, state validation │
├──────────────────────┼──────────────────────────────────┤
│ Layer 4: Database    │ Constraints, triggers            │
└──────────────────────┴──────────────────────────────────┘
```

#### Common Validations

| Input Type | Validations |
|------------|-------------|
| Email | Format, domain allowlist, MX record |
| Password | Length, complexity, breach check |
| URL | Protocol allowlist, domain check |
| File | Type (magic bytes), size, virus scan |
| Text | Length, encoding, sanitization |
| Number | Range, type, precision |

---

## Observability Patterns

### Structured Logging

```json
{
  "timestamp": "2024-01-15T10:30:00.123Z",
  "level": "INFO",
  "service": "order-service",
  "version": "1.2.3",
  "trace_id": "abc123def456",
  "span_id": "span789",
  "message": "Order created",
  "context": {
    "order_id": "ord_123",
    "user_id": "usr_456",
    "amount": 99.99,
    "items_count": 3
  },
  "duration_ms": 45
}
```

---

### Distributed Tracing

```
┌─────────────────────────────────────────────────────────────────┐
│ Trace: abc123                                                   │
├─────────────────────────────────────────────────────────────────┤
│ ├─ Span: API Gateway (15ms)                                     │
│ │  └─ Span: Auth Service (5ms)                                  │
│ ├─ Span: Order Service (25ms)                                   │
│ │  ├─ Span: Database Query (8ms)                                │
│ │  └─ Span: Payment Service (12ms)                              │
│ │     └─ Span: External Payment API (10ms)                      │
│ └─ Span: Notification Service (async, 3ms)                      │
└─────────────────────────────────────────────────────────────────┘
Total: 45ms (critical path)
```

---

### Metrics Types

| Type | Description | Example |
|------|-------------|---------|
| Counter | Cumulative count | `http_requests_total` |
| Gauge | Current value | `active_connections` |
| Histogram | Distribution | `request_duration_seconds` |
| Summary | Quantiles | `request_duration_quantiles` |

**RED Metrics (Request-focused):**
- **R**ate: Requests per second
- **E**rrors: Failed requests per second
- **D**uration: Request latency distribution

**USE Metrics (Resource-focused):**
- **U**tilization: Percentage of resource used
- **S**aturation: Queue depth, wait time
- **E**rrors: Error count

---

## Migration Strategies

### Database Migration Patterns

#### Expand and Contract

**Phase 1: Expand (add new)**
```sql
-- Add new column, allow null
ALTER TABLE users ADD COLUMN email_verified BOOLEAN;
```

**Phase 2: Migrate (dual write)**
```go
// Write to both old and new
user.Status = "verified"
user.EmailVerified = true  // New column
db.Save(user)
```

**Phase 3: Contract (remove old)**
```sql
-- After all code uses new column
ALTER TABLE users DROP COLUMN status;
```

---

#### Blue-Green Database

```
┌──────────────────────────────────────────────────┐
│                Blue-Green Migration              │
│                                                  │
│   ┌─────────┐                   ┌─────────┐     │
│   │  Blue   │                   │  Green  │     │
│   │ (v1.0)  │                   │ (v2.0)  │     │
│   └────┬────┘                   └────┬────┘     │
│        │                             │          │
│        ▼                             ▼          │
│   ┌─────────┐    replicate     ┌─────────┐     │
│   │ Blue DB │ ───────────────▶ │ Green DB│     │
│   │(current)│                   │  (new)  │     │
│   └─────────┘                   └─────────┘     │
│                                                  │
│   Switch: Update DNS/LB to point to Green       │
└──────────────────────────────────────────────────┘
```

---

### Service Migration Patterns

#### Strangler Fig Pattern

```
┌─────────────────────────────────────────────────┐
│            Strangler Fig Migration              │
│                                                 │
│  Phase 1:  All traffic → Legacy                 │
│            ┌─────────┐    ┌──────────┐          │
│            │  Proxy  │───▶│  Legacy  │          │
│            └─────────┘    └──────────┘          │
│                                                 │
│  Phase 2:  Route /api/v2 → New                  │
│            ┌─────────┐    ┌──────────┐          │
│            │  Proxy  │───▶│  Legacy  │          │
│            │         │    └──────────┘          │
│            │         │    ┌──────────┐          │
│            │         │───▶│   New    │          │
│            └─────────┘    └──────────┘          │
│                                                 │
│  Phase 3:  All traffic → New                    │
│            ┌─────────┐    ┌──────────┐          │
│            │  Proxy  │───▶│   New    │          │
│            └─────────┘    └──────────┘          │
└─────────────────────────────────────────────────┘
```

---

## Decision Framework

### Technology Selection Criteria

| Criterion | Weight | Questions |
|-----------|--------|-----------|
| Team expertise | High | Does team know this tech? |
| Ecosystem | Medium | Are libraries/tools available? |
| Performance | Varies | Does it meet our requirements? |
| Scalability | Varies | Can it grow with us? |
| Maintainability | High | Is it actively maintained? |
| Cost | Medium | What's TCO? |
| Risk | High | What's the blast radius of failure? |

### Build vs Buy

| Factor | Build | Buy |
|--------|-------|-----|
| Core differentiator | ✅ | |
| Commoditized function | | ✅ |
| Team has expertise | ✅ | |
| Time-to-market critical | | ✅ |
| Long-term cost sensitive | ✅ | |
| Need full control | ✅ | |
| Need support/SLA | | ✅ |

---

## Anti-Patterns Reference

### Architecture Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Big Ball of Mud | No clear structure | Define modules, boundaries |
| Golden Hammer | One solution for all | Right tool for the job |
| Distributed Monolith | Microservices without benefits | True loose coupling |
| Death Star | Everything connects to one service | Decentralize |

### API Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Chatty API | Too many round trips | Batch endpoints, GraphQL |
| Anemic API | Just CRUD, no business | Add business operations |
| Swiss Army Knife | One endpoint does everything | Single responsibility |
| Version Hell | Breaking changes | Semantic versioning, deprecation |

### Data Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Entity Attribute Value | Schema-less in SQL | Proper schema, or use document DB |
| God Table | One table for everything | Normalize |
| ID as String | "user_123" as PK | Use proper UUID/int |
| Missing Indexes | Slow queries | Analyze and add indexes |
