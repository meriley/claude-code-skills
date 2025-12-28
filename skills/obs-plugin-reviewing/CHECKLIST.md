# OBS Plugin Review Checklist

Quick reference checklist for OBS plugin code review. Print and check off items.

---

## P0 - CRITICAL (Must Fix Before Merge)

### Module Registration

- [ ] `OBS_DECLARE_MODULE()` macro present
- [ ] `obs_module_load()` returns `true` on success
- [ ] All sources/outputs registered in `obs_module_load()`

### Memory Safety

- [ ] Every `bzalloc`/`bmalloc` has matching `bfree` in destroy
- [ ] Context struct freed in destroy callback
- [ ] No double-free scenarios

### Audio Thread Safety

- [ ] No mutex/locks in `filter_audio` callback
- [ ] No memory allocation in `filter_audio`
- [ ] No I/O operations in `filter_audio`
- [ ] No `obs_data_get_*` calls in `filter_audio`

### Null Safety

- [ ] `audio->data[c]` checked for NULL before access
- [ ] `audio->frames` used for loop bounds (not hardcoded)
- [ ] `filter_audio` returns audio pointer (not NULL)

---

## P1 - HIGH (Should Fix)

### State Management

- [ ] No global/static mutable state
- [ ] Per-instance state in context struct
- [ ] Atomic operations for cross-thread state

### Error Handling

- [ ] Create callback returns NULL on allocation failure
- [ ] Settings validated in update callback
- [ ] Edge cases handled (empty input, zero frames)

### Resource Management

- [ ] Threads properly joined in destroy
- [ ] Events/signals properly destroyed
- [ ] File handles closed

---

## P2 - MEDIUM (Consider Fixing)

### Settings & UI

- [ ] `get_defaults` callback implemented
- [ ] `get_properties` creates all needed UI elements
- [ ] Range validation in update callback
- [ ] Sensible default values

### Localization

- [ ] `OBS_MODULE_USE_DEFAULT_LOCALE` set up
- [ ] `data/locale/en-US.ini` exists
- [ ] `obs_module_text()` used for UI strings

### Code Quality

- [ ] Consistent naming conventions
- [ ] No magic numbers (use #define constants)
- [ ] Logging for important events

---

## P3 - LOW (Nice to Have)

### Documentation

- [ ] License header in source files
- [ ] Function comments for complex logic
- [ ] README with build instructions

### Build System

- [ ] CMakeLists.txt uses cmake 3.28+
- [ ] buildspec.json has valid metadata
- [ ] All source files listed in target_sources

---

## Quick Grep Commands

```bash
# P0 Checks
grep -l "OBS_DECLARE_MODULE" src/*.c
grep -A5 "obs_module_load" src/*.c
grep -l "bfree" src/*.c
grep -A20 "filter_audio" src/*.c | grep -E "(mutex|malloc)"
grep "audio->data\[" src/*.c

# P1 Checks
grep "^static.*=" src/*.c
grep -E "(pthread|mutex)" src/*.c

# P2 Checks
grep "get_defaults" src/*.c
ls data/locale/
grep "obs_module_text" src/*.c
```

---

## Audio Filter Specific

### filter_audio Callback

```c
static struct obs_audio_data *filter_audio(void *data,
                                           struct obs_audio_data *audio)
{
    struct filter_data *ctx = data;
    float **adata = (float **)audio->data;

    for (size_t c = 0; c < ctx->channels; c++) {
        if (!audio->data[c])      // ✓ NULL check
            continue;

        for (size_t i = 0; i < audio->frames; i++) {  // ✓ Use frames
            adata[c][i] *= ctx->gain;
        }
    }
    return audio;  // ✓ Return audio
}
```

### Thread-Safe Config Pattern

```c
/* update() - main thread */
atomic_store(&ctx->gain, new_value);

/* filter_audio() - audio thread */
float gain = atomic_load(&ctx->gain);
```

---

## Common Issues Quick Reference

| Issue           | Detection             | Fix                               |
| --------------- | --------------------- | --------------------------------- |
| Missing bfree   | No bfree in destroy   | Add bfree for all allocations     |
| Blocking audio  | mutex in filter_audio | Use atomics instead               |
| NULL crash      | No data[c] check      | Add if (!audio->data[c]) continue |
| Buffer overflow | Hardcoded frame count | Use audio->frames                 |
| Global state    | static variables      | Move to context struct            |
| No defaults     | Missing get_defaults  | Implement callback                |
