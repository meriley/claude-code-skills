# Go Backend Security & Reliability Fixes

## Overview

Fix 12 issues identified in the Go code review, prioritized by security impact with minimal-change implementation approach.

## Issues Summary

| # | Issue | File | Severity | Lines Changed |
|---|-------|------|----------|---------------|
| 1 | Unbounded memory (OOM/DoS) | storage.go:174 | CRITICAL | ~10 |
| 2 | Missing filename validation | upload.go:162-182 | HIGH | ~25 |
| 3 | Weak MIME type validation | upload.go:175-179 | HIGH | ~15 |
| 4 | No request body size limit | main.go:132-140 | HIGH | ~5 |
| 5 | Goroutine leak (scanner) | scanner_worker.go:83-168 | HIGH | ~8 |
| 6 | Goroutine leak (thumbnail) | thumbnail_worker.go:97-191 | HIGH | ~8 |
| 7 | Context not propagated | scanner_worker.go (multiple) | MEDIUM | ~12 |
| 8 | No upload rate limiting | main.go:420-428 | MEDIUM | ~3 |
| 9 | Weak JWT secret validation | config.go:68-74 | MEDIUM | ~5 |
| 10 | Pagination constants conflict | constants.go vs pagination.go | LOW | ~2 |
| 11 | Control flow cleanup | media_repository.go:309 | LOW | ~5 |
| 12 | Magic numbers | validation.go:252, media_handler.go:434 | LOW | ~2 |

---

## Phase 1: Critical Security (Day 1)

### Fix 1: Unbounded Memory in GetObject
**File:** `backend/internal/services/storage.go:162-179`

**Problem:** `io.ReadAll(result.Body)` reads entire file into memory with no limit.

**Solution:**
```go
// Add size check before reading
if result.ContentLength != nil && *result.ContentLength > constants.MaxFileSizeBytes {
    return nil, fmt.Errorf("file too large: %d bytes (max %d)",
        *result.ContentLength, constants.MaxFileSizeBytes)
}

// Use LimitReader to enforce max size
limitedReader := io.LimitReader(result.Body, constants.MaxFileSizeBytes+1)
data, err := io.ReadAll(limitedReader)
if int64(len(data)) > constants.MaxFileSizeBytes {
    return nil, fmt.Errorf("file exceeds maximum size")
}
```

**Test:** Mock S3 with 6GB ContentLength → verify error returned without reading.

---

### Fix 2: Missing Filename Validation
**File:** `backend/internal/handlers/upload.go:162-182`

**Problem:** No validation for path traversal, null bytes, or length.

**Solution:**
```go
func validateFilename(filename string) error {
    if filename == "" {
        return fmt.Errorf("filename required")
    }
    if len(filename) > 255 {
        return fmt.Errorf("filename too long (max 255)")
    }
    if strings.Contains(filename, "..") {
        return fmt.Errorf("path traversal not allowed")
    }
    if strings.ContainsAny(filename, "\x00/\\") {
        return fmt.Errorf("invalid characters in filename")
    }
    return nil
}

// In validateUploadRequest:
if err := validateFilename(req.Filename); err != nil {
    validationErrors["filename"] = err.Error()
}
```

**Test:** `"../../../etc/passwd"` → rejected, `"video.mp4"` → accepted.

---

### Fix 3: Weak MIME Type Validation
**File:** `backend/internal/handlers/upload.go:175-179`

**Problem:** Only checks `video/` prefix, accepts `video/../../etc`.

**Pre-implementation:** Query database for existing MIME types:
```sql
SELECT DISTINCT mime_type, COUNT(*) FROM media GROUP BY mime_type;
```
Add any legitimate types found to the allowlist.

**Solution:**
```go
// In constants.go:
var AllowedVideoMIMETypes = map[string]bool{
    "video/mp4":        true,
    "video/quicktime":  true,
    "video/x-msvideo":  true,
    "video/x-matroska": true,
    "video/webm":       true,
    "video/mpeg":       true,
    // Add any additional types found in database query
}

// In upload.go:
if !constants.AllowedVideoMIMETypes[req.MimeType] {
    validationErrors["mime_type"] = "unsupported video format"
}
```

**Test:** Each allowed type → accepted, `"video/fake"` → rejected.

---

### Fix 4: No Request Body Size Limit
**File:** `backend/cmd/api/main.go:132-140`

**Problem:** No limit on JSON payload size.

**Solution:** Add middleware to limit request body:
```go
// In constants.go:
MaxRequestBodyBytes int64 = 10 * 1024 * 1024 // 10MB

// Add middleware in setupMiddleware:
func limitRequestBody(maxBytes int64) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            r.Body = http.MaxBytesReader(w, r.Body, maxBytes)
            next.ServeHTTP(w, r)
        })
    }
}

r.Use(limitRequestBody(constants.MaxRequestBodyBytes))
```

**Test:** 11MB POST → 413 status.

---

## Phase 2: Worker Reliability (Day 2)

### Fix 5 & 6: Goroutine Leaks in Workers
**Files:**
- `backend/internal/services/scanner_worker.go:83-168`
- `backend/internal/services/thumbnail_worker.go:97-191`

**Problem:** `Stop()` doesn't wait for spawned goroutines.

**Solution:** Add worker-level WaitGroup:
```go
// Add to struct:
type ScannerWorker struct {
    // ... existing fields
    scanWg sync.WaitGroup  // Track spawned scan goroutines
}

// In processPendingScans, change local scanWg to w.scanWg:
w.scanWg.Add(1)
go func(m models.Media) {
    defer w.scanWg.Done()
    // ...
}(media)

// In Stop(), add wait:
func (w *ScannerWorker) Stop() {
    // ... existing logic
    close(w.stopChan)
    w.wg.Wait()      // Wait for run() goroutine
    w.scanWg.Wait()  // Wait for spawned scan goroutines
    // ...
}
```

**Test:** `runtime.NumGoroutine()` before/after Stop() → no leak.

---

### Fix 7: Context Not Propagated
**File:** `backend/internal/services/scanner_worker.go:173, 237, 268, 325`

**Problem:** Functions create `context.Background()` instead of using worker context.

**Solution:**
```go
// Add to struct:
type ScannerWorker struct {
    ctx    context.Context
    cancel context.CancelFunc
}

// In NewScannerWorker:
ctx, cancel := context.WithCancel(context.Background())
return &ScannerWorker{
    ctx: ctx,
    cancel: cancel,
    // ...
}

// In Stop():
w.cancel()  // Cancel context before closing stopChan

// Replace all context.Background() with w.ctx:
ctx, cancel := context.WithTimeout(w.ctx, scanDBTimeout)
```

**Test:** Call Stop() during scan → verify context cancelled.

---

## Phase 3: Defense in Depth (Day 3)

### Fix 8: No Upload Rate Limiting
**File:** `backend/cmd/api/main.go:420-428`

**Problem:** Upload endpoints have no rate limiting.

**Solution:** Create a separate rate limiter for uploads (10 req/sec, more permissive than auth's 5 req/sec):
```go
// Create upload-specific rate limiter in main.go:
uploadRateLimiter := mw.NewRateLimiter(10, 20) // 10 req/sec, burst 20

func setupUploadRoutes(r chi.Router, h *handlers.UploadHandler,
    authMw *mw.AuthMiddleware, csrfMw *mw.CSRFMiddleware,
    rateLimiter *mw.RateLimiter) {  // Add parameter
    r.Group(func(r chi.Router) {
        r.Use(authMw.RequireAuth)
        r.Use(rateLimiter.Limit)  // Add rate limiting
        r.Use(csrfMw.Protect)
        // ... routes
    })
}
```

**Test:** 25 requests in 1 second → requests beyond burst get 429.

---

### Fix 9: Weak JWT Secret Validation
**File:** `backend/pkg/config/config.go:68-74`

**Problem:** No minimum length check.

**Solution:**
```go
// In constants.go:
MinJWTSecretLength = 32

// In config.go:
if len(cfg.JWTSecret) < constants.MinJWTSecretLength {
    return nil, fmt.Errorf("JWT_SECRET must be at least %d characters (currently %d)",
        constants.MinJWTSecretLength, len(cfg.JWTSecret))
}
```

**Test:** `JWT_SECRET="short"` → startup fails with clear error.

---

## Phase 4: Code Quality (Day 3-4)

### Fix 10: Pagination Constants Conflict
**Files:** `constants.go:64-66` vs `utils/pagination.go:11-15`

**Problem:** Duplicate constants with different values (50/100 vs 100/1000).

**Solution:** Use the more conservative 50/100 values. Update pagination.go to use constants from constants.go:
```go
// In utils/pagination.go, remove local constants and import:
import "github.com/yourusername/demi-upload/internal/constants"

// Replace local DefaultPageLimit/MaxPageLimit with:
constants.DefaultPageLimit  // 50
constants.MaxPageLimit      // 100
```

This reduces DoS risk (max 100 items vs 1000) while centralizing configuration.

---

### Fix 11: Control Flow Cleanup
**File:** `backend/internal/repositories/media_repository.go:309`

**Problem:** Unnecessary `else if` after return.

**Solution:** Refactor to use guard clauses.

---

### Fix 12: Magic Numbers
**Files:** `validation.go:252`, `media_handler.go:434`

**Solution:** Replace `1024*1024` with `constants.BytesPerKB*constants.BytesPerKB`.

---

## Critical Files to Modify

1. `backend/internal/services/storage.go` - Fix #1
2. `backend/internal/handlers/upload.go` - Fixes #2, #3
3. `backend/cmd/api/main.go` - Fixes #4, #8
4. `backend/internal/services/scanner_worker.go` - Fixes #5, #7
5. `backend/internal/services/thumbnail_worker.go` - Fix #6
6. `backend/internal/constants/constants.go` - New constants for #1, #3, #4, #9
7. `backend/pkg/config/config.go` - Fix #9
8. `backend/internal/utils/pagination.go` - Fix #10 (use constants.go values)
9. `backend/internal/repositories/media_repository.go` - Fix #11
10. `backend/internal/services/validation.go` - Fix #12

---

## Test Requirements

Each fix requires:
1. Unit tests for new validation functions
2. Integration tests for middleware
3. Existing tests must pass (regression check)

Run after each phase:
```bash
cd backend && make test && make lint
```

---

## Commits (One Per Fix)

1. `fix(storage): add size limit to GetObject to prevent OOM`
2. `fix(upload): add filename validation for path traversal`
3. `fix(upload): use MIME type allowlist instead of prefix check`
4. `fix(server): add request body size limit middleware`
5. `fix(scanner): wait for spawned goroutines on shutdown`
6. `fix(thumbnail): wait for spawned goroutines on shutdown`
7. `fix(scanner): propagate context for cancellation`
8. `fix(upload): add rate limiting to upload endpoints`
9. `fix(config): validate JWT secret minimum length`
10. `refactor(constants): remove duplicate pagination constants`
11. `refactor(media): use guard clauses in FindByIDWithAccess`
12. `refactor(validation): use constants for byte calculations`
