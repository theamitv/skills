# Supported Tech Stacks

## Frontend

### Next.js (React)

```
my-app/
├── app/                    # App Router pages
│   ├── layout.tsx
│   ├── page.tsx
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── register/page.tsx
│   └── (dashboard)/
│       └── page.tsx
├── components/
│   ├── ui/                 # Reusable UI components
│   ├── forms/              # Form components
│   └── layout/             # Layout components
├── lib/
│   ├── api-client.ts       # API client
│   ├── auth.ts             # Auth helpers
│   └── utils.ts            # Utility functions
├── types/
│   └── index.ts            # TypeScript types
├── public/
├── package.json
├── tsconfig.json
├── next.config.js
└── .env.local
```

**Key packages**: next, react, react-dom, typescript, tailwindcss, lucide-react, zod, react-hook-form

### React + Vite

```
my-app/
├── src/
│   ├── components/
│   ├── pages/
│   ├── hooks/
│   ├── lib/
│   ├── types/
│   ├── App.tsx
│   └── main.tsx
├── public/
├── package.json
├── tsconfig.json
├── vite.config.ts
└── .env
```

**Key packages**: react, react-dom, react-router-dom, typescript, tailwindcss, zustand, react-query, zod

### Vue 3 + Vite

```
my-app/
├── src/
│   ├── components/
│   ├── views/
│   ├── stores/
│   ├── composables/
│   ├── lib/
│   ├── router/
│   ├── App.vue
│   └── main.ts
├── public/
├── package.json
├── tsconfig.json
├── vite.config.ts
└── .env
```

**Key packages**: vue, vue-router, pinia, typescript, tailwindcss, zod

---

## Backend

### FastAPI (Python)

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # App entry point
│   ├── config.py            # Settings (pydantic-settings)
│   ├── database.py          # DB connection
│   ├── models/              # SQLAlchemy models
│   │   ├── __init__.py
│   │   └── user.py
│   ├── schemas/             # Pydantic schemas
│   │   ├── __init__.py
│   │   └── user.py
│   ├── api/
│   │   ├── __init__.py
│   │   ├── deps.py          # Dependencies (get_db, get_current_user)
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── auth.py
│   │       └── users.py
│   ├── services/            # Business logic
│   │   ├── __init__.py
│   │   └── auth.py
│   └── core/
│       ├── __init__.py
│       ├── security.py      # JWT, password hashing
│       └── exceptions.py    # Custom exceptions
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   └── test_auth.py
├── alembic/                 # Migrations
├── requirements.txt
├── Dockerfile
└── .env
```

**Key packages**: fastapi, uvicorn, sqlalchemy, alembic, pydantic, pydantic-settings, python-jose, passlib, httpx (tests)

### Express (Node.js)

```
backend/
├── src/
│   ├── index.ts             # Entry point
│   ├── config/
│   │   └── index.ts         # Environment config
│   ├── db/
│   │   ├── index.ts         # DB connection
│   │   └── migrations/
│   ├── models/
│   │   └── User.ts
│   ├── routes/
│   │   ├── auth.ts
│   │   └── users.ts
│   ├── middleware/
│   │   ├── auth.ts
│   │   ├── validate.ts
│   │   └── error.ts
│   ├── services/
│   │   └── auth.ts
│   └── types/
│       └── index.ts
├── tests/
│   ├── setup.ts
│   └── auth.test.ts
├── package.json
├── tsconfig.json
├── Dockerfile
└── .env
```

**Key packages**: express, typescript, prisma, zod, jsonwebtoken, bcryptjs, cors, helmet, jest, supertest

### Gin (Go)

```
backend/
├── cmd/
│   └── server/
│       └── main.go
├── internal/
│   ├── config/
│   │   └── config.go
│   ├── database/
│   │   └── database.go
│   ├── models/
│   │   └── user.go
│   ├── handlers/
│   │   ├── auth.go
│   │   └── user.go
│   ├── middleware/
│   │   ├── auth.go
│   │   └── cors.go
│   ├── services/
│   │   └── auth.go
│   └── repository/
│       └── user.go
├── migrations/
├── go.mod
├── go.sum
├── Dockerfile
└── .env
```

**Key packages**: gin, gorm, jwt-go, bcrypt, godotenv, viper, testify

---

## Database

### PostgreSQL

- **ORM**: SQLAlchemy (Python), Prisma (Node.js), GORM (Go)
- **Migrations**: Alembic (Python), Prisma Migrate (Node.js), golang-migrate (Go)
- **Connection**: Connection pooling with pgBouncer for production
- **Testing**: In-memory or testcontainers

### MongoDB

- **ODM**: Beanie/MongoEngine (Python), Mongoose (Node.js), mongo-go-driver (Go)
- **Migrations**: migrate-mongo (Node.js)
- **Connection**: Replica set required for transactions

### SQLite

- **ORM**: SQLAlchemy (Python), Prisma (Node.IO)
- **Best for**: Development, single-server deployments, embedded use cases
- **Limitation**: No concurrent writes, no replication

---

## Auth Patterns

| Method | Implementation |
|--------|---------------|
| **JWT** | Access token (15min) + Refresh token (7d). Store refresh in httpOnly cookie. |
| **OAuth** | Google/GitHub OAuth 2.0. State param for CSRF. Redirect to /api/auth/{provider}. |
| **Session** | Server-side session store (Redis/DB). httpOnly cookie with session ID. |
| **Passwordless** | Magic link via email. One-time code via SMS. Expire after 15min. |

---

## Testing Setup

| Layer | Tool | Config |
|-------|------|--------|
| Python backend | pytest + httpx | `pytest.ini` with `asyncio_mode = auto` |
| Node.js backend | jest + supertest | `jest.config.ts` with `ts-jest` |
| Go backend | testify + httptest | Standard Go test files |
| React/Next.js | vitest + testing-library | `vitest.config.ts` with jsdom |
| Vue | vitest + @vue/test-utils | `vitest.config.ts` with jsdom |
| E2E | Playwright | `playwright.config.ts` |
