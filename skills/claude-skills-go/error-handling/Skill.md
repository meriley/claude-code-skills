---
description: Enforces RMS error handling patterns including proper wrapping with %w, context preservation, and panic avoidance. Use when reviewing error handling code, seeing swallowed errors, or implementing retry logic.
---

# Error Handling

## Purpose

Establish consistent error handling patterns for RMS Go code. Proper error handling is critical for debugging, monitoring, and maintaining production systems.

## Core Principles

1. **Always add context** when propagating errors
2. **Use `%w`** for error wrapping (stdlib only, no `pkg/errors`)
3. **Never swallow errors** silently
4. **Avoid panics** in business logic
5. **Use sentinel errors** for expected error conditions

---

## Error Wrapping

### Use `%w` for Wrapping

Always wrap errors with `fmt.Errorf` and `%w` to preserve the error chain.

```go
// DO: Wrap with %w and add context
func (s *Service) GetTask(ctx context.Context, id rms.ID) (*Task, error) {
    task, err := s.store.Get(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("get task %s: %w", id, err)
    }
    return task, nil
}

// DO: Context describes the operation that failed
func (s *Service) CreateTask(ctx context.Context, params CreateTaskParams) (*Task, error) {
    if err := params.Validate(); err != nil {
        return nil, fmt.Errorf("validate params: %w", err)
    }
    
    task, err := s.factory.Create(params)
    if err != nil {
        return nil, fmt.Errorf("create task: %w", err)
    }
    
    if err := s.store.Save(ctx, task); err != nil {
        return nil, fmt.Errorf("save task: %w", err)
    }
    
    return task, nil
}
```

```go
// DON'T: Return bare error without context
func (s *Service) GetTask(ctx context.Context, id rms.ID) (*Task, error) {
    task, err := s.store.Get(ctx, id)
    if err != nil {
        return nil, err  // No context - where did this fail?
    }
    return task, nil
}

// DON'T: Use %v instead of %w (breaks error chain)
func (s *Service) GetTask(ctx context.Context, id rms.ID) (*Task, error) {
    task, err := s.store.Get(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("get task: %v", err)  // Loses error chain!
    }
    return task, nil
}
```

### Context Guidelines

Error context should describe **what operation failed**, not the error itself.

```go
// DO: Describe the operation
return nil, fmt.Errorf("get task %s: %w", id, err)
return nil, fmt.Errorf("validate metadata: %w", err)
return nil, fmt.Errorf("publish event: %w", err)

// DON'T: Redundant context
return nil, fmt.Errorf("error getting task: %w", err)     // "error" is redundant
return nil, fmt.Errorf("failed to get task: %w", err)    // "failed to" is redundant
return nil, fmt.Errorf("could not get task: %w", err)    // "could not" is redundant
```

---

## Sentinel Errors

### Define Sentinel Errors for Expected Conditions

```go
// DO: Define package-level sentinel errors
var (
    ErrNotFound        = errors.New("task not found")
    ErrAlreadyExists   = errors.New("task already exists")
    ErrInvalidState    = errors.New("invalid task state")
    ErrUnauthorized    = errors.New("unauthorized")
)

// Use in functions
func (s *Store) Get(ctx context.Context, id rms.ID) (*Task, error) {
    task, err := s.db.QueryRow(ctx, query, id)
    if errors.Is(err, sql.ErrNoRows) {
        return nil, ErrNotFound
    }
    if err != nil {
        return nil, fmt.Errorf("query task: %w", err)
    }
    return task, nil
}
```

### Checking Errors with `errors.Is`

```go
// DO: Use errors.Is for sentinel errors
task, err := service.GetTask(ctx, id)
if errors.Is(err, ErrNotFound) {
    // Handle not found case
    return nil, status.Error(codes.NotFound, "task not found")
}
if err != nil {
    return nil, fmt.Errorf("get task: %w", err)
}

// DON'T: Compare errors directly
if err == ErrNotFound {  // Breaks if error is wrapped
    // ...
}

// DON'T: String matching
if err != nil && err.Error() == "task not found" {  // Fragile!
    // ...
}
```

---

## Error Types

### Use `errors.As` for Custom Error Types

```go
// DO: Define custom error type
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation error on %s: %s", e.Field, e.Message)
}

// Check with errors.As
func handleError(err error) {
    var validationErr *ValidationError
    if errors.As(err, &validationErr) {
        log.Printf("validation failed on field %s: %s", 
            validationErr.Field, validationErr.Message)
        return
    }
    log.Printf("unexpected error: %v", err)
}
```

### Wrapping Custom Errors

Custom error types can still participate in error chains.

```go
// DO: Custom error with Unwrap
type TaskError struct {
    TaskID rms.ID
    Op     string
    Err    error
}

func (e *TaskError) Error() string {
    return fmt.Sprintf("task %s: %s: %v", e.TaskID, e.Op, e.Err)
}

func (e *TaskError) Unwrap() error {
    return e.Err
}

// Usage
func (s *Service) Update(ctx context.Context, id rms.ID, updates Updates) error {
    task, err := s.store.Get(ctx, id)
    if err != nil {
        return &TaskError{TaskID: id, Op: "get", Err: err}
    }
    // ...
}
```

---

## Error Joining (Go 1.20+)

### Join Multiple Errors

```go
// DO: Join errors when multiple can occur
func (t *Task) Validate() error {
    var errs []error
    
    if t.Title == "" {
        errs = append(errs, errors.New("title is required"))
    }
    if t.WorkflowID == "" {
        errs = append(errs, errors.New("workflow ID is required"))
    }
    if t.ActorID == "" {
        errs = append(errs, errors.New("actor ID is required"))
    }
    
    return errors.Join(errs...)  // Returns nil if errs is empty
}

// Check joined errors
err := task.Validate()
if errors.Is(err, ErrTitleRequired) {
    // This works - errors.Is checks the entire error tree
}
```

---

## Panic Rules

### Never Panic in Business Logic

```go
// DON'T: Panic in business logic
func (s *Service) GetTask(ctx context.Context, id rms.ID) *Task {
    task, err := s.store.Get(ctx, id)
    if err != nil {
        panic(err)  // NEVER do this!
    }
    return task
}

// DO: Return errors
func (s *Service) GetTask(ctx context.Context, id rms.ID) (*Task, error) {
    task, err := s.store.Get(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("get task: %w", err)
    }
    return task, nil
}
```

### Acceptable Panic Cases

Panics are only acceptable for:

1. **Initialization failures** - Configuration errors at startup
2. **Programming errors** - Truly impossible conditions (after all validation)

```go
// OK: Panic in init() for configuration
func init() {
    if os.Getenv("DATABASE_URL") == "" {
        panic("DATABASE_URL environment variable required")
    }
}

// OK: Panic for programming error (should never happen)
func (t *Task) mustHaveID() rms.ID {
    if t.ID == "" {
        panic("task ID is empty - this should never happen after validation")
    }
    return t.ID
}
```

---

## Never Swallow Errors

### Always Handle or Propagate

```go
// DON'T: Ignore errors silently
func process(task *Task) {
    task.Validate()  // Error ignored!
    
    result, _ := service.Get(ctx, id)  // Error discarded!
}

// DO: Handle or propagate every error
func process(task *Task) error {
    if err := task.Validate(); err != nil {
        return fmt.Errorf("validate: %w", err)
    }
    
    result, err := service.Get(ctx, id)
    if err != nil {
        return fmt.Errorf("get: %w", err)
    }
    // ...
}
```

### Explicitly Ignore Only When Safe

```go
// OK: Explicitly ignore when error handling is impossible/irrelevant
defer file.Close()  // Can't do anything with error in defer

// OK: Ignore with explicit discard and comment
_ = writer.Flush()  // Best effort; connection closing anyway

// BETTER: Log if ignoring
if err := writer.Flush(); err != nil {
    log.Printf("flush failed (ignoring): %v", err)
}
```

---

## Error Handling Patterns

### Early Return Pattern

```go
// DO: Early returns for error handling
func (s *Service) CreateTask(ctx context.Context, params CreateTaskParams) (*Task, error) {
    if err := params.Validate(); err != nil {
        return nil, fmt.Errorf("validate: %w", err)
    }
    
    task, err := s.factory.Create(params)
    if err != nil {
        return nil, fmt.Errorf("create: %w", err)
    }
    
    if err := s.store.Save(ctx, task); err != nil {
        return nil, fmt.Errorf("save: %w", err)
    }
    
    if err := s.publisher.Publish(ctx, TaskCreatedEvent{Task: task}); err != nil {
        return nil, fmt.Errorf("publish event: %w", err)
    }
    
    return task, nil
}
```

### Multiple Error Sources

```go
// DO: Handle each error source appropriately
func (s *Service) ProcessBatch(ctx context.Context, ids []rms.ID) ([]Result, error) {
    results := make([]Result, 0, len(ids))
    var errs []error
    
    for _, id := range ids {
        result, err := s.process(ctx, id)
        if err != nil {
            errs = append(errs, fmt.Errorf("process %s: %w", id, err))
            continue  // Continue processing others
        }
        results = append(results, result)
    }
    
    if len(errs) > 0 {
        return results, fmt.Errorf("batch processing: %w", errors.Join(errs...))
    }
    return results, nil
}
```

---

## Quick Reference

| Pattern | When to Use |
|---------|-------------|
| `fmt.Errorf("op: %w", err)` | Always when propagating errors |
| `errors.New("message")` | Creating new sentinel errors |
| `errors.Is(err, target)` | Checking for specific error |
| `errors.As(err, &target)` | Extracting error type |
| `errors.Join(errs...)` | Combining multiple errors |

### Error Context Checklist

- [ ] Does the context describe the operation?
- [ ] Is `%w` used (not `%v`)?
- [ ] Is redundant wording avoided ("error", "failed to")?
- [ ] Are identifiers included where helpful?

---

## See Also

- [EXAMPLES.md](./EXAMPLES.md) - Extended error handling examples
- [CUSTOM-ERRORS.md](./CUSTOM-ERRORS.md) - Custom error types and landmines
- [control-flow](../control-flow/Skill.md) - Early return patterns
- [logging](../logging/Skill.md) - Error logging patterns
