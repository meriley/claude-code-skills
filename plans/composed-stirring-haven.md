# Plan: Enable Tunnel Simulation in Local Dev

## Problem
`make start` runs r2-sync on port 8082, but the backend doesn't know to generate download URLs pointing there.

## Solution
Add tunnel config to `.envrc` so backend generates URLs like `http://localhost:8082/download?token=...`

## Changes

### 1. Update `.envrc`
Add backend tunnel vars:
```bash
# Backend tunnel config (for local dev)
export UNRAID_TUNNEL_ENABLED=true
export UNRAID_TUNNEL_BASE_URL=http://localhost:8082
```

### 2. Update `.env.example`
Document the tunnel vars in the sync service section.

## Flow After Fix
1. User clicks "Download" in frontend
2. Backend generates JWT token
3. Backend returns URL: `http://localhost:8082/download?token=<jwt>`
4. Browser requests file from r2-sync on port 8082
5. r2-sync validates JWT, streams file
