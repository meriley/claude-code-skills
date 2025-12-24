# Plan: Implement Streamed Malware Scanning

## Task
Implement streamed virus scanning to avoid loading entire files into memory. This addresses OOM risk for large files (up to 5GB).

## Current State
- `GetObject()` returns `[]byte` - loads entire file into RAM
- `ScanForMalware([]byte)` already streams to ClamAV in 2KB chunks
- Problem: 5GB file = 5GB memory allocation before scanning starts

## Target State
- `GetObjectStream()` returns `io.ReadCloser` - stream from R2
- `ScanForMalwareStream(io.Reader)` - stream input to ClamAV
- Memory: O(2KB) regardless of file size

---

## Implementation Steps

### Step 1: Add `GetObjectStream` to StorageClient

**File**: `internal/services/storage.go`

1. Add method to interface:
```go
type StorageClient interface {
    // ... existing methods
    GetObjectStream(key string) (io.ReadCloser, int64, error)  // Returns reader + size
}
```

2. Implement in `StorageService`:
```go
func (s *StorageService) GetObjectStream(key string) (io.ReadCloser, int64, error) {
    result, err := s.client.GetObject(&s3.GetObjectInput{
        Bucket: aws.String(s.bucket),
        Key:    aws.String(key),
    })
    if err != nil {
        return nil, 0, fmt.Errorf("failed to get object stream: %w", err)
    }
    size := int64(0)
    if result.ContentLength != nil {
        size = *result.ContentLength
    }
    return result.Body, size, nil
}
```

### Step 2: Add `ScanForMalwareStream` to MalwareScanner

**File**: `internal/services/validation.go`

1. Add method to interface (in `scanner_worker.go`):
```go
type MalwareScanner interface {
    ScanForMalware(fileData []byte) (bool, error)
    ScanForMalwareStream(reader io.Reader) (bool, error)  // NEW
}
```

2. Implement streaming scan - similar to existing but reads from reader:
```go
func (v *ValidationService) ScanForMalwareStream(reader io.Reader) (bool, error) {
    conn, err := v.dialClamAV()
    if err != nil {
        return false, err
    }
    defer conn.Close()

    // Set deadline
    conn.SetDeadline(time.Now().Add(v.scanTimeout))

    // Send INSTREAM command
    if _, err := conn.Write([]byte("zINSTREAM\x00")); err != nil {
        return false, fmt.Errorf("failed to send INSTREAM: %w", err)
    }

    // Stream chunks from reader
    buf := make([]byte, 2048)
    for {
        n, err := reader.Read(buf)
        if n > 0 {
            // Send chunk size (big-endian) + data
            sizeBuf := make([]byte, 4)
            binary.BigEndian.PutUint32(sizeBuf, uint32(n))
            if _, err := conn.Write(sizeBuf); err != nil {
                return false, fmt.Errorf("failed to send chunk size: %w", err)
            }
            if _, err := conn.Write(buf[:n]); err != nil {
                return false, fmt.Errorf("failed to send chunk: %w", err)
            }
        }
        if err == io.EOF {
            break
        }
        if err != nil {
            return false, fmt.Errorf("failed to read from stream: %w", err)
        }
    }

    // Send terminator (4 zero bytes)
    if _, err := conn.Write([]byte{0, 0, 0, 0}); err != nil {
        return false, fmt.Errorf("failed to send terminator: %w", err)
    }

    // Read and parse response
    return v.readScanResponse(conn)
}
```

### Step 3: Update ScannerWorker to Use Streaming

**File**: `internal/services/scanner_worker.go`

Update `scanMedia` method:
```go
func (w *ScannerWorker) scanMedia(media *models.Media) {
    // ... existing status update code ...

    // Stream file from R2 directly to scanner
    reader, size, err := w.storageService.GetObjectStream(media.R2Key)
    if err != nil {
        w.handleScanError(media, fmt.Errorf("failed to get file stream: %w", err))
        return
    }
    defer reader.Close()

    // Limit reader to max file size
    limitedReader := io.LimitReader(reader, constants.MaxFileSizeBytes+1)

    // Perform streaming malware scan
    isSafe, err := w.validationService.ScanForMalwareStream(limitedReader)
    // ... rest of existing logic ...
}
```

### Step 4: Update Mock for Tests

**File**: `internal/services/scanner_worker_test.go`

Add streaming method to mock:
```go
type mockStorageClient struct {
    getObjectData   []byte
    getObjectError  error
}

func (m *mockStorageClient) GetObjectStream(key string) (io.ReadCloser, int64, error) {
    if m.getObjectError != nil {
        return nil, 0, m.getObjectError
    }
    return io.NopCloser(bytes.NewReader(m.getObjectData)), int64(len(m.getObjectData)), nil
}
```

Add streaming method to validation mock:
```go
type mockValidationService struct {
    scanResult bool
    scanError  error
}

func (m *mockValidationService) ScanForMalwareStream(reader io.Reader) (bool, error) {
    // Drain the reader to simulate scanning
    io.Copy(io.Discard, reader)
    return m.scanResult, m.scanError
}
```

---

## Files to Modify

| File | Changes |
|------|---------|
| `internal/services/storage.go` | Add `GetObjectStream()` method |
| `internal/services/validation.go` | Add `ScanForMalwareStream()` method |
| `internal/services/scanner_worker.go` | Update interface, use streaming in `scanMedia()` |
| `internal/services/scanner_worker_test.go` | Update mocks for streaming methods |

## Backward Compatibility

- Keep existing `GetObject()` and `ScanForMalware()` methods
- `ThumbnailWorker` continues using buffered `GetObject()` (thumbnails are small)
- Only `ScannerWorker` uses streaming path

## Testing Strategy

1. Unit tests with mocked streaming
2. Integration test with actual ClamAV + EICAR test file
3. Manual test with large file (> 100MB) to verify memory profile
