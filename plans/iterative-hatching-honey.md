# Tags & Categories - Full Polish Plan

## Overview
Complete the Tags & Categories feature from 85% to 100% by fixing i18n, implementing media filtering, and adding backend tests.

**Estimated Total Effort**: 13-15 hours
**Current Status**: 85% complete (handlers, components, services all exist)

---

## Phase 1: i18n Fixes (1 hour)

### 1.1 Component Internationalization
Fix hardcoded English strings in 3 components:

**BulkTagModal.tsx**
- Add `useTranslation()` hook
- Replace hardcoded strings: "Add Tags", "Tags Applied", "Select tags to add", etc.

**BulkCategoryModal.tsx**
- Add `useTranslation()` hook
- Replace hardcoded strings: "Set Categories", "Categories Applied", etc.

**TagInput.tsx**
- Add `useTranslation()` hook
- Replace hardcoded strings: "Tags", "Add tags...", "No matching tags"

### 1.2 Translation Keys
Update locale files with new keys:

**en.json** - Add under `tags` and `categories` namespaces:
- `bulkTag.title`, `bulkTag.selectTags`, `bulkTag.applied`
- `bulkCategory.title`, `bulkCategory.selectCategories`, `bulkCategory.applied`
- `tagInput.placeholder`, `tagInput.noMatches`

**ru.json** - Add Russian translations for all new keys

---

## Phase 2: Media Filtering (6-8 hours)

### 2.1 Frontend Changes

**MediaFilters.tsx** - Add filter dropdowns
```typescript
// Add tag multi-select with search
<MultiSelect
  label={t('media.filterByTags')}
  data={tags.map(t => ({ value: t.id, label: t.name }))}
  value={selectedTags}
  onChange={setSelectedTags}
  searchable
/>

// Add category tree selector
<Select
  label={t('media.filterByCategory')}
  data={flattenCategoryTree(categories)}
  value={selectedCategory}
  onChange={setSelectedCategory}
/>
```

**MediaCatalog.tsx** - Pass filters to API
- Add state for `selectedTags: string[]` and `selectedCategory: string`
- Pass to `mediaService.list()` call
- Reset pagination when filters change

**media.ts service** - Update list method
```typescript
list(params: {
  page?: number
  limit?: number
  contentType?: string
  status?: string
  tagIds?: string[]      // NEW
  categoryId?: string    // NEW
})
```

### 2.2 Backend Changes

**media_handler.go** - Parse filter params
```go
func (h *MediaHandler) ListMedia(c echo.Context) error {
    // Existing: page, limit, content_type, status
    // Add:
    tagIDs := c.QueryParams()["tag_ids[]"]
    categoryID := c.QueryParam("category_id")

    // Pass to repository
}
```

**media_repository.go** - SQL filtering with JOINs
```go
func (r *MediaRepository) List(ctx context.Context, opts ListMediaOptions) ([]Media, error) {
    query := r.db.Model(&Media{}).Where("user_id = ?", opts.UserID)

    // Tag filtering (ANY match)
    if len(opts.TagIDs) > 0 {
        query = query.Joins("INNER JOIN media_tags mt ON mt.media_id = media.id").
            Where("mt.tag_id IN ?", opts.TagIDs).
            Group("media.id")
    }

    // Category filtering (exact or descendant match)
    if opts.CategoryID != "" {
        query = query.Joins("INNER JOIN media_categories mc ON mc.media_id = media.id").
            Joins("INNER JOIN categories c ON c.id = mc.category_id").
            Where("c.id = ? OR c.path LIKE ?", opts.CategoryID, opts.CategoryID+"/%")
    }
}
```

### 2.3 API Endpoints to Modify
- `GET /api/media` - Add query params: `tag_ids[]`, `category_id`

---

## Phase 3: Backend Tests (4-6 hours)

### 3.1 Tag Handler Tests (`tag_handler_test.go`)
Target: 70%+ coverage

**Test Cases:**
- `TestCreateTag` - valid input, duplicate name, invalid color
- `TestListTags` - pagination, filtering by system flag
- `TestGetTag` - exists, not found
- `TestUpdateTag` - valid, not found, system tag protection
- `TestDeleteTag` - valid, not found, system tag protection
- `TestAddTagToMedia` - valid, already tagged, media not found
- `TestRemoveTagFromMedia` - valid, not tagged, media not found
- `TestBulkAddTags` - valid, limit enforcement (100 media, 50 tags)

### 3.2 Category Handler Tests (`category_handler_test.go`)
Target: 70%+ coverage

**Test Cases:**
- `TestCreateCategory` - valid, duplicate name in same parent, max depth (10)
- `TestListCategories` - flat list, tree structure
- `TestGetCategory` - exists, not found, with breadcrumbs
- `TestUpdateCategory` - valid, circular reference prevention, not found
- `TestDeleteCategory` - valid, with children cascade, not found
- `TestAddCategoryToMedia` - valid, already categorized, max limit (10)
- `TestRemoveCategoryFromMedia` - valid, not categorized

### 3.3 Test Setup Pattern
Follow existing patterns from `media_handler_test.go`:
```go
func setupTagTestServer(t *testing.T) (*echo.Echo, *gorm.DB) {
    // Use testcontainers for PostgreSQL
    // Run migrations
    // Create test user with JWT
    // Return configured Echo server
}
```

---

## Files to Modify

### Frontend (6 files)
| File | Changes |
|------|---------|
| `components/BulkTagModal.tsx` | Add i18n |
| `components/BulkCategoryModal.tsx` | Add i18n |
| `components/TagInput.tsx` | Add i18n |
| `components/MediaFilters.tsx` | Add tag/category dropdowns |
| `routes/MediaCatalog.tsx` | Pass filter state to API |
| `services/media.ts` | Add filter params to list() |
| `i18n/locales/en.json` | Add translation keys |
| `i18n/locales/ru.json` | Add Russian translations |

### Backend (4 files)
| File | Changes |
|------|---------|
| `handlers/media_handler.go` | Parse tag_ids[], category_id params |
| `repositories/media_repository.go` | Add JOIN filtering logic |
| `handlers/tag_handler_test.go` | Create (NEW) |
| `handlers/category_handler_test.go` | Create (NEW) |

---

## Execution Order

1. **Phase 1: i18n** (1 hour)
   - Quick wins, improves Russian UX immediately
   - Run lint + type check after

2. **Phase 2: Media Filtering** (6-8 hours)
   - 2.1 Frontend first (can test with mocked data)
   - 2.2 Backend second (API changes)
   - Integration test manually

3. **Phase 3: Backend Tests** (4-6 hours)
   - tag_handler_test.go first (simpler)
   - category_handler_test.go second (hierarchy logic)
   - Run `go test ./...` for coverage

---

## Success Criteria

- [ ] All 3 components use useTranslation() - no hardcoded English
- [ ] Media catalog can filter by tags (multi-select)
- [ ] Media catalog can filter by category (with descendants)
- [ ] Combined filtering works (tags AND category)
- [ ] Backend tests pass with 70%+ coverage
- [ ] ESLint: 0 warnings, TypeScript: 0 errors
- [ ] `go test ./...` passes

---

## Dependencies
- None - Tags & Categories is independent feature
- Database migration 005 already applied with all tables/indexes
