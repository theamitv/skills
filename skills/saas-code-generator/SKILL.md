---
name: saas-code-generator
description: "Full SaaS code generator — from blueprint to working application. Generates full-stack code with auth, database, API, frontend, tests, and deployment config. Triggers on: 'generate code for', 'build the app', 'implement the blueprint', 'generate SaaS code', 'scaffold the project', 'generate frontend', 'generate backend', 'generate API', 'generate database schema', 'generate tests', 'generate Docker config', 'generate CI/CD'."
---

# SaaS Code Generator

Transform a product blueprint (from `saas-product-generator` or user description) into a complete, working full-stack application. Generates every file needed to run, test, and deploy a SaaS product.

## Quick Start

When the user says "generate code for [product]" or "build the app", run the **Code Generation Interview**:

1. **Blueprint source** — Do you have a blueprint from `saas-product-generator`, or should I design one first?
2. **Tech stack** — Frontend (Next.js, React, Vue), Backend (FastAPI, Express, Go Gin), Database (PostgreSQL, MongoDB, SQLite)
3. **Auth method** — JWT, OAuth (Google/GitHub), session-based, or passwordless?
4. **Deployment target** — Docker, Vercel, Railway, AWS, or self-hosted?
5. **Scope** — Full app or specific layer (frontend only, backend only, etc.)?

Present a **Generation Plan** for approval before writing any files.

## Generation Order

Always generate in this order, verifying each step before moving to the next:

1. **Scaffold** — Project structure, config files, package.json/requirements.txt, tsconfig, eslint, prettier
2. **Database** — Schema, models, migrations, seed data
3. **Backend** — Auth, middleware, routes/endpoints, services, error handling, validation
4. **Frontend** — Layout, pages, components, state management, API client, routing, forms
5. **Tests** — Unit tests, integration tests, e2e tests, test fixtures
6. **Deployment** — Dockerfile, docker-compose, CI/CD config, env templates, health checks
7. **Documentation** — README, API docs, setup instructions, architecture notes

## Quality Gates

Before marking a generation step complete:

- **Types** — TypeScript types or Pydantic models for all data structures
- **Validation** — Input validation on all API endpoints and forms
- **Error handling** — Every API route has try/catch, every async operation has error state
- **Auth** — Protected routes check auth; public routes are explicitly marked
- **Env vars** — All configuration is env-driven, not hardcoded
- **Tests** — At least one test per endpoint/component
- **Security** — No secrets in code, SQL injection protection, XSS prevention, rate limiting on auth routes

## Error States

| Scenario | Response |
|----------|----------|
| No blueprint provided | Run discovery interview to create one |
| Unsupported tech stack | Suggest the closest supported stack or explain the gap |
| Missing dependencies | Detect and suggest install commands |
| Conflicting requirements | Flag the conflict and ask for clarification |
| Partial generation requested | Generate only the requested layer with stubs for dependencies |

## Usage

```
Generate code for a gym management SaaS
Build the app from my SaaS blueprint
Implement the interview prep platform
Generate frontend for a CRM
Generate backend API with FastAPI
Generate database schema for a healthcare app
Generate Docker config for deployment
Generate tests for the payment module
```

## Structure

```
saas-code-generator/
├── SKILL.md
├── README.md
├── references/
│   ├── stacks.md         # Supported tech stacks
│   └── patterns.md       # Reusable code patterns
├── examples/
│   └── usage.md          # Usage examples
└── scripts/
    ├── scaffold.sh       # Project scaffold creator
    └── generate-env.sh   # Environment config generator
```
