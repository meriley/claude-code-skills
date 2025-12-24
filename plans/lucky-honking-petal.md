# Plan: Sentiment MCP Tool + Instagram DOM Fix

## Overview

Two tasks:
1. **Add `get_sentiment` MCP tool** - Wire up existing SentimentAnalyzer to MCP
2. **Fix Instagram userscript DOM scraping** - Stop capturing feed/UI content

---

## Task 1: Add `get_sentiment` MCP Tool

### Current State
- `SentimentAnalyzer` class exists at `src/conversation_intelligence/analytics/sentiment.py`
- Supports EN/RU word lists + emoji detection
- Has `analyze()`, `analyze_batch()`, `get_distribution()`, `get_average_score()`
- Unit tests exist and pass
- **NOT wired to MCP or API**

### Implementation

**File: `src/conversation_intelligence/mcp/__main__.py`**

Add decorator-based tool (simplest approach, matches existing `get_stats`):

```python
@mcp.tool()
def get_sentiment(
    query: str,
    date_from: str | None = None,
    date_to: str | None = None,
    platform: str | None = None,
    sender: str | None = None,
    limit: int = 100,
) -> dict[str, Any]:
    """Analyze sentiment of messages matching a query.

    Returns sentiment distribution (positive/negative/neutral),
    average score (-1 to 1), and per-message breakdown.
    """
    from conversation_intelligence.analytics.sentiment import SentimentAnalyzer

    # Search for relevant messages
    results = search_service.search(
        query=query,
        limit=limit,
        platform=platform,
        sender=sender,
        start_time=parse_date(date_from),
        end_time=parse_date(date_to),
    )

    # Analyze sentiment
    analyzer = SentimentAnalyzer()
    texts = [r["payload"].get("text_preview", "") for r in results]
    sentiment_results = analyzer.analyze_batch(texts)

    return {
        "query": query,
        "message_count": len(sentiment_results),
        "average_score": analyzer.get_average_score(sentiment_results),
        "distribution": analyzer.get_distribution(sentiment_results),
        "messages": [
            {
                "text": r.text[:100],
                "label": r.label.value,
                "score": r.score,
                "confidence": r.confidence,
            }
            for r in sentiment_results[:10]  # Top 10 examples
        ],
    }
```

### Files to Modify
| File | Change |
|------|--------|
| `src/conversation_intelligence/mcp/__main__.py` | Add `get_sentiment` tool |

---

## Task 2: Fix Instagram DOM Scraping

### Problem Analysis (from `docs/chat-examples/Instagram/dom/instagram.html`)

The DOM sample reveals the actual Instagram DM structure:

**Key Discovery: Message Grid Container**
```html
<div aria-label="Messages in conversation with daria"
     role="grid"
     class="x1gp6l83 ...">
    <div role="row"><!-- message row --></div>
    <div role="row"><!-- message row --></div>
</div>
```

**The Root Cause:**
- `[role="row"]` exists in BOTH:
  1. The DM message grid (correct - these ARE messages)
  2. The thread list sidebar (wrong - these are conversation previews)
- Current userscript captures ALL `[role="row"]` elements without checking ancestry

**DOM Structure from Sample:**
- **Messages page title**: `<title>Instagram • Messages</title>`
- **Thread list**: `<div aria-label="Thread list" role="navigation">`
- **Message grid**: `<div aria-label="Messages in conversation with {username}" role="grid">`
- **Message rows**: `<div role="row">` (ONLY inside the grid are actual messages)

### Solution

**File: `userscripts/instagram.user.js`**

#### Fix 1: Use Precise Message Grid Selector (PRIMARY FIX)

The key selector is: `[role="grid"][aria-label^="Messages in conversation"]`

```javascript
// In MESSAGE_SELECTORS (line ~827-831):
const MESSAGE_SELECTORS = [
    '[data-testid="message-container"]',
    // CHANGED: Only match rows INSIDE the message grid
    '[role="grid"][aria-label^="Messages in conversation"] [role="row"]',
    // Remove the broad selector:
    // '[role="row"]',  // TOO BROAD - matches thread list items too
];

// In extractMessageFromElement (line ~864):
function extractMessageFromElement(el) {
    // MUST be inside message conversation grid, not thread list
    const messageGrid = el.closest('[role="grid"][aria-label^="Messages in conversation"]');
    if (!messageGrid) {
        return null; // Not in a DM conversation, skip
    }
    // ... rest of extraction
}

// In observer setup (line ~1020):
// Only observe the message grid, not the entire page
const container = document.querySelector('[role="grid"][aria-label^="Messages in conversation"]');
if (!container) {
    log('debug', 'No message grid found - not in DM thread view');
    return;
}
```

#### Fix 2: Add Missing UI Text Filters (line ~834-856)

```javascript
const UI_TEXT_PATTERNS = [
    // ... existing patterns ...

    // Like/engagement counts (from user report)
    /^\d{1,3}(,\d{3})*\s*likes?$/i,  // "59 likes", "2,951 likes"
    /^\d+\s*reactions?$/i,
    /^\d+\s*comments?$/i,
    /^\d+\s*views?$/i,
    /^liked by .+$/i,

    // UI elements
    /^view transcription$/i,
    /^attachment$/i,
    /^messages$/i,
    /^instagram$/i,
    /^your note$/i,  // From DOM: user note section
    /^ready for/i,   // From DOM: status text
];
```

#### Fix 3: Better Sender Extraction (line ~896-932)

Use the conversation partner from the grid's aria-label:

```javascript
function getSenderFromGrid(el) {
    const grid = el.closest('[role="grid"][aria-label^="Messages in conversation"]');
    if (grid) {
        // Extract username: "Messages in conversation with daria"
        const match = grid.getAttribute('aria-label')?.match(/with\s+(.+)$/i);
        if (match) return match[1].trim();
    }
    return null;
}
```

#### Fix 4: Path Validation (line ~1000)

```javascript
// Only activate DOM observer on DM thread pages
const DM_THREAD_PATH = /^\/direct\/t\/\d+/;
if (!DM_THREAD_PATH.test(window.location.pathname)) {
    log('debug', 'Not in DM thread view');
    return;
}
```

### Files to Modify
| File | Change |
|------|--------|
| `userscripts/instagram.user.js` | Update selectors to use `[role="grid"][aria-label^="Messages in conversation"]`, add UI filters |

---

## Testing

### Task 1: Sentiment Tool
```bash
# Test via MCP server
uv run python -c "
from conversation_intelligence.mcp.__main__ import get_sentiment
result = get_sentiment('how are you', limit=10)
print(result)
"
```

### Task 2: Instagram Fix
1. Install updated userscript in browser
2. Navigate to Instagram DM conversation (e.g., `/direct/t/12345`)
3. Check browser console:
   - Should see: `DOM debug: X [role=row]` (only message rows)
   - Should NOT see: like counts, "Messages", "Your note" as captured content
4. Verify sync payload to API only contains actual messages

**Validation Checklist:**
- [ ] `[role="row"]` outside message grid ignored
- [ ] Thread list previews not captured
- [ ] Like counts filtered ("59 likes", "2,951 likes")
- [ ] UI text filtered ("View transcription", "Your note")
- [ ] Sender extracted from grid aria-label

---

## Priority

1. **Instagram DOM fix** - Higher priority (blocking data quality)
2. **Sentiment MCP tool** - Lower priority (feature addition)
