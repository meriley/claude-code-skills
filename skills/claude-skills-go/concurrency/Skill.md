---
description: Reviews Go concurrency patterns including channels, WaitGroup, errgroup, and mutex usage. Use when reviewing concurrent code, seeing race conditions, or implementing parallel operations.
---

# Concurrency

## Purpose

Establish safe and effective concurrency patterns for RMS Go code. Go's concurrency model is powerful but requires careful design to avoid race conditions and deadlocks.

## Core Principles

1. **Don't communicate by sharing memory; share memory by communicating** - Use channels when appropriate
2. **Keep the concurrency in goroutine management** - Don't leak goroutines
3. **Use the right synchronization primitive** - Mutex, RWMutex, channels, atomics
4. **Prefer `errgroup` for concurrent operations** - Handles errors and context cancellation

---

## Goroutine Management

### Always Handle Goroutine Lifecycle

```go
// DON'T: Fire and forget
func process(items []Item) {
    for _, item := range items {
        go processItem(item)  // No way to wait, no error handling
    }
    // Returns immediately - goroutines may not complete
}

// DO: Wait for completion
func process(items []Item) error {
    var wg sync.WaitGroup
    
    for _, item := range items {
        wg.Add(1)
        go func(item Item) {
            defer wg.Done()
            processItem(item)
        }(item)
    }
    
    wg.Wait()
    return nil
}
```

### Use errgroup for Error Handling

```go
// DO: errgroup handles errors and cancellation
func process(ctx context.Context, items []Item) error {
    g, ctx := errgroup.WithContext(ctx)
    
    for _, item := range items {
        item := item  // Capture for goroutine
        g.Go(func() error {
            return processItem(ctx, item)
        })
    }
    
    return g.Wait()  // Returns first error, cancels context
}
```

### Bounded Concurrency

```go
// DO: Limit concurrent operations
func processWithLimit(ctx context.Context, items []Item, maxConcurrent int) error {
    g, ctx := errgroup.WithContext(ctx)
    g.SetLimit(maxConcurrent)  // Go 1.20+
    
    for _, item := range items {
        item := item
        g.Go(func() error {
            return processItem(ctx, item)
        })
    }
    
    return g.Wait()
}

// Alternative: Semaphore pattern
func processWithSemaphore(ctx context.Context, items []Item, maxConcurrent int) error {
    sem := make(chan struct{}, maxConcurrent)
    g, ctx := errgroup.WithContext(ctx)
    
    for _, item := range items {
        item := item
        
        select {
        case sem <- struct{}{}:
        case <-ctx.Done():
            return ctx.Err()
        }
        
        g.Go(func() error {
            defer func() { <-sem }()
            return processItem(ctx, item)
        })
    }
    
    return g.Wait()
}
```

---

## Channels

### Channel Patterns

```go
// Generator pattern
func generateIDs(ctx context.Context, count int) <-chan rms.ID {
    ch := make(chan rms.ID)
    go func() {
        defer close(ch)
        for i := 0; i < count; i++ {
            select {
            case ch <- rms.NewID():
            case <-ctx.Done():
                return
            }
        }
    }()
    return ch
}

// Fan-out pattern
func fanOut(ctx context.Context, input <-chan Item, workers int) []<-chan Result {
    outputs := make([]<-chan Result, workers)
    for i := 0; i < workers; i++ {
        outputs[i] = worker(ctx, input)
    }
    return outputs
}

// Fan-in pattern
func fanIn(ctx context.Context, inputs ...<-chan Result) <-chan Result {
    output := make(chan Result)
    var wg sync.WaitGroup
    
    for _, input := range inputs {
        wg.Add(1)
        go func(ch <-chan Result) {
            defer wg.Done()
            for result := range ch {
                select {
                case output <- result:
                case <-ctx.Done():
                    return
                }
            }
        }(input)
    }
    
    go func() {
        wg.Wait()
        close(output)
    }()
    
    return output
}
```

### Channel Best Practices

```go
// DO: Always close from sender side
func producer(items []Item) <-chan Item {
    ch := make(chan Item)
    go func() {
        defer close(ch)  // Sender closes
        for _, item := range items {
            ch <- item
        }
    }()
    return ch
}

// DO: Use buffered channels for known capacity
ch := make(chan Result, len(items))

// DO: Select with context for cancellation
select {
case result := <-resultCh:
    return result, nil
case <-ctx.Done():
    return nil, ctx.Err()
}

// DO: Non-blocking send/receive with default
select {
case ch <- item:
    // Sent
default:
    // Channel full, handle accordingly
}
```

---

## Mutex Patterns

### sync.Mutex

```go
// DO: Protect shared state
type Counter struct {
    mu    sync.Mutex
    value int64
}

func (c *Counter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.value++
}

func (c *Counter) Value() int64 {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.value
}
```

### sync.RWMutex

Use RWMutex when reads are more frequent than writes.

```go
// DO: RWMutex for read-heavy workloads
type Cache struct {
    mu    sync.RWMutex
    items map[string]*Item
}

func (c *Cache) Get(key string) (*Item, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    item, ok := c.items[key]
    return item, ok
}

func (c *Cache) Set(key string, item *Item) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.items[key] = item
}

// DO: Upgrade lock pattern
func (c *Cache) GetOrCreate(key string, create func() *Item) *Item {
    // Try read lock first
    c.mu.RLock()
    if item, ok := c.items[key]; ok {
        c.mu.RUnlock()
        return item
    }
    c.mu.RUnlock()
    
    // Acquire write lock
    c.mu.Lock()
    defer c.mu.Unlock()
    
    // Double-check after acquiring write lock
    if item, ok := c.items[key]; ok {
        return item
    }
    
    item := create()
    c.items[key] = item
    return item
}
```

### Mutex Rules

```go
// DON'T: Copy mutex
type BadCache struct {
    sync.Mutex  // Will be copied if Cache is copied
    data map[string]string
}

// DO: Use pointer to mutex or embed carefully
type GoodCache struct {
    mu   *sync.Mutex  // Pointer prevents copying issues
    data map[string]string
}

// DON'T: Hold lock during I/O
func (s *Service) BadOperation() {
    s.mu.Lock()
    defer s.mu.Unlock()
    
    // BAD: Network call while holding lock
    result, err := s.client.Fetch(ctx)
}

// DO: Minimize critical section
func (s *Service) GoodOperation() error {
    // Fetch without lock
    result, err := s.client.Fetch(ctx)
    if err != nil {
        return err
    }
    
    // Only lock for state update
    s.mu.Lock()
    s.data = result
    s.mu.Unlock()
    
    return nil
}
```

---

## sync.WaitGroup

### Basic Usage

```go
func processAll(items []Item) {
    var wg sync.WaitGroup
    
    for _, item := range items {
        wg.Add(1)
        go func(item Item) {
            defer wg.Done()
            process(item)
        }(item)
    }
    
    wg.Wait()
}
```

### WaitGroup Rules

```go
// DO: Add before starting goroutine
wg.Add(1)
go func() {
    defer wg.Done()
    // work
}()

// DON'T: Add inside goroutine
go func() {
    wg.Add(1)  // Race condition!
    defer wg.Done()
    // work
}()

// DO: Use defer for Done
go func() {
    defer wg.Done()  // Guaranteed to run
    // work that might panic
}()
```

---

## Context and Cancellation

### Respecting Context

```go
// DO: Check context in loops
func processItems(ctx context.Context, items []Item) error {
    for _, item := range items {
        select {
        case <-ctx.Done():
            return ctx.Err()
        default:
        }
        
        if err := process(ctx, item); err != nil {
            return err
        }
    }
    return nil
}

// DO: Pass context to operations
func (s *Service) LongOperation(ctx context.Context) error {
    // Context-aware database call
    result, err := s.db.QueryContext(ctx, query)
    if err != nil {
        return err
    }
    
    // Context-aware HTTP call
    req, _ := http.NewRequestWithContext(ctx, "GET", url, nil)
    resp, err := s.client.Do(req)
    if err != nil {
        return err
    }
    
    return nil
}
```

### Context with Timeout

```go
func (s *Service) OperationWithTimeout(ctx context.Context) error {
    ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
    defer cancel()
    
    return s.longOperation(ctx)
}
```

---

## Atomic Operations

### sync/atomic for Simple Counters

```go
// DO: Atomic for simple counters
type Stats struct {
    requests atomic.Int64
    errors   atomic.Int64
}

func (s *Stats) RecordRequest() {
    s.requests.Add(1)
}

func (s *Stats) RecordError() {
    s.errors.Add(1)
}

func (s *Stats) Snapshot() (requests, errors int64) {
    return s.requests.Load(), s.errors.Load()
}
```

---

## Quick Reference

| Primitive | Use Case |
|-----------|----------|
| `sync.Mutex` | Protecting shared state |
| `sync.RWMutex` | Read-heavy shared state |
| `sync.WaitGroup` | Waiting for goroutines |
| `errgroup.Group` | Concurrent ops with errors |
| `chan` | Communication between goroutines |
| `atomic` | Simple counters, flags |
| `sync.Once` | One-time initialization |
| `sync.Map` | Concurrent map access |

### Concurrency Checklist

- [ ] No goroutine leaks (always wait or cancel)?
- [ ] Context respected for cancellation?
- [ ] Mutex critical sections minimized?
- [ ] No lock held during I/O?
- [ ] Channels closed by sender only?
- [ ] Race detector clean (`go test -race`)?

---

## See Also

- [PATTERNS.md](./PATTERNS.md) - Common concurrency patterns
- [ANTI-PATTERNS.md](./ANTI-PATTERNS.md) - Race conditions to avoid
- [collections](../collections/Skill.md) - Thread-safe collections
