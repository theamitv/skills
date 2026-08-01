# Redux → Zustand/Context Migrator

> Migrate from Redux (or Redux Toolkit) to Zustand or React Context without losing normalized data, memoization, or side-effect ordering.

The trap in this migration is assuming Redux was "just boilerplate" — normalized state shapes, memoized selectors, and middleware-based side effects were solving real problems. This skill inventories every slice, middleware, and selector before planning the migration.

## What It Does

- **Three-Phase Process** — Inventory → Plan (with user approval) → Execute
- **Store Inventory** — Maps every Redux slice, middleware, selector, and cross-slice dependency
- **Normalized Data Preservation** — Deliberately keeps or drops normalized shapes, never by accident
- **Memoization Plan** — Replaces `reselect` selectors with Zustand selectors + shallow equality or `useMemo`
- **Middleware Migration** — Maps thunks, sagas, and custom middleware to their new homes
- **Slice-by-Slice Migration** — Each slice migrated and verified independently

## Quick Start

```bash
# Install
npx skills add theamitv/skills --skill redux-to-zustand-migrator

# Use in Claude Code
/redux-to-zustand-migrator Migrate from Redux to Zustand
```

## When It Won't Work

- **No Redux store** — Designed for Redux-to-Zustand/Context migration. Greenfield state management doesn't need this skill.
- **Complex saga orchestrations** — Sagas with intricate `fork`/`race`/`spawn` patterns may need significant redesign. Simple `takeLatest`/`debounce` patterns map cleanly.
- **Redux DevTools-dependent debugging** — Zustand has DevTools support via middleware but the debugging experience differs from Redux DevTools.
- **Middleware-heavy stores** — Stores with 5+ custom middleware chains may need phased migration to avoid behavioral gaps.
- **Full behavioral parity** — Zustand and Redux have different subscription models. Verify re-render behavior in performance-critical components.

## Structure

```
redux-to-zustand-migrator/
├── SKILL.md                        # Skill metadata and instructions
├── README.md                       # This file
├── references/
│   ├── store-mapping.md                # Redux → Zustand/Context mapping guide
│   └── middleware-migration.md          # Thunks, sagas, and custom middleware migration
├── examples/
│   └── usage.md                         # Usage examples
└── scripts/
    └── audit-redux-store.sh             # Redux store audit scanner
```

## Verification Checklist

- [ ] Cross-slice logic still produces correct results after being split across stores
- [ ] No performance regression from lost memoization (spot check re-render frequency)
- [ ] All async side effects (API calls, analytics) still fire at the same points in the flow

## License

MIT
