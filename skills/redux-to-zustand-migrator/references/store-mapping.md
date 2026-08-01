# Redux → Zustand/Context Mapping Guide

## Core Concepts

| Redux Concept | Zustand Equivalent | Context Equivalent |
|---------------|-------------------|-------------------|
| Store | `create()` store | `React.createContext` + provider |
| Slice | Separate store or nested state | Separate context or nested state |
| Reducer | `set()` / `setState()` inside store | `useReducer` in provider |
| Action | Store method | Dispatch function |
| Action creator | Store method | Function that calls dispatch |
| Selector | Store selector function | `useContext` + optional `useMemo` |
| Memoized selector (reselect) | Zustand selector + `useShallow` | `useMemo` at call site |
| Middleware | Store `set`/`get` in action methods | Component-level effects |
| Thunk | Async store method | Async function in context |
| Saga | Explicit redesign needed | Explicit redesign needed |
| `combineReducers` | Nested stores or `create` with object | Multiple contexts or nested reducer |
| `createSlice` (RTK) | Manual store with actions | Manual reducer + actions |
| `configureStore` | `create()` | Provider setup |
| `Provider` | No provider needed (Zustand) | `Context.Provider` |

## Store Shape: One Store vs Several

### Zustand: One store

```js
// Redux: combined reducers
const store = configureStore({
  reducer: {
    users: usersReducer,
    posts: postsReducer,
    comments: commentsReducer,
  },
});
```

```js
// Zustand: single store with slices
const useStore = create((set, get) => ({
  users: { items: [], loading: false },
  posts: { items: [], loading: false },
  comments: { items: [], loading: false },

  fetchUsers: async () => { /* ... */ },
  fetchPosts: async () => { /* ... */ },
}));
```

**Use one store when**: slices are tightly coupled, cross-slice logic is common, or you want a single subscription point.

### Zustand: Multiple stores

```js
// Zustand: separate stores per domain
const useUserStore = create((set) => ({
  items: [], loading: false,
  fetchUsers: async () => { /* ... */ },
}));

const usePostStore = create((set, get) => ({
  items: [], loading: false,
  fetchPosts: async () => {
    const users = useUserStore.getState().items; // cross-store read
    // ...
  },
}));
```

**Use multiple stores when**: slices are independent, you want to minimize re-renders, or different teams own different slices.

## Normalized Data

```js
// Redux: normalized with createEntityAdapter
const usersAdapter = createEntityAdapter();
const initialState = usersAdapter.getInitialState();
// state = { ids: [1, 2], entities: { 1: { id: 1, name: 'Alice' }, ... } }
```

```js
// Zustand: preserve normalized shape
const useUserStore = create((set) => ({
  ids: [],
  entities: {},
  loading: false,

  setUsers: (users) => set({
    ids: users.map(u => u.id),
    entities: Object.fromEntries(users.map(u => [u.id, u])),
  }),

  getUserById: (id) => useUserStore.getState().entities[id],
}));
```

## Selectors and Memoization

```js
// Redux: reselect memoized selector
const selectUserPosts = createSelector(
  [selectUsers, selectPosts],
  (users, posts) => posts.filter(p => users.some(u => u.id === p.userId))
);
```

```js
// Zustand: selector with shallow equality
import { useShallow } from 'zustand/react/shallow';

// Option A: useShallow for object/array returns
const userPosts = useStore(
  useShallow((state) =>
    state.posts.filter(p => state.users.some(u => u.id === p.userId))
  )
);

// Option B: useMemo at call site
const userPosts = useMemo(
  () => posts.filter(p => users.some(u => u.id === p.userId)),
  [posts, users]
);
```

## Actions and Reducers

```js
// Redux Toolkit slice
const usersSlice = createSlice({
  name: 'users',
  initialState: { items: [], loading: false },
  reducers: {
    setUsers(state, action) {
      state.items = action.payload;
    },
    setLoading(state, action) {
      state.loading = action.payload;
    },
  },
});
```

```js
// Zustand: actions are store methods
const useUserStore = create((set) => ({
  items: [],
  loading: false,

  setUsers: (users) => set({ items: users }),
  setLoading: (loading) => set({ loading }),
}));
```

## Cross-Slice Logic

```js
// Redux: thunk reads from multiple slices
const fetchUserWithPosts = (userId) => async (dispatch, getState) => {
  const { auth } = getState();
  if (!auth.token) return;

  const user = await api.getUser(userId, auth.token);
  const posts = await api.getUserPosts(userId, auth.token);
  dispatch(setUser(user));
  dispatch(setPosts(posts));
};
```

```js
// Zustand: cross-store reads via getState()
const useStore = create((set, get) => ({
  // ... user and post state

  fetchUserWithPosts: async (userId) => {
    const token = useAuthStore.getState().token;
    if (!token) return;

    const user = await api.getUser(userId, token);
    const posts = await api.getUserPosts(userId, token);
    set({ user, posts });
  },
}));
```

## Context Alternative

For teams that prefer React Context over Zustand:

```js
// Context-based store
const UserContext = createContext();

function UserProvider({ children }) {
  const [state, dispatch] = useReducer(userReducer, initialState);
  const value = useMemo(() => ({ state, dispatch }), [state]);
  return <UserContext.Provider value={value}>{children}</UserContext.Provider>;
}

function useUsers() {
  const { state, dispatch } = useContext(UserContext);
  const setUsers = useCallback(
    (users) => dispatch({ type: 'SET_USERS', payload: users }),
    [dispatch]
  );
  return { users: state.items, setUsers };
}
```

**Use Context when**: the state changes infrequently, the component tree is shallow, or you want zero additional dependencies.

**Use Zustand when**: the state changes frequently, you need fine-grained re-render control, or you want to avoid provider nesting.
