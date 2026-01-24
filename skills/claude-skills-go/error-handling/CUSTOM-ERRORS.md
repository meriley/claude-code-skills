# Custom Errors and Landmines

Advanced error handling patterns and common pitfalls in Go error handling.

## Custom Error Types

### Basic Custom Error

```go
// Simple custom error with additional context
type TaskError struct {
    TaskID  rms.ID
    Op      string
    Message string
    Err     error
}

func (e *TaskError) Error() string {
    if e.Err != nil {
        return fmt.Sprintf("task %s: %s: %s: %v", e.TaskID, e.Op, e.Message, e.Err)
    }
    return fmt.Sprintf("task %s: %s: %s", e.TaskID, e.Op, e.Message)
}

func (e *TaskError) Unwrap() error {
    return e.Err
}

// Usage
func (s *Service) Update(ctx context.Context, id rms.ID, updates Updates) error {
    task, err := s.store.Get(ctx, id)
    if err != nil {
        return &TaskError{
            TaskID:  id,
            Op:      "get",
            Message: "failed to retrieve task",
            Err:     err,
        }
    }
    // ...
}

// Checking
var taskErr *TaskError
if errors.As(err, &taskErr) {
    log.Printf("task %s failed during %s: %s", taskErr.TaskID, taskErr.Op, taskErr.Message)
}
```

### Error with HTTP Status Code

```go
type HTTPError struct {
    Code    int
    Message string
    Err     error
}

func (e *HTTPError) Error() string {
    if e.Err != nil {
        return fmt.Sprintf("%d: %s: %v", e.Code, e.Message, e.Err)
    }
    return fmt.Sprintf("%d: %s", e.Code, e.Message)
}

func (e *HTTPError) Unwrap() error {
    return e.Err
}

// Constructor helpers
func NewNotFoundError(msg string) *HTTPError {
    return &HTTPError{Code: http.StatusNotFound, Message: msg}
}

func NewBadRequestError(msg string, err error) *HTTPError {
    return &HTTPError{Code: http.StatusBadRequest, Message: msg, Err: err}
}

func NewInternalError(err error) *HTTPError {
    return &HTTPError{Code: http.StatusInternalServerError, Message: "internal error", Err: err}
}

// Handler usage
func (h *Handler) HandleGet(w http.ResponseWriter, r *http.Request) {
    task, err := h.service.Get(r.Context(), id)
    if err != nil {
        var httpErr *HTTPError
        if errors.As(err, &httpErr) {
            http.Error(w, httpErr.Message, httpErr.Code)
            return
        }
        http.Error(w, "internal error", http.StatusInternalServerError)
        return
    }
    // ...
}
```

### Error with gRPC Status Code

```go
type GRPCError struct {
    Code    codes.Code
    Message string
    Err     error
}

func (e *GRPCError) Error() string {
    if e.Err != nil {
        return fmt.Sprintf("%s: %s: %v", e.Code, e.Message, e.Err)
    }
    return fmt.Sprintf("%s: %s", e.Code, e.Message)
}

func (e *GRPCError) Unwrap() error {
    return e.Err
}

func (e *GRPCError) GRPCStatus() *status.Status {
    return status.New(e.Code, e.Message)
}

// Usage in handler
func (h *Handler) GetTask(ctx context.Context, req *pb.GetTaskRequest) (*pb.Task, error) {
    task, err := h.service.Get(ctx, rms.ID(req.GetId()))
    if err != nil {
        var grpcErr *GRPCError
        if errors.As(err, &grpcErr) {
            return nil, grpcErr.GRPCStatus().Err()
        }
        return nil, status.Error(codes.Internal, "internal error")
    }
    return h.converter.ToProto(task), nil
}
```

---

## Multi-Error Wrapper

### Collecting Multiple Errors

```go
type MultiError struct {
    Errors []error
}

func (e *MultiError) Error() string {
    if len(e.Errors) == 0 {
        return "no errors"
    }
    if len(e.Errors) == 1 {
        return e.Errors[0].Error()
    }
    
    var b strings.Builder
    fmt.Fprintf(&b, "%d errors occurred:", len(e.Errors))
    for i, err := range e.Errors {
        fmt.Fprintf(&b, "\n  [%d] %v", i+1, err)
    }
    return b.String()
}

func (e *MultiError) Unwrap() []error {
    return e.Errors
}

func (e *MultiError) Add(err error) {
    if err != nil {
        e.Errors = append(e.Errors, err)
    }
}

func (e *MultiError) HasErrors() bool {
    return len(e.Errors) > 0
}

func (e *MultiError) ErrorOrNil() error {
    if e.HasErrors() {
        return e
    }
    return nil
}

// Usage
func (s *Service) ValidateAll(items []Item) error {
    multi := &MultiError{}
    
    for i, item := range items {
        if err := item.Validate(); err != nil {
            multi.Add(fmt.Errorf("item %d: %w", i, err))
        }
    }
    
    return multi.ErrorOrNil()
}
```

---

## Go Error Handling Landmines

### Landmine #1: Comparing Wrapped Errors with ==

```go
// DON'T: Direct comparison fails with wrapped errors
var ErrNotFound = errors.New("not found")

func getTask(id string) (*Task, error) {
    task, err := store.Get(id)
    if err != nil {
        return nil, fmt.Errorf("get task: %w", err)  // Wraps ErrNotFound
    }
    return task, nil
}

// This will NEVER be true because err is wrapped!
task, err := getTask("123")
if err == ErrNotFound {  // WRONG!
    // This code never executes
}

// DO: Use errors.Is
if errors.Is(err, ErrNotFound) {  // CORRECT!
    // Handle not found
}
```

### Landmine #2: Nil Interface Trap

```go
// DON'T: Returning typed nil causes unexpected behavior
type CustomError struct {
    Message string
}

func (e *CustomError) Error() string {
    return e.Message
}

func mayFail() *CustomError {
    // No error - return nil
    return nil
}

func process() error {
    err := mayFail()
    return err  // Returns (*CustomError)(nil), not nil!
}

// This check FAILS!
if process() == nil {  // FALSE - interface contains typed nil
    fmt.Println("no error")
}

// DO: Return error interface directly
func mayFail() error {
    // No error - return nil
    return nil
}

// Or explicitly return nil
func process() error {
    err := mayFail()
    if err != nil {
        return err
    }
    return nil  // Explicitly return untyped nil
}
```

### Landmine #3: Mutating Sentinel Errors

```go
// DON'T: Sentinel errors should be immutable
var ErrNotFound = errors.New("not found")

// Some code accidentally modifies it (in languages where this is possible)
// Go's errors.New returns immutable error, so this is safe
// But custom error types can be mutated:

var ErrConfig = &ConfigError{Message: "config error"}

// Someone could do:
ErrConfig.Message = "different message"  // Mutates global state!

// DO: Use functions or keep sentinel errors simple
var ErrNotFound = errors.New("not found")  // Immutable

// Or use a function
func ErrConfig(msg string) error {
    return &ConfigError{Message: msg}
}
```

### Landmine #4: Shadow Error Variable

```go
// DON'T: Shadowing err variable loses the error
func process() error {
    err := step1()
    if err != nil {
        return err
    }
    
    // This creates a NEW err variable in this scope!
    if result, err := step2(); err != nil {
        // This err is different from outer err
        _ = result
    }
    
    // Outer err is still from step1 (or nil)
    return err  // Bug: returns wrong error!
}

// DO: Don't shadow, or use explicit new variable
func process() error {
    if err := step1(); err != nil {
        return fmt.Errorf("step1: %w", err)
    }
    
    result, err := step2()
    if err != nil {
        return fmt.Errorf("step2: %w", err)
    }
    
    _ = result
    return nil
}
```

### Landmine #5: Ignoring errors.As Type Requirements

```go
// DON'T: errors.As requires pointer to interface or pointer to error type
var taskErr TaskError  // Wrong: not a pointer
if errors.As(err, &taskErr) {  // Panics or doesn't work!
    // ...
}

// DO: Use pointer to pointer for concrete types
var taskErr *TaskError
if errors.As(err, &taskErr) {  // Correct
    // taskErr is now populated
}

// For interface types, use pointer to interface
var validator Validator
if errors.As(err, &validator) {  // Correct for interfaces
    // ...
}
```

### Landmine #6: Error String Matching

```go
// DON'T: Never match on error strings
if strings.Contains(err.Error(), "not found") {
    // Fragile! Error message could change
}

if err.Error() == "task not found" {
    // Fragile! Exact match is even worse
}

// DO: Use sentinel errors or error types
if errors.Is(err, ErrNotFound) {
    // Stable
}

var notFoundErr *NotFoundError
if errors.As(err, &notFoundErr) {
    // Stable
}
```

### Landmine #7: Wrapping Errors Multiple Times

```go
// DON'T: Adding redundant context
func serviceA(id string) error {
    err := serviceB(id)
    if err != nil {
        return fmt.Errorf("serviceA failed: %w", err)
    }
    return nil
}

func serviceB(id string) error {
    err := serviceC(id)
    if err != nil {
        return fmt.Errorf("serviceB failed: %w", err)
    }
    return nil
}

// Result: "serviceA failed: serviceB failed: serviceC failed: actual error"
// Too verbose!

// DO: Add meaningful context only
func serviceA(ctx context.Context, id rms.ID) error {
    err := serviceB(ctx, id)
    if err != nil {
        return fmt.Errorf("get user %s: %w", id, err)  // What were we doing?
    }
    return nil
}

func serviceB(ctx context.Context, id rms.ID) error {
    err := db.Query(ctx, id)
    if err != nil {
        return fmt.Errorf("query database: %w", err)  // What failed?
    }
    return nil
}

// Result: "get user abc123: query database: connection refused"
// Clear and concise!
```

### Landmine #8: Recovering from Panic in Wrong Place

```go
// DON'T: Recover in the wrong goroutine
func process() {
    defer func() {
        if r := recover(); r != nil {
            log.Printf("recovered: %v", r)
        }
    }()
    
    go func() {
        panic("crash!")  // This panic is NOT recovered!
    }()
    
    time.Sleep(time.Second)
}

// DO: Recover in same goroutine
func process() {
    go func() {
        defer func() {
            if r := recover(); r != nil {
                log.Printf("recovered: %v", r)
            }
        }()
        
        panic("crash!")  // This panic IS recovered
    }()
    
    time.Sleep(time.Second)
}
```

---

## Best Practices Summary

### DO

1. Use `%w` for wrapping, never `%v`
2. Use `errors.Is` and `errors.As` for checking
3. Add context that describes the operation
4. Define sentinel errors for expected conditions
5. Return error interface, not concrete types
6. Keep error messages lowercase (they may be combined)

### DON'T

1. Compare errors with `==`
2. Match on error strings
3. Return typed nil
4. Shadow err variable
5. Swallow errors silently
6. Add redundant context ("error", "failed to")
7. Panic in business logic
