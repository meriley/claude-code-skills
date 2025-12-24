# Translation Helper: Whisper.cpp Integration & VAD Sensitivity

## Summary

**User Requirements:**
1. Add whisper.cpp as a selectable engine (memory is tight for large models)
2. Make engine selection available in CLI tool
3. Fix VAD sensitivity (missing quiet speech, short utterances, sentence edges)

---

## 1. Engine Comparison

| Aspect | faster-whisper (current) | whisper.cpp |
|--------|-------------------------|-------------|
| Memory (large-v3) | ~10 GB VRAM | **~5-7 GB VRAM** |
| GPU Performance | Excellent | Excellent |
| Built-in VAD | ✅ Silero VAD | ❌ None |
| Streaming | Limited | ✅ Real-time |
| Integration | Docker + Python | Docker + Binary |

**Recommendation:** Support both engines - use whisper.cpp when memory constrained, faster-whisper for VAD-heavy workflows.

---

## 2. Implementation Plan

### Phase 1: Enhanced VAD for faster-whisper (Quick Win)

**Files to modify:**

#### `whisper-cli.py` (lines 21-28)
Add missing VAD parameters:
```python
# Add these arguments
parser.add_argument('--vad_max_speech_duration_s', type=float, default=float('inf'))
parser.add_argument('--vad_min_silence_duration_ms', type=int, default=500)  # Was 2000
parser.add_argument('--vad_speech_pad_ms', type=int, default=200)  # Was 400
parser.add_argument('--vad_threshold', type=float, default=0.3)  # Was 0.5
```

Update `vad_parameters` dict (lines 54-57):
```python
vad_parameters={
    "min_speech_duration_ms": args.vad_min_speech_duration_ms,
    "max_speech_duration_s": args.vad_max_speech_duration_s,
    "min_silence_duration_ms": args.vad_min_silence_duration_ms,
    "speech_pad_ms": args.vad_speech_pad_ms,
    "threshold": args.vad_threshold,
} if vad_filter else None
```

#### `whisper-manager.py` (lines 714-720)
Update VAD defaults for better sensitivity:
```python
cmd.extend([
    '--vad_filter', 'True',
    '--vad_min_speech_duration_ms', '100',     # Was 250
    '--vad_min_silence_duration_ms', '500',    # Was default 2000
    '--vad_speech_pad_ms', '200',              # Was default 400
    '--vad_threshold', '0.3',                  # Was default 0.5
    '--beam_size', '1',
    '--temperature', '0',
    '--condition_on_previous_text', 'False',
])
```

---

### Phase 2: Whisper.cpp Integration

#### 2.1 Create whisper.cpp Dockerfile

**New file:** `Dockerfile.whisper-cpp`
```dockerfile
FROM nvidia/cuda:12.3.2-cudnn9-devel-ubuntu22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential cmake git ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Clone and build whisper.cpp with CUDA
WORKDIR /opt
RUN git clone https://github.com/ggerganov/whisper.cpp.git && \
    cd whisper.cpp && \
    WHISPER_CUDA=1 make -j$(nproc)

# Download models (ggml format)
RUN cd whisper.cpp/models && \
    ./download-ggml-model.sh large-v3

WORKDIR /opt/whisper.cpp
ENTRYPOINT ["./main"]
```

#### 2.2 Create whisper-cpp wrapper

**New file:** `whisper-cpp-cli.py`
- Wraps whisper.cpp binary with compatible interface
- Handles SRT output format conversion
- Provides same CLI interface as whisper-cli.py

#### 2.3 Update whisper-manager.py

**Add engine selection:**

```python
# New constant (line ~57)
WHISPER_ENGINES = ['faster-whisper', 'whisper-cpp']
DOCKER_IMAGES = {
    'faster-whisper': 'whisper-translate:latest',
    'whisper-cpp': 'whisper-cpp:latest',
}

# Updated memory requirements (line ~113)
MODEL_MEMORY_REQUIREMENTS = {
    'faster-whisper': {
        'tiny': 1024, 'base': 1024, 'small': 2048,
        'medium': 5120, 'large': 10240, 'large-v3': 10240,
    },
    'whisper-cpp': {
        'tiny': 512, 'base': 512, 'small': 1024,
        'medium': 2560, 'large': 5120, 'large-v3': 5120,  # ~50% less
    },
}
```

**CLI arguments (add to parser ~line 1047):**
```python
parser.add_argument('--engine', type=str,
    choices=WHISPER_ENGINES, default='faster-whisper',
    help='Transcription engine (default: faster-whisper)')
```

**Interactive mode (add engine selection):**
```python
def select_engine_interactive() -> Optional[str]:
    """Interactive engine selection"""
    gpu_memory = get_gpu_memory()

    engine_options = [
        f"faster-whisper - Best VAD, needs more VRAM (~{gpu_memory or '?'} MB free)",
        f"whisper-cpp - Lower memory (~50% less), no built-in VAD",
    ]

    selected = select_from_list("Select engine:", engine_options)
    if selected:
        return selected.split()[0]
    return None
```

---

### Phase 3: VAD Presets (Optional Enhancement)

Add preset system for easy configuration:

```python
VAD_PRESETS = {
    'low': {  # Current behavior
        'vad_min_speech_duration_ms': 250,
        'vad_min_silence_duration_ms': 2000,
        'vad_speech_pad_ms': 400,
        'vad_threshold': 0.5,
    },
    'medium': {  # Balanced
        'vad_min_speech_duration_ms': 150,
        'vad_min_silence_duration_ms': 1000,
        'vad_speech_pad_ms': 300,
        'vad_threshold': 0.4,
    },
    'high': {  # Most sensitive (recommended)
        'vad_min_speech_duration_ms': 100,
        'vad_min_silence_duration_ms': 500,
        'vad_speech_pad_ms': 200,
        'vad_threshold': 0.3,
    },
}
```

CLI: `--vad-preset [low|medium|high]`

---

## 3. Files to Create/Modify

| File | Action | Changes |
|------|--------|---------|
| `whisper-cli.py` | Modify | Add VAD parameters (5 new args) |
| `whisper-manager.py` | Modify | Engine selection, VAD presets, memory tables |
| `Dockerfile.whisper-cpp` | Create | whisper.cpp CUDA build |
| `whisper-cpp-cli.py` | Create | Wrapper for whisper.cpp binary |
| `Makefile` | Modify | Add build target for whisper-cpp image |

---

## 4. Task Breakdown

### Phase 1: VAD Sensitivity (Immediate Fix)
- [ ] Add VAD parameters to `whisper-cli.py` argparse
- [ ] Update `whisper-cli.py` vad_parameters dict
- [ ] Update `whisper-manager.py` with sensitive defaults
- [ ] Test with problematic audio samples

### Phase 2: Whisper.cpp Engine
- [ ] Create `Dockerfile.whisper-cpp`
- [ ] Build whisper-cpp Docker image
- [ ] Create `whisper-cpp-cli.py` wrapper
- [ ] Add engine selection to `whisper-manager.py` CLI args
- [ ] Add engine selection to interactive mode
- [ ] Update memory requirement tables
- [ ] Update Makefile with new build target
- [ ] Test whisper-cpp with same audio samples

### Phase 3: Polish (Optional)
- [ ] Add VAD preset system
- [ ] Add `--vad-preset` CLI flag
- [ ] Update help text and documentation

---

## 5. Testing Strategy

1. **VAD Sensitivity Test**
   - Use audio with quiet speech
   - Verify short utterances captured
   - Check sentence beginnings/endings

2. **Engine Comparison Test**
   - Same audio file, both engines
   - Compare VRAM usage
   - Compare output quality

3. **Memory Validation**
   - Test large-v3 on whisper-cpp
   - Verify reduced memory footprint
