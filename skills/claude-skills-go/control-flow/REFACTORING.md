# Control Flow Refactoring Examples

Before and after examples for improving control flow in Go code.

## Example 1: Nested Validation to Guard Clauses

### Before (Deeply Nested)

```go
func (s *Service) CreateTask(ctx context.Context, req *CreateTaskRequest) (*Task, error) {
    if ctx != nil {
        if req != nil {
            if req.Title != "" {
                if req.WorkflowID != "" {
                    if req.ActorID != "" {
                        task := &Task{
                            ID:         generateID(),
                            Title:      req.Title,
                            WorkflowID: req.WorkflowID,
                            ActorID:    req.ActorID,
                            Status:     StatusPending,
                            Priority:   req.Priority,
                            CreatedAt:  time.Now(),
                        }
                        
                        if err := s.store.Save(ctx, task); err != nil {
                            return nil, fmt.Errorf("save task: %w", err)
                        }
                        
                        return task, nil
                    }
                    return nil, errors.New("actor ID is required")
                }
                return nil, errors.New("workflow ID is required")
            }
            return nil, errors.New("title is required")
        }
        return nil, errors.New("request is required")
    }
    return nil, errors.New("context is required")
}
```

### After (Guard Clauses)

```go
func (s *Service) CreateTask(ctx context.Context, req *CreateTaskRequest) (*Task, error) {
    // Guard clauses - all validation upfront
    if ctx == nil {
        return nil, errors.New("context is required")
    }
    if req == nil {
        return nil, errors.New("request is required")
    }
    if req.Title == "" {
        return nil, errors.New("title is required")
    }
    if req.WorkflowID == "" {
        return nil, errors.New("workflow ID is required")
    }
    if req.ActorID == "" {
        return nil, errors.New("actor ID is required")
    }
    
    // Happy path - clean and unindented
    task := &Task{
        ID:         generateID(),
        Title:      req.Title,
        WorkflowID: req.WorkflowID,
        ActorID:    req.ActorID,
        Status:     StatusPending,
        Priority:   req.Priority,
        CreatedAt:  time.Now(),
    }
    
    if err := s.store.Save(ctx, task); err != nil {
        return nil, fmt.Errorf("save task: %w", err)
    }
    
    return task, nil
}
```

---

## Example 2: If-Else Chain to Switch

### Before (If-Else Chain)

```go
func (h *Handler) HandleRequest(ctx context.Context, req Request) (*Response, error) {
    if req.Type == "create" {
        task, err := h.service.Create(ctx, req.Data)
        if err != nil {
            return nil, err
        }
        return &Response{Task: task}, nil
    } else if req.Type == "update" {
        task, err := h.service.Update(ctx, req.ID, req.Data)
        if err != nil {
            return nil, err
        }
        return &Response{Task: task}, nil
    } else if req.Type == "delete" {
        if err := h.service.Delete(ctx, req.ID); err != nil {
            return nil, err
        }
        return &Response{Success: true}, nil
    } else if req.Type == "get" {
        task, err := h.service.Get(ctx, req.ID)
        if err != nil {
            return nil, err
        }
        return &Response{Task: task}, nil
    } else if req.Type == "list" {
        tasks, err := h.service.List(ctx, req.Filter)
        if err != nil {
            return nil, err
        }
        return &Response{Tasks: tasks}, nil
    } else {
        return nil, fmt.Errorf("unknown request type: %s", req.Type)
    }
}
```

### After (Switch Statement)

```go
func (h *Handler) HandleRequest(ctx context.Context, req Request) (*Response, error) {
    switch req.Type {
    case "create":
        return h.handleCreate(ctx, req)
    case "update":
        return h.handleUpdate(ctx, req)
    case "delete":
        return h.handleDelete(ctx, req)
    case "get":
        return h.handleGet(ctx, req)
    case "list":
        return h.handleList(ctx, req)
    default:
        return nil, fmt.Errorf("unknown request type: %s", req.Type)
    }
}

func (h *Handler) handleCreate(ctx context.Context, req Request) (*Response, error) {
    task, err := h.service.Create(ctx, req.Data)
    if err != nil {
        return nil, fmt.Errorf("create: %w", err)
    }
    return &Response{Task: task}, nil
}

func (h *Handler) handleUpdate(ctx context.Context, req Request) (*Response, error) {
    task, err := h.service.Update(ctx, req.ID, req.Data)
    if err != nil {
        return nil, fmt.Errorf("update: %w", err)
    }
    return &Response{Task: task}, nil
}

func (h *Handler) handleDelete(ctx context.Context, req Request) (*Response, error) {
    if err := h.service.Delete(ctx, req.ID); err != nil {
        return nil, fmt.Errorf("delete: %w", err)
    }
    return &Response{Success: true}, nil
}

func (h *Handler) handleGet(ctx context.Context, req Request) (*Response, error) {
    task, err := h.service.Get(ctx, req.ID)
    if err != nil {
        return nil, fmt.Errorf("get: %w", err)
    }
    return &Response{Task: task}, nil
}

func (h *Handler) handleList(ctx context.Context, req Request) (*Response, error) {
    tasks, err := h.service.List(ctx, req.Filter)
    if err != nil {
        return nil, fmt.Errorf("list: %w", err)
    }
    return &Response{Tasks: tasks}, nil
}
```

---

## Example 3: Nested Loops to Functions

### Before (Nested Loops)

```go
func processOrders(orders []Order, inventory map[string]int) ([]ProcessedOrder, error) {
    var results []ProcessedOrder
    
    for _, order := range orders {
        if order.Status == "pending" {
            var processedItems []ProcessedItem
            allAvailable := true
            
            for _, item := range order.Items {
                if item.Quantity > 0 {
                    available, ok := inventory[item.SKU]
                    if ok && available >= item.Quantity {
                        processedItems = append(processedItems, ProcessedItem{
                            SKU:      item.SKU,
                            Quantity: item.Quantity,
                            Price:    item.Price,
                            Total:    float64(item.Quantity) * item.Price,
                        })
                    } else {
                        allAvailable = false
                        break
                    }
                }
            }
            
            if allAvailable && len(processedItems) > 0 {
                var total float64
                for _, pi := range processedItems {
                    total += pi.Total
                    inventory[pi.SKU] -= pi.Quantity
                }
                
                results = append(results, ProcessedOrder{
                    OrderID: order.ID,
                    Items:   processedItems,
                    Total:   total,
                })
            }
        }
    }
    
    return results, nil
}
```

### After (Extracted Functions)

```go
func processOrders(orders []Order, inventory map[string]int) ([]ProcessedOrder, error) {
    var results []ProcessedOrder
    
    for _, order := range orders {
        processed, err := processOrder(order, inventory)
        if err != nil {
            continue // Skip orders that can't be processed
        }
        if processed != nil {
            results = append(results, *processed)
        }
    }
    
    return results, nil
}

func processOrder(order Order, inventory map[string]int) (*ProcessedOrder, error) {
    if order.Status != "pending" {
        return nil, nil
    }
    
    items, err := processItems(order.Items, inventory)
    if err != nil {
        return nil, err
    }
    if len(items) == 0 {
        return nil, nil
    }
    
    total := calculateTotal(items)
    deductInventory(items, inventory)
    
    return &ProcessedOrder{
        OrderID: order.ID,
        Items:   items,
        Total:   total,
    }, nil
}

func processItems(items []Item, inventory map[string]int) ([]ProcessedItem, error) {
    var processed []ProcessedItem
    
    for _, item := range items {
        pi, ok := processItem(item, inventory)
        if !ok {
            return nil, fmt.Errorf("item %s not available", item.SKU)
        }
        if pi != nil {
            processed = append(processed, *pi)
        }
    }
    
    return processed, nil
}

func processItem(item Item, inventory map[string]int) (*ProcessedItem, bool) {
    if item.Quantity <= 0 {
        return nil, true
    }
    
    available, ok := inventory[item.SKU]
    if !ok || available < item.Quantity {
        return nil, false
    }
    
    return &ProcessedItem{
        SKU:      item.SKU,
        Quantity: item.Quantity,
        Price:    item.Price,
        Total:    float64(item.Quantity) * item.Price,
    }, true
}

func calculateTotal(items []ProcessedItem) float64 {
    var total float64
    for _, item := range items {
        total += item.Total
    }
    return total
}

func deductInventory(items []ProcessedItem, inventory map[string]int) {
    for _, item := range items {
        inventory[item.SKU] -= item.Quantity
    }
}
```

---

## Example 4: Complex Boolean Logic

### Before (Nested Conditionals)

```go
func shouldProcess(task *Task, user *User) bool {
    if task != nil {
        if task.Status == StatusPending {
            if user != nil {
                if user.Role == RoleAdmin {
                    return true
                } else if user.Role == RoleManager {
                    if task.Priority >= PriorityHigh {
                        return true
                    }
                } else if user.ID == task.AssigneeID {
                    return true
                }
            }
        }
    }
    return false
}
```

### After (Switch True)

```go
func shouldProcess(task *Task, user *User) bool {
    if task == nil || user == nil {
        return false
    }
    if task.Status != StatusPending {
        return false
    }
    
    switch {
    case user.Role == RoleAdmin:
        return true
    case user.Role == RoleManager && task.Priority >= PriorityHigh:
        return true
    case user.ID == task.AssigneeID:
        return true
    default:
        return false
    }
}
```

---

## Example 5: Error Handling in Loops

### Before (Scattered Error Handling)

```go
func processBatch(ctx context.Context, tasks []*Task) error {
    for i, task := range tasks {
        if task == nil {
            continue
        }
        
        if err := validate(task); err != nil {
            return fmt.Errorf("task %d validation: %w", i, err)
        }
        
        metadata, err := fetchMetadata(ctx, task.ID)
        if err != nil {
            return fmt.Errorf("task %d metadata: %w", i, err)
        }
        
        if metadata != nil {
            if err := applyMetadata(task, metadata); err != nil {
                return fmt.Errorf("task %d apply metadata: %w", i, err)
            }
        }
        
        if err := save(ctx, task); err != nil {
            return fmt.Errorf("task %d save: %w", i, err)
        }
    }
    return nil
}
```

### After (Extracted with Clear Flow)

```go
func processBatch(ctx context.Context, tasks []*Task) error {
    for i, task := range tasks {
        if task == nil {
            continue
        }
        
        if err := processTask(ctx, task); err != nil {
            return fmt.Errorf("task %d (%s): %w", i, task.ID, err)
        }
    }
    return nil
}

func processTask(ctx context.Context, task *Task) error {
    if err := validate(task); err != nil {
        return fmt.Errorf("validate: %w", err)
    }
    
    if err := enrichWithMetadata(ctx, task); err != nil {
        return fmt.Errorf("enrich: %w", err)
    }
    
    if err := save(ctx, task); err != nil {
        return fmt.Errorf("save: %w", err)
    }
    
    return nil
}

func enrichWithMetadata(ctx context.Context, task *Task) error {
    metadata, err := fetchMetadata(ctx, task.ID)
    if err != nil {
        return fmt.Errorf("fetch: %w", err)
    }
    
    if metadata == nil {
        return nil
    }
    
    if err := applyMetadata(task, metadata); err != nil {
        return fmt.Errorf("apply: %w", err)
    }
    
    return nil
}
```

---

## Example 6: Defer Cleanup Pattern

### Before (Manual Cleanup)

```go
func processWithResources(ctx context.Context, id rms.ID) (*Result, error) {
    lock, err := acquireLock(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("acquire lock: %w", err)
    }
    
    conn, err := getConnection(ctx)
    if err != nil {
        lock.Release()
        return nil, fmt.Errorf("get connection: %w", err)
    }
    
    tx, err := conn.BeginTx(ctx, nil)
    if err != nil {
        conn.Close()
        lock.Release()
        return nil, fmt.Errorf("begin tx: %w", err)
    }
    
    result, err := doWork(ctx, tx, id)
    if err != nil {
        tx.Rollback()
        conn.Close()
        lock.Release()
        return nil, fmt.Errorf("do work: %w", err)
    }
    
    if err := tx.Commit(); err != nil {
        conn.Close()
        lock.Release()
        return nil, fmt.Errorf("commit: %w", err)
    }
    
    conn.Close()
    lock.Release()
    
    return result, nil
}
```

### After (Defer Cleanup)

```go
func processWithResources(ctx context.Context, id rms.ID) (*Result, error) {
    lock, err := acquireLock(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("acquire lock: %w", err)
    }
    defer lock.Release()
    
    conn, err := getConnection(ctx)
    if err != nil {
        return nil, fmt.Errorf("get connection: %w", err)
    }
    defer conn.Close()
    
    tx, err := conn.BeginTx(ctx, nil)
    if err != nil {
        return nil, fmt.Errorf("begin tx: %w", err)
    }
    
    result, err := doWork(ctx, tx, id)
    if err != nil {
        tx.Rollback()
        return nil, fmt.Errorf("do work: %w", err)
    }
    
    if err := tx.Commit(); err != nil {
        return nil, fmt.Errorf("commit: %w", err)
    }
    
    return result, nil
}
```

---

## Refactoring Checklist

When refactoring control flow:

1. **Identify nesting levels** - Count indentation levels (aim for ≤3)
2. **Find guard clauses** - Move validation to function start
3. **Look for if-else chains** - Convert to switch (3+ conditions)
4. **Find nested loops** - Extract inner logic to functions
5. **Check defer usage** - Ensure cleanup is consistent
6. **Verify early returns** - Handle errors immediately
7. **Test after refactoring** - Behavior should be unchanged
