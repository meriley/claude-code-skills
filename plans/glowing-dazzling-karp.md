# Plan: Add r2-sync-go to Docker Dev Environment

## Goal
Enable local development of r2-sync-go using MinIO (local S3) and Docker volumes instead of Unraid filesystem.

## Changes Required

### 1. Create `sync-service-go/Dockerfile.dev`
Hot-reload development Dockerfile using Air:
- Base: `golang:1.24-alpine`
- Install Air for hot-reload
- Mount source code
- Run with `air -c .air.toml`

### 2. Create `sync-service-go/.air.toml`
Air configuration for Go hot-reload (matches backend pattern)

### 3. Update root `docker-compose.yml`
Add `r2-sync-dev` service with:

```yaml
r2-sync-dev:
  build:
    context: ./sync-service-go
    dockerfile: Dockerfile.dev
  container_name: demi-r2-sync-dev
  profiles: ["docker-dev"]
  ports:
    - "8082:8080"  # File server (avoid conflict with backend 3001)
  environment:
    # Database (matches backend-dev pattern)
    - DB_HOST=postgres
    - DB_PORT=5432
    - DB_NAME=demi_upload
    - DB_USER=postgres
    - DB_PASS=postgres
    # Storage (MinIO, same as backend-dev)
    - R2_ENDPOINT=http://minio:9000
    - R2_ACCESS_KEY=${R2_ACCESS_KEY_ID:-minioadmin}
    - R2_SECRET_KEY=${R2_SECRET_ACCESS_KEY:-minioadmin}
    - R2_BUCKET=${R2_BUCKET_NAME:-video-uploads}
    # Sync settings (use Docker volumes)
    - ARCHIVE_DIR=/media/archive
    - ERROR_DIR=/media/errors
    - INCOMING_DIR=/media/incoming
    - SYNC_INTERVAL=1m  # Faster for dev
    - BATCH_SIZE=5
    # File server
    - UNRAID_TUNNEL_SECRET=${JWT_SECRET:-dev-secret-key-change-in-production}
  volumes:
    - ./sync-service-go:/app
    - sync_go_cache:/go/pkg/mod
    - sync_go_media:/media  # Named volume, not host path
  depends_on:
    postgres:
      condition: service_healthy
    minio:
      condition: service_healthy
  networks:
    - demi-network
```

### 4. Add volumes to root `docker-compose.yml`
```yaml
volumes:
  # ... existing volumes ...
  sync_go_cache:
  sync_go_media:
```

### 5. Update `sync-service-go/internal/config/config.go`
Add fallback for `R2_ACCESS_KEY_ID` → `R2_ACCESS_KEY` (backwards compat with root compose env var names)

## Files to Modify
1. `sync-service-go/Dockerfile.dev` (create)
2. `sync-service-go/.air.toml` (create)
3. `docker-compose.yml` (add service + volumes)
4. `sync-service-go/internal/config/config.go` (env var aliases)

## Dev Workflow After Implementation
```bash
# Start full dev stack including r2-sync
docker compose --profile docker-dev up

# Or start just r2-sync with infra
docker compose up postgres minio r2-sync-dev
```

## Notes
- Uses same `JWT_SECRET` as backend for tunnel auth (shared secret)
- File server on port 8082 to avoid conflicts
- 1-minute sync interval for faster dev feedback
- Media stored in Docker volume `sync_go_media`
