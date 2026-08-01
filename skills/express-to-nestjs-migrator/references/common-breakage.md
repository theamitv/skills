# Common Express → NestJS Breakage Points

## 1. Middleware Execution Order

**Express**: Linear — middleware A calls `next()`, then middleware B runs.
**Nest**: Layered by scope (global → controller → route) and type (guard → interceptor → pipe → handler).

**Risk**: Two Express middlewares registered in sequence may not map to the same Nest primitive, changing execution order.

**Fix**: Map each middleware to the correct Nest concept. If ordering matters, ensure they use the same primitive type at the same scope level.

## 2. req/res Mutation (State Passing)

**Express**: Common pattern — middleware A sets `req.user`, middleware B reads it, route handler uses it.
**Nest**: DI model discourages mutable request state. Guards/interceptors can still mutate `req`, but it's not type-safe.

**Fix**: Use `createParamDecorator` for typed access to request properties. Migrate shared state to Nest providers where possible.

## 3. Error Handling

**Express**: 4-argument error handler `(err, req, res, next)` catches errors from any middleware.
**Nest**: `ExceptionFilter` catches exceptions. Nest's built-in filter handles `HttpException`. Unhandled errors return 500.

**Risk**: Express error handlers often format errors differently (custom status codes, error shapes). Nest's default filter returns `{ statusCode, message, error }`.

**Fix**: Create a custom `ExceptionFilter` that matches the exact error response shape from the Express app.

## 4. Response Modification in Middleware

**Express**: Middleware can call `res.json()`, `res.send()`, `res.redirect()` at any point in the chain.
**Nest**: Controllers return values; interceptors can modify responses. Middleware calling `res.send()` bypasses Nest's pipeline.

**Fix**: Move response-shaping logic to interceptors or the controller itself. Use `@Res()` injection only as a last resort.

## 5. Dynamic Route Registration

**Express**: Routes can be registered dynamically at runtime:
```js
app.get('/api/' + someVar, handler);
```
**Nest**: Routes are declared statically via decorators at compile time.

**Fix**: Use Nest's dynamic module registration or a custom route factory for truly dynamic routes.

## 6. Express-Specific req/res Properties

Express adds properties to `req`/`res` that Nest may not expose:

| Express Property | Nest Equivalent |
|-----------------|-----------------|
| `req.params` | `@Param()` decorator |
| `req.query` | `@Query()` decorator |
| `req.body` | `@Body()` decorator |
| `req.headers` | `@Headers()` decorator |
| `req.ip` | `@Ip()` decorator |
| `req.hostname` | `@HostParam()` decorator |
| `req.path` | `@Req()` then `req.path` |
| `req.baseUrl` | `@Req()` then `req.baseUrl` |
| `req.xhr` | `@Req()` then `req.xhr` |
| `req.cookies` | `@Cookies()` decorator (from `@nestjs/common`) |
| `req.accepts()` | `@Req()` then `req.accepts()` |
| `res.status()` | `@HttpCode()` decorator or `return { statusCode }` |
| `res.redirect()` | `@Redirect()` decorator |
| `res.render()` | `@Render()` decorator (template engines) |

## 7. Module-Level Constants vs DI

**Express**: Common to import singletons at module level:
```js
const db = require('./db');
const config = require('./config');
```

**Nest**: These should become providers:
```ts
@Module({
  providers: [
    DatabaseService,
    { provide: 'CONFIG', useValue: config },
  ],
})
```

**Risk**: Module-level constants don't participate in DI, making testing and scoping harder.

## 8. Async Middleware

**Express**: Async middleware requires explicit error catching:
```js
app.use(async (req, res, next) => {
  try { /* ... */ } catch (err) { next(err); }
});
```

**Nest**: Guards, interceptors, and pipes natively support async/await. Nest catches thrown errors automatically.

## 9. Static File Serving

**Express**: `app.use(express.static('public'))`
**Nest**: Use `@nestjs/serve-static`:
```ts
import { ServeStaticModule } from '@nestjs/serve-static';
@Module({
  imports: [
    ServeStaticModule.forRoot({ rootPath: join(__dirname, '..', 'public') }),
  ],
})
```

## 10. Testing

**Express**: Often tested with `supertest` + manual server setup.
**Nest**: Built-in testing utilities via `@nestjs/testing`:
```ts
const module = await Test.createTestingModule({
  imports: [AppModule],
}).compile();
const app = module.createNestApplication();
return request(app.getHttpServer()).get('/users');
```

## 11. TypeScript Configuration

Express apps may use loose TS config. Nest requires stricter settings:

```json
{
  "compilerOptions": {
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "target": "ES2021",
    "module": "commonjs"
  }
}
```

## 12. File Structure Migration

| Express | NestJS |
|---------|--------|
| `routes/users.js` | `src/users/users.module.ts` + `users.controller.ts` + `users.service.ts` |
| `middleware/auth.js` | `src/common/guards/auth.guard.ts` |
| `middleware/error.js` | `src/common/filters/http-exception.filter.ts` |
| `middleware/logger.js` | `src/common/interceptors/logging.interceptor.ts` |
| `config/index.js` | `src/config/` module with providers |
| `app.js` | `src/app.module.ts` + `src/main.ts` |
