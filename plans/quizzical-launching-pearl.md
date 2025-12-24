# Plan: Tags/Categories Ownership Model Implementation

## Summary

Migrate the existing tags/categories system from a single user-owned context to a dual-context system supporting both **personal** (user-owned) and **group** contexts. This involves renaming existing tables, creating new group tables, and updating all backend/frontend code.

## Current State

**Existing Tables:**
- `tags` → will become `user_tags`
- `categories` → will become `user_categories`
- `media_tags` → will become `user_media_tags`
- `media_categories` → will become `user_media_categories`

**Existing Code:**
- Backend: `tag.go`, `category.go` models; `tag_repository.go`, `category_repository.go`; `tag_handler.go`, `category_handler.go`
- Frontend: `TagsManager.tsx`, `CategoriesManager.tsx`, `TagInput.tsx`, `CategoryTree.tsx`, `BulkTagModal.tsx`, `BulkCategoryModal.tsx`

## Implementation Phases

### Phase 1: Database Migration

**File:** `backend/internal/database/migrations/XXX_separate_user_group_tags_categories.sql`

```sql
-- 1. Rename existing user tables
ALTER TABLE tags RENAME TO user_tags;
ALTER TABLE categories RENAME TO user_categories;
ALTER TABLE media_tags RENAME TO user_media_tags;
ALTER TABLE media_categories RENAME TO user_media_categories;

-- 2. Update foreign key constraints and indexes (rename to match new table names)
-- Update trigger functions for user_categories materialized path

-- 3. Create group tables
CREATE TABLE group_tags (
    id SERIAL PRIMARY KEY,
    group_id INTEGER NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    color VARCHAR(7) DEFAULT '#3B82F6',
    description TEXT,
    created_by INTEGER NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    UNIQUE(group_id, name),
    UNIQUE(group_id, slug)
);

CREATE TABLE group_categories (
    id SERIAL PRIMARY KEY,
    group_id INTEGER NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    parent_id INTEGER REFERENCES group_categories(id) ON DELETE CASCADE,
    path VARCHAR(1000),
    level INTEGER DEFAULT 0 NOT NULL,
    description TEXT,
    created_by INTEGER NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    UNIQUE(group_id, slug, parent_id)
);

CREATE TABLE group_media_tags (
    media_id INTEGER REFERENCES media(id) ON DELETE CASCADE,
    tag_id INTEGER REFERENCES group_tags(id) ON DELETE CASCADE,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (media_id, tag_id)
);

CREATE TABLE group_media_categories (
    media_id INTEGER REFERENCES media(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES group_categories(id) ON DELETE CASCADE,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (media_id, category_id)
);

-- 4. Create indexes for group tables
CREATE INDEX idx_group_tags_group_id ON group_tags(group_id);
CREATE INDEX idx_group_categories_group_id ON group_categories(group_id);
CREATE INDEX idx_group_categories_path ON group_categories(path);
CREATE INDEX idx_group_media_tags_media_id ON group_media_tags(media_id);
CREATE INDEX idx_group_media_categories_media_id ON group_media_categories(media_id);

-- 5. Create trigger for group_categories materialized path (similar to user_categories)
```

**Rollback file:** `rollback_XXX_separate_user_group_tags_categories.sql`

---

### Phase 2: Backend Models

**Files to modify:**
- `backend/internal/models/tag.go` → Split into `user_tag.go` and `group_tag.go`
- `backend/internal/models/category.go` → Split into `user_category.go` and `group_category.go`

#### 2.1 User Tag Model (`user_tag.go`)

```go
type UserTag struct {
    ID          uint           `gorm:"primaryKey"`
    UserID      uint           `gorm:"not null;index"`
    User        *User          `gorm:"foreignKey:UserID"`
    Name        string         `gorm:"size:100;not null"`
    Slug        string         `gorm:"size:100;not null"`
    Color       string         `gorm:"size:7;default:'#3B82F6'"`
    Description string
    IsSystem    bool           `gorm:"default:false"`
    CreatedAt   time.Time
    UpdatedAt   time.Time
    DeletedAt   gorm.DeletedAt `gorm:"index"`
}

func (UserTag) TableName() string { return "user_tags" }
```

#### 2.2 Group Tag Model (`group_tag.go`)

```go
type GroupTag struct {
    ID          uint           `gorm:"primaryKey"`
    GroupID     uint           `gorm:"not null;index"`
    Group       *Group         `gorm:"foreignKey:GroupID"`
    Name        string         `gorm:"size:100;not null"`
    Slug        string         `gorm:"size:100;not null"`
    Color       string         `gorm:"size:7;default:'#3B82F6'"`
    Description string
    CreatedBy   uint           `gorm:"not null"`
    Creator     *User          `gorm:"foreignKey:CreatedBy"`
    CreatedAt   time.Time
    UpdatedAt   time.Time
    DeletedAt   gorm.DeletedAt `gorm:"index"`
}

func (GroupTag) TableName() string { return "group_tags" }
```

#### 2.3 Similar pattern for UserCategory and GroupCategory

---

### Phase 3: Backend Repositories

**Files:**
- Rename/modify `tag_repository.go` → `user_tag_repository.go`
- Create new `group_tag_repository.go`
- Rename/modify `category_repository.go` → `user_category_repository.go`
- Create new `group_category_repository.go`

#### 3.1 User Tag Repository Interface

```go
type UserTagRepository interface {
    Create(ctx rms.Ctx, tag *models.UserTag) error
    FindByID(ctx rms.Ctx, tagID, userID uint) (*models.UserTag, error)
    List(ctx rms.Ctx, userID uint, pagination utils.PaginationParams) ([]models.UserTag, int64, error)
    Update(ctx rms.Ctx, tag *models.UserTag) error
    Delete(ctx rms.Ctx, tagID, userID uint) error
    AddTagsToMedia(ctx rms.Ctx, mediaID uint, tagIDs []uint, userID uint) error
    RemoveTagFromMedia(ctx rms.Ctx, mediaID, tagID uint) error
    GetMediaTags(ctx rms.Ctx, mediaID, userID uint) ([]models.UserTag, error)
}
```

#### 3.2 Group Tag Repository Interface

```go
type GroupTagRepository interface {
    Create(ctx rms.Ctx, tag *models.GroupTag) error
    FindByID(ctx rms.Ctx, tagID, groupID uint) (*models.GroupTag, error)
    List(ctx rms.Ctx, groupID uint, pagination utils.PaginationParams) ([]models.GroupTag, int64, error)
    Update(ctx rms.Ctx, tag *models.GroupTag, userID uint) error  // Check permissions
    Delete(ctx rms.Ctx, tagID, groupID, userID uint) error  // Check permissions
    AddTagsToMedia(ctx rms.Ctx, mediaID uint, tagIDs []uint, groupID, userID uint) error
    RemoveTagFromMedia(ctx rms.Ctx, mediaID, tagID, groupID uint) error
    GetMediaTags(ctx rms.Ctx, mediaID, groupID uint) ([]models.GroupTag, error)
}
```

---

### Phase 4: Backend Handlers

**Files:**
- Rename `tag_handler.go` → `user_tag_handler.go`
- Create new `group_tag_handler.go`
- Same for category handlers

#### 4.1 User Tag Handler (personal context)

Routes: `/api/tags/*` (unchanged for personal)

#### 4.2 Group Tag Handler (group context)

Routes: `/api/groups/:groupId/tags/*`

```go
// Group-scoped endpoints
GET    /api/groups/:groupId/tags           // List group tags
POST   /api/groups/:groupId/tags           // Create group tag (owner/moderator only)
PATCH  /api/groups/:groupId/tags/:id       // Update group tag
DELETE /api/groups/:groupId/tags/:id       // Delete group tag

// Media-scoped within group
GET    /api/groups/:groupId/media/:mediaId/tags
POST   /api/groups/:groupId/media/:mediaId/tags
DELETE /api/groups/:groupId/media/:mediaId/tags/:tagId
```

**Authorization:**
- Check user is member of group
- Create/Update/Delete: Check user is owner or moderator

---

### Phase 5: Route Updates

**File:** `backend/cmd/api/main.go`

```go
// Personal tag routes (existing, renamed)
r.Route("/tags", func(r chi.Router) {
    r.Use(authMw.RequireAuth, csrfMw.Protect)
    r.Get("/", userTagHandler.List)
    r.Post("/", userTagHandler.Create)
    r.Patch("/{id}", userTagHandler.Update)
    r.Delete("/{id}", userTagHandler.Delete)
})

// Group tag routes (new)
r.Route("/groups/{groupId}/tags", func(r chi.Router) {
    r.Use(authMw.RequireAuth, csrfMw.Protect, groupMemberMw)
    r.Get("/", groupTagHandler.List)
    r.Post("/", groupTagHandler.Create)  // owner/mod check inside
    r.Patch("/{id}", groupTagHandler.Update)
    r.Delete("/{id}", groupTagHandler.Delete)
})

// Same pattern for categories
```

---

### Phase 6: Frontend Types

**Files:**
- `frontend/src/types/tags.ts` → Update for dual context
- `frontend/src/types/categories.ts` → Update for dual context

```typescript
// User (personal) tags
export interface UserTag {
  id: number;
  name: string;
  slug: string;
  color: string;
  description: string;
  is_system: boolean;
  usage_count: number;
  created_at: string;
}

// Group tags
export interface GroupTag {
  id: number;
  group_id: number;
  name: string;
  slug: string;
  color: string;
  description: string;
  created_by: number;
  usage_count: number;
  created_at: string;
}

// Union type for components that handle both
export type Tag = UserTag | GroupTag;
export function isGroupTag(tag: Tag): tag is GroupTag {
  return 'group_id' in tag;
}
```

---

### Phase 7: Frontend Services

**Files:**
- `frontend/src/services/tagService.ts` → Rename to `userTagService.ts`
- Create `frontend/src/services/groupTagService.ts`

```typescript
// userTagService.ts
export const userTagService = {
  listTags: () => api.get<UserTagListResponse>('/tags'),
  createTag: (data: TagCreateRequest) => api.post('/tags', data),
  // ...
}

// groupTagService.ts
export const groupTagService = {
  listTags: (groupId: number) => api.get<GroupTagListResponse>(`/groups/${groupId}/tags`),
  createTag: (groupId: number, data: TagCreateRequest) =>
    api.post(`/groups/${groupId}/tags`, data),
  // ...
}
```

---

### Phase 8: Frontend Components

**Key Updates:**

#### 8.1 TagInput Component

Add `context` prop to determine which tags to show:

```typescript
interface TagInputProps {
  context: 'personal' | { type: 'group'; groupId: number };
  selectedTagIds: number[];
  onChange: (tagIds: number[]) => void;
}
```

#### 8.2 CategoryTree Component

Add `context` prop similar to TagInput.

#### 8.3 BulkTagModal / BulkCategoryModal

Add context awareness to fetch appropriate tags/categories.

#### 8.4 TagsManager / CategoriesManager

These manage personal tags. Add new:
- `GroupTagsManager` - Accessed from group settings page
- `GroupCategoriesManager` - Accessed from group settings page

---

### Phase 9: Context Indicator in UI

When viewing media:
- In personal catalog → Show personal tags/categories
- In group view → Show group tags/categories

UI indicator:
```
┌──────────────────────────────────────┐
│ 🏷️ Tags (Personal)  or  🏷️ Tags (Marketing Team) │
└──────────────────────────────────────┘
```

---

## Implementation Order

1. **Database migration** (can deploy independently)
2. **Backend models** (UserTag, GroupTag, UserCategory, GroupCategory)
3. **Backend repositories** (user and group variants)
4. **Backend handlers** (user and group variants)
5. **Routes** (add group-scoped routes)
6. **Frontend types** (UserTag, GroupTag, etc.)
7. **Frontend services** (userTagService, groupTagService)
8. **Frontend components** (add context prop to existing)
9. **Group management UI** (GroupTagsManager, GroupCategoriesManager)
10. **Testing** (unit + integration + e2e)

## Critical Files

### Backend
- `backend/internal/database/migrations/` - New migration file
- `backend/internal/models/tag.go` → split to `user_tag.go`, `group_tag.go`
- `backend/internal/models/category.go` → split to `user_category.go`, `group_category.go`
- `backend/internal/repositories/tag_repository.go` → split
- `backend/internal/repositories/category_repository.go` → split
- `backend/internal/handlers/tag_handler.go` → split
- `backend/internal/handlers/category_handler.go` → split
- `backend/cmd/api/main.go` - Route updates

### Frontend
- `frontend/src/types/tags.ts`
- `frontend/src/types/categories.ts`
- `frontend/src/services/tagService.ts` → rename/split
- `frontend/src/services/categoryService.ts` → rename/split
- `frontend/src/components/TagInput.tsx`
- `frontend/src/components/CategoryTree.tsx`
- `frontend/src/components/BulkTagModal.tsx`
- `frontend/src/components/BulkCategoryModal.tsx`
- `frontend/src/routes/TagsManager.tsx`
- `frontend/src/routes/CategoriesManager.tsx`

## Estimated Effort

| Phase | Effort |
|-------|--------|
| Database migration | Small |
| Backend models | Small |
| Backend repositories | Medium |
| Backend handlers | Medium |
| Routes | Small |
| Frontend types/services | Small |
| Frontend components | Medium |
| Group management UI | Medium |
| Testing | Medium |

**Total: ~2-3 days of focused work**

## Risks & Mitigations

1. **Data integrity during migration**
   - Mitigation: Rename approach preserves all data
   - Test migration on staging first

2. **Breaking existing API consumers**
   - Mitigation: Personal tag routes unchanged (`/api/tags/*`)
   - Group routes are additive (`/api/groups/:id/tags/*`)

3. **Frontend regression**
   - Mitigation: Add context prop with default='personal' for backward compatibility
