---
name: rest-to-graphql-deriver
description: "Derive a GraphQL schema from existing REST endpoints. Triggers on: 'add GraphQL to my REST API', 'derive a GraphQL schema from my REST endpoints', 'REST to GraphQL transition', resolvers, schema-first GraphQL design from existing APIs, N+1 query concerns during migration. Do NOT trigger for GraphQL APIs built from scratch with no REST API to derive from."
---

# REST → GraphQL Schema Deriver

## Phase 1 — THINK
The dangerous part of this migration isn't schema syntax — it's the resolver layer silently introducing N+1 queries that don't show up until real traffic hits it.
- Catalog every REST endpoint: path, method, response shape, and — critically — what each endpoint does *underneath* (single query? multiple joins? N+1-prone loop?)
- Identify shared/nested entities across endpoints (e.g., both `/posts` and `/users/:id/posts` return post objects) — these become the core GraphQL types, and their resolvers are exactly where naive one-field-at-a-time resolution turns into N+1 queries at scale
- Check whether the existing data layer has batch-loading capability (DataLoader-style) or if that infrastructure doesn't exist yet — if it doesn't, say so before promising a performant schema

## Phase 2 — PLAN
1. Proposed GraphQL type definitions derived from the REST response shapes, with nested relationships explicitly mapped out
2. For every resolver that touches a "many" relationship, an explicit note: "this needs a DataLoader / batched query or it will N+1" — never leave this implicit
3. Whether this is additive (GraphQL layer alongside existing REST, common for gradual rollout) or a full replacement — recommend additive unless the user has a strong reason not to

## Phase 3 — EXECUTE
- Generate the schema (SDL or code-first, matching the project's existing conventions)
- Write resolvers using batched/DataLoader patterns for every one-to-many or many-to-many relationship flagged in Phase 1 — never write a naive per-item query resolver for these
- Preserve the same auth/permission checks the REST endpoints had, mapped to resolver-level or field-level auth as appropriate — don't accidentally loosen access control in translation

## Verification checklist
- [ ] Query a nested/relational field and confirm it doesn't produce N+1 queries (check actual query logs/count, not just correctness)
- [ ] Auth checks produce the same allow/deny behavior as the original REST endpoints
- [ ] Schema types match real response shapes, not idealized ones (spot-check against production data)

## Security Rules (never violate)
- **No `curl | bash`** — Use only `npm install` / `npm uninstall` for package management.
- **No `eval`** — Never use `eval` or equivalent dynamic code execution.
- **No file operations outside project** — Never read, write, or modify files outside the project directory.
- **No secrets in output** — Never print API keys, tokens, or credentials in reports or logs.
- **Backup before destructive ops** — Always create a git commit or stash before modifying `package.json` or rewriting resolvers.
- **Validate before write** — Validate `package.json` is valid JSON before editing. Validate SDL syntax before saving.
- **No silent dependency installs** — Tell the user which packages will be installed and get implicit confirmation before running `npm install`.
- **Never loosen access control** — Auth/permission checks from REST endpoints must be preserved exactly in the GraphQL layer.
