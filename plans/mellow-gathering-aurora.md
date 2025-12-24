# Go Code Review Findings & Remediation Plan

## Executive Summary

**Overall Assessment**: APPROVE WITH COMMENTS
**Code Quality Score**: B+ (Good with room for improvement)
**Production Risk**: LOW-MEDIUM
**Test Coverage**: 67.6% handlers, 72.3% services, 92.6% middleware

---

## Critical & High Priority Issues

### 1. SVG Sanitizer Variable Shadowing Bug (P1 - Security)
**File**: `backend/internal/services/validation.go:318-333`

Variable shadowing breaks depth tracking, allowing deep nesting to bypass `maxSVGDepth` check.

```go
// BUG: depth := 1 shadows outer depth variable
if dangerousElements[elem.Name.Local] {
    depth := 1  // SHADOWS outer depth!
```

**Fix**: Rename inner variable to `skipDepth` and update outer `depth` as elements are skipped.

---

### 2. LIKE Injection in Search (P1 - Security)
**File**: `backend/internal/repositories/media_repository.go:192-199`

User input with `%` or `_` bypasses search filters (searching `%` returns ALL records).

**Fix**: Add `escapeLikePattern()` function to escape special LIKE characters.

---

### 3. Missing Context Cancellation in Scanner Worker (P1 - Resource Leak)
**File**: `backend/internal/services/scanner_worker.go:185-218`

Long-running scans don't check context cancellation during shutdown, causing resource leaks.

**Fix**: Add cancellable context to worker, check `ctx.Err()` before expensive operations.

---

### 4. Missing Database Index on scan_status (P1 - Performance)
**File**: `backend/internal/models/media.go:69`

Scanner queries `WHERE scan_status = 'pending'` every 30 seconds without an index.

**Fix**: Add composite index `(scan_status, created_at)`.

---

### 5. Race Condition in RateLimiter Constructor (P2)
**File**: `backend/internal/middleware/rate_limit.go:29-40`

Goroutine starts before constructor returns.

**Fix**: Document as intentional or add explicit `Start()` method.

---

### 6. Error Context Loss in Auth Handler (P2)
**File**: `backend/internal/handlers/auth.go:119, 121, 356-358, 368`

Errors aren't wrapped with `%w`, breaking error chain inspection.

**Fix**: Extract business logic to internal methods, wrap errors with `%w`.

---

### 7. Unbounded Goroutine Creation (P2)
**File**: `backend/internal/services/scanner_worker.go:138-163`

Creates many goroutines that block on semaphore.

**Fix**: Switch to worker pool pattern with fixed goroutine count.

---

## Medium Priority Issues

1. **No Circuit Breaker for ClamAV** - `services/validation.go`
2. **Missing Prometheus Metrics** - No observability
3. **IP Fallback Vulnerability** - `middleware/rate_limit.go:174-176`
4. **Test Coverage Gaps** - Repositories at 46.3% (should be 80%+)
5. **Inconsistent Error Message Format** - Mix of constants/strings/formatted
6. **Missing Request ID in RMS Context** - `rms/context.go`

---

## Positive Observations (Keep These!)

1. **Excellent RMS Context Pattern** - Brilliant dependency injection design
2. **Security-First Rate Limiter** - Textbook double-checked locking
3. **Comprehensive Input Validation** - Magic numbers, SVG sanitization, EXIF stripping
4. **Proper Resource Cleanup** - Correct defer ordering, graceful shutdown
5. **Structured Logging** - Machine-parseable, aggregate-able
6. **HTTP Security Headers & Timeouts** - Slowloris protection
7. **Strong Test Coverage on Critical Paths** - Middleware 92.6%, Auth 94.4%
8. **Context Timeouts on All DB Operations** - Prevents connection pool exhaustion

---

## Recommended Fix Order

### Phase 1: Security Fixes (Must before production)
1. SVG sanitizer variable shadowing
2. LIKE injection in search
3. Scanner worker context cancellation

### Phase 2: Performance & Stability
4. Add scan_status database index
5. Fix unbounded goroutine creation
6. Fix RateLimiter constructor race

### Phase 3: Observability & Quality
7. Add error wrapping in handlers
8. Implement circuit breaker for ClamAV
9. Add Prometheus metrics

### Phase 4: Continuous Improvement
10. Increase repository test coverage
11. Standardize error message format
12. Add RequestID to RMS context

---

## Critical Files to Modify

| Priority | File | Issue |
|----------|------|-------|
| P1 | `services/validation.go` | SVG depth shadowing |
| P1 | `repositories/media_repository.go` | LIKE injection |
| P1 | `services/scanner_worker.go` | Context cancellation + goroutine pool |
| P1 | `models/media.go` | Missing index |
| P2 | `middleware/rate_limit.go` | Constructor race |
| P2 | `handlers/auth.go` | Error wrapping |

---

## Tests to Add

1. `TestSVG_DangerousElementDepthTracking` - Verify depth tracking fix
2. `TestSearch_LikeInjection` - Verify `%` and `_` are escaped
3. `TestScannerWorker_GracefulShutdown` - Verify in-flight scans cancel
4. `TestRateLimiter_ConcurrentAccess` - Run with `-race` flag

---

## Detailed Implementation Plan

### Issue 1: SVG Variable Shadowing (P1 - Security)
**File**: `backend/internal/services/validation.go:318-333`

**Current Code** (Lines 318-333):
```go
if dangerousElements[strings.ToLower(elem.Name.Local)] {
    depth := 1  // BUG: shadows outer 'depth' variable
    for depth > 0 {
        // ...
    }
}
```

**Fix**:
1. Rename inner `depth` to `skipDepth`
2. Track outer depth changes while skipping elements

```go
if dangerousElements[strings.ToLower(elem.Name.Local)] {
    skipDepth := 1
    for skipDepth > 0 {
        t, err := decoder.Token()
        if err != nil {
            return nil, fmt.Errorf("failed to skip dangerous element: %w", err)
        }
        switch t.(type) {
        case xml.StartElement:
            skipDepth++
            depth++  // Also update outer depth
        case xml.EndElement:
            skipDepth--
            depth--  // Also update outer depth
        }
    }
    continue
}
```

---

### Issue 2: LIKE Injection (P1 - Security)
**File**: `backend/internal/repositories/media_repository.go:192-199`

**Fix**:
1. Add `escapeLikePattern` helper function
2. Use it when building search patterns

```go
// Add at top of file (after imports)
func escapeLikePattern(pattern string) string {
    escaped := strings.ReplaceAll(pattern, `\`, `\\`)
    escaped = strings.ReplaceAll(escaped, `%`, `\%`)
    escaped = strings.ReplaceAll(escaped, `_`, `\_`)
    return escaped
}

// Update applyMediaFilters (lines 193-198)
if filters.Search != "" {
    escapedSearch := escapeLikePattern(filters.Search)
    searchPattern := "%" + escapedSearch + "%"
    query = query.Where(
        "title ILIKE ? OR filename ILIKE ? OR description ILIKE ?",
        searchPattern, searchPattern, searchPattern,
    )
}
```

---

### Issue 3: Scanner Worker Context Cancellation (P1 - Resource Leak)
**File**: `backend/internal/services/scanner_worker.go`

**Fix**:
1. Add `ctx context.Context` and `cancel context.CancelFunc` to struct
2. Initialize in `Start()`, cancel in `Stop()`
3. Pass context to `scanMedia()` and check `ctx.Err()` before expensive ops

```go
// Add to struct (lines 22-32)
type ScannerWorker struct {
    // ... existing fields ...
    ctx    context.Context
    cancel context.CancelFunc
}

// Update Start() (line 60-76)
func (w *ScannerWorker) Start() {
    // ... existing lock check ...
    w.ctx, w.cancel = context.WithCancel(context.Background())
    w.running = true
    // ... rest unchanged ...
}

// Update Stop() (line 78-96)
func (w *ScannerWorker) Stop() {
    // ... existing lock check ...
    w.cancel()  // Cancel all in-progress operations
    close(w.stopChan)
    // ... rest unchanged ...
}

// Update scanMedia signature and add cancellation checks (line 166)
func (w *ScannerWorker) scanMedia(ctx context.Context, media *models.Media) {
    if ctx.Err() != nil {
        logger.Info("Scan canceled before start", "media_id", media.ID)
        return
    }
    // ... after GetObject call ...
    if ctx.Err() != nil {
        logger.Info("Scan canceled after download", "media_id", media.ID)
        return
    }
    // ... rest unchanged ...
}

// Update caller in processPendingScans (line 158)
w.scanMedia(w.ctx, &m)
```

---

### Issue 4: Missing Database Index (P1 - Performance)
**File**: `backend/internal/models/media.go:69`

**Fix**: Add composite index on `scan_status` and `created_at`

```go
// Update line 69
ScanStatus ScanStatus `gorm:"type:varchar(50);index:idx_scan_status_created,priority:1" json:"scan_status,omitempty"`

// Also need to update CreatedAt (line 77) - already has index, need composite
CreatedAt time.Time `gorm:"index:idx_user_status_created,priority:3;index:idx_scan_status_created,priority:2" json:"created_at"`
```

**Migration**: Run `go run ./cmd/migrate` after change to create index.

---

### Issue 5: RateLimiter Constructor Race (P2)
**File**: `backend/internal/middleware/rate_limit.go:28-41`

**Fix**: Document as intentional (the goroutine only accesses immutable fields)

```go
// NewRateLimiter creates a new rate limiter.
// Note: The cleanup goroutine starts immediately but is safe because
// it only accesses immutable configuration fields (rate, burst, cleanup).
func NewRateLimiter(rateLimit float64, burst int, cleanupInterval time.Duration) *RateLimiter {
    // ... existing code ...
}
```

---

### Issue 6: Error Context Loss in Auth Handler (P2)
**File**: `backend/internal/handlers/auth.go:354-377`

**Fix**: Log the actual error while returning safe message to client

```go
// Update RefreshToken handler (lines 354-377)
// Extract user ID from token
userID, err := h.jwtService.ExtractUserID(req.RefreshToken)
if err != nil {
    logger.Warn("Failed to extract user ID from refresh token", "error", err)
    respondWithError(w, http.StatusUnauthorized, ErrMsgInvalidRefreshToken)
    return
}

// ... ctx setup ...

// Fetch user from database
var user models.User
if err := ctx.DB.First(&user, userID).Error; err != nil {
    if errors.Is(err, gorm.ErrRecordNotFound) {
        logger.Warn("User not found during token refresh", "user_id", userID)
    } else {
        logger.Error("Database error during token refresh", err, "user_id", userID)
    }
    respondWithError(w, http.StatusUnauthorized, "User not found")
    return
}
```

---

### Issue 7: Unbounded Goroutine Creation (P2)
**File**: `backend/internal/services/scanner_worker.go:137-162`

**Fix**: Switch to worker pool pattern

```go
// Replace processPendingScans semaphore pattern with worker pool
func (w *ScannerWorker) processPendingScans() {
    // ... existing query code (lines 120-133) ...

    logger.Info("Processing pending scans", "count", len(pendingMedia))

    // Create work channel
    workChan := make(chan models.Media, len(pendingMedia))

    // Start fixed pool of workers
    var scanWg sync.WaitGroup
    for i := 0; i < w.maxConcurrent; i++ {
        scanWg.Add(1)
        go func() {
            defer scanWg.Done()
            for media := range workChan {
                if w.ctx.Err() != nil {
                    return
                }
                w.scanMedia(w.ctx, &media)
            }
        }()
    }

    // Feed work to pool
    for _, media := range pendingMedia {
        select {
        case <-w.stopChan:
            break
        case workChan <- media:
        }
    }
    close(workChan)

    scanWg.Wait()
}
```

---

## Execution Order

1. **Security fixes first** (P1):
   - [ ] Fix SVG variable shadowing (`validation.go`)
   - [ ] Fix LIKE injection (`media_repository.go`)

2. **Resource management** (P1):
   - [ ] Add context cancellation to scanner worker (`scanner_worker.go`)
   - [ ] Add database index (`media.go` + migration)

3. **Quality improvements** (P2):
   - [ ] Document RateLimiter constructor (`rate_limit.go`)
   - [ ] Add error logging in auth handler (`auth.go`)
   - [ ] Refactor to worker pool pattern (`scanner_worker.go`)

4. **Testing**:
   - [ ] Add `TestSVG_DangerousElementDepthTracking`
   - [ ] Add `TestSearch_LikeInjection`
   - [ ] Add `TestScannerWorker_GracefulShutdown`
   - [ ] Run all tests with `-race` flag
