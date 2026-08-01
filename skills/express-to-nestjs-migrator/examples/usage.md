# Usage Examples

## Basic Migration

```
Migrate this Express app to NestJS
```

Triggers the full three-phase process: inspect → plan → execute.

## Structure-Focused

```
I want better structure for my Express API
Restructure my Express app with dependency injection
```

The skill will focus on module breakdown and DI migration.

## Middleware-Heavy

```
Convert my Express middleware to NestJS guards and interceptors
```

The skill will produce a detailed middleware → Nest concept mapping table.

## Incremental Migration

```
Wrap my existing Express app with NestJS incrementally
```

The skill will recommend an incremental approach using `@nestjs/platform-express` to wrap the existing Express app during transition.

## Error-Driven

```
[Paste an Express error handler or middleware issue]
```

The skill will diagnose whether the issue is related to middleware ordering or error handling patterns.

## Example Migration Output

### Phase 1 — Risk Summary
```
This Express app has:
- 8 middleware functions registered (3 global, 5 per-route)
- 2 middleware that mutate req (req.user, req.session)
- 15 route handlers across 3 router files
- Custom error handler with specific JSON error shape
- Module-level DB client singleton
- No existing TypeScript
```

### Phase 2 — Migration Plan
```
1. Module breakdown: UsersModule, OrdersModule, AuthModule, CommonModule
2. Middleware mapping:
   - auth middleware → AuthGuard (global)
   - request logger → LoggingInterceptor (global)
   - error handler → HttpExceptionFilter (global)
   - body parser → Nest built-in (main.ts)
   - rate limiter → @nestjs/throttler (AppModule)
   - req.user mutation → custom @User decorator
3. Ordering concern: auth (sets req.user) → route handler (reads req.user) — Guard runs before handler, safe
4. Recommendation: full rewrite (app is not yet in production)
```

### Phase 3 — Verification
```
✅ All 15 routes respond with same method/path/status/shape
✅ Middleware execution order verified with test request
✅ Auth guard returns 401 for unauthorized requests (same as before)
✅ Error filter returns same JSON shape as Express error handler
```
