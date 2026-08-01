# Express Middleware → NestJS Concept Mapping

## The Core Rule

| Express Concept | NestJS Equivalent | When to Use |
|-----------------|-------------------|-------------|
| `app.use(middleware)` (global) | Module-level config or global middleware | Applies to all routes |
| `router.use(middleware)` (scoped) | Controller-level `@UseGuards/Interceptors/Pipes` | Applies to a controller group |
| `route.use(middleware)` (per-route) | Handler-level `@UseGuards/Interceptors/Pipes` | Applies to a single handler |
| Auth/authorization middleware | `@UseGuards(AuthGuard)` | Authentication & authorization |
| Request logging middleware | `LoggingInterceptor` | Logging, metrics, timing |
| Body parsing (`express.json()`) | `app.use(express.json())` in `main.ts` or Nest's built-in body parser | Body parsing |
| CORS middleware | `app.enableCors()` in `main.ts` | CORS configuration |
| Error handling middleware (4-arg) | Global `ExceptionFilter` | Error responses, logging errors |
| Input validation middleware | `ValidationPipe` with DTOs | Request validation |
| Rate limiting middleware | `@nestjs/throttler` guard | Rate limiting |
| Static file serving | `@nestjs/serve-static` module | Serving static assets |
| Session middleware | `@nestjs/session` or custom module | Session management |
| CSRF protection | `csurf` package + Nest guard | CSRF tokens |
| Compression middleware | `compression` package as Nest interceptor | Response compression |
| Helmet (security headers) | `app.use(helmet())` in `main.ts` | Security headers |
| `req.customProp = value` pattern | Custom decorator + provider | Shared state via DI |

## Execution Order in NestJS

Nest's request pipeline executes in this order:

```
Incoming Request
  → Global Middleware (app.use())
  → Module Middleware (configure() in module)
  → Global Guards
  → Controller Guards
  → Route Guards
  → Global Interceptors (before)
  → Controller Interceptors (before)
  → Route Interceptors (before)
  → Global Pipes
  → Controller Pipes
  → Route Pipes
  → Route Handler
  → Route Interceptors (after)
  → Controller Interceptors (after)
  → Global Interceptors (after)
  → Exception Filter (if error thrown anywhere above)
  → Response
```

**Key difference from Express**: In Express, middleware runs in registration order — each calls `next()` to pass control. In Nest, guards/interceptors/pipes are layered by *scope* (global → controller → route), not registration order. This means two Express middlewares registered in sequence may need to be the *same* Nest primitive type to preserve ordering.

## Middleware That Mutates req/res

Express middleware often attaches data to `req`:

```js
// Express: attach user to req
app.use((req, res, next) => {
  req.user = { id: 1, role: 'admin' };
  next();
});
```

In Nest, this becomes a **custom decorator** + **guard or interceptor**:

```ts
// Nest: custom decorator extracts from request
@Injectable()
export class UserGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest();
    req.user = { id: 1, role: 'admin' }; // still works but not DI-friendly
    return true;
  }
}

// Better: custom param decorator
export const User = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    return request.user;
  },
);
```

## Middleware Ordering Dependencies

If middleware A sets `req.foo` and middleware B reads `req.foo`, they must map to the **same Nest primitive type** to preserve ordering:

| Express Order | Nest Mapping | Works? |
|---------------|-------------|--------|
| A (auth) → B (logging) | A → Guard, B → Interceptor | ✅ Guard runs before Interceptor |
| A (set req.user) → B (use req.user) | A → Guard, B → Guard | ✅ Both Guards, same scope |
| A (set req.user) → B (use req.user) | A → Guard, B → Interceptor | ⚠️ Guard runs first, but Interceptor can still read `req.user` |
| A (log timing start) → B (handler) → C (log timing end) | A → Interceptor (before), C → Interceptor (after) | ✅ Single interceptor wraps both |
| A (validate) → B (sanitize) → C (handler) | A → Pipe, B → Pipe | ⚠️ Pipes run in reverse order for the same scope! Use a single pipe instead |
