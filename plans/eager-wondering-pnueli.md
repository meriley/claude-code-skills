# Plan: Support Both Domains with Redirect

## Goal
Configure Caddy to support both `asphaltflowersandplants.com` (production) and `asphalt-flowers.com` (staging), with staging redirecting to production.

## Caddy Best Practices Applied (from official docs)

Based on https://caddyserver.com/docs/caddyfile/patterns and /concepts:

1. **Snippets for code reuse** - Define `(tls_cloudflare)` snippet, import across all blocks
2. **Multiple addresses** - Combine related domains: `asphalt-flowers.com, www.asphalt-flowers.com { }`
3. **Proper brace placement** - Opening `{` at end of line with preceding space
4. **Logging snippet** - Reusable `(logging)` snippet for consistent log configuration

## Redirect Mappings

| Staging Domain | → | Production Domain |
|----------------|---|-------------------|
| asphalt-flowers.com | → | asphaltflowersandplants.com |
| www.asphalt-flowers.com | → | asphaltflowersandplants.com |
| admin.asphalt-flowers.com | → | admin.asphaltflowersandplants.com |
| api.asphalt-flowers.com | → | api.asphaltflowersandplants.com |
| cdn.asphalt-flowers.com | → | cdn.asphaltflowersandplants.com |
| pos.asphalt-flowers.com | → | pos.asphaltflowersandplants.com |
| payments.asphalt-flowers.com | → | payments.asphaltflowersandplants.com |

## Implementation

### File Structure
```
.do/caddy/
├── Caddyfile.combined  # NEW - both domains with redirects
├── Caddyfile.domain    # Keep - production only (backup)
├── Caddyfile.staging   # Keep - staging only (backup)
└── Caddyfile.ip        # Keep - IP-based access
```

### Caddyfile.combined Structure

```caddy
{
    servers {
        trusted_proxies static 192.168.50.202/32
    }
    acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
}

# ==================== REUSABLE SNIPPETS ====================

# TLS with Cloudflare DNS challenge (reusable)
(tls_cloudflare) {
    tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        resolvers 1.1.1.1
    }
}

# Standard logging configuration
(logging) {
    log {
        output file /var/log/caddy/asphaltflowers.log
    }
}

# ==================== STAGING REDIRECTS ====================
# All asphalt-flowers.com domains redirect to asphaltflowersandplants.com

asphalt-flowers.com, www.asphalt-flowers.com {
    import tls_cloudflare
    redir https://asphaltflowersandplants.com{uri} permanent
}

admin.asphalt-flowers.com {
    import tls_cloudflare
    redir https://admin.asphaltflowersandplants.com{uri} permanent
}

api.asphalt-flowers.com {
    import tls_cloudflare
    redir https://api.asphaltflowersandplants.com{uri} permanent
}

cdn.asphalt-flowers.com {
    import tls_cloudflare
    redir https://cdn.asphaltflowersandplants.com{uri} permanent
}

pos.asphalt-flowers.com {
    import tls_cloudflare
    redir https://pos.asphaltflowersandplants.com{uri} permanent
}

payments.asphalt-flowers.com {
    import tls_cloudflare
    redir https://payments.asphaltflowersandplants.com{uri} permanent
}

# ==================== PRODUCTION DOMAINS ====================
# (Copy from Caddyfile.domain, using snippets for DRY)

www.asphaltflowersandplants.com {
    redir https://asphaltflowersandplants.com{uri} permanent
}

asphaltflowersandplants.com {
    import tls_cloudflare
    import logging
    reverse_proxy storefront:4000
}

cdn.asphaltflowersandplants.com {
    import tls_cloudflare
    import logging
    reverse_proxy vendure-server:3000
}

admin.asphaltflowersandplants.com {
    import tls_cloudflare
    import logging
    @not_admin not path /admin/*
    rewrite @not_admin /admin{uri}
    reverse_proxy vendure-server:3000
}

api.asphaltflowersandplants.com {
    import tls_cloudflare
    import logging
    reverse_proxy vendure-server:3000
}

payments.asphaltflowersandplants.com {
    import tls_cloudflare
    import logging
    # All Stripe webhooks go to Vendure's StripePlugin at /payments/stripe
    reverse_proxy vendure-server:3000
    # NOTE: /pos/webhook route removed - POS has no webhook handler
    # All payment webhooks are now consolidated in Vendure backend
}

pos.asphaltflowersandplants.com {
    import tls_cloudflare
    import logging
    reverse_proxy pos:3001
}
```

## Files to Create/Modify

| File | Action |
|------|--------|
| `.do/caddy/Caddyfile.combined` | Create - combined config with snippets and redirects |
| `.do/Makefile` | Add `switch-combined` target |

## Deployment Steps

1. Create `Caddyfile.combined`
2. On server: `cd /opt/asphalt-flowers/.do && make switch-combined`
3. Caddy auto-reloads with new config
4. Test both domains work correctly

## Benefits
- **DRY**: Snippets eliminate repeated TLS/logging config
- **SEO**: Single canonical domain prevents duplicate content
- **SSL**: Both domains get certificates via Cloudflare DNS challenge
- **Seamless**: Users hitting staging links get redirected automatically
- **Maintainable**: Clear separation between redirects and production blocks
