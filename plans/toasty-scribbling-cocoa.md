# Documentation Improvement Plan

## Overview

**Scope:** Comprehensive documentation update
**Estimated Effort:** 18-22 hours
**Deliverables:** 11 documentation updates

## Approach

Perform a comprehensive documentation update that:
1. Fixes all stale line number references in existing docs
2. Documents all undocumented endpoints (Media API + Quarantine API)
3. Updates status trackers to reflect actual implementation state
4. Adds the 7 "coming soon" detailed API docs

---

## Phase 1: Fix Stale References (2-3 hours)

### Task 1.1: Update API Overview Line Numbers
**File:** `docs/reference/api/overview.md`

Update all source code references to match current `main.go`:

| Section | Documented Lines | Actual Lines |
|---------|-----------------|--------------|
| setupAuthRoutes | 158-171 | 339-354 |
| setupUploadRoutes | 173-180 | 357-363 |
| setupVideoRoutes | 182-191 | 366-374 |
| setupRequestRoutes | 193-208 | 377-391 |
| setupGroupRoutes | 210-247 | 394-430 |
| setupUserRoutes | 249-255 | 433-438 |
| setupInvitationRoutes | 257-266 | 441-449 |
| setupHealthCheck | 136-143 | 315-321 |
| setupMiddleware | 122-134 | 294-312 |

### Task 1.2: Update Implementation Status
**File:** `docs/product-specs/IMPLEMENTATION_STATUS.md`

- Change "Personal Media Catalog" from ❌ NOT STARTED to ✅ BACKEND COMPLETE
- Add Media Handler implementation details
- Add Quarantine Handler implementation details
- Update "Last Updated" date

### Task 1.3: Update Product Spec Metadata
**File:** `docs/product-specs/overview.md`

- Bump version from 2.1 to 2.2
- Update "Last Updated" to current date
- Add malware scanning to features list

---

## Phase 2: Document New APIs (6-8 hours)

### Task 2.1: Create Media API Documentation
**File:** `docs/reference/api/media.md` (NEW)

Document all 8 endpoints:
1. `GET /api/media` - List user's media with pagination
2. `POST /api/media/upload-url` - Request presigned upload URL
3. `GET /api/media/{id}` - Get media details
4. `GET /api/media/{id}/download-url` - Get presigned download URL
5. `POST /api/media/{id}/complete` - Complete upload (validation + scan)
6. `PATCH /api/media/{id}` - Update media metadata
7. `DELETE /api/media/{id}` - Delete media
8. `GET /api/media/{id}/requests` - List associated requests

**Include:**
- Request/response schemas (from media_handler.go exploration)
- Validation rules
- Malware scanning workflow documentation
- Error responses
- Source code references with accurate line numbers

### Task 2.2: Create Quarantine API Documentation
**File:** `docs/reference/api/quarantine.md` (NEW)

Document all 4 admin endpoints:
1. `GET /api/admin/quarantine` - List quarantined files
2. `GET /api/admin/quarantine/stats` - Get quarantine statistics
3. `GET /api/admin/quarantine/{id}` - Get quarantine details
4. `DELETE /api/admin/quarantine/{id}` - Delete quarantine record

**Include:**
- Admin permission requirements
- QuarantineStats response schema
- ThreatSummary structure
- Error responses

### Task 2.3: Update API Overview with New Sections
**File:** `docs/reference/api/overview.md`

Add two new sections:
- Media Catalog endpoints table
- Quarantine Management endpoints table (with admin badge)

---

## Phase 3: Create Detailed API Docs (8-10 hours)

Create the 7 "coming soon" detailed API documentation pages:

### Task 3.1: Authentication API
**File:** `docs/reference/api/auth.md` (NEW)
- Register, Login, Refresh, Logout, GetCurrentUser
- JWT token flow documentation
- Rate limiting notes

### Task 3.2: Upload API
**File:** `docs/reference/api/upload.md` (NEW)
- InitializeUpload, CompleteUpload
- R2 presigned URL workflow
- Multipart upload notes

### Task 3.3: Videos API
**File:** `docs/reference/api/videos.md` (NEW)
- ListVideos, ApproveVideo, UpdateVideoMetadata, DeleteVideo
- Approval workflow states

### Task 3.4: Requests API
**File:** `docs/reference/api/requests.md` (NEW)
- Full request lifecycle (create → approve → assign → complete)
- All 10 endpoints documented

### Task 3.5: Groups API
**File:** `docs/reference/api/groups.md` (NEW)
- Group CRUD
- Member management
- Permission levels (owner/moderator/member)

### Task 3.6: Users API
**File:** `docs/reference/api/users.md` (NEW)
- SearchUsers endpoint
- @username autocomplete behavior

### Task 3.7: Invitations API
**File:** `docs/reference/api/invitations.md` (NEW)
- Create, List, Accept, Reject
- 7-day expiry behavior

---

## Phase 4: Final Updates (1-2 hours)

### Task 4.1: Update Overview Links
**File:** `docs/reference/api/overview.md`

Replace "(coming soon)" links with actual file references:
- `[Authentication API](auth.md)`
- `[Upload API](upload.md)`
- etc.

### Task 4.2: Verification Metadata
Update verification metadata in all modified files with:
- Current date
- Verification checklist
- Source file references

---

## Critical Files to Modify

| File | Action | Priority |
|------|--------|----------|
| `docs/reference/api/overview.md` | Update line refs + add sections | P0 |
| `docs/product-specs/IMPLEMENTATION_STATUS.md` | Fix media catalog status | P0 |
| `docs/reference/api/media.md` | CREATE - 8 endpoints | P0 |
| `docs/reference/api/quarantine.md` | CREATE - 4 endpoints | P0 |
| `docs/reference/api/auth.md` | CREATE | P1 |
| `docs/reference/api/upload.md` | CREATE | P1 |
| `docs/reference/api/videos.md` | CREATE | P1 |
| `docs/reference/api/requests.md` | CREATE | P1 |
| `docs/reference/api/groups.md` | CREATE | P1 |
| `docs/reference/api/users.md` | CREATE | P1 |
| `docs/reference/api/invitations.md` | CREATE | P1 |
| `docs/product-specs/overview.md` | Update version/date | P2 |

---

## Source Files for Reference

| Handler | File | Lines |
|---------|------|-------|
| Auth | `backend/internal/handlers/auth.go` | Full file |
| Upload | `backend/internal/handlers/upload.go` | Full file |
| Approval | `backend/internal/handlers/approval.go` | Full file |
| Request | `backend/internal/handlers/request.go` | Full file |
| Group | `backend/internal/handlers/group.go` | Full file |
| User | `backend/internal/handlers/user.go` | Full file |
| Invitation | `backend/internal/handlers/invitation.go` | Full file |
| Media | `backend/internal/handlers/media_handler.go` | Full file |
| Quarantine | `backend/internal/handlers/quarantine_handler.go` | Full file |
| Routes | `backend/cmd/api/main.go` | 282-476 |

---

## Execution Order

1. **Phase 1** - Fix stale references (establishes accuracy baseline)
2. **Phase 2** - Document new APIs (highest impact - unblocks users)
3. **Phase 3** - Create detailed docs (fills "coming soon" gaps)
4. **Phase 4** - Final updates (polish and link everything)

---

## Success Criteria

- [ ] All line number references match actual source code
- [ ] Media API fully documented with all 8 endpoints
- [ ] Quarantine API fully documented with all 4 endpoints
- [ ] All 7 "coming soon" pages replaced with real content
- [ ] IMPLEMENTATION_STATUS.md reflects actual state
- [ ] All docs have verification metadata with current date
- [ ] Zero fabricated APIs or methods
