# Mongoose → Prisma/Drizzle Migrator

> Migrate from Mongoose/MongoDB schemas to Prisma or Drizzle without silently losing schema-less flexibility or breaking populate relationships.

Mongoose's schema-less flexibility and population patterns behave fundamentally differently from Prisma/Drizzle's stricter, relational-leaning model. A literal conversion silently drops fields, breaks relations, or changes transaction behavior. This skill handles the full migration — schema mapping, populate conversion, data migration, and dual-write cutover.

## What It Does

- **Three-Phase Process** — Catalog → Plan (with user approval) → Execute
- **Schema Mapping** — Every Mongoose schema field mapped to Prisma/Drizzle, with schema-less flexibility flagged
- **Populate Conversion** — `.populate()` calls mapped to relations/joins with data-integrity risk flags
- **Data Migration** — Handles schema-less edge cases explicitly; fails loudly on unexpected data
- **Dual-Write Strategy** — Recommends dual-write with verification for production apps
- **MongoDB or Relational** — Handles both Prisma's Mongo connector and full relational moves

## Quick Start

```bash
# Install
npx skills add theamitv/skills --skill mongoose-to-prisma-drizzle-migrator

# Use in Claude Code
/mongoose-to-prisma-drizzle-migrator Migrate from Mongoose to Prisma
```

## Structure

```
mongoose-to-prisma-drizzle-migrator/
├── SKILL.md                            # Skill metadata and instructions
├── README.md                           # This file
├── references/
│   ├── schema-mapping.md                   # Mongoose → Prisma/Drizzle schema mapping guide
│   └── data-migration.md                   # Data migration and dual-write strategy guide
├── examples/
│   └── usage.md                             # Usage examples
└── scripts/
    └── audit-mongoose-schemas.sh            # Mongoose schema audit scanner
```

## Verification Checklist

- [ ] Every field with schema-less flexibility in the old data has a confirmed home (typed field, JSON column, or explicitly dropped with sign-off)
- [ ] All former populate() relationships resolve correctly on real (not just sample) data
- [ ] Migration script run against a full production data copy, not just a small sample, before cutover

## License

MIT
