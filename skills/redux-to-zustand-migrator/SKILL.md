---
name: redux-to-zustand-migrator
description: "Migrate from Redux (or Redux Toolkit) to Zustand or React Context. Triggers on: 'migrate from Redux to Zustand', 'Redux feels like too much boilerplate', 'simplify state management', actions/reducers/selectors being converted to a lighter state solution. Do NOT trigger if the user is migrating TO Redux, or has no existing Redux store."
---

# Redux → Zustand/Context Migrator

## Phase 1 — THINK
The trap in this migration is assuming Redux was "just boilerplate" — some of it was solving real problems (normalized state shape, memoized selectors, middleware-based side effects) that the new tool won't handle automatically.
- Inventory the store: which slices exist, and for each, whether it uses normalized data (entities keyed by ID) — this pattern needs to be deliberately preserved or consciously dropped, not lost by accident
- Identify any middleware in use (thunks, saga, custom logging/analytics middleware) — each needs an explicit new home (Zustand's setup functions, or component-level effects)
- Check for `reselect`-style memoized selectors — Zustand/Context don't give you this for free, and losing memoization silently can cause real performance regressions in a frequently-updating app
- Identify cross-slice logic (reducers/thunks that read from multiple slices) — this is the trickiest part to port since Zustand stores are more commonly siloed

## Phase 2 — PLAN
1. Store shape mapping: Redux slices → Zustand stores (one store or several, with reasoning)
2. Explicit plan for normalized data: keep it normalized, or flatten it — state which and why
3. Middleware → new-home mapping (thunk logic → async actions inside the Zustand store; saga-based side effects → explicit alternative, since sagas often encode non-trivial async coordination that needs real redesign, not a mechanical port)
4. Memoized selector → replacement plan (Zustand selectors + shallow equality checks, or `useMemo` at the call site)

## Phase 3 — EXECUTE
- Migrate slice by slice, not all at once, so each can be verified independently
- Preserve normalized shape and memoization per the plan — don't let either quietly disappear
- Port middleware logic to its planned new home, preserving side-effect ordering/timing where it mattered (e.g., analytics events firing at the same point in the flow)

## Verification checklist
- [ ] Cross-slice logic still produces correct results after being split across stores
- [ ] No performance regression from lost memoization (spot check re-render frequency)
- [ ] All async side effects (API calls, analytics) still fire at the same points in the flow

## Security Rules (never violate)
- **No `curl | bash`** — Use only `npm install` / `npm uninstall` for package management.
- **No `eval`** — Never use `eval` or equivalent dynamic code execution.
- **No file operations outside project** — Never read, write, or modify files outside the project directory.
- **No secrets in output** — Never print API keys, tokens, or credentials in reports or logs.
- **Backup before destructive ops** — Always create a git commit or stash before rewriting stores.
- **Validate before write** — Validate `package.json` is valid JSON before editing. Validate TypeScript compiles before declaring a store done.
- **No silent dependency installs** — Tell the user which packages will be installed and get implicit confirmation before running `npm install`.
- **Never drop normalized data or memoization silently** — These must be deliberately preserved or consciously dropped, not lost by accident.
