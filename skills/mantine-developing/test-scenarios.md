# Mantine Skill Test Scenarios

Use these scenarios to validate the mantine-developing skill improves Claude's performance over baseline.

## Test Protocol

1. **Fresh instance test**: Open new Claude Code session
2. **Don't mention skill**: Let Claude decide whether to invoke
3. **Measure**: Success rate, quality, time
4. **Compare**: With and without skill

---

## Scenario 1: Basic Component Styling

**Task**: "Add a custom styled button with a gradient background and hover effect using Mantine"

**Expected behavior (with skill)**:
- Uses Styles API with `classNames` or `styles` prop
- Creates CSS module or uses inline styles object for inner elements
- Targets correct selector names (root, label)

**Baseline behavior (without skill)**:
- May use inline `style` prop (only affects root)
- May try `!important` or className override
- May not know about Styles API

**Success criteria**:
- [ ] Uses classNames or styles prop
- [ ] Targets root selector for background
- [ ] Includes hover state
- [ ] No !important hacks

---

## Scenario 2: Form with Validation

**Task**: "Create a registration form with email validation, password confirmation, and terms acceptance using Mantine"

**Expected behavior (with skill)**:
- Uses `@mantine/form` with `useForm` hook
- Implements `validate` object with validation functions
- Uses `form.getInputProps()` for input binding
- Uses `{ type: 'checkbox' }` for terms checkbox

**Baseline behavior (without skill)**:
- May use individual useState for each field
- May implement custom validation logic
- May not know about getInputProps

**Success criteria**:
- [ ] Imports useForm from @mantine/form
- [ ] Uses validate object in useForm config
- [ ] Uses getInputProps for all fields
- [ ] Correctly binds checkbox with type: 'checkbox'
- [ ] Form validates on submit

---

## Scenario 3: Icon Button Accessibility

**Task**: "Add an icon-only button for search functionality using Mantine ActionIcon"

**Expected behavior (with skill)**:
- Uses ActionIcon component
- Adds `aria-label` prop
- Icon is from @tabler/icons-react or similar

**Baseline behavior (without skill)**:
- May use ActionIcon but forget aria-label
- May use regular Button with just icon

**Success criteria**:
- [ ] Uses ActionIcon component
- [ ] Includes aria-label="Search" or similar
- [ ] Functional click handler

---

## Scenario 4: Nested Interactive Element

**Task**: "Create an accordion with a delete button for each item using Mantine"

**Expected behavior (with skill)**:
- Places button OUTSIDE Accordion.Control
- Uses flex layout to position button alongside Control
- Maintains valid HTML (no button inside button)

**Baseline behavior (without skill)**:
- May nest Button inside Accordion.Control (invalid HTML)
- Browser will break it out, causing layout issues

**Success criteria**:
- [ ] Button is NOT inside Accordion.Control
- [ ] Button and Control are siblings in a flex container
- [ ] Both button and accordion control function correctly

---

## Scenario 5: Tooltip on Disabled Button

**Task**: "Show a tooltip explaining why a submit button is disabled"

**Expected behavior (with skill)**:
- Uses `data-disabled` instead of `disabled` prop
- Adds `onClick={(e) => e.preventDefault()}` to prevent action
- Tooltip wraps button and shows correctly

**Baseline behavior (without skill)**:
- Uses `disabled` prop (tooltip won't show on disabled elements)
- User sees nothing when hovering

**Success criteria**:
- [ ] Uses data-disabled attribute
- [ ] Prevents click with onClick handler
- [ ] Tooltip actually displays on hover
- [ ] Button appears visually disabled

---

## Scenario 6: Dark Mode Implementation

**Task**: "Add a dark mode toggle to a Mantine app with proper theme handling"

**Expected behavior (with skill)**:
- Uses `useMantineColorScheme` hook
- Calls `toggleColorScheme()` function
- Uses `light-dark()` CSS function for custom colors

**Baseline behavior (without skill)**:
- May try to manage state manually
- May use hardcoded colors that break in dark mode

**Success criteria**:
- [ ] Uses useMantineColorScheme hook
- [ ] Toggle button works correctly
- [ ] Custom styles use light-dark() or theme colors

---

## Scenario 7: Select vs Autocomplete

**Task**: "Create a country selector where users must choose from a predefined list"

**Expected behavior (with skill)**:
- Uses Select component (enforces list values)
- NOT Autocomplete (allows free text)

**Baseline behavior (without skill)**:
- May use Autocomplete incorrectly
- User could type invalid country

**Success criteria**:
- [ ] Uses Select, not Autocomplete
- [ ] Only allows values from data list
- [ ] Searchable prop for filtering (optional)

---

## Scenario 8: AppShell Layout

**Task**: "Create a responsive page layout with collapsible sidebar navigation"

**Expected behavior (with skill)**:
- Uses AppShell component with header, navbar, main
- Uses useDisclosure for mobile toggle
- Sets breakpoint for responsive behavior
- Burger component for mobile menu toggle

**Baseline behavior (without skill)**:
- May create custom layout with divs
- May not handle responsive collapse properly

**Success criteria**:
- [ ] Uses AppShell component
- [ ] Navbar collapses on mobile
- [ ] Burger toggles navbar visibility
- [ ] Header stays fixed
- [ ] Main content has proper padding

---

## Evaluation Matrix

| Scenario | Without Skill | With Skill | Improvement |
|----------|---------------|------------|-------------|
| 1. Styling | Uses inline style only | Uses Styles API | Proper customization |
| 2. Form | Manual state management | useForm hook | Less boilerplate |
| 3. Accessibility | Missing aria-label | Includes aria-label | Accessible |
| 4. Nested Interactive | Invalid HTML | Valid structure | No bugs |
| 5. Tooltip Disabled | Tooltip doesn't show | Tooltip works | UX fixed |
| 6. Dark Mode | Hardcoded colors | Theme-aware | Dark mode works |
| 7. Select vs Autocomplete | Wrong component | Correct component | Data integrity |
| 8. AppShell | Custom layout | Built-in component | Responsive works |

---

## Testing Commands

```bash
# Open fresh Claude Code session
claude

# Give task without mentioning Mantine skill
> "Create a registration form with email validation using Mantine"

# Observe:
# - Does Claude invoke mantine-developing skill?
# - Does Claude use correct patterns?
# - Is output correct and accessible?
```

---

## Minimum Success Rate

For skill to be considered effective:
- **6 of 8 scenarios** must show improvement over baseline
- **No scenario** should be worse with skill than without
- **Accessibility scenarios** (3, 5) must pass 100%
