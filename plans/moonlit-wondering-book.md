# Multi-Media Migration Plan

## Overview

The videos → media migration is **already largely complete** at the code level. The remaining work is:
1. Verify database migration script (already exists)
2. **Full cleanup** of legacy "video" terminology in method names, fields, and error messages

---

## Current State Analysis

### Already Complete
| Component | Status | Details |
|-----------|--------|---------|
| Migration SQL | ✅ | `002_rename_videos_to_media.sql` exists |
| Media model | ✅ | Uses `Media` struct with `ContentType` field |
| RequestMedia model | ✅ | Uses `RequestMedia` with `media_id` |
| Repositories | ✅ | All use `models.Media` |
| ContentType enum | ✅ | video/image/audio defined |
| Validation service | ✅ | Type-specific validation for all types |

### Remaining Work
| Item | Priority | Description |
|------|----------|-------------|
| Apply migration | **Required** | Run `002_rename_videos_to_media.sql` on database |
| Verify migration | **Required** | Ensure all tests pass post-migration |
| Method name cleanup | Optional | Rename `ApproveVideo` → `ApproveMedia` etc. |
| File rename | Optional | Rename `video_repository.go` |
| Route cleanup | Optional | Change `/videos` to `/media` in routes |

---

## Implementation Tasks

### Task 1: Verify Migration Script (READ-ONLY)

**File**: `backend/internal/database/migrations/002_rename_videos_to_media.sql`

Verify the migration handles:
- [x] Rename `videos` → `media` table
- [x] Rename `request_videos` → `request_media` junction table
- [x] Rename `video_id` → `media_id` column
- [x] Add `content_type` column with default 'video'
- [x] Rename all indexes
- [x] Rollback script exists

---

### Task 2: Apply Migration

```bash
# Apply migration to PostgreSQL
psql -U demi -d demi_upload -f backend/internal/database/migrations/002_rename_videos_to_media.sql
```

**Pre-flight checks:**
1. Backup database
2. Verify no active uploads in progress
3. Run in maintenance window

---

### Task 3: Run Tests

```bash
cd backend && go test ./... -v
```

All tests should pass since code already uses Media terminology.

---

### Task 4: Full Terminology Cleanup (SELECTED)

Rename all legacy "video" references to "media":

#### 4.1 Handler Method Names
**File**: `backend/internal/handlers/approval.go`
- `ApproveVideo()` → `ApproveMedia()`
- `DeleteVideo()` → `DeleteMedia()`
- `ListVideos()` → `ListMedia()`
- `UpdateVideoMetadata()` → `UpdateMediaMetadata()`

#### 4.2 Handler Method Names
**File**: `backend/internal/handlers/request.go`
- `AssociateVideo()` → `AssociateMedia()`
- `RemoveVideo()` → `RemoveMedia()`
- `createVideoAssociation()` → `createMediaAssociation()`

#### 4.3 Test Helper Names
**File**: `backend/internal/repositories/test_helpers.go`
- `createTestVideo()` → `createTestMedia()`
- `associateVideoWithRequest()` → `associateMediaWithRequest()`

#### 4.4 Repository Field Names
**File**: `backend/internal/repositories/request_repository.go`
- `VideoCount` field in `RequestWithCount` → `MediaCount`
- `ListWithVideoCounts()` → `ListWithMediaCounts()`

#### 4.5 Error Constants
**File**: `backend/internal/handlers/errors.go`
- Update error messages referencing "video" to "media"

#### 4.6 File Rename (Optional)
- `video_repository.go` → merge into `media_repository.go` or rename to `approval_repository.go`

---

## Decision Points

1. **Scope of cleanup**: Apply migration only, or also rename methods/files?
2. **API backward compatibility**: Keep `/api/videos` routes or migrate to `/api/media`?
3. **Frontend impact**: Does frontend need updates for route changes?

---

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Data loss during migration | Full database backup before migration |
| Application downtime | Migration is fast (table renames are metadata-only) |
| Test failures | Tests already use Media models - low risk |
| API breaking changes | Routes currently work - cosmetic only |

---

## Recommended Approach

**Full cleanup approach (user selected):**
1. Run tests to verify baseline
2. Rename all handler methods (Video → Media)
3. Rename test helpers
4. Update repository field names
5. Update error constants
6. Run tests to verify no regressions
7. Commit changes

**Order of changes** (to minimize test failures during refactor):
1. Start with models/repositories (already done)
2. Update handlers
3. Update test helpers
4. Update route registrations
5. Run full test suite

---

## Critical Files

| File | Purpose |
|------|---------|
| `migrations/002_rename_videos_to_media.sql` | Database migration |
| `models/media.go` | Media model (already correct) |
| `models/request.go` | RequestMedia model (already correct) |
| `handlers/approval.go` | Has legacy method names |
| `handlers/request.go` | Has legacy method names |
| `repositories/test_helpers.go` | Has legacy helper names |
