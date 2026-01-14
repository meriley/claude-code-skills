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

