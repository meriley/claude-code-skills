# Plan: Fix Category Page Navigation Issue

## Problem

Cannot navigate away from the category page. Similar to past navigation issues.

## Root Cause

In `CategoriesManager.tsx`, the `useEffect` on line 66-72 has `tree` in its dependency array:

```typescript
const tree = useTree({
  initialExpandedState: {},
})

useEffect(() => {
  if (categories.length > 0) {
    const data = categoriesToTreeData(categories)
    setTreeData(data)
    tree.setExpandedState(getTreeExpandedState(data, '*'))  // Triggers state update
  }
}, [categories, tree])  // ❌ tree object causes infinite update loop
```

**Why this breaks navigation:**
1. `tree` object reference may not be stable
2. Effect runs → calls `setExpandedState` → triggers re-render
3. Re-render creates new `tree` reference → effect runs again
4. This loop blocks React Router's navigation transitions

**Comparison with TagsManager:** TagsManager works because it doesn't use `useTree` hook - it uses a simple `Table` component with no tree state management.

## Fix

**File**: `frontend/src/routes/CategoriesManager.tsx`

**Line**: 72

**Change**: Remove `tree` from the dependency array. The effect only needs to run when `categories` changes, not when the tree controller changes.

```typescript
// BEFORE (line 66-72):
useEffect(() => {
  if (categories.length > 0) {
    const data = categoriesToTreeData(categories)
    setTreeData(data)
    tree.setExpandedState(getTreeExpandedState(data, '*'))
  }
}, [categories, tree])  // ❌ tree causes issues

// AFTER:
useEffect(() => {
  if (categories.length > 0) {
    const data = categoriesToTreeData(categories)
    setTreeData(data)
    tree.setExpandedState(getTreeExpandedState(data, '*'))
  }
  // tree is stable from useTree hook, only re-run when categories change
  // eslint-disable-next-line react-hooks/exhaustive-deps
}, [categories])  // ✅ Only depend on categories
```

**Note**: The `eslint-disable` is acceptable here because:
- `tree` is a controller object from `useTree()` that should be stable
- We intentionally only want to react to `categories` changes
- This is a common pattern with controller/ref objects

## Files to Modify

| File | Change |
|------|--------|
| `frontend/src/routes/CategoriesManager.tsx` | Remove `tree` from useEffect deps on line 72 |

## Verification

1. Navigate to Categories page
2. Click on a nav item (e.g., Dashboard, Tags)
3. Verify navigation works immediately
4. Return to Categories, verify tree still expands correctly
