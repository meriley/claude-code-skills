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

