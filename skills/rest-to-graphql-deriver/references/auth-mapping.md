# REST Auth → GraphQL Auth Mapping

## The Core Principle

Every auth check that existed in REST must exist in GraphQL. The translation is not always 1:1 — REST's route-level checks become resolver-level or field-level checks in GraphQL.

## Common REST Auth Patterns and Their GraphQL Equivalents

### 1. Route-Level Auth (Middleware)

```js
// REST: middleware checks auth for entire route
app.get('/admin/users', authenticate, authorize('admin'), getUsers);
```

```graphql
// GraphQL: resolver-level check
type Query {
  users: [User!]!   # ← @auth directive or resolver check
}
```

```js
// Option A: Directive-based
const schema = gql`
  directive @auth(role: String) on OBJECT | FIELD_DEFINITION

  type Query {
    users: [User!]! @auth(role: "admin")
  }
`;

// Option B: Resolver-based
const resolvers = {
  Query: {
    users: async (_, __, { user }) => {
      if (!user || user.role !== 'admin') {
        throw new ForbiddenError('Admin access required');
      }
      return getUsers();
    },
  },
};
```

### 2. Resource-Level Auth (ownership)

```js
// REST: check user owns the resource
app.get('/users/:id/profile', authenticate, async (req, res) => {
  if (req.user.id !== req.params.id && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }
  // ...
});
```

```graphql
// GraphQL: field-level or resolver-level check
type Query {
  user(id: ID!): User
}

const resolvers = {
  Query: {
    user: async (_, { id }, { user }) => {
      if (user.id !== id && user.role !== 'admin') {
        throw new ForbiddenError('Access denied');
      }
      return getUser(id);
    },
  },
};
```

### 3. Field-Level Auth (sensitive fields)

```js
// REST: different endpoints for different roles
app.get('/users/me', authenticate, getSelf);       // returns email, ssn
app.get('/users/:id', authenticate, authorize('admin'), getUser);  // no ssn
```

```graphql
// GraphQL: field-level auth
type User {
  id: ID!
  name: String!
  email: String    # ← only visible to self or admin
  ssn: String      # ← only visible to admin
}

const resolvers = {
  User: {
    email: async (parent, _, { user }) => {
      if (user.id !== parent.id && user.role !== 'admin') {
        return null;  // or throw
      }
      return parent.email;
    },
    ssn: async (parent, _, { user }) => {
      if (user.role !== 'admin') {
        return null;
      }
      return parent.ssn;
    },
  },
};
```

### 4. Query-Level Auth (filtered results)

```js
// REST: returns only the user's own data
app.get('/my-orders', authenticate, async (req, res) => {
  const orders = await db.select('*').from('orders').where('user_id', req.user.id);
  res.json(orders);
});
```

```graphql
// GraphQL: resolver filters based on context
type Query {
  orders: [Order!]!
}

const resolvers = {
  Query: {
    orders: async (_, __, { user }) => {
      return db.select('*').from('orders').where('user_id', user.id);
    },
  },
};
```

### 5. Mutation-Level Auth (write operations)

```js
// REST: auth on write endpoints
app.post('/posts', authenticate, async (req, res) => {
  // req.user.id is the author
  const post = await db('posts').insert({ ...req.body, author_id: req.user.id });
  res.status(201).json(post);
});
```

```graphql
// GraphQL: mutation resolver checks auth
type Mutation {
  createPost(input: CreatePostInput!): Post!
}

const resolvers = {
  Mutation: {
    createPost: async (_, { input }, { user }) => {
      if (!user) throw new AuthenticationError('Not authenticated');
      return db('posts').insert({ ...input, author_id: user.id }).returning('*');
    },
  },
};
```

## Auth Mapping Table

| REST Pattern | GraphQL Equivalent | Risk |
|-------------|-------------------|------|
| Route middleware (`app.use(authenticate)`) | Context-level check in schema | Low — applies to all resolvers |
| Route middleware (`app.use(authorize('admin'))`) | Resolver-level check or `@auth` directive | Medium — must be applied per resolver |
| Route param check (`req.params.id === req.user.id`) | Resolver-level ownership check | Medium — easy to miss in translation |
| Field filtering (different endpoints return different fields) | Field-level resolver checks | High — most commonly missed |
| Query filtering (user sees only their own data) | Resolver-level query filter | Medium — must replicate WHERE clause |
| Rate limiting | `graphql-rate-limit` or similar | Low — orthogonal concern |
| CSRF protection | CSRF token in GraphQL context | Low — handled at HTTP layer |

## Common Mistakes

### ❌ Missing field-level auth
```js
// REST: /admin/users returns SSN, /users/me does not
// GraphQL: both fields exposed without checks
const resolvers = {
  User: {
    ssn: (parent) => parent.ssn,  // ← visible to everyone!
  },
};
```

### ❌ Auth in the wrong resolver
```js
// REST: auth check on the endpoint
// GraphQL: auth check on the parent, not the nested resolver
const resolvers = {
  Query: {
    user: async (_, { id }, { user }) => {
      // Auth check here only covers the user query itself
      return getUser(id);
    },
  },
  User: {
    ssn: (parent) => parent.ssn,  // ← no auth check!
  },
};
```

### ❌ Loosening access in translation
```js
// REST: only admins can see /admin/stats
// GraphQL: stats field added to Query without auth
type Query {
  stats: Stats!  // ← no @auth directive, no resolver check
}
```
