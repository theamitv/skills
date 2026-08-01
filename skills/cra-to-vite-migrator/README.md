# CRA → Vite Migrator

> Migrate Create React App (react-scripts) projects to Vite with zero guesswork.

CRA is [deprecated](https://react.dev/blog/2022/03/08/react-18-upgrade-guide#create-react-app). Vite offers 10–20× faster dev server starts, instant HMR, native TypeScript support, and a modern build pipeline. This skill handles the full migration — env vars, SVG imports, CSS Modules, CRACO overrides, test config, and rollback planning.

## What It Does

- **Three-Phase Process** — Inspect → Plan (with user approval) → Execute
- **Comprehensive Scan** — Detects `REACT_APP_` env vars, SVG-as-component imports, CRACO overrides, CSS Modules, absolute imports, Jest config
- **Safe Migration** — Always produces a rollback plan; never edits without showing the plan first for complex projects
- **Verification** — Reports status of dev server, production build, env vars, asset imports, and test suite

## Quick Start

```bash
# Install
npx skills add theamitv/skills --skill cra-to-vite-migrator

# Use in Claude Code
/cra-to-vite-migrator Migrate this CRA project to Vite
```

## Structure

```
cra-to-vite-migrator/
├── SKILL.md              # Skill metadata and instructions
├── README.md             # This file
├── references/
│   ├── env-var-migration.md   # REACT_APP_ → VITE_ mapping guide
│   └── common-breakage.md     # Known CRA→Vite breakage points
├── examples/
│   └── usage.md               # Usage examples
└── scripts/
    └── migrate-env.sh         # Env var migration helper
```

## Migration Checklist

- [ ] Dev server starts and hot reload works
- [ ] Production build completes and `vite preview` renders correctly
- [ ] All env vars resolve correctly in build output
- [ ] SVG/asset imports render
- [ ] Test suite still runs (Jest or migrated Vitest)

## License

MIT
