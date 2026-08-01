# JS → TS Incremental Migrator

> Add TypeScript to an existing JavaScript codebase gradually, without a big-bang rewrite.

A full-codebase conversion produces giant unreviewable diffs and weeks of `any` soup. This skill takes an incremental approach: prioritize by leverage, type boundary code first, and let `.js` and `.ts` files coexist during the transition.

## What It Does

- **Three-Phase Process** — Analyze → Plan (with user approval) → Execute
- **Priority Analysis** — Identifies high-leverage files (most imported, most buggy) for typing first
- **Incremental Strictness** — Starts with `strict: false` and turns flags on one by one
- **JSDoc Harvesting** — Converts existing JSDoc annotations to TS types mechanically
- **Deferred Type Tracking** — Plans for `// @ts-expect-error` and `any` placeholders with a path to elimination

## Quick Start

```bash
# Install
npx skills add theamitv/skills --skill js-to-ts-incremental-migrator

# Use in Claude Code
/js-to-ts-incremental-migrator Add TypeScript to this project
```

## When It Won't Work

- **No JS codebase** — Designed for JavaScript-to-TypeScript migration. Greenfield TypeScript projects don't need this skill.
- **Heavy dynamic patterns** — Files with extensive `eval`, dynamic property access, or metaprogramming may need redesign before typing.
- **Third-party JS without types** — Libraries without TypeScript definitions may need manual `.d.ts` files or `@types/` packages.
- **Big-bang requirement** — If your team requires a single PR for the full migration, this incremental approach won't fit.
- **100% type safety guarantee** — Some `any` and `@ts-expect-error` are expected during incremental migration. Full strictness is a gradual process.

## Structure

```
js-to-ts-incremental-migrator/
├── SKILL.md                        # Skill metadata and instructions
├── README.md                       # This file
├── references/
│   ├── tsconfig-strictness.md          # Incremental strictness roadmap
│   └── common-patterns.md              # JS→TS pattern conversion guide
├── examples/
│   └── usage.md                         # Usage examples
└── scripts/
    └── audit-js-files.sh                # JS file audit scanner
```

## Verification Checklist

- [ ] Project still builds/runs after each converted file (not just at the end)
- [ ] No new `any` types beyond what was explicitly planned as deferred
- [ ] All deferred type gaps are tracked somewhere visible (issue list, TODO with ticket ref)

## License

MIT
