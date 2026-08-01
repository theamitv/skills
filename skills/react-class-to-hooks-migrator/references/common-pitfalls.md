# Common Class → Hooks Pitfalls

## 1. Stale Closures

The most common bug in hooks migration. A `useEffect` callback captures a value that's now out of date.

```jsx
// ❌ Stale closure
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCount(count + 1);  // ← count is always 0 (captured at mount)
    }, 1000);
    return () => clearInterval(interval);
  }, []);  // ← empty deps means count is never updated
}
```

```jsx
// ✅ Functional update
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCount(c => c + 1);  // ← functional update, no stale closure
    }, 1000);
    return () => clearInterval(interval);
  }, []);
}
```

```jsx
// ✅ Or add the dependency
function Counter({ step }) {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCount(c => c + step);  // ← step is in deps
    }, 1000);
    return () => clearInterval(interval);
  }, [step]);
}
```

## 2. Missing Dependencies

```jsx
// ❌ Missing dependency — ESLint exhaustive-deps would warn
function Profile({ userId }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, []);  // ← userId is missing from deps
}
```

```jsx
// ✅ Correct deps
function Profile({ userId }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);
}
```

## 3. Infinite Re-render Loops

```jsx
// ❌ Infinite loop — object/array in deps
function Search() {
  const [results, setResults] = useState([]);

  useEffect(() => {
    fetch('/search', { params: { q: query } }).then(setResults);
  }, [{ q: query }]);  // ← new object every render → infinite loop
}
```

```jsx
// ✅ Stable dependency
function Search() {
  const [results, setResults] = useState([]);

  useEffect(() => {
    fetch('/search', { params: { q: query } }).then(setResults);
  }, [query]);  // ← primitive value, stable reference
}
```

## 4. Function in Dependency Array

```jsx
// ❌ Function recreated every render
function List({ items }) {
  const handleClick = () => console.log(items.length);

  useEffect(() => {
    document.addEventListener('click', handleClick);
    return () => document.removeEventListener('click', handleClick);
  }, [handleClick]);  // ← new function every render → infinite loop
}
```

```jsx
// ✅ useCallback for stable reference
function List({ items }) {
  const handleClick = useCallback(() => {
    console.log(items.length);
  }, [items.length]);

  useEffect(() => {
    document.addEventListener('click', handleClick);
    return () => document.removeEventListener('click', handleClick);
  }, [handleClick]);
}
```

## 5. componentDidUpdate Timing

```jsx
// Class — runs after every render, can read DOM
class Logger extends React.Component {
  componentDidUpdate(prevProps) {
    if (prevProps.count !== this.props.count) {
      console.log('Count changed:', this.props.count);
      console.log('DOM height:', this.node.offsetHeight);
    }
  }
  render() { return <div ref={n => this.node = n}>{this.props.count}</div>; }
}
```

```jsx
// Hooks — useEffect also runs after paint
function Logger({ count }) {
  const nodeRef = useRef(null);

  useEffect(() => {
    console.log('Count changed:', count);
    console.log('DOM height:', nodeRef.current.offsetHeight);
  }, [count]);

  return <div ref={nodeRef}>{count}</div>;
}
```

**Note**: `useLayoutEffect` runs synchronously after DOM mutations but before paint — use it instead of `useEffect` if you need to read layout and prevent visual flicker (same timing as `componentDidUpdate`).

## 6. Multiple setState Calls in One Method

```jsx
// Class — batched
class Multi extends React.Component {
  handleClick = () => {
    this.setState({ a: 1 });
    this.setState({ b: 2 });
    // Both applied in one render
  };
}
```

```jsx
// Hooks — also batched in React 18+
function Multi() {
  const [a, setA] = useState(0);
  const [b, setB] = useState(0);

  const handleClick = () => {
    setA(1);
    setB(2);
    // Both applied in one render (React 18+)
  };
}
```

## 7. this.state Derived from Props

```jsx
// Class
class Derived extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      items: props.initialItems,
      filtered: props.initialItems.filter(/* ... */),
    };
  }
}
```

```jsx
// Hooks — useMemo for derived state
function Derived({ initialItems }) {
  const [items, setItems] = useState(initialItems);
  const filtered = useMemo(
    () => items.filter(/* ... */),
    [items]
  );
}
```

## 8. Refs to DOM Elements

```jsx
// Class
class Video extends React.Component {
  constructor() {
    this.videoRef = React.createRef();
  }
  play() {
    this.videoRef.current.play();
  }
  render() {
    return <video ref={this.videoRef} />;
  }
}
```

```jsx
// Hooks
function Video() {
  const videoRef = useRef(null);

  // useImperativeHandle if exposing to parent
  const play = () => videoRef.current?.play();

  return <video ref={videoRef} />;
}
```

## 9. Legacy Lifecycle: componentWillReceiveProps

```jsx
// Legacy class — called on every prop change before render
class Legacy extends React.Component {
  componentWillReceiveProps(nextProps) {
    if (nextProps.id !== this.props.id) {
      this.setState({ selected: nextProps.id });
    }
  }
}
```

```jsx
// Hooks — useEffect runs after render
function Legacy({ id }) {
  const [selected, setSelected] = useState(id);

  useEffect(() => {
    setSelected(id);
  }, [id]);
}
```

## 10. Legacy Lifecycle: componentWillMount

```jsx
// Legacy class — called before first render
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

## Quick Reference: ESLint exhaustive-deps

```json
{
  "rules": {
    "react-hooks/exhaustive-deps": "warn"
  }
}
```

**Never suppress this rule to make an effect "work"** — if the rule warns, either:
1. Add the missing dependency (most common fix)
2. Use a functional update (`setCount(c => c + 1)`) if the dep is only used in a setter
3. Use `useCallback`/`useMemo` if the dep is a function/object
4. Use `useRef` if you genuinely need a mutable value that shouldn't trigger re-runs
