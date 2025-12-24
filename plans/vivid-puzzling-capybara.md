# Responsive Navigation System Implementation

## Status: PLANNING

## Pre-Implementation: Move Specs to docs/

**Current location:** `.plan/navigation-refactor/`
**Target location:** `docs/product-specs/navigation-system/`

Files to move:
- `PRD.md` → `docs/product-specs/navigation-system/PRD.md`
- `FEATURE_SPEC.md` → `docs/product-specs/navigation-system/FEATURE_SPEC.md`
- `TECHNICAL_SPEC.md` → `docs/product-specs/navigation-system/TECHNICAL_SPEC.md`

---

## Overview

Implement a unified AppShell-based navigation system using Mantine 7.x to replace scattered inline headers. Mobile-first design with hamburger drawer and ABAC-filtered navigation items.

**Priority**: P1
**Effort**: Medium (1-2 weeks)
**Specs**: `.plan/navigation-refactor/` (PRD.md, FEATURE_SPEC.md, TECHNICAL_SPEC.md)

---

## Current State

- **8 route pages** with inline headers (~300 lines duplicated code)
- **No mobile navigation** - buttons wrap horizontally on small screens
- **Scattered ABAC logic** - Dashboard has inline role checks
- **No breadcrumbs** - users lose context on nested pages
- **Flat routing** - all routes directly under `<Routes>`

---

## Target Architecture

```
src/
├── types/
│   └── navigation.ts          # NavItem, NavSection, BreadcrumbItem types
├── config/
│   ├── navigation.ts          # Navigation items with ABAC permissions
│   └── breadcrumbs.ts         # Route-to-breadcrumb mapping
├── hooks/
│   ├── useNavigation.ts       # ABAC filtering, drawer state
│   └── useBreadcrumbs.ts      # Breadcrumb trail generation
├── layouts/
│   ├── AppLayout.tsx          # Main layout with AppShell
│   └── AuthLayout.tsx         # Login/register layout (no nav)
├── components/navigation/
│   ├── NavigationHeader.tsx   # Burger + logo + breadcrumbs + user menu
│   ├── NavigationSidebar.tsx  # Sidebar nav items
│   ├── NavItemLink.tsx        # Individual nav item
│   ├── AppBreadcrumbs.tsx     # Responsive breadcrumbs
│   └── UserMenu.tsx           # User dropdown with logout
└── App.tsx                    # Updated with nested routes
```

---

## Implementation Plan

### Phase 1: Foundation (Types, Config, Hooks)

**1.1 Create Types** (`src/types/navigation.ts`)
```typescript
type NavItemPermission =
  | { type: 'authenticated' }
  | { type: 'admin' }
  | { type: 'groupRole'; roles: ('owner' | 'moderator')[] };

interface NavItem {
  id: string;
  label: string;
  path: string;
  icon: React.ComponentType;
  permission: NavItemPermission;
  badge?: { key: 'invitations' | 'pendingApprovals' };
}
```

**1.2 Create Navigation Config** (`src/config/navigation.ts`)
- Define all nav items with paths, icons, permissions
- Group into sections (Main, Administration)

**1.3 Create Breadcrumb Config** (`src/config/breadcrumbs.ts`)
- Static route-to-label mapping
- Dynamic segment handlers (`:groupId`, `:mediaId`)

**1.4 Create Hooks**
- `useNavigation()` - Filter nav items by user role, manage drawer state
- `useBreadcrumbs()` - Generate breadcrumb trail from current route

### Phase 2: Layout Components

**2.1 Create AppLayout** (`src/layouts/AppLayout.tsx`)
- Mantine AppShell with header (48px mobile, 60px desktop) + sidebar (280px)
- React Router `<Outlet />` for nested routes
- Responsive breakpoint at `sm` (576px)

**2.2 Create AuthLayout** (`src/layouts/AuthLayout.tsx`)
- Simple centered layout for login/register
- No navigation sidebar

**2.3 Create NavigationHeader** (`src/components/navigation/NavigationHeader.tsx`)
- Burger menu (mobile only)
- Logo/app name
- Breadcrumbs (desktop: full trail, mobile: "< Back | Current")
- User menu

**2.4 Create NavigationSidebar** (`src/components/navigation/NavigationSidebar.tsx`)
- Nav sections with items
- Active state indication
- ABAC-filtered items

**2.5 Create Supporting Components**
- `NavItemLink.tsx` - Individual nav link with icon, active state
- `AppBreadcrumbs.tsx` - Responsive breadcrumb component
- `UserMenu.tsx` - Avatar dropdown with logout

### Phase 3: Route Integration

**3.1 Update App.tsx**
- Wrap authenticated routes in `<AppLayout>`
- Wrap auth routes in `<AuthLayout>`
- Use nested route structure with `<Outlet />`

**3.2 Update Route Pages** (8 files)
- Remove inline headers from each page
- Remove duplicate ABAC logic
- Remove individual logout buttons
- Pages become content-only

Files to modify:
- `src/routes/Dashboard.tsx`
- `src/routes/Upload.tsx`
- `src/routes/MediaCatalog.tsx`
- `src/routes/MediaDetailPage.tsx`
- `src/routes/GroupsListPage.tsx`
- `src/routes/GroupDetailPage.tsx`
- `src/routes/ApprovalQueue.tsx`
- `src/routes/QuarantineManager.tsx`

### Phase 4: Testing & Polish

**4.1 Unit Tests**
- `useNavigation.test.ts` - ABAC filtering logic (90%+ coverage)
- `useBreadcrumbs.test.ts` - Breadcrumb generation (90%+ coverage)

**4.2 Integration Tests**
- Navigation renders correct items per role
- Drawer opens/closes on mobile
- Active state updates on navigation

**4.3 Final Verification**
- All routes accessible
- Mobile drawer works
- ABAC filtering correct
- Breadcrumbs show on all pages
- `npm run lint` passes
- `npm run build` passes
- `npm run test:run` passes

---

## Files to Create (12 new files)

| File | Purpose |
|------|---------|
| `src/types/navigation.ts` | Type definitions |
| `src/config/navigation.ts` | Nav items config |
| `src/config/breadcrumbs.ts` | Breadcrumb config |
| `src/hooks/useNavigation.ts` | ABAC filtering hook |
| `src/hooks/useBreadcrumbs.ts` | Breadcrumb hook |
| `src/layouts/AppLayout.tsx` | Main app layout |
| `src/layouts/AuthLayout.tsx` | Auth pages layout |
| `src/components/navigation/NavigationHeader.tsx` | Header component |
| `src/components/navigation/NavigationSidebar.tsx` | Sidebar component |
| `src/components/navigation/NavItemLink.tsx` | Nav item component |
| `src/components/navigation/AppBreadcrumbs.tsx` | Breadcrumbs component |
| `src/components/navigation/UserMenu.tsx` | User menu component |

## Files to Modify (9 existing files)

| File | Changes |
|------|---------|
| `src/App.tsx` | Nested routes with layout wrappers |
| `src/routes/Dashboard.tsx` | Remove header (~70 lines) |
| `src/routes/Upload.tsx` | Remove header (~30 lines) |
| `src/routes/MediaCatalog.tsx` | Remove header (~20 lines) |
| `src/routes/MediaDetailPage.tsx` | Remove header (~20 lines) |
| `src/routes/GroupsListPage.tsx` | Remove header (~20 lines) |
| `src/routes/GroupDetailPage.tsx` | Remove header (~20 lines) |
| `src/routes/ApprovalQueue.tsx` | Remove header (~20 lines) |
| `src/routes/QuarantineManager.tsx` | Remove header (~20 lines) |

---

## Success Criteria

- [ ] AppShell layout renders correctly on desktop and mobile
- [ ] Mobile drawer opens/closes smoothly (200ms animation)
- [ ] ABAC filtering hides unauthorized nav items
- [ ] Breadcrumbs show on all pages with correct hierarchy
- [ ] All inline headers removed from route pages
- [ ] Touch targets >= 48px on mobile
- [ ] Active state visible for current page
- [ ] User can logout from user menu
- [ ] `npm run lint` passes
- [ ] `npm run build` passes
- [ ] `npm run test:run` passes
- [ ] 90%+ test coverage on hooks

---

## Technical Notes

### ABAC Permission Logic

```typescript
// From existing Dashboard.tsx pattern:
const canApproveRequests = user?.role === 'admin' ||
  user?.groups?.some(g => g.role === 'owner' || g.role === 'moderator');

// Should become centralized in useNavigation:
function filterNavItems(items: NavItem[], user: User | null): NavItem[] {
  return items.filter(item => {
    switch (item.permission.type) {
      case 'authenticated': return !!user;
      case 'admin': return user?.role === 'admin';
      case 'groupRole': return user?.groups?.some(
        g => item.permission.roles.includes(g.role)
      );
    }
  });
}
```

### Mantine AppShell Structure

```tsx
<AppShell
  header={{ height: { base: 48, sm: 60 } }}
  navbar={{ width: 280, breakpoint: 'sm', collapsed: { mobile: !opened } }}
>
  <AppShell.Header>
    <NavigationHeader opened={opened} toggle={toggle} />
  </AppShell.Header>
  <AppShell.Navbar>
    <NavigationSidebar />
  </AppShell.Navbar>
  <AppShell.Main>
    <Outlet />
  </AppShell.Main>
</AppShell>
```

---

## Dependencies

- Mantine 7.x (already installed)
- React Router 7 (already installed)
- @tabler/icons-react (already installed)
- AuthContext with user roles (complete)

## Risks

- **Route structure change** - Must update all route imports; test thoroughly
- **State management** - Drawer state needs to persist across navigations
- **Breadcrumb edge cases** - Dynamic routes (`:groupId`) need special handling
