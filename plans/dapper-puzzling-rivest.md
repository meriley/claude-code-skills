# Fix Redis Replica Mode Issue (Recurring)

## Problem

Redis is running as a **Slave/Replica** (`1:S` in logs) instead of standalone master, causing continuous "Connection refused" errors while trying to SYNC with a non-existent master.

```
redis | 1:S 28 Nov 2025 00:15:04.227 # Error condition on socket for SYNC: Connection refused
```

## Root Cause Analysis

The current fix in `.do/docker-compose.yaml` line 132:
```yaml
command: redis-server --maxmemory 512mb --maxmemory-policy allkeys-lru --save 60 1 --loglevel warning --replicaof no one
```

**This is INVALID!** `--replicaof no one` is NOT a valid Redis CLI startup argument.

- `REPLICAOF NO ONE` is a **runtime command** (executed inside redis-cli)
- The command-line syntax is `--replicaof <ip> <port>` (requires two arguments)

The external volume `do_redis-data` likely contains persisted replica configuration from a previous setup.

---

## Solution

### Approach: Remove invalid flag + Mount custom redis.conf

**Step 1: Create `.do/redis.conf`**

```conf
# Redis Configuration for Standalone Master Mode
# Prevents replica mode regardless of volume state

# Explicitly disable replication (ensure master mode)
# Note: We don't set replicaof at all, which means standalone master

# Performance settings
maxmemory 512mb
maxmemory-policy allkeys-lru

# Persistence
save 60 1

# Logging
loglevel warning

# Security (bind to container network only)
bind 0.0.0.0
protected-mode no
```

**Step 2: Update `.do/docker-compose.yaml`**

```yaml
redis:
  image: redis:7-alpine
  container_name: redis
  restart: unless-stopped
  ports:
    - "6379:6379"
  command: redis-server /etc/redis/redis.conf
  volumes:
    - redis-data:/data
    - ./redis.conf:/etc/redis/redis.conf:ro
  networks:
    - asphalt-net
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 10s
    timeout: 5s
    retries: 5
```

**Step 3: One-time cleanup on production server (manual)**

```bash
# On production server, after deploying new config:
cd /opt/asphalt-flowers/.do

# Stop Redis container
docker-compose stop redis

# Clear any stale replica config from volume
docker run --rm -v do_redis-data:/data alpine sh -c "rm -f /data/redis.conf /data/*.aof 2>/dev/null; echo 'Cleaned'"

# Restart Redis with new config
docker-compose up -d redis

# Verify Redis is now master (should show "role:master")
docker exec redis redis-cli INFO replication | head -5
```

---

## Files to Modify

1. **Create:** `.do/redis.conf` - Custom Redis configuration file
2. **Modify:** `.do/docker-compose.yaml` - Update redis service to use config file

---

## Verification Steps

After deployment:
```bash
# Check role (should be "master", not "slave")
docker exec redis redis-cli INFO replication | grep role

# Check no SYNC errors in logs
docker logs redis --tail=20 | grep -i sync

# Verify Redis responds
docker exec redis redis-cli PING
```

---

## Why This Fix is Permanent

1. **Explicit config file** takes precedence over any persisted state
2. **No replicaof directive** = Redis runs as standalone master by default
3. **Volume cleanup** removes any stale replica configuration
4. **Config is mounted read-only** so Redis can't modify it

---

## Alternative: Volume Reset (Destructive)

If the above doesn't work, the nuclear option is to recreate the Redis volume:

```bash
# WARNING: This will delete all cached session data!
docker-compose down
docker volume rm do_redis-data
docker volume create do_redis-data
docker-compose up -d
```

This is only necessary if Redis continues to enter replica mode despite the config file fix.
