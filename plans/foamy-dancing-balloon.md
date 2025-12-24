# Code Review Remediation Plan

**Review Date:** 2025-11-24
**Status:** APPROVED FOR IMPLEMENTATION (All Issues P0-P2)

---

## Implementation Order

Execute fixes in this order to minimize risk and dependencies:

---

## Phase 1: Critical Security Fixes (Day 1)

### Task 1.1: Add Authorization to Admin Resolver

**File:** `apps/backend/src/plugins/DeliveryManager/DeliveryReservation/delivery-reservation.resolver.ts`

**Changes:**
```typescript
// Add imports
import { Allow, Permission, Transaction } from '@vendure/core'

// Add decorators to each method:
@Query()
@Allow(Permission.ReadOrder)
async ordersForDeliveryTimeBlock(...) { }

@Query()
@Allow(Permission.ReadOrder)
async countOrdersForDeliveryTimeBlock(...) { }

@Query()
@Allow(Permission.ReadOrder)
async isDeliveryTimeBlockAvailable(...) { }

@Query()
@Allow(Permission.ReadOrder)
async availableDeliveryTimeBlocks(...) { }

@Mutation()
@Allow(Permission.UpdateOrder)
@Transaction()
async assignOrderToDeliveryTimeBlock(
  @Ctx() ctx: RequestContext,
  @Args('orderId') orderId: ID,
  @Args('timeBlockId') timeBlockId: ID,
  @Args('deliveryDate') deliveryDate: Date,
  @Args('timezone') timezone?: string  // Add timezone parameter
): Promise<boolean> { }

@Mutation()
@Allow(Permission.UpdateOrder)
@Transaction()
async removeOrderFromDeliveryTimeBlock(...) { }
```

### Task 1.2: Update GraphQL Schema for Admin API

**File:** `apps/backend/src/plugins/DeliveryManager/schema.ts`

**Add timezone parameter to admin mutations:**
```graphql
extend type Mutation {
  assignOrderToDeliveryTimeBlock(
    orderId: ID!
    timeBlockId: ID!
    deliveryDate: DateTime!
    timezone: String
  ): Boolean!
}
```

### Task 1.3: Install sanitize-html and Fix XSS

**Commands:**
```bash
cd apps/backend
pnpm add sanitize-html
pnpm add -D @types/sanitize-html
```

**File:** `apps/backend/src/plugins/EmailNotifications/handlers/delivery-confirmation.handler.ts`

**Replace sanitizeHtml method:**
```typescript
import sanitizeHtml from 'sanitize-html';

private sanitizeHtml(input: string | null | undefined): string {
  if (!input) return '';
  try {
    return sanitizeHtml(input, {
      allowedTags: [],
      allowedAttributes: {},
      disallowedTagsMode: 'discard'
    }).trim();
  } catch (error) {
    Logger.error('Error sanitizing HTML', {
      error: error instanceof Error ? error.message : String(error)
    }, 'DeliveryConfirmationHandler');
    return '[Content could not be displayed]';
  }
}
```

**Also update:** `apps/backend/src/plugins/EmailNotifications/handlers/admin-order-notification.handler.ts`

---

## Phase 2: Performance & Logic Fixes (Days 2-3)

### Task 2.1: Optimize countAssignedOrders Query

**File:** `apps/backend/src/plugins/DeliveryManager/DeliveryReservation/delivery-reservation.service.ts`

**Replace lines 302-335 with optimized SQL:**
```typescript
async countAssignedOrders(ctx: RequestContext, timeBlockId: ID, date: Date, userTimezone?: string): Promise<number> {
  const timezone = userTimezone ?? 'UTC'

  // Use SQL for efficient counting with timezone support
  const query = `
    SELECT COUNT(*) as count
    FROM "order" o
    WHERE o."customFieldsDeliverytimeblockid" = $1
      AND o."customFieldsDeliveryslotreserved" = true
      AND DATE(o."customFieldsDeliverydate" AT TIME ZONE 'UTC' AT TIME ZONE $2) = DATE($3::timestamptz AT TIME ZONE $2)
  `

  const result: Array<{ count: string }> = await this.connection.rawConnection.query(query, [
    timeBlockId.toString(),
    timezone,
    date.toISOString()
  ])

  return parseInt(result[0]?.count ?? '0', 10)
}
```

### Task 2.2: Similarly optimize getOrdersForTimeBlock

**Same file, lines 340-368:**
```typescript
async getOrdersForTimeBlock(ctx: RequestContext, timeBlockId: ID, date: Date, userTimezone?: string): Promise<CoreOrder[]> {
  const timezone = userTimezone ?? 'UTC'

  const query = `
    SELECT o.*
    FROM "order" o
    WHERE o."customFieldsDeliverytimeblockid" = $1
      AND o."customFieldsDeliveryslotreserved" = true
      AND DATE(o."customFieldsDeliverydate" AT TIME ZONE 'UTC' AT TIME ZONE $2) = DATE($3::timestamptz AT TIME ZONE $2)
  `

  return this.connection.rawConnection.query(query, [
    timeBlockId.toString(),
    timezone,
    date.toISOString()
  ])
}
```

### Task 2.3: Run codegen after schema changes

```bash
cd apps/backend
pnpm dev:server &  # Start server in background
sleep 10
pnpm codegen
```

---

## Phase 3: Code Quality Fixes (Days 4-7)

### Task 3.1: Replace console.* with Logger

**Files to update (40+ occurrences):**

| File | Occurrences |
|------|-------------|
| `EmailNotifications/helpers/timezone-formatter.ts` | 5 |
| `EmailNotifications/helpers/price-formatter.ts` | 4 |
| `EmailNotifications/handlers/delivery-confirmation.handler.ts` | 2 |
| `EmailNotifications/handlers/admin-order-notification.handler.ts` | 2 |
| `DeliveryManager/Shop/shop-delivery.resolver.ts` | 6 |
| `DeliveryManager/OrderProcess/validate-delivery-city-process.ts` | 1 |
| `DeliveryManager/DeliveryTimeBlock/delivery-time-block.entity.ts` | 1 |
| `CityBasedTaxStrategy/city-based-tax.service.ts` | 2 |
| `CityBasedTaxStrategy/city-based-tax-strategy.ts` | 1 |

**Pattern to follow:**
```typescript
// Before
console.error('Error message:', error);

// After
import { Logger } from '@vendure/core';

Logger.error('Error message', {
  error: error instanceof Error ? error.message : String(error),
  stack: error instanceof Error ? error.stack : undefined
}, 'ServiceName');
```

### Task 3.2: Remove Hardcoded Development Cities

**File:** `apps/backend/src/plugins/DeliveryManager/Shop/shop-delivery.resolver.ts`

**Remove lines 65-71:**
```typescript
// DELETE these lines:
// const developmentCities = ['Phoenix', 'Scottsdale', 'Gilbert', 'Mesa', 'Tempe']
// if (developmentCities.some(devCity => devCity.toLowerCase() === city.toLowerCase())) {
//   return true
// }
```

**Create migration to seed cities:**
```bash
npx vendure migration:generate src/migrations/seed-delivery-cities
```

**Migration content:**
```typescript
export class SeedDeliveryCities1732000000000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    const phoenixMetroAreas = ['Phoenix', 'Scottsdale', 'Gilbert', 'Mesa', 'Tempe'];

    for (const cityName of phoenixMetroAreas) {
      await queryRunner.query(`
        INSERT INTO delivery_city (name, "createdAt", "updatedAt")
        VALUES ($1, NOW(), NOW())
        ON CONFLICT (name) DO NOTHING
      `, [cityName]);
    }
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DELETE FROM delivery_city
      WHERE name IN ('Phoenix', 'Scottsdale', 'Gilbert', 'Mesa', 'Tempe')
    `);
  }
}
```

### Task 3.3: Improve Email Handler Error Logging

**File:** `apps/backend/src/plugins/EmailNotifications/handlers/delivery-confirmation.handler.ts`

**Update loadData method:**
```typescript
async loadData({ event, injector }: { event: OrderStateTransitionEvent; injector: Injector }) {
  const { order, ctx } = event;
  const timeBlockId = order.customFields?.deliveryTimeBlockId;

  if (!timeBlockId) {
    return { deliveryTimeBlock: null };
  }

  try {
    const connection = injector.get(TransactionalConnection);
    const timeBlock = await connection.getRepository(ctx, 'DeliveryTimeBlock').findOne({
      where: { id: timeBlockId },
    });

    if (!timeBlock) {
      Logger.warn('Delivery time block not found for email', {
        timeBlockId,
        orderCode: order.code
      }, 'DeliveryConfirmationHandler');
    }

    return { deliveryTimeBlock: timeBlock };
  } catch (error) {
    Logger.error('Failed to load delivery time block for email', {
      timeBlockId,
      orderCode: order.code,
      customerEmail: order.customer?.emailAddress,
      error: error instanceof Error ? error.message : String(error)
    }, 'DeliveryConfirmationHandler');
    return { deliveryTimeBlock: null };
  }
}
```

---

## Phase 4: Testing & Verification (Day 8)

### Task 4.1: Run All Quality Checks

```bash
pnpm lint
pnpm typecheck
pnpm test
```

### Task 4.2: Manual Testing Checklist

- [ ] Admin cannot be accessed by customer session
- [ ] Admin mutations require proper permissions
- [ ] Timezone parameter works in admin mutations
- [ ] Email sanitization blocks XSS payloads
- [ ] Capacity counts are accurate with SQL query
- [ ] Cities load from database (not hardcoded)
- [ ] Logger output is structured and filterable

### Task 4.3: Security Verification

```bash
# Test that customer cannot access admin API
curl -X POST http://localhost:3000/admin-api \
  -H "Content-Type: application/json" \
  -H "Cookie: session=customer_session_token" \
  -d '{"query":"{ ordersForDeliveryTimeBlock(timeBlockId: \"1\", date: \"2024-12-25\") { id } }"}'
# Should return 403 Forbidden
```

---

## Files Modified Summary

| File | Changes |
|------|---------|
| `delivery-reservation.resolver.ts` | @Allow, @Transaction, timezone param |
| `delivery-reservation.service.ts` | SQL optimization for counts/queries |
| `schema.ts` | Add timezone to admin mutations |
| `delivery-confirmation.handler.ts` | sanitize-html, Logger |
| `admin-order-notification.handler.ts` | sanitize-html, Logger |
| `shop-delivery.resolver.ts` | Remove hardcoded cities, Logger |
| `timezone-formatter.ts` | Replace console with Logger |
| `price-formatter.ts` | Replace console with Logger |
| `city-based-tax.service.ts` | Replace console with Logger |
| `city-based-tax-strategy.ts` | Replace console with Logger |
| `validate-delivery-city-process.ts` | Replace console with Logger |
| `delivery-time-block.entity.ts` | Replace console with Logger |
| New migration file | Seed delivery cities |

---

## Estimated Timeline

| Phase | Duration | Risk | Commit |
|-------|----------|------|--------|
| Phase 1 (Security) | Day 1 | HIGH if skipped | `security(delivery): add authorization and transaction decorators to admin API` |
| Phase 2 (Performance) | Days 2-3 | MEDIUM | `perf(delivery): optimize capacity queries with SQL` |
| Phase 3 (Quality) | Days 4-7 | LOW | `refactor(backend): replace console logging with Vendure Logger` |
| Phase 4 (Testing) | Day 8 | Required | Verification only (no commit) |

**Total: 8 working days**

**Approach:** Phase-by-phase implementation with commits after each phase for review

---

## Dependencies

1. `sanitize-html` package (install in Phase 1)
2. Backend server running for codegen
3. Database access for migration

---

## Success Criteria

- [ ] All admin resolvers have @Allow decorators
- [ ] All mutations have @Transaction decorators
- [ ] XSS payloads are blocked by sanitize-html
- [ ] SQL queries execute in <20ms regardless of order count
- [ ] Zero console.* calls in production code
- [ ] Cities load from database
- [ ] All tests pass
- [ ] pnpm lint returns 0 errors
