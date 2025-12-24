# Tags & Categories Frontend Implementation Plan

## Overview

Implement full Tags & Categories frontend UI for the demi-upload media catalog. Backend is complete (16 API endpoints). Several frontend components already exist and need to be wired up properly.

**Scope**: Full feature with MediaCatalog (bulk ops + filters) + MediaDetailPage (individual management)

---

## Current State

### Already Implemented
| Component | Location | Status |
|-----------|----------|--------|
| `TagInput` | `components/TagInput.tsx` | Working autocomplete |
| `TagBadges` | `components/TagInput.tsx` (export) | Working display |
| `CategoryTree` | `components/CategoryTree.tsx` | Working tree view |
| `CategorySelector` | `components/CategoryTree.tsx` (export) | Working selector |
| `CategoryBreadcrumbs` | `components/CategoryTree.tsx` (export) | Working breadcrumbs |
| `TagsManager` | `routes/TagsManager.tsx` | Admin CRUD page |
| `CategoriesManager` | `routes/CategoriesManager.tsx` | Admin CRUD page |
| `tagService` | `services/tagService.ts` | All API methods |
| `categoryService` | `services/categoryService.ts` | All API methods |
| Tag/Category types | `types/tags.ts`, `types/categories.ts` | Complete |

### What Needs Implementation
1. **MediaDetailPage** - Wire up tag/category display and editing
2. **MediaCatalog** - Add tag/category filters
3. **MediaCatalog** - Add selection mode for bulk operations
4. **BulkTagModal** - New modal for bulk tagging
5. **BulkCategoryModal** - New modal for bulk categorization
6. **MediaBulkActions** - Floating action bar for bulk ops

---

## Implementation Plan

### Phase 1: MediaDetailPage Integration

**Goal**: Complete tag/category management on individual media items

**File**: `frontend/src/routes/MediaDetailPage.tsx`

**Changes**:
1. Add state for `mediaTags` and `mediaCategories`
2. Load tags/categories on mount using `tagService.getMediaTags()` and `categoryService.getMediaCategories()`
3. Display `TagBadges` in read mode (not just edit mode)
4. Display `CategoryBreadcrumbs` for assigned categories in read mode
5. Wire `TagInput` to save on tag add/remove
6. Wire `CategorySelector` to save on selection change

**Pattern**:
```typescript
const [mediaTags, setMediaTags] = useState<Tag[]>([])
const [mediaCategories, setMediaCategories] = useState<Category[]>([])

const loadMediaTags = useCallback(async () => {
  const response = await tagService.getMediaTags(Number(mediaId))
  setMediaTags(response.tags)
}, [mediaId])
```

---

### Phase 2: MediaCatalog Filtering

**Goal**: Filter media by tags and categories

**Files to Modify**:

1. **`frontend/src/types/media.ts`**
   - Add `tag_ids?: number[]` to `MediaFilters`
   - Add `category_ids?: number[]` to `MediaFilters`

2. **`frontend/src/services/media.ts`**
   - Update `listMedia()` to pass `tag_ids` and `category_ids` as query params

3. **`frontend/src/routes/MediaCatalog.tsx`**
   - Add state for tag/category filters
   - Add MultiSelect for tags filter (using existing tags from API)
   - Add CategorySelector for category filter
   - Update filter application to include tag_ids/category_ids
   - Add URL state sync for filters (`?tags=1,2&category=5`)

---

### Phase 3: Selection Mode & Bulk Actions

**Goal**: Enable selecting multiple media for bulk operations

**Files**:

1. **`frontend/src/routes/MediaCatalog.tsx`**
   - Add `selectedIds: Set<number>` state
   - Add selection mode toggle
   - Pass `selectable` prop to MediaCard when in selection mode
   - Show bulk action bar when items selected

2. **`frontend/src/components/MediaCard.tsx`**
   - Display 2-3 tag badges on card (truncate with "+N more")
   - Verify checkbox selection works with `selectable` prop
   - Add visual indicator for selected state

3. **NEW: `frontend/src/components/MediaBulkActions.tsx`**
   - Floating action bar using Mantine `Affix` + `Paper`
   - Shows: "N items selected | [Add Tags] [Set Categories] [Clear]"
   - Triggers bulk modals

---

### Phase 4: Bulk Operation Modals

**Goal**: Modals for applying tags/categories to multiple media

**NEW: `frontend/src/components/BulkTagModal.tsx`**
```typescript
interface BulkTagModalProps {
  opened: boolean
  onClose: () => void
  mediaIds: number[]
  onSuccess: () => void
}
```
- Reuse `TagInput` component
- Call `tagService.bulkAddTags()` on submit
- Show progress/success notification

**NEW: `frontend/src/components/BulkCategoryModal.tsx`**
```typescript
interface BulkCategoryModalProps {
  opened: boolean
  onClose: () => void
  mediaIds: number[]
  onSuccess: () => void
}
```
- Reuse `CategorySelector` component
- Call `categoryService.addCategoriesToMedia()` for each media (or implement bulk endpoint)
- Show progress/success notification

---

## File Summary

### New Files (3)
| File | Purpose | Est. Lines |
|------|---------|------------|
| `components/BulkTagModal.tsx` | Bulk tag application modal | 80-100 |
| `components/BulkCategoryModal.tsx` | Bulk category application modal | 80-100 |
| `components/MediaBulkActions.tsx` | Floating action bar | 60-80 |

### Files to Modify (5)
| File | Changes |
|------|---------|
| `routes/MediaDetailPage.tsx` | Wire up tags/categories display and editing |
| `routes/MediaCatalog.tsx` | Add filters, selection mode, bulk actions |
| `types/media.ts` | Add tag_ids, category_ids to MediaFilters |
| `services/media.ts` | Update listMedia for tag/category filtering |
| `components/MediaCard.tsx` | Verify/enhance selection support |

---

## Critical Files to Read

Before implementation, read these files to understand existing patterns:

1. `/frontend/src/components/TagInput.tsx` - Existing tag input pattern
2. `/frontend/src/components/CategoryTree.tsx` - Existing category components
3. `/frontend/src/routes/MediaDetailPage.tsx` - Current page structure
4. `/frontend/src/routes/MediaCatalog.tsx` - Current filter/grid pattern
5. `/frontend/src/services/tagService.ts` - Available API methods

---

## Implementation Order

1. **Phase 1**: MediaDetailPage integration (~2 hours)
2. **Phase 2**: MediaCatalog filters (~2 hours)
3. **Phase 3**: Selection mode + bulk action bar (~2 hours)
4. **Phase 4**: Bulk modals (~2 hours)

**Total Estimate**: ~8 hours

---

## Patterns to Follow

### State Management
- Use local `useState` + `useCallback` (no global state)
- Follow existing loading/error/empty pattern

### Modal Pattern
```typescript
const [opened, { open, close }] = useDisclosure(false)
```

### Error Handling
```typescript
try {
  await service.action(data)
  notifications.show({ title: 'Success', message: '...', color: 'green' })
} catch (err) {
  notifications.show({ title: 'Error', message: '...', color: 'red' })
}
```

### Mantine Components
- `TagsInput` for tag autocomplete
- `MultiSelect` for tag filter
- `Tree` + `useTree` for categories
- `Affix` + `Paper` for floating action bar
- `Modal` for bulk operations
- `Checkbox` for selection
