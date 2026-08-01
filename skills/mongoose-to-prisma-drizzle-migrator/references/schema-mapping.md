# Mongoose → Prisma/Drizzle Schema Mapping Guide

## Core Decision: MongoDB vs Relational

| Path | ORM | Database | Migration Complexity |
|------|-----|----------|---------------------|
| Stay on MongoDB | Prisma (MongoDB connector) | MongoDB | Low — schema only, no data migration |
| Move to Postgres | Prisma or Drizzle | PostgreSQL | High — schema + data + query rewrite |
| Move to MySQL | Prisma or Drizzle | MySQL | High — schema + data + query rewrite |
| Move to SQLite | Prisma or Drizzle | SQLite | Medium — good for small apps |

**If staying on MongoDB with Prisma**: Prisma's MongoDB connector supports embedded documents and relations, but does NOT support transactions across collections. This is a significant limitation if your app uses multi-document transactions.

## Mongoose Schema → Prisma Schema

### Basic Types

```prisma
// Mongoose
const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, unique: true },
  age: { type: Number, default: 0 },
  isActive: { type: Boolean, default: true },
  tags: [{ type: String }],
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});
```

```prisma
// Prisma (Postgres)
model User {
  id        String   @id @default(auto()) @map("_id") @db.ObjectId
  name      String
  email     String   @unique
  age       Int      @default(0)
  isActive  Boolean  @default(true)
  tags      String[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

```ts
// Drizzle (Postgres)
import { pgTable, text, integer, boolean, timestamp, uuid } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  name: text('name').notNull(),
  email: text('email').notNull().unique(),
  age: integer('age').default(0),
  isActive: boolean('is_active').default(true),
  tags: text('tags').array(),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow().$onUpdate(() => new Date()),
});
```

### Embedded Documents

```js
// Mongoose: embedded subdocument
const orderSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  items: [{
    productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
    quantity: { type: Number, required: true },
    price: { type: Number, required: true },
  }],
  total: { type: Number, required: true },
});
```

```prisma
// Prisma: separate model with relation
model Order {
  id        String       @id @default(auto()) @map("_id") @db.ObjectId
  userId    String       @db.ObjectId
  user      User         @relation(fields: [userId], references: [id])
  items     OrderItem[]
  total     Float
  createdAt DateTime     @default(now())
}

model OrderItem {
  id        String  @id @default(auto()) @map("_id") @db.ObjectId
  orderId   String  @db.ObjectId
  order     Order   @relation(fields: [orderId], references: [id])
  productId String  @db.ObjectId
  product   Product @relation(fields: [productId], references: [id])
  quantity  Int
  price     Float
}
```

### Mixed / Schema-Less Types

```js
// Mongoose: Mixed type — any structure allowed
const logSchema = new mongoose.Schema({
  event: { type: String, required: true },
  metadata: { type: mongoose.Schema.Types.Mixed },  // ← schema-less!
  timestamp: { type: Date, default: Date.now },
});
```

```prisma
// Prisma: Json type preserves flexibility
model Log {
  id        String   @id @default(auto()) @map("_id") @db.ObjectId
  event     String
  metadata  Json     // ← preserves arbitrary structure
  timestamp DateTime @default(now())
}
```

```ts
// Drizzle: jsonb column
import { jsonb } from 'drizzle-orm/pg-core';

export const logs = pgTable('logs', {
  id: uuid('id').defaultRandom().primaryKey(),
  event: text('event').notNull(),
  metadata: jsonb('metadata'),  // ← preserves arbitrary structure
  timestamp: timestamp('timestamp').defaultNow(),
});
```

## Mongoose → Prisma/Drizzle Type Mapping

| Mongoose Type | Prisma Type | Drizzle Type | Notes |
|--------------|-------------|--------------|-------|
| `String` | `String` | `text()` | |
| `Number` | `Int` / `Float` | `integer()` / `double()` | Prisma: use `Int` or `Float` |
| `Boolean` | `Boolean` | `boolean()` | |
| `Date` | `DateTime` | `timestamp()` | |
| `Buffer` | `Bytes` | `text()` (base64) | No direct binary type in Drizzle |
| `Mixed` | `Json` | `jsonb()` | Best option for schema-less fields |
| `ObjectId` | `String @db.ObjectId` | `text()` | Prisma needs `@db.ObjectId` for Mongo connector |
| `[String]` | `String[]` | `text().array()` | |
| `[Number]` | `Int[]` / `Float[]` | `integer().array()` / `double().array()` | |
| `[Mixed]` | `Json[]` | `jsonb().array()` | |
| `Schema.Types.Decimal128` | `Decimal` | `numeric()` | |
| `Map` | `Json` | `jsonb()` | |

## Populate → Relation Mapping

```js
// Mongoose: populate
const order = await Order.findById(id).populate('userId').populate('items.productId');
```

```prisma
// Prisma: include with relation
const order = await prisma.order.findUnique({
  where: { id },
  include: {
    user: true,
    items: { include: { product: true } },
  },
});
```

```ts
// Drizzle: join
const result = await db.query.orders.findFirst({
  where: eq(orders.id, id),
  with: {
    user: true,
    items: { with: { product: true } },
  },
});
```

## Data Integrity Risks with Populate

Mongoose's `.populate()` works even when the referenced document doesn't exist — it returns `null` for the populated field. Prisma/Drizzle relations enforce referential integrity by default.

```js
// Mongoose: this works even if userId references a deleted user
const order = await Order.findById(id).populate('userId');
// order.userId might be null — app handles it gracefully
```

```prisma
// Prisma: this throws if the user doesn't exist
const order = await prisma.order.findUnique({
  where: { id },
  include: { user: true },  // ❌ throws if user deleted
});
```

**Fix**: Use `@relation` with `onDelete: SetNull` or `onDelete: Cascade` in Prisma, or handle missing references in the migration script.
