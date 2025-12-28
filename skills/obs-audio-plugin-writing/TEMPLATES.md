# OBS Audio Plugin Templates

Ready-to-use templates for OBS audio plugin development.

## Table of Contents

1. [Audio Filter Template](#audio-filter-template)
2. [Audio Source Template](#audio-source-template)
3. [CMakeLists.txt Template](#cmakeliststxt-template)
4. [buildspec.json Template](#buildspecjson-template)
5. [plugin-main.c Template](#plugin-mainc-template)
6. [Locale Template](#locale-template)

---

## Audio Filter Template

Complete audio filter based on gain-filter.c.

```c
/*
 * my-audio-filter.c
 * OBS Audio Filter Plugin
 */

#include <obs-module.h>
#include <media-io/audio-math.h>
#include <math.h>

/* Logging macros */
#define do_log(level, format, ...) \
    blog(level, "[my-filter: '%s'] " format, \
         obs_source_get_name(ctx->context), ##__VA_ARGS__)

#define warn(format, ...) do_log(LOG_WARNING, format, ##__VA_ARGS__)
#define info(format, ...) do_log(LOG_INFO, format, ##__VA_ARGS__)

/* Settings keys */
#define S_GAIN_DB "gain_db"
#define S_ENABLED "enabled"

/* Localized text */
#define TEXT_GAIN    obs_module_text("Gain")
#define TEXT_ENABLED obs_module_text("Enabled")

/*
 * Context structure - stores per-instance state
 */
struct filter_data {
    obs_source_t *context;    /* Reference to this filter */
    size_t channels;          /* Number of audio channels */
    float gain;               /* Linear gain multiplier */
    bool enabled;             /* Filter enabled state */
};

/*
 * get_name - Return the display name of this filter
 */
static const char *filter_name(void *unused)
{
    UNUSED_PARAMETER(unused);
    return obs_module_text("MyAudioFilter");
}

/*
 * destroy - Clean up resources when filter is removed
 */
static void filter_destroy(void *data)
{
    struct filter_data *ctx = data;
    info("Filter destroyed");
    bfree(ctx);
}

/*
 * update - Apply settings changes (called on main thread)
 */
static void filter_update(void *data, obs_data_t *settings)
{
    struct filter_data *ctx = data;

    /* Get settings values */
    double db = obs_data_get_double(settings, S_GAIN_DB);
    ctx->enabled = obs_data_get_bool(settings, S_ENABLED);

    /* Convert dB to linear multiplier */
    ctx->gain = db_to_mul((float)db);

    /* Get current channel count */
    ctx->channels = audio_output_get_channels(obs_get_audio());

    info("Updated: gain=%.1f dB (%.3f), enabled=%s",
         db, ctx->gain, ctx->enabled ? "true" : "false");
}

/*
 * create - Initialize filter instance
 */
static void *filter_create(obs_data_t *settings, obs_source_t *filter)
{
    struct filter_data *ctx = bzalloc(sizeof(*ctx));
    ctx->context = filter;

    /* Apply initial settings */
    filter_update(ctx, settings);

    info("Filter created");
    return ctx;
}

/*
 * filter_audio - Process audio data (called on audio thread)
 *
 * CRITICAL: This runs on the audio thread!
 * - Never block (no mutexes, no I/O)
 * - Never allocate memory
 * - Check for NULL channels
 * - Use audio->frames for loop bounds
 */
static struct obs_audio_data *filter_audio(void *data,
                                           struct obs_audio_data *audio)
{
    struct filter_data *ctx = data;

    /* Skip processing if disabled */
    if (!ctx->enabled)
        return audio;

    /* Get audio data as float array */
    float **adata = (float **)audio->data;
    const float gain = ctx->gain;

    /* Process each channel */
    for (size_t c = 0; c < ctx->channels; c++) {
        /* CRITICAL: Check channel exists before accessing */
        if (!audio->data[c])
            continue;

        /* Apply gain to each sample */
        for (size_t i = 0; i < audio->frames; i++) {
            adata[c][i] *= gain;
        }
    }

    return audio;
}

/*
 * get_defaults - Set default values for settings
 */
static void filter_defaults(obs_data_t *settings)
{
    obs_data_set_default_double(settings, S_GAIN_DB, 0.0);
    obs_data_set_default_bool(settings, S_ENABLED, true);
}

/*
 * get_properties - Define UI elements for settings
 */
static obs_properties_t *filter_properties(void *data)
{
    UNUSED_PARAMETER(data);

    obs_properties_t *props = obs_properties_create();

    /* Gain slider with dB suffix */
    obs_property_t *gain = obs_properties_add_float_slider(
        props, S_GAIN_DB, TEXT_GAIN, -30.0, 30.0, 0.1);
    obs_property_float_set_suffix(gain, " dB");

    /* Enable checkbox */
    obs_properties_add_bool(props, S_ENABLED, TEXT_ENABLED);

    return props;
}

/*
 * obs_source_info - Filter registration structure
 */
struct obs_source_info my_audio_filter = {
    .id = "my_audio_filter",
    .type = OBS_SOURCE_TYPE_FILTER,
    .output_flags = OBS_SOURCE_AUDIO,
    .get_name = filter_name,
    .create = filter_create,
    .destroy = filter_destroy,
    .update = filter_update,
    .filter_audio = filter_audio,
    .get_defaults = filter_defaults,
    .get_properties = filter_properties,
};
```

---

## Audio Source Template

Audio source that generates/captures audio based on test-sinewave.c.

```c
/*
 * my-audio-source.c
 * OBS Audio Source Plugin (Tone Generator Example)
 */

#include <obs-module.h>
#include <util/bmem.h>
#include <util/threading.h>
#include <util/platform.h>
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define S_FREQUENCY "frequency"
#define S_VOLUME    "volume"

/*
 * Context structure
 */
struct source_data {
    obs_source_t *source;

    /* Thread management */
    pthread_t thread;
    os_event_t *event;
    bool thread_active;

    /* Audio parameters */
    double frequency;
    float volume;
    double phase;
    uint64_t timestamp;
};

/*
 * Audio generation thread
 */
static void *audio_thread(void *data)
{
    struct source_data *ctx = data;
    uint64_t interval = 10000000ULL;  /* 10ms in nanoseconds */
    uint64_t last_time = os_gettime_ns();

    float buffer[480];  /* 10ms at 48kHz */

    while (os_event_try(ctx->event) == EAGAIN) {
        /* Sleep until next audio frame */
        if (!os_sleepto_ns(last_time += interval))
            last_time = os_gettime_ns();

        /* Generate sine wave */
        double phase_inc = ctx->frequency * 2.0 * M_PI / 48000.0;
        for (size_t i = 0; i < 480; i++) {
            buffer[i] = (float)(sin(ctx->phase) * ctx->volume);
            ctx->phase += phase_inc;
            if (ctx->phase > 2.0 * M_PI)
                ctx->phase -= 2.0 * M_PI;
        }

        /* Push audio to OBS */
        struct obs_source_audio audio = {
            .data[0] = (uint8_t *)buffer,
            .frames = 480,
            .speakers = SPEAKERS_MONO,
            .samples_per_sec = 48000,
            .timestamp = ctx->timestamp,
            .format = AUDIO_FORMAT_FLOAT_PLANAR,
        };

        obs_source_output_audio(ctx->source, &audio);
        ctx->timestamp += interval;
    }

    return NULL;
}

/*
 * Callbacks
 */
static const char *source_name(void *unused)
{
    UNUSED_PARAMETER(unused);
    return obs_module_text("ToneGenerator");
}

static void source_destroy(void *data)
{
    struct source_data *ctx = data;

    if (ctx->thread_active) {
        os_event_signal(ctx->event);
        pthread_join(ctx->thread, NULL);
    }

    os_event_destroy(ctx->event);
    bfree(ctx);
}

static void source_update(void *data, obs_data_t *settings)
{
    struct source_data *ctx = data;
    ctx->frequency = obs_data_get_double(settings, S_FREQUENCY);
    ctx->volume = (float)obs_data_get_double(settings, S_VOLUME);
}

static void *source_create(obs_data_t *settings, obs_source_t *source)
{
    struct source_data *ctx = bzalloc(sizeof(*ctx));
    ctx->source = source;

    /* Initialize event for thread control */
    if (os_event_init(&ctx->event, OS_EVENT_TYPE_MANUAL) != 0) {
        bfree(ctx);
        return NULL;
    }

    /* Apply settings */
    source_update(ctx, settings);

    /* Start audio thread */
    if (pthread_create(&ctx->thread, NULL, audio_thread, ctx) != 0) {
        os_event_destroy(ctx->event);
        bfree(ctx);
        return NULL;
    }

    ctx->thread_active = true;
    return ctx;
}

static void source_defaults(obs_data_t *settings)
{
    obs_data_set_default_double(settings, S_FREQUENCY, 440.0);
    obs_data_set_default_double(settings, S_VOLUME, 0.5);
}

static obs_properties_t *source_properties(void *data)
{
    UNUSED_PARAMETER(data);

    obs_properties_t *props = obs_properties_create();

    obs_property_t *freq = obs_properties_add_float_slider(
        props, S_FREQUENCY, "Frequency", 20.0, 20000.0, 1.0);
    obs_property_float_set_suffix(freq, " Hz");

    obs_properties_add_float_slider(
        props, S_VOLUME, "Volume", 0.0, 1.0, 0.01);

    return props;
}

/*
 * Registration structure
 */
struct obs_source_info my_audio_source = {
    .id = "my_audio_source",
    .type = OBS_SOURCE_TYPE_INPUT,
    .output_flags = OBS_SOURCE_AUDIO,
    .get_name = source_name,
    .create = source_create,
    .destroy = source_destroy,
    .update = source_update,
    .get_defaults = source_defaults,
    .get_properties = source_properties,
};
```

---

## CMakeLists.txt Template

```cmake
cmake_minimum_required(VERSION 3.28...3.30)

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/common/bootstrap.cmake" NO_POLICY_SCOPE)

project(${_name} VERSION ${_version})

# Optional: Enable frontend API for UI functionality
option(ENABLE_FRONTEND_API "Use obs-frontend-api for UI functionality" OFF)

# Optional: Enable Qt for custom widgets
option(ENABLE_QT "Use Qt functionality" OFF)

include(compilerconfig)
include(defaults)
include(helpers)

# Create the plugin module
add_library(${CMAKE_PROJECT_NAME} MODULE)

# Find and link libobs
find_package(libobs REQUIRED)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE OBS::libobs)

# Optional: Frontend API
if(ENABLE_FRONTEND_API)
  find_package(obs-frontend-api REQUIRED)
  target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE OBS::obs-frontend-api)
endif()

# Optional: Qt support
if(ENABLE_QT)
  find_package(Qt6 COMPONENTS Widgets Core)
  target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE Qt6::Core Qt6::Widgets)
  set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
    AUTOMOC ON AUTOUIC ON AUTORCC ON)
endif()

# Add source files
target_sources(${CMAKE_PROJECT_NAME} PRIVATE
  src/plugin-main.c
  src/my-audio-filter.c
  # Add more source files here
)

# Set output properties
set_target_properties_plugin(${CMAKE_PROJECT_NAME} PROPERTIES OUTPUT_NAME ${_name})
```

---

## buildspec.json Template

```json
{
  "name": "my-audio-plugin",
  "displayName": "My Audio Plugin",
  "version": "1.0.0",
  "author": "Your Name",
  "website": "https://github.com/username/my-audio-plugin",
  "email": "you@example.com",
  "uuids": {
    "macosBundleId": "com.example.my-audio-plugin"
  },
  "dependencies": {
    "obs-studio": {
      "version": "30.0.0",
      "repository": "https://github.com/obsproject/obs-studio",
      "branch": "release/30.0",
      "hash": "sha256-checksum-here"
    }
  },
  "platformConfig": {
    "macos": {
      "bundleId": "com.example.my-audio-plugin",
      "codesign": false
    },
    "windows": {
      "signtool": false
    },
    "linux": {}
  }
}
```

---

## plugin-main.c Template

```c
/*
 * plugin-main.c
 * OBS Plugin Entry Point
 */

#include <obs-module.h>
#include <plugin-support.h>

/* Required: Exports common module functions */
OBS_DECLARE_MODULE()

/* Optional: Load locale from data/locale/ */
OBS_MODULE_USE_DEFAULT_LOCALE(PLUGIN_NAME, "en-US")

/* Declare external source info structures */
extern struct obs_source_info my_audio_filter;
extern struct obs_source_info my_audio_source;

/*
 * obs_module_load - Called when plugin is loaded
 *
 * Register all sources, outputs, encoders, and services here.
 * Return true on success, false to abort loading.
 */
bool obs_module_load(void)
{
    obs_log(LOG_INFO, "Plugin loaded (version %s)", PLUGIN_VERSION);

    /* Register audio filter */
    obs_register_source(&my_audio_filter);

    /* Register audio source */
    obs_register_source(&my_audio_source);

    return true;
}

/*
 * obs_module_unload - Called when plugin is unloaded
 *
 * Clean up any global resources here.
 */
void obs_module_unload(void)
{
    obs_log(LOG_INFO, "Plugin unloaded");
}

/*
 * Optional: obs_module_post_load
 * Called after all modules have loaded.
 */
// void obs_module_post_load(void)
// {
//     obs_log(LOG_INFO, "Post-load initialization");
// }
```

---

## Locale Template

`data/locale/en-US.ini`:

```ini
MyAudioFilter="My Audio Filter"
ToneGenerator="Tone Generator"
Gain="Gain"
Enabled="Enabled"
Frequency="Frequency"
Volume="Volume"
```

---

## Project Structure

```
my-audio-plugin/
├── CMakeLists.txt
├── buildspec.json
├── cmake/
│   └── common/
│       └── bootstrap.cmake    (from obs-plugintemplate)
├── src/
│   ├── plugin-main.c
│   ├── plugin-support.h       (from obs-plugintemplate)
│   ├── my-audio-filter.c
│   └── my-audio-source.c
└── data/
    └── locale/
        └── en-US.ini
```

---

## Quick Start

```bash
# Clone obs-plugintemplate
git clone https://github.com/obsproject/obs-plugintemplate my-audio-plugin
cd my-audio-plugin

# Edit buildspec.json with your info
# Replace src/plugin-main.c with template above
# Add your filter/source .c files to src/

# Configure
cmake -B build -S .

# Build
cmake --build build

# The plugin will be in build/
```
