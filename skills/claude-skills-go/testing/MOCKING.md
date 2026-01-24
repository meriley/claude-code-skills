# Mocking Guide

Patterns for generating and using mocks in RMS Go tests.

## Mock Generation

### Using mockery

```bash
# Install mockery
go install github.com/vektra/mockery/v2@latest

# Generate mock for single interface
mockery --name=TaskStore --output=mocks --outpkg=mocks

# Generate mocks for all interfaces in package
mockery --all --output=mocks --outpkg=mocks

# Generate with go:generate directive
```

### Go Generate Directive

```go
// In your interface file
//go:generate mockery --name=TaskStore --output=mocks --outpkg=mocks
//go:generate mockery --name=EventPublisher --output=mocks --outpkg=mocks

type TaskStore interface {
    Get(ctx context.Context, id rms.ID) (*Task, error)
    Save(ctx context.Context, task *Task) error
    Delete(ctx context.Context, id rms.ID) error
    List(ctx context.Context, filter TaskFilter) ([]*Task, error)
}

type EventPublisher interface {
    Publish(ctx context.Context, event Event) error
}
```

Run with:
```bash
go generate ./...
```

---

## Using Mocks

### Basic Setup

```go
import (
    "testing"
    
    "github.com/stretchr/testify/mock"
    "your/package/mocks"
)

func TestService_Create(t *testing.T) {
    // Create mock
    mockStore := new(mocks.TaskStore)
    
    // Setup expectations
    mockStore.On("Save", mock.Anything, mock.Anything).Return(nil)
    
    // Use mock
    service := NewTaskService(mockStore)
    task, err := service.Create(context.Background(), params)
    
    // Verify
    assert.NoError(t, err)
    mockStore.AssertExpectations(t)
}
```

### Argument Matchers

```go
// Match any argument
mockStore.On("Get", mock.Anything, mock.Anything).Return(task, nil)

// Match specific value
mockStore.On("Get", mock.Anything, rms.ID("task-123")).Return(task, nil)

// Match with type assertion
mockStore.On("Get", mock.AnythingOfType("context.Context"), mock.AnythingOfType("rms.ID")).Return(task, nil)

// Match with custom function
mockStore.On("Save", mock.Anything, mock.MatchedBy(func(t *Task) bool {
    return t.Title == "Expected Title" && t.Status == StatusPending
})).Return(nil)

// Match struct by field
mockStore.On("Save", mock.Anything, mock.MatchedBy(func(t *Task) bool {
    return t.WorkflowID == "workflow-1"
})).Return(nil)
```

### Return Values

```go
// Return single value
mockStore.On("Delete", mock.Anything, mock.Anything).Return(nil)

// Return multiple values
mockStore.On("Get", mock.Anything, mock.Anything).Return(task, nil)

// Return error
mockStore.On("Get", mock.Anything, mock.Anything).Return(nil, ErrNotFound)

// Return dynamically
mockStore.On("Get", mock.Anything, mock.Anything).Return(func(ctx context.Context, id rms.ID) (*Task, error) {
    return &Task{ID: id, Title: "Dynamic"}, nil
})
```

### Call Counting

```go
// Expect once
mockStore.On("Save", mock.Anything, mock.Anything).Return(nil).Once()

// Expect exactly N times
mockStore.On("Get", mock.Anything, mock.Anything).Return(task, nil).Times(3)

// Different returns on successive calls
mockStore.On("Get", mock.Anything, mock.Anything).Return(nil, ErrNotFound).Once()
mockStore.On("Get", mock.Anything, mock.Anything).Return(task, nil).Once()
```

### Verification

```go
// Verify all expectations met
mockStore.AssertExpectations(t)

// Verify specific calls
mockStore.AssertCalled(t, "Save", mock.Anything, mock.Anything)
mockStore.AssertNotCalled(t, "Delete", mock.Anything, mock.Anything)

// Verify call count
mockStore.AssertNumberOfCalls(t, "Get", 2)
```

---

## Mock Patterns

### Setup Function

```go
func setupMocks(t *testing.T) (*TaskService, *mocks.TaskStore, *mocks.EventPublisher) {
    t.Helper()
    
    store := new(mocks.TaskStore)
    publisher := new(mocks.EventPublisher)
    service := NewTaskService(store, WithPublisher(publisher))
    
    return service, store, publisher
}

func TestService_Create(t *testing.T) {
    service, store, publisher := setupMocks(t)
    
    store.On("Save", mock.Anything, mock.Anything).Return(nil)
    publisher.On("Publish", mock.Anything, mock.Anything).Return(nil)
    
    // Test...
    
    store.AssertExpectations(t)
    publisher.AssertExpectations(t)
}
```

### Per-Test Mock Setup

```go
func TestService_Operations(t *testing.T) {
    tests := []struct {
        name      string
        setupMock func(*mocks.TaskStore)
        // ...
    }{
        {
            name: "success",
            setupMock: func(m *mocks.TaskStore) {
                m.On("Get", mock.Anything, mock.Anything).Return(task, nil)
                m.On("Save", mock.Anything, mock.Anything).Return(nil)
            },
        },
        {
            name: "get fails",
            setupMock: func(m *mocks.TaskStore) {
                m.On("Get", mock.Anything, mock.Anything).Return(nil, ErrNotFound)
            },
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            store := new(mocks.TaskStore)
            if tt.setupMock != nil {
                tt.setupMock(store)
            }
            
            service := NewTaskService(store)
            // Test...
            
            store.AssertExpectations(t)
        })
    }
}
```

### Mock Builder

```go
type MockStoreBuilder struct {
    mock *mocks.TaskStore
}

func NewMockStoreBuilder() *MockStoreBuilder {
    return &MockStoreBuilder{mock: new(mocks.TaskStore)}
}

func (b *MockStoreBuilder) WithTask(id rms.ID, task *Task) *MockStoreBuilder {
    b.mock.On("Get", mock.Anything, id).Return(task, nil)
    return b
}

func (b *MockStoreBuilder) WithNotFound(id rms.ID) *MockStoreBuilder {
    b.mock.On("Get", mock.Anything, id).Return(nil, ErrNotFound)
    return b
}

func (b *MockStoreBuilder) WithSaveSuccess() *MockStoreBuilder {
    b.mock.On("Save", mock.Anything, mock.Anything).Return(nil)
    return b
}

func (b *MockStoreBuilder) Build() *mocks.TaskStore {
    return b.mock
}

// Usage
store := NewMockStoreBuilder().
    WithTask("task-1", testTask).
    WithSaveSuccess().
    Build()
```

---

## Hand-Written Mocks

For simple interfaces, hand-written mocks can be cleaner:

```go
type mockTaskStore struct {
    getFunc    func(ctx context.Context, id rms.ID) (*Task, error)
    saveFunc   func(ctx context.Context, task *Task) error
    deleteFunc func(ctx context.Context, id rms.ID) error
}

func (m *mockTaskStore) Get(ctx context.Context, id rms.ID) (*Task, error) {
    if m.getFunc != nil {
        return m.getFunc(ctx, id)
    }
    return nil, nil
}

func (m *mockTaskStore) Save(ctx context.Context, task *Task) error {
    if m.saveFunc != nil {
        return m.saveFunc(ctx, task)
    }
    return nil
}

func (m *mockTaskStore) Delete(ctx context.Context, id rms.ID) error {
    if m.deleteFunc != nil {
        return m.deleteFunc(ctx, id)
    }
    return nil
}

// Usage
store := &mockTaskStore{
    getFunc: func(ctx context.Context, id rms.ID) (*Task, error) {
        return &Task{ID: id, Title: "Test"}, nil
    },
}
```

---

## Best Practices

### DO

- Mock interfaces, not concrete types
- Use `mock.Anything` for irrelevant parameters
- Verify expectations with `AssertExpectations`
- Create setup helpers for common mock configurations
- Use `t.Helper()` in setup functions

### DON'T

- Mock types you don't own (standard library, etc.)
- Create mocks with too many expectations
- Forget to verify mock expectations
- Use mocks when a real implementation is simple enough
