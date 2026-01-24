---
description: Enforces RMS Go testing patterns including table-driven tests, testify assertions, and mocking conventions. Use when reviewing test files, creating new tests, or seeing test anti-patterns.
---

# Testing

## Purpose

Establish consistent testing patterns for RMS Go code. Well-written tests are documentation, catch regressions, and enable confident refactoring.

## Core Principles

1. **Table-driven tests** - Preferred pattern for testing multiple cases
2. **Use testify** - For readable assertions
3. **Clear test names** - Describe what's being tested
4. **Mock interfaces** - Not concrete implementations
5. **Test behavior** - Not implementation details

---

## Table-Driven Tests

### Basic Pattern

```go
func TestValidateTask(t *testing.T) {
    tests := []struct {
        name    string
        task    *Task
        wantErr bool
    }{
        {
            name: "valid task",
            task: &Task{
                ID:         "task-1",
                Title:      "Test Task",
                WorkflowID: "workflow-1",
            },
            wantErr: false,
        },
        {
            name:    "nil task",
            task:    nil,
            wantErr: true,
        },
        {
            name: "missing title",
            task: &Task{
                ID:         "task-1",
                WorkflowID: "workflow-1",
            },
            wantErr: true,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateTask(tt.task)
            if tt.wantErr {
                assert.Error(t, err)
            } else {
                assert.NoError(t, err)
            }
        })
    }
}
```

### With Setup and Expected Values

```go
func TestTaskService_Create(t *testing.T) {
    tests := []struct {
        name       string
        params     CreateTaskParams
        setupMock  func(*MockTaskStore)
        want       *Task
        wantErr    bool
        wantErrMsg string
    }{
        {
            name: "success",
            params: CreateTaskParams{
                Title:      "New Task",
                WorkflowID: "workflow-1",
                ActorID:    "actor-1",
            },
            setupMock: func(m *MockTaskStore) {
                m.On("Save", mock.Anything, mock.Anything).Return(nil)
            },
            want: &Task{
                Title:      "New Task",
                WorkflowID: "workflow-1",
                Status:     StatusPending,
            },
            wantErr: false,
        },
        {
            name: "store error",
            params: CreateTaskParams{
                Title:      "New Task",
                WorkflowID: "workflow-1",
                ActorID:    "actor-1",
            },
            setupMock: func(m *MockTaskStore) {
                m.On("Save", mock.Anything, mock.Anything).Return(errors.New("db error"))
            },
            wantErr:    true,
            wantErrMsg: "save task",
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            store := new(MockTaskStore)
            if tt.setupMock != nil {
                tt.setupMock(store)
            }
            
            service := NewTaskService(store)
            got, err := service.Create(context.Background(), tt.params)
            
            if tt.wantErr {
                assert.Error(t, err)
                if tt.wantErrMsg != "" {
                    assert.Contains(t, err.Error(), tt.wantErrMsg)
                }
                return
            }
            
            assert.NoError(t, err)
            assert.Equal(t, tt.want.Title, got.Title)
            assert.Equal(t, tt.want.WorkflowID, got.WorkflowID)
            assert.Equal(t, tt.want.Status, got.Status)
            
            store.AssertExpectations(t)
        })
    }
}
```

---

## Testify Assertions

### Basic Assertions

```go
import (
    "testing"
    
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestExample(t *testing.T) {
    // Equality
    assert.Equal(t, expected, actual)
    assert.NotEqual(t, a, b)
    
    // Boolean
    assert.True(t, condition)
    assert.False(t, condition)
    
    // Nil checks
    assert.Nil(t, value)
    assert.NotNil(t, value)
    
    // Error checks
    assert.NoError(t, err)
    assert.Error(t, err)
    assert.ErrorIs(t, err, ErrNotFound)
    assert.ErrorContains(t, err, "not found")
    
    // Collections
    assert.Len(t, slice, 3)
    assert.Empty(t, slice)
    assert.Contains(t, slice, item)
    
    // Strings
    assert.Contains(t, str, substring)
    assert.HasPrefix(t, str, prefix)
}
```

### Assert vs Require

```go
func TestWithRequire(t *testing.T) {
    // require stops test immediately on failure
    result, err := service.Get(ctx, id)
    require.NoError(t, err)  // Stops here if error
    require.NotNil(t, result)  // Won't run if above fails
    
    // assert continues test after failure
    assert.Equal(t, expected.Title, result.Title)
    assert.Equal(t, expected.Status, result.Status)
}
```

### Custom Messages

```go
func TestWithMessages(t *testing.T) {
    assert.Equal(t, expected, actual, "task title should match")
    assert.NoError(t, err, "creating task should not error")
}
```

---

## Mocking

### Mock Generation

```go
// Use mockery to generate mocks
//go:generate mockery --name=TaskStore --output=mocks --outpkg=mocks

// Interface to mock
type TaskStore interface {
    Get(ctx context.Context, id rms.ID) (*Task, error)
    Save(ctx context.Context, task *Task) error
    Delete(ctx context.Context, id rms.ID) error
}
```

### Using Mocks

```go
func TestTaskService_Get(t *testing.T) {
    store := new(mocks.TaskStore)
    
    expectedTask := &Task{ID: "task-1", Title: "Test"}
    store.On("Get", mock.Anything, rms.ID("task-1")).Return(expectedTask, nil)
    
    service := NewTaskService(store)
    task, err := service.Get(context.Background(), "task-1")
    
    assert.NoError(t, err)
    assert.Equal(t, expectedTask, task)
    
    store.AssertExpectations(t)
}
```

### Mock Patterns

```go
// Match any argument
store.On("Get", mock.Anything, mock.Anything).Return(task, nil)

// Match specific argument
store.On("Get", mock.Anything, rms.ID("task-1")).Return(task, nil)

// Match with function
store.On("Save", mock.Anything, mock.MatchedBy(func(t *Task) bool {
    return t.Title == "Expected Title"
})).Return(nil)

// Return error
store.On("Get", mock.Anything, mock.Anything).Return(nil, ErrNotFound)

// Return different values on successive calls
store.On("Get", mock.Anything, mock.Anything).Return(nil, ErrNotFound).Once()
store.On("Get", mock.Anything, mock.Anything).Return(task, nil).Once()
```

---

## Test Naming

### Naming Convention

```go
// Pattern: Test<Type>_<Method>
func TestTaskService_Create(t *testing.T) {}
func TestTaskService_Get(t *testing.T) {}
func TestTaskService_Update(t *testing.T) {}

// Pattern: Test<Function>
func TestValidateTask(t *testing.T) {}
func TestParseTaskID(t *testing.T) {}

// Subtest names describe scenarios
t.Run("valid task", func(t *testing.T) {})
t.Run("missing title returns error", func(t *testing.T) {})
t.Run("not found returns ErrNotFound", func(t *testing.T) {})
```

---

## Test Helpers

### Setup Functions

```go
func setupTestService(t *testing.T) (*TaskService, *MockTaskStore) {
    t.Helper()
    
    store := new(MockTaskStore)
    service := NewTaskService(store)
    
    return service, store
}

func TestTaskService_Create(t *testing.T) {
    service, store := setupTestService(t)
    
    store.On("Save", mock.Anything, mock.Anything).Return(nil)
    // ...
}
```

### Test Fixtures

```go
func newTestTask(t *testing.T, opts ...func(*Task)) *Task {
    t.Helper()
    
    task := &Task{
        ID:         rms.ID("test-task-" + uuid.New().String()[:8]),
        Title:      "Test Task",
        WorkflowID: "workflow-1",
        ActorID:    "actor-1",
        Status:     StatusPending,
        Priority:   PriorityMedium,
        CreatedAt:  time.Now(),
        UpdatedAt:  time.Now(),
    }
    
    for _, opt := range opts {
        opt(task)
    }
    
    return task
}

func withTitle(title string) func(*Task) {
    return func(t *Task) {
        t.Title = title
    }
}

func withStatus(status Status) func(*Task) {
    return func(t *Task) {
        t.Status = status
    }
}

// Usage
task := newTestTask(t, withTitle("Custom Title"), withStatus(StatusComplete))
```

---

## Testing Errors

### Error Checking

```go
func TestTaskService_Get_NotFound(t *testing.T) {
    service, store := setupTestService(t)
    
    store.On("Get", mock.Anything, mock.Anything).Return(nil, ErrNotFound)
    
    _, err := service.Get(context.Background(), "nonexistent")
    
    assert.Error(t, err)
    assert.ErrorIs(t, err, ErrNotFound)
}

func TestTaskService_Create_ValidationError(t *testing.T) {
    service, _ := setupTestService(t)
    
    params := CreateTaskParams{} // Invalid - missing required fields
    
    _, err := service.Create(context.Background(), params)
    
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "title")
}
```

---

## Parallel Tests

```go
func TestTaskOperations(t *testing.T) {
    t.Parallel()  // Run this test in parallel with others
    
    tests := []struct {
        name string
        // ...
    }{
        // ...
    }
    
    for _, tt := range tests {
        tt := tt  // Capture for parallel
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel()  // Run subtests in parallel
            // ...
        })
    }
}
```

---

## Quick Reference

| Pattern | When to Use |
|---------|-------------|
| Table-driven | Multiple test cases |
| `assert` | Soft assertions (continue on fail) |
| `require` | Hard assertions (stop on fail) |
| Subtests | Group related tests |
| Helpers | Reduce duplication |
| Mocks | Isolate unit under test |

### Test Checklist

- [ ] Using table-driven tests for multiple cases?
- [ ] Clear, descriptive test names?
- [ ] Using testify assertions?
- [ ] Mocking dependencies (not implementations)?
- [ ] Testing error cases?
- [ ] Using t.Helper() in helpers?

---

## See Also

- [TABLE-DRIVEN.md](./TABLE-DRIVEN.md) - Table-driven test templates
- [MOCKING.md](./MOCKING.md) - Mock generation and usage
- [error-handling](../error-handling/Skill.md) - Error testing patterns
