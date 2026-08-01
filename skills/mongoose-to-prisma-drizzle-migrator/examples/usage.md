# Usage Examples

## Full Migration

```
Migrate from Mongoose to Prisma
Move off Mongoose to Drizzle
```

Triggers the full three-phase process: catalog → plan → execute.

## Stay on MongoDB

```
Migrate from Mongoose to Prisma but stay on MongoDB
```

The skill will use Prisma's MongoDB connector — schema mapping only, no data migration needed.

## Move to Postgres

```
Migrate from Mongoose/MongoDB to Prisma with Postgres
```

The skill will handle schema mapping, populate conversion, and data migration with dual-write strategy.

## Schema-Less Data

```
We have Mixed type fields everywhere — how do we handle that in Prisma?
```

The skill will flag every Mixed/ schema-less field and produce a decision for each.

## Populate-Heavy Codebase

```
We use .populate() extensively — will that work in Prisma?
```

The skill will catalog every populate call and flag data-integrity risks.

## Example Migration Output

### Phase 1 — Schema Catalog
```
This Mongoose codebase has:
- 6 Mongoose schemas: User, Order, Product, Category, Log, Setting
- 3 schemas with Mixed/ schema-less fields: Log.metadata, Setting.value, User.preferences
- 12 .populate() calls across 4 schemas
- 2 populate calls with potential data-integrity issues (referenced documents may not exist)
- 0 multi-document transactions (app uses eventual consistency)
- Decision: move to Postgres with Prisma (relational, full transaction support)
```

### Phase 2 — Migration Plan
```
1. Schema mapping:
   - User → Prisma User model (preferences → Json column)
   - Order → Prisma Order + OrderItem models (embedded → related)
   - Product → Prisma Product model (clean mapping)
   - Category → Prisma Category model (self-referencing for hierarchy)
   - Log → Prisma Log model (metadata → Json column)
   - Setting → Prisma Setting model (value → Json column)
2. Populate mapping:
   - Order.userId → @relation to User ✅
   - Order.items.productId → @relation to Product ✅
   - Product.categoryId → @relation to Category ✅
   - Log.userId → @relation to User ⚠️ (some logs reference deleted users — use onDelete: SetNull)
3. Migration strategy: dual-write with verification (production app)
4. Transaction behavior: will improve — Prisma supports transactions on Postgres
```

### Phase 3 — Verification
```
✅ All 6 schemas mapped with explicit decisions for schema-less fields
✅ All 12 populate calls mapped; 1 with onDelete: SetNull for deleted references
✅ Migration script run against production data copy: 99.8% success, 0.2% logged as warnings
✅ Dual-write active: 10,000+ records verified matching between old and new
```
