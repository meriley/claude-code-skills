# Plan: Complete Tags/Categories i18n

## Summary

Complete the internationalization of the Tags/Categories feature by adding i18n to the last remaining component: `MediaCard.tsx`.

**Scope:** ~30-45 minutes
**Files to modify:** 3

## Background

The Tags/Categories feature is **99% complete**:
- Backend filtering: Complete
- Frontend filter UI: Complete
- Bulk tag/category modals: Complete with i18n
- **MediaCard.tsx: Missing i18n** (8 hardcoded strings)

## Tasks

### Task 1: Add i18n to MediaCard.tsx

**File:** `frontend/src/components/MediaCard.tsx`

1. Import `useTranslation` hook:
   ```tsx
   import { useTranslation } from 'react-i18next'
   ```

2. Add hook at component top:
   ```tsx
   const { t } = useTranslation()
   ```

3. Replace hardcoded strings:

   | Line | Current | Replace With |
   |------|---------|--------------|
   | 133 | `'Delete Media'` | `t('mediaCard.deleteTitle')` |
   | 135-138 | `Are you sure...` | `t('mediaCard.deleteConfirm', { name: media.title \|\| media.filename })` |
   | 140 | `{ confirm: 'Delete', cancel: 'Cancel' }` | `{ confirm: t('common.delete'), cancel: t('common.cancel') }` |
   | 245 | `View Details` | `t('mediaCard.viewDetails')` |
   | 251 | `Download` | `t('mediaCard.download')` |
   | 261 | `Delete` | `t('common.delete')` |
   | 290 | `Used in {requestCount}...` | `t('mediaCard.usedInRequests', { count: requestCount })` |

### Task 2: Add English translations

**File:** `frontend/src/i18n/locales/en.json`

Add new keys:
```json
"mediaCard": {
  "deleteTitle": "Delete Media",
  "deleteConfirm": "Are you sure you want to delete \"{{name}}\"? This action cannot be undone.",
  "viewDetails": "View Details",
  "download": "Download",
  "usedInRequests": "Used in {{count}} request",
  "usedInRequests_other": "Used in {{count}} requests"
}
```

Note: `common.delete` (line 9) and `common.cancel` (line 8) already exist - reuse them.

### Task 3: Add Russian translations

**File:** `frontend/src/i18n/locales/ru.json`

Add new keys:
```json
"mediaCard": {
  "deleteTitle": "Удалить медиа",
  "deleteConfirm": "Вы уверены, что хотите удалить \"{{name}}\"? Это действие нельзя отменить.",
  "viewDetails": "Подробнее",
  "download": "Скачать",
  "usedInRequests": "Используется в {{count}} запросе",
  "usedInRequests_few": "Используется в {{count}} запросах",
  "usedInRequests_many": "Используется в {{count}} запросах"
}
```

Note: Russian has 3 plural forms (one, few, many).

## Verification

1. Run frontend lint: `cd frontend && npm run lint`
2. Run frontend build: `npm run build`
3. Manual test: Switch between EN/RU and verify MediaCard shows correct translations
4. Test delete modal in both languages
5. Test request count pluralization (1 vs 2+ requests)

## Files Summary

| File | Action |
|------|--------|
| `frontend/src/components/MediaCard.tsx` | Add i18n hook, replace 8 strings |
| `frontend/src/i18n/locales/en.json` | Add `mediaCard` section (~6 keys) |
| `frontend/src/i18n/locales/ru.json` | Add `mediaCard` section (~7 keys with plurals) |
