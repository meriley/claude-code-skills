# User Self-Approval System Implementation Plan

## Summary

Align the `Approve` action with the existing ownership-based permission pattern. Currently, approve is an outlier requiring admin role, while all other media operations (update, delete, complete upload) use ownership checks.

## Architectural Context: Existing ABAC Pattern

The codebase already uses ownership-based implicit permissions:

| Operation | Current Check | Location |
|-----------|--------------|----------|
| Update metadata | `media.UserID != userID` | `approval.go:344` |
| Complete upload | `video.UserID != userID` | `upload.go:279` |
| Delete | `media.UserID != userID && role != admin` | `approval.go:190` |
| **Approve** | `userRole != admin` (OUTLIER) | `approval.go:69-73` |

**The fix:** Make `Approve` follow the same owner-only pattern as `Update`.

## Requirements

| Requirement | Implementation |
|-------------|----------------|
| Owner-only approval | Align with existing ownership pattern |
| No reject option | Rejecting = deleting (approve or delete) |
| Visibility | Already owner-scoped via `ListMedia` |
| Auto-approval | Already works (1 hour via scheduler) |
| Request attachment | Already validates `StatusApproved`/`StatusSynced` |

## Key Findings (No Changes Needed)

- **Auto-approval already works:** Scheduler in `/backend/internal/services/scheduler.go` handles 1-hour auto-approval
- **Visibility already correct:** `ListMedia` filters by `userID` - users only see their own media
- **Request validation already correct:** `validateMediaForAssociation` checks `StatusApproved` or `StatusSynced`
- **Ownership pattern exists:** Just need to apply it to approve

---

## Phase 1: Backend Changes

### Task 1.1: Apply Ownership Check to ApproveMedia
**File:** `/backend/internal/handlers/approval.go`

Change from admin-only to owner-only (same pattern as `UpdateMediaMetadata`):

```go
// BEFORE (lines 69-73):
userRole, ok := middleware.GetUserRole(r.Context())
if !ok || userRole != constants.RoleAdmin {
    respondWithError(w, http.StatusForbidden, ErrMsgAdminAccessRequired)
    return
}

// AFTER (move check after fetching media, ~line 100):
if media.UserID != userID {
    respondWithError(w, http.StatusForbidden, ErrMsgNoPermissionApproveMedia)
    return
}
```

### Task 1.2: Remove Admin-Only Handlers
**File:** `/backend/internal/handlers/approval.go`

- Remove `RejectMedia` function (users use existing delete instead)
- Remove `ListPendingForApproval` function (admin queue not needed)

### Task 1.3: Remove Admin Approval Routes
**File:** `/backend/cmd/api/main.go`

- Remove `setupAdminApprovalRoutes` function call
- Keep user approval route: `POST /api/media/approval/:id/approve`

---

## Phase 2: Frontend Changes

### Task 2.1: Add Approve Button to MediaCard
**File:** `/frontend/src/components/MediaCard.tsx`

Add `onApprove` prop and render approve button when `status === 'pending'`:

```tsx
{media.status === 'pending' && onApprove && (
  <Menu.Item
    leftSection={<IconCheck size={14} />}
    color="green"
    onClick={(e) => { e.stopPropagation(); onApprove(media.id); }}
  >
    {t('media.approve')}
  </Menu.Item>
)}
```

### Task 2.2: Add Approve Handler to MediaCatalog
**File:** `/frontend/src/routes/MediaCatalog.tsx`

```tsx
const handleApprove = async (id: number) => {
  await mediaService.approveMedia(id)
  notifications.show({ title: t('common.success'), message: t('media.approveSuccess'), color: 'green' })
  loadMedia()
}
```

### Task 2.3: Add approveMedia to Media Service
**File:** `/frontend/src/services/media.ts`

```typescript
async approveMedia(mediaId: number): Promise<void> {
  await api.post(`/media/approval/${mediaId}/approve`)
}
```

### Task 2.4: Remove Admin Approval Route
**File:** `/frontend/src/App.tsx`

Remove: `<Route path="/admin/approval" element={<ApprovalQueue />} />`

### Task 2.5: Remove Navigation Item
**File:** `/frontend/src/config/navigation.ts`

Remove the 'approval' item from administration section (lines 86-92).

### Task 2.6: Delete Admin Approval Files
- `/frontend/src/routes/ApprovalQueue.tsx`
- `/frontend/src/components/ApprovalQueueCard.tsx`
- `/frontend/src/services/approval.ts`
- `/frontend/src/types/approval.ts`

### Task 2.7: Add Translations
**File:** `/frontend/src/locales/en/translation.json`

```json
"approve": "Approve",
"approveSuccess": "Media approved successfully"
```

---

## Phase 3: Test Updates

### Task 3.1: Update Backend Tests
**File:** `/backend/internal/handlers/approval_test.go`

- Change `TestApproveVideo` from admin to owner approval
- Remove reject-related tests
- Add: "Owner can approve their pending media"
- Add: "Non-owner cannot approve media"

---

## Critical Files

| File | Change |
|------|--------|
| `/backend/internal/handlers/approval.go` | Owner check, remove reject/list |
| `/backend/cmd/api/main.go` | Remove admin routes |
| `/frontend/src/components/MediaCard.tsx` | Add approve button |
| `/frontend/src/routes/MediaCatalog.tsx` | Add approve handler |
| `/frontend/src/services/media.ts` | Add approveMedia method |
| `/frontend/src/App.tsx` | Remove admin route |
| `/frontend/src/config/navigation.ts` | Remove admin nav item |

---

## Testing Checklist

- [ ] Owner can approve their pending media
- [ ] Owner cannot approve another user's media
- [ ] Already approved media returns error
- [ ] Auto-approval still works after 1 hour
- [ ] Approve button appears only for pending media
- [ ] Request-media attachment validates approved/synced status
