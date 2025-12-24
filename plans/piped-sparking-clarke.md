# Proxmox Deployment Directory for Demi Upload

**Goal:** Create a self-contained `.proxmox` directory that can be cloned into a Proxmox LXC/VM to deploy demi-upload with Docker services.

**Reference:** Adapted from `asphaltflowers/.do/` pattern

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     Proxmox LXC/VM                              │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │                    Caddy (Reverse Proxy)                │  │
│   │                    Port 80/443 → services               │  │
│   └────────────────────────┬────────────────────────────────┘  │
│                            │                                    │
│   ┌────────────┐    ┌──────┴─────┐    ┌──────────────┐        │
│   │  Frontend  │    │  Backend   │    │  PostgreSQL  │        │
│   │  (nginx)   │    │  (Go API)  │    │  (DB)        │        │
│   │  :80       │    │  :8080     │    │  :5432       │        │
│   └────────────┘    └────────────┘    └──────────────┘        │
│                                                                 │
│   External Volumes: proxmox_postgres-data, proxmox_uploads     │
└─────────────────────────────────────────────────────────────────┘
```

**Key Difference from asphaltflowers:**
- No Redis (demi-upload doesn't need it)
- No workers (no background jobs currently)
- Cloudflare R2 for storage (not local S3)
- Simpler setup: 3 core services vs 7

---

## Directory Structure

```
.proxmox/
├── README.md                   # Deployment documentation
├── Makefile                    # Deployment automation commands
├── docker-compose.yaml         # Service orchestration
├── .env.example               # Environment template
├── lxc-setup.sh               # Interactive LXC setup script
├── caddy/
│   ├── Caddyfile.ip           # IP-based routing (pre-DNS)
│   └── Caddyfile.domain       # Production domain routing
└── scripts/
    └── backup.sh              # Database backup script
```

---

## Services

| Service | Image | Port | Purpose |
|---------|-------|------|---------|
| `frontend` | `gitea.cmtriley.com/mriley/demi-frontend:latest` | 80 | Vite React UI via nginx |
| `backend` | `gitea.cmtriley.com/mriley/demi-backend:latest` | 8080 | Go API server |
| `postgres` | `postgres:16-alpine` | 5432 | Database |
| `caddy` | `caddy:2-alpine` | 80, 443 | Reverse proxy |

---

## Environment Variables

### Required

```bash
# PostgreSQL
POSTGRES_USER=demi
POSTGRES_PASSWORD=<secure-password>
POSTGRES_DB=demi_upload

# Backend
DATABASE_URL=postgres://demi:<password>@postgres:5432/demi_upload?sslmode=disable
JWT_SECRET=<32-char-secret>

# Cloudflare R2
R2_ACCESS_KEY=<from-cloudflare>
R2_SECRET_KEY=<from-cloudflare>
R2_ENDPOINT=https://<account-id>.r2.cloudflarestorage.com
R2_BUCKET=<bucket-name>

# Domain (when ready)
DOMAIN=upload.example.com
```

### Optional

```bash
# Feature flags
ENABLE_ANTIVIRUS=false      # ClamAV integration
MAX_UPLOAD_SIZE=2147483648  # 2GB default

# Timezone
TZ=America/New_York
```

---

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make deploy` | Pull images and start all services |
| `make restart` | Restart all services |
| `make stop` | Stop all services |
| `make logs` | View combined logs |
| `make logs-backend` | View backend logs |
| `make status` | Show container status |
| `make backup` | Backup PostgreSQL database |
| `make switch-ip` | Switch to IP-based Caddyfile |
| `make switch-domain` | Switch to domain Caddyfile |
| `make shell-backend` | Shell into backend container |
| `make shell-db` | Shell into postgres container |
| `make pull` | Pull latest images |
| `make clean` | Remove containers (keep volumes) |
| `make nuke` | Remove everything including volumes |

---

## Routing Modes

### 1. IP Mode (Initial Setup)

Access via LXC IP: `http://192.168.1.x`

```
Caddyfile.ip:
- / → frontend:80
- /api/* → backend:8080
- /health → backend:8080/health
```

### 2. Domain Mode (Production)

Access via domain: `https://upload.example.com`

```
Caddyfile.domain:
- Automatic HTTPS via Let's Encrypt
- Same routing as IP mode
- HSTS headers
```

---

## Volume Strategy

External named volumes (persist across `docker-compose down`):

| Volume | Mount | Purpose |
|--------|-------|---------|
| `proxmox_postgres-data` | `/var/lib/postgresql/data` | Database |
| `proxmox_caddy-data` | `/data` | Certificates |
| `proxmox_caddy-config` | `/config` | Caddy config |

---

## Setup Script Features

`lxc-setup.sh` will:

1. **Check Prerequisites**
   - Docker installed
   - Docker Compose available
   - Git available

2. **Clone Repository** (if needed)
   - Prompt for Gitea credentials
   - Clone to `/opt/demi-upload`

3. **Configure Environment**
   - Prompt for PostgreSQL password
   - Prompt for JWT secret (or generate)
   - Prompt for R2 credentials
   - Create `.env` file

4. **Pull Images**
   - Login to Gitea registry
   - Pull all service images

5. **Start Services**
   - Create external volumes
   - Start docker-compose
   - Run database migrations

6. **Verify Health**
   - Check all containers running
   - Test API health endpoint
   - Display access URL

---

## Implementation Tasks

### Phase 1: Core Files

1. [ ] Create `.proxmox/docker-compose.yaml`
   - 4 services: frontend, backend, postgres, caddy
   - External volumes with `proxmox_` prefix
   - Health checks for all services
   - Proper networking

2. [ ] Create `.proxmox/.env.example`
   - All required variables documented
   - Sensible defaults where possible
   - Comments explaining each variable

3. [ ] Create `.proxmox/Makefile`
   - All deployment targets
   - Color-coded output
   - Help target with descriptions

### Phase 2: Caddy Configuration

4. [ ] Create `.proxmox/caddy/Caddyfile.ip`
   - IP-based routing
   - API proxy to backend
   - Static files to frontend

5. [ ] Create `.proxmox/caddy/Caddyfile.domain`
   - Automatic HTTPS
   - Security headers
   - Same routing logic

### Phase 3: Setup Script

6. [ ] Create `.proxmox/lxc-setup.sh`
   - Interactive prompts
   - Credential validation
   - Service startup
   - Health verification

### Phase 4: Documentation

7. [ ] Create `.proxmox/README.md`
   - Quick start guide
   - Environment variables reference
   - Troubleshooting section
   - Maintenance commands

### Phase 5: Utilities

8. [ ] Create `.proxmox/scripts/backup.sh`
   - PostgreSQL dump
   - Timestamped files
   - Retention policy

---

## Key Differences from asphaltflowers/.do

| Aspect | asphaltflowers/.do | demi-upload/.proxmox |
|--------|-------------------|---------------------|
| Services | 7 (web, workers, redis, etc.) | 4 (frontend, backend, postgres, caddy) |
| Storage | MinIO (local S3) | Cloudflare R2 (cloud) |
| Background Jobs | Yes (workers) | No |
| Cache | Redis | None |
| Auth | Stripe + sessions | JWT |
| Setup Script | `droplet-setup.sh` | `lxc-setup.sh` |

---

## Files to Create

| Priority | File | Lines (est.) |
|----------|------|--------------|
| 1 | `.proxmox/docker-compose.yaml` | ~100 |
| 2 | `.proxmox/.env.example` | ~50 |
| 3 | `.proxmox/Makefile` | ~150 |
| 4 | `.proxmox/caddy/Caddyfile.ip` | ~40 |
| 5 | `.proxmox/caddy/Caddyfile.domain` | ~50 |
| 6 | `.proxmox/lxc-setup.sh` | ~300 |
| 7 | `.proxmox/README.md` | ~200 |
| 8 | `.proxmox/scripts/backup.sh` | ~50 |

**Total:** ~940 lines across 8 files

---

## Success Criteria

- [ ] `make deploy` starts all services successfully
- [ ] Frontend accessible at LXC IP
- [ ] Backend health check passes
- [ ] Database migrations run automatically
- [ ] `make backup` creates PostgreSQL dump
- [ ] `make switch-domain` enables HTTPS
- [ ] Setup script creates working deployment from scratch
- [ ] README documents all operations

---

**Plan Status:** READY FOR IMPLEMENTATION
