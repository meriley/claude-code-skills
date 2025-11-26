# Mantine Reviewing Skill Test Scenarios

Validate that the mantine-reviewing skill correctly identifies issues in Mantine code.

---

## Scenario 1: Missing Accessibility

**Input Code:**
```tsx
function SearchBar() {
  return (
    <Group>
      <TextInput placeholder="Search..." />
      <ActionIcon onClick={handleSearch}>
        <IconSearch />
      </ActionIcon>
      <ActionIcon onClick={handleClear}>
        <IconX />
      </ActionIcon>
    </Group>
  );
}
```

**Expected Findings:**
- **A1 CRITICAL**: ActionIcon at line 5 missing `aria-label`
- **A1 CRITICAL**: ActionIcon at line 8 missing `aria-label`

**Baseline (without skill):**
- May not flag accessibility issues
- May miss aria-label requirement

---

## Scenario 2: Nested Interactive Elements

**Input Code:**
```tsx
function AccordionWithActions() {
  return (
    <Accordion>
      <Accordion.Item value="item1">
        <Accordion.Control>
          Settings
          <Button size="xs" onClick={handleReset}>Reset</Button>
        </Accordion.Control>
        <Accordion.Panel>Content here</Accordion.Panel>
      </Accordion.Item>
    </Accordion>
  );
}
```

**Expected Findings:**
- **H1 CRITICAL**: Button inside Accordion.Control (line 6)
- Suggest moving Button outside Control using Group/Flex

**Baseline:**
- May not recognize invalid HTML structure
- May not know Accordion.Control is a button

---

## Scenario 3: Tooltip on Disabled Button

**Input Code:**
```tsx
function SubmitSection({ canSubmit }) {
  return (
    <Tooltip label="You don't have permission">
      <Button disabled={!canSubmit}>Submit</Button>
    </Tooltip>
  );
}
```

**Expected Findings:**
- **C1 HIGH**: Tooltip won't show on disabled button
- Suggest using `data-disabled` pattern

**Baseline:**
- May not know disabled elements don't receive mouse events
- May not know the data-disabled workaround

---

## Scenario 4: Styles API Misuse

**Input Code:**
```tsx
function CustomButton() {
  return (
    <Button
      style={{ background: 'linear-gradient(45deg, blue, purple)' }}
      className="my-button"
    >
      Click me
    </Button>
  );
}

// In CSS file:
.my-button span {
  color: white !important;
  font-weight: bold !important;
}
```

**Expected Findings:**
- **S1 HIGH**: Using `!important` to override Mantine styles
- **S2 HIGH**: Should use `classNames` or `styles` prop for inner elements
- Suggest: `classNames={{ label: classes.label }}` pattern

**Baseline:**
- May not know about Styles API
- May accept !important as valid approach

---

## Scenario 5: Dark Mode Issues

**Input Code:**
```tsx
function Card({ title, content }) {
  return (
    <Box
      style={{
        background: 'white',
        color: '#333',
        border: '1px solid #eee'
      }}
      p="md"
    >
      <Title order={3}>{title}</Title>
      <Text>{content}</Text>
    </Box>
  );
}
```

**Expected Findings:**
- **D1 HIGH**: Hardcoded `white` background
- **D2 HIGH**: Hardcoded `#333` text color
- **D4 HIGH**: Hardcoded `#eee` border
- Suggest using `light-dark()` or theme colors

**Baseline:**
- May not consider dark mode compatibility
- May accept hardcoded colors

---

## Scenario 6: Form Without useForm

**Input Code:**
```tsx
function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [emailError, setEmailError] = useState('');

  const handleSubmit = () => {
    if (!email.includes('@')) {
      setEmailError('Invalid email');
      return;
    }
    // submit...
  };

  return (
    <form onSubmit={handleSubmit}>
      <TextInput
        label="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        error={emailError}
      />
      <TextInput
        label="Password"
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />
      <Button type="submit">Login</Button>
    </form>
  );
}
```

**Expected Findings:**
- **F1 MEDIUM**: Manual form state management
- **F2 MEDIUM**: Not using `getInputProps` pattern
- Suggest: Use `@mantine/form` with `useForm` hook

**Baseline:**
- May accept manual state as valid
- May not suggest @mantine/form

---

## Scenario 7: Performance Issues

**Input Code:**
```tsx
function UserList({ users }) {
  return (
    <Stack>
      {users.map(user => (
        <Card
          key={user.id}
          styles={{
            root: { border: '1px solid gray' },
            section: { padding: 10 }
          }}
          onClick={() => handleUserClick(user.id)}
        >
          <Text>{user.name}</Text>
        </Card>
      ))}
    </Stack>
  );
}
```

**Expected Findings:**
- **P1 MEDIUM**: Inline `styles` object in map (new object each render)
- **P2 MEDIUM**: Inline arrow function in `onClick`
- Suggest: Extract styles to constant, use useCallback or data-attribute pattern

**Baseline:**
- May not identify performance anti-patterns
- May not know about re-render implications

---

## Scenario 8: ActionIcon.Group Structure

**Input Code:**
```tsx
function ActionButtons() {
  return (
    <ActionIcon.Group>
      <Tooltip label="Edit">
        <ActionIcon aria-label="Edit">
          <IconEdit />
        </ActionIcon>
      </Tooltip>
      <div className="spacer">
        <ActionIcon aria-label="Delete">
          <IconTrash />
        </ActionIcon>
      </div>
    </ActionIcon.Group>
  );
}
```

**Expected Findings:**
- **H6 CRITICAL**: Tooltip wrapper breaks ActionIcon.Group styling (line 3-6)
- **H6 CRITICAL**: div wrapper breaks ActionIcon.Group styling (line 7-10)
- Suggest: Move Tooltip outside group or restructure

**Baseline:**
- May not know about direct children requirement
- May not flag wrapper elements

---

## Evaluation Matrix

| Scenario | Without Skill | With Skill | Key Finding |
|----------|---------------|------------|-------------|
| 1. Accessibility | May miss | Flags A1 | aria-label required |
| 2. Nested Interactive | May miss | Flags H1 | Invalid HTML |
| 3. Tooltip Disabled | May miss | Flags C1 | data-disabled pattern |
| 4. Styles API | May accept | Flags S1, S2 | No !important |
| 5. Dark Mode | May miss | Flags D1-D4 | Theme-aware colors |
| 6. Form State | May accept | Flags F1, F2 | Use @mantine/form |
| 7. Performance | May miss | Flags P1, P2 | Stable references |
| 8. Group Structure | May miss | Flags H6 | Direct children only |

---

## Success Criteria

For skill to be effective:
- **8 of 8 scenarios** correctly identify issues
- **All Critical issues** (A1, H1, H6) flagged 100%
- **Correct severity** assigned to findings
- **Actionable fixes** suggested for each issue

---

## Testing Protocol

1. Create test file with scenario code
2. Run review without mentioning skill
3. Check if Claude invokes `mantine-reviewing`
4. Verify all expected findings are reported
5. Verify correct severity levels
6. Verify helpful fix suggestions provided
