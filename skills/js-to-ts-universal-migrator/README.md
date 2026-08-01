# JS → TS Universal Migrator

> Migrate any JavaScript project to TypeScript — React, Angular, Vue, Node/Express, or vanilla JS — without silent `any` soup or stalled migrations.

A framework-aware TypeScript migration skill. Unlike generic "add TS" guides, this skill identifies your project type first (React, Angular, Vue, Node, or vanilla JS) and applies framework-specific patterns for HOCs, DI, mixins, module systems, and more. It follows a disciplined 4-phase process: Identify → Think → Plan → Execute.

## What It Does

- **Phase 0 — Identify** — Determines the project type (React, Angular, Vue, Node, vanilla JS) and branches the migration strategy accordingly
- **Phase 1 — Think** — Analyzes leverage (import count, bug history), JSDoc harvest potential, and dynamic patterns that resist typing
- **Phase 2 — Plan** — Presents a prioritized file list, tsconfig strictness roadmap, framework-specific decisions, and deferred type tracking plan
- **Phase 3 — Execute** — Converts file-by-file in priority order, verifying the project builds after each file
- **Framework-Specific Patterns** — HOC generics (React), DI typing (Angular), `defineComponent` (Vue), module system handling (Node)
- **Incremental Strictness** — Starts with `strict: false` and turns flags on one by one

## Quick Start

```bash
# Install
npx skills add theamitv/skills --skill js-to-ts-universal-migrator

# Use in Claude Code
/js-to-ts-universal-migrator Migrate this React app to TypeScript
```

## When It Won't Work

- **No JS codebase** — Designed for JavaScript-to-TypeScript migration. Greenfield TypeScript projects don't need this skill.
- **AngularJS (1.x) modernization** — AngularJS→Angular is a framework migration, not just a typing pass. This skill handles typing, not framework replacement.
- **Heavy dynamic patterns** — Files with extensive `eval`, runtime prototype manipulation, or objects whose shape depends on a computed string may need redesign before typing.
- **Third-party JS without types** — Libraries without TypeScript definitions may need manual `.d.ts` files or `@types/` packages.
- **Big-bang requirement** — If your team requires a single PR for the full migration, this incremental approach won't fit.
- **100% type safety guarantee** — Some `any` and `@ts-expect-error` are expected during migration. Full strictness is a gradual process.

## Structure

```
js-to-ts-universal-migrator/
├── SKILL.md                        # Skill metadata and instructions
├── README.md                       # This file
├── references/
│   ├── tsconfig-guide.md               # Incremental strictness roadmap
│   └── framework-patterns.md            # Framework-specific typing patterns
├── examples/
│   └── usage.md                         # Usage examples
└── scripts/
    └── audit-js-project.sh              # JS project audit scanner
```

## Verification Checklist

- [ ] Project builds and runs after each converted file, not just at the very end
- [ ] No new `any` types beyond what was explicitly planned as deferred and tracked
- [ ] Framework-specific typing verified: HOCs/props render correctly (React), DI resolves at compile time (Angular), component props/emits typed (Vue), module resolution works (Node)
- [ ] Existing test suite still passes after each converted file
- [ ] tsconfig strictness matches the agreed rollout plan

## License

MIT
