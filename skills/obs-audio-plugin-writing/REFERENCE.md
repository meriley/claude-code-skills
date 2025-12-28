# OBS Audio Plugin API Reference

Complete API reference for OBS audio plugin development.

## Table of Contents

1. [obs_source_info Structure](#obs_source_info-structure)
2. [Audio Callbacks](#audio-callbacks)
3. [Settings API (obs_data_t)](#settings-api-obs_data_t)
4. [Properties API (obs_properties_t)](#properties-api-obs_properties_t)
5. [Audio Data Types](#audio-data-types)
6. [Audio Math Functions](#audio-math-functions)
7. [Utility Functions](#utility-functions)

---

## obs_source_info Structure

The core structure defining an audio source or filter.

```c
struct obs_source_info {
    /* Required fields */
    const char *id;                      /* Unique identifier string */
    enum obs_source_type type;           /* INPUT, FILTER, or TRANSITION */
    uint32_t output_flags;               /* OBS_SOURCE_AUDIO, etc. */

    /* Name callback (required) */
    const char *(*get_name)(void *type_data);

    /* Lifecycle callbacks */
    void *(*create)(obs_data_t *settings, obs_source_t *source);
    void (*destroy)(void *data);
    void (*update)(void *data, obs_data_t *settings);

    /* Audio processing (filters) */
    struct obs_audio_data *(*filter_audio)(void *data,
                                           struct obs_audio_data *audio);

    /* Settings and properties */
    void (*get_defaults)(obs_data_t *settings);
    obs_properties_t *(*get_properties)(void *data);

    /* Optional callbacks */
    void (*activate)(void *data);
    void (*deactivate)(void *data);
    void (*show)(void *data);
    void (*hide)(void *data);
    void (*save)(void *data, obs_data_t *settings);
    void (*load)(void *data, obs_data_t *settings);

    /* Type data (optional) */
    void *type_data;
    void (*free_type_data)(void *type_data);
};
```

### Source Types

| Type       | Constant                     | Description                  |
| ---------- | ---------------------------- | ---------------------------- |
| Input      | `OBS_SOURCE_TYPE_INPUT`      | Audio sources, generators    |
| Filter     | `OBS_SOURCE_TYPE_FILTER`     | Audio processing filters     |
| Transition | `OBS_SOURCE_TYPE_TRANSITION` | Not typically used for audio |

### Output Flags (Audio)

| Flag                            | Value   | Description             |
| ------------------------------- | ------- | ----------------------- |
| `OBS_SOURCE_AUDIO`              | (1<<0)  | Source outputs audio    |
| `OBS_SOURCE_DO_NOT_DUPLICATE`   | (1<<7)  | Prevent duplication     |
| `OBS_SOURCE_CONTROLLABLE_MEDIA` | (1<<14) | Media playback controls |

---

## Audio Callbacks

### filter_audio

The core callback for audio filters. Called on the audio thread.

```c
struct obs_audio_data *(*filter_audio)(void *data,
                                       struct obs_audio_data *audio);
```

**Parameters:**

- `data` - Your context structure pointer
- `audio` - Audio data to process

**Returns:**

- Same audio pointer (modified in place)
- NULL to output silence

**Thread:** Audio thread (non-blocking!)

**Example:**

```c
static struct obs_audio_data *filter_audio(void *data,
                                           struct obs_audio_data *audio)
{
    struct my_filter *ctx = data;
    float **adata = (float **)audio->data;

    for (size_t c = 0; c < ctx->channels; c++) {
        if (!audio->data[c])
            continue;

        for (size_t i = 0; i < audio->frames; i++) {
            adata[c][i] *= ctx->gain;
        }
    }

    return audio;
}
```

### create

Initialize your plugin's context data.

```c
void *(*create)(obs_data_t *settings, obs_source_t *source);
```

**Example:**

```c
static void *my_create(obs_data_t *settings, obs_source_t *source)
{
    struct my_filter *ctx = bzalloc(sizeof(*ctx));
    ctx->source = source;
    my_update(ctx, settings);
    return ctx;
}
```

### destroy

Clean up allocated resources.

```c
void (*destroy)(void *data);
```

**Example:**

```c
static void my_destroy(void *data)
{
    struct my_filter *ctx = data;
    /* Free any additional allocations */
    bfree(ctx->buffer);
    bfree(ctx);
}
```

### update

Apply settings changes. Called on main thread.

```c
void (*update)(void *data, obs_data_t *settings);
```

**Example:**

```c
static void my_update(void *data, obs_data_t *settings)
{
    struct my_filter *ctx = data;
    double db = obs_data_get_double(settings, "gain_db");
    ctx->gain = db_to_mul((float)db);
    ctx->channels = audio_output_get_channels(obs_get_audio());
}
```

### get_defaults

Set default values for settings.

```c
void (*get_defaults)(obs_data_t *settings);
```

**Example:**

```c
static void my_defaults(obs_data_t *settings)
{
    obs_data_set_default_double(settings, "gain_db", 0.0);
    obs_data_set_default_bool(settings, "enabled", true);
    obs_data_set_default_int(settings, "channel", -1);
}
```

### get_properties

Define UI properties for the settings dialog.

```c
obs_properties_t *(*get_properties)(void *data);
```

**Example:**

```c
static obs_properties_t *my_properties(void *data)
{
    UNUSED_PARAMETER(data);
    obs_properties_t *props = obs_properties_create();

    obs_properties_add_float_slider(props, "gain_db", "Gain (dB)",
                                    -30.0, 30.0, 0.1);
    obs_properties_add_bool(props, "enabled", "Enabled");

    return props;
}
```

---

## Settings API (obs_data_t)

JSON-like key-value storage for plugin settings.

### Getting Values

```c
/* String */
const char *obs_data_get_string(obs_data_t *data, const char *name);

/* Numbers */
long long obs_data_get_int(obs_data_t *data, const char *name);
double obs_data_get_double(obs_data_t *data, const char *name);

/* Boolean */
bool obs_data_get_bool(obs_data_t *data, const char *name);

/* Nested objects */
obs_data_t *obs_data_get_obj(obs_data_t *data, const char *name);
obs_data_array_t *obs_data_get_array(obs_data_t *data, const char *name);
```

### Setting Values

```c
void obs_data_set_string(obs_data_t *data, const char *name, const char *val);
void obs_data_set_int(obs_data_t *data, const char *name, long long val);
void obs_data_set_double(obs_data_t *data, const char *name, double val);
void obs_data_set_bool(obs_data_t *data, const char *name, bool val);
void obs_data_set_obj(obs_data_t *data, const char *name, obs_data_t *obj);
void obs_data_set_array(obs_data_t *data, const char *name, obs_data_array_t *arr);
```

### Setting Defaults

```c
void obs_data_set_default_string(obs_data_t *data, const char *name, const char *val);
void obs_data_set_default_int(obs_data_t *data, const char *name, long long val);
void obs_data_set_default_double(obs_data_t *data, const char *name, double val);
void obs_data_set_default_bool(obs_data_t *data, const char *name, bool val);
```

### Data Creation and Management

```c
obs_data_t *obs_data_create(void);
void obs_data_release(obs_data_t *data);
obs_data_t *obs_data_get_defaults(obs_data_t *data);
const char *obs_data_get_json(obs_data_t *data);
```

---

## Properties API (obs_properties_t)

Generate UI elements for plugin settings.

### Property Creation

```c
obs_properties_t *obs_properties_create(void);
void obs_properties_destroy(obs_properties_t *props);
```

### Numeric Properties

```c
/* Integer */
obs_property_t *obs_properties_add_int(obs_properties_t *props,
    const char *name, const char *desc, int min, int max, int step);

obs_property_t *obs_properties_add_int_slider(obs_properties_t *props,
    const char *name, const char *desc, int min, int max, int step);

/* Float */
obs_property_t *obs_properties_add_float(obs_properties_t *props,
    const char *name, const char *desc, double min, double max, double step);

obs_property_t *obs_properties_add_float_slider(obs_properties_t *props,
    const char *name, const char *desc, double min, double max, double step);
```

### Boolean Properties

```c
obs_property_t *obs_properties_add_bool(obs_properties_t *props,
    const char *name, const char *desc);
```

### Text Properties

```c
obs_property_t *obs_properties_add_text(obs_properties_t *props,
    const char *name, const char *desc, enum obs_text_type type);

/* Text types */
enum obs_text_type {
    OBS_TEXT_DEFAULT,
    OBS_TEXT_PASSWORD,
    OBS_TEXT_MULTILINE,
    OBS_TEXT_INFO,
};
```

### List/Combo Properties

```c
obs_property_t *obs_properties_add_list(obs_properties_t *props,
    const char *name, const char *desc,
    enum obs_combo_type type, enum obs_combo_format format);

/* Add items */
size_t obs_property_list_add_string(obs_property_t *p,
    const char *name, const char *val);
size_t obs_property_list_add_int(obs_property_t *p,
    const char *name, long long val);
size_t obs_property_list_add_float(obs_property_t *p,
    const char *name, double val);

/* Combo types */
enum obs_combo_type {
    OBS_COMBO_TYPE_INVALID,
    OBS_COMBO_TYPE_EDITABLE,
    OBS_COMBO_TYPE_LIST,
    OBS_COMBO_TYPE_RADIO,
};

/* Value formats */
enum obs_combo_format {
    OBS_COMBO_FORMAT_INVALID,
    OBS_COMBO_FORMAT_INT,
    OBS_COMBO_FORMAT_FLOAT,
    OBS_COMBO_FORMAT_STRING,
    OBS_COMBO_FORMAT_BOOL,
};
```

### Property Modifiers

```c
/* Set suffix (e.g., " dB", " Hz") */
void obs_property_float_set_suffix(obs_property_t *p, const char *suffix);
void obs_property_int_set_suffix(obs_property_t *p, const char *suffix);

/* Set limits */
void obs_property_int_set_limits(obs_property_t *p, int min, int max, int step);
void obs_property_float_set_limits(obs_property_t *p, double min, double max, double step);

/* Visibility */
void obs_property_set_visible(obs_property_t *p, bool visible);
void obs_property_set_enabled(obs_property_t *p, bool enabled);
```

### Button Properties

```c
obs_property_t *obs_properties_add_button(obs_properties_t *props,
    const char *name, const char *text, obs_property_clicked_t callback);

/* Callback signature */
typedef bool (*obs_property_clicked_t)(obs_properties_t *props,
    obs_property_t *property, void *data);
```

### Property Groups

```c
obs_property_t *obs_properties_add_group(obs_properties_t *props,
    const char *name, const char *desc, enum obs_group_type type,
    obs_properties_t *group_props);

enum obs_group_type {
    OBS_GROUP_NORMAL,
    OBS_GROUP_CHECKABLE,
};
```

---

## Audio Data Types

### obs_audio_data

Audio data passed to filter_audio callback.

```c
struct obs_audio_data {
    uint8_t *data[MAX_AV_PLANES];  /* Channel data pointers */
    uint32_t frames;               /* Number of audio frames */
    uint64_t timestamp;            /* Timestamp (nanoseconds) */
};
```

**Usage:**

```c
/* Cast to float for FLOAT_PLANAR format */
float **adata = (float **)audio->data;

/* Process each channel */
for (size_t c = 0; c < channels; c++) {
    if (!audio->data[c]) continue;

    for (size_t i = 0; i < audio->frames; i++) {
        adata[c][i] *= gain;
    }
}
```

### obs_source_audio

Audio data for pushing from sources.

```c
struct obs_source_audio {
    const uint8_t *data[MAX_AV_PLANES];  /* Channel data */
    uint32_t frames;                      /* Frame count */
    enum speaker_layout speakers;         /* Channel layout */
    enum audio_format format;             /* Sample format */
    uint32_t samples_per_sec;            /* Sample rate */
    uint64_t timestamp;                   /* Timestamp (ns) */
};
```

### Speaker Layouts

```c
enum speaker_layout {
    SPEAKERS_UNKNOWN,      /* Unknown layout */
    SPEAKERS_MONO,         /* 1 channel */
    SPEAKERS_STEREO,       /* 2 channels: L, R */
    SPEAKERS_2POINT1,      /* 3 channels: L, R, LFE */
    SPEAKERS_4POINT0,      /* 4 channels: L, R, C, S */
    SPEAKERS_4POINT1,      /* 5 channels: L, R, C, LFE, S */
    SPEAKERS_5POINT1,      /* 6 channels: L, R, C, LFE, SL, SR */
    SPEAKERS_7POINT1,      /* 8 channels: L, R, C, LFE, SL, SR, BL, BR */
};
```

### Audio Formats

```c
enum audio_format {
    AUDIO_FORMAT_UNKNOWN,
    AUDIO_FORMAT_U8BIT,           /* Unsigned 8-bit */
    AUDIO_FORMAT_16BIT,           /* Signed 16-bit */
    AUDIO_FORMAT_32BIT,           /* Signed 32-bit */
    AUDIO_FORMAT_FLOAT,           /* 32-bit float, interleaved */
    AUDIO_FORMAT_U8BIT_PLANAR,    /* Unsigned 8-bit, planar */
    AUDIO_FORMAT_16BIT_PLANAR,    /* Signed 16-bit, planar */
    AUDIO_FORMAT_32BIT_PLANAR,    /* Signed 32-bit, planar */
    AUDIO_FORMAT_FLOAT_PLANAR,    /* 32-bit float, planar (most common) */
};
```

---

## Audio Math Functions

From `<media-io/audio-math.h>`:

### db_to_mul

Convert decibels to linear multiplier.

```c
static inline float db_to_mul(float db)
{
    return powf(10.0f, db / 20.0f);
}
```

**Examples:**
| dB | Multiplier |
|----|------------|
| 0 | 1.0 |
| -6 | ~0.5 |
| -12 | ~0.25 |
| -20 | 0.1 |
| +6 | ~2.0 |

### mul_to_db

Convert linear multiplier to decibels.

```c
static inline float mul_to_db(float mul)
{
    return (mul > 0.0f) ? (20.0f * log10f(mul)) : -INFINITY;
}
```

---

## Utility Functions

### Memory Management

```c
/* Allocate zeroed memory */
void *bzalloc(size_t size);

/* Free memory */
void bfree(void *ptr);

/* Reallocate */
void *brealloc(void *ptr, size_t size);
```

### Logging

```c
/* Log levels */
void blog(int log_level, const char *format, ...);

#define LOG_ERROR   100
#define LOG_WARNING 200
#define LOG_INFO    300
#define LOG_DEBUG   400

/* Example */
blog(LOG_INFO, "Gain set to %.1f dB", gain_db);
```

### Audio System

```c
/* Get audio output handle */
audio_t *obs_get_audio(void);

/* Get channel count */
size_t audio_output_get_channels(audio_t *audio);

/* Get sample rate */
uint32_t audio_output_get_sample_rate(audio_t *audio);
```

### Source Functions

```c
/* Get source name */
const char *obs_source_get_name(obs_source_t *source);

/* Push audio from source */
void obs_source_output_audio(obs_source_t *source,
    const struct obs_source_audio *audio);

/* Get filter parent */
obs_source_t *obs_filter_get_parent(obs_source_t *filter);

/* Get filter target (next in chain) */
obs_source_t *obs_filter_get_target(obs_source_t *filter);
```

---

## Quick Reference

### Minimal Audio Filter

```c
#include <obs-module.h>
#include <media-io/audio-math.h>

OBS_DECLARE_MODULE()

struct gain_data { obs_source_t *ctx; float gain; size_t ch; };

static const char *name(void *u) { return "Gain"; }
static void destroy(void *d) { bfree(d); }
static void update(void *d, obs_data_t *s) {
    struct gain_data *g = d;
    g->gain = db_to_mul(obs_data_get_double(s, "db"));
    g->ch = audio_output_get_channels(obs_get_audio());
}
static void *create(obs_data_t *s, obs_source_t *src) {
    struct gain_data *g = bzalloc(sizeof(*g));
    g->ctx = src; update(g, s); return g;
}
static struct obs_audio_data *filter(void *d, struct obs_audio_data *a) {
    struct gain_data *g = d;
    for (size_t c = 0; c < g->ch; c++)
        if (a->data[c])
            for (size_t i = 0; i < a->frames; i++)
                ((float**)a->data)[c][i] *= g->gain;
    return a;
}
static void defaults(obs_data_t *s) { obs_data_set_default_double(s, "db", 0); }
static obs_properties_t *props(void *d) {
    obs_properties_t *p = obs_properties_create();
    obs_property_float_set_suffix(
        obs_properties_add_float_slider(p, "db", "Gain", -30, 30, 0.1), " dB");
    return p;
}

struct obs_source_info gain = {
    .id = "gain", .type = OBS_SOURCE_TYPE_FILTER, .output_flags = OBS_SOURCE_AUDIO,
    .get_name = name, .create = create, .destroy = destroy, .update = update,
    .filter_audio = filter, .get_defaults = defaults, .get_properties = props,
};

bool obs_module_load(void) { obs_register_source(&gain); return true; }
```
