# Fix Flaky Test: TestCanRemoveMembers

## Problem

`TestCanRemoveMembers` in `internal/middleware/group_auth_test.go` passes in isolation but fails when run with the full test suite due to FK constraint violations.

**Error:**
```
ERROR: update or delete on table "users" violates foreign key constraint "fk_users_media" on table "media"
```

## Root Cause

`group_auth_test.go` has its own `setupTestDB()`/`cleanupTestDB()` functions that differ from the shared `integration_test_helpers.go`:

| Issue | `group_auth_test.go` (Broken) | `integration_test_helpers.go` (Correct) |
|-------|------------------------------|----------------------------------------|
| Migrations | Missing: `Media`, `Request`, `RequestMedia` | All models migrated |
| Cleanup Order | `media` → `groups` → `users` (wrong) | `request_media` → `requests` → `groups` → `media` → `users` |
| Missing Cleanup | `request_media`, `requests` | All tables cleaned |

## Solution

### Option A: Minimal Fix (Recommended)
Fix the `group_auth_test.go` functions in place:

**1. Update `setupTestDB()` to migrate all required tables:**
```go
err = db.AutoMigrate(
    &models.User{},
    &models.Media{},           // ADD
    &models.Request{},         // ADD
    &models.Group{},
    &models.GroupMember{},
    &models.GroupInvitation{},
)
```

**2. Fix `cleanupTestDB()` order:**
```go
func cleanupTestDB(t *testing.T, db *gorm.DB) {
    t.Helper()
    // Delete in correct FK-dependency order
    db.Exec("DELETE FROM group_invitations")
    db.Exec("DELETE FROM group_members")
    db.Exec("DELETE FROM request_media")   // ADD
    db.Exec("DELETE FROM requests")        // ADD
    db.Exec("DELETE FROM groups")
    db.Exec("DELETE FROM media")
    db.Exec("DELETE FROM users")
}
```

### Option B: Consolidation (Future)
Refactor `group_auth_test.go` to use the shared `integration_test_helpers.go` functions instead of duplicating them. This is a larger refactor best done separately.

---

## Files to Modify

| File | Change |
|------|--------|
| `internal/middleware/group_auth_test.go` | Fix `setupTestDB()` and `cleanupTestDB()` |

---

## Verification

```bash
# Run full test suite to verify no FK violations
go test ./... -count=1

# Run middleware tests specifically
go test ./internal/middleware/... -v -count=1
```

---

## Success Criteria

1. `TestCanRemoveMembers` passes when run with full suite
2. All middleware tests pass
3. No FK constraint violations in any test run

---

# Previous Work (Completed)

### A1. Add PutObject() to StorageService (Shared Infrastructure)

**File:** `internal/services/storage.go`

**Implementation:**
```go
// PutObject uploads data directly to R2 bucket
func (s *StorageService) PutObject(key string, data []byte, contentType string) error {
    _, err := s.client.PutObject(context.Background(), &s3.PutObjectInput{
        Bucket:      aws.String(s.bucketName),
        Key:         aws.String(key),
        Body:        bytes.NewReader(data),
        ContentType: aws.String(contentType),
    })
    return err
}
```

**Tests needed:** 3-4 test cases in `storage_test.go`

---

### A2. Implement EXIF Stripping for JPEG

**Files to modify:**
- `internal/services/validation.go` - Add stripJPEGEXIF() function
- `internal/handlers/media_handler.go` - Re-upload stripped JPEG

**Approach:** Use standard library `image/jpeg` to decode and re-encode without EXIF:
```go
func stripJPEGEXIF(data []byte) ([]byte, error) {
    img, err := jpeg.Decode(bytes.NewReader(data))
    if err != nil {
        return nil, err
    }

    var buf bytes.Buffer
    if err := jpeg.Encode(&buf, img, &jpeg.Options{Quality: 95}); err != nil {
        return nil, err
    }
    return buf.Bytes(), nil
}
```

**Location:** Replace TODO at `validation.go:124`

**In validateImage():**
```go
if detectedMIME == "image/jpeg" {
    strippedData, err := stripJPEGEXIF(fileData)
    if err != nil {
        result.Warnings = append(result.Warnings, "EXIF stripping failed: "+err.Error())
    } else {
        result.SanitizedData = strippedData
        result.RequiresSanitization = true
    }
}
```

**Tests needed:** 8-10 test cases
- Valid JPEG with EXIF → stripped successfully
- Valid JPEG without EXIF → unchanged
- Corrupt JPEG → error handling
- EXIF with GPS data → verify removed
- Large JPEG → performance acceptable

---

### A3. Complete SVG Re-upload Workflow

**File:** `internal/handlers/media_handler.go`

**Current code (line ~219):**
```go
if validationResult.RequiresSanitization && validationResult.SanitizedData != nil {
    // TODO: Implement re-upload of sanitized SVG
    media.Notes += "SVG sanitized to remove XSS vectors"
}
```

**Replace with:**
```go
if validationResult.RequiresSanitization && validationResult.SanitizedData != nil {
    // Re-upload sanitized file to R2
    if err := h.storage.PutObject(media.R2Key, validationResult.SanitizedData,
        validationResult.DetectedMIME); err != nil {
        return fmt.Errorf("failed to upload sanitized file: %w", err)
    }

    // Update filesize if changed
    media.Filesize = int64(len(validationResult.SanitizedData))

    // Add note about sanitization
    if media.Notes != "" {
        media.Notes += "; "
    }
    media.Notes += fmt.Sprintf("%s sanitized for security",
        strings.ToUpper(filepath.Ext(media.Filename)))

    // Scan the SANITIZED data, not original
    dataToScan = validationResult.SanitizedData
}
```

**Key insight:** This same code path now handles both SVG and JPEG sanitization!

**Tests needed:** 6-8 test cases
- SVG with XSS → re-uploaded sanitized
- JPEG with EXIF → re-uploaded stripped
- Re-upload failure → proper error handling
- Filesize updated correctly
- Notes field updated correctly

---

## Track B: MediaHandler Tests

### B1. Test File Setup

**File:** `internal/handlers/media_handler_test.go` (extend existing)

**Helper functions to add:**
```go
func createTestMedia(t *testing.T, db *gorm.DB, userID uint,
    status models.MediaStatus, contentType models.ContentType) *models.Media

func createMediaHandlerWithMocks(t *testing.T) (*MediaHandler, *gorm.DB)

func mockStorageService(t *testing.T) *services.StorageService
```

---

### B2. Endpoint Tests (Priority Order)

| # | Endpoint | Tests | Complexity | Est. Time |
|---|----------|-------|------------|-----------|
| 1 | **CompleteUpload** | 15-18 | VERY HIGH | 2h |
| 2 | **RequestUploadURL** | 10-12 | HIGH | 1h 15m |
| 3 | **ListMedia** | 8-10 | MEDIUM | 45m |
| 4 | **DeleteMedia** | 7-8 | MEDIUM | 45m |
| 5 | **GetMediaRequests** | 6-8 | MEDIUM | 45m |
| 6 | **UpdateMedia** | 6-8 | LOW | 35m |
| 7 | **GetMedia** | 4-5 | LOW | 25m |

**Total: ~67 tests, 5-6 hours**

---

### B3. Critical Test Cases for CompleteUpload

This is the most complex endpoint - handles validation + malware scanning:

```go
tests := []struct {
    name           string
    mediaStatus    models.MediaStatus
    fileData       []byte
    mockScanResult string  // "clean", "infected", "error"
    expectedStatus models.MediaStatus
    expectedScan   models.ScanStatus
}{
    // Validation paths
    {"valid_jpeg_clean", StatusUploading, validJPEG, "clean", StatusPending, ScanStatusClean},
    {"invalid_mime_type", StatusUploading, invalidData, "", StatusRejected, ""},
    {"svg_with_xss", StatusUploading, svgWithScript, "clean", StatusPending, ScanStatusClean},

    // Malware scanning paths
    {"infected_file", StatusUploading, eicarData, "infected", StatusQuarantined, ScanStatusInfected},
    {"scanner_error", StatusUploading, validJPEG, "error", StatusQuarantined, ScanStatusError},

    // Async scanning (>=10MB)
    {"large_file_async", StatusUploading, largeFile, "", StatusPendingScan, ScanStatusPending},

    // Error cases
    {"wrong_status", StatusPending, validJPEG, "", StatusPending, ""},
    {"not_found", StatusUploading, validJPEG, "", 0, ""},
}
```

---

### B4. Quota Boundary Tests for RequestUploadURL

```go
tests := []struct {
    name           string
    currentUsage   int64
    quotaGB        int
    requestedSize  int64
    expectError    bool
}{
    {"within_quota", 5*GB, 10, 1*GB, false},
    {"exactly_at_limit", 9*GB, 10, 1*GB, false},
    {"one_byte_over", 10*GB, 10, 1, true},
    {"large_file_exceeds", 5*GB, 10, 6*GB, true},
}
```

---

## Execution Plan

### Phase 1: Shared Infrastructure (30 min)
1. Add `PutObject()` to StorageService
2. Add tests for `PutObject()`
3. Commit: `feat(storage): add PutObject method for server-side uploads`

### Phase 2A: Security Track (3.5 hours)
1. Implement `stripJPEGEXIF()` in validation.go
2. Update `validateImage()` to call EXIF stripper
3. Update `CompleteUpload()` to re-upload sanitized files
4. Add EXIF stripping tests
5. Add SVG re-upload tests
6. Commit: `feat(security): add EXIF stripping and sanitized file re-upload`

### Phase 2B: Testing Track (5-6 hours)
1. Add test helpers to media_handler_test.go
2. Implement CompleteUpload tests (most critical)
3. Implement RequestUploadURL tests
4. Implement remaining endpoint tests
5. Commit: `test(handlers): add comprehensive MediaHandler test suite`

---

## Critical Files

| File | Changes |
|------|---------|
| `internal/services/storage.go` | Add `PutObject()` |
| `internal/services/storage_test.go` | Add PutObject tests |
| `internal/services/validation.go` | Add `stripJPEGEXIF()`, update `validateImage()` |
| `internal/services/validation_test.go` | Add EXIF stripping tests |
| `internal/handlers/media_handler.go` | Update sanitization re-upload logic |
| `internal/handlers/media_handler_test.go` | Add 67 new tests |

---

## Dependencies

```
PutObject() ─────┬─────> EXIF Stripping
                 │
                 └─────> SVG Re-upload

MediaHandler Tests ───> Independent (can run in parallel)
```

---

## Success Criteria

1. **Security:**
   - JPEG files have EXIF data stripped before storage
   - SVG files are sanitized and re-uploaded
   - Malware scanning uses sanitized data

2. **Testing:**
   - MediaHandler coverage >80%
   - All 7 endpoints have comprehensive tests
   - Edge cases covered (quota, permissions, errors)

3. **Quality:**
   - All tests pass
   - No regressions in existing functionality
   - Clean commit history with conventional commits
