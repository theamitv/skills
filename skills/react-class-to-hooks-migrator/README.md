# Class → Hooks Migrator

> Convert React class components to functional components with hooks, one component at a time, without stale closures or infinite loops.

The real risk in this migration isn't syntax — `componentDidUpdate` and `useEffect` have fundamentally different mental models. A naive conversion silently introduces stale closures or infinite re-render loops. This skill handles the mapping carefully: lifecycle methods → `useEffect`, instance variables → `useRef`, state → `useState`/`useReducer`.

## What It Does

- **Three-Phase Process** — Analyze → Plan (with user approval) → Execute
- **Lifecycle Mapping** — Every lifecycle method gets a reasoned dependency array, not a blind "run every update"
- **Stale Closure Prevention** — Flags `componentDidUpdate` logic that needs careful dependency analysis
- **Instance Variable Detection** — Timers, subscriptions, and mutable refs map to `useRef`, not `useState`
- **One Component at a Time** — No batch find-and-replace; each component converted individually

## Quick Start

```bash
# Install
npx skills add theamitv/skills --skill react-class-to-hooks-migrator

# Use in Claude Code
/react-class-to-hooks-migrator Convert this class component to hooks
```

## Structure

```
react-class-to-hooks-migrator/
├── SKILL.md                        # Skill metadata and instructions
├── README.md                       # This file
├── references/
│   ├── lifecycle-mapping.md            # Lifecycle → useEffect mapping guide
│   └── common-pitfalls.md              # Stale closures, infinite loops, and other traps
├── examples/
│   └── usage.md                         # Usage examples
└── scripts/
    └── audit-class-components.sh        # Class component audit scanner
```

## Verification Checklist

- [ ] No stale-closure bugs (test with rapid state changes / interactions)
- [ ] No infinite re-render loops (check dependency arrays against actual `useEffect` body reads)
- [ ] Component's external prop API and rendered output unchanged

## License

MIT
