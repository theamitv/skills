---
name: cra-to-vite-migrator
description: "Migrate Create React App (react-scripts) projects to Vite. Triggers on: 'migrate CRA to Vite', 'CRA is deprecated', 'speed up dev server', 'react-scripts', 'CRACO', 'craco.config.js', CRA build errors, 'why is my build so slow' on a CRA project. Do NOT trigger for greenfield Vite setups."
---

# CRA → Vite Migrator

## Phase 1 — THINK (do this before touching any file)
Before writing a single line, inspect the project and build a mental model:
- Read `package.json` fully: `react-scripts` version, all dependencies, and any CRACO/react-app-rewired overrides (these signal hidden webpack customizations that Vite won't replicate for free).
- Scan for `REACT_APP_` env vars across the codebase (not just `.env`) — every usage site needs updating, not just the `.env` file.
- Check for CSS Modules, SVG-as-component imports (`import { ReactComponent as X }`), and absolute imports via jsconfig/tsconfig `baseUrl` — these are the three most common CRA→Vite breakage points.
- Check for Jest config (CRA ships Jest by default) — decide now whether to migrate tests to Vitest or leave Jest running standalone, and say so explicitly to the user. Don't silently drop test coverage.
- Identify any `window`/`process.env` polyfills CRA silently provided that Vite does not.

Do not proceed to Phase 2 until you can summarize, in a few sentences, what's risky about *this specific* project's migration — not a generic CRA→Vite risk list.

## Phase 2 — PLAN (show this to the user, wait for go-ahead on anything destructive)
Produce a written migration plan covering:
1. New file tree (`vite.config.js/ts` location, `index.html` moved to root, entry point changes)
2. Every env var rename (`REACT_APP_FOO` → `VITE_FOO`), listed explicitly, not just "rename the prefix"
3. Every import that needs rewriting (SVG imports, absolute path imports, `%PUBLIC_URL%` references in `index.html`)
4. Whether tests move to Vitest or stay on Jest, and why
5. A rollback plan: keep the CRA setup on a branch/tag until the Vite build is verified in a real deploy, not just `vite build` succeeding locally

Never skip straight to editing files for a project with more than ~10 dependencies or any CRACO override — always show this plan first.

## Phase 3 — EXECUTE
- Install Vite + `@vitejs/plugin-react` via `npm install` (never `curl | bash` or `npx` with unknown packages), remove `react-scripts`
- Validate `package.json` is valid JSON before modifying it
- Move `public/index.html` to project root, strip CRA's `%PUBLIC_URL%` templating, add `<script type="module" src="/src/index.jsx">`
- Write `vite.config.js` mapping any CRACO webpack customizations found in Phase 1 to their Vite/Rollup equivalents — flag any that have no direct equivalent instead of guessing
- Rewrite all `REACT_APP_` references to `VITE_` and switch `process.env.X` to `import.meta.env.X`
- Update `package.json` scripts (`start`→`dev`, `build`, `preview`)
- Run the build and dev server; if either fails, report the *specific* error and which Phase 1 risk it maps to — don't just retry blindly

## Verification checklist (must report status of each, not just "done")
- [ ] Dev server starts and hot reload works
- [ ] Production build completes and `vite preview` renders the app correctly
- [ ] All env vars resolve correctly in build output
- [ ] SVG/asset imports render
- [ ] Test suite still runs (Jest or migrated Vitest)

## Security Rules (never violate these)
- **No `curl | bash`** — Never pipe downloaded content into a shell. Use only `npm install` / `npm uninstall` for package management.
- **No `eval`** — Never use `eval` or equivalent dynamic code execution.
- **No file operations outside project** — Never read, write, or modify files outside the project directory being migrated.
- **No secrets in output** — Never print env var values in reports or logs. Print only the variable *names*.
- **Backup before destructive ops** — Always create a git commit or stash before modifying `package.json`, moving `index.html`, or rewriting imports.
- **Validate before write** — Validate `package.json` is valid JSON before editing. Validate `vite.config.js` syntax before saving.
- **No silent dependency installs** — Tell the user which packages will be installed and get implicit confirmation before running `npm install`.
