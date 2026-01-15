
## Common Pitfalls to Avoid

### 1. Paraphrasing Signatures

```markdown
❌ BAD - Simplified signature
func Create(params CreateParams) (Task, error)

✅ GOOD - Exact signature from source
func (s *TaskService) Create(ctx rms.Ctx, params *CreateTaskParams) (\*entity.Task, error)
```

### 2. Fabricating Methods

```markdown
❌ BAD - Method doesn't exist

### Method: TaskService.UpdateStatus

Updates the status of a task
[This method was never in the source code!]

✅ GOOD - Only document methods that exist
[Check source first, only document what exists]
```

### 3. Wrong Parameter Types

```markdown
❌ BAD - Wrong type

- `taskId` (string): Task identifier

✅ GOOD - Correct type from source

- `taskId` (TaskId): Task identifier (branded type)
```

### 4. Missing Error Conditions

```markdown
❌ BAD - Vague error description
Returns error if operation fails

✅ GOOD - Specific error conditions from code
Returns error if:

- taskId is empty string
- task not found in database
- user lacks permission (PermissionError)
```

### 5. Invalid Examples

````markdown
❌ BAD - Won't compile

```go
task := CreateTask(params)
```
````

✅ GOOD - Complete, working example

```go
import "github.com/org/pkg/services"

service := services.NewTaskService(db)
task, err := service.Create(ctx, params)
if err != nil {
    return fmt.Errorf("failed to create task: %w", err)
}
```

### 6. Using Line Numbers

```markdown
❌ BAD - Line numbers become outdated
**Source**: `services/task.go:145`

✅ GOOD - Use method names
**Source**: `services/task.go` (Create method)
```

### 7. Marketing Language

```markdown
❌ BAD - Marketing buzzwords
The TaskService provides blazing-fast, enterprise-grade task management

✅ GOOD - Technical description
The TaskService provides CRUD operations for task entities
