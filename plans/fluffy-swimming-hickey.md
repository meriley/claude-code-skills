# Improve Migrate Command - Only Require DATABASE_URL

## Problem
The `cmd/migrate/main.go` uses `config.Load()` which validates all required fields (including `JWT_SECRET`), but migration only needs `DATABASE_URL`. This makes the migrate command unnecessarily difficult to use.

## Fix

### Option A: Read DATABASE_URL Directly (Recommended)
Simplest fix - migrate reads `DATABASE_URL` directly from environment, bypassing `config.Load()`:

```go
package main

import (
    "fmt"
    "log"
    "os"

    "github.com/joho/godotenv"
    "github.com/mriley/demi-upload/internal/database"
)

func main() {
    // Load .env file if it exists
    _ = godotenv.Load()

    // Only need DATABASE_URL for migrations
    databaseURL := os.Getenv("DATABASE_URL")
    if databaseURL == "" {
        log.Fatal("DATABASE_URL is required")
    }

    // Connect to database
    db, err := database.Connect(databaseURL)
    if err != nil {
        log.Fatalf("Failed to connect to database: %v", err)
    }
    defer database.Close(db)

    fmt.Println("Running database migrations...")

    // Run auto-migration
    if err := database.AutoMigrate(db); err != nil {
        log.Fatalf("Migration failed: %v", err)
    }

    fmt.Println("Migration completed successfully!")
    os.Exit(0)
}
```

## Files to Modify
- `backend/cmd/migrate/main.go` - Simplify to only require DATABASE_URL
