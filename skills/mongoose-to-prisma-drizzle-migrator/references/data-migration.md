# Data Migration and Dual-Write Strategy Guide

## Migration Strategy Decision

| Strategy | When to Use | Risk | Effort |
|----------|-------------|------|--------|
| **In-place transform** | Dev/staging, small datasets, non-critical apps | High — no rollback if transform fails | Low |
| **Dual-write + verify** | Production apps, large datasets | Low — can roll back at any time | High |
| **Export/import** | One-time migration, static data | Medium — downtime required | Medium |

## Recommended: Dual-Write with Verification

### Phase 1 — Dual-Write (both systems active)

```
┌─────────┐     ┌──────────────┐     ┌──────────┐
│  App    │────▶│  Write to    │────▶│  Mongoose │
│  Code   │     │  Both ORMs   │     │  (Mongo)  │
│         │     │              │     └──────────┘
│         │     │              │     ┌──────────┐
│         │     │              │────▶│  Prisma   │
│         │     │              │     │  (New DB) │
└─────────┘     └──────────────┘     └──────────┘
```

```js
// Dual-write pattern
async function createUser(data) {
  // Write to both databases
  const mongoUser = await UserModel.create(data);
  const prismaUser = await prisma.user.create({ data });

  // Verify: compare the written data
  const verified = await verifyUser(mongoUser, prismaUser);
  if (!verified) {
    await rollbackCreate(prismaUser.id);
    throw new Error('Data mismatch during dual-write');
  }

  return prismaUser;
}
```

### Phase 2 — Read from New, Verify Against Old

```
┌─────────┐     ┌──────────────┐     ┌──────────┐
│  App    │────▶│  Read from   │────▶│  Prisma   │
│  Code   │     │  New ORM     │     │  (New DB) │
│         │     │              │     └──────────┘
│         │     │  Verify      │     ┌──────────┐
│         │     │  against old │────▶│  Mongoose │
│         │     │  (eventual)  │     │  (Old DB) │
└─────────┘     └──────────────┘     └──────────┘
```

### Phase 3 — Cutover (old system decommissioned)

```
┌─────────┐     ┌──────────────┐     ┌──────────┐
│  App    │────▶│  Read/Write  │────▶│  Prisma   │
│  Code   │     │  New Only    │     │  (New DB) │
└─────────┘     └──────────────┘     └──────────┘
```

## Data Migration Script Template

```js
// migrate-data.js
// Run against a production data COPY, not the live database

const mongoose = require('mongoose');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function migrateUsers() {
  const users = await mongoose.model('User').find().lean();
  const errors = [];

  for (const user of users) {
    try {
      // Handle schema-less fields explicitly
      const data = {
        id: user._id.toString(),
        name: user.name,
        email: user.email,
        age: user.age ?? 0,
        isActive: user.isActive ?? true,
        // Schema-less fields: put in JSON column or fail loudly
        metadata: user.metadata ?? {},
        preferences: user.preferences ?? {},
      };

      // Check for unexpected fields
      const expectedFields = ['_id', 'name', 'email', 'age', 'isActive',
        'metadata', 'preferences', '__v', 'createdAt', 'updatedAt'];
      const unexpected = Object.keys(user).filter(k => !expectedFields.includes(k));
      if (unexpected.length > 0) {
        errors.push({
          userId: user._id,
          type: 'unexpected_fields',
          fields: unexpected,
        });
        // Don't silently drop — include in metadata
        data.metadata.unexpectedFields = unexpected.reduce((acc, k) => {
          acc[k] = user[k];
          return acc;
        }, {});
      }

      await prisma.user.create({ data });
    } catch (err) {
      errors.push({ userId: user._id, type: 'error', message: err.message });
    }
  }

  // Report results
  console.log(`Migrated: ${users.length - errors.length}/${users.length}`);
  if (errors.length > 0) {
    console.error('Errors:', JSON.stringify(errors, null, 2));
    process.exit(1);  // Fail loudly — don't silently lose data
  }
}
```

## Schema-Less Field Handling Decision Matrix

| Pattern | Recommended Action | Example |
|---------|-------------------|---------|
| Field is always present with same type | Add as typed column | `user.profile` → typed JSON or separate model |
| Field varies by document | Use JSON column | `log.metadata` → `Json` / `jsonb` |
| Field is rarely used, no clear type | Drop with sign-off | Document and remove |
| Field is a runtime ad-hoc addition | Use JSON column | `user.customFields` → `Json` |
| Field references another collection | Create relation | `order.userId` → `@relation` |

## Rollback Plan

```markdown
## Rollback: Mongoose → Prisma Migration

### During dual-write phase:
1. Stop writing to Prisma (remove dual-write code)
2. Keep Mongoose as primary — no data loss
3. Drop Prisma database (no production data yet)

### After cutover (Phase 3):
1. Re-enable Mongoose writes (dual-write in reverse)
2. Run backfill script: Prisma → Mongoose
3. Verify data consistency
4. Decommission Prisma only after verification passes
```
