# Plan: Switch to Qwen3-Embedding-0.6B

## Summary
Replace `mxbai-embed-large` with `qwen3-embedding:0.6b` for better multilingual performance (EN/RU).

**Key advantage: Same 1024 dimensions = NO REINDEXING NEEDED**

## Why Qwen3-Embedding-0.6B?
- **+4% better** on MTEB Multilingual (64.33 vs ~60 for mxbai)
- **Same 1024 dimensions** - existing vectors remain compatible
- **Lighter** (~1.5GB vs ~2-3GB VRAM)
- **Faster** inference (0.6B vs 8B)
- **100+ languages** with excellent RU/EN support
- **Apache 2.0 license**

## Changes Required

### 1. Configuration Updates
**Files:**
- `/home/mriley/projects/chat-tracker/docker-compose.yml` - line 11
- `/home/mriley/projects/chat-tracker/.env.example`

**Change:**
```yaml
EMBEDDING_MODEL=mxbai-embed-large  →  EMBEDDING_MODEL=qwen3-embedding:0.6b
```

### 2. Increase Chunk Size (leverage 32K context)
**File:** `/home/mriley/projects/chat-tracker/src/conversation_intelligence/tasks/embedding_worker.py`

**Current:** `MAX_TEXT_LENGTH = 512` (chars)
**New:** `MAX_TEXT_LENGTH = 8000` (chars, ~2K tokens - conservative for 32K limit)

This allows ~16x more conversation context per chunk!

### 3. Pull New Model
```bash
ollama pull qwen3-embedding:0.6b
```

**No dimension change needed - vectors stay 1024-dim.**

## Execution Order
1. Pull the new model: `ollama pull qwen3-embedding:0.6b`
2. Update docker-compose.yml and .env.example
3. Update MAX_TEXT_LENGTH in embedding_worker.py (512 → 8000)
4. Restart services
5. **Full wipe and reindex:**
   ```sql
   -- Clear old chunks from Postgres
   TRUNCATE chunks;
   ```
   ```bash
   # Reindex (recreates Qdrant collection by default)
   uv run python -m src.cli reindex
   ```
6. Test embedding and search

## What Gets Wiped
- Qdrant `conversation_chunks` collection (recreated fresh)
- Postgres `chunks` table (truncated, re-populated)
- **Messages stay intact** - only embeddings regenerated

## Risks
- **Reindex time**: Depends on message count (may take minutes)
- **Temporary search unavailable**: During reindex

## Rollback
Revert config and MAX_TEXT_LENGTH:
```bash
EMBEDDING_MODEL=mxbai-embed-large
MAX_TEXT_LENGTH = 512
```
