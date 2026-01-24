# Functional Options Skill

```yaml
description: Enforces functional options pattern for configurable constructors and APIs. Use when designing factory functions, reviewing configuration patterns, or seeing builder-style APIs.
```

## Purpose

This skill enforces the functional options pattern for creating flexible, extensible constructors and APIs in Go. Use when designing factory functions with optional configuration, reviewing constructor patterns, or seeing builder-style APIs that could benefit from functional options.

## When This Skill Activates

- Designing factory functions with multiple optional parameters
- Reviewing constructors with config structs
- Seeing builder-style APIs with method chaining
- Creating extensible APIs that need backward compatibility
- Evaluating patterns for optional configuration

---

## Core Pattern

### The Functional Options Pattern

```go
// Option is a function that configures the type
type Option func(*Client)

// Constructor accepts variadic options
func NewClient(baseURL string, opts ...Option) *Client {
    // Start with defaults
    c := &Client{
        baseURL:    baseURL,
        timeout:    30 * time.Second,
        maxRetries: 3,
    }

    // Apply all options
    for _, opt := range opts {
        opt(c)
    }

    return c
}

// Option functions
func WithTimeout(d time.Duration) Option {
    return func(c *Client) {
        c.timeout = d
    }
}

func WithMaxRetries(n int) Option {
    return func(c *Client) {
        c.maxRetries = n
    }
}

func WithLogger(log rms.Logger) Option {
    return func(c *Client) {
        c.logger = log
    }
}
```

### Usage

```go
// Minimal - just required parameters
client := NewClient("https://api.example.com")

// With one option
client := NewClient("https://api.example.com",
    WithTimeout(10*time.Second),
)

// With multiple options
client := NewClient("https://api.example.com",
    WithTimeout(10*time.Second),
    WithMaxRetries(5),
    WithLogger(logger),
)
```

---

## Rules

### Rule 1: Use Functional Options for 3+ Optional Parameters

**DO: Use functional options when you have multiple optional settings**

```go
// Good: Functional options for multiple optionals
type ServerOption func(*Server)

func NewServer(addr string, opts ...ServerOption) *Server {
    s := &Server{
        addr:         addr,
        readTimeout:  5 * time.Second,
        writeTimeout: 10 * time.Second,
        maxConns:     100,
    }
    for _, opt := range opts {
        opt(s)
    }
    return s
}

func WithReadTimeout(d time.Duration) ServerOption {
    return func(s *Server) { s.readTimeout = d }
}

func WithWriteTimeout(d time.Duration) ServerOption {
    return func(s *Server) { s.writeTimeout = d }
}

func WithMaxConnections(n int) ServerOption {
    return func(s *Server) { s.maxConns = n }
}
```

**DON'T: Use long parameter lists**

```go
// Bad: Too many parameters, hard to read and maintain
func NewServer(
    addr string,
    readTimeout time.Duration,
    writeTimeout time.Duration,
    maxConns int,
    enableTLS bool,
    certFile string,
    keyFile string,
) *Server
```

### Rule 2: Keep Required Parameters as Regular Arguments

**DO: Separate required from optional**

```go
// Good: Required first, options after
func NewTaskFactory(
    ctx rms.Ctx,           // Required: context
    tenantID rms.ID,       // Required: tenant
    opts ...FactoryOption, // Optional: configuration
) *TaskFactory
```

**DON'T: Make required parameters optional**

```go
// Bad: Context hidden in options - caller might forget it
func NewTaskFactory(opts ...FactoryOption) *TaskFactory

func WithContext(ctx rms.Ctx) FactoryOption {
    return func(f *TaskFactory) { f.ctx = ctx }  // Required! Don't hide it
}
```

### Rule 3: Name Options with `With` Prefix

**DO: Use consistent `With` prefix**

```go
// Good: Clear and consistent naming
func WithTimeout(d time.Duration) Option
func WithLogger(log rms.Logger) Option
func WithRetryPolicy(p RetryPolicy) Option
func WithContext(ctx context.Context) Option
```

**DON'T: Use inconsistent naming**

```go
// Bad: Inconsistent prefixes
func Timeout(d time.Duration) Option
func SetLogger(log rms.Logger) Option
func RetryPolicyOption(p RetryPolicy) Option
```

### Rule 4: Options Should Be Additive, Not Destructive

**DO: Options should configure, not reset**

```go
// Good: Each option adds or modifies one aspect
func WithMiddleware(m Middleware) Option {
    return func(c *Client) {
        c.middlewares = append(c.middlewares, m)  // Additive
    }
}
```

**DON'T: Options that clear previous configuration**

```go
// Bad: Replaces all middlewares - surprising behavior
func WithMiddlewares(ms ...Middleware) Option {
    return func(c *Client) {
        c.middlewares = ms  // Destructive - clears existing
    }
}
```

### Rule 5: Validate in Constructor, Not in Options

**DO: Validate after all options are applied**

```go
func NewClient(baseURL string, opts ...Option) (*Client, error) {
    c := &Client{baseURL: baseURL}

    for _, opt := range opts {
        opt(c)
    }

    // Validate after all options applied
    if c.timeout <= 0 {
        return nil, fmt.Errorf("timeout must be positive: %v", c.timeout)
    }
    if c.maxRetries < 0 {
        return nil, fmt.Errorf("maxRetries cannot be negative: %d", c.maxRetries)
    }

    return c, nil
}
```

**DON'T: Validate inside options (can't return errors easily)**

```go
// Bad: Options can't return errors in standard pattern
func WithTimeout(d time.Duration) Option {
    return func(c *Client) {
        if d <= 0 {
            panic("timeout must be positive")  // Don't panic!
        }
        c.timeout = d
    }
}
```

### Rule 6: Consider Option Structs for Related Settings

**DO: Group related options**

```go
// Good: TLS options grouped together
type TLSConfig struct {
    CertFile string
    KeyFile  string
    CACert   string
}

func WithTLS(cfg TLSConfig) Option {
    return func(s *Server) {
        s.tlsConfig = cfg
    }
}

// Usage is clear
server := NewServer(addr,
    WithTLS(TLSConfig{
        CertFile: "cert.pem",
        KeyFile:  "key.pem",
    }),
)
```

**DON'T: Scatter related options**

```go
// Bad: Related settings scattered across many options
server := NewServer(addr,
    WithCertFile("cert.pem"),
    WithKeyFile("key.pem"),
    WithCACert("ca.pem"),
    WithTLSEnabled(true),
)
```

---

## Alternative Pattern: Options with Errors

When options need validation that can fail:

```go
type Option func(*Client) error

func NewClient(baseURL string, opts ...Option) (*Client, error) {
    c := &Client{baseURL: baseURL}

    for _, opt := range opts {
        if err := opt(c); err != nil {
            return nil, fmt.Errorf("apply option: %w", err)
        }
    }

    return c, nil
}

func WithTimeout(d time.Duration) Option {
    return func(c *Client) error {
        if d <= 0 {
            return fmt.Errorf("timeout must be positive: %v", d)
        }
        c.timeout = d
        return nil
    }
}
```

---

## When NOT to Use Functional Options

### Simple Constructors

```go
// Good: Just use regular parameters for simple types
func NewUser(id rms.ID, name string) *User {
    return &User{ID: id, Name: name}
}
```

### Config Struct is Better

When ALL configuration is typically provided together:

```go
// Good: Config struct when everything is usually set
type ServerConfig struct {
    Addr         string
    ReadTimeout  time.Duration
    WriteTimeout time.Duration
    MaxConns     int
}

func NewServer(cfg ServerConfig) *Server {
    return &Server{
        addr:         cfg.Addr,
        readTimeout:  cfg.ReadTimeout,
        writeTimeout: cfg.WriteTimeout,
        maxConns:     cfg.MaxConns,
    }
}
```

### Internal/Private Types

```go
// Good: Simple approach for internal types
type internalCache struct {
    size int
    ttl  time.Duration
}

func newCache(size int, ttl time.Duration) *internalCache {
    return &internalCache{size: size, ttl: ttl}
}
```

---

## Pattern Comparison

| Pattern                | Use When                                           | Example                                         |
| ---------------------- | -------------------------------------------------- | ----------------------------------------------- |
| **Functional Options** | Public API, many optionals, needs extensibility    | `NewClient(url, WithTimeout(t), WithLogger(l))` |
| **Config Struct**      | All settings typically provided, internal use      | `NewServer(ServerConfig{...})`                  |
| **Builder**            | Complex construction with validation between steps | `builder.SetX().SetY().Build()`                 |
| **Simple Parameters**  | Few parameters, all required                       | `NewUser(id, name)`                             |

---

## Testing with Functional Options

```go
func TestClient_WithOptions(t *testing.T) {
    tests := []struct {
        name    string
        opts    []Option
        wantErr bool
        check   func(*testing.T, *Client)
    }{
        {
            name: "default values",
            opts: nil,
            check: func(t *testing.T, c *Client) {
                assert.Equal(t, 30*time.Second, c.timeout)
                assert.Equal(t, 3, c.maxRetries)
            },
        },
        {
            name: "custom timeout",
            opts: []Option{WithTimeout(10 * time.Second)},
            check: func(t *testing.T, c *Client) {
                assert.Equal(t, 10*time.Second, c.timeout)
            },
        },
        {
            name: "multiple options",
            opts: []Option{
                WithTimeout(5 * time.Second),
                WithMaxRetries(10),
            },
            check: func(t *testing.T, c *Client) {
                assert.Equal(t, 5*time.Second, c.timeout)
                assert.Equal(t, 10, c.maxRetries)
            },
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            client, err := NewClient("https://api.example.com", tt.opts...)
            if tt.wantErr {
                require.Error(t, err)
                return
            }
            require.NoError(t, err)
            tt.check(t, client)
        })
    }
}
```

---

## Cross-References

- **[functions-methods](../functions-methods/Skill.md)**: Parameter ordering and function design
- **[struct-interface](../struct-interface/Skill.md)**: Struct design patterns
- **[testing](../testing/Skill.md)**: Testing constructors with options
- **[naming-convention](../naming-convention/Skill.md)**: Option function naming

## References

- [Google Go Style: Options](https://google.github.io/styleguide/go/best-practices#options)
- [Dave Cheney: Functional Options](https://dave.cheney.net/2014/10/17/functional-options-for-friendly-apis)
- [Self-referential Functions](https://commandcenter.blogspot.com/2014/01/self-referential-functions-and-design.html)
