# Fix: Navigation Broken on Media Detail Page

## Problem
When on the media detail page (`/catalog/:mediaId`), navigation stops working - navbar links, back button, and other navigation elements become unresponsive.

## Root Cause
**Infinite re-render loop** in `MediaDetailPage.tsx` caused by incorrect useEffect dependencies.

**Current code (lines 95-103):**
```tsx
useEffect(() => {
  if (media) {
    form.initialize({
      title: media.title || '',
      description: media.description || '',
      notes: media.notes || '',
    })
  }
}, [media, form])  // BUG: `form` in dependencies!
```

**Why it loops:**
1. `form` is included in the dependency array
2. `form.initialize()` triggers an internal state update
3. State update may cause re-render with new/changed form reference
4. useEffect runs again → loop continues
5. JavaScript thread blocked → no navigation possible

**Mantine docs show the correct pattern:**
```tsx
useEffect(() => {
  if (query.data) {
    form.initialize(query.data);
  }
}, [query.data]);  // Only data dependency, NOT form
```

## Fix

### File: `frontend/src/routes/MediaDetailPage.tsx`

**Change lines 95-103 from:**
```tsx
useEffect(() => {
  if (media) {
    form.initialize({
      title: media.title || '',
      description: media.description || '',
      notes: media.notes || '',
    })
  }
}, [media, form])
```

**To:**
```tsx
useEffect(() => {
  if (media) {
    form.initialize({
      title: media.title || '',
      description: media.description || '',
      notes: media.notes || '',
    })
  }
  // form.initialize is designed to be called once - it handles idempotency internally
  // eslint-disable-next-line react-hooks/exhaustive-deps
}, [media])
```

## Rationale
- `form.initialize()` is specifically designed to be safe to call multiple times - it only initializes once
- The Mantine documentation explicitly shows this pattern without `form` in dependencies
- The ESLint disable comment is acceptable here per project policy (explaining why the rule is intentionally bypassed)

## Testing
1. Navigate to a media detail page (`/catalog/1`)
2. Verify page loads without freezing
3. Verify navbar links work
4. Verify back button works
5. Verify editing form still functions correctly
6. Run frontend linting and type-check
