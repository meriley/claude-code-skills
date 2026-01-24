# Logging Examples

Extended examples for RMS Go logging patterns.

## Service Logging

### Complete Service Example

```go
type TaskService struct {
    store     TaskStore
    publisher EventPublisher
    logger    rms.Logger
}

func NewTaskService(store TaskStore, publisher EventPublisher, logger rms.Logger) *TaskService {
    return &TaskService{
        store:     store,
        publisher: publisher,
        logger:    logger.With("service", "task"),
    }
}

func (s *TaskService) Create(ctx context.Context, params CreateTaskParams) (*Task, error) {
    logger := s.logger.With(
        "operation", "create",
        "workflowID", params.WorkflowID,
        "actorID", params.ActorID,
    )
    
    logger.Info("creating task", "title", params.Title)
    
    // Validate
    if err := params.Validate(); err != nil {
        logger.Warn("validation failed", "error", err)
        return nil, fmt.Errorf("validate: %w", err)
    }
    
    // Create task
    task := &Task{
        ID:         rms.NewID(),
        Title:      params.Title,
        WorkflowID: params.WorkflowID,
        ActorID:    params.ActorID,
        Status:     StatusPending,
        CreatedAt:  time.Now(),
    }
    
    // Save
    if err := s.store.Save(ctx, task); err != nil {
        logger.Error("save failed", "error", err)
        return nil, fmt.Errorf("save: %w", err)
    }
    
    // Publish event (best effort)
    if s.publisher != nil {
        event := TaskCreatedEvent{TaskID: task.ID}
        if err := s.publisher.Publish(ctx, event); err != nil {
            logger.Warn("event publish failed", "taskID", task.ID, "error", err)
            // Don't return error - task was created successfully
        }
    }
    
    logger.Info("task created", "taskID", task.ID)
    return task, nil
}

func (s *TaskService) Update(ctx context.Context, id rms.ID, updates TaskUpdates) (*Task, error) {
    logger := s.logger.With("operation", "update", "taskID", id)
    
    logger.Debug("fetching task for update")
    
    task, err := s.store.Get(ctx, id)
    if err != nil {
        if errors.Is(err, ErrNotFound) {
            logger.Warn("task not found")
            return nil, err
        }
        logger.Error("get task failed", "error", err)
        return nil, fmt.Errorf("get: %w", err)
    }
    
    oldStatus := task.Status
    if err := task.ApplyUpdates(updates); err != nil {
        logger.Warn("apply updates failed", "error", err)
        return nil, fmt.Errorf("apply: %w", err)
    }
    
    if err := s.store.Save(ctx, task); err != nil {
        logger.Error("save failed", "error", err)
        return nil, fmt.Errorf("save: %w", err)
    }
    
    if task.Status != oldStatus {
        logger.Info("task status changed",
            "from", oldStatus,
            "to", task.Status,
        )
    }
    
    logger.Info("task updated")
    return task, nil
}
```

---

## Handler Logging

### HTTP Handler

```go
func (h *TaskHandler) HandleCreate(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context()
    requestID := middleware.GetRequestID(ctx)
    userID := auth.GetUserID(ctx)
    
    logger := h.logger.With(
        "handler", "createTask",
        "requestID", requestID,
        "userID", userID,
        "method", r.Method,
        "path", r.URL.Path,
    )
    
    logger.Info("request received")
    start := time.Now()
    
    defer func() {
        logger.Info("request completed", "duration", time.Since(start))
    }()
    
    // Parse request
    var params CreateTaskParams
    if err := json.NewDecoder(r.Body).Decode(&params); err != nil {
        logger.Warn("invalid request body", "error", err)
        http.Error(w, "invalid request", http.StatusBadRequest)
        return
    }
    
    // Create task
    task, err := h.service.Create(ctx, params)
    if err != nil {
        var validationErr *ValidationError
        if errors.As(err, &validationErr) {
            logger.Warn("validation error", "field", validationErr.Field, "error", err)
            http.Error(w, err.Error(), http.StatusBadRequest)
            return
        }
        
        logger.Error("create task failed", "error", err)
        http.Error(w, "internal error", http.StatusInternalServerError)
        return
    }
    
    logger.Info("task created successfully", "taskID", task.ID)
    
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(task)
}
```

### gRPC Handler

```go
func (h *TaskHandler) CreateTask(ctx context.Context, req *pb.CreateTaskRequest) (*pb.Task, error) {
    requestID := grpcutil.GetRequestID(ctx)
    userID := auth.GetUserID(ctx)
    
    logger := h.logger.With(
        "handler", "CreateTask",
        "requestID", requestID,
        "userID", userID,
    )
    
    logger.Info("gRPC request received")
    start := time.Now()
    
    defer func() {
        logger.Info("gRPC request completed", "duration", time.Since(start))
    }()
    
    // Convert and validate
    params := h.converter.CreateParamsFromProto(req)
    
    task, err := h.service.Create(ctx, params)
    if err != nil {
        logger.Error("create task failed", "error", err)
        return nil, status.Error(codes.Internal, "create failed")
    }
    
    logger.Info("task created", "taskID", task.ID)
    return h.converter.ToProto(task), nil
}
```

---

## Batch Processing Logging

```go
func (s *BatchProcessor) ProcessBatch(ctx context.Context, batchID string, items []Item) error {
    logger := s.logger.With(
        "operation", "processBatch",
        "batchID", batchID,
        "itemCount", len(items),
    )
    
    logger.Info("starting batch processing")
    start := time.Now()
    
    var processed, failed, skipped int
    var errors []error
    
    for i, item := range items {
        itemLogger := logger.With("itemID", item.ID, "index", i)
        
        if !item.IsValid() {
            itemLogger.Debug("skipping invalid item")
            skipped++
            continue
        }
        
        if err := s.processItem(ctx, item); err != nil {
            itemLogger.Warn("item processing failed", "error", err)
            failed++
            errors = append(errors, fmt.Errorf("item %s: %w", item.ID, err))
            continue
        }
        
        itemLogger.Debug("item processed successfully")
        processed++
    }
    
    logger.Info("batch processing complete",
        "processed", processed,
        "failed", failed,
        "skipped", skipped,
        "duration", time.Since(start),
    )
    
    if len(errors) > 0 {
        return fmt.Errorf("%d items failed: %w", len(errors), errors[0])
    }
    
    return nil
}
```

---

## Middleware Logging

### HTTP Middleware

```go
func LoggingMiddleware(logger rms.Logger) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            start := time.Now()
            
            // Create wrapped response writer to capture status
            wrapped := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}
            
            // Add request ID
            requestID := uuid.New().String()
            ctx := context.WithValue(r.Context(), requestIDKey, requestID)
            r = r.WithContext(ctx)
            
            reqLogger := logger.With(
                "requestID", requestID,
                "method", r.Method,
                "path", r.URL.Path,
                "remoteAddr", r.RemoteAddr,
            )
            
            reqLogger.Info("request started")
            
            defer func() {
                reqLogger.Info("request completed",
                    "status", wrapped.statusCode,
                    "duration", time.Since(start),
                    "bytes", wrapped.bytesWritten,
                )
            }()
            
            next.ServeHTTP(wrapped, r)
        })
    }
}

type responseWriter struct {
    http.ResponseWriter
    statusCode   int
    bytesWritten int
}

func (w *responseWriter) WriteHeader(statusCode int) {
    w.statusCode = statusCode
    w.ResponseWriter.WriteHeader(statusCode)
}

func (w *responseWriter) Write(b []byte) (int, error) {
    n, err := w.ResponseWriter.Write(b)
    w.bytesWritten += n
    return n, err
}
```

---

## Performance Logging

```go
func (s *Service) PerformanceAwareOperation(ctx context.Context) error {
    start := time.Now()
    
    // Log slow operations
    defer func() {
        duration := time.Since(start)
        if duration > s.slowThreshold {
            s.logger.Warn("slow operation detected",
                "operation", "PerformanceAwareOperation",
                "duration", duration,
                "threshold", s.slowThreshold,
            )
        }
    }()
    
    // Timed sub-operations
    dbStart := time.Now()
    data, err := s.db.Query(ctx)
    dbDuration := time.Since(dbStart)
    
    s.logger.Debug("database query completed", "duration", dbDuration)
    
    if err != nil {
        return err
    }
    
    processStart := time.Now()
    result := s.process(data)
    processDuration := time.Since(processStart)
    
    s.logger.Debug("processing completed",
        "duration", processDuration,
        "itemCount", len(result),
    )
    
    return nil
}
```

---

## Conditional Debug Logging

```go
// Expensive debug logging - check level first
func (s *Service) ProcessWithDetailedLogging(ctx context.Context, data *LargeData) error {
    // Only compute expensive string if debug is enabled
    if s.logger.Enabled(ctx, slog.LevelDebug) {
        s.logger.Debug("processing data",
            "dataSize", len(data.Items),
            "dataHash", computeHash(data),  // Expensive operation
        )
    }
    
    return s.process(data)
}
```

---

## Error Chain Logging

```go
func (s *Service) OperationWithErrorChain(ctx context.Context, id rms.ID) error {
    task, err := s.getTask(ctx, id)
    if err != nil {
        // Log the full error chain at debug level
        s.logger.Debug("operation failed with error chain",
            "taskID", id,
            "error", err,
            "errorChain", formatErrorChain(err),
        )
        
        // Log summary at error level
        s.logger.Error("operation failed",
            "taskID", id,
            "error", err,
        )
        
        return err
    }
    
    return nil
}

func formatErrorChain(err error) string {
    var chain []string
    for err != nil {
        chain = append(chain, err.Error())
        err = errors.Unwrap(err)
    }
    return strings.Join(chain, " -> ")
}
```
