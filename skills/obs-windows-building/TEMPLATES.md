# OBS Windows Building Templates

Ready-to-use templates for building OBS plugins on Windows.

## plugin.def (Complete OBS Exports)

```def
; plugin.def - DLL export definitions for OBS plugin
;
; REQUIRED: OBS loads plugins at runtime and looks up functions BY NAME.
; Without this file, functions may be exported by ordinal only (numbers),
; causing OBS to fail loading the plugin.
;
; Usage in CMakeLists.txt:
;   MSVC:  set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "/DEF:${CMAKE_CURRENT_SOURCE_DIR}/src/plugin.def")
;   MinGW: set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "${CMAKE_CURRENT_SOURCE_DIR}/src/plugin.def")

LIBRARY my-plugin
EXPORTS
    ; Required OBS module entry points (from OBS_DECLARE_MODULE)
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

## CMakeLists.txt Windows Section

```cmake
# Platform-specific configuration
if(WIN32 OR CROSS_COMPILE_WINDOWS)
    # Windows system libraries
    target_link_libraries(${PROJECT_NAME} PRIVATE
        ws2_32      # Windows Sockets 2
        comctl32    # Common Controls
    )

    # Windows defines
    target_compile_definitions(${PROJECT_NAME} PRIVATE
        UNICODE
        _UNICODE
        _CRT_SECURE_NO_WARNINGS
        WIN32_LEAN_AND_MEAN     # Exclude rarely-used Windows headers
    )

    # Platform-specific sources
    target_sources(${PROJECT_NAME} PRIVATE
        src/platform/socket-win32.c
    )

    # Export OBS module functions - different approach for MinGW vs MSVC
    if(CROSS_COMPILE_WINDOWS OR CMAKE_C_COMPILER_ID STREQUAL "GNU")
        # MinGW: Use .def file + ignore unresolved OBS symbols
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
    # Linux/macOS
    target_sources(${PROJECT_NAME} PRIVATE
        src/platform/socket-posix.c
    )
endif()
```

## Visual Studio CMake Preset

```json
{
  "name": "windows-x64",
  "displayName": "Windows x64",
  "description": "Build for Windows x64 with Visual Studio 2022",
  "binaryDir": "${sourceDir}/build_x64",
  "generator": "Visual Studio 17 2022",
  "architecture": "x64",
  "warnings": { "dev": true, "deprecated": true },
  "cacheVariables": {
    "CMAKE_C_STANDARD": "11",
    "CMAKE_CXX_STANDARD": "17",
    "OBS_SOURCE_DIR": "${sourceDir}/.deps/windows-x64/obs-studio-32.0.4"
  }
}
```

## socket-win32.c (Platform Implementation)

```c
/* socket-win32.c - Windows socket implementation
 *
 * Implements platform-independent socket interface for Windows.
 * Uses Winsock2 API.
 */

#include <winsock2.h>  /* MUST come before windows.h */
#include <ws2tcpip.h>
#include <windows.h>
#include <stdbool.h>
#include <stdint.h>

/* Socket context */
struct platform_socket {
    SOCKET sock;
    struct sockaddr_in addr;
};

static bool winsock_initialized = false;

/* Initialize Winsock - call once at plugin load */
int platform_socket_init(void)
{
    if (winsock_initialized)
        return 0;

    WSADATA wsa_data;
    int result = WSAStartup(MAKEWORD(2, 2), &wsa_data);
    if (result != 0) {
        /* WSAStartup failed */
        return -1;
    }

    winsock_initialized = true;
    return 0;
}

/* Cleanup Winsock - call at plugin unload */
void platform_socket_cleanup(void)
{
    if (winsock_initialized) {
        WSACleanup();
        winsock_initialized = false;
    }
}

/* Create UDP socket */
struct platform_socket *platform_socket_create(const char *host, uint16_t port)
{
    if (!winsock_initialized) {
        if (platform_socket_init() != 0)
            return NULL;
    }

    struct platform_socket *ctx = calloc(1, sizeof(*ctx));
    if (!ctx)
        return NULL;

    ctx->sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (ctx->sock == INVALID_SOCKET) {
        free(ctx);
        return NULL;
    }

    ctx->addr.sin_family = AF_INET;
    ctx->addr.sin_port = htons(port);
    inet_pton(AF_INET, host, &ctx->addr.sin_addr);

    return ctx;
}

/* Send data */
int platform_socket_send(struct platform_socket *ctx, const void *data, size_t len)
{
    if (!ctx || ctx->sock == INVALID_SOCKET)
        return -1;

    int result = sendto(ctx->sock, (const char *)data, (int)len, 0,
                        (struct sockaddr *)&ctx->addr, sizeof(ctx->addr));
    return (result == SOCKET_ERROR) ? -1 : result;
}

/* Destroy socket */
void platform_socket_destroy(struct platform_socket *ctx)
{
    if (!ctx)
        return;

    if (ctx->sock != INVALID_SOCKET) {
        closesocket(ctx->sock);
    }
    free(ctx);
}

/* Get last error as string */
const char *platform_socket_error(void)
{
    static char buf[256];
    int err = WSAGetLastError();

    FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                   NULL, err, 0, buf, sizeof(buf), NULL);
    return buf;
}
```

## socket-posix.c (For Comparison)

```c
/* socket-posix.c - POSIX socket implementation
 *
 * Implements platform-independent socket interface for Linux/macOS.
 */

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <stdbool.h>
#include <stdint.h>

struct platform_socket {
    int sock;
    struct sockaddr_in addr;
};

int platform_socket_init(void)
{
    /* No initialization needed on POSIX */
    return 0;
}

void platform_socket_cleanup(void)
{
    /* No cleanup needed on POSIX */
}

struct platform_socket *platform_socket_create(const char *host, uint16_t port)
{
    struct platform_socket *ctx = calloc(1, sizeof(*ctx));
    if (!ctx)
        return NULL;

    ctx->sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (ctx->sock < 0) {
        free(ctx);
        return NULL;
    }

    ctx->addr.sin_family = AF_INET;
    ctx->addr.sin_port = htons(port);
    inet_pton(AF_INET, host, &ctx->addr.sin_addr);

    return ctx;
}

int platform_socket_send(struct platform_socket *ctx, const void *data, size_t len)
{
    if (!ctx || ctx->sock < 0)
        return -1;

    ssize_t result = sendto(ctx->sock, data, len, 0,
                            (struct sockaddr *)&ctx->addr, sizeof(ctx->addr));
    return (result < 0) ? -1 : (int)result;
}

void platform_socket_destroy(struct platform_socket *ctx)
{
    if (!ctx)
        return;

    if (ctx->sock >= 0) {
        close(ctx->sock);
    }
    free(ctx);
}

const char *platform_socket_error(void)
{
    return strerror(errno);
}
```

## platform.h (Common Interface)

```c
/* platform.h - Platform abstraction header
 *
 * Include this header for cross-platform socket operations.
 * Implementation is in socket-win32.c or socket-posix.c.
 */

#pragma once

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Opaque socket context */
struct platform_socket;

/* Initialize platform (call in obs_module_load) */
int platform_socket_init(void);

/* Cleanup platform (call in obs_module_unload) */
void platform_socket_cleanup(void);

/* Create UDP socket to host:port */
struct platform_socket *platform_socket_create(const char *host, uint16_t port);

/* Send data, returns bytes sent or -1 on error */
int platform_socket_send(struct platform_socket *ctx, const void *data, size_t len);

/* Destroy socket */
void platform_socket_destroy(struct platform_socket *ctx);

/* Get last error message */
const char *platform_socket_error(void);

#ifdef __cplusplus
}
#endif
```

## Windows Resource File (.rc)

```rc
/* my-plugin.rc - Windows resource file
 *
 * Provides version info and metadata for the DLL.
 */

#include <windows.h>

#define VER_MAJOR 1
#define VER_MINOR 0
#define VER_PATCH 0
#define VER_STRING "1.0.0"

VS_VERSION_INFO VERSIONINFO
FILEVERSION     VER_MAJOR, VER_MINOR, VER_PATCH, 0
PRODUCTVERSION  VER_MAJOR, VER_MINOR, VER_PATCH, 0
FILEFLAGSMASK   VS_FFI_FILEFLAGSMASK
FILEFLAGS       0
FILEOS          VOS_NT_WINDOWS32
FILETYPE        VFT_DLL
FILESUBTYPE     VFT2_UNKNOWN
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "040904B0"  /* English (US), Unicode */
        BEGIN
            VALUE "CompanyName",      "Your Name\0"
            VALUE "FileDescription",  "My OBS Plugin\0"
            VALUE "FileVersion",      VER_STRING "\0"
            VALUE "InternalName",     "my-plugin\0"
            VALUE "LegalCopyright",   "Copyright (C) 2024\0"
            VALUE "OriginalFilename", "my-plugin.dll\0"
            VALUE "ProductName",      "My OBS Plugin\0"
            VALUE "ProductVersion",   VER_STRING "\0"
        END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x0409, 0x04B0  /* English (US), Unicode */
    END
END
```

## CMake Resource File Integration

```cmake
# Add Windows resource file
if(WIN32)
    # Configure version in resource file
    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/src/my-plugin.rc.in
        ${CMAKE_CURRENT_BINARY_DIR}/my-plugin.rc
        @ONLY
    )

    target_sources(${PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}/my-plugin.rc
    )
endif()
```

## Windows Settings Dialog (Win32 API)

```c
/* settings-dialog-win32.c - Native Windows settings dialog
 *
 * Fallback for when Qt is not available.
 * Uses Win32 common controls.
 */

#include <windows.h>
#include <commctrl.h>

#define ID_HOST_EDIT    101
#define ID_PORT_EDIT    102
#define ID_OK_BUTTON    103
#define ID_CANCEL_BUTTON 104

static HWND g_dialog = NULL;

static INT_PTR CALLBACK DialogProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    switch (msg) {
    case WM_INITDIALOG:
        /* Center dialog on screen */
        {
            RECT rc;
            GetWindowRect(hwnd, &rc);
            int x = (GetSystemMetrics(SM_CXSCREEN) - (rc.right - rc.left)) / 2;
            int y = (GetSystemMetrics(SM_CYSCREEN) - (rc.bottom - rc.top)) / 2;
            SetWindowPos(hwnd, NULL, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER);
        }
        return TRUE;

    case WM_COMMAND:
        switch (LOWORD(wParam)) {
        case ID_OK_BUTTON:
            /* Save settings */
            EndDialog(hwnd, IDOK);
            return TRUE;
        case ID_CANCEL_BUTTON:
            EndDialog(hwnd, IDCANCEL);
            return TRUE;
        }
        break;

    case WM_CLOSE:
        EndDialog(hwnd, IDCANCEL);
        return TRUE;
    }

    return FALSE;
}

void show_settings_dialog(void *parent)
{
    /* Create dialog from template or dynamically */
    /* This is a simplified example - real implementation would use DialogBoxIndirect */
    MessageBoxW((HWND)parent, L"Settings dialog not implemented", L"Settings", MB_OK);
}
```

## Build Script (Windows Batch)

```batch
@echo off
REM build-windows.bat - Build OBS plugin on Windows
REM
REM Usage: build-windows.bat [Debug|Release|RelWithDebInfo]

setlocal

set CONFIG=%1
if "%CONFIG%"=="" set CONFIG=RelWithDebInfo

echo === Building OBS Plugin for Windows ===
echo Configuration: %CONFIG%
echo.

REM Check for Visual Studio
where cl >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Visual Studio compiler not found.
    echo Run from "Developer Command Prompt for VS 2022"
    exit /b 1
)

REM Configure
echo Configuring...
cmake --preset windows-x64
if %ERRORLEVEL% neq 0 exit /b 1

REM Build
echo Building...
cmake --build --preset windows-x64 --config %CONFIG%
if %ERRORLEVEL% neq 0 exit /b 1

REM Verify DLL
echo.
echo === Verifying DLL ===
dumpbin /exports build_x64\%CONFIG%\my-plugin.dll | findstr "obs_module_load"
if %ERRORLEVEL% neq 0 (
    echo Warning: obs_module_load not found in exports!
)

echo.
echo === Build Complete ===
echo DLL: build_x64\%CONFIG%\my-plugin.dll

endlocal
```

## PowerShell Install Script

```powershell
# install-plugin.ps1 - Install OBS plugin to user directory
#
# Usage: .\install-plugin.ps1 [-Config Release]

param(
    [string]$Config = "RelWithDebInfo",
    [string]$PluginName = "my-plugin"
)

$ErrorActionPreference = "Stop"

$BuildDir = "build_x64\$Config"
$DllPath = "$BuildDir\$PluginName.dll"

if (-not (Test-Path $DllPath)) {
    Write-Error "DLL not found: $DllPath"
    Write-Error "Run build-windows.bat first"
    exit 1
}

$PluginDir = "$env:APPDATA\obs-studio\plugins\$PluginName"
$BinDir = "$PluginDir\bin\64bit"
$DataDir = "$PluginDir\data\locale"

Write-Host "Installing to: $PluginDir"

# Create directories
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
New-Item -ItemType Directory -Force -Path $DataDir | Out-Null

# Copy DLL
Copy-Item $DllPath -Destination $BinDir -Force

# Copy locale files
if (Test-Path "data\locale") {
    Copy-Item "data\locale\*" -Destination $DataDir -Force
}

Write-Host "Installation complete!"
Write-Host "Restart OBS to load the plugin."
```
