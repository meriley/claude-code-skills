# Struct and Interface Examples

Extended examples for RMS Go struct and interface design.

## Service Interface Patterns

### Repository Pattern

```go
// Consumer-defined interface in service package
package service

// Define only what the service needs
type TaskReader interface {
    Get(ctx context.Context, id rms.ID) (*Task, error)
    GetByWorkflow(ctx context.Context, workflowID rms.ID) ([]*Task, error)
}

type TaskWriter interface {
    Save(ctx context.Context, task *Task) error
    Delete(ctx context.Context, id rms.ID) error
}

type TaskStore interface {
    TaskReader
    TaskWriter
}

// Service depends on interface
type TaskService struct {
    store TaskStore
}

func NewTaskService(store TaskStore) *TaskService {
    return &TaskService{store: store}
}
```

```go
// Implementation in separate package
package sqlstore

type SQLTaskStore struct {
    db *sql.DB
}

func NewSQLTaskStore(db *sql.DB) *SQLTaskStore {
    return &SQLTaskStore{db: db}
}

// Implements service.TaskStore implicitly
func (s *SQLTaskStore) Get(ctx context.Context, id rms.ID) (*task.Task, error) {
    // SQL implementation
}

func (s *SQLTaskStore) GetByWorkflow(ctx context.Context, workflowID rms.ID) ([]*task.Task, error) {
    // SQL implementation
}

func (s *SQLTaskStore) Save(ctx context.Context, t *task.Task) error {
    // SQL implementation
}

func (s *SQLTaskStore) Delete(ctx context.Context, id rms.ID) error {
    // SQL implementation
}
```

### Caching Decorator

```go
// Decorator using embedding
type CachingTaskStore struct {
    TaskStore  // Embed the interface
    cache      *cache.Cache[rms.ID, *Task]
    ttl        time.Duration
}

func NewCachingTaskStore(store TaskStore, ttl time.Duration) *CachingTaskStore {
    return &CachingTaskStore{
        TaskStore: store,
        cache:     cache.New[rms.ID, *Task](),
        ttl:       ttl,
    }
}

// Override Get to check cache first
func (s *CachingTaskStore) Get(ctx context.Context, id rms.ID) (*Task, error) {
    // Check cache
    if task, ok := s.cache.Get(id); ok {
        return task, nil
    }
    
    // Cache miss - call underlying store
    task, err := s.TaskStore.Get(ctx, id)
    if err != nil {
        return nil, err
    }
    
    // Cache the result
    s.cache.SetWithTTL(id, task, s.ttl)
    return task, nil
}

// Override Save to invalidate cache
func (s *CachingTaskStore) Save(ctx context.Context, task *Task) error {
    if err := s.TaskStore.Save(ctx, task); err != nil {
        return err
    }
    s.cache.Delete(task.ID)
    return nil
}

// Delete, GetByWorkflow delegate to embedded TaskStore
```

---

## Entity Struct Patterns

### Domain Entity

```go
type Task struct {
    // Identity - always first
    id rms.ID
    
    // References
    workflowID rms.ID
    actorID    rms.ID
    assigneeID rms.ID
    
    // Core data
    title       string
    description string
    itemRef     string
    itemType    string
    
    // State
    status   Status
    priority Priority
    
    // Collections
    actions    []Action
    metadata   map[string]any
    tags       []string
    
    // Timestamps
    createdAt time.Time
    updatedAt time.Time
    dueDate   *time.Time
}

// Constructor
func NewTask(params CreateTaskParams) (*Task, error) {
    if err := params.Validate(); err != nil {
        return nil, fmt.Errorf("validate: %w", err)
    }
    
    now := time.Now()
    return &Task{
        id:          rms.NewID(),
        workflowID:  params.WorkflowID,
        actorID:     params.ActorID,
        title:       params.Title,
        description: params.Description,
        itemRef:     params.ItemRef,
        itemType:    params.ItemType,
        status:      StatusPending,
        priority:    params.Priority.OrDefault(PriorityMedium),
        metadata:    params.Metadata.OrEmpty(),
        tags:        params.Tags,
        createdAt:   now,
        updatedAt:   now,
        dueDate:     params.DueDate,
    }, nil
}

// Getters
func (t *Task) ID() rms.ID             { return t.id }
func (t *Task) WorkflowID() rms.ID     { return t.workflowID }
func (t *Task) ActorID() rms.ID        { return t.actorID }
func (t *Task) AssigneeID() rms.ID     { return t.assigneeID }
func (t *Task) Title() string          { return t.title }
func (t *Task) Description() string    { return t.description }
func (t *Task) Status() Status         { return t.status }
func (t *Task) Priority() Priority     { return t.priority }
func (t *Task) CreatedAt() time.Time   { return t.createdAt }
func (t *Task) UpdatedAt() time.Time   { return t.updatedAt }
func (t *Task) DueDate() *time.Time    { return t.dueDate }

// Boolean methods
func (t *Task) IsComplete() bool   { return t.status == StatusComplete }
func (t *Task) IsCancelled() bool  { return t.status == StatusCancelled }
func (t *Task) IsTerminal() bool   { return t.status.IsTerminal() }
func (t *Task) HasAssignee() bool  { return t.assigneeID != "" }
func (t *Task) IsOverdue() bool {
    return t.dueDate != nil && time.Now().After(*t.dueDate)
}

// State transitions
func (t *Task) Start(actorID rms.ID) error {
    if t.status != StatusPending {
        return fmt.Errorf("cannot start task in %s status", t.status)
    }
    
    t.status = StatusInProgress
    t.recordAction(ActionTypeStart, actorID)
    return nil
}

func (t *Task) Complete(actorID rms.ID) error {
    if t.status.IsTerminal() {
        return fmt.Errorf("task already in terminal status: %s", t.status)
    }
    
    t.status = StatusComplete
    t.recordAction(ActionTypeComplete, actorID)
    return nil
}

func (t *Task) Cancel(actorID rms.ID, reason string) error {
    if t.status.IsTerminal() {
        return fmt.Errorf("task already in terminal status: %s", t.status)
    }
    
    t.status = StatusCancelled
    t.recordAction(ActionTypeCancel, actorID, WithReason(reason))
    return nil
}

func (t *Task) Assign(assigneeID, actorID rms.ID) error {
    t.assigneeID = assigneeID
    t.recordAction(ActionTypeAssign, actorID, 
        WithData("assigneeId", string(assigneeID)))
    return nil
}

// Internal helper
func (t *Task) recordAction(actionType ActionType, actorID rms.ID, opts ...ActionOption) {
    action := Action{
        ID:          rms.NewID(),
        TaskID:      t.id,
        Type:        actionType,
        ActorID:     actorID,
        PerformedAt: time.Now(),
    }
    for _, opt := range opts {
        opt(&action)
    }
    
    t.actions = append(t.actions, action)
    t.updatedAt = time.Now()
}
```

### Data Transfer Object (DTO)

```go
// DTOs have exported fields for serialization
type TaskDTO struct {
    ID          string            `json:"id"`
    WorkflowID  string            `json:"workflowId"`
    ActorID     string            `json:"actorId"`
    AssigneeID  string            `json:"assigneeId,omitempty"`
    Title       string            `json:"title"`
    Description string            `json:"description,omitempty"`
    Status      string            `json:"status"`
    Priority    int               `json:"priority"`
    Metadata    map[string]any    `json:"metadata,omitempty"`
    Tags        []string          `json:"tags,omitempty"`
    CreatedAt   string            `json:"createdAt"`
    UpdatedAt   string            `json:"updatedAt"`
    DueDate     *string           `json:"dueDate,omitempty"`
}

// Converter
type TaskConverter struct{}

func (c *TaskConverter) ToDTO(task *Task) *TaskDTO {
    dto := &TaskDTO{
        ID:          string(task.ID()),
        WorkflowID:  string(task.WorkflowID()),
        ActorID:     string(task.ActorID()),
        Title:       task.Title(),
        Description: task.Description(),
        Status:      string(task.Status()),
        Priority:    int(task.Priority()),
        Metadata:    task.Metadata(),
        Tags:        task.Tags(),
        CreatedAt:   task.CreatedAt().Format(time.RFC3339),
        UpdatedAt:   task.UpdatedAt().Format(time.RFC3339),
    }
    
    if task.AssigneeID() != "" {
        dto.AssigneeID = string(task.AssigneeID())
    }
    
    if task.DueDate() != nil {
        s := task.DueDate().Format(time.RFC3339)
        dto.DueDate = &s
    }
    
    return dto
}
```

---

## Embedding Patterns

### Struct Embedding for Reuse

```go
// Base timestamps type
type Timestamps struct {
    CreatedAt time.Time
    UpdatedAt time.Time
}

func (t *Timestamps) Touch() {
    t.UpdatedAt = time.Now()
}

// Base audit type
type AuditInfo struct {
    Timestamps
    CreatedBy rms.ID
    UpdatedBy rms.ID
}

func (a *AuditInfo) SetCreator(userID rms.ID) {
    a.CreatedBy = userID
    a.CreatedAt = time.Now()
    a.UpdatedAt = time.Now()
}

func (a *AuditInfo) SetUpdater(userID rms.ID) {
    a.UpdatedBy = userID
    a.UpdatedAt = time.Now()
}

// Entities embed audit info
type Task struct {
    ID       rms.ID
    Title    string
    Status   Status
    AuditInfo // Embedded
}

// Usage
task := &Task{ID: rms.NewID(), Title: "Example"}
task.SetCreator(userID)  // From AuditInfo
task.Touch()             // From Timestamps via AuditInfo
```

### Interface Embedding for Composition

```go
// Combine interfaces
type ReadWriter interface {
    Reader
    Writer
}

type TaskRepository interface {
    TaskReader
    TaskWriter
    TaskSearcher
}

// Embed in struct for delegation
type LoggingStore struct {
    TaskStore
    logger rms.Logger
}

func (s *LoggingStore) Get(ctx context.Context, id rms.ID) (*Task, error) {
    s.logger.Debug("getting task", "id", id)
    
    task, err := s.TaskStore.Get(ctx, id)
    if err != nil {
        s.logger.Error("get task failed", "id", id, "error", err)
        return nil, err
    }
    
    s.logger.Debug("got task", "id", id, "status", task.Status())
    return task, nil
}

// Other methods delegate automatically
```

---

## Interface Satisfaction Patterns

### Compile-Time Verification

```go
// Verify interface satisfaction at compile time
var (
    _ TaskStore     = (*SQLTaskStore)(nil)
    _ TaskStore     = (*CachingTaskStore)(nil)
    _ TaskStore     = (*LoggingStore)(nil)
    _ io.ReadWriter = (*Buffer)(nil)
    _ fmt.Stringer  = (*Task)(nil)
    _ error         = (*TaskError)(nil)
)
```

### Optional Interface Implementation

```go
// Check if type implements optional interface
type Validator interface {
    Validate() error
}

func process(entity any) error {
    // Check if entity implements Validator
    if v, ok := entity.(Validator); ok {
        if err := v.Validate(); err != nil {
            return fmt.Errorf("validate: %w", err)
        }
    }
    
    // Continue processing
    return nil
}
```

---

## Type Patterns

### Type Definitions for Domain Types

```go
// Define distinct types for type safety
type TaskID string
type WorkflowID string
type UserID string

func (id TaskID) String() string    { return string(id) }
func (id WorkflowID) String() string { return string(id) }
func (id UserID) String() string    { return string(id) }

// These are different types - compile-time safety
func AssignTask(taskID TaskID, userID UserID) error {
    // Can't accidentally pass WorkflowID
    return nil
}

// Usage
var taskID TaskID = "task-123"
var userID UserID = "user-456"
var workflowID WorkflowID = "workflow-789"

AssignTask(taskID, userID)    // OK
// AssignTask(workflowID, userID)  // Compile error!
```

### Enum Types

```go
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

func (s Status) IsActive() bool {
    return s == StatusPending || s == StatusInProgress
}

func (s Status) CanTransitionTo(next Status) bool {
    transitions := map[Status][]Status{
        StatusPending:    {StatusInProgress, StatusCancelled},
        StatusInProgress: {StatusComplete, StatusCancelled},
        StatusComplete:   {},
        StatusCancelled:  {},
    }
    
    for _, valid := range transitions[s] {
        if valid == next {
            return true
        }
    }
    return false
}

func ParseStatus(s string) (Status, error) {
    switch Status(s) {
    case StatusPending, StatusInProgress, StatusComplete, StatusCancelled:
        return Status(s), nil
    default:
        return "", fmt.Errorf("invalid status: %s", s)
    }
}
```

---

## Nil-Safe Patterns

```go
// Nil-safe getters
func (t *Task) SafeTitle() string {
    if t == nil {
        return ""
    }
    return t.title
}

func (t *Task) SafeStatus() Status {
    if t == nil {
        return StatusPending // or a zero value
    }
    return t.status
}

// Nil-safe collection access
func (t *Task) SafeMetadata() map[string]any {
    if t == nil || t.metadata == nil {
        return make(map[string]any)
    }
    return t.metadata
}

func (t *Task) MetadataValue(key string) (any, bool) {
    if t == nil || t.metadata == nil {
        return nil, false
    }
    v, ok := t.metadata[key]
    return v, ok
}
```
