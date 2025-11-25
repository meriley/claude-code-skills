# Mantine Code Review Checklist

Comprehensive checklist for reviewing Mantine UI components. Use during PR reviews or codebase audits.

---

## Critical Issues (Must Fix)

### Accessibility

- [ ] **A1**: All `ActionIcon` components have `aria-label` prop
- [ ] **A2**: All `CloseButton` components have `aria-label` or parent has `closeButtonLabel`
- [ ] **A3**: Icon-only buttons have accessible names
- [ ] **A4**: Form inputs have associated labels (via `label` prop or `aria-label`)
- [ ] **A5**: Error messages are associated with inputs (using `error` prop)
- [ ] **A6**: Focus indicators are visible (not hidden by CSS)
- [ ] **A7**: Keyboard navigation works for all interactive elements
- [ ] **A8**: Accordion headings have correct `order` prop for hierarchy
- [ ] **A9**: Color contrast meets WCAG AA (4.5:1 for text, 3:1 for UI)
- [ ] **A10**: No content hidden from screen readers that should be visible

### Invalid HTML Structure

- [ ] **H1**: No `Button` inside `Accordion.Control`
- [ ] **H2**: No `ActionIcon` inside `Accordion.Control`
- [ ] **H3**: No `Link`/`Anchor` inside `Accordion.Control`
- [ ] **H4**: No interactive elements inside `Button`
- [ ] **H5**: No interactive elements inside `UnstyledButton`
- [ ] **H6**: `ActionIcon.Group` only has direct `ActionIcon` children (no wrappers)
- [ ] **H7**: `Button.Group` only has direct `Button` children (no wrappers)

---

## High Priority Issues

### Styles API

- [ ] **S1**: No `!important` in CSS targeting Mantine components
- [ ] **S2**: Using `classNames` or `styles` prop for inner element customization
- [ ] **S3**: Not using plain `style` prop expecting it to affect inner elements
- [ ] **S4**: Selector names match component's Styles API (root, label, etc.)
- [ ] **S5**: CSS variables follow `--mantine-*` naming when extending theme

### Component Patterns

- [ ] **C1**: Tooltips on disabled buttons use `data-disabled` pattern
- [ ] **C2**: `Select` used when value must be from list (not `Autocomplete`)
- [ ] **C3**: `Autocomplete` used when free text is acceptable
- [ ] **C4**: Polymorphic components have correct ref types
- [ ] **C5**: `AspectRatio` in flex containers has explicit width/flex
- [ ] **C6**: Modal/Drawer have `onClose` handler that matches `opened` state

### Dark Mode

- [ ] **D1**: No hardcoded light colors (`white`, `#fff`, `rgb(255,255,255)`)
- [ ] **D2**: No hardcoded dark colors (`black`, `#000`) in elements that should adapt
- [ ] **D3**: Using `light-dark()` CSS function for custom color values
- [ ] **D4**: Using theme color props (`color="gray.0"`) instead of hardcoded
- [ ] **D5**: Custom components tested in both light and dark modes

---

## Medium Priority Issues

### Form Handling

- [ ] **F1**: Using `@mantine/form` for forms with validation (not manual state)
- [ ] **F2**: Using `form.getInputProps()` for input binding
- [ ] **F3**: Checkbox/Switch inputs use `{ type: 'checkbox' }` in getInputProps
- [ ] **F4**: Form validation messages are clear and helpful
- [ ] **F5**: `validateInputOnChange` or `validateInputOnBlur` set appropriately
- [ ] **F6**: Form `onSubmit` uses `form.onSubmit()` wrapper

### Performance

- [ ] **P1**: No inline object literals in `styles` prop (creates new object each render)
- [ ] **P2**: No inline functions in event handlers for frequently rendered components
- [ ] **P3**: Large lists use virtualization (`@mantine/virtual`)
- [ ] **P4**: Heavy modals/drawers use lazy loading or code splitting
- [ ] **P5**: Memoization used for expensive computed values
- [ ] **P6**: No unnecessary state updates causing re-renders

### Component Usage

- [ ] **U1**: Using Mantine spacing props (`m`, `p`, `mt`, etc.) instead of custom CSS
- [ ] **U2**: Using Mantine color props instead of hardcoded colors
- [ ] **U3**: Using `Stack`/`Group` for layout instead of custom flexbox
- [ ] **U4**: Using `Grid` for responsive layouts
- [ ] **U5**: Using `Container` for max-width constraints
- [ ] **U6**: Notifications use `@mantine/notifications` system, not custom

---

## Low Priority / Suggestions

### Code Organization

- [ ] **O1**: Mantine imports grouped together
- [ ] **O2**: CSS modules used for complex styling (not inline styles objects)
- [ ] **O3**: Shared component styles extracted to theme or shared CSS
- [ ] **O4**: Custom hooks used for complex form logic
- [ ] **O5**: Consistent naming for classNames and styles props

### Best Practices

- [ ] **B1**: Using `rem` units via Mantine's rem() function
- [ ] **B2**: Responsive props used for breakpoint-aware values
- [ ] **B3**: Theme values used instead of magic numbers
- [ ] **B4**: Loading states shown appropriately (Skeleton, Button loading)
- [ ] **B5**: Error states handled with appropriate feedback
- [ ] **B6**: Empty states handled with helpful messages

---

## Quick Reference: Issue Codes

| Code | Category | Severity |
|------|----------|----------|
| A1-A10 | Accessibility | Critical |
| H1-H7 | HTML Structure | Critical |
| S1-S5 | Styles API | High |
| C1-C6 | Component Patterns | High |
| D1-D5 | Dark Mode | High |
| F1-F6 | Form Handling | Medium |
| P1-P6 | Performance | Medium |
| U1-U6 | Component Usage | Medium |
| O1-O5 | Code Organization | Low |
| B1-B6 | Best Practices | Low |

---

## Review Commands

### Find Accessibility Issues

```bash
# Missing aria-label on ActionIcon
grep -rn "ActionIcon" --include="*.tsx" | grep -v "aria-label"

# Missing aria-label on CloseButton
grep -rn "CloseButton" --include="*.tsx" | grep -v "aria-label"
```

### Find HTML Structure Issues

```bash
# Nested interactives in Accordion.Control
grep -rn "Accordion\.Control" -A10 --include="*.tsx" | grep -E "Button|ActionIcon|Link|Anchor"

# Wrapped ActionIcon.Group children
grep -rn "ActionIcon\.Group" -A5 --include="*.tsx" | grep -E "<div|<span|<Box"
```

### Find Styles API Issues

```bash
# !important usage (potential hack)
grep -rn "!important" --include="*.css" --include="*.scss" --include="*.module.css"

# Inline styles that might need Styles API
grep -rn "style={{" --include="*.tsx" | grep -E "Button|Input|Select|Modal"
```

### Find Dark Mode Issues

```bash
# Hardcoded white/black colors
grep -rn "style={{" --include="*.tsx" | grep -E "'white'|'black'|#fff|#000|rgb\(255|rgb\(0"

# Hardcoded colors in CSS
grep -rn "color:" --include="*.css" --include="*.module.css" | grep -E "#[0-9a-fA-F]{3,6}|rgb\("
```

### Find Form Issues

```bash
# Manual useState for form fields (potential issue)
grep -rn "useState.*''\|useState.*\"\"|useState.*false" --include="*.tsx" | head -20

# Missing useForm import
grep -rn "TextInput\|Select\|Checkbox" --include="*.tsx" -l | xargs grep -L "useForm"
```

### Find Performance Issues

```bash
# Inline styles objects
grep -rn "styles={{" --include="*.tsx"

# Inline functions in handlers
grep -rn "onClick={() =>" --include="*.tsx" | head -20
```

---

## Example Review Output

```markdown
## Mantine Review: UserProfile.tsx

### Critical Issues

- [ ] **A1** Missing aria-label - Line 45: `<ActionIcon><IconEdit /></ActionIcon>`
- [ ] **H1** Nested interactive - Line 78: Button inside Accordion.Control

### High Priority

- [ ] **S1** !important hack - UserProfile.module.css:23
- [ ] **C1** Tooltip on disabled - Line 92: Tooltip wrapping disabled Button
- [ ] **D1** Hardcoded color - Line 34: `style={{ background: 'white' }}`

### Medium Priority

- [ ] **F1** Manual form state - Lines 12-15: Using useState for form fields
- [ ] **P1** Inline styles object - Line 67: `styles={{ root: { ... } }}`

### Passed Checks

- [x] Form inputs have labels
- [x] Keyboard navigation works
- [x] Correct Select vs Autocomplete usage
- [x] Good component composition
```

---

## Severity Guidelines

### Critical (Must Fix Before Merge)
- Accessibility violations (fails WCAG)
- Invalid HTML structure (will break in browsers)
- Security issues

### High (Should Fix Before Merge)
- Will break in dark mode
- Common pitfalls that cause bugs
- Styles API misuse

### Medium (Fix Soon)
- Performance issues in hot paths
- Suboptimal patterns
- Maintainability concerns

### Low (Nice to Have)
- Code style preferences
- Minor optimizations
- Documentation suggestions
