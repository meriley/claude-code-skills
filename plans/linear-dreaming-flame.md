# Implementation Plan: Audit Logging Enhancements

## Summary

Update the status document and comprehensively enhance the audit logging system with:
1. Authentication event logging
2. Tag/Category event logging
3. Admin UI enhancements (user filter, export, stats)

**Estimated Time**: 4-6 hours

---

## Task 1: Update IMPLEMENTATION_STATUS.md

**Files to modify:**
- `/docs/product-specs/IMPLEMENTATION_STATUS.md`

**Changes:**
1. Mark Tags & Categories tests as ✅ **COMPLETE** (71 handler tests exist and pass)
2. Update Audit Logging section:
   - Backend: ✅ **COMPLETE** (3 API endpoints exist)
   - Frontend: ✅ **PARTIAL** → note UI exists at `/activity`
   - Update gaps list to reflect current state

---

## Task 2: Authentication Event Logging

**Files to modify:**
- `/backend/internal/handlers/auth.go`

**Events to add (from spec):**

| Event | Trigger | Details |
|-------|---------|---------|
| `auth.register` | After successful registration | `{email, role}` |
| `auth.login` | After successful login | `{email}` |
| `auth.login_failed` | After failed login | `{email, reason}` |
| `auth.logout` | After logout | `{email}` |
| `auth.token_refreshed` | After token refresh | `{email}` |

**Implementation pattern:**
```go
// In Register handler, after successful user creation:
createAuditLog(h.db, user.ID, "auth.register", "user", &user.ID,
    map[string]interface{}{"email": user.Email, "role": user.Role}, r)

// In Login handler, after successful authentication:
createAuditLog(h.db, user.ID, "auth.login", "user", &user.ID,
    map[string]interface{}{"email": user.Email}, r)

// In Login handler, on failure (before return):
// Note: user_id may be 0 if user not found
createAuditLog(h.db, 0, "auth.login_failed", "user", nil,
    map[string]interface{}{"email": req.Email, "reason": "invalid_credentials"}, r)
```

---

## Task 3: Tag/Category Event Logging

**Files to modify:**
- `/backend/internal/handlers/tag_handler.go`
- `/backend/internal/handlers/category_handler.go`

### Tag Events

| Event | Trigger | Details |
|-------|---------|---------|
| `tag.created` | After CreateTag | `{name, color, is_system}` |
| `tag.updated` | After UpdateTag | `{id, changes}` |
| `tag.deleted` | After DeleteTag | `{id, name}` |
| `media.tag_added` | After AddTagsToMedia | `{media_id, tag_ids}` |
| `media.tag_removed` | After RemoveTagFromMedia | `{media_id, tag_id}` |
| `media.tags_bulk_added` | After BulkAddTags | `{media_ids, tag_ids}` |

### Category Events

| Event | Trigger | Details |
|-------|---------|---------|
| `category.created` | After CreateCategory | `{name, parent_id}` |
| `category.updated` | After UpdateCategory | `{id, changes}` |
| `category.deleted` | After DeleteCategory | `{id, name}` |
| `media.category_added` | After AddCategoriesToMedia | `{media_id, category_ids}` |
| `media.category_removed` | After RemoveCategoryFromMedia | `{media_id, category_id}` |

---

## Task 4: Admin UI Enhancements

**Files to modify:**
- `/frontend/src/routes/AuditLogPage.tsx`
- `/frontend/src/services/auditService.ts`
- `/frontend/src/i18n/locales/en.json`
- `/frontend/src/i18n/locales/ru.json`

### 4.1 User Filter (Admin Only)

Add user selection dropdown that appears only for admin users:

```typescript
// New state
const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
const [users, setUsers] = useState<{id: number, email: string}[]>([]);

// Fetch users on mount (admin only)
useEffect(() => {
  if (user?.role === 'admin') {
    userService.listUsers().then(setUsers);
  }
}, [user]);

// Add Select component to filters
{user?.role === 'admin' && (
  <Select
    label={t('activity.filterByUser')}
    placeholder={t('activity.allUsers')}
    data={users.map(u => ({ value: String(u.id), label: u.email }))}
    value={selectedUserId}
    onChange={setSelectedUserId}
    clearable
  />
)}
```

### 4.2 Export Button

Add CSV export functionality:

```typescript
// In auditService.ts
export const exportAuditLogs = async (filters: AuditFilters): Promise<Blob> => {
  const response = await api.get('/audit/export', {
    params: filters,
    responseType: 'blob'
  });
  return response.data;
};

// In AuditLogPage.tsx
const handleExport = async () => {
  const blob = await auditService.exportAuditLogs(filters);
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `audit-logs-${new Date().toISOString()}.csv`;
  a.click();
};
```

**Backend endpoint needed:**
```go
// GET /api/audit/export
func (h *AuditHandler) ExportAuditLogs(w http.ResponseWriter, r *http.Request) {
    // Same filtering as ListAuditLogs
    // Write CSV response with Content-Disposition header
}
```

### 4.3 Statistics Dashboard

Add stats cards above the table (admin only):

```typescript
interface AuditStats {
  total_events: number;
  events_today: number;
  events_this_week: number;
  top_actions: {action: string, count: number}[];
  top_users: {user_id: number, email: string, count: number}[];
}

// Display as cards
<SimpleGrid cols={4}>
  <StatCard title={t('activity.totalEvents')} value={stats.total_events} />
  <StatCard title={t('activity.eventsToday')} value={stats.events_today} />
  <StatCard title={t('activity.eventsThisWeek')} value={stats.events_this_week} />
  <StatCard title={t('activity.uniqueUsers')} value={stats.top_users.length} />
</SimpleGrid>
```

**Backend endpoint needed:**
```go
// GET /api/audit/stats
func (h *AuditHandler) GetAuditStats(w http.ResponseWriter, r *http.Request) {
    // Admin only
    // Return aggregated statistics
}
```

---

## Task 5: i18n Keys

**New keys to add:**

```json
{
  "activity": {
    "filterByUser": "Filter by User",
    "allUsers": "All Users",
    "export": "Export",
    "exportCSV": "Export to CSV",
    "stats": "Statistics",
    "totalEvents": "Total Events",
    "eventsToday": "Today",
    "eventsThisWeek": "This Week",
    "uniqueUsers": "Active Users",
    "topActions": "Top Actions",
    "topUsers": "Most Active Users"
  }
}
```

---

## Task 6: Backend API Additions

**Files to modify:**
- `/backend/internal/handlers/audit_handler.go`
- `/backend/cmd/api/main.go` (route registration)

### New Endpoints

```go
// GET /api/audit/export - Export logs as CSV
r.Get("/audit/export", h.ExportAuditLogs)

// GET /api/audit/stats - Get statistics (admin only)
r.Get("/audit/stats", h.GetAuditStats)
```

---

## Implementation Order

1. **Status Doc Update** (~5 min) - Quick fix
2. **Auth Event Logging** (~45 min) - Backend only
3. **Tag/Category Event Logging** (~45 min) - Backend only
4. **Backend API Additions** (~1 hour) - Export + Stats endpoints
5. **Admin UI Enhancements** (~2 hours) - User filter, export, stats
6. **i18n Keys** (~15 min) - EN + RU translations
7. **Testing** (~30 min) - Verify all events logged, UI works

---

## Critical Files

### Backend
- `/backend/internal/handlers/auth.go` - Auth event logging
- `/backend/internal/handlers/tag_handler.go` - Tag event logging
- `/backend/internal/handlers/category_handler.go` - Category event logging
- `/backend/internal/handlers/audit_handler.go` - New endpoints
- `/backend/internal/handlers/audit_helpers.go` - Reference for `createAuditLog()`
- `/backend/cmd/api/main.go` - Route registration

### Frontend
- `/frontend/src/routes/AuditLogPage.tsx` - UI enhancements
- `/frontend/src/services/auditService.ts` - New API methods
- `/frontend/src/i18n/locales/en.json` - English translations
- `/frontend/src/i18n/locales/ru.json` - Russian translations

### Documentation
- `/docs/product-specs/IMPLEMENTATION_STATUS.md` - Status updates
- `/docs/product-specs/audit-logging-spec.md` - Spec reference

---

## Success Criteria

- [ ] IMPLEMENTATION_STATUS.md accurately reflects current state
- [ ] Auth events logged: register, login, login_failed, logout, token_refresh
- [ ] Tag events logged: created, updated, deleted, media associations
- [ ] Category events logged: created, updated, deleted, media associations
- [ ] Admin UI shows user filter dropdown
- [ ] Export button downloads CSV
- [ ] Stats dashboard shows event counts
- [ ] All i18n keys defined for EN and RU
- [ ] Existing tests pass
