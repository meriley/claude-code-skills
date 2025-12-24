# Security Hardening Initiative - Product Requirements Document

## Document Info

| Field | Value |
|-------|-------|
| **Author** | Pedro |
| **Date** | 2025-11-27 |
| **Version** | 1.0 |
| **Status** | Draft |
| **Stakeholders** | Product, Engineering, Security |
| **Target Release** | Q1 2025 |

---

## Executive Summary

Demi-upload users are at risk of account compromise due to session tokens being vulnerable to theft via XSS attacks. Additionally, users cannot trust that their sessions end when they log out, and malicious actors could potentially access all media through search manipulation. This initiative hardens authentication and authorization to protect user data and meet security best practices.

---

## Problem Statement

### The Problem

Users' authentication tokens are stored in browser localStorage, which is accessible to any JavaScript running on the page. A single XSS vulnerability—whether in our code, a third-party library, or a browser extension—could allow attackers to steal user sessions and access all their private media.

**Key insight:** Security isn't just a technical concern—users trust us with their personal media, and that trust requires defense-in-depth protection that current architecture doesn't provide.

### Who is Affected

| Persona | Description | Impact |
|---------|-------------|--------|
| **Media Uploader** | Primary user storing personal/sensitive media | Session theft exposes all private files |
| **Group Admin** | Manages shared collections with team members | Compromised admin could expose entire group |
| **Enterprise User** | Organization requiring compliance | Cannot pass security audit with current gaps |

### Current State

- Users authenticate and receive JWT tokens stored in localStorage
- Tokens remain valid until expiry even after "logout"
- No protection against cross-site request forgery
- Search patterns not sanitized, allowing enumeration attacks
- Users have no visibility into active sessions

### Impact of Not Solving

| Impact Type | Description | Quantification |
|-------------|-------------|----------------|
| User Impact | Account compromise, media theft | Any XSS = total account compromise |
| Business Impact | Reputation damage, user trust loss | 1 breach = significant churn risk |
| Compliance Impact | Cannot meet SOC2/enterprise requirements | Blocks enterprise sales |

---

## Proposed Solution

### Overview

Migrate authentication to HttpOnly cookies (inaccessible to JavaScript), add CSRF protection, implement token revocation on logout, and sanitize all user inputs to prevent injection attacks.

### User Stories

---

#### US-1: Secure Session Storage

**As a** media uploader,
**I want** my login session to be protected from malicious scripts,
**So that** even if there's a vulnerability in the page, attackers cannot steal my session.

**Acceptance Criteria:**

```gherkin
Scenario: Secure cookie-based authentication
  Given I am on the login page
  When I enter valid credentials and submit
  Then I am logged in successfully
  And my session token is stored in an HttpOnly cookie
  And JavaScript cannot access the token (document.cookie returns empty for auth tokens)
  And the cookie has Secure flag (HTTPS only)
  And the cookie has SameSite=Strict attribute

Scenario: Session persists across page reloads
  Given I am logged in with cookie-based auth
  When I refresh the page or navigate to another page
  Then I remain logged in
  And no token appears in localStorage

```

**Priority:** Must Have
**Estimated Size:** M (simplified - no migration needed)

---

#### US-2: True Logout

**As a** security-conscious user,
**I want** my session to actually end when I log out,
**So that** if my device is compromised after logout, my account remains safe.

**Acceptance Criteria:**

```gherkin
Scenario: Logout invalidates token
  Given I am logged in
  When I click logout
  Then my session cookie is cleared
  And the token is added to a server-side revocation list
  And attempting to use the old token returns 401 Unauthorized

Scenario: Multiple device logout
  Given I am logged in on Device A and Device B
  When I log out on Device A
  Then my session on Device A is invalidated
  But my session on Device B remains active

Scenario: Revocation persists briefly after logout
  Given I logged out 5 minutes ago
  And an attacker has my old token
  When they attempt to use it
  Then they receive 401 Unauthorized
```

**Priority:** Must Have
**Estimated Size:** M

---

#### US-3: CSRF Protection

**As a** user,
**I want** my actions to only execute when I intentionally perform them,
**So that** malicious websites cannot trick my browser into performing unwanted actions.

**Acceptance Criteria:**

```gherkin
Scenario: State-changing requests require CSRF token
  Given I am logged in
  When I submit a form to upload/delete/modify media
  Then the request includes a CSRF token
  And the server validates the token matches my session
  And the action succeeds

Scenario: Missing CSRF token is rejected
  Given I am logged in
  And a malicious site tries to submit a form to my account
  When the request lacks a valid CSRF token
  Then the server returns 403 Forbidden
  And no action is performed

Scenario: Safe methods don't require CSRF
  Given I am logged in
  When I make GET, HEAD, or OPTIONS requests
  Then no CSRF token is required
  And the request succeeds
```

**Priority:** Must Have
**Estimated Size:** M

---

#### US-4: Private Search Results

**As a** user,
**I want** search to only return my matching media,
**So that** I can't accidentally (or maliciously) see all records by entering special characters.

**Acceptance Criteria:**

```gherkin
Scenario: Normal search works correctly
  Given I have media titled "Vacation Photos"
  When I search for "Vacation"
  Then I see "Vacation Photos" in results
  And I only see my own media

Scenario: Wildcard characters are escaped
  Given I search for "%"
  Then I see only media with "%" in the title
  And I do NOT see all records returned

Scenario: SQL special characters are safe
  Given I search for "'; DROP TABLE media; --"
  Then the search returns no results (or only matching titles)
  And no database error occurs
  And the media table is unaffected
```

**Priority:** Must Have
**Estimated Size:** S

---

#### US-5: Validated File Uploads

**As a** user uploading media,
**I want** malicious files to be rejected,
**So that** my uploads don't become vectors for attacks on myself or others.

**Acceptance Criteria:**

```gherkin
Scenario: Valid images are accepted
  Given I upload a valid JPEG image
  When the file is processed
  Then the upload succeeds
  And EXIF metadata is stripped (privacy protection)
  And the file is stored safely

Scenario: Mismatched extensions are rejected
  Given I upload a file named "image.jpg" that is actually a PHP script
  When the file is validated
  Then the upload is rejected with "File type mismatch" error
  And the file is not stored

Scenario: EXIF stripping failures are handled safely
  Given I upload a JPEG with corrupted EXIF data
  When EXIF stripping fails
  Then the upload is rejected (not stored with original EXIF)
  And I receive "Cannot process image safely" error
```

**Priority:** Should Have
**Estimated Size:** M

---

#### US-6: Responsive Application

**As a** user,
**I want** the application to remain responsive even under load,
**So that** slow operations don't hang indefinitely.

**Acceptance Criteria:**

```gherkin
Scenario: Long-running requests timeout gracefully
  Given a request takes longer than 30 seconds
  When the timeout is reached
  Then the user receives a "Request timeout" error
  And server resources are freed
  And the user can retry

Scenario: Upload endpoints have extended timeout
  Given I am uploading a large file
  When the upload takes up to 5 minutes
  Then the upload continues (extended timeout)
  And I receive success or failure feedback
```

**Priority:** Should Have
**Estimated Size:** S

---

### User Journey

```
[Login] → [Cookie Set (HttpOnly)] → [CSRF Token Generated]
                                           ↓
[Browse/Search] ←────────────── [API Requests with Cookie + CSRF]
     ↓
[Upload Media] → [File Validated] → [EXIF Stripped] → [Stored]
     ↓
[Logout] → [Cookie Cleared] → [Token Revoked] → [Session Invalid]
```

---

## Scope

### In Scope

| Item | Description | Priority |
|------|-------------|----------|
| HttpOnly Cookie Auth | Move JWT from localStorage to secure cookies | Must Have |
| CSRF Protection | Double-submit cookie pattern for state changes | Must Have |
| Token Revocation | Server-side blacklist on logout | Must Have |
| Search Sanitization | Escape LIKE wildcards in search | Must Have |
| File Validation Hardening | Extension/MIME matching, EXIF failure handling | Should Have |
| Request Timeouts | Prevent hung requests | Should Have |
| Rate Limiter Improvement | Better cleanup, prevent memory leaks | Should Have |
| N+1 Query Fixes | Preload associations for performance | Nice to Have |
| API Race Condition Fix | Prevent concurrent token refresh | Nice to Have |
| Error Logging Enhancement | Add context to error logs | Nice to Have |

### Out of Scope

| Item | Reason | Future Consideration |
|------|--------|---------------------|
| Password Special Characters | NIST 800-63B recommends against | P2 - Blocklist instead |
| Redis Token Store | Single-server currently | Yes - when scaling |
| MFA/2FA | Larger initiative | Yes - Q2 2025 |
| Session Management UI | Show active sessions | Yes - P2 |
| Penetration Testing | Separate engagement | Yes - post-release |

### Dependencies

| Dependency | Owner | Status | Risk |
|------------|-------|--------|------|
| Frontend Build/Deploy | Engineering | Ready | Low |
| Backend Deploy Pipeline | Engineering | Ready | Low |
| Browser Cookie Support | External | Ready | Low |

### Assumptions

- Single backend server (in-memory token revocation acceptable)
- Users primarily use modern browsers (cookie support)
- No mobile apps currently depend on Bearer token auth
- Frontend can be deployed alongside backend changes

### Open Questions

- [x] Password special characters? **Decision: Skip per NIST guidelines**
- [x] Distributed token revocation? **Decision: Interface-based, in-memory now, Redis-ready**
- [x] Test coverage priority? **Decision: Security-first (4-6h critical tests)**
- [x] Migration period? **Decision: None needed - not deployed, no users**
- [x] User communication? **Decision: None needed - not deployed**

---

## Success Metrics

### Key Results

| Metric | Current State | Target | Timeline | Measurement Method |
|--------|--------------|--------|----------|-------------------|
| XSS Token Theft Risk | HIGH (tokens in localStorage) | NONE (HttpOnly cookies) | Week 2 | Security audit |
| Post-Logout Token Validity | Valid until expiry (7 days) | Immediate revocation | Week 3 | Security test |
| CSRF Protection | None | 100% state-change coverage | Week 2 | Security audit |
| Search Injection Risk | HIGH (% returns all) | NONE (escaped) | Week 1 | Penetration test |

### Leading Indicators (Early Signals)

| Indicator | Target | Why It Matters |
|-----------|--------|----------------|
| Auth test coverage | 95%+ | High coverage = fewer security regressions |
| CSRF middleware test coverage | 100% | Critical security component |
| Zero localStorage tokens | 100% | Confirms migration complete |

### Guardrails (Don't Break These)

| Guardrail | Threshold | Action if Breached |
|-----------|-----------|-------------------|
| Login success rate | >= 99% | Rollback cookie auth |
| API error rate | < 1% | Investigate immediately |
| Session duration complaints | 0 | Extend cookie lifetime |

---

## Timeline & Milestones

| Milestone | Target Date | Description | Success Criteria |
|-----------|-------------|-------------|------------------|
| PRD Approved | Week 0 | Requirements finalized | Stakeholder sign-off |
| Phase 1: Auth Security | Week 2 | Cookies, CSRF, search fix | Security tests pass |
| Phase 2: Token Revocation | Week 3 | Logout invalidates tokens | Revocation tests pass |
| Phase 3: File Security | Week 4 | Validation hardening | Edge case tests pass |
| Phase 4: Performance | Week 5 | Timeouts, N+1 fixes | Performance benchmarks |
| Full Release | Week 5 | All features complete | All tests pass, audit clean |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation | Owner |
|------|------------|--------|------------|-------|
| Token revocation memory growth | Low | Low | TTL cleanup, monitor memory | Engineering |
| Implementation complexity | Low | Medium | Phased approach, tests first | Engineering |

**Note:** No migration risks - application not yet deployed.

---

## Appendix

### Research / Data

| Source | Summary | Link |
|--------|---------|------|
| OWASP Session Management | Best practices for token storage | [OWASP](https://owasp.org) |
| NIST 800-63B | Password guidelines (no special chars) | [NIST](https://nist.gov) |
| Hermes Code Review | 15 findings across security/performance | Internal |

### Related Documents

| Document | Description | Link |
|----------|-------------|------|
| Implementation Plan | Technical implementation details | Below |
| Code Review Report | Original findings | Hermes Agent Output |

---

## Approval

| Role | Name | Status | Date |
|------|------|--------|------|
| Product | Pedro | [ ] Pending | |
| Engineering | Pedro | [ ] Pending | |
| Security | Pedro | [ ] Pending | |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-27 | Pedro | Initial draft from code review |

---

---

# Implementation Plan

## Overview

Since the application is not yet deployed, we can implement security features aggressively without migration concerns. Total effort: ~40-50 hours across 4 phases.

---

## Phase 1: Authentication Security (Days 1-3)

### 1.1 HttpOnly Cookie Implementation

**Files to Modify:**

| File | Changes |
|------|---------|
| `backend/internal/handlers/auth.go` | Set HttpOnly cookies in Login/Register/Refresh, remove tokens from JSON response |
| `backend/internal/middleware/auth.go` | Extract token from cookie instead of Authorization header |
| `frontend/src/services/api.ts` | Remove all localStorage usage, rely on cookies |

**Backend Cookie Helper:**
```go
// backend/internal/handlers/auth.go
func setAuthCookies(w http.ResponseWriter, accessToken, refreshToken string, cfg *config.Config) {
    http.SetCookie(w, &http.Cookie{
        Name:     "access_token",
        Value:    accessToken,
        HttpOnly: true,
        Secure:   !cfg.IsDevelopment,
        SameSite: http.SameSiteStrictMode,
        Path:     "/api",
        MaxAge:   int(constants.AccessTokenDuration.Seconds()),
    })
    http.SetCookie(w, &http.Cookie{
        Name:     "refresh_token",
        Value:    refreshToken,
        HttpOnly: true,
        Secure:   !cfg.IsDevelopment,
        SameSite: http.SameSiteStrictMode,
        Path:     "/api/auth/refresh",
        MaxAge:   int(constants.RefreshTokenDuration.Seconds()),
    })
}

func clearAuthCookies(w http.ResponseWriter) {
    http.SetCookie(w, &http.Cookie{Name: "access_token", MaxAge: -1, Path: "/api"})
    http.SetCookie(w, &http.Cookie{Name: "refresh_token", MaxAge: -1, Path: "/api/auth/refresh"})
}
```

**Middleware Token Extraction:**
```go
// backend/internal/middleware/auth.go
func extractToken(r *http.Request) string {
    // Cookie-based (primary)
    if cookie, err := r.Cookie("access_token"); err == nil {
        return cookie.Value
    }
    return ""
}
```

**Frontend Changes:**
```typescript
// frontend/src/services/api.ts
// Remove ALL of these:
// - localStorage.getItem('access_token')
// - localStorage.setItem('access_token', ...)
// - localStorage.removeItem('access_token')

// Axios already sends cookies with:
const client = axios.create({
    baseURL: API_BASE_URL,
    withCredentials: true,  // This sends cookies automatically
})
```

---

### 1.2 CSRF Protection

**New File:** `backend/internal/middleware/csrf.go`

```go
package middleware

import (
    "crypto/rand"
    "encoding/base64"
    "net/http"
)

type CSRFMiddleware struct {
    cookieName string
    headerName string
    secure     bool
}

func NewCSRFMiddleware(secure bool) *CSRFMiddleware {
    return &CSRFMiddleware{
        cookieName: "csrf_token",
        headerName: "X-CSRF-Token",
        secure:     secure,
    }
}

func (m *CSRFMiddleware) GenerateToken() string {
    b := make([]byte, 32)
    rand.Read(b)
    return base64.URLEncoding.EncodeToString(b)
}

func (m *CSRFMiddleware) SetToken(w http.ResponseWriter, token string) {
    http.SetCookie(w, &http.Cookie{
        Name:     m.cookieName,
        Value:    token,
        HttpOnly: false,  // Must be readable by JS
        Secure:   m.secure,
        SameSite: http.SameSiteStrictMode,
        Path:     "/",
    })
}

func (m *CSRFMiddleware) Protect(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // Skip safe methods
        if r.Method == "GET" || r.Method == "HEAD" || r.Method == "OPTIONS" {
            next.ServeHTTP(w, r)
            return
        }

        cookie, err := r.Cookie(m.cookieName)
        if err != nil {
            http.Error(w, "CSRF token missing", http.StatusForbidden)
            return
        }

        header := r.Header.Get(m.headerName)
        if header == "" || header != cookie.Value {
            http.Error(w, "CSRF token mismatch", http.StatusForbidden)
            return
        }

        next.ServeHTTP(w, r)
    })
}
```

**Frontend CSRF Handling:**
```typescript
// frontend/src/services/api.ts
client.interceptors.request.use((config) => {
    // Read CSRF token from cookie
    const csrfToken = document.cookie
        .split('; ')
        .find(row => row.startsWith('csrf_token='))
        ?.split('=')[1]

    if (csrfToken && ['POST', 'PUT', 'PATCH', 'DELETE'].includes(config.method?.toUpperCase() || '')) {
        config.headers['X-CSRF-Token'] = csrfToken
    }
    return config
})
```

---

### 1.3 Search Wildcard Escaping

**File:** `backend/internal/repositories/media_repository.go`

```go
// Add helper
func escapeLikeWildcards(s string) string {
    s = strings.ReplaceAll(s, "\\", "\\\\")
    s = strings.ReplaceAll(s, "%", "\\%")
    s = strings.ReplaceAll(s, "_", "\\_")
    return s
}

// Update in applyMediaFilters:
if filters.Search != "" {
    searchPattern := "%" + escapeLikeWildcards(filters.Search) + "%"
    query = query.Where(
        "title ILIKE ? OR filename ILIKE ? OR description ILIKE ?",
        searchPattern, searchPattern, searchPattern,
    )
}
```

---

## Phase 2: Token Revocation (Days 4-5)

### 2.1 Token Blacklist

**New File:** `backend/internal/auth/blacklist.go`

```go
package auth

import (
    "sync"
    "time"
)

type TokenBlacklist interface {
    Add(jti string, expiry time.Time) error
    IsRevoked(jti string) bool
    Cleanup() error
    Stop()
}

type MemoryBlacklist struct {
    tokens map[string]time.Time
    mu     sync.RWMutex
    stop   chan struct{}
}

func NewMemoryBlacklist() *MemoryBlacklist {
    b := &MemoryBlacklist{
        tokens: make(map[string]time.Time),
        stop:   make(chan struct{}),
    }
    go b.cleanupLoop()
    return b
}

func (b *MemoryBlacklist) Add(jti string, expiry time.Time) error {
    b.mu.Lock()
    defer b.mu.Unlock()
    b.tokens[jti] = expiry
    return nil
}

func (b *MemoryBlacklist) IsRevoked(jti string) bool {
    b.mu.RLock()
    defer b.mu.RUnlock()
    _, exists := b.tokens[jti]
    return exists
}

func (b *MemoryBlacklist) Cleanup() error {
    b.mu.Lock()
    defer b.mu.Unlock()
    now := time.Now()
    for jti, expiry := range b.tokens {
        if now.After(expiry) {
            delete(b.tokens, jti)
        }
    }
    return nil
}

func (b *MemoryBlacklist) cleanupLoop() {
    ticker := time.NewTicker(5 * time.Minute)
    defer ticker.Stop()
    for {
        select {
        case <-ticker.C:
            b.Cleanup()
        case <-b.stop:
            return
        }
    }
}

func (b *MemoryBlacklist) Stop() {
    close(b.stop)
}
```

### 2.2 JWT Claims Update

**File:** `backend/internal/auth/jwt.go`

```go
// Add JTI to claims
type Claims struct {
    UserID uint   `json:"sub"`
    Email  string `json:"email"`
    Name   string `json:"name"`
    Role   string `json:"role"`
    Type   string `json:"type"`
    JTI    string `json:"jti"`  // ADD: JWT ID for revocation
    jwt.RegisteredClaims
}

// Generate JTI in token creation
func (s *JWTService) GenerateTokens(user *models.User) (string, string, error) {
    jti := uuid.New().String()  // Generate unique ID
    // ... use jti in claims
}
```

### 2.3 Middleware Integration

```go
// backend/internal/middleware/auth.go
func (m *AuthMiddleware) RequireAuth(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        token := extractToken(r)
        claims, err := m.jwtService.ValidateToken(token)
        if err != nil {
            respondUnauthorized(w, "Invalid token")
            return
        }

        // Check blacklist
        if m.blacklist.IsRevoked(claims.JTI) {
            respondUnauthorized(w, "Token revoked")
            return
        }

        // Continue...
    })
}
```

---

## Phase 3: Input Validation & File Security (Days 6-7)

### 3.1 File Extension Validation

**File:** `backend/internal/services/validation.go`

```go
var mimeToExtensions = map[string][]string{
    "image/jpeg": {".jpg", ".jpeg"},
    "image/png":  {".png"},
    "image/gif":  {".gif"},
    "image/webp": {".webp"},
    "video/mp4":  {".mp4"},
    "video/webm": {".webm"},
    "audio/mpeg": {".mp3"},
    "audio/wav":  {".wav"},
}

func validateExtension(filename, mimeType string) error {
    ext := strings.ToLower(filepath.Ext(filename))
    allowedExts, ok := mimeToExtensions[mimeType]
    if !ok {
        return nil // Unknown MIME, skip extension check
    }
    for _, allowed := range allowedExts {
        if ext == allowed {
            return nil
        }
    }
    return fmt.Errorf("extension %s does not match MIME type %s", ext, mimeType)
}
```

### 3.2 EXIF Failure Handling

```go
// Change from warning to error
if detectedMIME == "image/jpeg" {
    strippedData, err := stripJPEGEXIF(fileData)
    if err != nil {
        result.Valid = false  // FAIL instead of warn
        result.Errors = append(result.Errors, "Cannot safely process image metadata")
        return result, nil
    }
    result.SanitizedData = strippedData
    result.RequiresSanitization = true
}
```

---

## Phase 4: Performance & Polish (Days 8-10)

### 4.1 Request Timeout Middleware

**New File:** `backend/internal/middleware/timeout.go`

```go
func TimeoutMiddleware(timeout time.Duration) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.TimeoutHandler(next, timeout, `{"error":"Request timeout"}`)
    }
}
```

**Apply in main.go:**
```go
// Standard routes
r.Use(middleware.TimeoutMiddleware(30 * time.Second))

// Upload group with extended timeout
r.Group(func(r chi.Router) {
    r.Use(middleware.TimeoutMiddleware(5 * time.Minute))
    r.Post("/api/media/upload", h.Upload)
})
```

### 4.2 N+1 Query Fixes

**File:** `backend/internal/repositories/media_repository.go`

```go
func (r *mediaRepository) List(...) ([]models.Media, int64, error) {
    // Add Preload for associations
    var media []models.Media
    err := query.
        Preload("Tags").
        Preload("Categories").
        Order("created_at DESC").
        Scopes(pagination.Apply).
        Find(&media).Error
    // ...
}
```

### 4.3 Rate Limiter Enhancement

**File:** `backend/internal/middleware/rate_limit.go`

```go
type RateLimiter struct {
    limiters   map[string]*rate.Limiter
    lastAccess map[string]time.Time  // ADD
    mu         sync.RWMutex
    rate       rate.Limit
    burst      int
    inactivity time.Duration  // ADD: cleanup after this duration
}

func (rl *RateLimiter) getLimiter(ip string) *rate.Limiter {
    rl.mu.Lock()
    defer rl.mu.Unlock()

    if limiter, exists := rl.limiters[ip]; exists {
        rl.lastAccess[ip] = time.Now()  // Update access time
        return limiter
    }

    limiter := rate.NewLimiter(rl.rate, rl.burst)
    rl.limiters[ip] = limiter
    rl.lastAccess[ip] = time.Now()
    return limiter
}

func (rl *RateLimiter) performCleanup() {
    now := time.Now()
    var toDelete []string

    rl.mu.RLock()
    for ip, lastSeen := range rl.lastAccess {
        if now.Sub(lastSeen) > rl.inactivity {
            toDelete = append(toDelete, ip)
        }
    }
    rl.mu.RUnlock()

    if len(toDelete) > 0 {
        rl.mu.Lock()
        for _, ip := range toDelete {
            delete(rl.limiters, ip)
            delete(rl.lastAccess, ip)
        }
        rl.mu.Unlock()
    }
}
```

### 4.4 API Client Race Condition Fix

**File:** `frontend/src/services/api.ts`

```typescript
class ApiClient {
    private refreshPromise: Promise<void> | null = null

    private async handleTokenRefresh(): Promise<void> {
        if (this.refreshPromise) {
            return this.refreshPromise
        }

        this.refreshPromise = (async () => {
            try {
                await axios.post(`${API_BASE_URL}/api/auth/refresh`, {}, {
                    withCredentials: true
                })
            } finally {
                this.refreshPromise = null
            }
        })()

        return this.refreshPromise
    }
}
```

---

## Test Plan (Throughout)

### Security-Critical Tests (Phase 1-2)

| Test | File | Priority |
|------|------|----------|
| Cookie HttpOnly/Secure/SameSite | `auth_test.go` | P0 |
| Token NOT in JSON response | `auth_test.go` | P0 |
| CSRF validation on POST/PUT/DELETE | `csrf_test.go` | P0 |
| CSRF skip on GET | `csrf_test.go` | P0 |
| Token revocation on logout | `blacklist_test.go` | P0 |
| Search wildcard escaping | `media_repository_test.go` | P0 |

### Additional Tests (Phase 3-4)

| Test | File | Priority |
|------|------|----------|
| Extension/MIME mismatch rejection | `validation_test.go` | P1 |
| EXIF failure handling | `validation_test.go` | P1 |
| Rate limiter cleanup | `rate_limit_test.go` | P1 |
| Request timeout | `timeout_test.go` | P2 |

---

## Files Summary

### Must Modify

| File | Phase | Changes |
|------|-------|---------|
| `backend/internal/handlers/auth.go` | 1 | Cookie auth, CSRF token generation |
| `backend/internal/middleware/auth.go` | 1,2 | Cookie extraction, blacklist check |
| `backend/internal/repositories/media_repository.go` | 1,4 | Wildcard escaping, Preload |
| `backend/internal/services/validation.go` | 3 | Extension check, EXIF error handling |
| `backend/internal/middleware/rate_limit.go` | 4 | Last-access tracking |
| `backend/cmd/api/main.go` | 1,4 | Wire CSRF, timeout middlewares |
| `frontend/src/services/api.ts` | 1 | Remove localStorage, add CSRF header |

### Must Create

| File | Phase | Purpose |
|------|-------|---------|
| `backend/internal/middleware/csrf.go` | 1 | CSRF middleware |
| `backend/internal/auth/blacklist.go` | 2 | Token revocation |
| `backend/internal/middleware/timeout.go` | 4 | Request timeouts |
| `backend/internal/middleware/csrf_test.go` | 1 | CSRF tests |
| `backend/internal/auth/blacklist_test.go` | 2 | Blacklist tests |

---

## Estimated Timeline

| Phase | Days | Effort |
|-------|------|--------|
| Phase 1: Auth Security | 3 | ~15h |
| Phase 2: Token Revocation | 2 | ~8h |
| Phase 3: File Security | 2 | ~8h |
| Phase 4: Performance | 3 | ~12h |
| **Total** | **10 days** | **~43h** |

---
