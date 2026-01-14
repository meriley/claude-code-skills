---
name: vendure-delivery-plugin
description: Build delivery and fulfillment plugins for Vendure with idempotency, capacity management, timezone handling, and N+1 prevention. Covers ShippingCalculator, FulfillmentHandler, and slot reservation patterns. Use when implementing delivery features.
version: 1.0.0
---

# Vendure Delivery Plugin

## Purpose

Guide creation of delivery and fulfillment features in Vendure with production-grade patterns for concurrency, performance, and reliability.

## When NOT to Use

- Generic plugin structure (use vendure-plugin-writing)
- Simple CRUD operations (use vendure-entity-writing)
- Standard GraphQL endpoints (use vendure-graphql-writing)

---

## CRITICAL Patterns

These patterns are essential for production-grade delivery systems.

### 1. Idempotency for Slot Operations

```typescript
// idempotency.service.ts
import * as crypto from "crypto";
import { Injectable } from "@nestjs/common";
import { TransactionalConnection, RequestContext } from "@vendure/core";

export interface IdempotencyResponse {
  isProcessing?: boolean;
  isCompleted?: boolean;
  responseStatus?: number;
  responseBody?: unknown;
}

const IDEMPOTENCY_TTL_MINUTES = 24 * 60; // 24 hours

@Injectable()
export class IdempotencyService {
  constructor(private connection: TransactionalConnection) {}

  /**
   * Generate consistent hash for request payload
   */
  generateRequestHash(payload: unknown): string {
    const data = JSON.stringify(payload);
    return crypto.createHash("sha256").update(data).digest("hex");
  }

  /**
   * Check idempotency status before processing
   */
  async checkIdempotency(
    ctx: RequestContext,
    idempotencyKey: string,
    requestHash: string,
  ): Promise<IdempotencyResponse> {
    const repo = this.connection.getRepository(ctx, IdempotencyRecord);
    const existing = await repo.findOne({ where: { idempotencyKey } });

    if (existing) {
      // Check TTL
      const ageMinutes = (Date.now() - existing.createdAt.getTime()) / 60000;
      if (ageMinutes > IDEMPOTENCY_TTL_MINUTES) {
        await repo.delete({ idempotencyKey });
        return {}; // Treat as new
      }

      // Conflict: key reused with different payload
      if (existing.requestHash !== requestHash) {
        return {
          isCompleted: true,
          responseStatus: 409,
          responseBody: { message: "Idempotency key reused" },
        };
      }

      // Already completed
      if (existing.responseStatus > 0) {
        return {
          isCompleted: true,
          responseStatus: existing.responseStatus,
          responseBody: existing.responseBody,
        };
      }

      // Still processing
      return { isProcessing: true };
    }

    // New request - create record
    await this.createRecord(ctx, idempotencyKey, requestHash);
    return {};
  }

  async storeResponse(
    ctx: RequestContext,
    key: string,
    status: number,
    body: unknown,
  ): Promise<void> {
    const repo = this.connection.getRepository(ctx, IdempotencyRecord);
    await repo.update(
      { idempotencyKey: key },
      {
        responseStatus: status,
        responseBody: JSON.stringify(body),
      },
    );
  }
}
```

### 2. Pessimistic Locking for Capacity

```typescript
// delivery-reservation.service.ts
async reserveSlot(
  ctx: RequestContext,
  orderId: ID,
  timeBlockId: ID,
  deliveryDate: Date,
  idempotencyKey?: string,
  requestHash?: string,
  userTimezone?: string
): Promise<boolean> {
  // Check idempotency first
  if (idempotencyKey && requestHash) {
    const check = await this.idempotencyService.checkIdempotency(
      ctx, idempotencyKey, requestHash
    );
    if (check.isCompleted) {
      if (check.responseStatus >= 400) {
        throw new HttpException(check.responseBody, check.responseStatus);
      }
      return true; // Previous success
    }
    if (check.isProcessing) {
      throw new HttpException('Request processing', HttpStatus.ACCEPTED);
    }
  }

  let result = false;
  let error: unknown = null;
  let httpStatus = HttpStatus.OK;

  try {
    // Use transaction with pessimistic locking
    await this.connection.rawConnection.transaction(async (manager) => {
      // Verify order exists
      const order = await manager.findOne(Order, { where: { id: orderId } });
      if (!order) {
        throw new HttpException('Order not found', HttpStatus.NOT_FOUND);
      }

      // Lock the time block row (SELECT FOR UPDATE)
      const lockedBlock = await manager
        .createQueryBuilder(DeliveryTimeBlock, 'block')
        .where('block.id = :id', { id: timeBlockId })
        .setLock('pessimistic_write')
        .getOne();

      if (!lockedBlock) {
        throw new HttpException('Time block not found', HttpStatus.NOT_FOUND);
      }

      // Convert to UTC for storage
      const utcDate = this.convertToUTCForStorage(deliveryDate, userTimezone);

      // Count assigned orders (atomic within transaction)
      const count = await this.countAssignedOrdersAtomic(
        manager, timeBlockId, utcDate
      );

      if (count >= lockedBlock.maxDeliveries) {
        throw new HttpException(
          `Slot at capacity (${count}/${lockedBlock.maxDeliveries})`,
          HttpStatus.CONFLICT
        );
      }

      // Reserve the slot
      await manager.update(Order, orderId, {
        customFields: {
          deliveryTimeBlockId: timeBlockId.toString(),
          deliverySlotReserved: true,
          deliveryDate: utcDate,
        },
      });
    });

    result = true;
  } catch (e) {
    error = e;
    httpStatus = e instanceof HttpException
      ? e.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;
  }

  // Store idempotency response
  if (idempotencyKey) {
    const body = error
      ? { message: error instanceof Error ? error.message : String(error) }
      : result;
    await this.idempotencyService.storeResponse(ctx, idempotencyKey, httpStatus, body);
  }

  if (error) throw error;
  return result;
}
```

### 3. UTC Timezone Storage

```typescript
import dayjs from 'dayjs';
import utc from 'dayjs/plugin/utc';
import timezone from 'dayjs/plugin/timezone';

dayjs.extend(utc);
dayjs.extend(timezone);

/**
 * Convert user's local date to UTC for database storage
 * Takes a date representing a local calendar date and converts to UTC midnight
 */
private convertToUTCForStorage(localDate: Date, userTimezone?: string): Date {
  const tz = userTimezone ?? 'UTC';
  const dateStr = localDate.toISOString().split('T')[0]; // YYYY-MM-DD

  // Create at midnight in user's timezone
  const localMidnight = dayjs.tz(`${dateStr} 00:00:00`, tz);

  // Convert to UTC
  return localMidnight.utc().toDate();
}

/**
 * Convert UTC date from database to user's local date
 */
private convertFromUTCForComparison(utcDate: Date, userTimezone: string): string {
  return dayjs(utcDate).tz(userTimezone).format('YYYY-MM-DD');
}

/**
 * Format date with timezone awareness
 */
private formatDate(date: Date, userTimezone?: string): string {
  if (userTimezone && userTimezone !== 'UTC') {
    return dayjs(date).tz(userTimezone).format('YYYY-MM-DD');
  }
  // Use UTC methods
  return `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, '0')}-${String(date.getUTCDate()).padStart(2, '0')}`;
}
```

### 4. N+1 Query Prevention

```typescript
/**
 * OPTIMIZED: Batch count orders for multiple time blocks
 * Uses single GROUP BY query instead of N individual queries
 */
private async batchCountAssignedOrders(
  ctx: RequestContext,
  timeBlockIds: string[],
  date: Date,
  userTimezone?: string
): Promise<Map<string, number>> {
  if (timeBlockIds.length === 0) return new Map();

  const tz = userTimezone ?? 'UTC';
  const formattedDate = this.formatDate(date, tz);

  // Single query with GROUP BY
  const query = `
    SELECT o."customFieldsDeliverytimeblockid" as block_id, COUNT(*) as count
    FROM "order" o
    WHERE o."customFieldsDeliverytimeblockid" = ANY($1)
      AND o."customFieldsDeliveryslotreserved" = true
      AND DATE(o."customFieldsDeliverydate" AT TIME ZONE 'UTC' AT TIME ZONE $2) = $3::date
    GROUP BY o."customFieldsDeliverytimeblockid"
  `;

  const result = await this.connection.rawConnection.query(
    query,
    [timeBlockIds, tz, formattedDate]
  );

  // Build map with defaults
  const countMap = new Map<string, number>();
  for (const id of timeBlockIds) {
    countMap.set(id, 0);
  }
  for (const row of result) {
    countMap.set(row.block_id, parseInt(row.count, 10));
  }

  return countMap;
}

/**
 * OPTIMIZED: Get available time blocks with 2 queries instead of 1+3N
 */
async getAvailableTimeBlocks(
  ctx: RequestContext,
  date: Date,
  userTimezone?: string
): Promise<DeliveryTimeBlock[]> {
  // Query 1: Get all time blocks with relations
  const allBlocks = await this.connection
    .getRepository(ctx, DeliveryTimeBlock)
    .find({ relations: ['deliveryDays'] });

  if (allBlocks.length === 0) return [];

  // Filter in memory (no additional queries)
  const eligibleBlocks = allBlocks.filter(block =>
    this.isTimeBlockAvailableForDate(block, date, userTimezone)
  );

  if (eligibleBlocks.length === 0) return [];

  // Query 2: Batch count all orders
  const blockIds = eligibleBlocks.map(b => b.id.toString());
  const orderCounts = await this.batchCountAssignedOrders(
    ctx, blockIds, date, userTimezone
  );

  // Filter out full blocks
  return eligibleBlocks
    .filter(block => {
      const count = orderCounts.get(block.id.toString()) ?? 0;
      return count < block.maxDeliveries;
    })
    .map(block => ({
      ...block,
      ordersCount: orderCounts.get(block.id.toString()) ?? 0,
      remainingCapacity: block.maxDeliveries - (orderCounts.get(block.id.toString()) ?? 0),
    }));
}
```

---

## Shop API Patterns

### IDOR Prevention

```typescript
/**
 * SECURITY: Verify order belongs to current session
 * Prevents IDOR attacks on delivery slot manipulation
 */
private async verifyOrderOwnership(
  ctx: RequestContext,
  orderId: ID
): Promise<void> {
  const activeOrder = await this.activeOrderService.getActiveOrder(ctx, {});

  if (!activeOrder) {
    throw new HttpException(
      'You do not have permission to modify this order',
      HttpStatus.FORBIDDEN
    );
  }

  if (activeOrder.id.toString() !== orderId.toString()) {
    Logger.warn(
      `IDOR attempt: active=${activeOrder.id}, requested=${orderId}`,
      'ShopDeliveryResolver'
    );
    throw new HttpException(
      'You do not have permission to modify this order',
      HttpStatus.FORBIDDEN
    );
  }
}
```

### Customer-Facing Resolver

```typescript
@Resolver()
export class ShopDeliveryResolver {
  constructor(
    private reservationService: DeliveryReservationService,
    private activeOrderService: ActiveOrderService,
    private orderService: OrderService,
    private idempotencyService: IdempotencyService,
  ) {}

  @Allow(Permission.Public)
  @Query()
  async availableDeliveryTimeBlocks(
    @Ctx() ctx: RequestContext,
    @Args("date") date: Date,
    @Args("timezone") timezone?: string,
  ): Promise<AvailableSlotsResponse> {
    const tz = timezone ?? "UTC";
    const slots = await this.reservationService.getAvailableTimeBlocks(
      ctx,
      date,
      tz,
    );
    return { availableSlots: slots, cutoffTime: "17:00", blackoutDates: [] };
  }

  @Allow(Permission.Public)
  @Mutation()
  @UseInterceptors(IdempotencyInterceptor)
  @Transaction()
  async setOrderDeliveryTimeBlock(
    @Ctx() ctx: RequestContext,
    @Args("orderId") orderId: ID,
    @Args("timeBlockId") timeBlockId: ID,
    @Args("deliveryDate") deliveryDate: Date,
    @Args("timezone") timezone?: string,
  ): Promise<Order> {
    // SECURITY: Verify ownership first
    await this.verifyOrderOwnership(ctx, orderId);

    const { idempotencyKey, graphqlArgs } = ctx as IdempotentRequestContext;
    const requestHash = idempotencyKey
      ? this.idempotencyService.generateRequestHash(graphqlArgs)
      : undefined;

    await this.reservationService.reserveSlot(
      ctx,
      orderId,
      timeBlockId,
      deliveryDate,
      idempotencyKey,
      requestHash,
      timezone ?? "UTC",
    );

    const order = await this.orderService.findOne(ctx, orderId);
    if (!order)
      throw new HttpException("Order not found", HttpStatus.NOT_FOUND);
    return order;
  }
}
```

---

## InputMaybe Handling

```typescript
/**
 * CRITICAL: GraphQL InputMaybe<T> generates T | null | undefined
 * Must check BOTH to avoid bugs
 */

// WRONG - null passes through!
if (input.value !== undefined) {
  entity.value = input.value;
}

// CORRECT - handles both undefined and null
if (input.value !== undefined && input.value !== null) {
  entity.value = input.value;
}

// For nullable fields where null is valid:
if (input.description !== undefined) {
  entity.description = input.description; // null is valid here
}
```

---

## Entity Patterns

### Time Block Entity

```typescript
@Entity()
export class DeliveryTimeBlock extends VendureEntity {
  constructor(input?: DeepPartial<DeliveryTimeBlock>) {
    super(input);
  }

  @Column()
  startTime: string; // "09:00"

  @Column()
  endTime: string; // "12:00"

  @Column({ type: "int" })
  maxDeliveries: number;

  @Column({ type: "int", default: 0 })
  fee: number; // In smallest currency unit (cents)

  @Column()
  currencyCode: string;

  @OneToMany(() => DeliveryDay, (day) => day.timeBlock)
  deliveryDays: DeliveryDay[];
}
```

### Idempotency Record Entity

```typescript
@Entity()
export class IdempotencyRecord extends VendureEntity {
  constructor(input?: DeepPartial<IdempotencyRecord>) {
    super(input);
  }

  @Index({ unique: true })
  @Column()
  idempotencyKey: string;

  @Column()
  requestHash: string;

  @Column({ type: "int", default: 0 })
  responseStatus: number; // 0 = processing

  @Column({ type: "simple-json", nullable: true })
  responseBody: unknown;
}
```

---

## GraphQL Schema

```typescript
export const deliveryShopSchema = gql`
  type AvailableDeliverySlotsResponse {
    availableSlots: [DeliveryTimeBlock!]!
    cutoffTime: String!
    blackoutDates: [DateTime!]!
  }

  type DeliveryTimeBlock {
    id: ID!
    startTime: String!
    endTime: String!
    fee: Int!
    currencyCode: String!
    remainingCapacity: Int
  }

  extend type Query {
    availableDeliveryTimeBlocks(
      date: DateTime!
      timezone: String
    ): AvailableDeliverySlotsResponse!

    isDeliveryTimeBlockAvailable(
      timeBlockId: ID!
      date: DateTime!
      timezone: String
    ): Boolean!

    isDeliveryAvailableForAddress(city: String!): Boolean!
  }

  extend type Mutation {
    setOrderDeliveryTimeBlock(
      orderId: ID!
      timeBlockId: ID!
      deliveryDate: DateTime!
      timezone: String
    ): Order!

    releaseOrderDeliveryTimeBlock(orderId: ID!): Order!
  }
`;
```

---

## Idempotency Interceptor

```typescript
@Injectable()
export class IdempotencyInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const gqlContext = GqlExecutionContext.create(context);
    const ctx = gqlContext.getContext().req;

    // Extract X-Idempotency-Key header
    const idempotencyKey = ctx.headers?.["x-idempotency-key"];

    if (idempotencyKey) {
      // Attach to RequestContext for service use
      (ctx as IdempotentRequestContext).idempotencyKey = idempotencyKey;
      (ctx as IdempotentRequestContext).graphqlArgs = gqlContext.getArgs();
    }

    return next.handle();
  }
}
```

---

## Testing Patterns

```typescript
describe("DeliveryReservationService", () => {
  it("should prevent double booking with pessimistic lock", async () => {
    // Create time block with capacity 1
    const block = await createTimeBlock({ maxDeliveries: 1 });

    // Simulate concurrent requests
    const [result1, result2] = await Promise.allSettled([
      service.reserveSlot(ctx, order1.id, block.id, date),
      service.reserveSlot(ctx, order2.id, block.id, date),
    ]);

    // One should succeed, one should fail
    const successes = [result1, result2].filter(
      (r) => r.status === "fulfilled",
    );
    const failures = [result1, result2].filter((r) => r.status === "rejected");

    expect(successes).toHaveLength(1);
    expect(failures).toHaveLength(1);
  });

  it("should handle idempotent requests", async () => {
    const key = "unique-key-123";
    const hash = service.generateRequestHash({ orderId: order.id });

    // First request succeeds
    await service.reserveSlot(ctx, order.id, block.id, date, key, hash);

    // Second request with same key returns cached response
    const result2 = await service.reserveSlot(
      ctx,
      order.id,
      block.id,
      date,
      key,
      hash,
    );
    expect(result2).toBe(true);
  });
});
```

---

## Troubleshooting

| Problem                    | Cause                    | Solution                             |
| -------------------------- | ------------------------ | ------------------------------------ |
| Race condition on booking  | Missing pessimistic lock | Use `setLock('pessimistic_write')`   |
| Wrong date in different TZ | Storing local time       | Always convert to UTC for storage    |
| Slow slot availability     | N+1 queries              | Use batch counting with GROUP BY     |
| Duplicate reservations     | Missing idempotency      | Implement X-Idempotency-Key handling |
| IDOR vulnerability         | No ownership check       | Call `verifyOrderOwnership()` first  |

---

## Related Skills

- **vendure-plugin-writing** - Plugin structure
- **vendure-entity-writing** - Entity patterns
- **vendure-graphql-writing** - GraphQL patterns
