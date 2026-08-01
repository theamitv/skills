# Usage Examples

## Full Migration

```
Migrate from Redux to Zustand
Simplify our state management — Redux is too much boilerplate
```

Triggers the full three-phase process: inventory → plan → execute.

## Redux Toolkit

```
Migrate from Redux Toolkit to Zustand
```

The skill will inventory RTK slices, `createAsyncThunk`, and `createEntityAdapter` usage.

## Saga-Heavy Codebase

```
We use redux-saga — migrate to Zustand
```

The skill will flag saga patterns (takeLatest, fork, race, debounce) that need explicit redesign.

## Normalized Data

```
We have normalized data with createEntityAdapter — migrate to Zustand
```

The skill will deliberately preserve the normalized shape in the Zustand store.

## Cross-Slice Logic

```
Our thunks read from multiple slices — how do we handle that in Zustand?
```

The skill will map cross-slice reads to `getState()` across multiple Zustand stores.

## Example Migration Output

### Phase 1 — Store Inventory
```
This Redux store has:
- 4 slices: users, posts, comments, auth
- 2 middleware: redux-thunk (API calls), custom analytics middleware
- 3 memoized selectors (reselect): selectUserPosts, selectPostComments, selectAuthUser
- 1 normalized entity: users (createEntityAdapter with ids/entities shape)
- 3 cross-slice thunks: fetchUserWithPosts, fetchPostWithComments, getDashboardData
```

### Phase 2 — Migration Plan
```
1. Store mapping:
   - users + posts + comments → single Zustand store (tightly coupled)
   - auth → separate Zustand store (independent, high churn)
2. Normalized data: KEEP normalized shape (ids/entities) in Zustand
3. Middleware:
   - thunks → async store methods inside Zustand
   - analytics → Zustand subscribe with analytics tracking
4. Memoized selectors:
   - selectUserPosts → useShallow in component
   - selectPostComments → useShallow in component
   - selectAuthUser → simple selector (no memo needed, single value)
5. Migration order: auth → users → posts → comments (least dependent first)
```

### Phase 3 — Verification
```
✅ Cross-slice logic: fetchUserWithPosts produces same results
✅ No re-render regression: auth store changes don't re-render user components
✅ Analytics events fire at same points in the flow
✅ Normalized shape preserved: ids/entities pattern intact
```
