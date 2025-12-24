# Feature: Add Folder View to Group Media

## Problem
The folder view was implemented for personal media (`MediaCatalog.tsx`), but groups don't have a media browsing interface. The group's "Categories" tab only shows category management (create/edit/delete), not media organized in folders.

**User expectation:** When viewing a group, see media organized in category folders like the personal MediaCatalog.

## Solution
Add a **Media tab** to `GroupDetailPage` that displays group media with folder view using group categories.

---

## Implementation

### 1. Create GroupMediaTab Component
**File:** `frontend/src/components/groups/GroupMediaTab.tsx` (NEW)

Create a new component similar to MediaCatalog but for group media:

```typescript
interface GroupMediaTabProps {
  groupId: number
}
```

**Features to include:**
- Folder view state (viewMode, currentCategoryId, categoryPath, childCategories)
- Load group categories tree using `groupCategoryService.listGroupCategoriesTree(groupId)`
- Load group media using group media API (need to verify API exists)
- `ViewModeToggle` component for folder/grid switching
- `CatalogBreadcrumb` for folder navigation
- `CategoryFolderCard` for displaying folders
- `MediaCard` for displaying group media
- localStorage persistence with key `groupCatalogViewMode`

### 2. Update GroupDetailPage
**File:** `frontend/src/routes/GroupDetailPage.tsx`

Add new "Media" tab:

```tsx
// Add import
import { GroupMediaTab } from '../components/groups/GroupMediaTab'

// Add tab (around line 420)
<Tabs.Tab value="media" leftSection={<IconPhoto size={16} />}>
  {t('groupDetail.mediaTab')}
</Tabs.Tab>

// Add panel (around line 450)
<Tabs.Panel value="media">
  <GroupMediaTab groupId={group.id} />
</Tabs.Panel>
```

### 3. Add i18n
**File:** `frontend/src/i18n/locales/en.json`

```json
{
  "groupDetail": {
    "mediaTab": "Media"
  }
}
```

---

## Files Summary

| File | Action | Description |
|------|--------|-------------|
| `frontend/src/components/groups/GroupMediaTab.tsx` | CREATE | New group media browser with folder view |
| `frontend/src/routes/GroupDetailPage.tsx` | MODIFY | Add Media tab |
| `frontend/src/i18n/locales/en.json` | MODIFY | Add translation key |

## Existing Components to Reuse
- `CategoryFolderCard` - folder display
- `CatalogBreadcrumb` - breadcrumb navigation
- `ViewModeToggle` - folder/grid switch
- `MediaCard` - media display

## Existing Services to Use
- `groupCategoryService.listGroupCategoriesTree(groupId)`
- `groupCategoryService.getGroupCategoryBreadcrumbs(groupId, categoryId)`
- Group media API (need to verify endpoint)

## Testing
- Open a group with categories and media
- Verify Media tab appears
- Verify folders render in folder view
- Click folder to navigate into it
- Verify breadcrumb works
- Toggle between folder and grid views
