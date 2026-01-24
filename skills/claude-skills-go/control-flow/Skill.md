---
description: Reviews Go control flow for early returns, nesting depth, switch statements, and defer usage. Use when reviewing deeply nested code, complex conditionals, or resource cleanup patterns.
---

# Control Flow

## Purpose

Establish patterns for readable control flow in RMS Go code. Well-structured control flow makes code easier to understand, test, and maintain.

## Core Principles

1. **Early returns** - Handle errors and edge cases first
2. **Minimize nesting** - Maximum 2-3 levels of indentation
3. **Happy path unindented** - Main logic should flow straight down
4. **Prefer switch** - Over long if-else chains
5. **Defer wisely** - For cleanup, but understand the costs

---

## Early Returns

### Guard Clauses First

Handle edge cases and errors at the start of functions.

```go
// DO: Guard clauses first, happy path unindented
func (s *Service) CreateTask(ctx context.Context, params CreateTaskParams) (*Task, error) {
    if ctx.Err() != nil {
        return nil, ctx.Err()
    }
    if params.Title == "" {
        return nil, errors.New("title required")
    }
    if params.WorkflowID == "" {
        return nil, errors.New("workflow ID required")
    }
    
    // Happy path - main logic flows unindented
    task := &Task{
        ID:         generateID(),
        Title:      params.Title,
        WorkflowID: params.WorkflowID,
        Status:     StatusPending,
        CreatedAt:  time.Now(),
    }
    
    if err := s.store.Save(ctx, task); err != nil {
        return nil, fmt.Errorf("save task: %w", err)
    }
    
    return task, nil
}
```

```go
// DON'T: Nested validation and main logic
func (s *Service) CreateTask(ctx context.Context, params CreateTaskParams) (*Task, error) {
    if ctx.Err() == nil {
        if params.Title != "" {
            if params.WorkflowID != "" {
                task := &Task{
                    ID:         generateID(),
                    Title:      params.Title,
                    WorkflowID: params.WorkflowID,
                    Status:     StatusPending,
                    CreatedAt:  time.Now(),
                }
                
                if err := s.store.Save(ctx, task); err != nil {
                    return nil, fmt.Errorf("save task: %w", err)
                }
                
                return task, nil
            }
            return nil, errors.New("workflow ID required")
        }
        return nil, errors.New("title required")
    }
    return nil, ctx.Err()
}
```

### Return Early in Loops

```go
// DO: Return early when found
func findTaskByID(tasks []*Task, id rms.ID) *Task {
    for _, task := range tasks {
        if task.ID == id {
            return task
        }
    }
    return nil
}

// DO: Continue early to skip iterations
func processValidTasks(tasks []*Task) error {
    for _, task := range tasks {
        if task == nil {
            continue
        }
        if task.Status == StatusComplete {
            continue
        }
        
        // Process valid, incomplete tasks
        if err := process(task); err != nil {
            return fmt.Errorf("process task %s: %w", task.ID, err)
        }
    }
    return nil
}
```

---

## Minimize Nesting

### Maximum 2-3 Levels

Deeply nested code is hard to read and maintain.

```go
// DON'T: Too deeply nested
func processTask(task *Task) error {
    if task != nil {
        if task.Status == StatusPending {
            if task.Priority >= PriorityHigh {
                if task.AssigneeID != "" {
                    // Finally doing something - 4 levels deep!
                    return execute(task)
                }
            }
        }
    }
    return nil
}

// DO: Flatten with early returns
func processTask(task *Task) error {
    if task == nil {
        return nil
    }
    if task.Status != StatusPending {
        return nil
    }
    if task.Priority < PriorityHigh {
        return nil
    }
    if task.AssigneeID == "" {
        return nil
    }
    
    return execute(task)
}
```

### Extract Functions to Reduce Nesting

```go
// DON'T: All logic in one function
func processOrders(orders []Order) error {
    for _, order := range orders {
        if order.Status == "pending" {
            for _, item := range order.Items {
                if item.InStock {
                    if item.Price > 0 {
                        // Process item...
                    }
                }
            }
        }
    }
    return nil
}

// DO: Extract to separate functions
func processOrders(orders []Order) error {
    for _, order := range orders {
        if err := processOrder(order); err != nil {
            return fmt.Errorf("process order %s: %w", order.ID, err)
        }
    }
    return nil
}

func processOrder(order Order) error {
    if order.Status != "pending" {
        return nil
    }
    
    for _, item := range order.Items {
        if err := processItem(item); err != nil {
            return fmt.Errorf("process item %s: %w", item.ID, err)
        }
    }
    return nil
}

func processItem(item Item) error {
    if !item.InStock {
        return nil
    }
    if item.Price <= 0 {
        return nil
    }
    
    // Process valid item
    return execute(item)
}
```

---

## Reduce Scope

### Declare Variables Close to Use

```go
// DO: Declare close to use, in smallest scope
func process(ctx context.Context, id rms.ID) (*Result, error) {
    task, err := getTask(ctx, id)
    if err != nil {
        return nil, err
    }
    
    // metadata only needed in this block
    if task.RequiresValidation {
        metadata, err := fetchMetadata(ctx, task.ID)
        if err != nil {
            return nil, err
        }
        if err := validate(task, metadata); err != nil {
            return nil, err
        }
    }
    
    return process(task), nil
}
```

```go
// DON'T: Declare all variables at top
func process(ctx context.Context, id rms.ID) (*Result, error) {
    var task *Task
    var metadata *Metadata
    var err error
    
    task, err = getTask(ctx, id)
    if err != nil {
        return nil, err
    }
    
    // metadata declared at top but only used conditionally
    if task.RequiresValidation {
        metadata, err = fetchMetadata(ctx, task.ID)
        if err != nil {
            return nil, err
        }
        if err := validate(task, metadata); err != nil {
            return nil, err
        }
    }
    
    return process(task), nil
}
```

### If with Initialization

Use if-initialization to limit variable scope.

```go
// DO: Scope variable to if block
if task, err := s.store.Get(ctx, id); err != nil {
    return fmt.Errorf("get task: %w", err)
} else if task.Status != StatusPending {
    return ErrInvalidState
}

// DO: Common pattern for comma-ok idiom
if value, ok := cache.Get(key); ok {
    return value, nil
}

// DO: Type assertion with limited scope
if task, ok := entity.(*Task); ok {
    return processTask(task)
}
```

---

## Switch Statements

### Prefer Switch Over Long If-Else

```go
// DON'T: Long if-else chain
func handleStatus(status Status) error {
    if status == StatusPending {
        return handlePending()
    } else if status == StatusInProgress {
        return handleInProgress()
    } else if status == StatusComplete {
        return handleComplete()
    } else if status == StatusCancelled {
        return handleCancelled()
    } else {
        return ErrUnknownStatus
    }
}

// DO: Switch statement
func handleStatus(status Status) error {
    switch status {
    case StatusPending:
        return handlePending()
    case StatusInProgress:
        return handleInProgress()
    case StatusComplete:
        return handleComplete()
    case StatusCancelled:
        return handleCancelled()
    default:
        return ErrUnknownStatus
    }
}
```

### Switch True Pattern

For complex conditions, use `switch true`.

```go
// DO: switch true for complex conditions
func categorize(task *Task) Category {
    switch {
    case task.Priority == PriorityCritical && task.DueDate.Before(time.Now()):
        return CategoryUrgent
    case task.Priority >= PriorityHigh:
        return CategoryHigh
    case task.AssigneeID == "":
        return CategoryUnassigned
    default:
        return CategoryNormal
    }
}
```

### Type Switch

Use type switch for interface handling.

```go
// DO: Type switch for interface handling
func processEntity(entity Entity) error {
    switch e := entity.(type) {
    case *Task:
        return processTask(e)
    case *Action:
        return processAction(e)
    case *Assignment:
        return processAssignment(e)
    default:
        return fmt.Errorf("unknown entity type: %T", entity)
    }
}
```

---

## Loop Patterns

### Range Over Index When Possible

```go
// DO: Use range
for _, task := range tasks {
    process(task)
}

for i, task := range tasks {
    fmt.Printf("task %d: %s\n", i, task.ID)
}

// DON'T: Index-based when range works
for i := 0; i < len(tasks); i++ {
    process(tasks[i])
}
```

### Break and Continue with Labels

For nested loops, use labels for clarity.

```go
// DO: Labeled break for nested loops
outer:
for _, order := range orders {
    for _, item := range order.Items {
        if item.ID == targetID {
            result = item
            break outer  // Exits both loops
        }
    }
}
```

### Avoid Loop Variable Capture Issues

```go
// DON'T: Capture loop variable directly (before Go 1.22)
for _, task := range tasks {
    go func() {
        process(task)  // All goroutines see same (last) task!
    }()
}

// DO: Capture by parameter or local copy
for _, task := range tasks {
    task := task  // Create local copy (still needed in some cases)
    go func() {
        process(task)
    }()
}

// Or pass as parameter
for _, task := range tasks {
    go func(t *Task) {
        process(t)
    }(task)
}
```

---

## Defer

### Use Defer for Cleanup

```go
// DO: Defer for resource cleanup
func processFile(path string) error {
    f, err := os.Open(path)
    if err != nil {
        return fmt.Errorf("open file: %w", err)
    }
    defer f.Close()
    
    // Process file...
    return nil
}

// DO: Defer for mutex unlock
func (s *Service) Update(id rms.ID, updates Updates) error {
    s.mu.Lock()
    defer s.mu.Unlock()
    
    // Critical section...
    return nil
}
```

### Defer Executes in LIFO Order

```go
// Defers execute in Last-In-First-Out order
func example() {
    defer fmt.Println("first")   // Executes third
    defer fmt.Println("second")  // Executes second
    defer fmt.Println("third")   // Executes first
}
// Output: third, second, first
```

### Defer Captures Values at Declaration

```go
// DON'T: Expect defer to capture updated values
func example() int {
    x := 1
    defer fmt.Println(x)  // Prints 1, not 2!
    x = 2
    return x
}

// DO: Use closure to capture current value
func example() int {
    x := 1
    defer func() {
        fmt.Println(x)  // Prints 2
    }()
    x = 2
    return x
}

// DO: Use named return for modification
func example() (result int) {
    defer func() {
        result = result * 2  // Modifies return value
    }()
    return 5  // Returns 10
}
```

### Avoid Defer in Loops

```go
// DON'T: Defer in loop accumulates until function returns
func processFiles(paths []string) error {
    for _, path := range paths {
        f, err := os.Open(path)
        if err != nil {
            return err
        }
        defer f.Close()  // All closes happen at function end!
        
        // If processing many files, file handles accumulate
        process(f)
    }
    return nil
}

// DO: Extract to separate function or close explicitly
func processFiles(paths []string) error {
    for _, path := range paths {
        if err := processFile(path); err != nil {
            return fmt.Errorf("process %s: %w", path, err)
        }
    }
    return nil
}

func processFile(path string) error {
    f, err := os.Open(path)
    if err != nil {
        return err
    }
    defer f.Close()  // Closes after each file
    
    return process(f)
}
```

---

## Quick Reference

| Pattern | When to Use |
|---------|-------------|
| Early return | Handle errors/edge cases first |
| Guard clause | Validate at function start |
| Continue early | Skip invalid loop iterations |
| Extract function | Reduce nesting below 3 levels |
| Switch statement | 3+ if-else conditions |
| switch true | Complex boolean conditions |
| Type switch | Handle interface types |
| Defer | Resource cleanup, mutex unlock |

### Nesting Checklist

- [ ] Maximum 2-3 levels of indentation?
- [ ] Guard clauses at function start?
- [ ] Happy path flows unindented?
- [ ] Complex logic extracted to functions?
- [ ] Switch used instead of if-else chains?

---

## See Also

- [REFACTORING.md](./REFACTORING.md) - Before/after refactoring examples
- [error-handling](../error-handling/Skill.md) - Error handling patterns
- [functions-methods](../functions-methods/Skill.md) - Function design
