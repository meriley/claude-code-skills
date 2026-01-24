# Caching Patterns

Advanced caching patterns for RMS Go services.

## LRU Cache with Generics

```go
type LRUCache[K comparable, V any] struct {
    mu       sync.Mutex
    capacity int
    items    map[K]*list.Element
    order    *list.List
}

type lruEntry[K comparable, V any] struct {
    key   K
    value V
}

func NewLRUCache[K comparable, V any](capacity int) *LRUCache[K, V] {
    return &LRUCache[K, V]{
        capacity: capacity,
        items:    make(map[K]*list.Element),
        order:    list.New(),
    }
}

func (c *LRUCache[K, V]) Get(key K) (V, bool) {
    c.mu.Lock()
    defer c.mu.Unlock()
    
    if elem, ok := c.items[key]; ok {
        c.order.MoveToFront(elem)
        return elem.Value.(*lruEntry[K, V]).value, true
    }
    
    var zero V
    return zero, false
}

func (c *LRUCache[K, V]) Set(key K, value V) {
    c.mu.Lock()
    defer c.mu.Unlock()
    
    if elem, ok := c.items[key]; ok {
        c.order.MoveToFront(elem)
        elem.Value.(*lruEntry[K, V]).value = value
        return
    }
    
    if c.order.Len() >= c.capacity {
        oldest := c.order.Back()
        if oldest != nil {
            c.order.Remove(oldest)
            delete(c.items, oldest.Value.(*lruEntry[K, V]).key)
        }
    }
    
    entry := &lruEntry[K, V]{key: key, value: value}
    elem := c.order.PushFront(entry)
    c.items[key] = elem
}
```

## TTL Cache with Cleanup

```go
type TTLCache[K comparable, V any] struct {
    mu      sync.RWMutex
    items   map[K]*ttlEntry[V]
    ttl     time.Duration
    cleaner *time.Ticker
    done    chan struct{}
}

type ttlEntry[V any] struct {
    value     V
    expiresAt time.Time
}

func NewTTLCache[K comparable, V any](ttl time.Duration) *TTLCache[K, V] {
    c := &TTLCache[K, V]{
        items: make(map[K]*ttlEntry[V]),
        ttl:   ttl,
        done:  make(chan struct{}),
    }
    
    // Start cleanup goroutine
    c.cleaner = time.NewTicker(ttl / 2)
    go c.cleanup()
    
    return c
}

func (c *TTLCache[K, V]) cleanup() {
    for {
        select {
        case <-c.cleaner.C:
            c.mu.Lock()
            now := time.Now()
            for k, v := range c.items {
                if now.After(v.expiresAt) {
                    delete(c.items, k)
                }
            }
            c.mu.Unlock()
        case <-c.done:
            c.cleaner.Stop()
            return
        }
    }
}

func (c *TTLCache[K, V]) Close() {
    close(c.done)
}

func (c *TTLCache[K, V]) Get(key K) (V, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    
    entry, ok := c.items[key]
    if !ok || time.Now().After(entry.expiresAt) {
        var zero V
        return zero, false
    }
    return entry.value, true
}

func (c *TTLCache[K, V]) Set(key K, value V) {
    c.mu.Lock()
    defer c.mu.Unlock()
    
    c.items[key] = &ttlEntry[V]{
        value:     value,
        expiresAt: time.Now().Add(c.ttl),
    }
}
```

## Singleflight Pattern

Prevents duplicate work for concurrent requests for the same key.

```go
import "golang.org/x/sync/singleflight"

type CachedService struct {
    cache   *TTLCache[string, *Task]
    store   TaskStore
    group   singleflight.Group
}

func (s *CachedService) GetTask(ctx context.Context, id rms.ID) (*Task, error) {
    key := string(id)
    
    // Check cache first
    if task, ok := s.cache.Get(key); ok {
        return task, nil
    }
    
    // Use singleflight to deduplicate concurrent requests
    result, err, _ := s.group.Do(key, func() (any, error) {
        // Double-check cache after acquiring the lock
        if task, ok := s.cache.Get(key); ok {
            return task, nil
        }
        
        // Fetch from store
        task, err := s.store.Get(ctx, id)
        if err != nil {
            return nil, err
        }
        
        // Cache the result
        s.cache.Set(key, task)
        return task, nil
    })
    
    if err != nil {
        return nil, err
    }
    
    return result.(*Task), nil
}
```

## Write-Through Cache

```go
type WriteThroughCache struct {
    cache *TTLCache[rms.ID, *Task]
    store TaskStore
}

func (c *WriteThroughCache) Get(ctx context.Context, id rms.ID) (*Task, error) {
    // Check cache
    if task, ok := c.cache.Get(id); ok {
        return task, nil
    }
    
    // Fetch from store
    task, err := c.store.Get(ctx, id)
    if err != nil {
        return nil, err
    }
    
    // Populate cache
    c.cache.Set(id, task)
    return task, nil
}

func (c *WriteThroughCache) Save(ctx context.Context, task *Task) error {
    // Write to store first
    if err := c.store.Save(ctx, task); err != nil {
        return err
    }
    
    // Update cache
    c.cache.Set(task.ID, task)
    return nil
}

func (c *WriteThroughCache) Delete(ctx context.Context, id rms.ID) error {
    // Delete from store first
    if err := c.store.Delete(ctx, id); err != nil {
        return err
    }
    
    // Invalidate cache
    c.cache.Delete(id)
    return nil
}
```

## Cache Metrics

```go
type MetricsCache[K comparable, V any] struct {
    cache   Cache[K, V]
    hits    atomic.Int64
    misses  atomic.Int64
    evicts  atomic.Int64
}

func (c *MetricsCache[K, V]) Get(key K) (V, bool) {
    v, ok := c.cache.Get(key)
    if ok {
        c.hits.Add(1)
    } else {
        c.misses.Add(1)
    }
    return v, ok
}

func (c *MetricsCache[K, V]) Stats() CacheStats {
    hits := c.hits.Load()
    misses := c.misses.Load()
    total := hits + misses
    
    var hitRatio float64
    if total > 0 {
        hitRatio = float64(hits) / float64(total)
    }
    
    return CacheStats{
        Hits:     hits,
        Misses:   misses,
        Evicts:   c.evicts.Load(),
        HitRatio: hitRatio,
    }
}

type CacheStats struct {
    Hits     int64
    Misses   int64
    Evicts   int64
    HitRatio float64
}
```

## Multi-Level Cache

```go
type MultiLevelCache struct {
    l1 *LRUCache[string, *Task]    // In-memory
    l2 *RedisCache                  // Redis
    store TaskStore                 // Database
}

func (c *MultiLevelCache) Get(ctx context.Context, id rms.ID) (*Task, error) {
    key := string(id)
    
    // L1: In-memory
    if task, ok := c.l1.Get(key); ok {
        return task, nil
    }
    
    // L2: Redis
    task, err := c.l2.Get(ctx, key)
    if err == nil {
        c.l1.Set(key, task)  // Populate L1
        return task, nil
    }
    if !errors.Is(err, ErrCacheMiss) {
        return nil, err
    }
    
    // L3: Database
    task, err = c.store.Get(ctx, id)
    if err != nil {
        return nil, err
    }
    
    // Populate caches
    c.l2.Set(ctx, key, task)
    c.l1.Set(key, task)
    
    return task, nil
}
```
