---
name: js-to-ts-incremental-migrator
description: "Add TypeScript to an existing JavaScript codebase gradually. Triggers on: 'migrate to TypeScript', 'add types to my project', 'where to start typing a large JS codebase', converting specific files or 'the whole project' to TS. Do NOT trigger for brand-new TypeScript projects."
---

# JS → TS Incremental Migrator

## Phase 1 — THINK
A full-codebase big-bang conversion is almost always the wrong plan — it produces a giant unreviewable diff and weeks of `any` soup. Before proposing anything:
- Run a rough analysis: which files are imported most often (highest leverage for typing first), and which have the most git churn/bug history (highest value from type safety)
- Identify files that are pure boundary/interface code (API request/response shapes, shared utils) vs. files that are UI-heavy or highly dynamic — boundary code should be typed first since it gives the most downstream benefit
- Check for any existing JSDoc type annotations already in the codebase — these can often convert to TS types almost mechanically, saving real work
- Flag any dynamic patterns (heavy use of `Object.keys`/spread-based dynamic object construction, `arguments`, prototype hacking) that will resist typing and need a design decision, not just a type annotation

## Phase 2 — PLAN
Present, don't just start converting:
1. A prioritized file list (not "all files") with reasoning for the order
2. `tsconfig.json` strictness plan — recommend starting with `strict: false` and specific stricter flags turned on incrementally, not full strict mode day one (this is the #1 reason JS→TS migrations stall)
3. Where `// @ts-expect-error` or `any` will be deliberately used as a placeholder, and a plan to track/eliminate them later (e.g., a tracked list, not scattered forever)
4. How `.js` and `.ts` files will coexist during the transition (allowJs, checkJs settings)

## Phase 3 — EXECUTE
- Convert the highest-priority files first per the plan
- Derive types from actual runtime shapes (sample data, existing JSDoc, API contracts) rather than guessing broad types like `any`/`object`
- Add `// @ts-expect-error` with a short comment explaining *why*, for anything deliberately deferred — never silently suppress
- Keep each converted file's public interface (exports) unchanged unless explicitly asked to refactor — this is a typing pass, not a redesign

## Verification checklist
- [ ] Project still builds/runs after each converted file (not just at the end)
- [ ] No new `any` types beyond what was explicitly planned as deferred
- [ ] All deferred type gaps are tracked somewhere visible (issue list, TODO with ticket ref)

## Security Rules (never violate)
- **No `curl | bash`** — Use only `npm install` / `npm uninstall` for package management.
- **No `eval`** — Never use `eval` or equivalent dynamic code execution.
- **No file operations outside project** — Never read, write, or modify files outside the project directory being migrated.
- **No secrets in output** — Never print API keys, tokens, or credentials in reports or logs.
- **Backup before destructive ops** — Always create a git commit or stash before renaming `.js` to `.ts`, modifying `package.json`, or rewriting imports.
- **Validate before write** — Validate `package.json` is valid JSON before editing. Validate TypeScript compiles before declaring a file done.
- **No silent dependency installs** — Tell the user which packages will be installed and get implicit confirmation before running `npm install`.
- **Never change public API surface** — Exported function signatures, class names, and module paths must remain identical during the typing pass.
