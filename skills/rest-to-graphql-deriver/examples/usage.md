# Usage Examples

## Full Schema Derivation

```
Derive a GraphQL schema from my REST API
Add GraphQL to my existing REST API
```

Triggers the full three-phase process: catalog → plan → execute.

## N+1 Concern

```
I'm worried about N+1 queries in my GraphQL resolvers
How do I prevent N+1 when adding GraphQL to my REST API?
```

The skill will focus on DataLoader setup and batched resolver patterns.

## Auth Preservation

```
Map my REST auth to GraphQL resolver-level auth
```

The skill will catalog every REST auth check and produce a mapping table.

## Gradual Rollout

```
Add GraphQL alongside my existing REST API
```

The skill will recommend an additive approach with a gateway or Apollo Server wrapping existing REST.

## Schema-First

```
Design a GraphQL schema based on my REST response shapes
```

The skill will derive type definitions from actual endpoint response shapes.

## DataLoader Setup

```
Set up DataLoader for my GraphQL resolvers
```

The skill will create DataLoader instances for each shared entity with batching and caching.

## Example Migration Output

### Phase 1 — Endpoint Catalog
```
This REST API has:
- 12 endpoints across 3 resource groups (users, posts, comments)
- 3 shared entities: User (appears in 5 endpoints), Post (appears in 4), Comment (appears in 3)
- 4 endpoints with N+1-prone patterns: /posts (loads author per post), /users/:id/feed (loads comments per post)
- 2 auth levels: user (authenticated), admin (elevated)
- No existing DataLoader infrastructure
```

### Phase 2 — Schema Plan
```
1. Types: User, Post, Comment, with nested relationships
2. N+1 risks:
   - Post.author → needs DataLoader for users
   - Post.comments → needs DataLoader for comments
   - User.posts → needs DataLoader for posts
3. Auth mapping:
   - /admin/* → @auth(role: "admin") directive on Query fields
   - /users/:id → resolver-level ownership check
   - /users/me → context-based user extraction
4. Recommendation: additive (GraphQL alongside REST via Apollo Server)
```

### Phase 3 — Verification
```
✅ Nested query (posts + authors + comments) executes 3 queries (not 1+N+M)
✅ Auth: admin-only fields return ForbiddenError for non-admin users
✅ Auth: ownership check prevents user A from accessing user B's data
✅ Schema types match production response shapes (spot-checked 5 endpoints)
```
