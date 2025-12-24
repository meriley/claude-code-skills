# Fix: Auto-Approval Scheduler Not Running in Production

## Problem
Media items are stuck in `pending` status for hours in production. Auto-approval should trigger 1 hour after upload completion, but it's not happening.

## Root Cause
The scheduler goroutine in `backend/internal/services/scheduler.go` has **no panic recovery**. If any runtime error causes a panic inside `runAutoApproval()`, the goroutine crashes silently and no more auto-approvals ever happen. The rest of the backend continues functioning normally, making this failure invisible.

**The same vulnerability exists in all background workers:**
- `scheduler.go` - Auto-approval scheduler
- `scanner_worker.go` - Malware scanning
- `thumbnail_worker.go` - Thumbnail generation

## Evidence
1. Media status is `pending` (confirmed by user) - status is correct for auto-approval
2. No `recover()` calls in scheduler.go or any services
3. All workers run in goroutines with no health checks or heartbeats
4. No mechanism to detect or recover from worker failure

## Fix Plan

### 1. Create Shared Panic Recovery Helper
**File:** `backend/internal/services/recovery.go` (new file)

Create a reusable panic recovery wrapper:

```go
package services

import (
    "fmt"
    "runtime/debug"
    "github.com/mriley/demi-upload/internal/logger"
)

// SafeGo runs fn in a goroutine with panic recovery
func SafeGo(name string, fn func()) {
    go func() {
        defer func() {
            if r := recover(); r != nil {
                logger.Error(fmt.Sprintf("%s panicked, recovered", name),
                    fmt.Errorf("panic: %v", r),
                    "stack", string(debug.Stack()),
                )
            }
        }()
        fn()
    }()
}

// SafeRun wraps fn with panic recovery (non-goroutine version)
func SafeRun(name string, fn func()) {
    defer func() {
        if r := recover(); r != nil {
            logger.Error(fmt.Sprintf("%s panicked, recovered", name),
                fmt.Errorf("panic: %v", r),
                "stack", string(debug.Stack()),
            )
        }
    }()
    fn()
}
```

### 2. Add Panic Recovery to Scheduler
**File:** `backend/internal/services/scheduler.go`

Wrap each `runAutoApproval()` call with `SafeRun`:

```go
func (s *Scheduler) Start() {
    logger.Info("Scheduler started")
    go func() {
        // Run immediately on start
        SafeRun("auto-approval", s.runAutoApproval)

        // Then run on interval
        for {
            select {
            case <-s.ticker.C:
                SafeRun("auto-approval", s.runAutoApproval)
            case <-s.done:
                return
            }
        }
    }()
}
```

### 3. Add Panic Recovery to Scanner Worker
**File:** `backend/internal/services/scanner_worker.go`

Wrap `processPendingScans()` and individual scan operations:

```go
func (w *ScannerWorker) run() {
    defer w.wg.Done()
    ticker := time.NewTicker(w.pollInterval)
    defer ticker.Stop()

    SafeRun("scanner-init", w.processPendingScans)

    for {
        select {
        case <-ticker.C:
            SafeRun("scanner-poll", w.processPendingScans)
        case <-w.stopChan:
            return
        }
    }
}
```

### 4. Add Panic Recovery to Thumbnail Worker
**File:** `backend/internal/services/thumbnail_worker.go`

Same pattern as scanner:

```go
func (w *ThumbnailWorker) run() {
    defer w.wg.Done()
    ticker := time.NewTicker(w.pollInterval)
    defer ticker.Stop()

    SafeRun("thumbnail-init", w.processPendingThumbnails)

    for {
        select {
        case <-ticker.C:
            SafeRun("thumbnail-poll", w.processPendingThumbnails)
        case <-w.stopChan:
            return
        }
    }
}
```

### 5. Add Health Logging to All Workers
Add periodic heartbeat logs to verify workers are running:

```go
// In scheduler.go runAutoApproval()
logger.Debug("Auto-approval heartbeat", "pending_count", len(media))

// In scanner_worker.go processPendingScans()
logger.Debug("Scanner heartbeat", "pending_count", len(pendingMedia))

// In thumbnail_worker.go processPendingThumbnails()
logger.Debug("Thumbnail heartbeat", "pending_count", len(pendingMedia))
```

### 6. Immediate Production Fix (Manual)
To unblock stuck media immediately:

```sql
-- Check stuck media and their deadlines
SELECT id, status, approval_deadline, created_at
FROM media
WHERE status = 'pending'
AND approval_deadline < NOW();

-- Manual approval of stuck media (one-time fix)
UPDATE media
SET status = 'approved',
    approved_at = NOW(),
    approval_method = 'auto'
WHERE status = 'pending'
AND approval_deadline < NOW();
```

### 7. Deploy Fix
After code changes:
1. Run tests
2. Build new backend image
3. Deploy to production
4. Restart backend container
5. Verify all worker logs appear

## Files to Modify

| File | Change |
|------|--------|
| `backend/internal/services/recovery.go` | **NEW** - Shared panic recovery helpers |
| `backend/internal/services/scheduler.go` | Use SafeRun, add heartbeat logging |
| `backend/internal/services/scanner_worker.go` | Use SafeRun, add heartbeat logging |
| `backend/internal/services/thumbnail_worker.go` | Use SafeRun, add heartbeat logging |

## Testing

1. Add unit tests for `SafeRun` and `SafeGo` helpers
2. Add tests verifying each worker recovers from panic
3. Verify existing worker tests still pass

## Verification Steps

After deployment:
1. Check logs for "Scheduler started", "Scanner worker started", "Thumbnail worker started"
2. Check logs for periodic heartbeat messages from all workers
3. Upload new test file and verify:
   - Thumbnail generation works
   - Auto-approval triggers after 1 hour
4. Confirm stuck media was approved
