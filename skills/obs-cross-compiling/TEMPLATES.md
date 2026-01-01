# OBS Cross-Compilation Templates

Ready-to-use templates for cross-compiling OBS plugins from Linux to Windows.

## CMakePresets.json (Full Multi-Platform)

```json
{
  "version": 8,
  "cmakeMinimumRequired": {
    "major": 3,
    "minor": 28,
    "patch": 0
  },
  "configurePresets": [
    {
      "name": "template",
      "hidden": true,
      "cacheVariables": {
        "ENABLE_FRONTEND_API": false,
        "ENABLE_QT": false
      }
    },
    {
      "name": "macos",
      "displayName": "macOS Universal",
      "description": "Build for macOS 12.0+ (Universal binary)",
      "inherits": ["template"],
      "binaryDir": "${sourceDir}/build_macos",
      "condition": {
        "type": "equals",
        "lhs": "${hostSystemName}",
        "rhs": "Darwin"
      },
      "generator": "Xcode",
      "warnings": { "dev": true, "deprecated": true },
      "cacheVariables": {
        "CMAKE_OSX_DEPLOYMENT_TARGET": "12.0",
        "CMAKE_OSX_ARCHITECTURES": "arm64;x86_64"
      }
    },
    {
      "name": "macos-ci",
      "inherits": ["macos"],
      "displayName": "macOS Universal CI build",
      "cacheVariables": {
        "CMAKE_COMPILE_WARNING_AS_ERROR": true,
        "ENABLE_CCACHE": true
      }
    },
    {
      "name": "windows-x64",
      "displayName": "Windows x64",
      "description": "Build for Windows x64 (native Visual Studio)",
      "inherits": ["template"],
      "binaryDir": "${sourceDir}/build_x64",
      "generator": "Visual Studio 17 2022",
      "architecture": "x64",
      "warnings": { "dev": true, "deprecated": true },
      "cacheVariables": {
        "OBS_SOURCE_DIR": "${sourceDir}/.deps/windows-x64/obs-studio-32.0.4"
      }
    },
    {
      "name": "windows-ci-x64",
      "inherits": ["windows-x64"],
      "displayName": "Windows x64 CI build",
      "cacheVariables": {
        "CMAKE_COMPILE_WARNING_AS_ERROR": true
      }
    },
    {
      "name": "ubuntu-x86_64",
      "displayName": "Ubuntu x86_64",
      "description": "Build for Ubuntu x86_64",
      "inherits": ["template"],
      "binaryDir": "${sourceDir}/build_x86_64",
      "condition": {
        "type": "equals",
        "lhs": "${hostSystemName}",
        "rhs": "Linux"
      },
      "generator": "Ninja",
      "warnings": { "dev": true, "deprecated": true },
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "RelWithDebInfo"
      }
    },
    {
      "name": "ubuntu-ci-x86_64",
      "inherits": ["ubuntu-x86_64"],
      "displayName": "Ubuntu x86_64 CI build",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "RelWithDebInfo",
        "CMAKE_COMPILE_WARNING_AS_ERROR": true,
        "ENABLE_CCACHE": true
      }
    },
    {
      "name": "linux-cross-windows-x64",
      "displayName": "Cross-compile Windows x64 (from Linux)",
      "description": "Cross-compile for Windows x64 using MinGW-w64 on Linux",
      "inherits": ["template"],
      "binaryDir": "${sourceDir}/build_windows_x64",
      "condition": {
        "type": "equals",
        "lhs": "${hostSystemName}",
        "rhs": "Linux"
      },
      "generator": "Ninja",
      "toolchainFile": "${sourceDir}/cmake/mingw-w64-toolchain.cmake",
      "warnings": { "dev": true, "deprecated": true },
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "RelWithDebInfo",
        "CROSS_COMPILE_WINDOWS": true
      }
    },
    {
      "name": "linux-cross-windows-ci-x64",
      "inherits": ["linux-cross-windows-x64"],
      "displayName": "Cross-compile Windows x64 CI (from Linux)",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "RelWithDebInfo",
        "CMAKE_COMPILE_WARNING_AS_ERROR": true,
        "CROSS_COMPILE_WINDOWS": true
      }
    }
  ],
  "buildPresets": [
    {
      "name": "macos",
      "configurePreset": "macos",
      "configuration": "RelWithDebInfo"
    },
    {
      "name": "macos-ci",
      "configurePreset": "macos-ci",
      "configuration": "RelWithDebInfo"
    },
    {
      "name": "windows-x64",
      "configurePreset": "windows-x64",
      "configuration": "RelWithDebInfo"
    },
    {
      "name": "windows-ci-x64",
      "configurePreset": "windows-ci-x64",
      "configuration": "RelWithDebInfo"
    },
    {
      "name": "ubuntu-x86_64",
      "configurePreset": "ubuntu-x86_64"
    },
    {
      "name": "ubuntu-ci-x86_64",
      "configurePreset": "ubuntu-ci-x86_64"
    },
    {
      "name": "linux-cross-windows-x64",
      "configurePreset": "linux-cross-windows-x64"
    },
    {
      "name": "linux-cross-windows-ci-x64",
      "configurePreset": "linux-cross-windows-ci-x64"
    }
  ]
}
```

## mingw-w64-toolchain.cmake

```cmake
# mingw-w64-toolchain.cmake - CMake toolchain for Windows cross-compilation
#
# Usage:
#   cmake -DCMAKE_TOOLCHAIN_FILE=cmake/mingw-w64-toolchain.cmake ..
#
# Prerequisites:
#   - mingw-w64 package installed (sudo apt install mingw-w64)

set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Cross-compiler
set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)
set(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)

# Target environment
set(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32)

# Search for programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Search for libraries and headers in the target environment
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Windows-specific settings
set(WIN32 TRUE)
set(MINGW TRUE)

# Output suffix
set(CMAKE_SHARED_LIBRARY_SUFFIX ".dll")
set(CMAKE_EXECUTABLE_SUFFIX ".exe")

# Position-independent code is always enabled on Windows
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Link static libgcc and libstdc++ to avoid runtime dependencies
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libgcc -static-libstdc++")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -static-libgcc -static-libstdc++")
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -static-libgcc -static-libstdc++")

# For OBS plugins (MODULE libraries): allow undefined symbols (resolved at runtime by OBS)
# This is required because we're cross-compiling without OBS import libraries
# --unresolved-symbols=ignore-all: don't report missing symbols
# --warn-unresolved-symbols: downgrade errors to warnings
# --noinhibit-exec: force output creation despite unresolved symbols
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -Wl,--unresolved-symbols=ignore-all,--warn-unresolved-symbols,--noinhibit-exec")
```

## buildspec.json

```json
{
  "name": "my-obs-plugin",
  "displayName": "My OBS Plugin",
  "version": "1.0.0",
  "author": "Your Name",
  "website": "https://github.com/yourname/my-obs-plugin",
  "email": "you@example.com",
  "dependencies": {
    "obs-studio": {
      "version": "32.0.4",
      "hashes": {
        "windows-x64": "5e17f2e99213af77ee15c047755ee3e3e88b78e5eee17351c113d79671ffb98b"
      }
    },
    "prebuilt": {
      "version": "2025-07-11",
      "hashes": {
        "windows-x64": "c8c642c1070dc31ce9a0f1e4cef5bb992f4bff4882255788b5da12129e85caa7"
      }
    }
  }
}
```

## plugin.def (Windows Exports)

```def
; plugin.def - DLL export definitions for OBS plugin
;
; MinGW sometimes exports functions by ordinal only (not by name).
; OBS looks up module functions BY NAME, so we must explicitly
; list all exports to ensure they appear in the name table.
;
LIBRARY my-obs-plugin
EXPORTS
    ; Required OBS module entry points
    obs_module_load
    obs_module_unload
    obs_module_post_load
    obs_module_ver
    obs_module_set_pointer
    obs_current_module
    obs_module_description

    ; OBS locale functions (from OBS_MODULE_USE_DEFAULT_LOCALE)
    obs_module_set_locale
    obs_module_free_locale
    obs_module_get_string
    obs_module_text
```

## fetch-obs-sdk.sh

```bash
#!/bin/bash
# fetch-obs-sdk.sh - Download OBS Studio headers for cross-compilation
#
# Usage: ./fetch-obs-sdk.sh <platform>
#   platform: windows, linux, or macos
#
# This script downloads OBS Studio source code (for headers) and
# any required prebuilt dependencies.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILDSPEC="$PLUGIN_ROOT/buildspec.json"

# Parse arguments
PLATFORM="${1:-}"
if [[ -z "$PLATFORM" ]]; then
    echo "Usage: $0 <platform>"
    echo "  platform: windows, linux, or macos"
    exit 1
fi

# Read versions from buildspec.json
OBS_VERSION=$(jq -r '.dependencies["obs-studio"].version' "$BUILDSPEC")
OBS_HASH=$(jq -r ".dependencies[\"obs-studio\"].hashes[\"${PLATFORM}-x64\"]" "$BUILDSPEC")

echo "=== OBS SDK Fetcher ==="
echo "Platform: $PLATFORM"
echo "OBS Version: $OBS_VERSION"
echo ""

# Create deps directory
DEPS_DIR="$PLUGIN_ROOT/.deps/${PLATFORM}-x64"
mkdir -p "$DEPS_DIR"
cd "$DEPS_DIR"

# Download OBS source (for headers)
if [[ ! -d "obs-studio-$OBS_VERSION" ]]; then
    echo "Downloading OBS Studio $OBS_VERSION..."
    OBS_URL="https://github.com/obsproject/obs-studio/archive/refs/tags/${OBS_VERSION}.tar.gz"
    curl -L "$OBS_URL" -o obs-studio.tar.gz

    # Verify checksum if available
    if [[ -n "$OBS_HASH" && "$OBS_HASH" != "null" ]]; then
        echo "Verifying checksum..."
        echo "$OBS_HASH  obs-studio.tar.gz" | sha256sum -c
    fi

    tar -xzf obs-studio.tar.gz
    rm obs-studio.tar.gz
fi

# Create stub obsconfig.h (normally generated by CMake)
OBSCONFIG="$DEPS_DIR/obs-studio-$OBS_VERSION/libobs/obsconfig.h"
if [[ ! -f "$OBSCONFIG" ]]; then
    echo "Creating stub obsconfig.h..."
    cat > "$OBSCONFIG" << EOF
#pragma once
/* Stub obsconfig.h for cross-compilation */
#define OBS_VERSION "$OBS_VERSION"
#define OBS_DATA_PATH ""
#define OBS_INSTALL_PREFIX ""
#define OBS_PLUGIN_PATH ""
#define OBS_RELATIVE_PREFIX "../../"
EOF
fi

echo ""
echo "=== OBS SDK Ready ==="
echo "OBS Source: $DEPS_DIR/obs-studio-$OBS_VERSION"
echo ""
echo "Use with CMake:"
echo "  cmake -DOBS_SOURCE_DIR=$DEPS_DIR/obs-studio-$OBS_VERSION .."
```

## GitHub Actions Workflow

```yaml
name: Build OBS Plugin

on:
  push:
    branches: [main]
    tags: ["v*"]
  pull_request:
    branches: [main]

env:
  PLUGIN_NAME: my-obs-plugin

jobs:
  build-linux:
    name: Build Linux x86_64
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y cmake ninja-build libobs-dev jq

      - name: Configure
        run: cmake --preset ubuntu-ci-x86_64

      - name: Build
        run: cmake --build --preset ubuntu-ci-x86_64

      - name: Package
        run: |
          VERSION=$(jq -r '.version' buildspec.json)
          COMMIT=$(git rev-parse --short=9 HEAD)
          ARTIFACT="${PLUGIN_NAME}-${VERSION}-linux-x86_64-${COMMIT}"

          mkdir -p "release/${ARTIFACT}/bin/64bit"
          mkdir -p "release/${ARTIFACT}/data/locale"

          cp build_x86_64/${PLUGIN_NAME}.so "release/${ARTIFACT}/bin/64bit/"
          cp -r data/locale/*.ini "release/${ARTIFACT}/data/locale/" 2>/dev/null || true

          cd release && tar -cJf "${ARTIFACT}.tar.xz" "${ARTIFACT}"

      - uses: actions/upload-artifact@v4
        with:
          name: linux-x86_64
          path: release/*.tar.xz

  build-windows:
    name: Build Windows x64 (Cross-compile)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y \
            cmake ninja-build jq curl unzip \
            mingw-w64 gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64

      - name: Fetch OBS SDK
        run: |
          chmod +x ci/fetch-obs-sdk.sh
          ci/fetch-obs-sdk.sh windows

      - name: Configure
        run: |
          OBS_VERSION=$(jq -r '.dependencies["obs-studio"].version' buildspec.json)
          cmake --preset linux-cross-windows-ci-x64 \
            -DOBS_SOURCE_DIR="${PWD}/.deps/windows-x64/obs-studio-${OBS_VERSION}"

      - name: Build
        run: cmake --build --preset linux-cross-windows-ci-x64

      - name: Verify DLL
        run: |
          file build_windows_x64/${PLUGIN_NAME}.dll | grep "PE32+"

      - name: Package
        run: |
          VERSION=$(jq -r '.version' buildspec.json)
          COMMIT=$(git rev-parse --short=9 HEAD)
          ARTIFACT="${PLUGIN_NAME}-${VERSION}-windows-x64-${COMMIT}"

          mkdir -p "release/${ARTIFACT}/bin/64bit"
          mkdir -p "release/${ARTIFACT}/data/locale"

          cp build_windows_x64/${PLUGIN_NAME}.dll "release/${ARTIFACT}/bin/64bit/"
          cp -r data/locale/*.ini "release/${ARTIFACT}/data/locale/" 2>/dev/null || true

          cd release && zip -rq "${ARTIFACT}.zip" "${ARTIFACT}"

      - uses: actions/upload-artifact@v4
        with:
          name: windows-x64
          path: release/*.zip

  release:
    name: Create Release
    runs-on: ubuntu-latest
    needs: [build-linux, build-windows]
    if: startsWith(github.ref, 'refs/tags/v')
    steps:
      - uses: actions/checkout@v4

      - uses: actions/download-artifact@v4
        with:
          path: release/

      - name: Generate checksums
        working-directory: release
        run: |
          find . -name "*.tar.xz" -o -name "*.zip" | xargs sha256sum > checksums-sha256.txt
          cat checksums-sha256.txt

      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            release/**/*.tar.xz
            release/**/*.zip
            release/checksums-sha256.txt
          generate_release_notes: true
```

## CMakeLists.txt (Cross-Platform Plugin)

```cmake
cmake_minimum_required(VERSION 3.28)
project(my-obs-plugin VERSION 1.0.0 LANGUAGES C CXX)

# C/C++ standards
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Cross-compilation option
option(CROSS_COMPILE_WINDOWS "Cross-compile for Windows from Linux" OFF)

# Determine build mode
if(CROSS_COMPILE_WINDOWS OR DEFINED OBS_SOURCE_DIR)
    # Building from OBS source: use headers directly
    if(NOT DEFINED OBS_SOURCE_DIR)
        message(FATAL_ERROR "OBS_SOURCE_DIR must be set for cross-compilation")
    endif()

    message(STATUS "Building from OBS source: ${OBS_SOURCE_DIR}")
    set(BUILD_FROM_OBS_SOURCE ON)

    # Create interface library for OBS headers
    add_library(obs-headers INTERFACE)
    target_include_directories(obs-headers INTERFACE
        "${OBS_SOURCE_DIR}/libobs"
        "${OBS_SOURCE_DIR}/frontend/api"
    )

    # Windows defines
    target_compile_definitions(obs-headers INTERFACE
        UNICODE _UNICODE _CRT_SECURE_NO_WARNINGS
    )
    if(WIN32 OR CROSS_COMPILE_WINDOWS)
        target_compile_definitions(obs-headers INTERFACE WIN32 _WIN32)
    endif()
else()
    # Native build with installed OBS
    set(BUILD_FROM_OBS_SOURCE OFF)
    find_package(libobs REQUIRED)
endif()

# Create plugin module
add_library(${PROJECT_NAME} MODULE
    src/plugin-main.c
    src/my-source.c
)

# Platform-specific sources
if(WIN32 OR CROSS_COMPILE_WINDOWS)
    target_sources(${PROJECT_NAME} PRIVATE
        src/platform/socket-win32.c
    )
    target_link_libraries(${PROJECT_NAME} PRIVATE ws2_32 comctl32)

    # Export OBS module functions
    if(CROSS_COMPILE_WINDOWS OR CMAKE_C_COMPILER_ID STREQUAL "GNU")
        # MinGW: Use .def file + ignore unresolved symbols
        set_target_properties(${PROJECT_NAME} PROPERTIES
            LINK_FLAGS "${CMAKE_CURRENT_SOURCE_DIR}/src/plugin.def -Wl,--unresolved-symbols=ignore-all"
        )
    else()
        # MSVC: Use .def file for exports
        set_target_properties(${PROJECT_NAME} PROPERTIES
            LINK_FLAGS "/DEF:${CMAKE_CURRENT_SOURCE_DIR}/src/plugin.def"
        )
    endif()
else()
    target_sources(${PROJECT_NAME} PRIVATE
        src/platform/socket-posix.c
    )
endif()

# Link OBS
if(BUILD_FROM_OBS_SOURCE)
    target_link_libraries(${PROJECT_NAME} PRIVATE obs-headers)
else()
    target_link_libraries(${PROJECT_NAME} PRIVATE OBS::libobs)
endif()

# Output properties
set_target_properties(${PROJECT_NAME} PROPERTIES
    PREFIX ""
    OUTPUT_NAME "${PROJECT_NAME}"
)

# Install paths
if(WIN32)
    set(OBS_PLUGIN_DIR "$ENV{APPDATA}/obs-studio/plugins/${PROJECT_NAME}")
elseif(APPLE)
    set(OBS_PLUGIN_DIR "$ENV{HOME}/Library/Application Support/obs-studio/plugins/${PROJECT_NAME}")
else()
    set(OBS_PLUGIN_DIR "$ENV{HOME}/.config/obs-studio/plugins/${PROJECT_NAME}")
endif()

install(TARGETS ${PROJECT_NAME}
    LIBRARY DESTINATION ${OBS_PLUGIN_DIR}/bin/64bit
    RUNTIME DESTINATION ${OBS_PLUGIN_DIR}/bin/64bit
)
```

## Makefile (Build Wrapper)

```makefile
# Makefile - OBS Plugin build wrapper
#
# Usage:
#   make plugin-configure    # Configure for current platform
#   make plugin-build        # Build plugin
#   make plugin-cross-win    # Cross-compile for Windows
#   make help                # Show all targets

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    CMAKE_PRESET := ubuntu-x86_64
else ifeq ($(UNAME_S),Darwin)
    CMAKE_PRESET := macos
else
    CMAKE_PRESET := windows-x64
endif

.PHONY: plugin-configure plugin-build plugin-cross-win help

plugin-configure:
	cmake --preset $(CMAKE_PRESET)

plugin-build: plugin-configure
	cmake --build --preset $(CMAKE_PRESET)

plugin-cross-win:
	@if [ "$(UNAME_S)" != "Linux" ]; then \
		echo "Error: Cross-compilation requires Linux"; \
		exit 1; \
	fi
	./ci/fetch-obs-sdk.sh windows
	OBS_VERSION=$$(jq -r '.dependencies["obs-studio"].version' buildspec.json) && \
	cmake --preset linux-cross-windows-x64 \
		-DOBS_SOURCE_DIR="$${PWD}/.deps/windows-x64/obs-studio-$${OBS_VERSION}"
	cmake --build --preset linux-cross-windows-x64

help:
	@echo "OBS Plugin Build Targets:"
	@echo "  plugin-configure  - Configure for current platform ($(CMAKE_PRESET))"
	@echo "  plugin-build      - Build plugin"
	@echo "  plugin-cross-win  - Cross-compile for Windows (Linux only)"
```
