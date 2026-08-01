---
name: webpack-to-vite-config-translator
description: "Migrate Webpack configuration to Vite or Turbopack. Triggers on: 'migrate Webpack to Vite', 'translate webpack.config.js', 'build tool migration', loader/plugin names alongside a request to move to Vite or Turbopack. Do NOT trigger for CRA projects — use the dedicated CRA-to-Vite skill for those."
---

# Webpack → Vite/Turbopack Config Translator

## Phase 1 — THINK
Loaders and plugins are the whole risk surface here — some have clean Vite/Rollup equivalents, some don't exist yet, and guessing wrong produces a build that "works" but silently mishandles certain files.
- List every loader and plugin in the webpack config, and for each, classify it as:
  (a) has a known clean Vite equivalent, (b) has a partial/behavior-different equivalent, or (c) has no real equivalent and needs a workaround or a "keep on Webpack for this part" decision
- Pay special attention to CSS-in-JS setups, SVG loaders, and module federation — these are the most common "no clean equivalent" cases
- Check for webpack-specific features in use: `require.context`, dynamic `require()` with variables, or `DefinePlugin`-based global replacements — these need explicit rewrites, not just a config swap

## Phase 2 — PLAN
1. Full loader/plugin → Vite/Turbopack equivalent mapping table, explicitly marking any entries in category (b) or (c) from Phase 1
2. For every (c) entry, a proposed workaround or an explicit "this can't be ported automatically, here's what to do manually"
3. Migration order: config first and verified on a minimal build, then progressively re-enable each loader/plugin one at a time rather than a single big-bang swap

## Phase 3 — EXECUTE
- Write the new config incrementally per the plan, verifying the build after each loader/plugin is added back
- For `require.context`/dynamic requires, rewrite using Vite's `import.meta.glob` equivalent rather than leaving them broken
- Flag anything from category (c) directly in the code/config with a comment explaining what manual step is still needed — don't leave it silently half-migrated

## Verification checklist
- [ ] Build output is verified file-by-file against the old Webpack output for at least one non-trivial page (asset hashing, chunk splitting, CSS extraction all behave as expected)
- [ ] No loader/plugin silently dropped — every original one is either ported or explicitly called out as unported

## Security Rules (never violate)
- **No `curl | bash`** — Use only `npm install` / `npm uninstall` for package management.
- **No `eval`** — Never use `eval` or equivalent dynamic code execution.
- **No file operations outside project** — Never read, write, or modify files outside the project directory.
- **No secrets in output** — Never print API keys, tokens, or credentials in reports or logs.
- **Backup before destructive ops** — Always create a git commit or stash before modifying build config.
- **Validate before write** — Validate `vite.config.js` syntax before saving. Run the build after each incremental change.
- **No silent dependency installs** — Tell the user which packages will be installed and get implicit confirmation before running `npm install`.
- **Never guess on loaders/plugins with no equivalent** — Mark category (c) explicitly in the config with a comment. Don't leave them silently half-migrated.
