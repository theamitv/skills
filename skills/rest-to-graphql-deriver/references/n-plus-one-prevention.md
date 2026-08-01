# N+1 Query Prevention Guide

## What Is the N+1 Problem?

A resolver fetches a list of N items, then for each item fires a separate query to fetch related data — resulting in 1 query for the list + N queries for the relations.

```
Query: { posts { author { name } } }

Without DataLoader:
  1 query: SELECT * FROM posts              → 100 posts
  100 queries: SELECT * FROM users WHERE id = ?  ← one per post!
  Total: 101 queries

With DataLoader:
  1 query: SELECT * FROM posts              → 100 posts
  1 query: SELECT * FROM users WHERE id IN (...)  ← batched!
  Total: 2 queries
```

## Where N+1 Happens in REST → GraphQL

### Pattern 1: One-to-Many (most common)

```graphql
type Query {
  posts: [Post!]!
}

type Post {
  id: ID!
  title: String!
  comments: [Comment!]!  # ← N+1 risk here
}
```

**REST equivalent**: `/posts` returns posts, then the client calls `/posts/:id/comments` for each one. In REST the N+1 is the client's problem. In GraphQL it becomes the server's problem.

### Pattern 2: Many-to-Many

```graphql
type User {
  id: ID!
  teams: [Team!]!  # ← N+1 risk via join table
}
```

### Pattern 3: Computed/derived fields

```graphql
type Order {
  id: ID!
  total: Float!       # computed from line items
  lineItems: [LineItem!]!  # ← N+1 risk if computed per order
}
```

## DataLoader Pattern

```js
// 1. Create a batch loading function
const batchUsers = async (ids) => {
  const users = await db.select('*').from('users').whereIn('id', ids);
  const map = {};
  users.forEach(u => { map[u.id] = u; });
  return ids.map(id => map[id] || null);  // preserve order
};

// 2. Create a DataLoader instance (one per request)
const userLoader = new DataLoader(batchUsers);

// 3. Use in resolvers
const resolvers = {
  Post: {
    author: (post, _, { loaders }) => loaders.users.load(post.authorId),
  },
};
```

## DataLoader Lifecycle

```js
// Middleware: create fresh loaders per request
app.use('/graphql', (req, res, next) => {
  req.loaders = {
    users: new DataLoader(batchUsers),
    comments: new DataLoader(batchComments),
    teams: new DataLoader(batchTeams),
  };
  next();
});

// Context: pass loaders to resolvers
const server = new ApolloServer({
  context: ({ req }) => ({ loaders: req.loaders }),
});
```

## Detecting N+1 in Practice

### Before deployment: query logging
```js
// Log every SQL query with a comment identifying the resolver
const queryCounter = { count: 0, queries: [] };
db.on('query', (q) => {
  queryCounter.count++;
  queryCounter.queries.push(q.sql);
});

// After running a GraphQL query:
console.log(`Queries executed: ${queryCounter.count}`);
// If count > expected (e.g., 2 for posts + authors), N+1 is happening
```

### In production: tracing
```js
// Apollo Studio tracing or OpenTelemetry spans
// Look for resolver spans with high call counts
```

## Common Anti-Patterns

### ❌ Naive per-item resolver
```js
const resolvers = {
  Post: {
    comments: async (post) => {
      return db.select('*').from('comments').where('post_id', post.id);
      // Called once per post — N+1!
    },
  },
};
```

### ✅ Batched resolver
```js
const resolvers = {
  Post: {
    comments: async (post, _, { loaders }) => {
      return loaders.comments.load(post.id);
      // Batched into WHERE post_id IN (...)
    },
  },
};
```

### ❌ Resolver that ignores DataLoader
```js
const resolvers = {
  Post: {
    comments: async (post, _, { loaders }) => {
      const all = await loaders.comments.loadMany([post.id]);
      return all[0];
      // Works but unnecessary — use .load() for single keys
    },
  },
};
```

## When DataLoader Isn't Enough

- **Pagination**: DataLoader batches by key, not by range. Use cursor-based pagination with dedicated batch functions.
- **Computed fields**: If a field requires processing all related items together (e.g., aggregations), batch at the parent resolver level, not the field level.
- **Cross-service dependencies**: If a resolver calls an external API, DataLoader can still batch HTTP requests with `dataloader-http` or similar.
