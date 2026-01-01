# OBS Cross-Compilation Reference

## CMake Preset Variables

### Configure Preset Fields

| Field            | Type   | Description                                              |
| ---------------- | ------ | -------------------------------------------------------- |
| `name`           | string | Unique preset identifier                                 |
| `displayName`    | string | Human-readable name                                      |
| `description`    | string | Detailed description                                     |
| `hidden`         | bool   | If true, not listed (use for templates)                  |
| `inherits`       | array  | Parent presets to inherit from                           |
| `binaryDir`      | string | Output directory                                         |
| `generator`      | string | CMake generator ("Ninja", "Visual Studio 17 2022", etc.) |
| `toolchainFile`  | string | Path to toolchain file                                   |
| `condition`      | object | When preset is available                                 |
| `cacheVariables` | object | CMake cache variables                                    |
| `warnings`       | object | Warning settings                                         |

### Condition Types

```json
{
  "condition": {
    "type": "equals",
    "lhs": "${hostSystemName}",
    "rhs": "Linux"
  }
}
```

**Available variables:**

- `${hostSystemName}` - Host OS ("Linux", "Darwin", "Windows")
- `${sourceDir}` - Source directory path
- `${presetName}` - Current preset name

### Build Preset Fields

| Field             | Type   | Description                                       |
| ----------------- | ------ | ------------------------------------------------- |
| `name`            | string | Unique preset identifier                          |
| `configurePreset` | string | Configure preset to use                           |
| `configuration`   | string | Build type ("Debug", "Release", "RelWithDebInfo") |

## MinGW Compiler Flags

### Cross-Compiler Executables

| Executable                   | Purpose               |
| ---------------------------- | --------------------- |
| `x86_64-w64-mingw32-gcc`     | C compiler            |
| `x86_64-w64-mingw32-g++`     | C++ compiler          |
| `x86_64-w64-mingw32-windres` | Resource compiler     |
| `x86_64-w64-mingw32-objdump` | Object file inspector |
| `x86_64-w64-mingw32-nm`      | Symbol table viewer   |
| `x86_64-w64-mingw32-strip`   | Strip symbols         |

### Linker Flags

| Flag                                  | Purpose                                      |
| ------------------------------------- | -------------------------------------------- |
| `-static-libgcc`                      | Static link libgcc (avoid DLL dependency)    |
| `-static-libstdc++`                   | Static link libstdc++ (avoid DLL dependency) |
| `-Wl,--unresolved-symbols=ignore-all` | Don't fail on missing symbols                |
| `-Wl,--warn-unresolved-symbols`       | Warn instead of error                        |
| `-Wl,--noinhibit-exec`                | Create output despite errors                 |

### CMAKE_FIND_ROOT_PATH_MODE Options

| Mode                                | Value   | Effect                                 |
| ----------------------------------- | ------- | -------------------------------------- |
| `CMAKE_FIND_ROOT_PATH_MODE_PROGRAM` | `NEVER` | Search host for programs (cmake, etc.) |
| `CMAKE_FIND_ROOT_PATH_MODE_LIBRARY` | `ONLY`  | Search target for libraries            |
| `CMAKE_FIND_ROOT_PATH_MODE_INCLUDE` | `ONLY`  | Search target for headers              |
| `CMAKE_FIND_ROOT_PATH_MODE_PACKAGE` | `ONLY`  | Search target for packages             |

## Platform Detection Macros

### CMake Platform Detection

```cmake
# Check host system
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    # Running on Linux
endif()

# Check target system
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    # Building for Windows
endif()

# Check compiler
if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    # Using GCC (includes MinGW)
endif()

if(MINGW)
    # Building with MinGW
endif()
```

### C/C++ Platform Macros

```c
#ifdef _WIN32
    // Windows (32-bit or 64-bit)
#endif

#ifdef _WIN64
    // Windows 64-bit
#endif

#ifdef __linux__
    // Linux
#endif

#ifdef __APPLE__
    // macOS
#endif

#ifdef __MINGW32__
    // MinGW (32-bit or 64-bit)
#endif

#ifdef __MINGW64__
    // MinGW 64-bit
#endif
```

## OBS API Symbols (Required Exports)

### Module Functions

| Symbol                   | Signature                                           | Required |
| ------------------------ | --------------------------------------------------- | -------- |
| `obs_module_load`        | `bool obs_module_load(void)`                        | Yes      |
| `obs_module_unload`      | `void obs_module_unload(void)`                      | No       |
| `obs_module_post_load`   | `void obs_module_post_load(void)`                   | No       |
| `obs_module_ver`         | `uint32_t obs_module_ver(void)`                     | Auto     |
| `obs_module_set_pointer` | `void obs_module_set_pointer(obs_module_t *module)` | Auto     |
| `obs_current_module`     | `obs_module_t *obs_current_module(void)`            | Auto     |
| `obs_module_description` | `const char *obs_module_description(void)`          | No       |

### Locale Functions (from OBS_MODULE_USE_DEFAULT_LOCALE)

| Symbol                   | Signature                                            |
| ------------------------ | ---------------------------------------------------- |
| `obs_module_set_locale`  | `void obs_module_set_locale(const char *locale)`     |
| `obs_module_free_locale` | `void obs_module_free_locale(void)`                  |
| `obs_module_get_string`  | `const char *obs_module_get_string(const char *val)` |
| `obs_module_text`        | `const char *obs_module_text(const char *val)`       |

## CI Artifact Naming

### Convention

```
{name}-{version}-{platform}-{commit}.{ext}
```

### Components

| Component  | Description                     | Example                                          |
| ---------- | ------------------------------- | ------------------------------------------------ |
| `name`     | Plugin name from buildspec.json | `my-plugin`                                      |
| `version`  | SemVer from buildspec.json      | `1.0.0`                                          |
| `platform` | Target platform                 | `linux-x86_64`, `windows-x64`, `macos-universal` |
| `commit`   | Short git hash (9 chars)        | `abc123def`                                      |
| `ext`      | Archive format                  | `tar.xz` (Linux/macOS), `zip` (Windows)          |

### Directory Structure Inside Archive

```
{artifact-name}/
├── bin/
│   └── 64bit/
│       ├── my-plugin.so    (Linux)
│       ├── my-plugin.dll   (Windows)
│       └── my-plugin.dylib (macOS)
└── data/
    └── locale/
        ├── en-US.ini
        └── de-DE.ini
```

## OBS Plugin Installation Paths

### Per-Platform Paths

| Platform | User Directory                                               |
| -------- | ------------------------------------------------------------ |
| Linux    | `~/.config/obs-studio/plugins/{plugin}/`                     |
| Windows  | `%APPDATA%\obs-studio\plugins\{plugin}\`                     |
| macOS    | `~/Library/Application Support/obs-studio/plugins/{plugin}/` |

### System-Wide Paths

| Platform | System Directory                                            |
| -------- | ----------------------------------------------------------- |
| Linux    | `/usr/share/obs/obs-plugins/` or `/usr/lib/obs-plugins/`    |
| Windows  | `C:\ProgramData\obs-studio\plugins\{plugin}\`               |
| macOS    | `/Library/Application Support/obs-studio/plugins/{plugin}/` |

## DLL Export Verification

### Check Export Table

```bash
# Show all exports
x86_64-w64-mingw32-objdump -p my-plugin.dll | grep -A 100 "Export Table"

# Expected output shows named exports:
# [Ordinal/Name Pointer] Table
#         [   0] obs_module_load
#         [   1] obs_module_unload
#         ...
```

### Check Symbol Table

```bash
# List all symbols
x86_64-w64-mingw32-nm my-plugin.dll

# Filter for OBS functions
x86_64-w64-mingw32-nm my-plugin.dll | grep obs_
```

### Verify File Format

```bash
# Check it's a Windows DLL
file my-plugin.dll
# Expected: "PE32+ executable (DLL) (console) x86-64, for MS Windows"

# NOT: "ELF 64-bit LSB shared object"
```

## buildspec.json Schema

```json
{
  "name": "string (required)",
  "displayName": "string (optional)",
  "version": "string (SemVer, required)",
  "author": "string (optional)",
  "website": "string (URL, optional)",
  "email": "string (optional)",
  "dependencies": {
    "obs-studio": {
      "version": "string (required)",
      "hashes": {
        "windows-x64": "string (SHA256)",
        "linux-x86_64": "string (SHA256)",
        "macos-universal": "string (SHA256)"
      }
    }
  }
}
```

## Error Codes and Diagnostics

### Common Linker Errors

| Error                                          | Cause                           | Solution                                  |
| ---------------------------------------------- | ------------------------------- | ----------------------------------------- |
| `undefined reference to 'obs_register_source'` | Missing unresolved-symbols flag | Add `-Wl,--unresolved-symbols=ignore-all` |
| `cannot find -lobs`                            | Trying to link libobs           | Use headers-only approach                 |
| `file format not recognized`                   | Wrong object file format        | Check toolchain file is loaded            |

### DLL Load Failures in OBS

| Symptom            | Cause                   | Solution                               |
| ------------------ | ----------------------- | -------------------------------------- |
| Plugin not visible | DLL not in correct path | Check `bin/64bit/` structure           |
| "Failed to load"   | Missing exports         | Verify .def file and exports           |
| "Missing DLL"      | Runtime dependencies    | Add `-static-libgcc -static-libstdc++` |

## Git Commands for CI

### Get Short Commit Hash

```bash
git rev-parse --short=9 HEAD
```

### Get Latest Tag

```bash
git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0"
```

### Get Commits Since Tag

```bash
LAST_TAG=$(git describe --tags --abbrev=0)
git log ${LAST_TAG}..HEAD --pretty=format:"%s"
```

### Check if Tag Push

```bash
if [[ "$GITHUB_REF" == refs/tags/* ]]; then
    TAG="${GITHUB_REF#refs/tags/}"
fi
```
