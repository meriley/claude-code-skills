# Concurrency Patterns

Common concurrency patterns for RMS Go code.

## Worker Pool

### Fixed Worker Pool

```go
func workerPool(ctx context.Context, numWorkers int, jobs <-chan Job) <-chan Result {
    results := make(chan Result)
    
    var wg sync.WaitGroup
    for i := 0; i < numWorkers; i++ {
        wg.Add(1)
        go func(workerID int) {
            defer wg.Done()
            for job := range jobs {
                select {
                case <-ctx.Done():
                    return
                case results <- processJob(job):
                }
            }
        }(i)
    }
    
    go func() {
        wg.Wait()
        close(results)
    }()
    
    return results
}

// Usage
func ProcessJobs(ctx context.Context, jobs []Job) ([]Result, error) {
    jobCh := make(chan Job, len(jobs))
    for _, job := range jobs {
        jobCh <- job
    }
    close(jobCh)
    
    resultCh := workerPool(ctx, 10, jobCh)
    
    var results []Result
    for result := range resultCh {
        results = append(results, result)
    }
    
    return results, ctx.Err()
}
```

### Dynamic Worker Pool with errgroup

```go
func processWithWorkerPool(ctx context.Context, items []Item, numWorkers int) error {
    g, ctx := errgroup.WithContext(ctx)
    
    itemCh := make(chan Item, numWorkers)
    
    // Producer
    g.Go(func() error {
        defer close(itemCh)
        for _, item := range items {
            select {
            case itemCh <- item:
            case <-ctx.Done():
                return ctx.Err()
            }
        }
        return nil
    })
    
    // Workers
    for i := 0; i < numWorkers; i++ {
        g.Go(func() error {
            for item := range itemCh {
                if err := processItem(ctx, item); err != nil {
                    return err
                }
            }
            return nil
        })
    }
    
    return g.Wait()
}
```

---

## Pipeline Pattern

### Multi-Stage Pipeline

```go
// Stage 1: Generate
func generate(ctx context.Context, items []Item) <-chan Item {
    out := make(chan Item)
    go func() {
        defer close(out)
        for _, item := range items {
            select {
            case out <- item:
            case <-ctx.Done():
                return
            }
        }
    }()
    return out
}

// Stage 2: Transform
func transform(ctx context.Context, in <-chan Item) <-chan Transformed {
    out := make(chan Transformed)
    go func() {
        defer close(out)
        for item := range in {
            select {
            case out <- doTransform(item):
            case <-ctx.Done():
                return
            }
        }
    }()
    return out
}

// Stage 3: Filter
func filter(ctx context.Context, in <-chan Transformed) <-chan Transformed {
    out := make(chan Transformed)
    go func() {
        defer close(out)
        for item := range in {
            if item.IsValid() {
                select {
                case out <- item:
                case <-ctx.Done():
                    return
                }
            }
        }
    }()
    return out
}

// Usage
func runPipeline(ctx context.Context, items []Item) []Transformed {
    generated := generate(ctx, items)
    transformed := transform(ctx, generated)
    filtered := filter(ctx, transformed)
    
    var results []Transformed
    for item := range filtered {
        results = append(results, item)
    }
    return results
}
```

---

## Fan-Out / Fan-In

### Fan-Out: Distribute Work

```go
func fanOut(ctx context.Context, input <-chan Item, numWorkers int) []<-chan Result {
    outputs := make([]<-chan Result, numWorkers)
    
    for i := 0; i < numWorkers; i++ {
        outputs[i] = worker(ctx, input)
    }
    
    return outputs
}

func worker(ctx context.Context, input <-chan Item) <-chan Result {
    output := make(chan Result)
    go func() {
        defer close(output)
        for item := range input {
            result := process(item)
            select {
            case output <- result:
            case <-ctx.Done():
                return
            }
        }
    }()
    return output
}
```

### Fan-In: Collect Results

```go
func fanIn(ctx context.Context, inputs ...<-chan Result) <-chan Result {
    output := make(chan Result)
    var wg sync.WaitGroup
    
    collect := func(ch <-chan Result) {
        defer wg.Done()
        for result := range ch {
            select {
            case output <- result:
            case <-ctx.Done():
                return
            }
        }
    }
    
    wg.Add(len(inputs))
    for _, input := range inputs {
        go collect(input)
    }
    
    go func() {
        wg.Wait()
        close(output)
    }()
    
    return output
}
```

---

## Semaphore Pattern

### Bounded Concurrency

```go
type Semaphore struct {
    ch chan struct{}
}

func NewSemaphore(n int) *Semaphore {
    return &Semaphore{ch: make(chan struct{}, n)}
}

func (s *Semaphore) Acquire(ctx context.Context) error {
    select {
    case s.ch <- struct{}{}:
        return nil
    case <-ctx.Done():
        return ctx.Err()
    }
}

func (s *Semaphore) Release() {
    <-s.ch
}

// Usage
func processWithSemaphore(ctx context.Context, items []Item) error {
    sem := NewSemaphore(10)
    g, ctx := errgroup.WithContext(ctx)
    
    for _, item := range items {
        item := item
        
        if err := sem.Acquire(ctx); err != nil {
            return err
        }
        
        g.Go(func() error {
            defer sem.Release()
            return processItem(ctx, item)
        })
    }
    
    return g.Wait()
}
```

---

## Once Pattern

### Lazy Initialization

```go
type Client struct {
    once   sync.Once
    conn   *Connection
    connErr error
}

func (c *Client) getConnection() (*Connection, error) {
    c.once.Do(func() {
        c.conn, c.connErr = dial()
    })
    return c.conn, c.connErr
}

func (c *Client) Do(ctx context.Context, req Request) (Response, error) {
    conn, err := c.getConnection()
    if err != nil {
        return Response{}, err
    }
    return conn.Send(ctx, req)
}
```

### Singleton Pattern

```go
var (
    instance *Service
    once     sync.Once
)

func GetService() *Service {
    once.Do(func() {
        instance = &Service{
            // Initialize
        }
    })
    return instance
}
```

---

## Rate Limiting

### Token Bucket

```go
type RateLimiter struct {
    tokens   chan struct{}
    interval time.Duration
}

func NewRateLimiter(rate int, interval time.Duration) *RateLimiter {
    rl := &RateLimiter{
        tokens:   make(chan struct{}, rate),
        interval: interval,
    }
    
    // Fill bucket
    for i := 0; i < rate; i++ {
        rl.tokens <- struct{}{}
    }
    
    // Refill periodically
    go func() {
        ticker := time.NewTicker(interval / time.Duration(rate))
        defer ticker.Stop()
        for range ticker.C {
            select {
            case rl.tokens <- struct{}{}:
            default:
            }
        }
    }()
    
    return rl
}

func (rl *RateLimiter) Wait(ctx context.Context) error {
    select {
    case <-rl.tokens:
        return nil
    case <-ctx.Done():
        return ctx.Err()
    }
}
```

---

## Pub/Sub Pattern

### Simple Event Bus

```go
type EventBus struct {
    mu          sync.RWMutex
    subscribers map[string][]chan Event
}

func NewEventBus() *EventBus {
    return &EventBus{
        subscribers: make(map[string][]chan Event),
    }
}

func (eb *EventBus) Subscribe(topic string) <-chan Event {
    eb.mu.Lock()
    defer eb.mu.Unlock()
    
    ch := make(chan Event, 100)
    eb.subscribers[topic] = append(eb.subscribers[topic], ch)
    return ch
}

func (eb *EventBus) Publish(topic string, event Event) {
    eb.mu.RLock()
    defer eb.mu.RUnlock()
    
    for _, ch := range eb.subscribers[topic] {
        select {
        case ch <- event:
        default:
            // Subscriber too slow, drop event
        }
    }
}

func (eb *EventBus) Unsubscribe(topic string, ch <-chan Event) {
    eb.mu.Lock()
    defer eb.mu.Unlock()
    
    subs := eb.subscribers[topic]
    for i, sub := range subs {
        if sub == ch {
            eb.subscribers[topic] = append(subs[:i], subs[i+1:]...)
            close(sub)
            break
        }
    }
}
```

---

## Timeout Pattern

### Operation with Timeout

```go
func operationWithTimeout(ctx context.Context, timeout time.Duration) (Result, error) {
    ctx, cancel := context.WithTimeout(ctx, timeout)
    defer cancel()
    
    resultCh := make(chan Result, 1)
    errCh := make(chan error, 1)
    
    go func() {
        result, err := longOperation(ctx)
        if err != nil {
            errCh <- err
            return
        }
        resultCh <- result
    }()
    
    select {
    case result := <-resultCh:
        return result, nil
    case err := <-errCh:
        return Result{}, err
    case <-ctx.Done():
        return Result{}, ctx.Err()
    }
}
```

---

## Graceful Shutdown

```go
type Server struct {
    done chan struct{}
    wg   sync.WaitGroup
}

func (s *Server) Start(ctx context.Context) error {
    s.done = make(chan struct{})
    
    // Start workers
    for i := 0; i < numWorkers; i++ {
        s.wg.Add(1)
        go s.worker(ctx)
    }
    
    return nil
}

func (s *Server) worker(ctx context.Context) {
    defer s.wg.Done()
    
    for {
        select {
        case <-s.done:
            return
        case <-ctx.Done():
            return
        default:
            // Do work
        }
    }
}

func (s *Server) Shutdown(ctx context.Context) error {
    close(s.done)
    
    // Wait for workers with timeout
    done := make(chan struct{})
    go func() {
        s.wg.Wait()
        close(done)
    }()
    
    select {
    case <-done:
        return nil
    case <-ctx.Done():
        return ctx.Err()
    }
}
```
