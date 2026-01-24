# Naming Convention Examples

Extended examples for RMS Go naming conventions.

## Real-World Naming Patterns

### Entity Types

```go
// DO: RMS entity naming
type Task struct {
    ID          rms.ID
    EntityType  rms.EntityType
    WorkflowID  rms.ID
    ItemRef     string
    ItemType    string
    ActorID     rms.ID
    Priority    Priority
    Status      Status
    CreatedAt   time.Time
    UpdatedAt   time.Time
}

type Assignment struct {
    ID         rms.ID
    TaskID     rms.ID
    AssigneeID rms.ID
    AssignedAt time.Time
    Role       AssignmentRole
}

type Action struct {
    ID          rms.ID
    TaskID      rms.ID
    ActorID     rms.ID
    Type        ActionType
    PerformedAt time.Time
    Metadata    map[string]any
}
```

### Factory Pattern Naming

```go
// DO: Factory naming
type TaskFactory struct {
    defaultPriority Priority
    defaultStatus   Status
    validator       Validator
}

// Constructor
func NewTaskFactory(opts ...TaskFactoryOption) *TaskFactory

// Factory method
func (f *TaskFactory) Create(params CreateTaskParams) (*Task, error)

// Options
type TaskFactoryOption func(*TaskFactory)

func WithDefaultPriority(p Priority) TaskFactoryOption
func WithValidator(v Validator) TaskFactoryOption
```

### Service Layer Naming

```go
// DO: Service naming
type TaskService struct {
    store      TaskStore
    publisher  EventPublisher
    validator  Validator
    logger     rms.Logger
}

func NewTaskService(
    store TaskStore,
    publisher EventPublisher,
    opts ...TaskServiceOption,
) *TaskService

func (s *TaskService) Create(ctx context.Context, params CreateTaskParams) (*Task, error)
func (s *TaskService) Get(ctx context.Context, id rms.ID) (*Task, error)
func (s *TaskService) Update(ctx context.Context, id rms.ID, updates TaskUpdates) error
func (s *TaskService) Delete(ctx context.Context, id rms.ID) error
func (s *TaskService) List(ctx context.Context, filter TaskFilter) ([]*Task, error)
```

### Repository/Store Naming

```go
// DO: Store interface naming
type TaskStore interface {
    Get(ctx context.Context, id rms.ID) (*Task, error)
    Save(ctx context.Context, task *Task) error
    Update(ctx context.Context, task *Task) error
    Delete(ctx context.Context, id rms.ID) error
    List(ctx context.Context, filter TaskFilter) ([]*Task, error)
    Count(ctx context.Context, filter TaskFilter) (int64, error)
}

// Implementation naming
type SQLTaskStore struct {
    db *sql.DB
}

type RedisTaskCache struct {
    client *redis.Client
    ttl    time.Duration
}
```

---

## Variable Naming Patterns

### Loop Variables

```go
// DO: Standard loop patterns
for i := 0; i < len(tasks); i++ {
    task := tasks[i]
    // ...
}

for i, task := range tasks {
    log.Printf("task %d: %s", i, task.ID)
}

for _, task := range tasks {
    if err := task.Validate(); err != nil {
        return err
    }
}

// Map iteration
for k, v := range metadata {
    result[k] = transform(v)
}

// Channel iteration
for msg := range ch {
    process(msg)
}
```

### Error Variables

```go
// DO: Error naming
if err := task.Validate(); err != nil {
    return fmt.Errorf("validate task: %w", err)
}

// Multiple errors - add context
result, createErr := service.Create(ctx, params)
if createErr != nil {
    return nil, createErr
}

// Named errors at package level
var (
    ErrNotFound     = errors.New("task not found")
    ErrInvalidState = errors.New("invalid task state")
    ErrUnauthorized = errors.New("unauthorized")
)
```

### Context Variables

```go
// DO: Context naming
func (s *Service) Create(ctx context.Context, params CreateParams) (*Task, error) {
    // Short name for context - always ctx
    if err := ctx.Err(); err != nil {
        return nil, err
    }
    // ...
}
```

---

## Interface Naming Patterns

### Single-Method Interfaces

```go
// DO: -er suffix for single method
type Validator interface {
    Validate() error
}

type Processor interface {
    Process(ctx context.Context, task *Task) error
}

type Transformer interface {
    Transform(input any) (output any, err error)
}

type Publisher interface {
    Publish(ctx context.Context, event Event) error
}

type Subscriber interface {
    Subscribe(ctx context.Context, topic string) (<-chan Event, error)
}
```

### Multi-Method Interfaces

```go
// DO: Descriptive nouns
type TaskStore interface {
    Get(ctx context.Context, id rms.ID) (*Task, error)
    Save(ctx context.Context, task *Task) error
    Delete(ctx context.Context, id rms.ID) error
}

type EventBus interface {
    Publish(ctx context.Context, event Event) error
    Subscribe(ctx context.Context, topic string) (<-chan Event, error)
    Unsubscribe(ctx context.Context, topic string) error
}

type MetadataProcessor interface {
    Validate(meta Metadata) error
    Transform(meta Metadata) (Metadata, error)
    Normalize(meta Metadata) Metadata
}
```

### Composed Interfaces

```go
// DO: Composed interface naming
type ReadWriter interface {
    Reader
    Writer
}

type TaskReadWriter interface {
    TaskReader
    TaskWriter
}
```

---

## Package Naming Patterns

### Good Package Names

```go
// Service packages
package task       // Task domain
package user       // User domain
package workflow   // Workflow domain

// Infrastructure packages
package sqlstore   // SQL storage
package redis      // Redis client wrapper
package kafka      // Kafka producer/consumer

// Utility packages (specific)
package timeutil   // Time utilities
package testutil   // Test utilities
package httputil   // HTTP utilities
```

### Avoiding Generic Names

```go
// DON'T: Generic package names
package util
package common
package helper
package misc
package shared

// DO: Specific package names instead
package stringutil  // String utilities
package sliceutil   // Slice utilities
package maputil     // Map utilities
```

### Package Path Conventions

```
// DO: Clear package paths
git.taservs.net/rms/taskcore/entity
git.taservs.net/rms/taskcore/factory
git.taservs.net/rms/taskcore/metadata
git.taservs.net/rms/taskcore/converter

// DON'T: Stuttering paths
git.taservs.net/rms/taskcore/task      // task.Task stutters
git.taservs.net/rms/taskcore/taskpkg   // Adds nothing
```

---

## Constant and Enum Naming

### Type-Safe Enums

```go
// DO: Typed constants with clear prefix
type TaskStatus string

const (
    TaskStatusPending    TaskStatus = "PENDING"
    TaskStatusInProgress TaskStatus = "IN_PROGRESS"
    TaskStatusComplete   TaskStatus = "COMPLETE"
    TaskStatusCancelled  TaskStatus = "CANCELLED"
)

type Priority int

const (
    PriorityLow    Priority = 1
    PriorityMedium Priority = 2
    PriorityHigh   Priority = 3
    PriorityCritical Priority = 4
)
```

### Configuration Constants

```go
// DO: Descriptive configuration constants
const (
    DefaultTimeout        = 30 * time.Second
    DefaultMaxRetries     = 3
    DefaultBatchSize      = 100
    DefaultWorkerPoolSize = 10
)
```

### Error Sentinels

```go
// DO: Clear error naming
var (
    ErrNotFound        = errors.New("not found")
    ErrAlreadyExists   = errors.New("already exists")
    ErrInvalidInput    = errors.New("invalid input")
    ErrUnauthorized    = errors.New("unauthorized")
    ErrForbidden       = errors.New("forbidden")
    ErrInternalError   = errors.New("internal error")
)
```

---

## Initialism Examples

### Common Initialisms

```go
// DO: Proper initialism casing
type UserID string
type TaskID string
type HTTPClient struct {}
type HTTPHandler struct {}
type JSONEncoder struct {}
type XMLParser struct {}
type SQLStore struct {}
type RPCClient struct {}
type APIServer struct {}
type URLBuilder struct {}

// Exported methods
func NewHTTPClient(cfg *Config) *HTTPClient
func ParseJSON(data []byte) (any, error)
func BuildURL(base string, params map[string]string) string
func (s *Store) GetByID(ctx context.Context, id rms.ID) (*Entity, error)
```

### Unexported Initialisms

```go
// DO: Lowercase initialisms when unexported
type service struct {
    httpClient *http.Client
    apiKey     string
    userID     rms.ID
}

func parseJSON(data []byte) (any, error) {
    // ...
}

func buildURL(base string) string {
    // ...
}
```

---

## Real RMS Examples

### From TaskCore

```go
// Entity naming
type Task struct { ... }
type Action struct { ... }
type Assignment struct { ... }

// Factory naming
type TaskFactory struct { ... }
func NewTaskFactory(opts ...Option) *TaskFactory
func (f *TaskFactory) Create(params CreateTaskParams) (*Task, error)

// Converter naming
type ProtoConverter struct { ... }
func (c *ProtoConverter) ToProto(task *Task) *pb.Task
func (c *ProtoConverter) FromProto(pb *pb.Task) (*Task, error)

// Metadata processor naming
type MetadataProcessor struct { ... }
func (p *MetadataProcessor) Process(meta Metadata) (Metadata, error)
```

### From Zeke Services

```go
// Service naming
type TaskService struct { ... }
type ConfigService struct { ... }
type SearchService struct { ... }

// Handler naming
type TaskHandler struct { ... }
type ConfigHandler struct { ... }

// Client naming
type ZekeClient struct { ... }
type KafkaPublisher struct { ... }
```
