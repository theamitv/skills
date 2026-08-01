# Lifecycle → useEffect Mapping Guide

## The Core Mental Model Shift

| Class Lifecycle | Hooks Equivalent | Key Difference |
|-----------------|-------------------|----------------|
| `constructor()` | `useState` + `useRef` initializers | No constructor needed; state and refs initialized at module level |
| `componentDidMount()` | `useEffect(() => { ... }, [])` | Empty dependency array = run once after mount |
| `componentDidUpdate(prevProps, prevState)` | `useEffect(() => { ... }, [deps])` | Dependency array replaces manual prev/current comparison |
| `componentWillUnmount()` | `useEffect(() => { return () => { ... } }, [])` | Cleanup function returned from effect |
| `shouldComponentUpdate()` | `React.memo()` | Wrapper, not an effect |
| `componentDidCatch()` | No direct equivalent | Use `ErrorBoundary` class component wrapper |
| `getDerivedStateFromProps()` | Derived state via `useMemo` or computed during render | Usually avoid; prefer computed values |
| `getSnapshotBeforeUpdate()` | No direct equivalent | Rare; use refs as workaround |

## componentDidMount → useEffect([], [])

```jsx
// Class
class Profile extends React.Component {
  componentDidMount() {
    this.fetchData(this.props.userId);
  }
  render() { /* ... */ }
}
```

```jsx
// Hooks
function Profile({ userId }) {
  useEffect(() => {
    fetchData(userId);
  }, []); // ⚠️ ESLint will warn: userId is missing from deps
  // ✅ Correct: fetchData(userId) — add userId to deps
}
```

**Correct version:**
```jsx
function Profile({ userId }) {
  useEffect(() => {
    fetchData(userId);
  }, [userId]);
}
```

## componentDidUpdate → useEffect([deps])

```jsx
// Class
class SearchResults extends React.Component {
  componentDidUpdate(prevProps) {
    if (prevProps.query !== this.props.query) {
      this.search(this.props.query);
    }
  }
}
```

```jsx
// Hooks
function SearchResults({ query }) {
  useEffect(() => {
    search(query);
  }, [query]); // ← dependency array replaces the if-check
}
```

## componentWillUnmount → useEffect Cleanup

```jsx
// Class
class Timer extends React.Component {
  componentDidMount() {
    this.interval = setInterval(this.tick, 1000);
  }
  componentWillUnmount() {
    clearInterval(this.interval);
  }
}
```

```jsx
// Hooks
function Timer() {
  useEffect(() => {
    const interval = setInterval(tick, 1000);
    return () => clearInterval(interval); // ← cleanup = componentWillUnmount
  }, []);
}
```

## Combined Mount + Unmount + Update

```jsx
// Class
class Subscription extends React.Component {
  componentDidMount() {
    subscribe(this.props.channel, this.handleMessage);
  }
  componentDidUpdate(prevProps) {
    if (prevProps.channel !== this.props.channel) {
      unsubscribe(prevProps.channel, this.handleMessage);
      subscribe(this.props.channel, this.handleMessage);
    }
  }
  componentWillUnmount() {
    unsubscribe(this.props.channel, this.handleMessage);
  }
}
```

```jsx
// Hooks
function Subscription({ channel }) {
  useEffect(() => {
    subscribe(channel, handleMessage);
    return () => unsubscribe(channel, handleMessage);
  }, [channel]); // ← re-runs when channel changes
}
```

## Multiple Effects for Separate Concerns

```jsx
// Class — all in one method
class Dashboard extends React.Component {
  componentDidMount() {
    this.fetchUser(this.props.userId);
    this.subscribeToUpdates();
    this.startPolling();
  }
  componentWillUnmount() {
    this.unsubscribeFromUpdates();
    this.stopPolling();
  }
}
```

```jsx
// Hooks — separate effects for separate concerns
function Dashboard({ userId }) {
  useEffect(() => {
    fetchUser(userId);
  }, [userId]);

  useEffect(() => {
    subscribeToUpdates();
    return unsubscribeFromUpdates;
  }, []);

  useEffect(() => {
    startPolling();
    return stopPolling;
  }, []);
}
```

## useState vs useReducer Decision

| Condition | Use |
|-----------|-----|
| 1–2 independent state values | `useState` |
| 3+ interdependent state values | `useReducer` |
| State logic involves complex transitions | `useReducer` |
| Next state depends on previous state | Either (both support functional updates) |
| State is a deeply nested object | `useReducer` or `useImmer` |

```jsx
// useState — simple
const [count, setCount] = useState(0);
const [name, setName] = useState('');

// useReducer — complex
const initialState = { items: [], loading: false, error: null };
function reducer(state, action) {
  switch (action.type) {
    case 'LOADING': return { ...state, loading: true, error: null };
    case 'SUCCESS': return { items: action.payload, loading: false };
    case 'ERROR': return { ...state, loading: false, error: action.payload };
    default: return state;
  }
}
const [state, dispatch] = useReducer(reducer, initialState);
```

## this.instance → useRef

```jsx
// Class
class VideoPlayer extends React.Component {
  constructor() {
    this.videoRef = React.createRef();
    this.interval = null;
  }
  componentDidMount() {
    this.interval = setInterval(this.tick, 1000);
  }
  componentWillUnmount() {
    clearInterval(this.interval);
  }
}
```

```jsx
// Hooks
function VideoPlayer() {
  const videoRef = useRef(null);
  const intervalRef = useRef(null);

  useEffect(() => {
    intervalRef.current = setInterval(tick, 1000);
    return () => clearInterval(intervalRef.current);
  }, []);
}
```

## Legacy Lifecycle Methods

### componentWillReceiveProps → getDerivedStateFromProps → avoid

```jsx
// Legacy class
class Legacy extends React.Component {
  componentWillReceiveProps(nextProps) {
    if (nextProps.id !== this.props.id) {
      this.setState({ selected: nextProps.id });
    }
  }
}
```

```jsx
// Hooks — compute during render instead
function Legacy({ id }) {
  const [selected, setSelected] = useState(id);

  useEffect(() => {
    setSelected(id);
  }, [id]);
}
```

### componentWillMount → constructor → not needed

```jsx
// Legacy class
class Legacy extends React.Component {
  componentWillMount() {
    this.setState({ data: this.props.initialData });
  }
}
```

```jsx
// Hooks — initialize state directly
function Legacy({ initialData }) {
  const [data, setData] = useState(initialData);
}
```
