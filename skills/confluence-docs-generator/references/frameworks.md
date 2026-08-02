# Framework Reference — Route & API Extraction Guide

A quick-lookup table for where routes/controllers live and how to extract API
endpoints, organized by framework. Used by the confluence-docs-generator skill
during Step 3 (framework detection) and Step 4 (API surface extraction).

| Framework | Where routes/controllers live | Where schema/migrations live | Typical auth pattern | Notes for API extraction |
|---|---|---|---|---|
| **Express** | `routes/` or `src/routes/` — `router.get()`, `app.post()` | `models/` or `src/models/` — Mongoose/Sequelize schemas | JWT via `jsonwebtoken` middleware, passport.js | Look for `router.METHOD()` calls; controller functions are usually in separate files under `controllers/` |
| **NestJS** | `src/**/*.controller.ts` — `@Get()`, `@Post()` decorators | `src/**/*.entity.ts` or `prisma/schema.prisma` | `@UseGuards(AuthGuard())` decorator, passport | Controllers are classes with decorators; DTOs in separate `dto/` files |
| **FastAPI** | `app/routes/` or `app/api/` — `@router.get()`, `@app.post()` | `app/models/` or `app/schemas/` — SQLAlchemy + Pydantic | `Depends(get_current_user)` OAuth2/JWT | Pydantic models in `schemas.py` define request/response shapes; `app.openapi()` auto-generates OpenAPI |
| **Flask** | `app.py` or `app/routes.py` — `@app.route()` decorator | `app/models/` — SQLAlchemy models | `@login_required` decorator, flask-login | `methods=['GET','POST']` on the decorator; blueprints in `blueprints/` |
| **Django REST** | `urls.py` per app — `path()`, `router.register()` | `models.py` per app — Django ORM models | DRF's `IsAuthenticated`, token auth, JWT via `djangorestframework-simplejwt` | ViewSets in `views.py`; serializers in `serializers.py`; router in `urls.py` |
| **Laravel** | `routes/api.php`, `routes/web.php` — `Route::get()`, `Route::post()` | `database/migrations/` — PHP migration files | Laravel Sanctum (SPA), Passport (OAuth), JWT | Controllers in `app/Http/Controllers/`; `php artisan route:list` is authoritative |
| **Spring Boot** | `@RestController` classes — `@GetMapping`, `@PostMapping` | `src/main/resources/db/migration/` or `schema.sql` | Spring Security, `@PreAuthorize`, JWT, OAuth2 | `@RequestMapping` at class level sets a prefix; method-level annotations add the path |
| **Next.js** | `app/api/**/route.ts` — exported `GET()`, `POST()` functions | `prisma/schema.prisma` or `db/` | NextAuth.js, middleware.ts, JWT | File path IS the route path; `[param]` in filename = `:param` in route |
| **Ruby on Rails** | `config/routes.rb` — `resources :users`, `get '/login'` | `db/migrate/` — timestamped migration files | Devise gem, JWT via `devise-jwt`, CanCanCan | `resources :posts` generates 7 RESTful routes; `rails routes` is authoritative |
| **Go (generic)** | `handlers/` or `main.go` — `mux.HandleFunc()`, `gin.GET()` | `models/` or `migrations/` — varies by ORM | JWT middleware, OAuth2, API keys | No single convention; look for `mux`, `gin`, `echo`, `chi` router patterns |
