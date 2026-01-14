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

