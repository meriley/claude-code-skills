# Mantine Frontend Code Review

## Summary

This review covers the demi-upload frontend codebase which uses **Mantine v7.17.8** as the primary UI library. The codebase demonstrates **good Mantine fundamentals** with consistent component usage and proper accessibility practices. However, there are several issues to address.

---

## Critical Issues (Accessibility)

### 1. ActionIcons Missing aria-label

**Severity:** CRITICAL - Accessibility violation

**Files affected:**
| File | Line | Context |
|------|------|---------|
| `MediaCard.tsx` | 227-234 | Menu trigger (IconDots) |
| `GroupCard.tsx` | 86-88 | Menu trigger (IconDots) |
| `MemberCard.tsx` | 103-105 | Menu trigger (IconDots) |
| `RequestCard.tsx` | 161-163, 251-258 | Menu triggers |
| `GroupDetailPage.tsx` | 316-318 | Action button |
| `MediaDetailPage.tsx` | 385-393 | Action button |

**Example fix:**
```tsx
// Before (FAIL)
<ActionIcon variant="subtle" color="gray" size="sm">
  <IconDots size={16} />
</ActionIcon>

// After (PASS)
<ActionIcon
  variant="subtle"
  color="gray"
  size="sm"
  aria-label="Open menu"
>
  <IconDots size={16} />
</ActionIcon>
```

**Note:** ActionIcons wrapped in `<Tooltip>` (like in QuarantineTable.tsx:105-123) are acceptable since the Tooltip label provides the accessible name.

---

## High Priority Issues

### 2. Forms Not Using @mantine/form

**Severity:** HIGH - Suboptimal pattern

**Files affected:**
- `CreateRequestForm.tsx` - Uses manual useState for each field
- `CreateGroupForm.tsx` - Manual state management

**Current pattern (suboptimal):**
```tsx
const [title, setTitle] = useState('')
const [description, setDescription] = useState('')
// ... many more states

// Manual validation in handleSubmit
if (!title.trim()) {
  setError('Title is required')
  return
}
```

**Recommended pattern:**
```tsx
import { useForm } from '@mantine/form'

const form = useForm({
  initialValues: { title: '', description: '' },
  validate: {
    title: (v) => (!v.trim() ? 'Title is required' : null),
  }
})

<TextInput {...form.getInputProps('title')} />
```

### 3. Package Version Mismatch

**Severity:** HIGH - Maintenance issue

**Issue:** package.json shows `@mantine/*: ^7.15.2` but `7.17.8` is actually installed

**Fix:** Update package.json to match installed versions

---

## Medium Priority Issues

### 4. No Custom Theme Configuration

**Severity:** MEDIUM - UX consistency

**Location:** `main.tsx`

**Current:**
```tsx
<MantineProvider defaultColorScheme="auto">
```

**Recommended:** Add custom theme object for brand colors, spacing, and component defaults.

### 5. Error Display Uses Inline Style

**Severity:** MEDIUM - Minor inconsistency

**File:** `CreateRequestForm.tsx:327-329`

```tsx
// Current (using inline style)
<div style={{ color: 'var(--mantine-color-red-6)', fontSize: '14px' }}>
  {error}
</div>

// Recommended (use Mantine Alert component)
<Alert color="red">{error}</Alert>
```

---

## Passed Checks

- **No nested interactive elements** - No Button/ActionIcon inside Accordion.Control
- **No disabled buttons in Tooltips** - Pattern not detected
- **Minimal Styles API usage** - Only 2 instances (acceptable)
- **No !important hacks** - CSS is clean
- **Theme-aware colors** - Using CSS variables correctly
- **Good loading states** - Proper use of Loader component
- **Excellent test coverage** - 134 data-testid occurrences
- **Proper form labels** - All inputs have label props
- **Responsive design** - Using SimpleGrid with responsive cols

---

## Files Requiring Fixes

### Critical (Accessibility):
1. `frontend/src/components/MediaCard.tsx` - Add aria-label to ActionIcon (line 227)
2. `frontend/src/components/GroupCard.tsx` - Add aria-label to ActionIcon (line 86)
3. `frontend/src/components/MemberCard.tsx` - Add aria-label to ActionIcon (line 103)
4. `frontend/src/components/RequestCard.tsx` - Add aria-label to ActionIcons (lines 161, 251)
5. `frontend/src/routes/GroupDetailPage.tsx` - Add aria-label to ActionIcon (line 316)
6. `frontend/src/routes/MediaDetailPage.tsx` - Add aria-label to ActionIcon (line 385)

### High Priority:
7. `frontend/src/components/CreateRequestForm.tsx` - Convert to useForm
8. `frontend/package.json` - Sync version numbers

### Medium Priority:
9. `frontend/src/main.tsx` - Add custom theme configuration
10. `frontend/src/components/CreateRequestForm.tsx` - Replace inline error style with Alert

---

## Implementation Plan (All Issues - Approved)

### Phase 1: Critical Accessibility Fixes
Add `aria-label` to all ActionIcon components without Tooltip wrappers:
1. `MediaCard.tsx:227` - aria-label="Open menu"
2. `GroupCard.tsx:86` - aria-label="Open menu"
3. `MemberCard.tsx:103` - aria-label="Open menu"
4. `RequestCard.tsx:161, 251` - aria-label="Open menu"
5. `GroupDetailPage.tsx:316` - aria-label appropriate to context
6. `MediaDetailPage.tsx:385` - aria-label appropriate to context

### Phase 2: Form Refactoring
Convert CreateRequestForm.tsx to use @mantine/form hook:
- Replace 10+ useState calls with single useForm
- Add declarative validation
- Use getInputProps for input binding
- Replace inline error div with Alert component

### Phase 3: Package Sync
Update package.json Mantine versions to 7.17.8 to match installed

### Phase 4: Theme Configuration
Add custom theme to main.tsx:
- Primary color configuration
- Default component props
- Consistent styling foundation

---

## Statistics

- **Total React files:** 68
- **Files using Mantine:** 37 (54%)
- **Files with issues:** 8
- **Critical issues:** 6 (accessibility)
- **High priority issues:** 2
- **Medium priority issues:** 2
