# Breaking Change Detection Reference

## Breaking Change Categories

### 1. Removals (Always Breaking)

| Change | Example | Impact |
|--------|---------|--------|
| Remove endpoint | DELETE /users/{id} → removed | 404 for existing consumers |
| Remove field | `email` removed from response | Consumer crashes on access |
| Remove enum value | `status: pending\|active\|archived` → `pending\|active` | Serialization failure |
| Remove request parameter | `?include=stats` no longer accepted | Silent ignored param |

### 2. Type Changes (Always Breaking)

| Change | Example | Risk |
|--------|---------|------|
| Narrow→Wider | `int32` → `int64` | Safe in most languages |
| Wider→Narrow | `int64` → `int32` | Overflow on large values |
| String→Enum | `"pending"` → `enum Pending` | Safe if values match |
| Enum→String | `enum` → `string` | Consumers lose validation |
| Object→Array | `{...}` → `[...]` | Deserialization crash |
| Nullable→Required | `type: string, nullable: true` → `type: string` | Existing nulls break |

### 3. Semantic Changes (Hard to Detect)

| Change | Detection Strategy |
|--------|-------------------|
| Sort order changed | Compare example responses |
| Pagination default changed | Check `pageSize` default |
| Rate limit lowered | Check `X-RateLimit-*` headers |
| Error format changed | Compare error response schemas |
| Idempotency removed | Check `Idempotency-Key` header handling |
| Auth requirement added | Compare security schemes |

### 4. Additive Changes (Usually Safe)

| Change | Caveat |
|--------|--------|
| New endpoint | Safe — doesn't break existing consumers |
| New optional field | Safe — consumers ignore unknown fields |
| New enum value | **Potentially breaking** — consumers with exhaustive switches fail |
| New HTTP method | Safe — existing methods unchanged |

## Consumer Impact Analysis

```
Breaking Change: Remove field "email" from GET /users/{id}/profile
Impact: 3 known consumers read this field
  - billing-service (reads email for invoicing) — HIGH
  - notification-service (reads email for alerts) — HIGH
  - analytics-pipeline (reads email for reporting) — MEDIUM
Migration: Add email to a new /users/{id}/contact endpoint
Deprecation: Keep field for 2 versions with @deprecated annotation
```

## Versioning Strategies

| Strategy | Pros | Cons |
|----------|------|------|
| URL path (`/v1/`, `/v2/`) | Explicit, cache-friendly | URL proliferation |
| Header (`Accept: version=2`) | Clean URLs | Harder to discover |
| Query param (`?version=2`) | Easy to test | Pollutes cache keys |
| No versioning | Simple | Breaking changes impossible |

## Recommended Governance Rules

- All removals require 2-version deprecation notice
- Type changes require major version bump
- New enum values must be additive (never reorder)
- Breaking change report required for all production API changes
- Consumer impact analysis required for all breaking changes
