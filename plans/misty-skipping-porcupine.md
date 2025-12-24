# Tags & Categories Implementation Plan

## Overview

Implement a media organization system with user-created tags and hierarchical categories.

**Spec**: `docs/product-specs/tags-categories-spec.md`
**Priority**: P1
**Effort**: 1-2 weeks
**Scope**: Full Feature (13 endpoints, full frontend UI, hierarchical categories)

---

## Phase 1: Database & Models

### Migration: `005_add_tags_and_categories.sql`

**Tags Table:**
```sql
CREATE TABLE tags (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  color VARCHAR(7) DEFAULT '#3B82F6',
  description TEXT,
  created_by INTEGER REFERENCES users(id),
  is_system BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_tags_name ON tags(name);
CREATE INDEX idx_tags_created_by ON tags(created_by);
```

**Categories Table:**
```sql
CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  parent_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
  path VARCHAR(1000),  -- Materialized path: /family/vacation/2024
  level INTEGER DEFAULT 0 CHECK (level >= 0 AND level < 10),
  description TEXT,
  created_by INTEGER REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(slug, parent_id)
);
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_path ON categories(path);
```

**Junction Tables:**
```sql
CREATE TABLE media_tags (
  media_id INTEGER REFERENCES media(id) ON DELETE CASCADE,
  tag_id INTEGER REFERENCES tags(id) ON DELETE CASCADE,
  created_by INTEGER REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (media_id, tag_id)
);

CREATE TABLE media_categories (
  media_id INTEGER REFERENCES media(id) ON DELETE CASCADE,
  category_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
  created_by INTEGER REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (media_id, category_id)
);
```

### Backend Models

**Files to create:**
- `backend/internal/models/tag.go`
- `backend/internal/models/category.go`

---

## Phase 2: Backend API

### Tag Endpoints (7 endpoints)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/tags` | ListTags | List all user tags with usage count |
| POST | `/api/tags` | CreateTag | Create new tag |
| PATCH | `/api/tags/:id` | UpdateTag | Update tag name/color |
| DELETE | `/api/tags/:id` | DeleteTag | Delete tag |
| POST | `/api/media/:id/tags` | AddTagsToMedia | Add tags to media |
| DELETE | `/api/media/:id/tags/:tagId` | RemoveTagFromMedia | Remove tag |
| POST | `/api/media/bulk/tags` | BulkAddTags | Bulk tag multiple media |

### Category Endpoints (6 endpoints)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/categories` | ListCategories | List as tree structure |
| POST | `/api/categories` | CreateCategory | Create category |
| PATCH | `/api/categories/:id` | UpdateCategory | Update category |
| DELETE | `/api/categories/:id` | DeleteCategory | Delete (cascade children) |
| POST | `/api/media/:id/categories` | AddCategoriesToMedia | Add categories |
| DELETE | `/api/media/:id/categories/:catId` | RemoveCategoryFromMedia | Remove |

**Files to create:**
- `backend/internal/repositories/tag_repository.go`
- `backend/internal/repositories/category_repository.go`
- `backend/internal/handlers/tag_handler.go`
- `backend/internal/handlers/category_handler.go`

**File to modify:**
- `backend/cmd/api/main.go` - Add route setup functions

---

## Phase 3: Frontend (Mantine 7.x Patterns)

### Types & Services

**Files to create:**
- `frontend/src/types/tags.ts` - Tag, TagCreateRequest interfaces
- `frontend/src/types/categories.ts` - Category, TreeNodeData interfaces
- `frontend/src/services/tagService.ts` - Tag API calls
- `frontend/src/services/categoryService.ts` - Category API calls

### Components (Mantine Patterns)

**TagInput.tsx** - Using `TagsInput` component:
```tsx
import { TagsInput } from '@mantine/core';

// Controlled TagsInput with autocomplete from existing tags
<TagsInput
  label="Tags"
  data={existingTags.map(t => t.name)}  // Autocomplete suggestions
  value={selectedTags}
  onChange={setSelectedTags}
  acceptValueOnBlur={false}  // Require Enter to submit
  clearable
  clearButtonProps={{ 'aria-label': 'Clear tags' }}
/>
```

**CategoryTree.tsx** - Using `Tree` + `useTree` hook:
```tsx
import { Tree, useTree, TreeNodeData } from '@mantine/core';

const tree = useTree({
  initialExpandedState: getTreeExpandedState(data, '*'),
  multiple: false,  // Single category selection
});

<Tree
  data={categoryData}  // TreeNodeData[] with unique values
  tree={tree}
  selectOnClick
  clearSelectionOnOutsideClick
  renderNode={(payload) => <CategoryNode {...payload} />}
/>
```

**Files to create:**
- `frontend/src/components/TagInput.tsx` - TagsInput wrapper with API integration
- `frontend/src/components/TagBadges.tsx` - Badge display for assigned tags
- `frontend/src/components/CategoryTree.tsx` - Tree + useTree for hierarchy
- `frontend/src/components/CategoryBreadcrumb.tsx` - Breadcrumbs from path

### Pages

**TagsManager.tsx** - Tag CRUD with useForm:
```tsx
import { useForm } from '@mantine/form';
import { TextInput, ColorInput, Button } from '@mantine/core';

const form = useForm({
  initialValues: { name: '', color: '#3B82F6' },
  validate: {
    name: (v) => v.length < 1 ? 'Required' : null,
  },
});
```

**CategoriesManager.tsx** - Category CRUD with Tree:
- Tree view for category hierarchy
- Modal for create/edit with parent selector
- Drag-drop reordering (future enhancement)

**Files to create:**
- `frontend/src/routes/TagsManager.tsx` - Tag CRUD page
- `frontend/src/routes/CategoriesManager.tsx` - Category CRUD page

**Files to modify:**
- `frontend/src/routes/MediaDetailPage.tsx` - Add TagInput + CategoryTree
- `frontend/src/routes/MediaCatalog.tsx` - Add tag/category filter chips
- `frontend/src/App.tsx` - Add routes
- `frontend/src/config/navigation.ts` - Add nav items

---

## Critical Files Summary

### Backend (Create)
1. `backend/internal/database/migrations/005_add_tags_and_categories.sql`
2. `backend/internal/models/tag.go`
3. `backend/internal/models/category.go`
4. `backend/internal/repositories/tag_repository.go`
5. `backend/internal/repositories/category_repository.go`
6. `backend/internal/handlers/tag_handler.go`
7. `backend/internal/handlers/category_handler.go`

### Backend (Modify)
1. `backend/cmd/api/main.go` - Add routes

### Frontend (Create)
1. `frontend/src/types/tags.ts`
2. `frontend/src/types/categories.ts`
3. `frontend/src/services/tagService.ts`
4. `frontend/src/services/categoryService.ts`
5. `frontend/src/components/TagInput.tsx` - TagsInput wrapper
6. `frontend/src/components/TagBadges.tsx` - Badge display
7. `frontend/src/components/CategoryTree.tsx` - Tree + useTree
8. `frontend/src/components/CategoryBreadcrumb.tsx` - Path breadcrumbs
9. `frontend/src/routes/TagsManager.tsx` - Tag CRUD page
10. `frontend/src/routes/CategoriesManager.tsx` - Category CRUD page

### Frontend (Modify)
1. `frontend/src/routes/MediaDetailPage.tsx` - Add TagInput + CategoryTree
2. `frontend/src/routes/MediaCatalog.tsx` - Add filter chips
3. `frontend/src/App.tsx` - Add routes
4. `frontend/src/config/navigation.ts` - Add nav items for Tags/Categories

---

## Testing Requirements

- Unit tests: 90%+ coverage on repositories and handlers
- Integration tests: Tag/category CRUD workflows
- E2E tests: Create tag → assign to media → filter by tag
