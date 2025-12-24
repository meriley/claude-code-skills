# Plan: Update PRD and TDD for Instagram HTML Format

## Summary

Instagram examples are now available. Update PRD and TDD to reflect actual Instagram HTML format:

| Platform | Previous Assumption | Actual Format |
|----------|-------------------|---------------|
| **Telegram** | JSON export | **HTML export** (DOM structure) ✅ Done |
| **Instagram** | JSON in messages/inbox/ | **HTML export** (Meta data download) - NEW |
| **OnlyFans** | Not documented | **JSON array** with HTML-wrapped content ✅ Done |

## Instagram HTML Format Analysis

**File:** `/docs/chat-examples/Instagram/message_1.html` (415KB)

### Structure:
```html
<div class="pam _3-95 _2ph- _a6-g uiBoxWhite noborder">
  <h2 class="_3-95 _2pim _a6-h _a6-i">Mark</h2>
  <div class="_3-95 _a6-p">
    <div><div></div><div>Message content with <br /> line breaks</div></div>
  </div>
  <div class="_3-94 _a6-o">Oct 30, 2025 3:34 pm</div>
</div>
```

### Key Elements:
- **Message container**: `div.pam._3-95._2ph-._a6-g.uiBoxWhite.noborder`
- **Sender name**: `h2._3-95._2pim._a6-h._a6-i`
- **Content**: `div._3-95._a6-p > div > div` (nested divs)
- **Timestamp**: `div._3-94._a6-o` (format: "Oct 30, 2025 3:34 pm")
- **Photos**: `<a href="..."><img src="..." class="_a6_o _3-96"/></a>`
- **Reactions**: `<ul class="_a6-q"><li><span>🫀daria</span></li></ul>`
- **Stickers**: Text "X sent a sticker."
- **Line breaks**: `<br />`
- **HTML entities**: `&#039;` for apostrophes

### Features:
- Cyrillic (Russian) text support
- Photos with relative paths to inbox folder
- Reaction emoji with reactor name
- (edited) marker for edited messages

## Files to Modify

1. `/home/mriley/projects/chat-tracker/docs/chat-tracker-prd.md`
2. `/home/mriley/projects/chat-tracker/docs/tdd-implementation.md`

---

## Part 1: PRD Updates

### 1.1 Section 2: Problem Statement
- Add "OnlyFans" to the platform list

### 1.2 Section 3: Goals
- Update: "Unified ingestion of Telegram (HTML export), Instagram (HTML export), and OnlyFans (JSON array)"

### 1.3 Section 4: Non-Goals
- Add: "Real-time synchronization with OnlyFans API (batch export only)"

### 1.4 Section 6: User Stories

#### Update US-011 (Telegram Import)
Change from JSON to HTML:
- Accepts Telegram Desktop **HTML export** (messages.html, messages2.html, etc.)
- Parses DOM structure: `div.message`, `div.from_name`, `div.text`, `div.date`
- Handles message types: `default`, `joined`, `service`
- Extracts reply chains via `div.reply_to` elements
- Processes media: photos, stickers (.tgs), video files
- Parses timestamps from title attribute format

#### Update US-012 (Instagram Import)
Change from JSON to HTML (Meta data download format):
- Accepts Instagram HTML export (message_1.html, message_2.html, etc.)
- Parses DOM structure: `div.pam._3-95._2ph-._a6-g.uiBoxWhite.noborder` message container
- Extracts sender from `h2._3-95._2pim._a6-h._a6-i`
- Extracts content from nested `div._3-95._a6-p > div > div` structure
- Parses timestamps from `div._3-94._a6-o` (format: "Oct 30, 2025 3:34 pm")
- Processes media: photos with relative paths (`<a href><img class="_a6_o _3-96"/></a>`)
- Handles reactions: `<ul class="_a6-q"><li><span>🫀reactor_name</span></li></ul>`
- Detects stickers: "X sent a sticker." text pattern
- Handles edited messages: "(edited)" marker
- Converts `<br />` to newlines, decodes HTML entities (`&#039;`)
- Supports Cyrillic (Russian) text

#### Add US-014 (OnlyFans Import) - NEW
- Accepts OnlyFans JSON array export format
- Parses fields: `id`, `user_id`, `text` (HTML-wrapped), `created_at`
- Strips HTML tags from text field (`<p>`, `<br>`, `<a>`)
- Preserves emoji content
- Maps `user_id` integers to participant names via configuration
- Handles timestamp format: "YYYY-MM-DD HH:MM:SS"

### 1.5 Section 9: Data Model

Update schema:
```sql
-- Add new columns
platform TEXT NOT NULL,  -- 'telegram', 'instagram', or 'onlyfans'
platform_message_id TEXT,
user_id BIGINT,  -- OnlyFans numeric user ID
content_html TEXT,  -- Original HTML content

-- Add Telegram metadata table
CREATE TABLE telegram_metadata (...)

-- Add OnlyFans users table
CREATE TABLE onlyfans_users (...)
```

### 1.6 Section 10: Implementation Phases

Update Phase 1:
1. **Telegram HTML parser** (DOM-based with BeautifulSoup4/lxml)
2. **Instagram HTML parser** (DOM-based, Meta data download format)
3. **OnlyFans JSON parser** (JSON array with HTML-wrapped content)

### 1.7 Section 11: Configuration

Update CLI examples:
```bash
# Telegram HTML export
uv run python -m src.cli ingest --platform telegram --dir ChatExport_2025-07-24/

# Instagram HTML export (Meta data download)
uv run python -m src.cli ingest --platform instagram --dir messages/inbox/username/

# OnlyFans JSON export
uv run python -m src.cli ingest --platform onlyfans --file messages.json \
    --user-map "459928872:Dasha,243807034:Mark"
```

### 1.8 Section 12: Risks

Add new risks:
- Telegram HTML format changes (Medium)
- Instagram HTML format changes - Meta uses obfuscated class names (Medium)
- HTML parsing complexity vs JSON (Medium)
- OnlyFans user_id mapping (Low)

---

## Part 2: TDD Updates

### 2.1 Section 4.2: Replace Telegram Parser Tests

**DELETE** all `TestTelegramParser` JSON-based tests

**ADD** `TestTelegramHTMLParser` with tests for:
- Parsing DOM structure (`div.message`, `div.from_name`, `div.text`)
- Extracting message ID from `id="message3207"` attribute
- Parsing timestamps from `title="DD.MM.YYYY HH:MM:SS UTC+offset"`
- Handling `joined` messages (inherit sender from previous)
- Handling `service` messages (date separators)
- Extracting reply references from `div.reply_to`
- Converting `<br>` to newlines, stripping HTML
- Extracting photo/sticker/video media
- Handling Russian (Cyrillic) text
- Parsing multiple HTML files (messages.html, messages2.html)

### 2.2 Section 4.3: Replace Instagram Parser Tests

**DELETE** all `TestInstagramParser` JSON-based tests

**ADD** `TestInstagramHTMLParser` with tests for:
- Parsing message container: `div.pam._3-95._2ph-._a6-g.uiBoxWhite.noborder`
- Extracting sender name from `h2._3-95._2pim._a6-h._a6-i`
- Extracting message content from nested `div._3-95._a6-p > div > div`
- Parsing human-readable timestamps: "Oct 30, 2025 3:34 pm" format
- Handling multiple messages in one HTML file
- Processing photos: `<a href><img class="_a6_o _3-96"/></a>`
- Extracting reactions: `<ul class="_a6-q"><li><span>🫀name</span></li></ul>`
- Detecting stickers: "X sent a sticker." pattern
- Handling edited messages: "(edited)" marker
- Converting `<br />` to newlines
- Decoding HTML entities: `&#039;` → `'`
- Handling Cyrillic (Russian) text
- Parsing multiple HTML files (message_1.html, message_2.html)
- Handling empty content divs
- Extracting relative photo paths

### 2.3 Add Section 4.4: OnlyFans Parser Tests (NEW)

Add `TestOnlyFansParser` with tests for:
- Parsing JSON array format
- Extracting `id`, `user_id`, `text`, `created_at`
- Stripping HTML tags (`<p>`, `<br>`) from text
- Preserving original HTML in `content_html` field
- Preserving emoji characters
- Extracting links from `<a>` tags
- Mapping `user_id` to sender names via config
- Handling unknown user_id (fallback to "user_N")
- Parsing "YYYY-MM-DD HH:MM:SS" timestamps
- Sorting messages by timestamp
- Handling empty text fields

### 2.4 Update Fixtures

```
tests/fixtures/
├── telegram_export.html         # HTML with div.message structure
├── telegram_export/             # Multi-file directory
│   ├── messages.html
│   ├── messages2.html
│   └── photos/
├── instagram_export.html        # HTML with Meta data download structure
├── instagram_export/            # Multi-file directory
│   ├── message_1.html
│   ├── message_2.html
│   └── photos/
└── onlyfans_export.json         # JSON array format
```

### 2.5 Add HTML Utility Tests

Add `TestHTMLParsingUtils`:
- `extract_text()` - strip tags, convert `<br>` to newlines
- `extract_links()` - extract href from `<a>` tags
- `decode_html_entities()` - `&#039;` → `'`
- `parse_telegram_timestamp()` - DD.MM.YYYY HH:MM:SS format
- `parse_instagram_timestamp()` - "Oct 30, 2025 3:34 pm" format
- `parse_onlyfans_timestamp()` - YYYY-MM-DD HH:MM:SS format

### 2.6 Update Test Execution Order

```bash
# 1. HTML utilities
uv run pytest tests/unit/test_html_utils.py -v

# 2. Models
uv run pytest tests/unit/test_models.py -v

# 3. Parsers (all platforms)
uv run pytest tests/unit/test_parsers.py::TestTelegramHTMLParser -v
uv run pytest tests/unit/test_parsers.py::TestInstagramHTMLParser -v
uv run pytest tests/unit/test_parsers.py::TestOnlyFansParser -v
```

---

## Implementation Order

1. **PRD Foundation** - Sections 2, 3, 4 (platform additions)
2. **PRD User Stories** - US-011, US-012, US-014
3. **PRD Technical** - Sections 9, 10, 11, 12
4. **TDD Parser Tests** - Replace 4.2, update 4.3, add 4.4
5. **TDD Infrastructure** - fixtures, utilities, execution order

---

## Reference Files

- `/docs/chat-examples/telegram/messages.html` - Actual Telegram HTML structure
- `/docs/chat-examples/Instagram/message_1.html` - Actual Instagram HTML structure (Meta data download)
- `/docs/chat-examples/onlyfans/sorted_reindexed_filez.json` - Actual OnlyFans format
- `/docs/chat-examples/onlyfans/CLAUDE.md` - User mapping context

## Files to Modify

1. `/home/mriley/projects/chat-tracker/docs/chat-tracker-prd.md`
   - Section 3: Update goals to include Instagram HTML
   - US-012: Replace TBD with Instagram HTML parser requirements
   - Section 10: Update implementation phases
   - Section 11: Add Instagram CLI example
   - Section 12: Update risks

2. `/home/mriley/projects/chat-tracker/docs/tdd-implementation.md`
   - Section 4.3: Replace Instagram JSON tests with HTML parser tests
   - Section 4.5 (or wherever): Update fixtures
   - Update test execution order
