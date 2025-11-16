---
name: Mantine UI Expert
description: Build React applications with Mantine UI: components, theming, hooks, Styles API, forms. For creating UIs with Mantine library.
version: 1.0.0
---

# ⚠️ MANDATORY: Mantine UI Expert Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Building UIs with Mantine components
2. Implementing Mantine theming
3. Using Mantine hooks (useForm, useMediaQuery, etc.)
4. Styling with Styles API
5. Working with Mantine forms

**This skill is MANDATORY because:**
- Ensures consistent Mantine usage across codebase
- Prevents common Mantine mistakes
- Leverages Mantine capabilities properly
- Maintains design system consistency
- Improves component accessibility

**ENFORCEMENT:**

**P1 Violations (High - Quality Failure):**
- Not using Mantine components (reinventing the wheel)
- Inconsistent theming approach
- Missing accessibility features
- Poor component composition
- Not using Mantine hooks where available

**P2 Violations (Medium - Efficiency Loss):**
- Overriding Mantine styles unnecessarily
- Missing responsive design
- Unclear component usage

**Blocking Conditions:**
- Must use Mantine components for UI
- Must follow Mantine design patterns
- Theming must be consistent
- Accessibility must be maintained

---

## Purpose

Build React applications using Mantine UI library. Use when creating UIs with Mantine components, implementing Mantine theming, using Mantine hooks, styling with Styles API.

## Core Components

### Layout Components
- Container, Grid, Flex
- Stack, Group, Center
- Navbar, Header, Footer, Aside

### Form Components
- TextInput, PasswordInput, Textarea
- Select, MultiSelect, Checkbox, Radio
- FileInput, NumberInput
- DateInput, TimeInput
- Button, Anchor

### Data Components
- Table, DataTable
- Timeline, Stepper
- Progress, RingProgress

### Feedback Components
- Alert, Notification, Toast
- Modal, Drawer
- Badge, Indicator

### Navigation Components
- Tabs, Breadcrumbs
- Pagination
- SegmentedControl

## Mantine Hooks

**Form Management:**
```typescript
const form = useForm({
  initialValues: { email: '', password: '' },
  validate: { email: isEmail }
});
```

**Responsive Design:**
```typescript
const isMobile = useMediaQuery('(max-width: 600px)');
```

**Theme Management:**
```typescript
const { colorScheme, toggleColorScheme } = useMantineColorScheme();
```

## Theming Best Practices

- Use theme provider at app root
- Define color palette
- Set typography defaults
- Configure responsive breakpoints
- Use CSS variables for consistency

## Styles API

```typescript
const useStyles = createStyles((theme) => ({
  wrapper: {
    padding: theme.spacing.md,
    backgroundColor: theme.colors.gray[0],
  },
}));
```

## Form Handling

```typescript
const form = useForm({
  initialValues: { },
  validate: { },
  onSubmit: (values) => { }
});

return (
  <form onSubmit={form.onSubmit((values) => { })}>
    <TextInput {...form.getInputProps('field')} />
  </form>
);
```

## Anti-Patterns

### ❌ Anti-Pattern: Not Using Mantine Components

**Wrong:**
```typescript
const CustomButton = styled.button`
  padding: 12px;
  border: none;
  background: blue;
  color: white;
`; // Reinventing Button!
```

**Correct:**
```typescript
import { Button } from '@mantine/core';

<Button color="blue">Click me</Button>
```

---

## References

**Based on:**
- CLAUDE.md Section 3 (Available Skills Reference - maintine-ui)
- Mantine documentation: https://mantine.dev/

**Related skills:**
- `material-design` - Complementary design system
