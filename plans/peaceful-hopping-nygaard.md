# Fix ESLint Disables and Add CLAUDE.md Rule

## Summary

Found **4 eslint-disable comments** in the frontend codebase. 2 are legitimate, 2 need proper fixes.

---

## Audit Results

| File | Rule | Verdict |
|------|------|---------|
| `test-utils.tsx:1` | `react-refresh/only-export-components` | ✅ Keep - test files don't need HMR |
| `AuthContext.tsx:76` | `react-refresh/only-export-components` | ✅ Keep - context+hook co-location is standard |
| `CreateRequestForm.tsx:79` | `react-hooks/exhaustive-deps` | ❌ **Fix** |
| `MediaDetailPage.tsx:104` | `react-hooks/exhaustive-deps` | ❌ **Fix** |

---

## Fix 1: CreateRequestForm.tsx

**Current (problematic):**
```tsx
const loadGroups = async () => { /* ... */ }

useEffect(() => {
  if (opened) {
    loadGroups()
  }
  // eslint-disable-next-line react-hooks/exhaustive-deps
}, [opened])
```

**Problem:** `loadGroups` is recreated every render, but excluded from deps.

**Fix:** Convert `loadGroups` to `useCallback`:
```tsx
const loadGroups = useCallback(async () => {
  try {
    setLoadingGroups(true)
    const response = await groupService.listGroups()
    setGroups(response.groups || [])
  } catch (err) {
    console.error('Failed to load groups:', err)
    setSubmitError(t('createRequestForm.groupLoadError'))
  } finally {
    setLoadingGroups(false)
  }
}, [t])

useEffect(() => {
  if (opened) {
    loadGroups()
  }
}, [opened, loadGroups])  // No disable needed!
```

---

## Fix 2: MediaDetailPage.tsx

**Current (problematic - I added this!):**
```tsx
useEffect(() => {
  if (media) {
    form.setValues({...})
  }
  // eslint-disable-next-line react-hooks/exhaustive-deps
}, [media])
```

**Problem:** Hides the fact that `form.setValues` is being used without proper dep tracking.

**Fix:** Use `form.initialize()` which is Mantine's recommended method for async data:
```tsx
// Sync form values when media data loads (Mantine's recommended pattern)
useEffect(() => {
  if (media) {
    form.initialize({
      title: media.title || '',
      description: media.description || '',
      notes: media.notes || '',
    })
  }
}, [media, form])  // No disable needed!
```

**Why this works:**
- `form.initialize()` is designed for async data loading (see [Mantine docs](https://mantine.dev/form/values/))
- It sets both `values` and `initialValues`, so `form.reset()` works correctly
- It can only be called once per form (subsequent calls are no-ops), preventing loops
- The `handleCancelEdit` function should also use `form.reset()` instead of `form.setValues()`

---

## Fix 3: Add Rule to CLAUDE.md

Add to `/home/mriley/CLAUDE.md` in the Code Quality Requirements section:

```markdown
## ESLint Disable Policy

**NEVER use `eslint-disable` comments to silence linting errors.**

❌ **FORBIDDEN:**
```typescript
// eslint-disable-next-line react-hooks/exhaustive-deps
```

**WHY:** Disabling rules hides bugs and code smells. If a rule flags an issue, FIX the underlying problem.

**EXCEPTIONS (rare, must have comment explaining why):**
1. `react-refresh/only-export-components` in test files (HMR not needed)
2. `react-refresh/only-export-components` for context+hook co-location (standard React pattern)

**If you encounter a lint error:**
1. Understand WHY the rule exists
2. Fix the code to satisfy the rule
3. If truly a false positive, discuss with the user first
```

---

## Files to Modify

| File | Change |
|------|--------|
| `frontend/src/components/CreateRequestForm.tsx` | Convert `loadGroups` to useCallback, remove disable |
| `frontend/src/routes/MediaDetailPage.tsx` | Use `form.initialize()` instead of `form.setValues()`, remove disable |
| `/home/mriley/CLAUDE.md` | Add ESLint Disable Policy section |

---

## Testing

After fixes:
- `npm run lint` should pass with 0 warnings
- CreateRequestForm modal should load groups correctly
- MediaDetailPage should populate form without loops
