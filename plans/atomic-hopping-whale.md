# Plan: Fix Request Completion Bug + Add Shared Media Feature

## Summary

Two related issues to fix:
1. **Bug**: "null value in column 'associated_by'" when completing a fulfilled request
2. **Feature**: Requestors should see media associated with their requests in "My Media"

---

## Issue 1: NULL Constraint Bug (High Priority)

### Root Cause
- `Request` model has `Media []Media gorm:"many2many:request_media"` (line 69)
- `FindByID()` preloads `Media` field
- `Update()` uses `Save(request)`
- GORM sees preloaded Media and tries to upsert `request_media` join table
- Custom `AssociatedBy` column not populated → NULL constraint violation

### Fix: Add `Omit("Media")`

**File:** `backend/internal/repositories/request_repository.go`

Change line 151 from:
```go
if err := ctx.DB.Save(request).Error; err != nil {
```
To:
```go
// Omit Media to prevent GORM from upserting the many2many join table.
// The join table has custom columns (AssociatedBy) that GORM doesn't populate.
// Media associations are managed via dedicated AssociateMedia/RemoveMedia handlers.
if err := ctx.DB.Omit("Media").Save(request).Error; err != nil {
```

**Blast radius:** 1 line change, fixes all request update operations (Complete, Cancel, Approve, Reject, Update)

### Test to Add
Add regression test `TestCompleteRequest_WithMedia` that:
1. Creates request with media association
2. Calls CompleteRequest
3. Verifies no error and status updated
4. Verifies media association unchanged

---

## Issue 2: Shared Media Feature

### Requirements (from user)
- Access: "Copy to My Media" - reference, not duplicate storage
- UI: "Mixed in My Media" with 'shared' indicator badge
- Visible when request is `fulfilled` or `completed`

### Implementation Plan

#### Phase 1: Backend Model
**File:** `backend/internal/models/media.go`

Add struct:
```go
type MediaWithSharing struct {
    Media
    IsShared           bool   `json:"is_shared"`
    SharedViaRequestID *uint  `json:"shared_via_request_id,omitempty"`
    SharedByUserID     *uint  `json:"shared_by_user_id,omitempty"`
    SharedByUserName   string `json:"shared_by_user_name,omitempty"`
}
```

#### Phase 2: Repository Layer
**File:** `backend/internal/repositories/media_repository.go`

Add methods to interface:
- `ListWithShared(ctx, userID, filters, pagination) ([]MediaWithSharing, int64, error)`
- `FindByIDWithAccess(ctx, userID, mediaID) (*MediaWithSharing, error)`
- `CheckMediaAccess(ctx, userID, mediaID) (hasAccess, isShared bool, err)`

Implementation uses UNION query:
```sql
-- Owned media
SELECT m.*, false AS is_shared, NULL AS shared_via_request_id
FROM media m WHERE m.user_id = ? AND m.deleted_at IS NULL

UNION ALL

-- Shared media via fulfilled requests
SELECT m.*, true AS is_shared, rm.request_id, rm.associated_by, u.name
FROM media m
JOIN request_media rm ON m.id = rm.media_id
JOIN requests r ON rm.request_id = r.id
JOIN users u ON rm.associated_by = u.id
WHERE r.requested_by = ?
  AND r.status IN ('fulfilled', 'completed')
  AND m.user_id != ?
  AND m.deleted_at IS NULL
```

#### Phase 3: Handler Updates
**File:** `backend/internal/handlers/media_handler.go`

- `ListMedia`: Use `ListWithShared` instead of `List`
- `GetDownloadURL`: Use `FindByIDWithAccess` instead of `FindByID`
- `GetThumbnailURL`: Same pattern as GetDownloadURL
- `GetMedia`: Use `FindByIDWithAccess` for viewing details

#### Phase 4: Frontend
**File:** `frontend/src/types/media.ts`
- Add optional fields: `is_shared`, `shared_via_request_id`, `shared_by_user_id`, `shared_by_user_name`

**File:** `frontend/src/components/MediaCard.tsx` (or equivalent)
- Add shared badge when `is_shared === true`

---

## Files to Modify

### Bug Fix (Issue 1)
| File | Change |
|------|--------|
| `backend/internal/repositories/request_repository.go` | Add `Omit("Media")` to Save (line 151) |
| `backend/internal/handlers/request_test.go` | Add regression test |

### Shared Media Feature (Issue 2)
| File | Change |
|------|--------|
| `backend/internal/models/media.go` | Add `MediaWithSharing` struct |
| `backend/internal/repositories/media_repository.go` | Add `ListWithShared`, `FindByIDWithAccess`, `CheckMediaAccess` |
| `backend/internal/handlers/media_handler.go` | Update `ListMedia`, `GetDownloadURL`, `GetThumbnailURL`, `GetMedia` |
| `backend/internal/repositories/media_repository_test.go` | Add tests for shared access |
| `frontend/src/types/media.ts` | Add sharing fields to Media interface |
| `frontend/src/components/MediaCard.tsx` | Add shared badge indicator |

---

## Implementation Order

1. **Bug fix first** (Issue 1) - single line change, unblocks user
2. **Backend model** - MediaWithSharing struct
3. **Repository methods** - UNION query implementation
4. **Repository tests** - shared media access scenarios
5. **Handler updates** - use new access-aware methods
6. **Frontend types** - add sharing fields
7. **Frontend UI** - shared badge

---

## Security Notes

- Shared media is read-only (no edit/delete for requestor)
- Only visible when request status is `fulfilled` or `completed`
- Existing security checks (pending_scan, quarantined) still apply
- Audit log tracks downloads with `is_shared` flag

---

## Testing Scenarios

1. User lists media → sees owned + shared with correct badges
2. User downloads shared media → succeeds with audit log
3. User downloads unshared media from stranger → denied
4. Request cancelled → shared media no longer visible
5. Complete request with media → no NULL constraint error
