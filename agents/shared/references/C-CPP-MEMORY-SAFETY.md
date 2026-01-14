# C/C++ Memory and Thread Safety Patterns Reference

This reference provides detailed patterns for C/C++ memory safety, thread safety, and resource management. Load when reviewing systems code, debugging crashes, or implementing production-ready C/C++ systems.

---

## Memory Safety Patterns

### Buffer Overflow Prevention

```c
// ❌ BUFFER OVERFLOW - P0 CRITICAL
char buf[10];
strcpy(buf, user_input);  // No bounds checking!

char buf[10];
gets(buf);  // NEVER use gets() - deprecated for good reason

sprintf(buf, "%s", user_input);  // No bounds checking!

// ✅ SAFE ALTERNATIVES
char buf[10];
strncpy(buf, user_input, sizeof(buf) - 1);
buf[sizeof(buf) - 1] = '\0';  // Ensure null termination

snprintf(buf, sizeof(buf), "%s", user_input);  // Bounds-checked

// ✅ C++ - Use std::string
std::string buf = user_input;  // Automatic memory management
```

### Use-After-Free Prevention

```c
// ❌ USE-AFTER-FREE - P0 CRITICAL
void process(Item *item) {
    free(item);
    printf("%s\n", item->name);  // UAF!
}

// ❌ Returning pointer to freed memory
char *get_name(void) {
    char *name = malloc(100);
    strcpy(name, "test");
    free(name);
    return name;  // UAF when caller uses it!
}

// ❌ Double free
void cleanup(void *ptr) {
    free(ptr);
    free(ptr);  // Double free!
}

// ✅ SAFE PATTERNS
void process(Item *item) {
    printf("%s\n", item->name);  // Use BEFORE free
    free(item);
    item = NULL;  // Defensive: null after free
}

// ✅ C++ - Use smart pointers
void process(std::unique_ptr<Item> item) {
    printf("%s\n", item->name);
    // Automatically freed when scope ends
}
```

### Null Pointer Dereference Prevention

```c
// ❌ NULL DEREFERENCE - P0 CRITICAL
char *name = get_user_name();
printf("Name: %s\n", name);  // Crash if NULL!

// ❌ Unchecked malloc
char *buf = malloc(size);
memset(buf, 0, size);  // Crash if malloc failed!

// ✅ ALWAYS CHECK POINTERS
char *name = get_user_name();
if (name == NULL) {
    log_error("Failed to get user name");
    return ERROR_NULL_POINTER;
}
printf("Name: %s\n", name);

// ✅ Check malloc returns
char *buf = malloc(size);
if (buf == NULL) {
    log_error("malloc failed for size %zu", size);
    return ERROR_OUT_OF_MEMORY;
}
memset(buf, 0, size);
```

### Uninitialized Memory Prevention

```c
// ❌ UNINITIALIZED - P0 CRITICAL
int result;
if (condition) {
    result = 42;
}
return result;  // UB if condition false!

char buf[100];
strcat(buf, user_input);  // buf not initialized!

// ✅ ALWAYS INITIALIZE
int result = 0;  // Default value
if (condition) {
    result = 42;
}
return result;

char buf[100] = {0};  // Zero-initialize
// or
char buf[100];
buf[0] = '\0';  // Initialize as empty string
strcat(buf, user_input);
```

---

## Thread Safety Patterns

### Data Race Prevention

```c
// ❌ DATA RACE - P0 CRITICAL
static int counter = 0;

void increment(void) {
    counter++;  // Not atomic! Race condition!
}

// ❌ Reading while another thread writes
void reader(void) {
    printf("%d\n", counter);  // Race!
}

// ✅ ATOMIC OPERATIONS (C11)
#include <stdatomic.h>
static atomic_int counter = 0;

void increment(void) {
    atomic_fetch_add(&counter, 1);
}

// ✅ MUTEX PROTECTION
static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
static int counter = 0;

void increment(void) {
    pthread_mutex_lock(&mutex);
    counter++;
    pthread_mutex_unlock(&mutex);
}

// ✅ C++ - std::atomic or std::mutex
std::atomic<int> counter{0};

void increment() {
    counter.fetch_add(1, std::memory_order_relaxed);
}

// Or with mutex for complex operations
std::mutex mtx;
int counter = 0;

void increment() {
    std::lock_guard<std::mutex> lock(mtx);
    counter++;
}
```

### Deadlock Prevention

```c
// ❌ DEADLOCK - P0 CRITICAL (lock ordering violation)
void thread1(void) {
    pthread_mutex_lock(&mutex_a);
    pthread_mutex_lock(&mutex_b);  // Thread 2 holds B, waits for A
    // ...
}

void thread2(void) {
    pthread_mutex_lock(&mutex_b);
    pthread_mutex_lock(&mutex_a);  // Thread 1 holds A, waits for B - DEADLOCK!
    // ...
}

// ✅ CONSISTENT LOCK ORDERING
void thread1(void) {
    pthread_mutex_lock(&mutex_a);  // Always lock A first
    pthread_mutex_lock(&mutex_b);
    // ...
    pthread_mutex_unlock(&mutex_b);
    pthread_mutex_unlock(&mutex_a);
}

void thread2(void) {
    pthread_mutex_lock(&mutex_a);  // Same order
    pthread_mutex_lock(&mutex_b);
    // ...
}

// ✅ C++ - std::scoped_lock (C++17) handles ordering
void safe_operation() {
    std::scoped_lock lock(mutex_a, mutex_b);  // Deadlock-free
    // ...
}
```

### TOCTOU Prevention

```c
// ❌ TOCTOU - P0 CRITICAL (Time-of-Check-Time-of-Use)
if (access(filepath, W_OK) == 0) {
    // Attacker can replace file between check and use!
    FILE *f = fopen(filepath, "w");
    // ...
}

// ❌ Checking then acting on file existence
if (stat(path, &st) == 0) {
    // File exists, but might be deleted/replaced before open!
    fd = open(path, O_RDONLY);
}

// ✅ ATOMIC OPERATIONS - Open with flags
int fd = open(filepath, O_WRONLY | O_CREAT | O_EXCL, 0600);
if (fd < 0) {
    if (errno == EEXIST) {
        // File already exists
    } else {
        // Other error
    }
}

// ✅ Use file descriptor operations after open
int fd = open(filepath, O_RDONLY);
if (fd >= 0) {
    // Use fstat on fd, not stat on path
    if (fstat(fd, &st) == 0) {
        // Safe - operating on same file
    }
}
```

---

## Resource Management Patterns

### Memory Leak Prevention

```c
// ❌ MEMORY LEAK - P1 HIGH
void process(void) {
    char *buf = malloc(1024);
    if (error_condition) {
        return;  // LEAK! buf not freed
    }
    // ...
    free(buf);
}

// ❌ Lost pointer
void lost_pointer(void) {
    char *buf = malloc(1024);
    buf = malloc(2048);  // Original allocation leaked!
    free(buf);
}

// ✅ CLEANUP ON ALL PATHS
void process(void) {
    char *buf = malloc(1024);
    if (buf == NULL) {
        return;
    }

    if (error_condition) {
        free(buf);  // Clean up before early return
        return;
    }

    // ... use buf ...

    free(buf);
}

// ✅ GOTO CLEANUP PATTERN (C idiom)
int process(void) {
    int ret = -1;
    char *buf1 = NULL;
    char *buf2 = NULL;

    buf1 = malloc(1024);
    if (buf1 == NULL) goto cleanup;

    buf2 = malloc(2048);
    if (buf2 == NULL) goto cleanup;

    // ... use buf1 and buf2 ...
    ret = 0;

cleanup:
    free(buf2);  // free(NULL) is safe
    free(buf1);
    return ret;
}

// ✅ C++ - RAII
void process() {
    auto buf = std::make_unique<char[]>(1024);
    if (error_condition) {
        return;  // buf automatically freed
    }
    // ... buf automatically freed when scope ends
}
```

### File Handle Leak Prevention

```c
// ❌ FILE HANDLE LEAK - P1 HIGH
void read_config(void) {
    FILE *f = fopen("config.txt", "r");
    if (parse_error) {
        return;  // LEAK! f not closed
    }
    // ...
    fclose(f);
}

// ❌ File descriptor leak
void process_file(const char *path) {
    int fd = open(path, O_RDONLY);
    if (read(fd, buf, size) < 0) {
        return;  // LEAK! fd not closed
    }
    close(fd);
}

// ✅ CLEANUP ON ALL PATHS
void read_config(void) {
    FILE *f = fopen("config.txt", "r");
    if (f == NULL) {
        return;
    }

    if (parse_error) {
        fclose(f);
        return;
    }

    // ...
    fclose(f);
}

// ✅ C++ - RAII with unique_ptr
void read_config() {
    auto f = std::unique_ptr<FILE, decltype(&fclose)>(
        fopen("config.txt", "r"), fclose
    );
    if (!f) return;

    if (parse_error) {
        return;  // f automatically closed
    }
    // f automatically closed when scope ends
}

// ✅ C++ - std::fstream
void read_config() {
    std::ifstream f("config.txt");
    if (!f) return;
    // f automatically closed when scope ends
}
```

---

## Error Handling Patterns

### Unchecked Return Value Prevention

```c
// ❌ UNCHECKED RETURN - P2 MEDIUM
void process(void) {
    malloc(1024);  // Return value ignored - memory lost!

    fread(buf, 1, size, f);  // Partial read not detected!

    pthread_mutex_lock(&mutex);  // Can fail with EDEADLK!
}

// ✅ ALWAYS CHECK RETURNS
void *buf = malloc(1024);
if (buf == NULL) {
    log_error("malloc failed");
    return ERROR_OOM;
}

size_t nread = fread(buf, 1, size, f);
if (nread != size) {
    if (feof(f)) {
        log_warning("Unexpected EOF, read %zu of %zu", nread, size);
    } else if (ferror(f)) {
        log_error("Read error");
        return ERROR_IO;
    }
}

int rc = pthread_mutex_lock(&mutex);
if (rc != 0) {
    log_error("mutex_lock failed: %s", strerror(rc));
    return ERROR_LOCK;
}
```

### Missing Cleanup on Error Paths

```c
// ❌ MISSING CLEANUP - P2 MEDIUM
int init_subsystem(void) {
    buf1 = malloc(1024);
    buf2 = malloc(2048);

    if (init_component_a() < 0) {
        return -1;  // buf1 and buf2 leaked!
    }

    if (init_component_b() < 0) {
        return -1;  // component_a not cleaned up!
    }

    return 0;
}

// ✅ PROPER ERROR PATH CLEANUP
int init_subsystem(void) {
    int ret = -1;
    buf1 = malloc(1024);
    if (buf1 == NULL) goto fail;

    buf2 = malloc(2048);
    if (buf2 == NULL) goto fail_buf1;

    if (init_component_a() < 0) goto fail_buf2;
    if (init_component_b() < 0) goto fail_component_a;

    return 0;  // Success

fail_component_a:
    cleanup_component_a();
fail_buf2:
    free(buf2);
fail_buf1:
    free(buf1);
fail:
    return ret;
}
```

---

## Modern C++ Patterns

### RAII and Smart Pointers

```cpp
// ❌ RAW POINTERS - Avoid in modern C++
Widget* createWidget() {
    Widget* w = new Widget();  // Who owns this?
    return w;  // Caller must remember to delete!
}

void process() {
    Widget* w = createWidget();
    if (error) {
        return;  // LEAK!
    }
    delete w;
}

// ✅ SMART POINTERS
std::unique_ptr<Widget> createWidget() {
    return std::make_unique<Widget>();  // Clear ownership
}

void process() {
    auto w = createWidget();  // Unique ownership
    if (error) {
        return;  // Automatically cleaned up
    }
    // Automatically cleaned up
}

// ✅ Shared ownership when needed
std::shared_ptr<Widget> createSharedWidget() {
    return std::make_shared<Widget>();
}

// ✅ Non-owning reference
void useWidget(Widget& w) {  // Reference = no ownership transfer
    w.doSomething();
}
```

### Move Semantics

```cpp
// ❌ UNNECESSARY COPIES
std::vector<int> createData() {
    std::vector<int> data(10000);
    // Fill data...
    return data;  // Copy in C++03, move in C++11
}

void process(std::vector<int> data) {  // Passed by value = copy
    // ...
}

// ✅ MOVE SEMANTICS
void process(std::vector<int>&& data) {  // Rvalue reference = move
    auto local = std::move(data);  // Moved, not copied
}

// ✅ Perfect forwarding
template<typename T>
void wrapper(T&& arg) {
    actual_function(std::forward<T>(arg));
}
```

### RAII Wrappers

```cpp
// ✅ RAII for C resources
class FileHandle {
public:
    explicit FileHandle(const char* path)
        : handle_(fopen(path, "r")) {
        if (!handle_) throw std::runtime_error("Failed to open");
    }

    ~FileHandle() {
        if (handle_) fclose(handle_);
    }

    // Delete copy operations
    FileHandle(const FileHandle&) = delete;
    FileHandle& operator=(const FileHandle&) = delete;

    // Allow move
    FileHandle(FileHandle&& other) noexcept
        : handle_(other.handle_) {
        other.handle_ = nullptr;
    }

    FILE* get() const { return handle_; }

private:
    FILE* handle_;
};

// ✅ Using std::unique_ptr with custom deleter
auto file = std::unique_ptr<FILE, decltype(&fclose)>(
    fopen("test.txt", "r"), fclose
);
```

### Const Correctness

```cpp
// ❌ MISSING CONST
class Widget {
public:
    int getValue() { return value_; }  // Should be const!
    void process(std::string& name);   // Modifies name?
};

// ✅ PROPER CONST USAGE
class Widget {
public:
    int getValue() const { return value_; }  // Doesn't modify
    void process(const std::string& name);   // Doesn't modify name

    const std::vector<int>& getData() const { return data_; }
};
```

---

## Control Flow Excellence

### Early Returns Pattern

```c
// ❌ WRONG - Deep nesting
int process_request(Request *req) {
    if (req != NULL) {
        if (req->is_valid) {
            if (req->has_permission) {
                // 30 lines of logic
                return SUCCESS;
            } else {
                return ERROR_PERMISSION;
            }
        } else {
            return ERROR_INVALID;
        }
    } else {
        return ERROR_NULL;
    }
}

// ✅ CORRECT - Early returns
int process_request(Request *req) {
    // Guard clauses first
    if (req == NULL) {
        return ERROR_NULL;
    }

    if (!req->is_valid) {
        return ERROR_INVALID;
    }

    if (!req->has_permission) {
        return ERROR_PERMISSION;
    }

    // Happy path - clear and at main indentation
    return do_actual_work(req);
}
```

### Maximum Nesting Rules

- **Level 0-1**: Preferred - main logic flow
- **Level 2**: Acceptable - simple nested conditions
- **Level 3**: Maximum - must justify complexity
- **Level 4+**: FORBIDDEN - refactor immediately

---

## Security Patterns

### Format String Protection

```c
// ❌ FORMAT STRING VULNERABILITY
printf(user_input);  // DANGEROUS!

// ✅ SAFE ALTERNATIVE
printf("%s", user_input);
```

### Integer Overflow Protection

```c
// ❌ INTEGER OVERFLOW
size_t size = count * element_size;  // Can overflow!

// ✅ SAFE ALTERNATIVE
if (count > SIZE_MAX / element_size) {
    return ERROR_OVERFLOW;
}
size_t size = count * element_size;
```

---

## Testing Requirements

### Sanitizer Build Configuration

```bash
# Debug build with ASan
cmake -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_C_FLAGS="-fsanitize=address,undefined -g" ..

# Debug build with TSan
cmake -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_C_FLAGS="-fsanitize=thread -g" ..

# Coverage build
cmake -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_C_FLAGS="--coverage -g" ..
```

### Memory Testing

```bash
# Valgrind memory check
valgrind --leak-check=full --error-exitcode=1 ./test_binary

# AddressSanitizer
./test_binary  # Built with -fsanitize=address

# ThreadSanitizer
./test_binary  # Built with -fsanitize=thread
```

---

## References

- **C++ Core Guidelines** - Bjarne Stroustrup & Herb Sutter (HIGHEST PRIORITY)
- **SEI CERT C/C++ Coding Standards** - Security-focused guidelines
- **Effective Modern C++** - Scott Meyers (C++11/14/17 patterns)
- **OpenSSF Compiler Hardening Guide** - Security compilation flags
