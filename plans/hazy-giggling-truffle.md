# Plan: Create Mantine UI Skill

## Summary

Create a Mantine UI skill following skill-writing guidelines that provides component patterns, Styles API usage, common pitfalls, and accessibility requirements. Uses progressive disclosure with Skill.md < 500 lines.

## Skill Structure (Following skill-writing Guidelines)

```
~/.claude/skills/mantine-developing/
├── Skill.md           # Main skill (< 500 lines, core patterns)
├── REFERENCE.md       # Detailed component reference
└── test-scenarios.md  # Test scenarios for validation
```

## Skill.md Content Plan

### Frontmatter (Following Guidelines)
```yaml
---
name: mantine-developing
description: Build React UIs with Mantine component library. Customize styles with Styles API, handle forms with @mantine/form, implement theming, and avoid accessibility pitfalls. Use when creating Mantine components or fixing styling issues.
version: 1.0.0
---
```

### Required Sections (Per skill-writing Guidelines)

1. **Purpose** (1 sentence)
   Build React UIs with Mantine's component library, Styles API, and form handling.

2. **When to Use** (Specific triggers)
   - Creating new React components with Mantine
   - Customizing Mantine component styles
   - Building forms with validation
   - Fixing Mantine styling or accessibility issues
   - Implementing dark mode or theming

3. **When NOT to Use** (Clear boundaries)
   - Basic React development (Claude knows this)
   - Non-Mantine UI libraries (use library-specific skill)
   - Simple HTML/CSS without Mantine
   - Mantine v6 or earlier (this covers v7+)

4. **Quick Start Workflow**
   ```
   Step 1: Import from correct package
   Step 2: Use component with common props
   Step 3: Customize with Styles API if needed
   Step 4: Validate accessibility
   ```

5. **Core Patterns** (Most important - what Claude doesn't already know)

   **Styles API Pattern** (Critical - non-obvious):
   ```tsx
   // classNames prop - target inner elements
   <Button classNames={{ root: classes.button, label: classes.label }} />

   // styles prop - inline styles for inner elements
   <Button styles={{ root: { padding: 10 }, label: { color: 'blue' } }} />

   // CSS variables
   <Button style={{ '--button-bg': 'var(--mantine-color-blue-6)' }} />

   // Data attributes for state styling
   <Button data-active={isActive} />
   ```

   **Form Pattern** (@mantine/form):
   ```tsx
   import { useForm } from '@mantine/form';

   const form = useForm({
     initialValues: { email: '', terms: false },
     validate: {
       email: (v) => (/^\S+@\S+$/.test(v) ? null : 'Invalid email'),
       terms: (v) => (v ? null : 'Must accept terms'),
     },
   });

   // In JSX
   <TextInput {...form.getInputProps('email')} />
   <Checkbox {...form.getInputProps('terms', { type: 'checkbox' })} />
   <form onSubmit={form.onSubmit(handleSubmit)}>
   ```

   **Polymorphic Components**:
   ```tsx
   // Change underlying element
   <Button component="a" href="/link">Link styled as button</Button>
   <Text component="span">Inline text</Text>

   // Note: Ref type changes! HTMLButtonElement → HTMLAnchorElement
   ```

6. **Common Pitfalls** (Critical - these cause bugs)

   | Pitfall | Wrong | Correct |
   |---------|-------|---------|
   | Nested interactive | `<Accordion.Control><Button/></Accordion.Control>` | Move button outside Control |
   | Tooltip on disabled | `<Tooltip><Button disabled/></Tooltip>` | Use `data-disabled` on button |
   | ActionIcon.Group | `<ActionIcon.Group><div><ActionIcon/></div></ActionIcon.Group>` | Direct children only |
   | Missing aria-label | `<ActionIcon><IconSearch/></ActionIcon>` | Add `aria-label="Search"` |
   | AspectRatio in flex | No width set | Add explicit `width` or `flex` |

7. **Accessibility Requirements**
   - `aria-label` required on icon-only buttons
   - Use `closeButtonLabel` prop on closable components
   - Set `order` prop for correct heading hierarchy
   - Test keyboard navigation

8. **Troubleshooting**
   | Problem | Cause | Solution |
   |---------|-------|----------|
   | Styles not applying | Wrong selector | Check component's Styles API docs for selector names |
   | Dark mode broken | Hardcoded colors | Use `light-dark()` CSS or theme colors |
   | Form not validating | Missing config | Check `validate` vs `validateInputOnChange` prop |
   | Type errors on ref | Polymorphic change | Update ref type to match `component` prop |

9. **External Docs**
   ```
   For latest Mantine docs:
   1. Context7: mcp__context7__get-library-docs with "/mantinedev/mantine"
   2. Direct: WebFetch → https://mantine.dev/llms.txt
   ```

## REFERENCE.md Content Plan

Detailed patterns organized by category:

### Layout Components
- Stack (vertical spacing)
- Group (horizontal spacing)
- Grid (responsive grid)
- Flex (flexbox wrapper)
- Container (max-width wrapper)
- AppShell (page layout)

### Input Components
- TextInput, NumberInput, PasswordInput
- Select vs Autocomplete (key difference: Select enforces options)
- Checkbox, Radio, Switch
- DatePicker, ColorPicker

### Feedback Components
- Notifications (toast system)
- Modal, Drawer (overlays)
- Alert, Indicator, Badge

### Navigation Components
- Tabs, NavLink
- Breadcrumbs
- Pagination

### Data Display
- Table (basic)
- Skeleton (loading)
- Timeline, Stepper

## test-scenarios.md Content

```markdown
## Test Scenarios

### Scenario 1: Basic Component Styling
**Input**: "Add a custom styled button with hover effect"
**Expected**: Uses Styles API with classNames, not inline styles
**Baseline**: May use inline styles or !important

### Scenario 2: Form with Validation
**Input**: "Create a login form with email and password validation"
**Expected**: Uses @mantine/form with validate object, getInputProps
**Baseline**: May use useState for each field

### Scenario 3: Fix Accessibility
**Input**: "Add icon button for search"
**Expected**: ActionIcon with aria-label
**Baseline**: May forget aria-label

### Scenario 4: Fix Nested Interactive
**Input**: "Add delete button inside accordion item"
**Expected**: Places button outside Accordion.Control
**Baseline**: May nest inside Control (invalid HTML)
```

## Implementation Order

1. Create `~/.claude/skills/mantine-developing/` directory
2. Create Skill.md with all required sections (< 500 lines)
3. Create REFERENCE.md with detailed component patterns
4. Create test-scenarios.md for validation
5. Verify line count and progressive disclosure
6. Test with fresh Claude instance

## Quality Checklist (From skill-writing)

- [x] Name uses gerund form (mantine-developing)
- [x] Description in third person with triggers
- [ ] Skill.md < 500 lines
- [ ] 2-3 concrete examples
- [ ] When to Use AND When NOT to Use
- [ ] Sequential workflow
- [ ] Troubleshooting section
- [ ] Consistent terminology
- [ ] No deeply nested references (max 1 level)
- [ ] test-scenarios.md exists
