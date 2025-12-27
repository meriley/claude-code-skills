---
name: vendure-admin-ui-writing
description: Create Vendure Admin UI extensions with React components, route registration, navigation menus, and GraphQL integration. Handles useQuery, useMutation, useInjector patterns. Use when building Admin UI features for Vendure plugins.
version: 1.0.0
---

# Vendure Admin UI Writing

## Purpose

Guide creation of Vendure Admin UI extensions following React patterns and official conventions.

## When to Use

- Adding custom admin pages to a plugin
- Creating list/detail/form components
- Registering navigation menu items
- Building data tables with CRUD operations
- Integrating GraphQL queries and mutations

## When NOT to Use

- Plugin structure only (use vendure-plugin-writing)
- GraphQL schema only (use vendure-graphql-writing)
- Reviewing UI code (use vendure-admin-ui-reviewing)

---

## FORBIDDEN Patterns

- Using Angular patterns (Vendure v2+ uses React)
- Direct fetch calls (use Vendure GraphQL hooks)
- Missing useInjector for services
- Hardcoded routes without registerReactRouteComponent
- Missing page metadata (title, breadcrumbs)
- Inline styles without CSS variables
- Missing loading and error states
- Direct DOM manipulation

---

## REQUIRED Patterns

- `@vendure/admin-ui/react` hooks for data fetching
- `useInjector(NotificationService)` for notifications
- `usePageMetadata()` for titles and breadcrumbs
- `registerReactRouteComponent()` for routes
- `addNavMenuSection()` for navigation
- Proper TypeScript types from generated GraphQL
- Loading states for async operations
- Error handling with user feedback

---

## Workflow

### Step 1: Create UI Extension Entry Point

```typescript
// ui/index.ts
import path from "path";
import { AdminUiExtension } from "@vendure/ui-devkit/compiler";

export const myPluginUiExtension: AdminUiExtension = {
  id: "my-plugin-ui",
  extensionPath: path.join(__dirname),
  routes: [
    {
      route: "my-plugin",
      filePath: "routes.ts",
    },
  ],
  providers: ["providers.ts"],
  translations: {
    en: path.join(__dirname, "translations/en.json"),
  },
};
```

### Step 2: Register Navigation Menu

```typescript
// ui/providers.ts
import { addNavMenuSection } from "@vendure/admin-ui/core";

export default [
  addNavMenuSection(
    {
      id: "my-plugin",
      label: "My Plugin",
      items: [
        {
          id: "my-items",
          label: "Items",
          routerLink: ["/extensions/my-plugin/items"],
          icon: "list",
        },
        {
          id: "my-settings",
          label: "Settings",
          routerLink: ["/extensions/my-plugin/settings"],
          icon: "cog",
        },
      ],
    },
    "settings",
  ), // Position after 'settings' section
];
```

### Step 3: Register Routes

```typescript
// ui/routes.ts
import { registerReactRouteComponent } from "@vendure/admin-ui/react";

import { ItemList } from "./components/ItemList";
import { ItemDetail } from "./components/ItemDetail";
import { ItemForm } from "./components/ItemForm";

export default [
  registerReactRouteComponent({
    component: ItemList,
    path: "items",
    title: "Items",
    breadcrumb: "Items",
  }),
  registerReactRouteComponent({
    component: ItemDetail,
    path: "items/:id",
    title: "Item Details",
    breadcrumb: "Details",
  }),
  registerReactRouteComponent({
    component: ItemForm,
    path: "items/new",
    title: "New Item",
    breadcrumb: "New",
  }),
];
```

### Step 4: Create List Component

```typescript
// ui/components/ItemList.tsx
import { NotificationService } from '@vendure/admin-ui/core';
import {
    Card,
    ActionBar,
    Link,
    usePageMetadata,
    PageBlock,
    useQuery,
    useMutation,
    useInjector
} from '@vendure/admin-ui/react';
import * as React from 'react';

import { GET_ITEMS, DELETE_ITEM } from '../graphql';
import { GetItemsQuery, DeleteItemMutation } from '../gql/graphql';

export function ItemList() {
    const { setTitle, setBreadcrumb } = usePageMetadata();
    const notificationService = useInjector(NotificationService);

    // Pagination state
    const [currentPage, setCurrentPage] = React.useState(1);
    const [itemsPerPage] = React.useState(25);

    // Set page metadata
    React.useEffect(() => {
        setTitle('Items');
        setBreadcrumb([
            { label: 'My Plugin', link: ['/extensions/my-plugin'] },
            { label: 'Items', link: ['/extensions/my-plugin/items'] }
        ]);
    }, [setTitle, setBreadcrumb]);

    // Query
    const { data, loading, error, refetch } = useQuery<GetItemsQuery>(GET_ITEMS, {
        variables: {
            options: {
                skip: (currentPage - 1) * itemsPerPage,
                take: itemsPerPage,
            }
        }
    });

    // Delete mutation
    const [deleteItem] = useMutation<DeleteItemMutation>(DELETE_ITEM);

    const handleDelete = React.useCallback(async (id: string) => {
        try {
            await deleteItem({ input: { id } });
            notificationService.success('Item deleted');
            await refetch();
        } catch {
            notificationService.error('Failed to delete item');
        }
    }, [deleteItem, notificationService, refetch]);

    if (loading) return <div>Loading...</div>;
    if (error) return <div>Error: {error.message}</div>;

    return (
        <PageBlock>
            <ActionBar>
                <div className="action-bar-start">
                    <h1>Items</h1>
                </div>
                <div className="action-bar-end">
                    <Link href="/extensions/my-plugin/items/new">
                        <button className="button primary">Add Item</button>
                    </Link>
                </div>
            </ActionBar>

            <Card>
                <table className="data-table">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Created</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {data?.items.items.map(item => (
                            <tr key={item.id}>
                                <td>{item.name}</td>
                                <td>{new Date(item.createdAt).toLocaleDateString()}</td>
                                <td>
                                    <Link href={`/extensions/my-plugin/items/${item.id}`}>
                                        Edit
                                    </Link>
                                    <button onClick={() => void handleDelete(item.id)}>
                                        Delete
                                    </button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </Card>
        </PageBlock>
    );
}
```

### Step 5: Create Detail/Form Component

```typescript
// ui/components/ItemDetail.tsx
import { NotificationService } from '@vendure/admin-ui/core';
import {
    usePageMetadata,
    PageBlock,
    useQuery,
    useMutation,
    useInjector,
    useRouteParams
} from '@vendure/admin-ui/react';
import * as React from 'react';

import { GET_ITEM, UPDATE_ITEM } from '../graphql';

export function ItemDetail() {
    const { setTitle, setBreadcrumb } = usePageMetadata();
    const notificationService = useInjector(NotificationService);
    const { id } = useRouteParams();

    const [name, setName] = React.useState('');

    // Query
    const { data, loading, error } = useQuery(GET_ITEM, {
        variables: { id }
    });

    // Mutation
    const [updateItem, { loading: saving }] = useMutation(UPDATE_ITEM);

    // Populate form when data loads
    React.useEffect(() => {
        if (data?.item) {
            setName(data.item.name);
            setTitle(data.item.name);
            setBreadcrumb([
                { label: 'Items', link: ['/extensions/my-plugin/items'] },
                { label: data.item.name, link: [] }
            ]);
        }
    }, [data, setTitle, setBreadcrumb]);

    const handleSubmit = React.useCallback(async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            await updateItem({ input: { id, name } });
            notificationService.success('Item updated');
        } catch {
            notificationService.error('Failed to update item');
        }
    }, [id, name, updateItem, notificationService]);

    if (loading) return <div>Loading...</div>;
    if (error) return <div>Error: {error.message}</div>;

    return (
        <PageBlock>
            <form onSubmit={(e) => void handleSubmit(e)}>
                <div className="form-group">
                    <label htmlFor="name">Name</label>
                    <input
                        id="name"
                        type="text"
                        value={name}
                        onChange={e => setName(e.target.value)}
                        required
                    />
                </div>
                <button type="submit" disabled={saving}>
                    {saving ? 'Saving...' : 'Save'}
                </button>
            </form>
        </PageBlock>
    );
}
```

### Step 6: Set Up GraphQL Queries

```typescript
// ui/graphql/queries.ts
import { gql } from "graphql-tag";

export const GET_ITEMS = gql`
  query GetItems($options: ItemListOptions) {
    items(options: $options) {
      items {
        id
        name
        createdAt
        updatedAt
      }
      totalItems
    }
  }
`;

export const GET_ITEM = gql`
  query GetItem($id: ID!) {
    item(id: $id) {
      id
      name
      createdAt
      updatedAt
    }
  }
`;
```

```typescript
// ui/graphql/mutations.ts
import { gql } from "graphql-tag";

export const CREATE_ITEM = gql`
  mutation CreateItem($input: CreateItemInput!) {
    createItem(input: $input) {
      id
      name
    }
  }
`;

export const UPDATE_ITEM = gql`
  mutation UpdateItem($input: UpdateItemInput!) {
    updateItem(input: $input) {
      id
      name
    }
  }
`;

export const DELETE_ITEM = gql`
  mutation DeleteItem($input: DeleteItemInput!) {
    deleteItem(input: $input)
  }
`;
```

### Step 7: Configure GraphQL Codegen

```yaml
# ui/codegen.yml
schema: http://localhost:3000/admin-api
documents: "./ui/graphql/**/*.ts"
generates:
  ./ui/gql/graphql.ts:
    plugins:
      - typescript
      - typescript-operations
    config:
      avoidOptionals: true
      maybeValue: T | null
```

---

## Common Patterns

### Custom Hook for Domain Operations

```typescript
// ui/hooks/useItems.ts
import { useQuery, useMutation, useInjector } from "@vendure/admin-ui/react";
import { NotificationService } from "@vendure/admin-ui/core";
import { useMemo, useCallback, useState } from "react";

import { GET_ITEMS, CREATE_ITEM, UPDATE_ITEM, DELETE_ITEM } from "../graphql";

export function useItems() {
  const notificationService = useInjector(NotificationService);
  const [loading, setLoading] = useState(false);

  const itemsQuery = useQuery(GET_ITEMS);
  const [createItem] = useMutation(CREATE_ITEM);
  const [updateItem] = useMutation(UPDATE_ITEM);
  const [deleteItem] = useMutation(DELETE_ITEM);

  const operations = useMemo(
    () => ({
      create: async (input: { name: string }) => {
        try {
          setLoading(true);
          const result = await createItem({ input });
          notificationService.success("Item created");
          await itemsQuery.refetch();
          return result;
        } catch {
          notificationService.error("Failed to create item");
          throw new Error("Create failed");
        } finally {
          setLoading(false);
        }
      },

      update: async (id: string, input: { name?: string }) => {
        try {
          setLoading(true);
          const result = await updateItem({ input: { id, ...input } });
          notificationService.success("Item updated");
          await itemsQuery.refetch();
          return result;
        } catch {
          notificationService.error("Failed to update item");
          throw new Error("Update failed");
        } finally {
          setLoading(false);
        }
      },

      delete: async (id: string) => {
        try {
          setLoading(true);
          await deleteItem({ input: { id } });
          notificationService.success("Item deleted");
          await itemsQuery.refetch();
          return true;
        } catch {
          notificationService.error("Failed to delete item");
          throw new Error("Delete failed");
        } finally {
          setLoading(false);
        }
      },
    }),
    [createItem, updateItem, deleteItem, notificationService, itemsQuery],
  );

  return {
    items: itemsQuery.data?.items.items ?? [],
    loading: loading || itemsQuery.loading,
    error: itemsQuery.error,
    refetch: itemsQuery.refetch,
    ...operations,
  };
}
```

### Confirmation Dialog

```typescript
// ui/components/common/ConfirmDialog.tsx
import { Card } from '@vendure/admin-ui/react';
import * as React from 'react';

interface ConfirmDialogProps {
    open: boolean;
    title: string;
    message: string;
    confirmLabel?: string;
    cancelLabel?: string;
    onConfirm: () => void;
    onCancel: () => void;
    loading?: boolean;
}

export function ConfirmDialog({
    open,
    title,
    message,
    confirmLabel = 'Confirm',
    cancelLabel = 'Cancel',
    onConfirm,
    onCancel,
    loading = false,
}: ConfirmDialogProps) {
    if (!open) return null;

    return (
        <>
            <div className="dialog-backdrop" onClick={onCancel} />
            <div className="dialog">
                <Card>
                    <div className="dialog-header">
                        <h3>{title}</h3>
                    </div>
                    <div className="dialog-body">
                        <p>{message}</p>
                    </div>
                    <div className="dialog-actions">
                        <button onClick={onCancel} disabled={loading}>
                            {cancelLabel}
                        </button>
                        <button
                            className="danger"
                            onClick={onConfirm}
                            disabled={loading}
                        >
                            {loading ? 'Processing...' : confirmLabel}
                        </button>
                    </div>
                </Card>
            </div>
        </>
    );
}
```

### CSS Variables (Vendure Theme)

```css
/* Use Vendure CSS variables for consistent theming */
.my-component {
  /* Colors */
  background-color: var(--color-white);
  border: 1px solid var(--color-grey-200);
  color: var(--color-grey-900);

  /* Primary colors */
  --primary: var(--color-primary-600);
  --primary-hover: var(--color-primary-700);

  /* Spacing */
  padding: var(--space-4);
  margin: var(--space-2);
  gap: var(--space-3);

  /* Typography */
  font-size: var(--font-size-sm);
  font-weight: 500;

  /* Border radius */
  border-radius: var(--border-radius);
}

.button.primary {
  background-color: var(--color-primary-600);
  color: white;
}

.button.primary:hover {
  background-color: var(--color-primary-700);
}

.button.danger {
  background-color: var(--color-danger-600);
  color: white;
}
```

---

## Examples

### Example 1: Data Table with Pagination

```typescript
export function PaginatedTable() {
    const [page, setPage] = React.useState(1);
    const [perPage, setPerPage] = React.useState(25);

    const { data, loading } = useQuery(GET_ITEMS, {
        variables: {
            options: {
                skip: (page - 1) * perPage,
                take: perPage,
            }
        }
    });

    const totalPages = Math.ceil((data?.items.totalItems ?? 0) / perPage);

    return (
        <div>
            <table className="data-table">
                {/* ... table content ... */}
            </table>

            <div className="pagination">
                <select
                    value={perPage}
                    onChange={e => setPerPage(Number(e.target.value))}
                >
                    <option value="10">10</option>
                    <option value="25">25</option>
                    <option value="50">50</option>
                </select>

                <button
                    onClick={() => setPage(p => p - 1)}
                    disabled={page === 1}
                >
                    Previous
                </button>
                <span>Page {page} of {totalPages}</span>
                <button
                    onClick={() => setPage(p => p + 1)}
                    disabled={page === totalPages}
                >
                    Next
                </button>
            </div>
        </div>
    );
}
```

### Example 2: Form with Validation

```typescript
export function ItemForm() {
    const [name, setName] = React.useState('');
    const [errors, setErrors] = React.useState<Record<string, string>>({});
    const notificationService = useInjector(NotificationService);
    const [createItem, { loading }] = useMutation(CREATE_ITEM);

    const validate = () => {
        const newErrors: Record<string, string> = {};
        if (!name.trim()) newErrors.name = 'Name is required';
        if (name.length > 100) newErrors.name = 'Name too long';
        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!validate()) return;

        try {
            await createItem({ input: { name } });
            notificationService.success('Item created');
            // Navigate back to list
        } catch {
            notificationService.error('Failed to create item');
        }
    };

    return (
        <form onSubmit={(e) => void handleSubmit(e)}>
            <div className="form-group">
                <label htmlFor="name">Name *</label>
                <input
                    id="name"
                    type="text"
                    value={name}
                    onChange={e => setName(e.target.value)}
                    className={errors.name ? 'error' : ''}
                />
                {errors.name && <span className="error-text">{errors.name}</span>}
            </div>
            <button type="submit" disabled={loading}>
                {loading ? 'Creating...' : 'Create'}
            </button>
        </form>
    );
}
```

---

## Project Structure

```
ui/
├── index.ts              # AdminUiExtension entry point
├── providers.ts          # Navigation registration
├── routes.ts             # Route registration
├── codegen.yml           # GraphQL codegen config
├── components/
│   ├── ItemList.tsx
│   ├── ItemDetail.tsx
│   ├── ItemForm.tsx
│   └── common/
│       ├── ConfirmDialog.tsx
│       └── LoadingState.tsx
├── graphql/
│   ├── index.ts          # Re-exports
│   ├── queries.ts
│   ├── mutations.ts
│   └── fragments.ts
├── gql/
│   └── graphql.ts        # Generated types
├── hooks/
│   └── useItems.ts
├── styles/
│   └── common.css
└── translations/
    └── en.json
```

---

## Troubleshooting

| Problem                  | Cause                   | Solution                                          |
| ------------------------ | ----------------------- | ------------------------------------------------- |
| Component not rendering  | Route not registered    | Add to routes.ts with registerReactRouteComponent |
| Nav item missing         | Provider not loaded     | Add to providers.ts, ensure exported as default   |
| Query returns undefined  | Missing generated types | Run graphql-codegen                               |
| Notification not showing | Missing useInjector     | Use useInjector(NotificationService)              |
| Page title wrong         | Missing usePageMetadata | Call setTitle in useEffect                        |

---

## Related Skills

- **vendure-admin-ui-reviewing** - UI review
- **vendure-plugin-writing** - Plugin structure
- **vendure-graphql-writing** - GraphQL schema
