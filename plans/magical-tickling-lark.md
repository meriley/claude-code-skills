# E2E Test Suite Expansion Plan

## Goal
Add Playwright E2E tests for recently implemented catalog features: context menus, keyboard navigation, and drag-drop.

## CRITICAL: No Mocking Policy
**All test data MUST be real data created through actual API calls. NO mocking, fixtures, or fake data.**

## Existing Patterns (from `frontend/e2e/`)
- Tests use `data-testid` attributes for element selection
- Login via `beforeEach` with hard-coded credentials (`test@example.com` / `Test1234`)
- Organized by `test.describe()` blocks per feature area
- Uses Chromium only, baseURL `http://localhost:5174`
- **Current tests do NOT use API data creation** - this will be new pattern

## New Test File
**Path:** `frontend/e2e/catalog-interactions.spec.ts`

---

## Real Test Data Creation Strategy

### Authentication for API Calls
After UI login, Playwright's `page.request` automatically includes cookies set by the browser.
This allows authenticated API calls without manual token handling.

### Categories API
- **Endpoint:** `POST /api/categories`
- **Body:** `{ "name": "Test Category", "parent_id": null, "description": "..." }`
- **Auth:** Cookies from login (auto-included by `page.request`)

```typescript
// Example: Create category via real API call
const response = await page.request.post('/api/categories', {
  data: { name: `Test-${Date.now()}`, parent_id: null }
})
const category = await response.json()
```

### Media Creation
Media requires real file upload through the UI (complex multi-step process):
1. Click upload button
2. Select file via file chooser
3. Complete upload flow

**For tests needing media:** Use UI upload flow in beforeAll hook, OR scope tests to only require categories.

### Cleanup Strategy
- Use unique names with `Date.now()` for test isolation
- Tests should clean up via `DELETE /api/categories/{id}` in afterEach
- Media cleanup is optional (test user has quota)

---

## Test Suites

### 1. Context Menu - Folders (6 tests)
```
- should show context menu on right-click folder
- should rename folder via context menu
- should create subfolder via context menu
- should delete folder via context menu (with confirmation)
- should move folder to parent via context menu (when nested)
- should hide "move to parent" for root folders
```

**Data Setup:**
- Create 2 categories via API: root folder + child folder (for nested tests)

**Requires:**
- `data-testid="category-folder-{id}"` (already exists)
- Context menu items need testids (add `data-testid` to menu items)

### 2. Context Menu - Media Cards (6 tests)
```
- should show context menu on right-click media card
- should navigate to detail via "View" menu item
- should trigger download via "Download" menu item
- should show share option for approved media only
- should show approve option for pending media only
- should show delete confirmation on delete
```

**Data Setup:**
- Upload real media file via UI in beforeAll hook
- Or: Create test that uploads first, then tests context menu

**Requires:**
- Media card needs `data-testid="media-card-{id}"`
- Context menu items need testids

### 3. Keyboard Navigation (6 tests)
```
- should focus first item when pressing arrow key in grid
- should navigate with arrow keys (left/right/up/down)
- should open folder on Enter
- should open media detail on Enter
- should navigate to parent on Backspace
- should show focus indicator on focused item
```

**Data Setup:**
- Create 2+ categories via API
- Uses categories as navigation targets

**Requires:**
- Grid container with `tabIndex={0}` (already exists)
- Focus indicator styles (already implemented)

### 4. Drag and Drop - Media to Folders (4 tests)
```
- should show drop indicator when dragging over folder
- should assign category when dropping media on folder
- should show success notification after drop
- should update folder media count after drop
```

**Data Setup:**
- Create category via API
- Upload media via UI

**Requires:**
- Playwright `dragAndDrop()` API
- Existing DnD implementation

---

## Implementation Steps

### Step 1: Context Menu Selection Strategy

**mantine-contextmenu does NOT support custom `data-testid` on menu items** (verified via type definitions).

**Solution:** Use Playwright text/role selectors for menu items:
```typescript
// Select menu item by text
await page.getByText('Rename').click()

// Or by role
await page.getByRole('menuitem', { name: 'Rename' }).click()
```

This is actually the recommended Playwright pattern - test from user perspective.

### Step 2: Add testid to MediaCard

**File:** `frontend/src/components/MediaCard.tsx`
Add `data-testid={`media-card-${media.id}`}` to card wrapper.

### Step 3: Create test file

**File:** `frontend/e2e/catalog-interactions.spec.ts`

```typescript
import { test, expect } from '@playwright/test'

// Helper: Login and get authenticated page
async function loginAsTestUser(page) {
  await page.goto('/login')
  await page.getByTestId('login-email-input').fill('test@example.com')
  await page.getByTestId('login-password-input').fill('Test1234')
  await page.getByTestId('login-submit-button').click()
  await page.waitForURL('/dashboard')
}

// Helper: Create category via real API
async function createCategory(page, name: string, parentId?: number) {
  const response = await page.request.post('/api/categories', {
    data: { name, parent_id: parentId ?? null }
  })
  expect(response.ok()).toBeTruthy()
  return response.json()
}

// Helper: Delete category via real API
async function deleteCategory(page, id: number) {
  await page.request.delete(`/api/categories/${id}`)
}

test.describe('Folder Context Menu', () => {
  let categoryId: number

  test.beforeEach(async ({ page }) => {
    await loginAsTestUser(page)
    // Create real category via API
    const category = await createCategory(page, `Test-${Date.now()}`)
    categoryId = category.id
    await page.goto('/catalog')
  })

  test.afterEach(async ({ page }) => {
    // Cleanup
    await deleteCategory(page, categoryId)
  })

  test('should show context menu on right-click folder', async ({ page }) => {
    await page.getByTestId(`category-folder-${categoryId}`).click({ button: 'right' })
    await expect(page.getByText('Rename')).toBeVisible()
  })

  // ... more tests
})
```

---

## Files to Modify

1. **`frontend/src/components/MediaCard.tsx`**
   - Add `data-testid="media-card-{id}"` to card wrapper

2. **`frontend/e2e/catalog-interactions.spec.ts`** (NEW)
   - All test suites with real API data creation
   - Helper functions for API-based test data creation
   - Cleanup logic in afterEach hooks

**No changes needed to context menu components** - mantine-contextmenu doesn't support custom testids, but we can use text selectors which is actually the preferred Playwright pattern.

---

## Estimated Tests: ~22 test cases

| Suite | Tests | Data Needed |
|-------|-------|-------------|
| Folder Context Menu | 6 | Categories via API |
| Media Context Menu | 6 | Media via UI upload |
| Keyboard Navigation | 6 | Categories via API |
| Drag and Drop | 4 | Categories + Media |
