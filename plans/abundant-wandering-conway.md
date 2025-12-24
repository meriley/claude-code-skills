# Real-Time Message Capture System - PRD & Implementation Plan

**Task:** Userscript + API to capture Instagram/Telegram messages in real-time
**Status:** Planning
**Last Updated:** 2025-12-22

---

## Requirements Summary

| Requirement | Decision |
|-------------|----------|
| Platforms | Instagram + Telegram Web |
| Capture method | Intercept network requests (fetch/XHR/WebSocket) |
| Direction | Both sent and received messages |
| Offline mode | Queue in localStorage, sync when online |

---

## Architecture Overview

```
[Instagram/Telegram Web]
        |
        v
[Userscript] --intercept--> Network Requests
        |
        v
[localStorage Queue] --batch sync (5s)--> POST /messages
        |
        v
[FastAPI Endpoint]
        |
        v
[PostgreSQL] --async--> [Chunker] --> [Embeddings] --> [Qdrant]
```

---

## Phase 1: Server-Side API (2-3 hours)

### New Files
- `src/conversation_intelligence/api/routes/realtime.py`

### Request Schema
```python
class RealtimeMessage(BaseModel):
    platform: Literal["instagram", "telegram"]
    platform_message_id: str
    timestamp: datetime
    sender: str
    content: str | None
    direction: Literal["sent", "received"]
    reply_to_id: str | None = None
    has_media: bool = False
    media_type: str | None = None
    raw_json: dict | None = None

class RealtimeMessageBatch(BaseModel):
    messages: list[RealtimeMessage]  # max 100
    client_id: str
    sync_timestamp: datetime
```

### Response Schema
```python
class RealtimeMessageResponse(BaseModel):
    accepted: int
    duplicates: int
    message_ids: list[str]
```

### Endpoint: `POST /messages`
- Auth: API key header (`X-API-Key`)
- Validates, sanitizes, deduplicates via `(platform, platform_message_id)`
- Saves to PostgreSQL immediately
- Returns 200 with accepted/duplicate counts

### Files to Modify
- `src/conversation_intelligence/api/main.py` - Register router

---

## Phase 2: Background Embedding (1-2 hours)

### Strategy
- **Async embedding** - Messages stored immediately, vectors generated in background
- Trigger: Every 30 seconds OR every 50 new messages (whichever first)
- Uses existing: `Chunker`, `EmbeddingService`, `QdrantStorage`

### New File
- `src/conversation_intelligence/tasks/embedding_worker.py`

---

## Phase 3: Userscript Core (2-3 hours)

### File: `userscripts/chat-tracker-core.js`

```javascript
const ChatTrackerCore = {
    CONFIG: {
        API_URL: 'http://localhost:8000/messages',
        API_KEY: '',
        BATCH_SIZE: 10,
        SYNC_INTERVAL_MS: 5000,
        MAX_QUEUE_SIZE: 1000
    },

    // localStorage queue
    enqueue(message) { ... },
    dequeue(count) { ... },

    // Sync with retry
    sync() { ... },
    startSyncLoop() { ... },

    // Network
    sendBatch(messages) { ... }  // Uses GM_xmlhttpRequest
};
```

### localStorage Queue Schema
```json
{
    "queue": [
        {
            "id": "uuid",
            "platform": "instagram",
            "platform_message_id": "123",
            "timestamp": "ISO8601",
            "sender": "username",
            "content": "text",
            "direction": "received",
            "queued_at": "ISO8601",
            "retry_count": 0
        }
    ],
    "last_sync": "ISO8601"
}
```

### Offline Handling
- Queue persists in localStorage
- Exponential backoff: 1s → 5s → 30s → 60s
- Auto-sync on `online` event
- `sendBeacon` on page unload

---

## Phase 4: Platform Adapters (3-4 hours)

### File: `userscripts/instagram.user.js`

**Interception targets:**
- `fetch()` to `/api/graphql/` and `/api/v1/direct_v2/`
- `XMLHttpRequest` to same endpoints

**Message extraction:**
```javascript
// Instagram response: data.thread.items[] or data.items[]
{
    item_id: "123",
    timestamp: 1703123456000000,  // microseconds
    user_id: "456",
    text: "message",
    item_type: "text" | "media"
}
```

### File: `userscripts/telegram.user.js`

**Interception targets:**
- `fetch()` to telegram.org
- `WebSocket` messages (MTProto)

**Message extraction:**
```javascript
// Telegram response: messages[]
{
    id: 123,
    date: 1703123456,  // seconds
    from_id: { user_id: 456 },
    message: "text",
    out: true | false,
    media: { _: "messageMediaPhoto" }
}
```

---

## Phase 5: Integration Testing (1-2 hours)

- E2E: Userscript → API → PostgreSQL → Qdrant
- Offline queue persistence
- Duplicate handling
- Error recovery

---

## Critical Files Summary

### Create
| File | Purpose |
|------|---------|
| `src/conversation_intelligence/api/routes/realtime.py` | POST /messages endpoint |
| `src/conversation_intelligence/tasks/embedding_worker.py` | Background embedding |
| `userscripts/chat-tracker-core.js` | Shared userscript core |
| `userscripts/instagram.user.js` | Instagram adapter |
| `userscripts/telegram.user.js` | Telegram adapter |

### Modify
| File | Change |
|------|--------|
| `src/conversation_intelligence/api/main.py` | Register realtime router |

### Reference (no changes)
| File | Reuse |
|------|-------|
| `src/conversation_intelligence/storage/postgres.py` | MessageRepository.save_batch() |
| `src/conversation_intelligence/normalizer.py` | Timestamp/language normalization |
| `src/conversation_intelligence/security/sanitizer.py` | Input sanitization patterns |
| `src/conversation_intelligence/chunker.py` | Time-window chunking |
| `src/conversation_intelligence/embedding.py` | Ollama embedding service |

---

## Security Considerations

1. **API Key** - Required for all requests, stored in GM_setValue
2. **Input Sanitization** - Reuse existing `InputSanitizer`
3. **Content Limit** - Max 10KB per message
4. **Raw JSON Filtering** - Strip auth tokens from intercepted payloads

---

## Success Criteria

1. Messages captured within 5 seconds of appearing on platform
2. No message loss during offline periods (up to 1000 queued)
3. Deduplication works (re-opening chat doesn't create duplicates)
4. Semantic search available within 60 seconds of capture
5. Works with Tampermonkey/Greasemonkey/Violentmonkey
