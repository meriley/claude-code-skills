# Mantine Component Reference

Detailed component patterns organized by category. For quick patterns and core concepts, see Skill.md.

## Table of Contents

1. [Layout Components](#layout-components)
2. [Input Components](#input-components)
3. [Feedback Components](#feedback-components)
4. [Navigation Components](#navigation-components)
5. [Data Display Components](#data-display-components)
6. [Overlay Components](#overlay-components)
7. [Common Props Reference](#common-props-reference)

---

## Layout Components

### Stack (Vertical Spacing)

```tsx
import { Stack } from '@mantine/core';

// Basic vertical stack
<Stack gap="md">
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
</Stack>

// With alignment
<Stack gap="lg" align="center" justify="space-between">
  <div>Centered item</div>
</Stack>
```

**Key props:**
- `gap`: Spacing between items (xs, sm, md, lg, xl or number in px)
- `align`: Cross-axis alignment (stretch, center, flex-start, flex-end)
- `justify`: Main-axis alignment (flex-start, center, space-between, etc.)

### Group (Horizontal Spacing)

```tsx
import { Group } from '@mantine/core';

// Basic horizontal group
<Group gap="sm">
  <Button>Action 1</Button>
  <Button>Action 2</Button>
</Group>

// Spread items apart
<Group justify="space-between">
  <Logo />
  <Navigation />
</Group>

// Wrap when overflow
<Group wrap="wrap">
  {tags.map(tag => <Badge key={tag}>{tag}</Badge>)}
</Group>
```

**Key props:**
- `gap`: Spacing between items
- `justify`: Main-axis alignment
- `wrap`: 'wrap' | 'nowrap' (default: nowrap)
- `grow`: Boolean, items grow to fill space

### Grid (Responsive Grid)

```tsx
import { Grid } from '@mantine/core';

// Basic 12-column grid
<Grid>
  <Grid.Col span={6}>Half width</Grid.Col>
  <Grid.Col span={6}>Half width</Grid.Col>
</Grid>

// Responsive columns
<Grid>
  <Grid.Col span={{ base: 12, sm: 6, md: 4 }}>
    Full on mobile, half on tablet, third on desktop
  </Grid.Col>
</Grid>

// With gutter
<Grid gutter="xl">
  <Grid.Col span={4}>Column</Grid.Col>
  <Grid.Col span={4}>Column</Grid.Col>
  <Grid.Col span={4}>Column</Grid.Col>
</Grid>
```

**Key props:**
- `gutter`: Gap between columns
- `span`: Column width (1-12 or responsive object)
- `offset`: Left offset in columns

### Container (Max-Width Wrapper)

```tsx
import { Container } from '@mantine/core';

// Default max-width
<Container>
  <Content />
</Container>

// Custom size
<Container size="xs">  {/* xs, sm, md, lg, xl */}
  <NarrowContent />
</Container>

// Fluid (no max-width)
<Container fluid>
  <FullWidthContent />
</Container>
```

### AppShell (Page Layout)

```tsx
import { AppShell, Burger } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';

function Layout() {
  const [opened, { toggle }] = useDisclosure();

  return (
    <AppShell
      header={{ height: 60 }}
      navbar={{ width: 300, breakpoint: 'sm', collapsed: { mobile: !opened } }}
      padding="md"
    >
      <AppShell.Header>
        <Group h="100%" px="md">
          <Burger opened={opened} onClick={toggle} hiddenFrom="sm" />
          <Logo />
        </Group>
      </AppShell.Header>

      <AppShell.Navbar p="md">
        <NavLinks />
      </AppShell.Navbar>

      <AppShell.Main>
        <Outlet />  {/* React Router */}
      </AppShell.Main>
    </AppShell>
  );
}
```

**Key props:**
- `header`: { height: number }
- `navbar`: { width: number, breakpoint: 'xs'|'sm'|'md'|'lg'|'xl', collapsed: { mobile?: boolean, desktop?: boolean } }
- `aside`: Same as navbar, for right side
- `footer`: { height: number }
- `padding`: Content padding

---

## Input Components

### TextInput

```tsx
import { TextInput } from '@mantine/core';

// Basic
<TextInput
  label="Email"
  placeholder="your@email.com"
  description="We'll never share your email"
  error="Invalid email format"
  required
/>

// With icon
<TextInput
  leftSection={<IconSearch size={16} />}
  rightSection={<IconX size={16} onClick={clear} style={{ cursor: 'pointer' }} />}
/>

// With form
<TextInput {...form.getInputProps('email')} />
```

### NumberInput

```tsx
import { NumberInput } from '@mantine/core';

<NumberInput
  label="Quantity"
  min={0}
  max={100}
  step={1}
  allowNegative={false}
  decimalScale={2}
  prefix="$"
  suffix=" USD"
  thousandSeparator=","
/>
```

### Select

```tsx
import { Select } from '@mantine/core';

// Simple options
<Select
  label="Country"
  data={['USA', 'Canada', 'Mexico']}
  placeholder="Select country"
/>

// With value/label
<Select
  label="Status"
  data={[
    { value: 'active', label: 'Active' },
    { value: 'inactive', label: 'Inactive' },
  ]}
/>

// Searchable with clear
<Select
  searchable
  clearable
  nothingFoundMessage="No options"
  data={countries}
/>

// Grouped
<Select
  data={[
    { group: 'Frontend', items: ['React', 'Vue', 'Angular'] },
    { group: 'Backend', items: ['Node', 'Python', 'Go'] },
  ]}
/>
```

**Select vs Autocomplete:**
- **Select**: Value MUST be from the list
- **Autocomplete**: Value CAN be anything (list is suggestions)

### Autocomplete

```tsx
import { Autocomplete } from '@mantine/core';

<Autocomplete
  label="Search"
  placeholder="Type to search..."
  data={suggestions}
  limit={5}
/>
```

### Checkbox & Radio

```tsx
import { Checkbox, Radio, Group } from '@mantine/core';

// Single checkbox
<Checkbox
  label="Accept terms"
  {...form.getInputProps('terms', { type: 'checkbox' })}
/>

// Checkbox group
<Checkbox.Group
  label="Select features"
  value={selectedFeatures}
  onChange={setSelectedFeatures}
>
  <Group mt="xs">
    <Checkbox value="dark" label="Dark mode" />
    <Checkbox value="notifications" label="Notifications" />
  </Group>
</Checkbox.Group>

// Radio group
<Radio.Group
  label="Payment method"
  value={paymentMethod}
  onChange={setPaymentMethod}
>
  <Group mt="xs">
    <Radio value="card" label="Credit Card" />
    <Radio value="paypal" label="PayPal" />
  </Group>
</Radio.Group>
```

### Switch

```tsx
import { Switch } from '@mantine/core';

<Switch
  label="Enable notifications"
  {...form.getInputProps('notifications', { type: 'checkbox' })}
/>

// With icon
<Switch
  thumbIcon={checked ? <IconCheck size={12} /> : <IconX size={12} />}
/>
```

### Textarea

```tsx
import { Textarea } from '@mantine/core';

<Textarea
  label="Description"
  placeholder="Enter description..."
  minRows={3}
  maxRows={6}
  autosize
/>
```

---

## Feedback Components

### Modal

```tsx
import { Modal, Button } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';

function ModalExample() {
  const [opened, { open, close }] = useDisclosure(false);

  return (
    <>
      <Modal
        opened={opened}
        onClose={close}
        title="Confirm Action"
        centered
        closeButtonLabel="Close dialog"
      >
        <Text>Are you sure you want to proceed?</Text>
        <Group mt="md" justify="flex-end">
          <Button variant="default" onClick={close}>Cancel</Button>
          <Button onClick={handleConfirm}>Confirm</Button>
        </Group>
      </Modal>

      <Button onClick={open}>Open Modal</Button>
    </>
  );
}
```

**Key props:**
- `opened`: Boolean control
- `onClose`: Close handler
- `title`: Header title
- `centered`: Vertically center
- `size`: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | number
- `fullScreen`: Boolean
- `closeOnClickOutside`: Boolean (default: true)
- `closeOnEscape`: Boolean (default: true)

### Drawer

```tsx
import { Drawer } from '@mantine/core';

<Drawer
  opened={opened}
  onClose={close}
  title="Navigation"
  position="left"  // 'left' | 'right' | 'top' | 'bottom'
  size="sm"
>
  <NavContent />
</Drawer>
```

### Notifications (Toast)

```tsx
import { Notifications, notifications } from '@mantine/notifications';

// In app root
<MantineProvider>
  <Notifications position="top-right" />
  <App />
</MantineProvider>

// Show notification
notifications.show({
  title: 'Success',
  message: 'File uploaded successfully',
  color: 'green',
  icon: <IconCheck />,
  autoClose: 5000,
});

// Update existing notification
notifications.update({
  id: 'upload',
  title: 'Upload complete',
  message: 'File is ready',
  color: 'green',
  loading: false,
});

// Clean all
notifications.clean();
```

### Alert

```tsx
import { Alert } from '@mantine/core';
import { IconAlertCircle } from '@tabler/icons-react';

<Alert
  variant="light"
  color="red"
  title="Error"
  icon={<IconAlertCircle />}
  withCloseButton
  onClose={() => setShowAlert(false)}
>
  Something went wrong. Please try again.
</Alert>
```

### Badge

```tsx
import { Badge } from '@mantine/core';

<Badge color="blue" variant="filled">Active</Badge>
<Badge color="red" variant="light">Pending</Badge>
<Badge color="gray" variant="outline">Draft</Badge>

// With dot indicator
<Badge variant="dot" color="green">Online</Badge>
```

---

## Navigation Components

### Tabs

```tsx
import { Tabs } from '@mantine/core';

<Tabs defaultValue="gallery">
  <Tabs.List>
    <Tabs.Tab value="gallery" leftSection={<IconPhoto />}>
      Gallery
    </Tabs.Tab>
    <Tabs.Tab value="messages" leftSection={<IconMessageCircle />}>
      Messages
    </Tabs.Tab>
    <Tabs.Tab value="settings" leftSection={<IconSettings />}>
      Settings
    </Tabs.Tab>
  </Tabs.List>

  <Tabs.Panel value="gallery" pt="md">
    <GalleryContent />
  </Tabs.Panel>
  <Tabs.Panel value="messages" pt="md">
    <MessagesContent />
  </Tabs.Panel>
  <Tabs.Panel value="settings" pt="md">
    <SettingsContent />
  </Tabs.Panel>
</Tabs>
```

### NavLink

```tsx
import { NavLink } from '@mantine/core';

<NavLink
  href="/dashboard"
  label="Dashboard"
  leftSection={<IconDashboard size={16} />}
  active={pathname === '/dashboard'}
/>

// Nested navigation
<NavLink label="Settings" childrenOffset={28}>
  <NavLink label="Account" href="/settings/account" />
  <NavLink label="Security" href="/settings/security" />
</NavLink>
```

### Breadcrumbs

```tsx
import { Breadcrumbs, Anchor } from '@mantine/core';

const items = [
  { title: 'Home', href: '/' },
  { title: 'Products', href: '/products' },
  { title: 'Electronics', href: '/products/electronics' },
].map((item, index) => (
  <Anchor href={item.href} key={index}>
    {item.title}
  </Anchor>
));

<Breadcrumbs separator=">">{items}</Breadcrumbs>
```

### Pagination

```tsx
import { Pagination } from '@mantine/core';

<Pagination
  total={10}
  value={activePage}
  onChange={setPage}
  siblings={1}
  boundaries={1}
  withEdges
/>
```

---

## Data Display Components

### Table

```tsx
import { Table } from '@mantine/core';

// Basic table
<Table>
  <Table.Thead>
    <Table.Tr>
      <Table.Th>Name</Table.Th>
      <Table.Th>Email</Table.Th>
      <Table.Th>Role</Table.Th>
    </Table.Tr>
  </Table.Thead>
  <Table.Tbody>
    {users.map((user) => (
      <Table.Tr key={user.id}>
        <Table.Td>{user.name}</Table.Td>
        <Table.Td>{user.email}</Table.Td>
        <Table.Td>{user.role}</Table.Td>
      </Table.Tr>
    ))}
  </Table.Tbody>
</Table>

// Styled table
<Table
  striped
  highlightOnHover
  withTableBorder
  withColumnBorders
  stickyHeader
  stickyHeaderOffset={60}
>
```

### Skeleton (Loading)

```tsx
import { Skeleton } from '@mantine/core';

// Loading states
<Skeleton height={50} circle mb="xl" />
<Skeleton height={8} radius="xl" />
<Skeleton height={8} mt={6} radius="xl" />
<Skeleton height={8} mt={6} width="70%" radius="xl" />

// Wrap content
<Skeleton visible={loading}>
  <Text>This content is loading...</Text>
</Skeleton>
```

### Timeline

```tsx
import { Timeline, Text } from '@mantine/core';

<Timeline active={1} bulletSize={24} lineWidth={2}>
  <Timeline.Item bullet={<IconCheck size={12} />} title="Order placed">
    <Text c="dimmed" size="sm">Your order has been placed</Text>
    <Text size="xs" mt={4}>2 hours ago</Text>
  </Timeline.Item>
  <Timeline.Item bullet={<IconPackage size={12} />} title="Shipped">
    <Text c="dimmed" size="sm">Package is on the way</Text>
  </Timeline.Item>
  <Timeline.Item bullet={<IconTruck size={12} />} title="Out for delivery">
    <Text c="dimmed" size="sm">Expected today</Text>
  </Timeline.Item>
</Timeline>
```

### Stepper

```tsx
import { Stepper, Button, Group } from '@mantine/core';

function StepperExample() {
  const [active, setActive] = useState(0);

  return (
    <>
      <Stepper active={active} onStepClick={setActive}>
        <Stepper.Step label="Account" description="Create account">
          <AccountForm />
        </Stepper.Step>
        <Stepper.Step label="Profile" description="Set up profile">
          <ProfileForm />
        </Stepper.Step>
        <Stepper.Step label="Complete" description="Review & submit">
          <ReviewForm />
        </Stepper.Step>
        <Stepper.Completed>
          <Text>All steps completed!</Text>
        </Stepper.Completed>
      </Stepper>

      <Group mt="xl">
        <Button variant="default" onClick={() => setActive((c) => c - 1)}>
          Back
        </Button>
        <Button onClick={() => setActive((c) => c + 1)}>
          Next
        </Button>
      </Group>
    </>
  );
}
```

---

## Overlay Components

### Menu

```tsx
import { Menu, Button, ActionIcon } from '@mantine/core';

<Menu shadow="md" width={200}>
  <Menu.Target>
    <Button>Actions</Button>
  </Menu.Target>

  <Menu.Dropdown>
    <Menu.Label>Application</Menu.Label>
    <Menu.Item leftSection={<IconSettings size={14} />}>
      Settings
    </Menu.Item>
    <Menu.Item leftSection={<IconMessageCircle size={14} />}>
      Messages
    </Menu.Item>

    <Menu.Divider />

    <Menu.Label>Danger zone</Menu.Label>
    <Menu.Item color="red" leftSection={<IconTrash size={14} />}>
      Delete account
    </Menu.Item>
  </Menu.Dropdown>
</Menu>
```

### Popover

```tsx
import { Popover, Button, Text } from '@mantine/core';

<Popover width={300} position="bottom" withArrow shadow="md">
  <Popover.Target>
    <Button>Show details</Button>
  </Popover.Target>
  <Popover.Dropdown>
    <Text size="sm">Detailed information goes here...</Text>
  </Popover.Dropdown>
</Popover>
```

### Tooltip

```tsx
import { Tooltip, Button } from '@mantine/core';

<Tooltip label="Save changes">
  <Button>Save</Button>
</Tooltip>

// With arrow and position
<Tooltip label="Help text" position="right" withArrow>
  <ActionIcon><IconHelp /></ActionIcon>
</Tooltip>

// For disabled elements (use data-disabled)
<Tooltip label="You don't have permission">
  <Button data-disabled onClick={(e) => e.preventDefault()}>
    Submit
  </Button>
</Tooltip>
```

---

## Common Props Reference

### Size Props

Most components accept `size` prop:
- `xs`, `sm`, `md` (default), `lg`, `xl`
- Or number value (converted to rem)

### Color Props

```tsx
// Theme colors
color="blue"
color="red.6"  // Shade 6 of red

// CSS colors (where supported)
color="#ff0000"
color="rgb(255, 0, 0)"
```

### Spacing Props

Shorthand props available on most components:
- `m`, `mt`, `mb`, `ml`, `mr`, `mx`, `my` (margin)
- `p`, `pt`, `pb`, `pl`, `pr`, `px`, `py` (padding)

```tsx
<Box p="md" mt="xl" mb="sm">
  Content with spacing
</Box>
```

### Responsive Props

Many props accept responsive objects:

```tsx
<Grid.Col span={{ base: 12, sm: 6, md: 4, lg: 3 }}>
  Responsive column
</Grid.Col>

<Text size={{ base: 'sm', md: 'lg' }}>
  Responsive text
</Text>
```

### Data Attributes

For CSS styling based on state:

```tsx
<Button data-active={isActive}>
  Click me
</Button>
```

```css
.button[data-active] {
  background: blue;
}
```
