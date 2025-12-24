# Fix: Navigation Broken on MediaDetailPage

## Problem
When on `/catalog/:mediaId`, navigation is completely broken - clicking navbar links, back button, etc. does nothing. Issue happens immediately on page load. No console errors.

## Root Cause Analysis
The most likely cause is an **infinite re-render loop** from the `form.initialize()` pattern:

1. React StrictMode calls effects twice in development
2. `form.initialize()` updates internal form state
3. This may trigger additional renders
4. Combined with other state updates, creates render thrashing that blocks the main thread

**Key difference from working GroupDetailPage:** GroupDetailPage uses plain `useState` for form fields, NOT `@mantine/form`.

## Fix (Phase 1) - MediaDetailPage.tsx

### Change 1: Add initialization guard with useRef

**File:** `frontend/src/routes/MediaDetailPage.tsx`

**Before (current code after my first fix attempt):**
```tsx
useEffect(() => {
  if (media) {
    form.initialize({
      title: media.title || '',
      description: media.description || '',
      notes: media.notes || '',
    })
  }
  // eslint-disable-next-line react-hooks/exhaustive-deps
}, [media])
```

**After:**
```tsx
const formInitialized = useRef(false)

useEffect(() => {
  if (media && !formInitialized.current) {
    formInitialized.current = true
    form.initialize({
      title: media.title || '',
      description: media.description || '',
      notes: media.notes || '',
    })
  }
  // eslint-disable-next-line react-hooks/exhaustive-deps
}, [media])
```

This ensures `form.initialize()` only runs ONCE, even if React StrictMode or re-renders trigger the effect multiple times.

## Testing
1. Hard refresh the page (Ctrl+Shift+R) to bypass cache
2. Navigate to `/catalog/:mediaId`
3. Verify navbar links work
4. Verify back button works
5. Verify edit functionality still works

## If Phase 1 Doesn't Work

**Phase 2 fixes to try:**
- Fix CategoryTree.tsx line 99 (remove `tree` from dependencies)
- Consolidate data loading into single Promise.all
- Replace useForm with useState (like GroupDetailPage)
