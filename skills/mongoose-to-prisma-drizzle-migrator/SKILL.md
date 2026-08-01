---
name: mongoose-to-prisma-drizzle-migrator
description: "Migrate from Mongoose/MongoDB schemas to Prisma or Drizzle. Triggers on: 'migrate from Mongoose to Prisma', 'convert Mongoose schemas', 'move off Mongoose', 'adopt Prisma' or 'adopt Drizzle' for an existing MongoDB-backed app. Do NOT trigger for brand-new Prisma/Drizzle projects with no existing Mongoose schema."
---

# Mongoose → Prisma/Drizzle Migrator

## Phase 1 — THINK
The danger here isn't schema syntax — it's that Mongoose's schema-less flexibility and population patterns behave fundamentally differently from Prisma/Drizzle's stricter, relational-leaning model, and a literal conversion can silently change app behavior.
- For every Mongoose schema, identify fields that are actually used with schema-less flexibility in practice (mixed types, optional fields added ad hoc at runtime) — these need an explicit typed decision, not an automatic guess
- Catalog every `.populate()` call and what it's really doing — some map cleanly to Prisma relations/Drizzle joins, but any populate used across collections with inconsistent foreign key integrity (common in schema-less Mongo apps) needs a real data-integrity pass before conversion, or the "relation" will fail on real data
- Check for multi-document transactions or the *lack* of them — Mongoose apps often rely on eventual consistency patterns that a relational move could either fix or break depending on how the app currently handles partial failures
- If staying on MongoDB with Prisma's Mongo connector vs. moving to Postgres/MySQL with Drizzle — these are very different migrations; don't conflate them

## Phase 2 — PLAN
1. Full schema mapping (Mongoose schema → Prisma/Drizzle schema), explicitly marking every field where the schema-less flexibility required a judgment call, and what call was made
2. `.populate()` → relation/join mapping, with any data-integrity risks flagged per Phase 1
3. Migration strategy for existing data: in-place transform script vs. dual-write transition period — recommend dual-write with verification for anything in active production use, not a single big cutover
4. Explicit call-out of any transaction/consistency behavior that will change

## Phase 3 — EXECUTE
- Write the target schema per the plan
- Write a data migration script that handles the schema-less edge cases explicitly found in Phase 1 (don't let a script silently drop or null-out fields it doesn't expect — fail loudly and report what didn't fit the new schema)
- If dual-write was chosen, implement it with a verification step comparing old/new reads before fully cutting over

## Verification checklist
- [ ] Every field with schema-less flexibility in the old data has a confirmed home (typed field, JSON column, or explicitly dropped with sign-off)
- [ ] All former populate() relationships resolve correctly on real (not just sample) data
- [ ] Migration script run against a full production data copy, not just a small sample, before cutover

## Security Rules (never violate)
- **No `curl | bash`** — Use only `npm install` / `npm uninstall` for package management.
- **No `eval`** — Never use `eval` or equivalent dynamic code execution.
- **No file operations outside project** — Never read, write, or modify files outside the project directory.
- **No secrets in output** — Never print database connection strings, API keys, or credentials in reports or logs.
- **Backup before destructive ops** — Always create a git commit or stash before modifying schemas. Always back up the database before running data migration scripts.
- **Validate before write** — Validate Prisma/Drizzle schema compiles. Validate migration script on a production data copy before cutover.
- **No silent dependency installs** — Tell the user which packages will be installed and get implicit confirmation before running `npm install`.
- **Never silently drop or null-out schema-less fields** — Every field that doesn't fit the new schema must be explicitly handled: typed field, JSON column, or dropped with sign-off. No silent data loss.
