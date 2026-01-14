# TypeScript + GraphQL + gRPC Patterns Reference

This reference provides detailed patterns for TypeScript/GraphQL/gRPC code review. Load when reviewing complex distributed systems, N+1 query analysis, or production-ready streaming implementations.

---

## TypeScript Advanced Type Safety

### Branded Types for Domain IDs

```typescript
// ❌ Weak Type Safety
interface User {
  id: string;
  email: string;
  role: string; // Too broad!
}

function updateUser(user: any): Promise<any> {
  // No type safety!
  return api.post("/users", user);
}

// ✅ Strong Type Safety with Branded Types
type UserId = string & { readonly __brand: unique symbol };
type EmailAddress = string & { readonly __brand: unique symbol };
type UserRole = "admin" | "moderator" | "user";

interface User {
  readonly id: UserId;
  readonly email: EmailAddress;
  readonly role: UserRole;
  readonly createdAt: Date;
}

type CreateUserRequest = Omit<User, "id" | "createdAt">;
type UpdateUserRequest = Partial<Pick<User, "email" | "role">> & { id: UserId };

// Type-safe API functions
async function createUser(request: CreateUserRequest): Promise<User> {
  const response = await api.post<User>("/users", request);
  return response.data;
}

async function updateUser(request: UpdateUserRequest): Promise<User> {
  const { id, ...updates } = request;
  const response = await api.patch<User>(`/users/${id}`, updates);
  return response.data;
}
```

### Type-Safe API Client Pattern

```typescript
// ✅ Runtime Type Validation with Zod
class TypeSafeAPIClient {
  async request<TResponse, TRequest = unknown>(
    endpoint: string,
    method: "GET" | "POST" | "PUT" | "DELETE",
    data?: TRequest,
    schema: ZodSchema<TResponse>,
  ): Promise<TResponse> {
    const response = await fetch(endpoint, {
      method,
      body: data ? JSON.stringify(data) : undefined,
      headers: { "Content-Type": "application/json" },
    });

    if (!response.ok) {
      throw new APIError(`Request failed: ${response.status}`);
    }

    const rawData = await response.json();

    // Runtime type validation
    const validatedData = schema.parse(rawData);
    return validatedData;
  }
}
```

### Security Patterns

```typescript
// ❌ Security Vulnerability
function processUserInput(data: any): void {
  const user = { ...data }; // Prototype pollution risk!
  Object.assign(config, data); // Configuration injection!
}

// ✅ Secure Implementation
interface UserInput {
  readonly name: string;
  readonly email: string;
}

function processUserInput(data: unknown): UserInput {
  const parsed = UserInputSchema.parse(data); // Schema validation

  // Safe object creation with known properties only
  return {
    name: sanitizeString(parsed.name),
    email: validateEmail(parsed.email),
  };
}
```

---

## GraphQL DataLoader Patterns

### N+1 Query Anti-pattern vs DataLoader

```typescript
// ❌ N+1 Query Anti-pattern
class UserResolver {
  async posts(user: User): Promise<Post[]> {
    // This executes N queries for N users!
    return await PostService.findByUserId(user.id);
  }
}

// ✅ Proper DataLoader Implementation
class DataLoaderFactory {
  static createPostsByUserIdLoader(): DataLoader<string, Post[]> {
    return new DataLoader<string, Post[]>(
      async (userIds: readonly string[]) => {
        // Single batch query for all user IDs
        const posts = await PostService.findByUserIds([...userIds]);

        // Group posts by user ID, maintaining order
        const postsByUserId = new Map<string, Post[]>();
        userIds.forEach((id) => postsByUserId.set(id, []));

        posts.forEach((post) => {
          const userPosts = postsByUserId.get(post.userId) || [];
          userPosts.push(post);
          postsByUserId.set(post.userId, userPosts);
        });

        // Return results in same order as input keys
        return userIds.map((id) => postsByUserId.get(id) || []);
      },
      {
        // Configure caching and batching
        maxBatchSize: 100,
        cacheKeyFn: (key: string) => key,
        cacheMap: new Map(), // Use Redis in production
      },
    );
  }
}

class UserResolver {
  constructor(private readonly postLoader: DataLoader<string, Post[]>) {}

  async posts(user: User): Promise<Post[]> {
    return await this.postLoader.load(user.id);
  }
}
```

### Performance Testing DataLoader

```typescript
describe("DataLoader Performance", () => {
  it("should batch multiple requests efficiently", async () => {
    const loader = createUserLoader();
    const startTime = process.hrtime.bigint();

    // Simulate concurrent requests
    const promises = Array.from({ length: 100 }, (_, i) =>
      loader.load(`user-${i}`),
    );

    const results = await Promise.all(promises);
    const endTime = process.hrtime.bigint();

    expect(results).toHaveLength(100);
    expect(loader.stats.batchCount).toBeLessThan(10); // Effective batching
    expect(Number(endTime - startTime) / 1e6).toBeLessThan(100); // < 100ms
  });
});
```

---

## GraphQL Federation Patterns

### Poor vs Proper Federation Design

```typescript
// ❌ Poor Federation Design
// Gateway Schema - Tight Coupling
type User @key(fields: "id") {
  id: ID!
  email: String!
  posts: [Post!]! # Direct resolution - potential N+1!
  profile: UserProfile! # Synchronous cross-service call!
}

// ✅ Proper Federation Design
// User Service Schema
type User @key(fields: "id") {
  id: ID!
  email: String!
  createdAt: DateTime!
}

// Post Service Schema
type User @key(fields: "id") @extends {
  id: ID! @external
  posts: [Post!]! @provides(fields: "title summary")
}

type Post @key(fields: "id") {
  id: ID!
  title: String!
  summary: String!
  authorId: ID!
  author: User! @provides(fields: "id")
}

// Profile Service Schema
type User @key(fields: "id") @extends {
  id: ID! @external
  profile: UserProfile @requires(fields: "id")
}

// Efficient Federation Resolver
class UserPostsResolver {
  @ResolveReference()
  async resolveUserReference(
    reference: Pick<User, 'id'>,
    context: GraphQLContext
  ): Promise<User> {
    // Only return the ID - don't fetch full user data
    return { id: reference.id } as User;
  }

  @ResolveField('posts')
  async posts(
    @Parent() user: User,
    @Context() context: GraphQLContext
  ): Promise<Post[]> {
    // Use DataLoader for efficient batching
    return context.loaders.postsByUserId.load(user.id);
  }
}
```

### Federation Anti-patterns

```typescript
// ❌ Poor Federation Design
type User @key(fields: "id") {
  id: ID!
  email: String!
  posts: [Post!]! # Cross-service N+1 risk
  profile: UserProfile! # Synchronous dependency
  analytics: UserAnalytics! # Heavy computation in gateway
}

// ✅ Proper Federation Design
type User @key(fields: "id") {
  id: ID!
  email: String!
}

extend type User @key(fields: "id") {
  id: ID! @external
  posts: [Post!]! @provides(fields: "title publishedAt")
}

extend type User @key(fields: "id") {
  id: ID! @external
  profile: UserProfile @requires(fields: "id")
}
```

---

## gRPC Stream Safety Patterns

### Poor vs Proper Stream Management

```typescript
// ❌ Poor Stream Management
class ChatService {
  async streamMessages(call: ServerWritableStream<StreamRequest, Message>) {
    const messages = await this.getMessages();
    for (const message of messages) {
      call.write(message); // No error handling or cleanup!
    }
    call.end();
  }
}

// ✅ Proper Stream Management
class ChatService {
  async streamMessages(call: ServerWritableStream<StreamRequest, Message>) {
    const cleanup = new Set<() => void>();
    let isEnded = false;

    try {
      // Set up cancellation handling
      call.on("cancelled", () => {
        this.logger.info("Stream cancelled by client");
        this.cleanup(cleanup);
        isEnded = true;
      });

      call.on("error", (error) => {
        this.logger.error("Stream error:", error);
        this.cleanup(cleanup);
        isEnded = true;
      });

      // Set up message subscription with backpressure
      const subscription = this.messageService.subscribe(
        call.request.channelId,
        (message: Message) => {
          if (isEnded) return;

          if (!call.write(message)) {
            // Handle backpressure - client can't keep up
            this.logger.warn("Backpressure detected, pausing stream");
            subscription.pause();

            call.once("drain", () => {
              if (!isEnded) {
                subscription.resume();
              }
            });
          }
        },
      );

      cleanup.add(() => subscription.unsubscribe());

      // Handle graceful shutdown
      process.on("SIGTERM", () => {
        if (!isEnded) {
          call.end();
          this.cleanup(cleanup);
        }
      });
    } catch (error) {
      this.logger.error("Failed to setup stream:", error);
      call.emit("error", error);
    }
  }

  private cleanup(cleanupTasks: Set<() => void>): void {
    cleanupTasks.forEach((task) => {
      try {
        task();
      } catch (error) {
        this.logger.error("Cleanup task failed:", error);
      }
    });
    cleanupTasks.clear();
  }
}
```

### Safe Stream Handler Pattern

```typescript
// ✅ Safe Stream Implementation
class SafeStreamHandler {
  private readonly activeStreams = new Set<ServerWritableStream>();

  handleStream(call: ServerWritableStream<Request, Response>) {
    this.activeStreams.add(call);

    const cleanup = () => {
      this.activeStreams.delete(call);
      // Additional cleanup logic
    };

    call.on("cancelled", cleanup);
    call.on("error", cleanup);
    call.on("close", cleanup);

    // Implement stream logic with proper error handling
    this.processStreamSafely(call)
      .catch((error) => call.emit("error", error))
      .finally(cleanup);
  }

  async shutdown(): Promise<void> {
    // Gracefully close all active streams
    const closePromises = Array.from(this.activeStreams).map(
      (stream) =>
        new Promise<void>((resolve) => {
          stream.end();
          stream.on("close", resolve);
        }),
    );

    await Promise.all(closePromises);
  }
}
```

### Efficient Stream Processing with Backpressure

```typescript
// ✅ Efficient Stream Processing with Backpressure
class OptimizedStreamProcessor {
  async processStream(
    stream: Duplex,
    options: { maxConcurrency: number; batchSize: number },
  ): Promise<void> {
    const semaphore = new Semaphore(options.maxConcurrency);
    const batch: Message[] = [];

    for await (const message of stream) {
      batch.push(message);

      if (batch.length >= options.batchSize) {
        await semaphore.acquire();

        // Process batch without blocking stream
        this.processBatch([...batch])
          .finally(() => semaphore.release())
          .catch((error) => this.handleBatchError(error));

        batch.length = 0; // Clear batch
      }
    }

    // Process remaining messages
    if (batch.length > 0) {
      await this.processBatch(batch);
    }
  }
}
```

---

## Testing Patterns

### Comprehensive Test Coverage

```typescript
// ✅ Comprehensive Test Coverage Example
describe("UserService", () => {
  describe("createUser", () => {
    it.each([
      {
        scenario: "valid user data",
        input: { name: "John Doe", email: "john@example.com" },
        expectedResult: { id: expect.any(String), name: "John Doe" },
      },
      {
        scenario: "duplicate email",
        input: { name: "Jane Doe", email: "existing@example.com" },
        expectedError: "User with email already exists",
      },
      {
        scenario: "invalid email format",
        input: { name: "Invalid", email: "not-an-email" },
        expectedError: "Invalid email format",
      },
    ])(
      "should handle $scenario correctly",
      async ({ input, expectedResult, expectedError }) => {
        if (expectedError) {
          await expect(userService.createUser(input)).rejects.toThrow(
            expectedError,
          );
        } else {
          const result = await userService.createUser(input);
          expect(result).toMatchObject(expectedResult);
        }
      },
    );
  });
});
```

---

## Error Handling Patterns

### GraphQL Error Boundaries

```typescript
// ✅ Proper Error Boundaries
class GraphQLErrorHandler {
  static formatError(error: GraphQLError): GraphQLFormattedError {
    // Sanitize error messages for production
    const isDevelopment = process.env.NODE_ENV === "development";

    if (error instanceof UserInputError) {
      return {
        message: error.message,
        extensions: { code: "USER_INPUT_ERROR" },
      };
    }

    if (error instanceof AuthenticationError) {
      return {
        message: "Authentication required",
        extensions: { code: "UNAUTHENTICATED" },
      };
    }

    // Log internal errors but don't expose details
    logger.error("GraphQL Error:", error);

    return {
      message: isDevelopment ? error.message : "Internal server error",
      extensions: { code: "INTERNAL_ERROR" },
    };
  }
}
```

---

## Observability Patterns

### Comprehensive Observability

```typescript
// ✅ Comprehensive Observability
class ObservableGraphQLService {
  async resolveField(
    fieldName: string,
    resolver: () => Promise<any>,
    context: GraphQLContext,
  ): Promise<any> {
    const timer = metrics
      .histogram("graphql_field_duration_seconds")
      .startTimer({ field: fieldName });

    const traceSpan = context.tracer.startSpan(`graphql.resolve.${fieldName}`);

    try {
      logger.debug("Resolving GraphQL field", {
        field: fieldName,
        correlationId: context.correlationId,
        userId: context.user?.id,
      });

      const result = await resolver();

      metrics.counter("graphql_field_success_total").inc({ field: fieldName });

      return result;
    } catch (error) {
      metrics
        .counter("graphql_field_error_total")
        .inc({ field: fieldName, error: error.constructor.name });

      traceSpan.recordException(error);
      traceSpan.setStatus({ code: SpanStatusCode.ERROR });

      logger.error("GraphQL field resolution failed", {
        field: fieldName,
        error: error.message,
        correlationId: context.correlationId,
      });

      throw error;
    } finally {
      timer();
      traceSpan.end();
    }
  }
}
```

### Feature Flag Integration

```typescript
// ✅ Feature Flag Integration
class FeatureAwareResolver {
  async resolveWithFeatureFlag<T>(
    featureFlag: string,
    newImplementation: () => Promise<T>,
    fallbackImplementation: () => Promise<T>,
    context: GraphQLContext,
  ): Promise<T> {
    const isEnabled = await this.featureFlagService.isEnabled(
      featureFlag,
      context.user?.id,
    );

    if (isEnabled) {
      try {
        return await newImplementation();
      } catch (error) {
        // Log and fallback on errors
        logger.error("New implementation failed, falling back", {
          featureFlag,
          error: error.message,
        });

        return await fallbackImplementation();
      }
    }

    return await fallbackImplementation();
  }
}
```

---

## GraphQL Security Checklist

- [ ] Query depth limiting (max 7-10 levels)
- [ ] Query complexity analysis and limits
- [ ] Field-level authorization checks
- [ ] Input validation and sanitization
- [ ] Rate limiting on expensive operations
- [ ] Introspection disabled in production
- [ ] Error message sanitization

---

## References

- **TypeScript Official Docs** - Type system and patterns
- **GraphQL Best Practices** - Schema design and performance
- **DataLoader Documentation** - Batching and caching patterns
- **gRPC Official Guide** - Stream management and protocols
- **Apollo Federation** - Subgraph design and gateway optimization
