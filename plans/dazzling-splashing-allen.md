# POS Payment Polling Fixes

## Problem Summary

Three issues with POS checkout payment flow:

1. **Polling too fast & GraphQL errors**: useEffect re-runs on every status change causing rapid polling
2. **Polling stops after 60 seconds**: MAX_POLL_ATTEMPTS limit causes premature timeout
3. **Order state not reset on cancel/navigation**: Cart items lost, order stuck in ArrangingPayment

---

## Root Cause Analysis

### Issue 1: Polling Interval Bug

**File:** `apps/pos/app/routes/payment/route.tsx` (lines 442-493)

```typescript
useEffect(() => {
  // ... polling logic ...
  pollPaymentStatus()           // ← Immediate poll on effect run
  pollingIntervalRef.current = setInterval(() => {
    pollPaymentStatus()
  }, 1500)

  return () => clearInterval(...)
}, [paymentId, paymentStatus, orderState, pollPaymentStatus])  // ← BUG: state in deps
```

**Problem:** `paymentStatus` and `orderState` change on every poll response, causing:
1. Effect cleanup runs (clears interval)
2. Effect re-runs immediately
3. Calls `pollPaymentStatus()` immediately (line 477)
4. Creates new interval
5. Result: Polls every ~100ms instead of 1500ms

### Issue 2: Polling Timeout

**File:** `apps/pos/app/routes/payment/route.tsx` (lines 459-474)

```typescript
if (pollAttemptsRef.current >= MAX_POLL_ATTEMPTS) {  // MAX_POLL_ATTEMPTS = 40
  // Shows error, stops polling
  clearInterval(pollingIntervalRef.current)
  return
}
```

**Problem:** User wants polling to continue indefinitely until terminal state.

### Issue 3: Order State Not Reset

**File:** `apps/pos/app/routes/payment/route.tsx` (lines 279-289)

```typescript
const handleCancelPayment = useCallback(() => {
  // Cancels payment but doesn't reset order state
  fetcherSubmit(formData, { method: 'POST' })
}, [...])
```

**Problem:** When payment is canceled or user navigates away:
- Payment is canceled in Stripe
- Order remains in `ArrangingPayment` state
- Cart items preserved but order unusable
- User cannot retry checkout

---

## Implementation Plan

### Fix 1: Correct Polling Interval

**Approach:** Remove state dependencies from useEffect, use refs for state checks

```typescript
// Before (buggy):
useEffect(() => {
  pollPaymentStatus()
  const interval = setInterval(() => pollPaymentStatus(), 1500)
  return () => clearInterval(interval)
}, [paymentId, paymentStatus, orderState, pollPaymentStatus])

// After (fixed):
useEffect(() => {
  if (!paymentId) return

  // Use refs for state checks inside interval (no re-trigger)
  const interval = setInterval(() => {
    // Check terminal conditions via refs
    if (isTerminalStateRef.current) {
      clearInterval(interval)
      return
    }
    pollPaymentStatus()
  }, 1500)

  // Initial poll
  pollPaymentStatus()

  return () => clearInterval(interval)
}, [paymentId])  // Only paymentId triggers new interval
```

**Key Changes:**
1. Remove `paymentStatus`, `orderState`, `pollPaymentStatus` from dependencies
2. Add refs to track terminal state: `isTerminalStateRef`
3. Check refs inside interval callback (not effect dependencies)
4. Only `paymentId` change triggers new interval

### Fix 2: Remove Polling Timeout (Never Stop)

**Approach:** Remove MAX_POLL_ATTEMPTS logic entirely

```typescript
// Remove these lines (459-474):
if (pollAttemptsRef.current >= MAX_POLL_ATTEMPTS) {
  // ... timeout handling ...
  return
}
```

**Replace with:** Polling continues until terminal state:
- `SUCCEEDED` + (`Complete` or `PaymentSettled`)
- `FAILED`
- `CANCELED`

**Optional:** Add a much longer timeout (10+ minutes) with staff notification.

### Fix 3: Reset Order State on Cancel/Navigation

**Approach:** Add backend mutation to transition order back to AddingItems

**A. Add new GraphQL mutation (backend):**

```graphql
# In POSOrder plugin schema
extend type Mutation {
  resetPosOrderToAddingItems(orderCode: String!): Order
}
```

**B. Add resolver logic:**

```typescript
// In POSOrder resolver
@Mutation()
async resetPosOrderToAddingItems(
  @Ctx() ctx: RequestContext,
  @Args() { orderCode }: { orderCode: string }
): Promise<Order> {
  const order = await this.orderService.findOneByCode(ctx, orderCode)

  // Only reset if in ArrangingPayment state
  if (order.state === 'ArrangingPayment') {
    return this.orderService.transitionToState(ctx, order.id, 'AddingItems')
  }

  return order
}
```

**C. Call on cancel (frontend):**

```typescript
const handleCancelPayment = useCallback(async () => {
  // 1. Cancel Stripe payment
  fetcherSubmit({ _action: 'cancel-payment', paymentId }, { method: 'POST' })

  // 2. Reset order to AddingItems (new action)
  fetcherSubmit({ _action: 'reset-order', orderCode: order.code }, { method: 'POST' })
}, [...])
```

**D. Call on navigation away:**

```typescript
useEffect(() => {
  return () => {
    if (paymentId && paymentStatus !== 'SUCCEEDED') {
      // Best effort: reset order on unmount
      // Note: May not complete before unmount - backend should also handle
      navigator.sendBeacon('/api/reset-order', JSON.stringify({ orderCode }))
    }
  }
}, [...])
```

---

## Files to Modify

| File | Changes |
|------|---------|
| `apps/pos/app/routes/payment/route.tsx` | Fix polling useEffect, remove timeout, add reset-order action |
| `apps/backend/src/plugins/POSOrder/api/schema.ts` | Add `resetPosOrderToAddingItems` mutation |
| `apps/backend/src/plugins/POSOrder/api/pos-order.resolver.ts` | Implement reset mutation |
| `apps/pos/app/gql/admin/mutations/` | Add reset order mutation GraphQL file |

---

## Implementation Order

1. **Backend first:** Add `resetPosOrderToAddingItems` mutation
2. **Generate types:** `pnpm codegen` in backend, `pnpm gen` in POS
3. **Fix polling interval:** Refactor useEffect dependencies
4. **Remove timeout:** Delete MAX_POLL_ATTEMPTS logic
5. **Add reset on cancel:** Call reset mutation in handleCancelPayment
6. **Add reset on navigation:** Add cleanup effect with sendBeacon fallback
7. **Test:** Verify polling works correctly, cancel resets order

---

## Success Criteria

1. Polling happens exactly every 1.5 seconds (not faster)
2. Polling never stops until terminal state reached
3. Canceling payment resets order to AddingItems (cart preserved)
4. Navigating away resets order to AddingItems
5. User can retry checkout after cancel/navigation

---

## Critical Files to Read Before Implementation

| File | Reason |
|------|--------|
| `apps/pos/app/routes/payment/route.tsx` | Main file to modify |
| `apps/backend/src/plugins/POSOrder/api/pos-order.resolver.ts` | Add reset mutation |
| `apps/backend/src/plugins/POSOrder/services/pos-order.service.ts` | Service layer for reset |
| `apps/pos/app/routes/cart-management/route.tsx` | Understand order state patterns |
