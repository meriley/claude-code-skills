# Functions and Methods Examples

Extended examples for RMS Go function and method patterns.

## Service Layer Patterns

### Complete Service Definition

```go
// Service with proper method signatures
type TaskService struct {
    store     TaskStore
    factory   *TaskFactory
    publisher EventPublisher
    validator Validator
    logger    rms.Logger
}

// Constructor with required and optional dependencies
func NewTaskService(
    store TaskStore,
    factory *TaskFactory,
    opts ...TaskServiceOption,
) *TaskService {
    s := &TaskService{
        store:   store,
        factory: factory,
        logger:  rms.DefaultLogger(),
    }
    for _, opt := range opts {
        opt(s)
    }
    return s
}

// Options
type TaskServiceOption func(*TaskService)

func WithPublisher(p EventPublisher) TaskServiceOption {
    return func(s *TaskService) {
        s.publisher = p
    }
}

func WithValidator(v Validator) TaskServiceOption {
    return func(s *TaskService) {
        s.validator = v
    }
}

func WithLogger(l rms.Logger) TaskServiceOption {
    return func(s *TaskService) {
        s.logger = l
    }
}
```

### CRUD Methods

```go
// Create - context first, params struct, returns pointer and error
func (s *TaskService) Create(ctx context.Context, params CreateTaskParams) (*Task, error) {
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
    
    return task, nil
}

// Get - context first, ID parameter, returns pointer and error
func (s *TaskService) Get(ctx context.Context, id rms.ID) (*Task, error) {
    task, err := s.store.Get(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("get task %s: %w", id, err)
    }
    return task, nil
}

// Update - context first, ID before data
func (s *TaskService) Update(ctx context.Context, id rms.ID, updates TaskUpdates) (*Task, error) {
    task, err := s.store.Get(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("get task: %w", err)
    }
    
    if err := task.ApplyUpdates(updates); err != nil {
        return nil, fmt.Errorf("apply updates: %w", err)
    }
    
    if err := s.store.Save(ctx, task); err != nil {
        return nil, fmt.Errorf("save: %w", err)
    }
    
    return task, nil
}

// Delete - context first, ID parameter, returns only error
func (s *TaskService) Delete(ctx context.Context, id rms.ID) error {
    if err := s.store.Delete(ctx, id); err != nil {
        return fmt.Errorf("delete task %s: %w", id, err)
    }
    return nil
}

// List - context first, filter struct, returns slice and error
func (s *TaskService) List(ctx context.Context, filter TaskFilter) ([]*Task, error) {
    tasks, err := s.store.List(ctx, filter)
    if err != nil {
        return nil, fmt.Errorf("list tasks: %w", err)
    }
    return tasks, nil
}

// List with pagination - returns slice, total, error
func (s *TaskService) ListPaginated(ctx context.Context, filter TaskFilter) ([]*Task, int64, error) {
    tasks, err := s.store.List(ctx, filter)
    if err != nil {
        return nil, 0, fmt.Errorf("list tasks: %w", err)
    }
    
    total, err := s.store.Count(ctx, filter)
    if err != nil {
        return nil, 0, fmt.Errorf("count tasks: %w", err)
    }
    
    return tasks, total, nil
}
```

---

## Parameter Struct Examples

### Create Parameters

```go
type CreateTaskParams struct {
    // Required fields
    Title      string `json:"title"`
    WorkflowID rms.ID `json:"workflowId"`
    ActorID    rms.ID `json:"actorId"`
    ItemRef    string `json:"itemRef"`
    ItemType   string `json:"itemType"`
    
    // Optional fields (use pointers or zero values)
    Description string            `json:"description,omitempty"`
    Priority    Priority          `json:"priority,omitempty"`
    DueDate     *time.Time        `json:"dueDate,omitempty"`
    Metadata    map[string]any    `json:"metadata,omitempty"`
    Tags        []string          `json:"tags,omitempty"`
}

func (p CreateTaskParams) Validate() error {
    var errs []error
    
    if p.Title == "" {
        errs = append(errs, errors.New("title is required"))
    }
    if p.WorkflowID == "" {
        errs = append(errs, errors.New("workflow ID is required"))
    }
    if p.ActorID == "" {
        errs = append(errs, errors.New("actor ID is required"))
    }
    if p.ItemRef == "" {
        errs = append(errs, errors.New("item ref is required"))
    }
    if p.ItemType == "" {
        errs = append(errs, errors.New("item type is required"))
    }
    
    return errors.Join(errs...)
}
```

### Update Parameters

```go
type TaskUpdates struct {
    Title       *string        `json:"title,omitempty"`
    Description *string        `json:"description,omitempty"`
    Priority    *Priority      `json:"priority,omitempty"`
    Status      *Status        `json:"status,omitempty"`
    DueDate     *time.Time     `json:"dueDate,omitempty"`
    AssigneeID  *rms.ID        `json:"assigneeId,omitempty"`
    Metadata    map[string]any `json:"metadata,omitempty"`
}

func (u TaskUpdates) HasUpdates() bool {
    return u.Title != nil ||
        u.Description != nil ||
        u.Priority != nil ||
        u.Status != nil ||
        u.DueDate != nil ||
        u.AssigneeID != nil ||
        len(u.Metadata) > 0
}

// Apply updates to task
func (t *Task) ApplyUpdates(updates TaskUpdates) error {
    if updates.Title != nil {
        t.Title = *updates.Title
    }
    if updates.Description != nil {
        t.Description = *updates.Description
    }
    if updates.Priority != nil {
        t.Priority = *updates.Priority
    }
    if updates.Status != nil {
        if err := t.validateStatusTransition(*updates.Status); err != nil {
            return err
        }
        t.Status = *updates.Status
    }
    if updates.DueDate != nil {
        t.DueDate = updates.DueDate
    }
    if updates.AssigneeID != nil {
        t.AssigneeID = *updates.AssigneeID
    }
    for k, v := range updates.Metadata {
        t.Metadata[k] = v
    }
    
    t.UpdatedAt = time.Now()
    return nil
}
```

### Filter Parameters

```go
type TaskFilter struct {
    // Filters
    IDs        []rms.ID   `json:"ids,omitempty"`
    Status     []Status   `json:"status,omitempty"`
    Priority   []Priority `json:"priority,omitempty"`
    AssigneeID *rms.ID    `json:"assigneeId,omitempty"`
    WorkflowID *rms.ID    `json:"workflowId,omitempty"`
    
    // Date range
    CreatedAfter  *time.Time `json:"createdAfter,omitempty"`
    CreatedBefore *time.Time `json:"createdBefore,omitempty"`
    
    // Pagination
    Limit  int `json:"limit,omitempty"`
    Offset int `json:"offset,omitempty"`
    
    // Sorting
    SortBy    string `json:"sortBy,omitempty"`
    SortOrder string `json:"sortOrder,omitempty"` // "asc" or "desc"
}

func (f TaskFilter) WithDefaults() TaskFilter {
    if f.Limit == 0 {
        f.Limit = 50
    }
    if f.Limit > 1000 {
        f.Limit = 1000
    }
    if f.SortBy == "" {
        f.SortBy = "created_at"
    }
    if f.SortOrder == "" {
        f.SortOrder = "desc"
    }
    return f
}
```

---

## Method Receiver Examples

### Entity Methods

```go
type Task struct {
    id          rms.ID
    title       string
    description string
    status      Status
    priority    Priority
    workflowID  rms.ID
    actorID     rms.ID
    assigneeID  rms.ID
    metadata    map[string]any
    actions     []Action
    createdAt   time.Time
    updatedAt   time.Time
}

// Getters - value or pointer receiver depending on size
func (t *Task) ID() rms.ID           { return t.id }
func (t *Task) Title() string        { return t.title }
func (t *Task) Status() Status       { return t.status }
func (t *Task) Priority() Priority   { return t.priority }
func (t *Task) WorkflowID() rms.ID   { return t.workflowID }
func (t *Task) CreatedAt() time.Time { return t.createdAt }

// Boolean methods
func (t *Task) IsComplete() bool     { return t.status == StatusComplete }
func (t *Task) IsPending() bool      { return t.status == StatusPending }
func (t *Task) HasAssignee() bool    { return t.assigneeID != "" }
func (t *Task) IsHighPriority() bool { return t.priority >= PriorityHigh }

// Setters - always pointer receiver
func (t *Task) SetTitle(title string) {
    t.title = title
    t.updatedAt = time.Now()
}

func (t *Task) SetStatus(status Status) error {
    if err := t.validateStatusTransition(status); err != nil {
        return err
    }
    t.status = status
    t.updatedAt = time.Now()
    return nil
}

func (t *Task) SetAssignee(assigneeID rms.ID) {
    t.assigneeID = assigneeID
    t.updatedAt = time.Now()
}

// Complex operations - pointer receiver
func (t *Task) AddAction(action Action) {
    t.actions = append(t.actions, action)
    t.updatedAt = time.Now()
}

func (t *Task) Complete(actorID rms.ID) error {
    if t.status == StatusComplete {
        return errors.New("task already complete")
    }
    
    t.status = StatusComplete
    t.AddAction(Action{
        Type:        ActionTypeComplete,
        ActorID:     actorID,
        PerformedAt: time.Now(),
    })
    
    return nil
}

// Validation - pointer receiver for consistency
func (t *Task) Validate() error {
    var errs []error
    
    if t.id == "" {
        errs = append(errs, errors.New("id is required"))
    }
    if t.title == "" {
        errs = append(errs, errors.New("title is required"))
    }
    if t.workflowID == "" {
        errs = append(errs, errors.New("workflow ID is required"))
    }
    
    return errors.Join(errs...)
}
```

### Value Type Methods

```go
// Small types can use value receivers
type Status string

const (
    StatusPending    Status = "PENDING"
    StatusInProgress Status = "IN_PROGRESS"
    StatusComplete   Status = "COMPLETE"
    StatusCancelled  Status = "CANCELLED"
)

func (s Status) String() string {
    return string(s)
}

func (s Status) IsTerminal() bool {
    return s == StatusComplete || s == StatusCancelled
}

func (s Status) CanTransitionTo(next Status) bool {
    switch s {
    case StatusPending:
        return next == StatusInProgress || next == StatusCancelled
    case StatusInProgress:
        return next == StatusComplete || next == StatusCancelled
    case StatusComplete, StatusCancelled:
        return false
    default:
        return false
    }
}

type Priority int

const (
    PriorityLow      Priority = 1
    PriorityMedium   Priority = 2
    PriorityHigh     Priority = 3
    PriorityCritical Priority = 4
)

func (p Priority) String() string {
    switch p {
    case PriorityLow:
        return "low"
    case PriorityMedium:
        return "medium"
    case PriorityHigh:
        return "high"
    case PriorityCritical:
        return "critical"
    default:
        return "unknown"
    }
}

func (p Priority) IsHigh() bool {
    return p >= PriorityHigh
}
```

---

## Constructor Patterns

### Simple Constructor

```go
func NewTask(id rms.ID, title string, workflowID rms.ID) *Task {
    return &Task{
        id:         id,
        title:      title,
        workflowID: workflowID,
        status:     StatusPending,
        priority:   PriorityMedium,
        metadata:   make(map[string]any),
        createdAt:  time.Now(),
        updatedAt:  time.Now(),
    }
}
```

### Constructor with Validation

```go
func NewTaskWithValidation(params CreateTaskParams) (*Task, error) {
    if err := params.Validate(); err != nil {
        return nil, fmt.Errorf("validate: %w", err)
    }
    
    task := &Task{
        id:          rms.NewID(),
        title:       params.Title,
        description: params.Description,
        workflowID:  params.WorkflowID,
        actorID:     params.ActorID,
        status:      StatusPending,
        priority:    params.Priority,
        metadata:    params.Metadata,
        createdAt:   time.Now(),
        updatedAt:   time.Now(),
    }
    
    if task.priority == 0 {
        task.priority = PriorityMedium
    }
    if task.metadata == nil {
        task.metadata = make(map[string]any)
    }
    
    return task, nil
}
```

### Factory Pattern

```go
type TaskFactory struct {
    defaultPriority Priority
    defaultStatus   Status
    validator       Validator
    idGenerator     IDGenerator
}

func NewTaskFactory(opts ...TaskFactoryOption) *TaskFactory {
    f := &TaskFactory{
        defaultPriority: PriorityMedium,
        defaultStatus:   StatusPending,
        idGenerator:     rms.NewIDGenerator(),
    }
    for _, opt := range opts {
        opt(f)
    }
    return f
}

type TaskFactoryOption func(*TaskFactory)

func WithDefaultPriority(p Priority) TaskFactoryOption {
    return func(f *TaskFactory) {
        f.defaultPriority = p
    }
}

func WithValidator(v Validator) TaskFactoryOption {
    return func(f *TaskFactory) {
        f.validator = v
    }
}

func (f *TaskFactory) Create(params CreateTaskParams) (*Task, error) {
    if f.validator != nil {
        if err := f.validator.Validate(params); err != nil {
            return nil, fmt.Errorf("validate: %w", err)
        }
    }
    
    priority := params.Priority
    if priority == 0 {
        priority = f.defaultPriority
    }
    
    return &Task{
        id:          f.idGenerator.Generate(),
        title:       params.Title,
        description: params.Description,
        workflowID:  params.WorkflowID,
        actorID:     params.ActorID,
        status:      f.defaultStatus,
        priority:    priority,
        metadata:    params.Metadata,
        createdAt:   time.Now(),
        updatedAt:   time.Now(),
    }, nil
}
```

---

## Multiple Return Values

### Pattern: Result + Error

```go
// Standard pattern
func (s *Service) Get(ctx context.Context, id rms.ID) (*Task, error)

// With boolean for existence
func (s *Cache) Get(key string) (*Task, bool)

// With count
func (s *Service) List(ctx context.Context, filter Filter) ([]*Task, int64, error)
```

### Pattern: Named Returns for Documentation

```go
// Named returns clarify complex return values
func (p *Parser) Parse(input string) (ast *AST, remaining string, err error) {
    // Implementation
}

func (c *Calculator) Divide(a, b float64) (quotient, remainder float64, err error) {
    if b == 0 {
        return 0, 0, errors.New("division by zero")
    }
    quotient = a / b
    remainder = math.Mod(a, b)
    return quotient, remainder, nil
}
```
