---
name: express-to-nestjs-migrator
description: "Migrate Express.js apps to NestJS. Triggers on: 'migrate Express to NestJS', 'better structure', 'dependency injection' for Express projects, converting routes/middleware/controllers to Nest modules, Express + Nest mentioned together, 'restructure my Express app'. Do NOT trigger for brand-new Nest projects with no Express code."
---

# Express → NestJS Migrator

## Phase 1 — THINK
Middleware order is the single biggest source of subtle bugs in this migration — Nest's guards/interceptors/pipes execute in a different conceptual model than Express middleware chains. Before planning anything:
- Map every Express middleware currently registered, in the exact order it runs, including per-route middleware, not just app-level `app.use()`
- Identify what each middleware actually does: auth check, logging, body parsing, error handling, CORS — because each maps to a *different* Nest concept (guard, interceptor, pipe, exception filter, or module-level config)
- Find any middleware that mutates `req`/`res` and is depended on by later middleware or route handlers — this state-passing pattern doesn't translate directly to Nest's DI model and needs a redesign, not a 1:1 port
- Check for raw `app.get/post/put/delete` route definitions vs. any router-based structure already in place — this tells you how much restructuring is ahead

## Phase 2 — PLAN
Show the user, before any code changes:
1. Proposed module breakdown (which routes become which Nest modules/controllers)
2. Explicit middleware → Nest concept mapping table (e.g. "auth middleware → AuthGuard", "error handler → global ExceptionFilter", "request logger → LoggingInterceptor")
3. Which middleware has ordering dependencies that need special handling (Nest guards/interceptors have defined execution order — call out anywhere the current Express order doesn't map cleanly)
4. Whether this is an incremental migration (Nest wrapping the existing Express app during transition) or a full rewrite — recommend incremental for anything already in production

## Phase 3 — EXECUTE
- Scaffold Nest modules/controllers/services matching the plan
- Convert route handlers to controller methods, preserving exact HTTP method/path/status codes
- Convert middleware to the mapped Nest primitive (guard/interceptor/pipe/filter), preserving execution order via explicit `@UseGuards()`/global ordering
- Migrate DI-worthy singletons (DB clients, config) into Nest providers instead of leaving them as imported module-level constants
- Never change route paths, status codes, or response shapes as a side effect of restructuring — flag any accidental behavior change

## Verification checklist
- [ ] Every original route responds with the same method/path/status/shape
- [ ] Middleware execution order preserved (test with a request that hits every layer)
- [ ] Auth/guard behavior identical for both authorized and unauthorized requests
- [ ] Error handling produces the same error responses as before

## Security Rules (never violate)
- **No `curl | bash`** — Use only `npm install` / `npm uninstall` for package management.
- **No `eval`** — Never use `eval` or equivalent dynamic code execution.
- **No file operations outside project** — Never read, write, or modify files outside the project directory being migrated.
- **No secrets in output** — Never print env var values, DB credentials, or API keys in reports or logs.
- **Backup before destructive ops** — Always create a git commit or stash before modifying `package.json`, moving files, or rewriting routes.
- **Validate before write** — Validate `package.json` is valid JSON before editing. Validate TypeScript syntax before saving.
- **No silent dependency installs** — Tell the user which packages will be installed and get implicit confirmation before running `npm install`.
- **Never change API contract** — Route paths, HTTP methods, status codes, and response shapes must remain identical. Flag any accidental behavior change.
