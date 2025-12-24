# SSR Migration - Technical Specification

## Document Info

| Field | Value |
|-------|-------|
| **Spec ID** | TS-2025-001 |
| **Author** | Pedro |
| **Date** | 2025-11-27 |
| **Version** | 1.0 |
| **Status** | Draft |
| **Priority** | P1 - Post-CSRF |
| **Prerequisites** | CSRF implementation complete |

---

## System Overview

### Problem Statement

The current frontend is a Client-Side Rendered (CSR) Vite SPA. This exposes:
1. **Security risk**: All API endpoints visible in browser Network tab
2. **Mobile performance**: Slower initial load, no pre-rendered content
3. **Architecture mismatch**: Original requirement was SSR with React Router 7

### Proposed Solution

Migrate to React Router 7 Framework Mode with server-side rendering. Replace JWT localStorage auth with PostgreSQL-backed session cookies. All data fetching moves to server-side loaders.

### Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| SSR Framework | React Router 7 Framework Mode | Already using React Router, minimal paradigm shift |
| Auth Strategy | Session-based (PostgreSQL + HTTP-only cookie) | Most secure, server-side only |
| Data Fetching | Route loaders | RR7 native, eliminates useEffect patterns |
| CSRF Integration | Keep existing double-submit cookie | Already implemented, SSR-compatible |

### Scope

**In Scope:**
- React Router 7 Framework Mode setup
- PostgreSQL session store + session middleware
- Convert all 13 routes to loader pattern
- Mantine SSR configuration
- i18n SSR support

**Out of Scope:**
- React Server Components (future enhancement)
- Streaming SSR (future enhancement)
- Edge deployment (remain on Node.js server)

---

## Component Architecture

### System Diagram (Target State)

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │   React Router  │     │                 │
│     Browser     │────▶│   Node Server   │────▶│   Go Backend    │
│                 │     │   (SSR + API)   │     │   (API Only)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
        │                       │                       │
        ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Hydrated App   │     │  Session Check  │     │   PostgreSQL    │
│  (Client JS)    │     │  Cookie Forward │     │   (Sessions +   │
│                 │     │                 │     │    App Data)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### Component Details

#### React Router Node Server

| Aspect | Description |
|--------|-------------|
| **Responsibility** | Handle SSR rendering, route matching, loader execution |
| **Inputs** | HTTP requests from browser |
| **Outputs** | Pre-rendered HTML + hydration data |
| **Dependencies** | Go backend API (via internal network) |
| **Location** | `frontend/server.ts` or `frontend/app/entry.server.tsx` |

#### Session Store (PostgreSQL)

| Aspect | Description |
|--------|-------------|
| **Responsibility** | Persist user sessions, validate session cookies |
| **Inputs** | Session ID from HTTP-only cookie |
| **Outputs** | User context for authenticated requests |
| **Dependencies** | PostgreSQL database |
| **Location** | `backend/internal/services/session_store.go` |

#### Route Loaders

| Aspect | Description |
|--------|-------------|
| **Responsibility** | Server-side data fetching for each route |
| **Inputs** | Request object with cookies |
| **Outputs** | JSON data for component rendering |
| **Dependencies** | Go backend API |
| **Location** | `frontend/app/routes/*.tsx` |

---

## API Design

### New Backend Endpoints

#### GET /api/auth/me

**Description:** Returns current authenticated user from session

**Authentication:** Session cookie (HTTP-only)

**Request Headers:**
| Header | Required | Description |
|--------|----------|-------------|
| `Cookie` | Yes | Contains `session_id` |

**Response (200 OK):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "User Name",
  "role": "user",
  "language": "en"
}
```

**Error Responses:**
| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | No valid session |

---

#### POST /api/auth/login (Modified)

**Description:** Authenticate user, create session, set cookie

**Request Body:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response (200 OK):**
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "User Name",
    "role": "user"
  }
}
```

**Response Headers:**
```
Set-Cookie: session_id=<uuid>; HttpOnly; Secure; SameSite=Strict; Path=/; Max-Age=86400
```

---

#### POST /api/auth/logout (Modified)

**Description:** Destroy session, clear cookie

**Response (200 OK):**
```json
{
  "status": "logged_out"
}
```

**Response Headers:**
```
Set-Cookie: session_id=; HttpOnly; Secure; SameSite=Strict; Path=/; Max-Age=0
```

---

## Data Model

### Entity: Session

**Table:** `sessions`

**Description:** Stores active user sessions for server-side auth

| Column | Type | Constraints | Default | Description |
|--------|------|-------------|---------|-------------|
| `id` | UUID | PK | gen_random_uuid() | Session identifier (cookie value) |
| `user_id` | INTEGER | FK, NOT NULL | - | Reference to users table |
| `data` | JSONB | - | '{}' | Optional session metadata |
| `expires_at` | TIMESTAMP | NOT NULL | - | Session expiry time |
| `created_at` | TIMESTAMP | NOT NULL | NOW() | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | NOW() | Last activity timestamp |

**Indexes:**

| Name | Columns | Type | Purpose |
|------|---------|------|---------|
| `idx_sessions_user_id` | (user_id) | BTREE | Find sessions by user |
| `idx_sessions_expires_at` | (expires_at) | BTREE | Cleanup expired sessions |

**Relationships:**

| Relation | Target | Type | On Delete |
|----------|--------|------|-----------|
| Belongs to | users | N:1 | CASCADE |

### Migration Script

```sql
-- Migration: 005_add_sessions.sql

CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    data JSONB DEFAULT '{}',
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_expires_at ON sessions(expires_at);

-- Cleanup job: Delete expired sessions
-- Run via scheduler: DELETE FROM sessions WHERE expires_at < NOW();
```

---

## Implementation Approach

### Frontend Migration Pattern

**Current (CSR):**
```typescript
// src/routes/Dashboard.tsx
export default function Dashboard() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData().then(setData).finally(() => setLoading(false));
  }, []);

  if (loading) return <Loader />;
  return <DashboardContent data={data} />;
}
```

**Target (SSR):**
```typescript
// app/routes/_app._index.tsx
import type { Route } from "./+types/_app._index";

export async function loader({ request }: Route.LoaderArgs) {
  const cookie = request.headers.get("Cookie");

  const [pending, approved] = await Promise.all([
    fetch(`${API_URL}/api/videos?status=pending`, {
      headers: { Cookie: cookie }
    }),
    fetch(`${API_URL}/api/videos?status=approved`, {
      headers: { Cookie: cookie }
    }),
  ]);

  return {
    pendingCount: (await pending.json()).total,
    approvedCount: (await approved.json()).total,
  };
}

export default function Dashboard({ loaderData }: Route.ComponentProps) {
  const { pendingCount, approvedCount } = loaderData;
  return <DashboardContent data={{ pendingCount, approvedCount }} />;
}
```

### Route File Structure

```
frontend/
├── react-router.config.ts
├── vite.config.ts (modified)
├── app/
│   ├── entry.server.tsx
│   ├── entry.client.tsx
│   ├── root.tsx
│   ├── routes/
│   │   ├── _index.tsx              # Redirect to /dashboard
│   │   ├── _auth.tsx               # Auth layout (public)
│   │   ├── _auth.login.tsx         # /login
│   │   ├── _auth.register.tsx      # /register
│   │   ├── _app.tsx                # App layout (protected)
│   │   ├── _app._index.tsx         # /dashboard
│   │   ├── _app.upload.tsx         # /upload
│   │   ├── _app.catalog.tsx        # /catalog
│   │   ├── _app.catalog.$mediaId.tsx
│   │   ├── _app.groups.tsx         # /groups
│   │   ├── _app.groups.$groupId.tsx
│   │   ├── _app.tags.tsx
│   │   ├── _app.categories.tsx
│   │   ├── _app.activity.tsx
│   │   ├── _app.admin.approval.tsx
│   │   └── _app.admin.quarantine.tsx
│   └── components/                  # Shared components
└── src/                             # (deprecated, migrate to app/)
```

### CSRF Integration

**Existing CSRF middleware** (`backend/internal/middleware/csrf.go`) uses double-submit cookie pattern. Compatible with SSR:

1. Server sets `csrf_token` cookie on page load
2. Frontend reads cookie (not HttpOnly)
3. Mutations include `X-CSRF-Token` header
4. Backend validates header matches cookie

```typescript
// app/utils/csrf.ts
export function getCSRFToken(): string {
  if (typeof document === 'undefined') return '';
  const match = document.cookie.match(/csrf_token=([^;]+)/);
  return match ? match[1] : '';
}

// Usage in mutations
async function submitForm(data: FormData) {
  await fetch('/api/...', {
    method: 'POST',
    headers: {
      'X-CSRF-Token': getCSRFToken(),
      'Content-Type': 'application/json',
    },
    credentials: 'include',
    body: JSON.stringify(data),
  });
}
```

---

## Testing Strategy

### Unit Tests

| Component | What to Test | Coverage Target |
|-----------|--------------|-----------------|
| Session Store | CRUD operations, expiry | 90%+ |
| Session Middleware | Cookie parsing, validation | 90%+ |
| Auth Handler | Login/logout session creation | 90%+ |

### Integration Tests

| Test Area | Scope | Dependencies |
|-----------|-------|--------------|
| Session auth flow | Login → session → authenticated request | Test database |
| SSR rendering | Route renders with loader data | Test server |
| Cookie forwarding | Session cookie passed to backend | Test server |

### E2E Tests

| Scenario | Steps | Expected Outcome |
|----------|-------|------------------|
| SSR smoke test | Load dashboard | HTML contains pre-rendered content |
| Login flow | Submit credentials | Session cookie set, redirect to dashboard |
| Protected route | Access /dashboard without auth | Redirect to /login |
| Logout flow | Click logout | Cookie cleared, redirect to login |

### SSR-Specific Tests

```typescript
// e2e/ssr.spec.ts
test('dashboard renders server-side', async ({ page }) => {
  // Login first
  await login(page);

  // Get page HTML before JS executes
  const html = await page.content();

  // Verify SSR content
  expect(html).toContain('Dashboard');
  expect(html).not.toContain('Loading...');
});

test('session cookie is HttpOnly', async ({ page }) => {
  await login(page);

  const cookies = await page.context().cookies();
  const session = cookies.find(c => c.name === 'session_id');

  expect(session).toBeDefined();
  expect(session.httpOnly).toBe(true);
  expect(session.secure).toBe(true);
  expect(session.sameSite).toBe('Strict');
});
```

---

## Security Considerations

### Authentication

| Aspect | Implementation |
|--------|----------------|
| Method | Session-based (PostgreSQL store) |
| Token Location | HTTP-only, Secure, SameSite=Strict cookie |
| Token Lifetime | 24 hours (configurable) |
| Token Storage | PostgreSQL `sessions` table |
| Rotation | On sensitive operations (password change) |

### Authorization

| Aspect | Implementation |
|--------|----------------|
| Model | RBAC (admin/user roles) |
| Enforcement Point | Go backend middleware |
| Permission Granularity | Route-level + resource-level |

### Cookie Security

| Cookie | HttpOnly | Secure | SameSite | Purpose |
|--------|----------|--------|----------|---------|
| `session_id` | Yes | Yes | Strict | Auth session |
| `csrf_token` | No | Yes | Strict | CSRF protection |

### Security Checklist

- [x] CSRF protection (existing double-submit cookie)
- [ ] Session-based auth (PostgreSQL store)
- [ ] HTTP-only session cookies
- [ ] Secure cookies (HTTPS only)
- [ ] SameSite=Strict
- [ ] Session expiry + cleanup
- [ ] API endpoints hidden from browser

---

## Migration & Rollout

### Migration Steps

| Step | Action | Validation | Rollback |
|------|--------|------------|----------|
| 1 | Add sessions table migration | Run migration, verify table | Drop table |
| 2 | Implement session store + middleware | Unit tests pass | Revert code |
| 3 | Update auth handlers (login/logout) | Auth flow works | Revert code |
| 4 | Setup RR7 infrastructure | Build succeeds | Remove config |
| 5 | Migrate routes one-by-one | Route renders correctly | Revert route |
| 6 | Remove JWT auth code | All tests pass | Restore code |
| 7 | Remove old src/ directory | Build succeeds | Restore files |

### Rollout Plan

| Phase | Target | Duration | Success Criteria |
|-------|--------|----------|------------------|
| 0 | Development | 2-3 weeks | All routes migrated |
| 1 | Staging | 1 week | E2E tests pass |
| 2 | Production | - | Monitoring green |

### Rollback Plan

**If issues in production:**
1. Revert to previous CSR build
2. Re-enable JWT auth endpoints
3. Clear sessions table
4. Investigate and fix

---

## File Changes Summary

### Backend (Create)

| File | Purpose |
|------|---------|
| `migrations/005_add_sessions.sql` | Session table |
| `internal/services/session_store.go` | Session CRUD |
| `internal/services/session_store_test.go` | Unit tests |
| `internal/middleware/session.go` | Session middleware |

### Backend (Modify)

| File | Changes |
|------|---------|
| `internal/handlers/auth_handler.go` | Session-based login/logout |
| `internal/middleware/auth.go` | Replace JWT with session check |
| `cmd/api/main.go` | Add session middleware |

### Frontend (Create)

| File | Purpose |
|------|---------|
| `react-router.config.ts` | RR7 configuration |
| `app/entry.server.tsx` | Server entry point |
| `app/entry.client.tsx` | Client entry point |
| `app/root.tsx` | Root layout |
| `app/routes/_app.tsx` | Protected layout |
| `app/routes/_auth.tsx` | Auth layout |
| `app/routes/*.tsx` | 13 route modules |
| `app/utils/csrf.ts` | CSRF helper |

### Frontend (Delete)

| File | Reason |
|------|--------|
| `src/services/auth.ts` | Replaced by session |
| `src/contexts/AuthContext.tsx` | Replaced by root loader |
| `src/components/ProtectedRoute.tsx` | Replaced by layout routes |
| `src/routes/*.tsx` | Moved to app/routes/ |

---

## Effort Estimate

| Phase | Effort | Description |
|-------|--------|-------------|
| Backend Sessions | 16-20h | Migration, store, middleware, auth changes |
| RR7 Infrastructure | 12-16h | Config, entry points, Vite setup |
| Route Migration | 24-32h | Convert 13 routes to loaders |
| Mantine SSR | 4-6h | CSS extraction, ClientOnly wrappers |
| i18n SSR | 4-6h | Server-side language detection |
| Testing | 12-16h | E2E, hydration, security |
| **Total** | **72-96h** | ~2-3 weeks |

---

## Open Questions

| Question | Owner | Status |
|----------|-------|--------|
| Session expiry duration? (24h proposed) | Pedro | Open |
| Multi-device session support? | Pedro | Open |
| Session cleanup scheduler interval? | Pedro | Open |

---

## References

- [React Router 7 Framework Mode](https://reactrouter.com/how-to/framework-mode)
- [Mantine SSR](https://mantine.dev/guides/ssr/)
- Existing CSRF spec: `backend/internal/middleware/csrf.go`
- Related spec: `docs/product-specs/authentication-spec.md`

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-27 | Pedro | Initial draft |
