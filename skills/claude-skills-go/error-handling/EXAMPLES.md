# Error Handling Examples

Extended examples for RMS Go error handling patterns.

## Service Layer Error Handling

### CRUD Operations

```go
// Complete service with proper error handling
type TaskService struct {
    store     TaskStore
    factory   *TaskFactory
    publisher EventPublisher
    logger    rms.Logger
}

func (s *TaskService) Create(ctx context.Context, params CreateTaskParams) (*Task, error) {
    // Validate input
    if err := params.Validate(); err != nil {
        return nil, fmt.Errorf("validate params: %w", err)
    }
    
    // Create task
    task, err := s.factory.Create(params)
    if err != nil {
        return nil, fmt.Errorf("create task: %w", err)
    }
    
    // Persist
    if err := s.store.Save(ctx, task); err != nil {
        return nil, fmt.Errorf("save task: %w", err)
    }
    
    // Publish event (best effort - log and continue)
    if err := s.publisher.Publish(ctx, TaskCreatedEvent{Task: task}); err != nil {
        s.logger.Error("publish task created event", "taskID", task.ID, "error", err)
        // Don't fail the create - task is already saved
    }
    
    return task, nil
}

func (s *TaskService) Get(ctx context.Context, id rms.ID) (*Task, error) {
    task, err := s.store.Get(ctx, id)
    if errors.Is(err, ErrNotFound) {
        return nil, err  // Don't wrap sentinel errors - caller expects them
    }
    if err != nil {
        return nil, fmt.Errorf("get task %s: %w", id, err)
    }
    return task, nil
}

func (s *TaskService) Update(ctx context.Context, id rms.ID, updates TaskUpdates) error {
    task, err := s.store.Get(ctx, id)
    if err != nil {
        return fmt.Errorf("get task %s: %w", id, err)
    }
    
    if err := task.ApplyUpdates(updates); err != nil {
        return fmt.Errorf("apply updates: %w", err)
    }
    
    if err := s.store.Save(ctx, task); err != nil {
        return fmt.Errorf("save task: %w", err)
    }
    
    return nil
}

func (s *TaskService) Delete(ctx context.Context, id rms.ID) error {
    if err := s.store.Delete(ctx, id); err != nil {
        return fmt.Errorf("delete task %s: %w", id, err)
    }
    return nil
}
```

---

## Repository Layer Error Handling

### SQL Store Pattern

```go
type SQLTaskStore struct {
    db *sql.DB
}

func (s *SQLTaskStore) Get(ctx context.Context, id rms.ID) (*Task, error) {
    const query = `SELECT id, title, status, priority, created_at, updated_at 
                   FROM tasks WHERE id = ?`
    
    var task Task
    err := s.db.QueryRowContext(ctx, query, id).Scan(
        &task.ID,
        &task.Title,
        &task.Status,
        &task.Priority,
        &task.CreatedAt,
        &task.UpdatedAt,
    )
    
    if errors.Is(err, sql.ErrNoRows) {
        return nil, ErrNotFound  // Convert to domain error
    }
    if err != nil {
        return nil, fmt.Errorf("query task: %w", err)
    }
    
    return &task, nil
}

func (s *SQLTaskStore) List(ctx context.Context, filter TaskFilter) ([]*Task, error) {
    query, args := buildListQuery(filter)
    
    rows, err := s.db.QueryContext(ctx, query, args...)
    if err != nil {
        return nil, fmt.Errorf("query tasks: %w", err)
    }
    defer rows.Close()
    
    var tasks []*Task
    for rows.Next() {
        var task Task
        if err := rows.Scan(&task.ID, &task.Title, &task.Status); err != nil {
            return nil, fmt.Errorf("scan task: %w", err)
        }
        tasks = append(tasks, &task)
    }
    
    if err := rows.Err(); err != nil {
        return nil, fmt.Errorf("iterate tasks: %w", err)
    }
    
    return tasks, nil
}

func (s *SQLTaskStore) Save(ctx context.Context, task *Task) error {
    const query = `INSERT INTO tasks (id, title, status, priority, created_at, updated_at)
                   VALUES (?, ?, ?, ?, ?, ?)
                   ON DUPLICATE KEY UPDATE title=?, status=?, priority=?, updated_at=?`
    
    _, err := s.db.ExecContext(ctx, query,
        task.ID, task.Title, task.Status, task.Priority, task.CreatedAt, task.UpdatedAt,
        task.Title, task.Status, task.Priority, task.UpdatedAt,
    )
    if err != nil {
        return fmt.Errorf("upsert task: %w", err)
    }
    
    return nil
}
```

---

## Handler Layer Error Handling

### gRPC Handler

```go
func (h *TaskHandler) GetTask(ctx context.Context, req *pb.GetTaskRequest) (*pb.Task, error) {
    // Validate request
    if req.GetId() == "" {
        return nil, status.Error(codes.InvalidArgument, "task ID required")
    }
    
    id := rms.ID(req.GetId())
    
    // Call service
    task, err := h.service.Get(ctx, id)
    if errors.Is(err, ErrNotFound) {
        return nil, status.Error(codes.NotFound, "task not found")
    }
    if errors.Is(err, ErrUnauthorized) {
        return nil, status.Error(codes.PermissionDenied, "unauthorized")
    }
    if err != nil {
        h.logger.Error("get task failed", "taskID", id, "error", err)
        return nil, status.Error(codes.Internal, "internal error")
    }
    
    // Convert to proto
    return h.converter.ToProto(task), nil
}

func (h *TaskHandler) CreateTask(ctx context.Context, req *pb.CreateTaskRequest) (*pb.Task, error) {
    params, err := h.converter.CreateParamsFromProto(req)
    if err != nil {
        return nil, status.Error(codes.InvalidArgument, err.Error())
    }
    
    task, err := h.service.Create(ctx, params)
    if err != nil {
        var validationErr *ValidationError
        if errors.As(err, &validationErr) {
            return nil, status.Error(codes.InvalidArgument, validationErr.Error())
        }
        
        h.logger.Error("create task failed", "error", err)
        return nil, status.Error(codes.Internal, "internal error")
    }
    
    return h.converter.ToProto(task), nil
}
```

### HTTP Handler

```go
func (h *TaskHandler) HandleGetTask(w http.ResponseWriter, r *http.Request) {
    id := chi.URLParam(r, "id")
    if id == "" {
        http.Error(w, "task ID required", http.StatusBadRequest)
        return
    }
    
    task, err := h.service.Get(r.Context(), rms.ID(id))
    if errors.Is(err, ErrNotFound) {
        http.Error(w, "task not found", http.StatusNotFound)
        return
    }
    if err != nil {
        h.logger.Error("get task failed", "taskID", id, "error", err)
        http.Error(w, "internal error", http.StatusInternalServerError)
        return
    }
    
    w.Header().Set("Content-Type", "application/json")
    if err := json.NewEncoder(w).Encode(task); err != nil {
        h.logger.Error("encode response failed", "error", err)
    }
}
```

---

## Validation Error Handling

### Struct Validation

```go
func (p CreateTaskParams) Validate() error {
    var errs []error
    
    if p.Title == "" {
        errs = append(errs, errors.New("title is required"))
    }
    if len(p.Title) > 255 {
        errs = append(errs, errors.New("title exceeds 255 characters"))
    }
    if p.WorkflowID == "" {
        errs = append(errs, errors.New("workflow ID is required"))
    }
    if p.ActorID == "" {
        errs = append(errs, errors.New("actor ID is required"))
    }
    if p.Priority < PriorityLow || p.Priority > PriorityCritical {
        errs = append(errs, fmt.Errorf("invalid priority: %d", p.Priority))
    }
    
    return errors.Join(errs...)
}

// Usage
func (s *Service) Create(ctx context.Context, params CreateTaskParams) (*Task, error) {
    if err := params.Validate(); err != nil {
        return nil, fmt.Errorf("validate params: %w", err)
    }
    // ...
}
```

### Field-Level Validation Errors

```go
type FieldError struct {
    Field   string
    Value   any
    Message string
}

func (e *FieldError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

type ValidationErrors struct {
    Errors []*FieldError
}

func (e *ValidationErrors) Error() string {
    if len(e.Errors) == 0 {
        return "validation failed"
    }
    
    var msgs []string
    for _, err := range e.Errors {
        msgs = append(msgs, err.Error())
    }
    return strings.Join(msgs, "; ")
}

func (e *ValidationErrors) Add(field, message string, value any) {
    e.Errors = append(e.Errors, &FieldError{
        Field:   field,
        Value:   value,
        Message: message,
    })
}

func (e *ValidationErrors) HasErrors() bool {
    return len(e.Errors) > 0
}

// Usage
func (p CreateTaskParams) Validate() error {
    errs := &ValidationErrors{}
    
    if p.Title == "" {
        errs.Add("title", "is required", p.Title)
    }
    if p.WorkflowID == "" {
        errs.Add("workflowID", "is required", p.WorkflowID)
    }
    
    if errs.HasErrors() {
        return errs
    }
    return nil
}
```

---

## Retry with Error Handling

### Exponential Backoff

```go
func (c *Client) GetWithRetry(ctx context.Context, id rms.ID) (*Task, error) {
    var lastErr error
    
    for attempt := 0; attempt < maxRetries; attempt++ {
        task, err := c.get(ctx, id)
        if err == nil {
            return task, nil
        }
        
        // Don't retry on client errors
        if errors.Is(err, ErrNotFound) || errors.Is(err, ErrInvalidInput) {
            return nil, err
        }
        
        lastErr = err
        
        // Exponential backoff
        backoff := time.Duration(1<<attempt) * baseBackoff
        if backoff > maxBackoff {
            backoff = maxBackoff
        }
        
        select {
        case <-ctx.Done():
            return nil, fmt.Errorf("context cancelled during retry: %w", ctx.Err())
        case <-time.After(backoff):
            // Continue to next attempt
        }
    }
    
    return nil, fmt.Errorf("get task after %d retries: %w", maxRetries, lastErr)
}
```

---

## Batch Processing Error Handling

### Collect and Continue

```go
func (s *Service) ProcessBatch(ctx context.Context, items []Item) (*BatchResult, error) {
    result := &BatchResult{
        Processed: make([]rms.ID, 0, len(items)),
        Failed:    make([]FailedItem, 0),
    }
    
    for _, item := range items {
        if err := s.process(ctx, item); err != nil {
            result.Failed = append(result.Failed, FailedItem{
                ID:    item.ID,
                Error: err.Error(),
            })
            continue
        }
        result.Processed = append(result.Processed, item.ID)
    }
    
    if len(result.Failed) > 0 {
        return result, fmt.Errorf("batch partially failed: %d/%d items failed", 
            len(result.Failed), len(items))
    }
    
    return result, nil
}
```

### Fail Fast

```go
func (s *Service) ProcessBatchStrict(ctx context.Context, items []Item) error {
    for i, item := range items {
        if err := s.process(ctx, item); err != nil {
            return fmt.Errorf("process item %d (ID=%s): %w", i, item.ID, err)
        }
    }
    return nil
}
```

---

## Cleanup Error Handling

### Multiple Cleanup Operations

```go
func (s *Service) ProcessWithCleanup(ctx context.Context, task *Task) (err error) {
    // Acquire resources
    lock, err := s.locker.Lock(ctx, task.ID)
    if err != nil {
        return fmt.Errorf("acquire lock: %w", err)
    }
    
    // Use named return for cleanup
    defer func() {
        if unlockErr := lock.Unlock(ctx); unlockErr != nil {
            if err != nil {
                err = fmt.Errorf("%w; unlock failed: %v", err, unlockErr)
            } else {
                err = fmt.Errorf("unlock: %w", unlockErr)
            }
        }
    }()
    
    // Process
    if err := s.process(ctx, task); err != nil {
        return fmt.Errorf("process: %w", err)
    }
    
    return nil
}
```

### Transaction Rollback

```go
func (s *Store) SaveWithTransaction(ctx context.Context, tasks []*Task) error {
    tx, err := s.db.BeginTx(ctx, nil)
    if err != nil {
        return fmt.Errorf("begin transaction: %w", err)
    }
    
    // Always handle transaction completion
    defer func() {
        if err != nil {
            if rbErr := tx.Rollback(); rbErr != nil {
                s.logger.Error("rollback failed", "error", rbErr)
            }
        }
    }()
    
    for _, task := range tasks {
        if err = s.saveTask(ctx, tx, task); err != nil {
            return fmt.Errorf("save task %s: %w", task.ID, err)
        }
    }
    
    if err = tx.Commit(); err != nil {
        return fmt.Errorf("commit transaction: %w", err)
    }
    
    return nil
}
```

---

## Error Aggregation

### Using errgroup

```go
func (s *Service) ProcessConcurrent(ctx context.Context, ids []rms.ID) error {
    g, ctx := errgroup.WithContext(ctx)
    
    for _, id := range ids {
        id := id  // Capture for goroutine
        g.Go(func() error {
            if err := s.process(ctx, id); err != nil {
                return fmt.Errorf("process %s: %w", id, err)
            }
            return nil
        })
    }
    
    if err := g.Wait(); err != nil {
        return fmt.Errorf("concurrent processing: %w", err)
    }
    
    return nil
}
```
