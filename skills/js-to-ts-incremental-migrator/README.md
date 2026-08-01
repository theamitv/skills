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
