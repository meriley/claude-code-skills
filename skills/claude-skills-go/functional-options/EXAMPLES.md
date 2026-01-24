# Functional Options Examples

Extended examples and real-world patterns for functional options.

---

## Real-World Example: HTTP Client

```go
package httpclient

import (
    "net/http"
    "time"

    "go.taservs.net/rms"
)

// Client is a configurable HTTP client
type Client struct {
    baseURL     string
    httpClient  *http.Client
    timeout     time.Duration
    maxRetries  int
    retryDelay  time.Duration
    headers     map[string]string
    logger      rms.Logger
    rateLimiter RateLimiter
}

// Option configures a Client
type Option func(*Client)

// NewClient creates an HTTP client with the given options
func NewClient(baseURL string, opts ...Option) *Client {
    c := &Client{
        baseURL:    baseURL,
        timeout:    30 * time.Second,
        maxRetries: 3,
        retryDelay: time.Second,
        headers:    make(map[string]string),
        httpClient: http.DefaultClient,
    }

    for _, opt := range opts {
        opt(c)
    }

    // Set timeout on http client
    c.httpClient.Timeout = c.timeout

    return c
}

// WithTimeout sets the request timeout
func WithTimeout(d time.Duration) Option {
    return func(c *Client) {
        c.timeout = d
    }
}

// WithMaxRetries sets the maximum retry attempts
func WithMaxRetries(n int) Option {
    return func(c *Client) {
        c.maxRetries = n
    }
}

// WithRetryDelay sets the delay between retries
func WithRetryDelay(d time.Duration) Option {
    return func(c *Client) {
        c.retryDelay = d
    }
}

// WithHeader adds a default header to all requests
func WithHeader(key, value string) Option {
    return func(c *Client) {
        c.headers[key] = value
    }
}

// WithLogger sets the logger for request logging
func WithLogger(log rms.Logger) Option {
    return func(c *Client) {
        c.logger = log
    }
}

// WithRateLimiter sets a rate limiter for requests
func WithRateLimiter(rl RateLimiter) Option {
    return func(c *Client) {
        c.rateLimiter = rl
    }
}

// WithHTTPClient sets a custom http.Client
func WithHTTPClient(hc *http.Client) Option {
    return func(c *Client) {
        c.httpClient = hc
    }
}
```

### Usage Examples

```go
// Minimal client
client := httpclient.NewClient("https://api.example.com")

// Production client with full configuration
client := httpclient.NewClient("https://api.example.com",
    httpclient.WithTimeout(10*time.Second),
    httpclient.WithMaxRetries(5),
    httpclient.WithRetryDelay(2*time.Second),
    httpclient.WithHeader("Authorization", "Bearer "+token),
    httpclient.WithHeader("X-Request-ID", requestID),
    httpclient.WithLogger(logger),
    httpclient.WithRateLimiter(rateLimiter),
)

// Test client with short timeouts
client := httpclient.NewClient("https://api.test.com",
    httpclient.WithTimeout(time.Second),
    httpclient.WithMaxRetries(1),
)
```

---

## Real-World Example: Task Factory (RMS Pattern)

```go
package factory

import (
    "fmt"

    "go.taservs.net/rms"
    "go.taservs.net/taskcore/entity"
    "go.taservs.net/taskcore/constants"
)

// TaskFactory creates tasks with configurable defaults
type TaskFactory struct {
    ctx          rms.Ctx
    tenantID     rms.ID
    workflowID   rms.ID
    dataSchemaID rms.ID
    actorID      rms.ID
    priority     constants.Priority
    validators   []Validator
}

// FactoryOption configures a TaskFactory
type FactoryOption func(*TaskFactory)

// NewTaskFactory creates a factory for the given tenant
func NewTaskFactory(ctx rms.Ctx, tenantID rms.ID, opts ...FactoryOption) (*TaskFactory, error) {
    if tenantID == "" {
        return nil, fmt.Errorf("tenantID is required")
    }

    f := &TaskFactory{
        ctx:      ctx,
        tenantID: tenantID,
        priority: constants.PriorityMedium,
    }

    for _, opt := range opts {
        opt(f)
    }

    // Validate required fields after options
    if f.workflowID == "" {
        return nil, fmt.Errorf("workflowID is required: use WithWorkflowID option")
    }
    if f.dataSchemaID == "" {
        return nil, fmt.Errorf("dataSchemaID is required: use WithDataSchemaID option")
    }

    return f, nil
}

// WithWorkflowID sets the workflow for created tasks
func WithWorkflowID(id rms.ID) FactoryOption {
    return func(f *TaskFactory) {
        f.workflowID = id
    }
}

// WithDataSchemaID sets the data schema for validation
func WithDataSchemaID(id rms.ID) FactoryOption {
    return func(f *TaskFactory) {
        f.dataSchemaID = id
    }
}

// WithActorID sets the default actor for task actions
func WithActorID(id rms.ID) FactoryOption {
    return func(f *TaskFactory) {
        f.actorID = id
    }
}

// WithPriority sets the default priority for created tasks
func WithPriority(p constants.Priority) FactoryOption {
    return func(f *TaskFactory) {
        f.priority = p
    }
}

// WithValidator adds a validator to the factory
func WithValidator(v Validator) FactoryOption {
    return func(f *TaskFactory) {
        f.validators = append(f.validators, v)
    }
}

// CreateTask creates a new task with the factory defaults
func (f *TaskFactory) CreateTask(params CreateTaskParams) (*entity.Task, error) {
    task := &entity.Task{
        TenantID:     f.tenantID,
        WorkflowID:   f.workflowID,
        DataSchemaID: f.dataSchemaID,
        ActorID:      f.actorID,
        Priority:     f.priority,
        // Apply params...
    }

    for _, v := range f.validators {
        if err := v.Validate(task); err != nil {
            return nil, fmt.Errorf("validation failed: %w", err)
        }
    }

    return task, nil
}
```

### Usage

```go
// Create factory with required configuration
factory, err := factory.NewTaskFactory(ctx, tenantID,
    factory.WithWorkflowID(workflowID),
    factory.WithDataSchemaID(schemaID),
    factory.WithActorID(userID),
    factory.WithPriority(constants.PriorityHigh),
    factory.WithValidator(metadataValidator),
)
if err != nil {
    return fmt.Errorf("create task factory: %w", err)
}

// Create tasks using the factory
task, err := factory.CreateTask(params)
```

---

## Real-World Example: gRPC Server

```go
package grpcserver

import (
    "time"

    "google.golang.org/grpc"
    "google.golang.org/grpc/keepalive"

    "go.taservs.net/rms"
)

// Server wraps a gRPC server with RMS configuration
type Server struct {
    addr            string
    grpcServer      *grpc.Server
    logger          rms.Logger
    unaryMiddleware []grpc.UnaryServerInterceptor
    keepaliveParams keepalive.ServerParameters
    maxRecvMsgSize  int
    maxSendMsgSize  int
}

// ServerOption configures a Server
type ServerOption func(*Server)

// NewServer creates a gRPC server with the given options
func NewServer(addr string, opts ...ServerOption) *Server {
    s := &Server{
        addr:           addr,
        maxRecvMsgSize: 4 * 1024 * 1024,  // 4MB
        maxSendMsgSize: 4 * 1024 * 1024,  // 4MB
        keepaliveParams: keepalive.ServerParameters{
            Time:    30 * time.Second,
            Timeout: 10 * time.Second,
        },
    }

    for _, opt := range opts {
        opt(s)
    }

    return s
}

// WithLogger sets the server logger
func WithLogger(log rms.Logger) ServerOption {
    return func(s *Server) {
        s.logger = log
    }
}

// WithUnaryInterceptor adds a unary interceptor
func WithUnaryInterceptor(i grpc.UnaryServerInterceptor) ServerOption {
    return func(s *Server) {
        s.unaryMiddleware = append(s.unaryMiddleware, i)
    }
}

// WithKeepalive configures keepalive parameters
func WithKeepalive(params keepalive.ServerParameters) ServerOption {
    return func(s *Server) {
        s.keepaliveParams = params
    }
}

// WithMaxRecvMsgSize sets the maximum receive message size
func WithMaxRecvMsgSize(size int) ServerOption {
    return func(s *Server) {
        s.maxRecvMsgSize = size
    }
}

// WithMaxSendMsgSize sets the maximum send message size
func WithMaxSendMsgSize(size int) ServerOption {
    return func(s *Server) {
        s.maxSendMsgSize = size
    }
}
```

---

## Pattern: Composable Options

Create higher-level options from lower-level ones:

```go
// WithProductionDefaults applies all production settings
func WithProductionDefaults() Option {
    return func(c *Client) {
        WithTimeout(30 * time.Second)(c)
        WithMaxRetries(5)(c)
        WithRetryDelay(2 * time.Second)(c)
    }
}

// WithTestDefaults applies settings for testing
func WithTestDefaults() Option {
    return func(c *Client) {
        WithTimeout(time.Second)(c)
        WithMaxRetries(1)(c)
        WithRetryDelay(10 * time.Millisecond)(c)
    }
}

// Usage
prodClient := NewClient(url, WithProductionDefaults(), WithLogger(logger))
testClient := NewClient(url, WithTestDefaults())
```

---

## Pattern: Options from Configuration

```go
// OptionsFromConfig creates options from a config struct
func OptionsFromConfig(cfg Config) []Option {
    var opts []Option

    if cfg.Timeout > 0 {
        opts = append(opts, WithTimeout(cfg.Timeout))
    }
    if cfg.MaxRetries > 0 {
        opts = append(opts, WithMaxRetries(cfg.MaxRetries))
    }
    if cfg.Logger != nil {
        opts = append(opts, WithLogger(cfg.Logger))
    }

    return opts
}

// Usage
cfg := loadConfig()
client := NewClient(cfg.BaseURL, OptionsFromConfig(cfg)...)
```

---

## Pattern: Conditional Options

```go
// WithOptionalLogger only sets logger if not nil
func WithOptionalLogger(log rms.Logger) Option {
    return func(c *Client) {
        if log != nil {
            c.logger = log
        }
    }
}

// WithTimeoutIf sets timeout only if condition is true
func WithTimeoutIf(condition bool, d time.Duration) Option {
    return func(c *Client) {
        if condition {
            c.timeout = d
        }
    }
}

// Usage
client := NewClient(url,
    WithOptionalLogger(maybeNilLogger),
    WithTimeoutIf(isProduction, 30*time.Second),
)
```

---

## Anti-Pattern: Mutable Options

**DON'T: Create options that can be modified after use**

```go
// Bad: Shared mutable state
type MutableOption struct {
    timeout time.Duration
}

func (o *MutableOption) Apply(c *Client) {
    c.timeout = o.timeout
}

opt := &MutableOption{timeout: time.Second}
client1 := NewClient(url, opt.Apply)
opt.timeout = time.Hour  // Affects what?!
client2 := NewClient(url, opt.Apply)
```

**DO: Options should capture values at creation time**

```go
// Good: Value captured in closure
func WithTimeout(d time.Duration) Option {
    return func(c *Client) {
        c.timeout = d  // d is captured, immutable
    }
}
```

---

## Testing: Verifying Options Were Applied

```go
func TestWithTimeout(t *testing.T) {
    timeout := 5 * time.Second
    client := NewClient("https://example.com", WithTimeout(timeout))

    // Access internal field for testing (use a getter in production)
    assert.Equal(t, timeout, client.timeout)
}

func TestOptionsAreAdditive(t *testing.T) {
    client := NewClient("https://example.com",
        WithMiddleware(loggingMiddleware),
        WithMiddleware(tracingMiddleware),
    )

    assert.Len(t, client.middlewares, 2)
    assert.Contains(t, client.middlewares, loggingMiddleware)
    assert.Contains(t, client.middlewares, tracingMiddleware)
}

func TestDefaultsWhenNoOptions(t *testing.T) {
    client := NewClient("https://example.com")

    // Verify defaults
    assert.Equal(t, 30*time.Second, client.timeout)
    assert.Equal(t, 3, client.maxRetries)
    assert.Empty(t, client.middlewares)
}
```

---

## Migration: From Config Struct to Functional Options

### Before (Config Struct)

```go
type ClientConfig struct {
    BaseURL    string
    Timeout    time.Duration
    MaxRetries int
    Logger     rms.Logger
}

func NewClient(cfg ClientConfig) *Client {
    return &Client{
        baseURL:    cfg.BaseURL,
        timeout:    cfg.Timeout,
        maxRetries: cfg.MaxRetries,
        logger:     cfg.Logger,
    }
}
```

### After (Functional Options with Backward Compatibility)

```go
// Keep the config struct for backward compatibility
type ClientConfig struct {
    BaseURL    string
    Timeout    time.Duration
    MaxRetries int
    Logger     rms.Logger
}

// New functional options API
type Option func(*Client)

func NewClient(baseURL string, opts ...Option) *Client {
    c := &Client{
        baseURL:    baseURL,
        timeout:    30 * time.Second,
        maxRetries: 3,
    }
    for _, opt := range opts {
        opt(c)
    }
    return c
}

// Backward compatibility: create from config
func NewClientFromConfig(cfg ClientConfig) *Client {
    return NewClient(cfg.BaseURL,
        WithTimeout(cfg.Timeout),
        WithMaxRetries(cfg.MaxRetries),
        WithLogger(cfg.Logger),
    )
}
```
