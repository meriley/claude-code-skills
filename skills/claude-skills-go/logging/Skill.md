---
description: Enforces RMS logging standards using rms.Logger and slog for structured logging. Use when reviewing logging code, adding log statements, or seeing inconsistent log formats.
---

# Logging

## Purpose

Establish consistent logging patterns for RMS Go code. Proper logging is essential for debugging, monitoring, and incident response.

## Core Principles

1. **Use structured logging** - Key-value pairs, not formatted strings
2. **Use appropriate levels** - Debug, Info, Warn, Error
3. **Include context** - Request IDs, user IDs, entity IDs
4. **Avoid sensitive data** - Never log passwords, tokens, PII

---

## RMS Logger

### Basic Usage

```go
// DO: Use rms.Logger
type Service struct {
    logger rms.Logger
}

func NewService(logger rms.Logger) *Service {
    return &Service{logger: logger}
}

func (s *Service) ProcessTask(ctx context.Context, id rms.ID) error {
    s.logger.Info("processing task", "taskID", id)
    
    task, err := s.getTask(ctx, id)
    if err != nil {
        s.logger.Error("get task failed", "taskID", id, "error", err)
        return err
    }
    
    s.logger.Debug("task retrieved", "taskID", id, "status", task.Status)
    return nil
}
```

### Log Levels

| Level | When to Use |
|-------|-------------|
| `Debug` | Detailed information for debugging |
| `Info` | Normal operational events |
| `Warn` | Recoverable issues, degraded operation |
| `Error` | Errors that need attention |

```go
// Debug: Detailed diagnostic info
s.logger.Debug("cache lookup", "key", key, "hit", hit)
s.logger.Debug("query executed", "query", query, "duration", duration)

// Info: Normal operations
s.logger.Info("task created", "taskID", task.ID, "workflowID", task.WorkflowID)
s.logger.Info("request completed", "method", r.Method, "path", r.URL.Path)

// Warn: Concerning but recoverable
s.logger.Warn("retry attempt", "attempt", attempt, "maxRetries", maxRetries, "error", err)
s.logger.Warn("deprecated API called", "endpoint", endpoint)

// Error: Requires attention
s.logger.Error("database connection failed", "error", err)
s.logger.Error("task processing failed", "taskID", id, "error", err)
```

---

## Structured Logging with slog

### Basic slog Usage

```go
import "log/slog"

// DO: Structured key-value pairs
slog.Info("task created",
    "taskID", task.ID,
    "workflowID", task.WorkflowID,
    "status", task.Status,
)

// DON'T: Formatted strings
slog.Info(fmt.Sprintf("task %s created in workflow %s", task.ID, task.WorkflowID))
```

### Typed Attributes

```go
// DO: Use slog.Attr for typed values
slog.Info("request handled",
    slog.String("method", r.Method),
    slog.String("path", r.URL.Path),
    slog.Int("status", statusCode),
    slog.Duration("latency", duration),
)

// DO: Group related attributes
slog.Info("task updated",
    slog.Group("task",
        slog.String("id", string(task.ID)),
        slog.String("status", string(task.Status)),
    ),
    slog.Group("actor",
        slog.String("id", string(actorID)),
    ),
)
```

### Context-Aware Logging

```go
// DO: Extract context values for logging
func (s *Service) HandleRequest(ctx context.Context, req Request) error {
    // Get request ID from context
    requestID := middleware.GetRequestID(ctx)
    userID := auth.GetUserID(ctx)
    
    s.logger.Info("handling request",
        "requestID", requestID,
        "userID", userID,
        "action", req.Action,
    )
    
    // ...
}

// DO: Create child logger with context
func (s *Service) ProcessTask(ctx context.Context, task *Task) error {
    logger := s.logger.With(
        "taskID", task.ID,
        "workflowID", task.WorkflowID,
    )
    
    logger.Info("starting task processing")
    
    if err := s.validate(task); err != nil {
        logger.Error("validation failed", "error", err)
        return err
    }
    
    logger.Info("task processing complete")
    return nil
}
```

---

## What to Log

### DO Log

```go
// Service boundaries
s.logger.Info("API request received", "method", method, "path", path)
s.logger.Info("gRPC call completed", "method", method, "duration", duration)

// State changes
s.logger.Info("task status changed", "taskID", id, "from", oldStatus, "to", newStatus)
s.logger.Info("user assigned to task", "taskID", id, "assigneeID", assigneeID)

// Errors with context
s.logger.Error("database query failed", "query", queryName, "error", err)
s.logger.Error("external API error", "service", serviceName, "status", status, "error", err)

// Performance metrics
s.logger.Info("batch processed", "count", count, "duration", duration)
s.logger.Debug("cache stats", "hits", hits, "misses", misses, "ratio", hitRatio)

// Business events
s.logger.Info("task completed", "taskID", id, "duration", time.Since(startTime))
s.logger.Info("workflow triggered", "workflowID", workflowID, "trigger", trigger)
```

### DON'T Log

```go
// DON'T: Sensitive data
s.logger.Info("user login", "password", password)     // NEVER log passwords
s.logger.Info("API call", "apiKey", apiKey)          // NEVER log API keys
s.logger.Info("payment", "cardNumber", cardNumber)    // NEVER log PII

// DON'T: Large data structures
s.logger.Debug("response", "body", largeResponseBody) // Too much data

// DON'T: High-frequency internal details
for _, item := range items {
    s.logger.Debug("processing item", "item", item)   // Too noisy
}

// DO INSTEAD: Log summary
s.logger.Debug("processing batch", "count", len(items))
```

---

## Error Logging Patterns

### Log Once at Appropriate Level

```go
// DO: Log at boundary, propagate error
func (h *Handler) HandleRequest(ctx context.Context, req Request) error {
    result, err := h.service.Process(ctx, req)
    if err != nil {
        h.logger.Error("request failed",
            "requestID", req.ID,
            "error", err,
        )
        return err
    }
    return nil
}

// Service doesn't log - just returns error
func (s *Service) Process(ctx context.Context, req Request) (*Result, error) {
    task, err := s.store.Get(ctx, req.TaskID)
    if err != nil {
        return nil, fmt.Errorf("get task: %w", err)  // No logging here
    }
    // ...
}
```

```go
// DON'T: Log at every level
func (h *Handler) HandleRequest(ctx context.Context, req Request) error {
    result, err := h.service.Process(ctx, req)
    if err != nil {
        h.logger.Error("handler: request failed", "error", err)  // Logged here
        return err
    }
    return nil
}

func (s *Service) Process(ctx context.Context, req Request) (*Result, error) {
    task, err := s.store.Get(ctx, req.TaskID)
    if err != nil {
        s.logger.Error("service: get task failed", "error", err)  // And here - duplicate!
        return nil, err
    }
    // ...
}
```

### Warn vs Error

```go
// Warn: Recoverable, system continues
if err := s.cache.Set(key, value); err != nil {
    s.logger.Warn("cache write failed, continuing without cache",
        "key", key,
        "error", err,
    )
    // Continue execution
}

// Error: Requires attention, may need intervention
if err := s.db.Save(ctx, task); err != nil {
    s.logger.Error("database save failed",
        "taskID", task.ID,
        "error", err,
    )
    return err
}
```

---

## Logger Configuration

### Creating Loggers

```go
// DO: Create logger with service context
func NewTaskService(baseLogger rms.Logger) *TaskService {
    return &TaskService{
        logger: baseLogger.With("service", "task"),
    }
}

func NewUserService(baseLogger rms.Logger) *UserService {
    return &UserService{
        logger: baseLogger.With("service", "user"),
    }
}
```

### Child Loggers

```go
// DO: Create child logger for operations
func (s *Service) ProcessBatch(ctx context.Context, batchID string, tasks []*Task) error {
    logger := s.logger.With("batchID", batchID, "taskCount", len(tasks))
    
    logger.Info("starting batch processing")
    
    for i, task := range tasks {
        taskLogger := logger.With("taskID", task.ID, "index", i)
        
        if err := s.processTask(ctx, task); err != nil {
            taskLogger.Error("task processing failed", "error", err)
            continue
        }
        
        taskLogger.Debug("task processed successfully")
    }
    
    logger.Info("batch processing complete")
    return nil
}
```

---

## Quick Reference

| Level | Use Case | Example |
|-------|----------|---------|
| Debug | Diagnostic details | Cache lookups, query timing |
| Info | Normal operations | Task created, request complete |
| Warn | Recoverable issues | Retry, deprecated API |
| Error | Requires attention | DB failure, critical error |

### Logging Checklist

- [ ] Using structured key-value pairs?
- [ ] Appropriate log level?
- [ ] Includes relevant IDs (request, task, user)?
- [ ] No sensitive data (passwords, keys, PII)?
- [ ] Logged once, not at every level?
- [ ] Child logger for operation context?

---

## See Also

- [EXAMPLES.md](./EXAMPLES.md) - Extended logging examples
- [error-handling](../error-handling/Skill.md) - Error context patterns
