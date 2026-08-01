# Usage Examples

## Single Component Conversion

```
Convert this class component to hooks
Rewrite this class component with functional components
```

Triggers the full three-phase process: analyze → plan → execute for one component.

## Full Codebase Migration

```
Modernize all class components in this project
Convert all React class components to hooks
```

The skill will catalog every class component and convert them one at a time.

## Lifecycle-Specific

```
This component uses componentDidUpdate — convert to hooks
```

The skill will focus on the `componentDidUpdate` → `useEffect` mapping with careful dependency analysis.

## Legacy Lifecycle

```
This component has componentWillReceiveProps — rewrite with hooks
```

The skill will flag the legacy lifecycle and design a proper hooks-based replacement.

## Error-Driven

```
[Paste a class component with a bug]
```

The skill will diagnose whether the bug is related to lifecycle timing and propose a hooks rewrite.

## TypeScript Class Components

```
Convert this TypeScript class component to typed hooks
```

The skill will preserve TypeScript types and convert prop types to typed functional component patterns.

## Example Migration Output

### Phase 1 — Analysis
```
Component: UserProfile (class, 120 lines)
- State: userId, user, loading, error (4 values)
- Lifecycle methods: componentDidMount, componentDidUpdate, componentWillUnmount
- Instance variables: this.interval (polling timer), this.cancelToken (fetch abort)
- componentDidUpdate compares prevProps.userId to fetch new data
- No legacy lifecycle methods
```

### Phase 2 — Plan
```
1. State mapping:
   - userId → prop (no useState needed)
   - user → useState(null)
   - loading → useState(false)
   - error → useState(null)
   - Recommend: useReducer (3 interdependent values: user, loading, error)
2. Lifecycle mapping:
   - componentDidMount (fetch + start polling) → useEffect with [userId]
   - componentDidUpdate (re-fetch on userId change) → merged into same effect
   - componentWillUnmount (clear interval, abort fetch) → cleanup in same effect
3. Instance variables:
   - this.interval → useRef
   - this.cancelToken → useRef
4. No ambiguous behavior — clean conversion
```

### Phase 3 — Verification
```
✅ No stale closures (tested with rapid userId changes)
✅ No infinite re-render loops (dependency arrays verified against effect body reads)
✅ Rendered output identical (snapshot match)
✅ Prop API unchanged (TypeScript types match)
```
