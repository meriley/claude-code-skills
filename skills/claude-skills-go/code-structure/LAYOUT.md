# Reference Package Layouts

Example layouts for common RMS Go project types.

## Microservice Layout

```
service-name/
├── cmd/
│   └── service-name/
│       └── main.go              # Entry point, wiring
│
├── internal/
│   ├── config/
│   │   └── config.go            # Configuration loading
│   │
│   ├── handler/
│   │   ├── grpc/
│   │   │   ├── handler.go       # gRPC service impl
│   │   │   └── handler_test.go
│   │   └── http/
│   │       ├── handler.go       # HTTP handlers
│   │       └── handler_test.go
│   │
│   ├── service/
│   │   ├── task/
│   │   │   ├── service.go       # Business logic
│   │   │   └── service_test.go
│   │   └── user/
│   │       ├── service.go
│   │       └── service_test.go
│   │
│   └── store/
│       ├── mysql/
│       │   ├── store.go         # MySQL implementation
│       │   └── store_test.go
│       └── redis/
│           ├── cache.go         # Redis cache
│           └── cache_test.go
│
├── pkg/
│   └── client/
│       ├── client.go            # Public client library
│       └── client_test.go
│
├── api/
│   └── proto/
│       └── service.proto        # Proto definitions
│
├── scripts/
│   ├── build.sh
│   └── migrate.sh
│
├── docker/
│   └── Dockerfile
│
├── go.mod
├── go.sum
├── Makefile
└── README.md
```

## Domain Library Layout

```
taskcore/
├── entity/
│   ├── doc.go                   # Package documentation
│   ├── task.go                  # Task entity
│   ├── task_test.go
│   ├── action.go                # Action entity
│   ├── action_test.go
│   ├── assignment.go            # Assignment entity
│   └── assignment_test.go
│
├── factory/
│   ├── factory.go               # TaskFactory
│   ├── factory_test.go
│   ├── options.go               # Functional options
│   └── params.go                # CreateTaskParams
│
├── metadata/
│   ├── processor.go             # Pipeline orchestration
│   ├── processor_test.go
│   ├── stages/
│   │   ├── boolean.go           # Boolean normalization
│   │   ├── time.go              # Time standardization
│   │   ├── promotion.go         # Field promotion
│   │   └── validation.go        # Validation stage
│   └── stages_test.go
│
├── converter/
│   ├── proto.go                 # Proto conversion
│   ├── proto_test.go
│   ├── graph.go                 # Graph conversion
│   └── graph_test.go
│
├── constants/
│   ├── status.go                # Status enum
│   ├── priority.go              # Priority enum
│   └── action_type.go           # ActionType enum
│
├── internal/
│   └── validate/
│       └── validate.go          # Internal validation
│
├── go.mod
├── go.sum
└── README.md
```

## Kafka Consumer Layout

```
consumer-name/
├── cmd/
│   └── consumer/
│       └── main.go              # Entry point
│
├── internal/
│   ├── config/
│   │   └── config.go
│   │
│   ├── consumer/
│   │   ├── consumer.go          # Kafka consumer
│   │   ├── consumer_test.go
│   │   └── handler.go           # Message handler
│   │
│   └── processor/
│       ├── processor.go         # Business logic
│       └── processor_test.go
│
├── go.mod
├── go.sum
├── Makefile
└── README.md
```

## CLI Tool Layout

```
cli-tool/
├── cmd/
│   └── tool-name/
│       └── main.go
│
├── internal/
│   └── commands/
│       ├── root.go              # Root command
│       ├── create.go            # Subcommand
│       └── list.go              # Subcommand
│
├── go.mod
├── go.sum
└── README.md
```

## Shared Package Layout

```
rms-common/
├── context/
│   └── context.go               # Context utilities
│
├── errors/
│   ├── errors.go                # Common errors
│   └── codes.go                 # Error codes
│
├── id/
│   ├── id.go                    # ID type
│   └── generator.go             # ID generation
│
├── logger/
│   ├── logger.go                # Logger interface
│   └── slog.go                  # slog implementation
│
├── go.mod
├── go.sum
└── README.md
```

## Package File Organization

### Small Package (< 200 lines)

```
package/
├── package.go                   # All code
└── package_test.go              # All tests
```

### Medium Package (200-500 lines)

```
package/
├── doc.go                       # Package doc
├── types.go                     # Type definitions
├── package.go                   # Main implementation
└── package_test.go              # Tests
```

### Large Package (500+ lines)

```
package/
├── doc.go                       # Package documentation
├── types.go                     # Type definitions
├── errors.go                    # Error definitions
├── options.go                   # Functional options
├── service.go                   # Main service
├── service_test.go
├── handler.go                   # Handlers
├── handler_test.go
├── store.go                     # Data access
└── store_test.go
```

## Test Organization

### Unit Tests

```
package/
├── service.go
├── service_test.go              # Unit tests for service.go
├── handler.go
└── handler_test.go              # Unit tests for handler.go
```

### Integration Tests

```
package/
├── service.go
├── service_test.go              # Unit tests
├── integration_test.go          # Integration tests (separate file)
└── testdata/
    ├── fixture1.json
    └── fixture2.json
```

### Test Helpers

```
package/
├── service.go
├── service_test.go
├── testing.go                   # Test helpers (exported for other packages)
└── testutil_test.go             # Internal test utilities (not exported)
```

## Common Directories

| Directory | Purpose |
|-----------|---------|
| `cmd/` | Application entry points |
| `internal/` | Private packages |
| `pkg/` | Public library packages |
| `api/` | API definitions (proto, OpenAPI) |
| `scripts/` | Build and utility scripts |
| `docker/` | Docker files |
| `testdata/` | Test fixtures |
| `docs/` | Documentation |
| `tools/` | Development tools |
