# Plan: Rewrite r2-sync Service in Go

**Task:** Replace bash-based sync service with Go binary that includes both R2→Unraid sync AND HTTP file server for Cloudflare Tunnel downloads.

---

## Why Go Rewrite?

| Current (Bash) | New (Go) |
|----------------|----------|
| 3 containers (r2-sync + cloudflared + fileserver) | 2 containers (r2-sync-go + cloudflared) |
| Depends on rclone | Native AWS SDK (no external deps) |
| Config duplicated | Single config source |
| No HTTP capability | Built-in file server |
| Hard to test | Unit + integration testable |

---

## Package Structure

```
sync-service-go/
├── cmd/r2-sync/main.go           # Entry point
├── internal/
│   ├── config/config.go          # Environment variables
│   ├── database/
│   │   ├── database.go           # GORM connection
│   │   └── models.go             # Media, AuditLog (subset)
│   ├── fileserver/
│   │   ├── server.go             # HTTP setup
│   │   ├── handlers.go           # File download
│   │   └── jwt.go                # Token validation
│   ├── syncer/
│   │   ├── syncer.go             # Orchestration
│   │   ├── downloader.go         # R2 streaming download
│   │   ├── validator.go          # ffprobe
│   │   └── metadata.go           # JSON sidecars
│   ├── storage/r2.go             # AWS SDK S3 client
│   └── scheduler/scheduler.go    # Cron-like scheduling
├── Dockerfile
├── docker-compose.yml
└── go.mod
```

---

## Key Components

### 1. Config (backwards compatible with bash)

```go
type Config struct {
    // Database (same vars as bash)
    DBHost, DBPort, DBName, DBUser, DBPassword

    // R2 (same vars as bash)
    R2Endpoint, R2AccessKey, R2SecretKey, R2Bucket

    // Sync Settings
    BatchSize    int           // BATCH_SIZE (default: 10)
    SyncInterval time.Duration // SYNC_INTERVAL (default: 30m)
    ArchiveDir   string        // /media/archive

    // File Server (NEW)
    ServerPort   int    // 8080
    TunnelSecret string // UNRAID_TUNNEL_SECRET (shared with backend)
}
```

### 2. Sync Workflow (same as bash)

```
Query approved → Download from R2 → Validate (ffprobe) →
Move to archive → Create JSON sidecar → Update DB → Delete from R2
```

### 3. File Server (NEW)

| Endpoint | Purpose |
|----------|---------|
| `GET /*?token=jwt` | Download file with JWT auth |
| `GET /health` | Health check for tunnel |

JWT claims match backend's `TunnelDownloadClaims`:
```go
type TunnelDownloadClaims struct {
    MediaID uint `json:"media_id"`
    UserID  uint `json:"user_id"`
    jwt.RegisteredClaims
}
```

---

## HTTP Endpoints

| Path | Method | Auth | Purpose |
|------|--------|------|---------|
| `/health` | GET | None | Tunnel health check |
| `/health/deep` | GET | None | DB + R2 connectivity |
| `/*` | GET | JWT in `?token=` | File download |

---

## Dependencies

```go
require (
    github.com/aws/aws-sdk-go-v2          // R2 client
    github.com/go-chi/chi/v5              // HTTP router
    github.com/golang-jwt/jwt/v5          // JWT validation
    github.com/caarlos0/env/v10           // Config loading
    gorm.io/gorm                          // Database
    gorm.io/driver/postgres
)
```

Runtime: `alpine` + `ffmpeg` (for ffprobe)

---

## Files to Create

| File | Lines (est) | Purpose |
|------|-------------|---------|
| `cmd/r2-sync/main.go` | ~100 | Entry point, signal handling |
| `internal/config/config.go` | ~80 | Env var loading |
| `internal/database/database.go` | ~50 | GORM setup |
| `internal/database/models.go` | ~40 | Media, AuditLog |
| `internal/storage/r2.go` | ~80 | S3 client |
| `internal/syncer/syncer.go` | ~200 | Main sync logic |
| `internal/syncer/downloader.go` | ~60 | Streaming download |
| `internal/syncer/validator.go` | ~40 | ffprobe wrapper |
| `internal/syncer/metadata.go` | ~50 | JSON sidecar |
| `internal/fileserver/server.go` | ~60 | HTTP setup |
| `internal/fileserver/handlers.go` | ~80 | Download handler |
| `internal/fileserver/jwt.go` | ~40 | Token validation |
| `internal/scheduler/scheduler.go` | ~50 | Cron loop |
| `Dockerfile` | ~30 | Multi-stage build |
| `docker-compose.yml` | ~50 | Service config |
| `Makefile` | ~30 | Build commands |

**Total: ~1,040 lines**

---

## Implementation Order

### Phase 1: Core Infrastructure
1. `go.mod` + dependencies
2. `config/config.go` - environment loading
3. `database/` - GORM connection + models
4. `storage/r2.go` - S3 client

### Phase 2: Sync Logic
5. `syncer/downloader.go` - streaming download
6. `syncer/validator.go` - ffprobe
7. `syncer/metadata.go` - JSON sidecars
8. `syncer/syncer.go` - orchestration
9. `scheduler/scheduler.go` - cron loop

### Phase 3: File Server
10. `fileserver/jwt.go` - token validation
11. `fileserver/handlers.go` - download handler
12. `fileserver/server.go` - HTTP setup

### Phase 4: Entry Point + Docker
13. `cmd/r2-sync/main.go` - wire everything
14. `Dockerfile` - multi-stage build
15. `docker-compose.yml` - production config
16. `Makefile` - build/test commands

### Phase 5: Testing
17. Unit tests for each package
18. Integration test with MinIO + Postgres

---

## Migration Plan

1. **Deploy alongside bash** - Run both, Go in dry-run mode
2. **Shadow mode** - Go syncs to test directory
3. **Cutover** - Stop bash, enable Go
4. **Cleanup** - Remove bash service

---

## Critical Source Files (read for reference)

| File | Why |
|------|-----|
| `sync-service/scripts/r2-sync.sh` | Sync logic to replicate |
| `backend/internal/handlers/media_handler.go` | JWT claims structure |
| `backend/internal/services/storage.go` | S3 client pattern |
| `backend/internal/services/scanner_worker.go` | Worker pattern |
| `backend/internal/models/media.go` | Media status constants |

---

## Docker Compose (Final)

```yaml
services:
  r2-sync:
    build: ./sync-service-go
    ports:
      - "8080:8080"   # File server (behind tunnel)
      - "8081:8081"   # Health check
    environment:
      - DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASS
      - R2_ENDPOINT, R2_ACCESS_KEY, R2_SECRET_KEY, R2_BUCKET
      - BATCH_SIZE, SYNC_INTERVAL
      - UNRAID_TUNNEL_SECRET
    volumes:
      - /mnt/user/media/videos:/media:rw
```

Cloudflare Tunnel points to `localhost:8080` on Unraid.

---

## Success Criteria

- [ ] All bash functionality replicated
- [ ] File server serves files with valid JWT
- [ ] Invalid/expired tokens rejected
- [ ] Health endpoints work
- [ ] Graceful shutdown on SIGTERM
- [ ] Structured JSON logging
- [ ] Unit tests for core logic
- [ ] Documentation updated
