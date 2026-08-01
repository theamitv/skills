# Middleware Migration: Redux → Zustand/Context

## Middleware Mapping Table

| Redux Middleware | Zustand Equivalent | Context Equivalent | Difficulty |
|-----------------|-------------------|-------------------|------------|
| `redux-thunk` | Async store method | Async function in context | Easy |
| `redux-saga` | Explicit redesign | Explicit redesign | Hard |
| `redux-observable` | Explicit redesign | Explicit redesign | Hard |
| Custom logging middleware | Zustand `subscribe` with logger | Component-level `useEffect` | Easy |
| Custom analytics middleware | Zustand `subscribe` with analytics | Component-level `useEffect` | Easy |
| `redux-persist` | `zustand/middleware` persist | `localStorage` in provider | Easy |
| `redux-devtools` | `zustand/middleware` devtools | N/A | Easy |
| `redux-api-middleware` | Async store method | Async function in context | Medium |

## Thunks → Async Store Methods

```js
// Redux: thunk
const fetchUser = (id) => async (dispatch) => {
  dispatch({ type: 'users/loading', payload: true });
  try {
    const user = await api.getUser(id);
    dispatch({ type: 'users/setUser', payload: user });
  } catch (err) {
    dispatch({ type: 'users/error', payload: err.message });
  } finally {
    dispatch({ type: 'users/loading', payload: false });
  }
};
```

```js
// Zustand: async store method
const useUserStore = create((set) => ({
  user: null,
  loading: false,
  error: null,

  fetchUser: async (id) => {
    set({ loading: true, error: null });
    try {
      const user = await api.getUser(id);
      set({ user, loading: false });
    } catch (err) {
      set({ error: err.message, loading: false });
    }
  },
}));
```

## Sagas → Explicit Redesign

Sagas encode complex async coordination (fork, race, takeLatest, debounce, channel) that has no direct equivalent in Zustand or Context.

```js
// Redux: saga
function* watchFetchUser() {
  yield takeLatest('FETCH_USER', function* (action) {
    try {
      const user = yield call(api.getUser, action.payload);
      yield put({ type: 'SET_USER', payload: user });
    } catch (err) {
      yield put({ type: 'SET_ERROR', payload: err.message });
    }
  });
}
```

```js
// Zustand: explicit alternatives for each saga pattern
const useUserStore = create((set) => ({
  user: null,
  error: null,

  // takeLatest → cancel previous promise
  fetchUser: (() => {
    let lastPromise = null;
    return async (id) => {
      const promise = api.getUser(id);
      lastPromise = promise;
      try {
        const user = await promise;
        if (promise === lastPromise) { // only set if still the latest
          set({ user, error: null });
        }
      } catch (err) {
        if (promise === lastPromise) {
          set({ error: err.message });
        }
      }
    };
  })(),

  // debounce → use debounce wrapper
  searchUsers: debounce(async (query) => {
    const results = await api.searchUsers(query);
    set({ searchResults: results });
  }, 300),

  // race → Promise.race
  fetchWithTimeout: async (id) => {
    const result = await Promise.race([
      api.getUser(id),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error('timeout')), 5000)
      ),
    ]);
    set({ user: result });
  },
}));
```

## Custom Logging Middleware

```js
// Redux: custom logging middleware
const loggerMiddleware = (store) => (next) => (action) => {
  console.log('dispatching', action);
  const result = next(action);
  console.log('next state', store.getState());
  return result;
};
```

```js
// Zustand: subscribe with logger
const useStore = create((set) => ({
  // ... state
}));

// Log every state change
useStore.subscribe((state, prevState) => {
  console.log('state changed', { prev: prevState, next: state });
});
```

## Analytics Middleware

```js
// Redux: analytics middleware
const analyticsMiddleware = (store) => (next) => (action) => {
  if (action.meta?.analytics) {
    analytics.track(action.meta.analytics.event, action.meta.analytics.props);
  }
  return next(action);
};
```

```js
// Zustand: subscribe with analytics
useStore.subscribe((state, prevState) => {
  if (state.user !== prevState.user && state.user) {
    analytics.track('user_logged_in', { userId: state.user.id });
  }
  if (state.orders.length !== prevState.orders.length) {
    analytics.track('order_count_changed', { count: state.orders.length });
  }
});
```

## Persist Middleware

```js
// Redux: redux-persist
const persistConfig = { key: 'root', storage };
const persistedReducer = persistReducer(persistConfig, rootReducer);
```

```js
// Zustand: built-in persist middleware
import { persist } from 'zustand/middleware';

const useStore = create(
  persist(
    (set) => ({
      user: null,
      token: null,
      setUser: (user) => set({ user }),
      setToken: (token) => set({ token }),
    }),
    {
      name: 'app-storage',
      partialize: (state) => ({ token: state.token }), // only persist token
    }
  )
);
```

## DevTools Middleware

```js
// Zustand: built-in devtools middleware
import { devtools } from 'zustand/middleware';

const useStore = create(
  devtools(
    (set) => ({
      // ... state and actions
    }),
    { name: 'MyStore' }
  )
);
```

## Side-Effect Ordering

When side-effect ordering matters (e.g., analytics must fire after state update):

```js
// Zustand: subscribe guarantees post-update
useStore.subscribe((state, prevState) => {
  // This runs AFTER the state has been updated
  // Same timing as Redux middleware's next(action) → log
  if (state.user !== prevState.user) {
    analytics.track('user_changed');
  }
});
```

For precise ordering within a single action:

```js
const useStore = create((set, get) => ({
  updateUser: async (userData) => {
    // 1. Update state
    set({ user: userData, saving: false });

    // 2. Side effect (runs after state update)
    analytics.track('user_updated', { userId: userData.id });

    // 3. Cross-store side effect
    const posts = usePostStore.getState();
    if (posts.items.some(p => p.userId === userData.id)) {
      // trigger post refresh
    }
  },
}));
```
