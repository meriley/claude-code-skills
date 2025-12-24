# Feature Enhancement Plan: Conversation Intelligence

## Current State Summary

The system has a solid foundation with:
- Semantic search working (Qwen3 embeddings)
- 3 MCP tools exposed: `search_conversations`, `get_context`, `get_summary`
- Parsers for Telegram, Instagram, OnlyFans
- Sentiment and topic analysis classes **implemented but NOT exposed**

---

## High-Value Features to Add

### Tier 1: Quick Wins (Already Implemented, Just Need Exposure)

| Feature | Status | Effort | Value |
|---------|--------|--------|-------|
| **Expose sentiment as MCP tool** | Class exists, not exposed | 1 hour | High |
| **Expose topic modeling as MCP tool** | Class exists, not exposed | 1 hour | High |
| **Add exact phrase search MCP tool** | Method exists in repo | 1 hour | High |
| **Add thread expansion MCP tool** | Method exists | 1 hour | Medium |
| **Add date range browsing** | Query exists | 1 hour | Medium |

### Tier 2: New Analytics Features

| Feature | Description | Effort | Value |
|---------|-------------|--------|-------|
| **Communication statistics** | Messages/day, response times, activity heatmaps | 4 hours | High |
| **Relationship dynamics** | Sentiment per sender-pair, who initiates | 6 hours | High |
| **Commitment tracking** | Extract "I'll do X by Y" patterns | 4 hours | Medium |
| **Conversation velocity** | How fast are replies, dormancy detection | 2 hours | Medium |

### Tier 3: Data Enrichment

| Feature | Description | Effort | Value |
|---------|-------------|--------|-------|
| **Instagram emoji reactions** | Extract from DOM (already available) | 2 hours | High |
| **Language detection** | Auto-detect per message | 2 hours | Medium |
| **Voice transcription integration** | Link transcriptions to messages | 3 hours | Medium |
| **Edit tracking** | Capture message edits/deletions | 4 hours | Low |

### Tier 4: Advanced Features

| Feature | Description | Effort | Value |
|---------|-------------|--------|-------|
| **Cross-platform linking** | Same conversation on multiple platforms | 8 hours | High |
| **Knowledge extraction** | What facts/skills discussed | 8 hours | Medium |
| **Influence networks** | Who drives topics, relationships | 6 hours | Medium |
| **Streamlit dashboard** | Visual analytics UI | 12 hours | High |

---

## Implementation Plan: Tier 3 Data Enrichment

User selected: **Tier 3: Data Enrichment** with goal of **comprehensive analytics**

---

### Feature 1: Instagram Emoji Reactions Extraction

**Current State:**
- Instagram DOM contains reactions in `<ul class="_a6-q">` elements
- Parser (`parsers/instagram_html.py`) does not extract them
- Message model has no `reactions` field

**Implementation:**
1. Add `reactions: list[dict] | None` to Message model
2. Update Instagram parser to extract reactions from DOM:
   ```python
   # DOM structure: <ul class="_a6-q"><li>😍 reactor_name</li></ul>
   reactions_ul = msg_div.find('ul', class_='_a6-q')
   if reactions_ul:
       reactions = [{'emoji': li.text[0], 'reactor': li.text[2:]} for li in reactions_ul.find_all('li')]
   ```
3. Add `reactions` to PostgreSQL schema (JSONB column)
4. Expose via MCP tool for reaction-based queries

**Files to modify:**
- `src/conversation_intelligence/models/message.py`
- `src/conversation_intelligence/parsers/instagram_html.py`
- `src/conversation_intelligence/storage/postgres.py`
- `src/conversation_intelligence/migrations/schema.py`

**Effort:** 2-3 hours

---

### Feature 2: Language Detection

**Current State:**
- Message model has `language: str | None` field (unused)
- No language detection library integrated

**Implementation:**
1. Add `langdetect` or `lingua-py` dependency
2. Create language detection utility:
   ```python
   from langdetect import detect, LangDetectException

   def detect_language(text: str) -> str | None:
       try:
           return detect(text) if len(text) > 10 else None
       except LangDetectException:
           return None
   ```
3. Populate `language` field during message parsing
4. Add language filter to search MCP tools
5. Enable language-specific analytics (sentiment by language)

**Files to modify:**
- `pyproject.toml` (add langdetect)
- `src/conversation_intelligence/utils/language.py` (new)
- All parsers to call `detect_language()`
- `src/conversation_intelligence/mcp/__main__.py` (add filter)

**Effort:** 2 hours

---

### Feature 3: Voice Transcription Integration

**Current State:**
- Userscript captures transcriptions from Instagram GraphQL
- Transcriptions stored as regular messages
- No link between voice message and its transcription

**Implementation:**
1. Add `transcription: str | None` field to Message model
2. Add `is_voice_message: bool` field
3. Update userscript to send transcription with voice message metadata:
   ```javascript
   {
     content: "[Voice message]",
     transcription: "actual transcription text",
     is_voice_message: true
   }
   ```
4. Update realtime API to handle transcription field
5. Include transcription in search indexing

**Files to modify:**
- `src/conversation_intelligence/models/message.py`
- `src/conversation_intelligence/api/routes/messages.py`
- `userscripts/instagram.user.js`
- `src/conversation_intelligence/storage/postgres.py`

**Effort:** 3 hours

---

### Feature 4: Communication Statistics MCP Tool

**New MCP tool:** `get_communication_stats`

**Returns:**
```python
{
    "total_messages": 5000,
    "by_platform": {"telegram": 3000, "instagram": 1500, "onlyfans": 500},
    "by_sender": {"Mark": 2500, "Dasha": 2500},
    "by_hour": {0: 50, 1: 30, ..., 23: 100},  # Activity by hour
    "by_day_of_week": {"Mon": 700, "Tue": 800, ...},
    "first_message": "2025-02-01T00:00:00Z",
    "last_message": "2025-12-23T00:00:00Z",
    "avg_messages_per_day": 15.5,
    "avg_response_time_minutes": {"Mark": 12.5, "Dasha": 8.2}
}
```

**Files to modify:**
- `src/conversation_intelligence/analytics/stats.py` (new)
- `src/conversation_intelligence/mcp/__main__.py`

**Effort:** 3 hours

---

## Implementation Order

1. **Instagram Emoji Reactions** (highest signal value)
2. **Communication Statistics Tool** (immediately useful)
3. **Language Detection** (enables better filtering)
4. **Voice Transcription Integration** (depends on userscript changes)

---

## Files Summary

| File | Changes |
|------|---------|
| `models/message.py` | Add reactions, transcription, is_voice_message, update language |
| `parsers/instagram_html.py` | Extract emoji reactions |
| `storage/postgres.py` | Add reactions column, update schema |
| `migrations/schema.py` | Add migration for new columns |
| `analytics/stats.py` | New file for communication statistics |
| `mcp/__main__.py` | Add get_communication_stats tool, language filter |
| `utils/language.py` | New language detection utility |
| `userscripts/instagram.user.js` | Send transcription with voice messages |
| `pyproject.toml` | Add langdetect dependency |

---

## Total Effort Estimate

- Instagram reactions: 2-3 hours
- Communication stats: 3 hours
- Language detection: 2 hours
- Voice transcription: 3 hours

**Total: ~10-11 hours of implementation**
