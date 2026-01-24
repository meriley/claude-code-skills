# Concurrency Anti-Patterns

Common concurrency bugs and race conditions to avoid in Go.

## Race Conditions

### Data Race on Shared Variable

```go
// BUG: Data race
var counter int

func increment() {
    counter++  // Read-modify-write is not atomic
}

func main() {
    for i := 0; i < 1000; i++ {
        go increment()
    }
    time.Sleep(time.Second)
    fmt.Println(counter)  // Undefined behavior
}

// FIX: Use mutex
var (
    counter int
    mu      sync.Mutex
)

func increment() {
    mu.Lock()
    counter++
    mu.Unlock()
}

// OR: Use atomic
var counter atomic.Int64

func increment() {
    counter.Add(1)
}
```

### Map Concurrent Write

```go
// BUG: Concurrent map write
var cache = make(map[string]string)

func set(key, value string) {
    cache[key] = value  // Panic: concurrent map writes
}

func main() {
    for i := 0; i < 1000; i++ {
        go set(fmt.Sprintf("key%d", i), "value")
    }
}

// FIX: Use sync.Map
var cache sync.Map

func set(key, value string) {
    cache.Store(key, value)
}

// OR: Use mutex-protected map
type SafeMap struct {
    mu sync.RWMutex
    m  map[string]string
}

func (s *SafeMap) Set(key, value string) {
    s.mu.Lock()
    defer s.mu.Unlock()
    s.m[key] = value
}
```

---

## Loop Variable Capture (Pre Go 1.22)

### Bug: All Goroutines See Same Value

```go
// BUG: Loop variable capture
for _, item := range items {
    go func() {
        process(item)  // All goroutines see last item
    }()
}

// FIX: Pass as parameter
for _, item := range items {
    go func(item Item) {
        process(item)
    }(item)
}

// FIX: Create local copy
for _, item := range items {
    item := item  // Shadow with local variable
    go func() {
        process(item)
    }()
}
```

---

## Goroutine Leaks

### Blocked Send

```go
// BUG: Goroutine leak on blocked send
func process(items []Item) <-chan Result {
    ch := make(chan Result)  // Unbuffered
    
    go func() {
        for _, item := range items {
            ch <- processItem(item)  // Blocks forever if receiver stops
        }
        close(ch)
    }()
    
    return ch
}

func main() {
    ch := process(items)
    result := <-ch  // Only read one
    // Goroutine leaks - still trying to send
}

// FIX: Use context for cancellation
func process(ctx context.Context, items []Item) <-chan Result {
    ch := make(chan Result)
    
    go func() {
        defer close(ch)
        for _, item := range items {
            select {
            case ch <- processItem(item):
            case <-ctx.Done():
                return
            }
        }
    }()
    
    return ch
}
```

### Blocked Receive

```go
// BUG: Goroutine waits forever
func waitForResult(ch <-chan Result) Result {
    return <-ch  // Blocks forever if channel never receives
}

// FIX: Use select with timeout
func waitForResult(ctx context.Context, ch <-chan Result) (Result, error) {
    select {
    case result := <-ch:
        return result, nil
    case <-ctx.Done():
        return Result{}, ctx.Err()
    }
}
```

---

## Deadlocks

### Lock Ordering

```go
// BUG: Deadlock from inconsistent lock ordering
func transfer(from, to *Account, amount int) {
    from.mu.Lock()
    to.mu.Lock()
    // ...
    to.mu.Unlock()
    from.mu.Unlock()
}

// Thread 1: transfer(A, B, 100) -> locks A, waits for B
// Thread 2: transfer(B, A, 50)  -> locks B, waits for A
// DEADLOCK!

// FIX: Consistent lock ordering
func transfer(from, to *Account, amount int) {
    // Always lock lower ID first
    first, second := from, to
    if from.ID > to.ID {
        first, second = to, from
    }
    
    first.mu.Lock()
    second.mu.Lock()
    // ...
    second.mu.Unlock()
    first.mu.Unlock()
}
```

### Channel Deadlock

```go
// BUG: Deadlock - send and receive in same goroutine
func main() {
    ch := make(chan int)  // Unbuffered
    ch <- 1               // Blocks forever - no receiver
    fmt.Println(<-ch)
}

// FIX: Use goroutine for sender
func main() {
    ch := make(chan int)
    go func() {
        ch <- 1
    }()
    fmt.Println(<-ch)
}

// OR: Use buffered channel
func main() {
    ch := make(chan int, 1)
    ch <- 1
    fmt.Println(<-ch)
}
```

---

## WaitGroup Misuse

### Add Inside Goroutine

```go
// BUG: Race condition
var wg sync.WaitGroup

for i := 0; i < 10; i++ {
    go func() {
        wg.Add(1)  // Too late! Wait() may have already returned
        defer wg.Done()
        // work
    }()
}

wg.Wait()

// FIX: Add before goroutine
var wg sync.WaitGroup

for i := 0; i < 10; i++ {
    wg.Add(1)
    go func() {
        defer wg.Done()
        // work
    }()
}

wg.Wait()
```

### Reusing WaitGroup Before Wait Returns

```go
// BUG: Reusing WaitGroup
var wg sync.WaitGroup

wg.Add(1)
go func() {
    defer wg.Done()
    // work
}()

wg.Add(1)  // BUG if called after Wait() but before goroutine completes
go func() {
    defer wg.Done()
    // work
}()

wg.Wait()

// FIX: Add all before any Wait, or use new WaitGroup
```

---

## Mutex Misuse

### Copying Mutex

```go
// BUG: Copying mutex
type Counter struct {
    sync.Mutex
    n int
}

func (c Counter) Value() int {  // Value receiver copies mutex!
    c.Lock()
    defer c.Unlock()
    return c.n
}

// FIX: Use pointer receiver
func (c *Counter) Value() int {
    c.Lock()
    defer c.Unlock()
    return c.n
}
```

### Forgetting to Unlock

```go
// BUG: Mutex not unlocked on all paths
func (c *Cache) Get(key string) string {
    c.mu.Lock()
    if v, ok := c.data[key]; ok {
        return v  // BUG: mutex still locked!
    }
    c.mu.Unlock()
    return ""
}

// FIX: Use defer
func (c *Cache) Get(key string) string {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.data[key]
}
```

### Recursive Locking

```go
// BUG: Deadlock from recursive lock
func (c *Cache) Update(key string) {
    c.mu.Lock()
    defer c.mu.Unlock()
    
    c.validate(key)  // Tries to lock again - DEADLOCK
}

func (c *Cache) validate(key string) {
    c.mu.Lock()  // Already locked by caller
    defer c.mu.Unlock()
    // ...
}

// FIX: Internal method without locking
func (c *Cache) Update(key string) {
    c.mu.Lock()
    defer c.mu.Unlock()
    
    c.validateLocked(key)  // Assumes lock is held
}

func (c *Cache) validateLocked(key string) {
    // ...no locking here
}
```

---

## Channel Misuse

### Closing Receiver's Channel

```go
// BUG: Receiver closing channel
func producer() <-chan int {
    ch := make(chan int)
    go func() {
        for i := 0; i < 10; i++ {
            ch <- i
        }
        // Producer should close
    }()
    return ch
}

func consumer(ch <-chan int) {
    for v := range ch {
        fmt.Println(v)
    }
    close(ch)  // BUG: Receiver shouldn't close (also compile error with <-chan)
}

// FIX: Only sender closes
func producer() <-chan int {
    ch := make(chan int)
    go func() {
        defer close(ch)  // Sender closes
        for i := 0; i < 10; i++ {
            ch <- i
        }
    }()
    return ch
}
```

### Sending on Closed Channel

```go
// BUG: Sending on closed channel panics
ch := make(chan int)
close(ch)
ch <- 1  // PANIC: send on closed channel

// FIX: Use done channel or context
func producer(ctx context.Context) <-chan int {
    ch := make(chan int)
    go func() {
        defer close(ch)
        for i := 0; ; i++ {
            select {
            case ch <- i:
            case <-ctx.Done():
                return
            }
        }
    }()
    return ch
}
```

---

## Detection

### Race Detector

Always run tests with race detector:

```bash
go test -race ./...
go build -race -o myapp
./myapp  # Runs with race detection
```

### Common Signs of Race Conditions

1. Inconsistent/flaky test results
2. Different behavior under load
3. "Impossible" values
4. Panics in production only
5. Goroutine growth over time (leaks)
