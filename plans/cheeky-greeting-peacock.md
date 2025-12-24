# Plan: Mantine Frontend Audit Fixes

## Configuration
- **Scope:** All phases (accessibility, performance, dark mode)
- **i18n:** Use translation keys for all aria-labels

## Audit Summary

| Category | Count | Severity |
|----------|-------|----------|
| Accessibility (missing aria-label) | 7+ | CRITICAL |
| Performance (inline styles) | 5+ | MEDIUM |
| Dark Mode Issues | 2 | MEDIUM |
| Styles API Misuse | 1 | LOW |
| **Total** | **16+** | |

## Phase 1: CRITICAL Accessibility Fixes

### New i18n Keys Required
Add to `src/i18n/locales/en.json` and `ru.json`:
```json
{
  "common": {
    "editItem": "Edit {{item}}",
    "deleteItem": "Delete {{item}}",
    "viewDetails": "View details",
    "toggleExpand": "Toggle expand",
    "toggleSort": "Toggle sort direction"
  }
}
```

### 1.1 TagsManager.tsx (lines 195, 198)
```tsx
<ActionIcon aria-label={t('common.editItem', { item: tag.name })} ...>
<ActionIcon aria-label={t('common.deleteItem', { item: tag.name })} ...>
```

### 1.2 CategoriesManager.tsx (lines 161, 196, 206)
```tsx
<ActionIcon aria-label={t('common.toggleExpand')} ...>
<ActionIcon aria-label={t('common.editItem', { item: node.label })} ...>
<ActionIcon aria-label={t('common.deleteItem', { item: node.label })} ...>
```

### 1.3 SearchPage.tsx (lines 395, 405, 476, 716, 774)
```tsx
<ActionIcon aria-label={t('search.savedSearches')} ...>
<ActionIcon aria-label={t('search.history')} ...>
<ActionIcon aria-label={t('common.toggleSort')} ...>
<ActionIcon aria-label={t('common.delete')} ...>
```

### 1.4 QuarantineTable.tsx (lines 105-123)
```tsx
<ActionIcon aria-label={t('common.viewDetails')} ...>
<ActionIcon aria-label={t('common.deleteItem', { item: 'record' })} ...>
```

## Phase 2: Performance Fixes (Inline Styles)

### 2.1 MediaCard.tsx
- Lines 154-158: Extract card styles to stable reference
- Lines 187-192, 200-204: Extract badge/box positioning styles
- Lines 210-214: Remove hardcoded checkbox background

### 2.2 RequestCard.tsx (lines 228, 234, 244, 278)
- Replace inline `style={{...}}` with Mantine props (`bg="gray.1"`)
- Extract repeated styles to CSS module

### 2.3 SearchPage.tsx (lines 423, 599-607, 708, 770)
- Replace `style={{ flex: 1 }}` with Mantine's `flex={1}` prop
- Extract cursor styles to CSS module

### 2.4 NavItemLink.tsx (line 42-44)
- Extract `borderRadius` style to stable reference

## Phase 3: Dark Mode Fixes

### 3.1 MediaCard.tsx Checkbox (line 212)
Replace hardcoded white:
```tsx
// Before
backgroundColor: 'white'

// After - use theme function or remove override
styles={(theme) => ({
  input: { backgroundColor: theme.colorScheme === 'dark' ? theme.colors.dark[6] : 'white' }
})}
```

## Files to Modify

| File | Issues | Priority |
|------|--------|----------|
| `src/i18n/locales/en.json` | Add aria-label keys | HIGH |
| `src/i18n/locales/ru.json` | Add aria-label keys | HIGH |
| `src/routes/SearchPage.tsx` | 5 aria-labels, 4 inline styles | HIGH |
| `src/routes/TagsManager.tsx` | 2 aria-labels | HIGH |
| `src/routes/CategoriesManager.tsx` | 3 aria-labels | HIGH |
| `src/components/MediaCard.tsx` | 4 inline styles, 1 dark mode | MEDIUM |
| `src/components/RequestCard.tsx` | 4 inline styles | MEDIUM |
| `src/components/QuarantineTable.tsx` | 2 aria-labels | MEDIUM |
| `src/components/navigation/NavItemLink.tsx` | 1 inline style | LOW |

## Positive Findings (No Action Needed)
- No `!important` violations
- Proper Tooltip usage patterns
- Good theme variable usage (`var(--mantine-color-*)`)
- Navigation components are accessible (Burger, Breadcrumbs)

## Estimated Effort
- Phase 1 (Accessibility): ~30 min
- Phase 2 (Performance): ~45 min
- Phase 3 (Dark Mode): ~15 min
- **Total: ~1.5 hours**
