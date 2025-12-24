# Fix: Stripe Webhook Routing in Caddyfile.combined

## Problem
Stripe reports webhook failures at `https://payments.asphaltflowersandplants.com/stripe`.

## Root Cause
`Caddyfile.combined` is missing the path rewrite that exists in `Caddyfile.domain`.

- **Vendure expects webhooks at:** `/payments/stripe`
- **Stripe sends to:** `/stripe`
- **Caddyfile.combined does:** Direct proxy (no rewrite) → 404

## Fix

Update `.do/caddy/Caddyfile.combined` lines 101-107:

**Before:**
```caddy
# Payments - Stripe webhooks
# All webhooks handled by Vendure's StripePlugin at /payments/stripe
payments.asphaltflowersandplants.com {
    import tls_cloudflare
    import logging
    reverse_proxy vendure-server:3000
}
```

**After:**
```caddy
# Payments - Stripe webhooks
# Vendure's StripePlugin handles at /payments/stripe
payments.asphaltflowersandplants.com {
    import tls_cloudflare
    import logging

    # Route /stripe to /payments/stripe (Stripe sends to /stripe)
    @stripePath path /stripe
    rewrite @stripePath /payments/stripe

    reverse_proxy vendure-server:3000
}
```

## Verification Steps (Post-Deploy)

1. **Check current routing mode on production:**
   ```bash
   cd /opt/asphalt-flowers/.do && make routing
   ```

2. **If using combined mode, reload Caddy:**
   ```bash
   docker-compose exec caddy caddy reload --config /etc/caddy/Caddyfile
   ```

3. **Test webhook endpoint:**
   ```bash
   curl -X POST https://payments.asphaltflowersandplants.com/stripe \
     -H "Content-Type: application/json" \
     -d '{"test": true}'
   # Should return 400 (bad signature) not 404
   ```

4. **Trigger Stripe test webhook:**
   ```bash
   stripe trigger payment_intent.succeeded
   ```

## Files to Modify
- `.do/caddy/Caddyfile.combined` (lines 101-107)
