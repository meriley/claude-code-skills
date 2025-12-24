# Media Group Sharing - Implementation Plan

**PRD Location:** `docs/product-specs/media-group-sharing-spec.md`

---

## Implementation Overview

This plan implements direct media-to-group sharing with approval workflows, role-based visibility (Owner/Moderator only), immediate group revocation, and 5-day delayed user revocation.

---

## Skills Required by Phase

| Phase | Description | Skills to Invoke |
|-------|-------------|------------------|
| **Phase 1** | Backend Models & Database | `setup-go` (if Go env not ready) |
| **Phase 2** | Backend Repositories | `error-handling-audit`, `control-flow-check` (after implementation) |
| **Phase 3** | Backend Handlers | `error-handling-audit` (after implementation) |
| **Phase 4** | Background Worker | `error-handling-audit` (after implementation) |
| **Phase 5** | Backend Tests | `run-tests` |
| **Phase 6** | Frontend Types & Services | `type-safety-audit` (after implementation) |
| **Phase 7** | Frontend Components | `mantine-developing`, `mantine-reviewing` (after implementation) |
| **Phase 8** | Frontend Tests | `run-tests` |
| **Phase 9** | Integration & Quality | `quality-check`, `security-scan`, `run-tests` (via `safe-commit`) |
| **All Commits** | Every commit | `safe-commit` (mandatory - includes security, quality, tests) |

### Skill Invocation Guide

**Before starting any phase:**
- `check-history` - Already done at session start

**During Go implementation (Phases 1-4):**
- After writing Go code → `error-handling-audit` (check %w wrapping, error context)
- After writing Go code → `control-flow-check` (check early returns, nesting depth)

**During TypeScript implementation (Phases 6-7):**
- After writing types → `type-safety-audit` (check for `any`, branded IDs)
- After writing components → `mantine-developing` (patterns reference)
- Before committing components → `mantine-reviewing` (accessibility, patterns)

**Before every commit:**
- `safe-commit` (MANDATORY - runs security-scan, quality-check, run-tests automatically)

---

## Phase 1: Backend Models & Database
**Skills:** `setup-go` (if needed)

### Step 1.1: Create GroupMedia Model
**Skill:** `setup-go` (if needed), then manual implementation
**File:** `backend/internal/models/group_media.go`

```go
// GroupMediaStatus enum
type GroupMediaStatus string

const (
    GroupMediaStatusPending  GroupMediaStatus = "pending"
    GroupMediaStatusApproved GroupMediaStatus = "approved"
    GroupMediaStatusRejected GroupMediaStatus = "rejected"
)

// GroupMedia model
type GroupMedia struct {
    ID           uint              `gorm:"primarykey" json:"id"`
    GroupID      uint              `gorm:"not null;index" json:"group_id"`
    MediaID      uint              `gorm:"not null;index" json:"media_id"`
    SharedByID   uint              `gorm:"not null" json:"shared_by_id"`
    Status       GroupMediaStatus  `gorm:"not null;default:'pending';index" json:"status"`
    ApprovedByID *uint             `json:"approved_by_id,omitempty"`
    ApprovedAt   *time.Time        `json:"approved_at,omitempty"`
    RejectedByID *uint             `json:"rejected_by_id,omitempty"`
    RejectedAt   *time.Time        `json:"rejected_at,omitempty"`
    RejectReason *string           `gorm:"type:text" json:"reject_reason,omitempty"`
    CreatedAt    time.Time         `json:"created_at"`
    UpdatedAt    time.Time         `json:"updated_at"`

    // Relationships
    Group      *Group `gorm:"foreignKey:GroupID" json:"group,omitempty"`
    Media      *Media `gorm:"foreignKey:MediaID" json:"media,omitempty"`
    SharedBy   *User  `gorm:"foreignKey:SharedByID" json:"shared_by,omitempty"`
    ApprovedBy *User  `gorm:"foreignKey:ApprovedByID" json:"approved_by,omitempty"`
    RejectedBy *User  `gorm:"foreignKey:RejectedByID" json:"rejected_by,omitempty"`
}

func (GroupMedia) TableName() string {
    return "group_media"
}

// State machine helpers
func (gm *GroupMedia) CanBeApproved() bool {
    return gm.Status == GroupMediaStatusPending
}

func (gm *GroupMedia) CanBeRejected() bool {
    return gm.Status == GroupMediaStatusPending
}
```

### Step 1.2: Create UserMediaRevocation Model
**Skill:** Manual implementation (follows same pattern)
**File:** `backend/internal/models/user_media_revocation.go`

```go
type UserMediaRevocation struct {
    ID          uint       `gorm:"primarykey" json:"id"`
    MediaID     uint       `gorm:"not null;index" json:"media_id"`
    UserID      uint       `gorm:"not null;index" json:"user_id"`
    RevokedByID uint       `gorm:"not null" json:"revoked_by_id"`
    RevokedAt   time.Time  `gorm:"not null" json:"revoked_at"`
    EffectiveAt time.Time  `gorm:"not null;index" json:"effective_at"`
    Cancelled   bool       `gorm:"default:false" json:"cancelled"`
    CancelledAt *time.Time `json:"cancelled_at,omitempty"`
    CreatedAt   time.Time  `json:"created_at"`

    // Relationships
    Media     *Media `gorm:"foreignKey:MediaID" json:"media,omitempty"`
    User      *User  `gorm:"foreignKey:UserID" json:"user,omitempty"`
    RevokedBy *User  `gorm:"foreignKey:RevokedByID" json:"revoked_by,omitempty"`
}

func (UserMediaRevocation) TableName() string {
    return "user_media_revocations"
}

func (r *UserMediaRevocation) IsEffective() bool {
    return !r.Cancelled && time.Now().After(r.EffectiveAt)
}

func (r *UserMediaRevocation) DaysRemaining() int {
    if r.Cancelled {
        return 0
    }
    remaining := time.Until(r.EffectiveAt)
    if remaining <= 0 {
        return 0
    }
    return int(remaining.Hours() / 24) + 1
}
```

### Step 1.3: Register Models for Auto-Migration
**Skill:** Manual edit
**File:** `backend/internal/database/database.go`

Add to `AutoMigrate()`:
```go
&models.GroupMedia{},
&models.UserMediaRevocation{},
```

---

## Phase 2: Backend Repository Layer
**Skills:** `error-handling-audit`, `control-flow-check` (after implementation)

### Step 2.1: Create GroupMedia Repository
**Skill:** `error-handling-audit`, `control-flow-check` (after implementation)
**File:** `backend/internal/repositories/group_media_repository.go`

```go
type GroupMediaRepository interface {
    Create(ctx rms.Ctx, gm *models.GroupMedia) error
    FindByID(ctx rms.Ctx, id uint) (*models.GroupMedia, error)
    FindByGroupAndMedia(ctx rms.Ctx, groupID, mediaID uint) (*models.GroupMedia, error)
    ListByGroup(ctx rms.Ctx, groupID uint, filters GroupMediaFilters, pagination utils.PaginationParams) ([]models.GroupMedia, int64, error)
    ListByMedia(ctx rms.Ctx, mediaID uint) ([]models.GroupMedia, error)
    Update(ctx rms.Ctx, gm *models.GroupMedia) error
    Delete(ctx rms.Ctx, id uint) error
    DeleteByGroupAndMedia(ctx rms.Ctx, groupID, mediaID uint) error
}

type GroupMediaFilters struct {
    Status   string
    SharedBy uint
}
```

### Step 2.2: Create UserMediaRevocation Repository
**Skill:** `error-handling-audit`, `control-flow-check` (after implementation)
**File:** `backend/internal/repositories/user_media_revocation_repository.go`

```go
type UserMediaRevocationRepository interface {
    Create(ctx rms.Ctx, r *models.UserMediaRevocation) error
    FindByID(ctx rms.Ctx, id uint) (*models.UserMediaRevocation, error)
    FindActiveByMediaAndUser(ctx rms.Ctx, mediaID, userID uint) (*models.UserMediaRevocation, error)
    ListByMedia(ctx rms.Ctx, mediaID uint) ([]models.UserMediaRevocation, error)
    ListPendingEffective(ctx rms.Ctx) ([]models.UserMediaRevocation, error)
    Update(ctx rms.Ctx, r *models.UserMediaRevocation) error
    Delete(ctx rms.Ctx, id uint) error
}
```

---

## Phase 3: Backend Handlers
**Skills:** `error-handling-audit` (after implementation)

### Step 3.1: Add Share Endpoints to MediaHandler
**Skill:** `error-handling-audit` (after implementation)
**File:** `backend/internal/handlers/media_handler.go`

Add these endpoints:
- `POST /api/media/{id}/share` - ShareWithGroup
- `GET /api/media/{id}/shares` - ListShares
- `DELETE /api/media/{id}/share/{groupId}` - RevokeFromGroup
- `POST /api/media/{id}/revoke-user` - RevokeFromUser
- `GET /api/media/{id}/revocations` - ListRevocations
- `DELETE /api/media/{id}/revocations/{revocationId}` - CancelRevocation

```go
// ShareWithGroup shares media with a group (pending approval)
func (h *MediaHandler) ShareWithGroup(w http.ResponseWriter, r *http.Request) {
    // 1. Get user ID, verify ownership
    // 2. Validate media is approved/synced
    // 3. Verify user is member of target group
    // 4. Check not already shared
    // 5. Create GroupMedia with status=pending
    // 6. Audit log
}

// RevokeFromUser initiates 5-day delayed revocation
func (h *MediaHandler) RevokeFromUser(w http.ResponseWriter, r *http.Request) {
    // 1. Get user ID, verify ownership
    // 2. Check user didn't receive via request (protected)
    // 3. Create UserMediaRevocation with effective_at = now + 5 days
    // 4. Audit log
}
```

### Step 3.2: Add Approval Endpoints to GroupHandler
**Skill:** `error-handling-audit` (after implementation)
**File:** `backend/internal/handlers/group_handler.go`

Add these endpoints:
- `GET /api/groups/{id}/shared-media` - ListSharedMedia (Owner/Mod only)
- `POST /api/groups/{id}/shared-media/{mediaId}/approve` - ApproveShare
- `POST /api/groups/{id}/shared-media/{mediaId}/reject` - RejectShare

```go
// ApproveShare approves a pending media share
func (h *GroupHandler) ApproveShare(w http.ResponseWriter, r *http.Request) {
    // 1. Get user ID
    // 2. Verify user is Owner or Moderator of group
    // 3. Find pending GroupMedia record
    // 4. Update status=approved, approved_by, approved_at
    // 5. Audit log
}
```

### Step 3.3: Register Routes
**Skill:** Manual edit
**File:** `backend/cmd/api/main.go`

```go
// Media sharing routes (authenticated)
r.Route("/media/{id}", func(r chi.Router) {
    r.Post("/share", mediaHandler.ShareWithGroup)
    r.Get("/shares", mediaHandler.ListShares)
    r.Delete("/share/{groupId}", mediaHandler.RevokeFromGroup)
    r.Post("/revoke-user", mediaHandler.RevokeFromUser)
    r.Get("/revocations", mediaHandler.ListRevocations)
    r.Delete("/revocations/{revocationId}", mediaHandler.CancelRevocation)
})

// Group shared media routes (Owner/Mod only)
r.Route("/groups/{id}/shared-media", func(r chi.Router) {
    r.Get("/", groupHandler.ListSharedMedia)
    r.Post("/{mediaId}/approve", groupHandler.ApproveShare)
    r.Post("/{mediaId}/reject", groupHandler.RejectShare)
})
```

---

## Phase 4: Background Worker
**Skills:** `error-handling-audit` (after implementation)

### Step 4.1: Create RevocationEnforcer Worker
**Skill:** `error-handling-audit` (after implementation)
**File:** `backend/internal/services/revocation_worker.go`

```go
// RevocationEnforcer processes pending user revocations
func (s *Scheduler) runRevocationEnforcement() {
    // 1. Find all UserMediaRevocation where effective_at <= now AND cancelled = false
    // 2. For each revocation:
    //    a. Delete user's access (implementation depends on access model)
    //    b. Mark revocation as processed (or delete)
    //    c. Create audit log
    // 3. Log summary
}
```

### Step 4.2: Add to Scheduler
**Skill:** Manual edit
**File:** `backend/internal/services/scheduler.go`

```go
func (s *Scheduler) Start() {
    go func() {
        SafeRun("auto-approval", s.runAutoApproval)
        SafeRun("revocation-enforcement", s.runRevocationEnforcement) // Add this

        for {
            select {
            case <-s.ticker.C:
                SafeRun("auto-approval", s.runAutoApproval)
                SafeRun("revocation-enforcement", s.runRevocationEnforcement) // Add this
            case <-s.done:
                return
            }
        }
    }()
}
```

---

## Phase 5: Backend Tests
**Skills:** `run-tests`

### Step 5.1: Model Tests
**Skill:** `run-tests` (to verify)
**Files:**
- `backend/internal/models/group_media_test.go`
- `backend/internal/models/user_media_revocation_test.go`

### Step 5.2: Repository Tests
**Skill:** `run-tests` (to verify)
**Files:**
- `backend/internal/repositories/group_media_repository_test.go`
- `backend/internal/repositories/user_media_revocation_repository_test.go`

### Step 5.3: Handler Tests
**Skill:** `run-tests` (to verify)
**Files:**
- `backend/internal/handlers/media_handler_test.go` (add share tests)
- `backend/internal/handlers/group_handler_test.go` (add approval tests)

---

## Phase 6: Frontend Types & Services
**Skills:** `type-safety-audit` (after implementation)

### Step 6.1: Add TypeScript Types
**Skill:** `type-safety-audit` (after implementation)
**File:** `frontend/src/types/media.ts`

```typescript
export type GroupMediaStatus = 'pending' | 'approved' | 'rejected'

export interface GroupMedia {
  id: number
  group_id: number
  media_id: number
  shared_by_id: number
  status: GroupMediaStatus
  approved_by_id?: number
  approved_at?: string
  rejected_by_id?: number
  rejected_at?: string
  reject_reason?: string
  created_at: string
  // Populated relationships
  group?: Group
  shared_by?: User
}

export interface UserMediaRevocation {
  id: number
  media_id: number
  user_id: number
  revoked_by_id: number
  revoked_at: string
  effective_at: string
  cancelled: boolean
  cancelled_at?: string
  // Populated relationships
  user?: User
}

export interface ShareMediaRequest {
  group_id: number
}

export interface RevokeUserRequest {
  user_id: number
}
```

### Step 6.2: Add Media Service Methods
**Skill:** Manual implementation
**File:** `frontend/src/services/media.ts`

```typescript
// Share with group
async shareWithGroup(mediaId: number, groupId: number): Promise<GroupMedia> {
  const response = await api.post<GroupMedia>(`/media/${mediaId}/share`, { group_id: groupId })
  return response.data
}

// List shares
async listShares(mediaId: number): Promise<GroupMedia[]> {
  const response = await api.get<GroupMedia[]>(`/media/${mediaId}/shares`)
  return response.data
}

// Revoke from group
async revokeFromGroup(mediaId: number, groupId: number): Promise<void> {
  await api.delete(`/media/${mediaId}/share/${groupId}`)
}

// Revoke from user
async revokeFromUser(mediaId: number, userId: number): Promise<UserMediaRevocation> {
  const response = await api.post<UserMediaRevocation>(`/media/${mediaId}/revoke-user`, { user_id: userId })
  return response.data
}

// List revocations
async listRevocations(mediaId: number): Promise<UserMediaRevocation[]> {
  const response = await api.get<UserMediaRevocation[]>(`/media/${mediaId}/revocations`)
  return response.data
}

// Cancel revocation
async cancelRevocation(mediaId: number, revocationId: number): Promise<void> {
  await api.delete(`/media/${mediaId}/revocations/${revocationId}`)
}
```

### Step 6.3: Add Group Service Methods
**Skill:** Manual implementation
**File:** `frontend/src/services/group.ts`

```typescript
// List shared media (Owner/Mod only)
async listSharedMedia(groupId: number, status?: GroupMediaStatus): Promise<GroupMedia[]> {
  const params = status ? `?status=${status}` : ''
  const response = await api.get<GroupMedia[]>(`/groups/${groupId}/shared-media${params}`)
  return response.data
}

// Approve share
async approveShare(groupId: number, mediaId: number): Promise<GroupMedia> {
  const response = await api.post<GroupMedia>(`/groups/${groupId}/shared-media/${mediaId}/approve`)
  return response.data
}

// Reject share
async rejectShare(groupId: number, mediaId: number, reason: string): Promise<GroupMedia> {
  const response = await api.post<GroupMedia>(`/groups/${groupId}/shared-media/${mediaId}/reject`, { reason })
  return response.data
}
```

---

## Phase 7: Frontend Components
**Skills:** `mantine-developing`, `mantine-reviewing` (after implementation)

### Step 7.1: Create ShareWithGroupModal
**Skill:** `mantine-developing`, `mantine-reviewing` (after implementation)
**File:** `frontend/src/components/ShareWithGroupModal.tsx`

Features:
- List groups user is member of
- Filter by group name
- Show existing share status per group
- Submit shares media to selected group

### Step 7.2: Create GroupSharedMediaTab
**Skill:** `mantine-developing`, `mantine-reviewing` (after implementation)
**File:** `frontend/src/components/groups/GroupSharedMediaTab.tsx`

Features:
- List shared media (grid view)
- Filter by status (pending/approved/rejected)
- Approve/Reject buttons for Owner/Mod
- Show sharer info and date

### Step 7.3: Create MediaSharingDetails Component
**Skill:** `mantine-developing` (after implementation)
**File:** `frontend/src/components/MediaSharingDetails.tsx`

Features:
- Show "Shared With" section with group list
- Show status badges (pending/approved/rejected)
- Revoke buttons per group
- Show "Pending Revocations" section
- Cancel revocation button

### Step 7.4: Update GroupDetailPage
**Skill:** Manual edit
**File:** `frontend/src/routes/GroupDetailPage.tsx`

Add:
- Shared Media tab (visible only to Owner/Moderator)
- Import and render `GroupSharedMediaTab`

---

## Phase 8: Frontend Tests
**Skills:** `run-tests`

### Step 8.1: Component Tests
**Skill:** `run-tests` (to verify)
**Files:**
- `frontend/src/components/ShareWithGroupModal.test.tsx`
- `frontend/src/components/groups/GroupSharedMediaTab.test.tsx`
- `frontend/src/components/MediaSharingDetails.test.tsx`

---

## Phase 9: Integration & Quality
**Skills:** `quality-check`, `security-scan`, `run-tests` (all via `safe-commit`)

### Step 9.1: Add i18n Translations
**Skill:** Manual implementation
**File:** `frontend/src/i18n/locales/en.json`

```json
{
  "mediaSharing": {
    "shareWithGroup": "Share with Group",
    "selectGroup": "Select a group to share with",
    "pendingApproval": "Pending Approval",
    "approved": "Approved",
    "rejected": "Rejected",
    "revokeFromGroup": "Revoke from Group",
    "revokeFromUser": "Revoke User Access",
    "revocationPending": "Revocation pending ({{days}} days remaining)",
    "cancelRevocation": "Cancel Revocation",
    "protectedAccess": "This user has protected access via request fulfillment"
  },
  "groupSharedMedia": {
    "title": "Shared Media",
    "noSharedMedia": "No media has been shared with this group yet",
    "approveShare": "Approve",
    "rejectShare": "Reject",
    "sharedBy": "Shared by {{name}}",
    "pendingReview": "Pending Review"
  }
}
```

### Step 9.2: Run Full Quality Check
**Skill:** `quality-check` (automatic via safe-commit)

### Step 9.3: Run Tests
**Skill:** `run-tests` (automatic via safe-commit)

### Step 9.4: Security Scan
**Skill:** `security-scan` (automatic via safe-commit)

---

## Commit Strategy

### Commit 1: Backend Models
**Skill:** `safe-commit`
```
feat(models): add GroupMedia and UserMediaRevocation models

- Add GroupMedia for direct media-to-group sharing
- Add UserMediaRevocation for 5-day delayed user revocation
- Add status enums and state machine helpers
```

### Commit 2: Backend Repositories
**Skill:** `safe-commit`
```
feat(repos): add GroupMedia and UserMediaRevocation repositories

- Implement CRUD operations
- Add filter-based queries
- Add pending revocation lookup
```

### Commit 3: Backend Handlers + Routes
**Skill:** `safe-commit`
```
feat(handlers): add media sharing and approval endpoints

- POST /media/{id}/share - share with group
- DELETE /media/{id}/share/{groupId} - revoke from group
- POST /media/{id}/revoke-user - 5-day user revocation
- GET/POST /groups/{id}/shared-media - list/approve/reject
```

### Commit 4: Background Worker
**Skill:** `safe-commit`
```
feat(scheduler): add revocation enforcement worker

- Process expired user revocations daily
- Audit log each enforcement
```

### Commit 5: Frontend Types & Services
**Skill:** `safe-commit`
```
feat(frontend): add media sharing types and services

- Add GroupMedia and UserMediaRevocation types
- Add mediaService share/revoke methods
- Add groupService approval methods
```

### Commit 6: Frontend Components
**Skill:** `safe-commit`
```
feat(frontend): add media sharing UI components

- ShareWithGroupModal for sharing media
- GroupSharedMediaTab for approval workflow
- MediaSharingDetails for managing shares
- Add i18n translations
```

---

## Skills Summary by Phase

| Phase | Primary Skills | Verification Skills |
|-------|---------------|---------------------|
| 1. Models | `setup-go` (if needed) | - |
| 2. Repositories | - | `error-handling-audit`, `control-flow-check` |
| 3. Handlers | - | `error-handling-audit` |
| 4. Worker | - | `error-handling-audit` |
| 5. Backend Tests | `run-tests` | - |
| 6. Frontend Services | - | `type-safety-audit` |
| 7. Frontend Components | `mantine-developing` | `mantine-reviewing` |
| 8. Frontend Tests | `run-tests` | - |
| 9. Integration | `quality-check`, `security-scan`, `run-tests` | - |
| Commits | `safe-commit` (all commits) | - |

---

## Files to Create

**Backend (7 files):**
1. `backend/internal/models/group_media.go`
2. `backend/internal/models/user_media_revocation.go`
3. `backend/internal/repositories/group_media_repository.go`
4. `backend/internal/repositories/user_media_revocation_repository.go`
5. `backend/internal/services/revocation_worker.go`
6. `backend/internal/models/group_media_test.go`
7. `backend/internal/models/user_media_revocation_test.go`

**Frontend (4 files):**
1. `frontend/src/components/ShareWithGroupModal.tsx`
2. `frontend/src/components/groups/GroupSharedMediaTab.tsx`
3. `frontend/src/components/MediaSharingDetails.tsx`
4. `frontend/src/components/ShareWithGroupModal.test.tsx`

## Files to Modify

**Backend (4 files):**
1. `backend/internal/database/database.go` - Add model migration
2. `backend/internal/handlers/media_handler.go` - Add share endpoints
3. `backend/internal/handlers/group_handler.go` - Add approval endpoints
4. `backend/cmd/api/main.go` - Register routes

**Frontend (4 files):**
1. `frontend/src/types/media.ts` - Add types
2. `frontend/src/services/media.ts` - Add service methods
3. `frontend/src/services/group.ts` - Add service methods
4. `frontend/src/routes/GroupDetailPage.tsx` - Add shared media tab
5. `frontend/src/i18n/locales/en.json` - Add translations
