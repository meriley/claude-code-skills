# Type Safety Refactoring: Replace `map[string]interface{}` with Structs

## Overview

Refactor 255 instances of `map[string]interface{}` across 34 files to use type-safe structs. This improves:
- Compile-time type checking
- IDE autocompletion
- API documentation (JSON tags)
- Test reliability

## Scope

**INCLUDE:**
- API response maps in handlers (~100 instances)
- GORM database updates (~15 instances) - convert to struct updates
- Test response parsing (~80 instances)
- Audit log data structures (~20 instances)

**EXCLUDE (keep as-is):**
- i18n template data (`TWithData`, `TPlural`) - inherently dynamic
- Logger dynamic fields - standard logging pattern
- `JSONMap` for EXIF data - arbitrary external data

---

## Phase 1: Create Response Types

### 1.1 Create `handlers/response_types.go`

Define all API response structs in a single file for discoverability:

```go
// handlers/response_types.go

// === Common Response Types ===

type MessageResponse struct {
    Message string `json:"message"`
}

type PaginatedResponse struct {
    Items      interface{} `json:"items"`
    Total      int64       `json:"total"`
    Page       int         `json:"page"`
    PageSize   int         `json:"page_size"`
    TotalPages int         `json:"total_pages"`
}

// === Media Responses ===

type UploadInitResponse struct {
    UploadID  string `json:"upload_id"`
    UploadURL string `json:"upload_url"`
    ExpiresAt string `json:"expires_at"`
}

type UploadCompletionResponse struct {
    Message          string            `json:"message"`
    Status           string            `json:"status"`
    ValidationErrors map[string]string `json:"validation_errors,omitempty"`
    Media            *models.Media     `json:"media,omitempty"`
}

type MediaApprovalResponse struct {
    Message        string     `json:"message"`
    MediaID        uint       `json:"media_id"`
    Status         string     `json:"status"`
    ApprovedAt     *time.Time `json:"approved_at,omitempty"`
    ApprovalMethod string     `json:"approval_method,omitempty"`
}

type MediaDeleteResponse struct {
    Message string `json:"message"`
    MediaID uint   `json:"media_id"`
}

type MediaAuditResponse struct {
    Media    *models.Media     `json:"media"`
    AuditLog []models.AuditLog `json:"audit_log"`
}

// === List Responses ===

type MediaListResponse struct {
    Media      []models.Media `json:"media"`
    Total      int64          `json:"total"`
    Page       int            `json:"page"`
    PageSize   int            `json:"page_size"`
    TotalPages int            `json:"total_pages"`
}

type CategoryListResponse struct {
    Categories []models.Category `json:"categories"`
    Total      int64             `json:"total"`
    Page       int               `json:"page"`
    PageSize   int               `json:"page_size"`
    TotalPages int               `json:"total_pages"`
}

type TagListResponse struct {
    Tags       []models.Tag `json:"tags"`
    Total      int64        `json:"total"`
    Page       int          `json:"page"`
    PageSize   int          `json:"page_size"`
    TotalPages int          `json:"total_pages"`
}

type RequestListResponse struct {
    Requests   []models.Request `json:"requests"`
    Total      int64            `json:"total"`
    Page       int              `json:"page"`
    PageSize   int              `json:"page_size"`
    TotalPages int              `json:"total_pages"`
}

// === Quarantine Responses ===

type QuarantineListResponse struct {
    Items      []QuarantineItem `json:"items"`
    Total      int64            `json:"total"`
    Page       int              `json:"page"`
    PageSize   int              `json:"page_size"`
    TotalPages int              `json:"total_pages"`
}

type QuarantineItem struct {
    ID           uint       `json:"id"`
    Filename     string     `json:"filename"`
    ScanResult   string     `json:"scan_result"`
    ScanMessage  string     `json:"scan_message"`
    QuarantinedAt time.Time `json:"quarantined_at"`
    UploadedBy   string     `json:"uploaded_by"`
}

type QuarantineDetailResponse struct {
    Media       *models.Media     `json:"media"`
    ScanDetails *ScanDetails      `json:"scan_details"`
    AuditLog    []models.AuditLog `json:"audit_log,omitempty"`
}

type ScanDetails struct {
    Status    string     `json:"status"`
    Result    string     `json:"result"`
    Message   string     `json:"message"`
    ScannedAt *time.Time `json:"scanned_at,omitempty"`
}

// === Group Responses ===

type GroupResponse struct {
    Group   *models.Group `json:"group"`
    Role    string        `json:"role,omitempty"`
    Members []GroupMember `json:"members,omitempty"`
}

type GroupMember struct {
    UserID   uint   `json:"user_id"`
    Username string `json:"username"`
    Role     string `json:"role"`
}

// === Invitation Responses ===

type InvitationResponse struct {
    Message    string             `json:"message"`
    Invitation *models.Invitation `json:"invitation,omitempty"`
}

type InvitationListResponse struct {
    Invitations []models.Invitation `json:"invitations"`
    Total       int64               `json:"total"`
}

// === User Responses ===

type UserProfileResponse struct {
    User        *models.User `json:"user"`
    Preferences interface{}  `json:"preferences,omitempty"`
}

// === Search Responses ===

type SearchResponse struct {
    Results    []SearchResult `json:"results"`
    Total      int64          `json:"total"`
    Query      string         `json:"query"`
    Page       int            `json:"page"`
    PageSize   int            `json:"page_size"`
}

type SearchResult struct {
    ID       uint   `json:"id"`
    Type     string `json:"type"`
    Title    string `json:"title"`
    Snippet  string `json:"snippet,omitempty"`
}
```

### 1.2 Create `handlers/audit_types.go`

Define types for audit log data:

```go
// handlers/audit_types.go

// FieldChange tracks a single field change for audit logs
type FieldChange struct {
    Old interface{} `json:"old"`
    New interface{} `json:"new"`
}

// AuditChangeData represents changes made during an update operation
type AuditChangeData struct {
    Changes map[string]FieldChange `json:"changes"`
}

// LoginAuditData tracks login event details
type LoginAuditData struct {
    Email string `json:"email"`
    Role  string `json:"role"`
}

// FailedLoginAuditData tracks failed login attempts
type FailedLoginAuditData struct {
    Email  string `json:"email"`
    Reason string `json:"reason"`
}
```

---

## Phase 2: GORM Struct Updates

### 2.1 Create Update Structs in `models/`

For each model that uses `map[string]interface{}` updates, create dedicated update structs:

```go
// models/media_updates.go

// MediaScanUpdate for updating scan-related fields
type MediaScanUpdate struct {
    ScanStatus  *string    `gorm:"column:scan_status"`
    ScanResult  *string    `gorm:"column:scan_result"`
    ScanMessage *string    `gorm:"column:scan_message"`
    UpdatedAt   *time.Time `gorm:"column:updated_at"`
}

// MediaStatusUpdate for updating status-related fields
type MediaStatusUpdate struct {
    Status         *string    `gorm:"column:status"`
    ApprovedAt     *time.Time `gorm:"column:approved_at"`
    ApprovalMethod *string    `gorm:"column:approval_method"`
    UpdatedAt      *time.Time `gorm:"column:updated_at"`
}
```

### 2.2 Convert Scanner Worker Updates

**Before:**
```go
w.db.WithContext(ctx).Model(media).Updates(map[string]interface{}{
    "scan_status": models.ScanStatusScanning,
    "updated_at":  now,
})
```

**After:**
```go
status := models.ScanStatusScanning
w.db.WithContext(ctx).Model(media).Updates(&models.MediaScanUpdate{
    ScanStatus: &status,
    UpdatedAt:  &now,
})
```

---

## Phase 3: Handler Refactoring

### 3.1 Files to Modify (by priority)

1. `handlers/response.go` - Add new response types
2. `handlers/media_handler.go` - 12+ instances
3. `handlers/approval.go` - 4 instances
4. `handlers/category_handler.go` - 8 instances
5. `handlers/tag_handler.go` - similar to category
6. `handlers/group_category_handler.go` - 9 instances
7. `handlers/group_tag_handler.go` - similar
8. `handlers/quarantine_handler.go` - 8 instances
9. `handlers/upload.go` - 1 instance
10. `handlers/user.go` - 1 instance
11. `handlers/request.go` - 2 instances
12. `handlers/group.go` - 3 instances
13. `handlers/invitation.go` - 3 instances
14. `handlers/search_handler.go` - 2 instances
15. `handlers/auth.go` - audit log data (4 instances)

### 3.2 Conversion Pattern

**Before:**
```go
respondWithJSON(w, http.StatusOK, map[string]interface{}{
    "message":         "Media approved successfully",
    "media_id":        media.ID,
    "status":          media.Status,
    "approved_at":     media.ApprovedAt,
    "approval_method": media.ApprovalMethod,
})
```

**After:**
```go
respondWithJSON(w, http.StatusOK, MediaApprovalResponse{
    Message:        "Media approved successfully",
    MediaID:        media.ID,
    Status:         media.Status,
    ApprovedAt:     media.ApprovedAt,
    ApprovalMethod: media.ApprovalMethod,
})
```

---

## Phase 4: Test Refactoring

### 4.1 Create Test Response Types

In `handlers/response_types_test.go` or alongside test files:

```go
// parseResponse is a generic test helper for parsing JSON responses
func parseResponse[T any](t *testing.T, body []byte) T {
    t.Helper()
    var result T
    if err := json.Unmarshal(body, &result); err != nil {
        t.Fatalf("Failed to parse response: %v", err)
    }
    return result
}
```

### 4.2 Files to Modify

1. `handlers/media_handler_test.go` - 22+ instances
2. `handlers/group_test.go` - 15+ instances
3. `handlers/category_handler_test.go` - 5 instances
4. `handlers/tag_handler_test.go` - 4 instances
5. `handlers/user_test.go` - 7 instances
6. `handlers/invitation_test.go` - 5 instances
7. `handlers/quarantine_handler_test.go` - several
8. `handlers/approval_test.go` - several
9. `handlers/search_handler_test.go` - several
10. `handlers/request_test.go` - several
11. `handlers/upload_test.go` - several
12. `handlers/malware_integration_test.go` - 5 instances

### 4.3 Test Conversion Pattern

**Before:**
```go
var response map[string]interface{}
json.Unmarshal(body, &response)
assert.Equal(t, "success", response["message"])
```

**After:**
```go
var response MessageResponse
json.Unmarshal(body, &response)
assert.Equal(t, "success", response.Message)
```

---

## Phase 5: Service Layer Updates

### 5.1 Scanner Worker (`services/scanner_worker.go`)

Convert 4 GORM update instances to use `MediaScanUpdate` struct.

### 5.2 Request Handler (`handlers/request.go`)

Convert 1 GORM update instance.

---

## Execution Order

1. **Create type files first** (no breaking changes)
   - `handlers/response_types.go`
   - `handlers/audit_types.go`
   - `models/media_updates.go`

2. **Refactor handlers one at a time** (run tests after each)
   - Start with smallest files (user.go, upload.go)
   - Progress to larger files (media_handler.go)

3. **Refactor GORM updates**
   - scanner_worker.go
   - request.go

4. **Refactor tests last** (after handlers are stable)
   - Update test assertions to use typed responses

---

## Verification

After each phase:
1. `make lint` - Ensure no linting errors
2. `make test` - All tests pass
3. `go vet ./...` - No vet warnings

---

## Items to Keep As-Is

| Location | Pattern | Reason |
|----------|---------|--------|
| `i18n/i18n.go:89` | `TWithData(data map[string]interface{})` | Template data varies per message |
| `i18n/i18n.go:103` | `TPlural(data map[string]interface{})` | Same as above |
| `logger/logger.go:154` | Log entry map | Standard logging pattern |
| `models/media_exif.go:64` | `JSONMap` type | Arbitrary EXIF data |
| `handlers/response.go:55` | `respondWithI18nErrorData` | Passes to i18n function |

---

## Estimated File Count

- **New files:** 3
- **Modified handler files:** 15
- **Modified test files:** 12
- **Modified service files:** 1
- **Modified model files:** 1

**Total:** ~32 files modified
