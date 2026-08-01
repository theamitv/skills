---
name: js-to-ts-universal-migrator
description: "Migrate any JavaScript project to TypeScript — React, Angular, Vue, Node/Express backends, or vanilla JS. Triggers on: 'migrate to TypeScript', 'add types to my project', 'convert this to TS', typing a specific file/component/module, or pasting JS code asking for a 'TS version'. Do NOT trigger for projects already fully in TypeScript, or brand-new projects started directly in TypeScript."
---

# JS → TS Universal Migrator

## Phase 0 — IDENTIFY (before Phase 1 THINK)
Before analyzing anything, determine what kind of project this actually is, because the rest of this skill branches on it:
- **React** (CRA, Vite, Next.js)
- **Angular** (already TS-oriented in modern versions, but older AngularJS/Angular.js hybrid projects exist)
- **Vue** (2 or 3 — Options API vs. Composition API changes the typing story significantly)
- **Node/Express** or other backend-only JS
- **Vanilla JS** / bundler-agnostic library code

State which one this is, and if it's ambiguous (e.g., a monorepo with a Node backend and a React frontend), say so explicitly and treat them as two separate migrations with two separate plans — don't blend them into one config/plan, since their type needs and tsconfig settings diverge.

## Phase 1 — THINK
This is the same discipline as any migration in this pack: understand before touching.

**Common to all frameworks:**
- Identify the highest-leverage files to type first: shared utilities, API request/response shapes, and anything imported everywhere — these give the most downstream safety per file typed
- Identify highest-churn/highest-bug-history files (via git log) — these benefit most from type safety, independent of import count
- Check for existing JSDoc annotations — these often convert to TS types almost mechanically and represent free value
- Flag genuinely dynamic patterns that will resist typing cleanly: heavy `Object.keys`/spread-based dynamic object construction, `arguments` usage, runtime prototype manipulation, or objects whose shape depends on a string computed at runtime

**React-specific:**
- Identify prop-types usage (`PropTypes.shape(...)`) — these convert almost directly to TS interfaces/types and should be ported, not re-invented from scratch
- Check for `children` typing patterns, render-prop components, and higher-order components (HOCs) — HOCs are the single trickiest thing to type correctly in React+TS (generic constraints, prop merging) and deserve explicit attention rather than an `any` escape hatch
- Check whether hooks return tuples (`useState`-style) vs. objects — tuple returns need `as const` or explicit tuple typing or React will infer overly-wide union types
- Note the JSX file extension requirement (`.tsx` vs `.ts`) — files with JSX must be renamed, not just have types added

**Angular-specific:**
- Modern Angular is already TypeScript-first, so this case usually means either (a) an old AngularJS (1.x) project being modernized, or (b) a hybrid ngUpgrade project — identify which, since these are fundamentally different migrations (AngularJS→Angular is a framework migration, not just a typing pass, and should not be scoped as "just add TS")
- If it genuinely is Angular (2+) with stray `.js` files mixed in, check decorator usage (`@Component`, `@Injectable`) and constructor-based dependency injection — DI typing needs to match the injected service's actual interface, not just `any`, or Angular's compile-time DI checks lose their value

**Vue-specific:**
- Determine Options API vs. Composition API — Composition API (`<script setup lang="ts">`) has a much smoother TS story; Options API typing (especially `this` context inside methods/computed) is more error-prone and needs explicit `defineComponent()` wrapping, not just a file rename
- Check for mixins — these are notoriously hard to type correctly in Vue 2/Options API and often justify a Composition API refactor alongside the TS migration rather than fighting to type the mixin pattern as-is

**Node/backend-specific:**
- Check module system: CommonJS (`require`/`module.exports`) vs. ESM (`import`/`export`) — TypeScript's handling of these interacts with `tsconfig` module/moduleResolution settings, and picking the wrong combination is a very common source of confusing runtime-vs-compile-time errors
- Identify any dynamic `require()` calls (conditional requires, computed paths) — these need explicit handling since TS's static analysis doesn't reason about them well
- Check for callback-style APIs without Promise wrapping — decide whether to type them as-is or modernize to Promises/async-await during the same pass (recommend deciding explicitly, not doing both changes silently in one diff)

## Phase 2 — PLAN
Present before converting anything:
1. Confirmed project type(s) from Phase 0, with separate plans if it's a mixed monorepo
2. Prioritized file list with reasoning (leverage + churn/bug-history, not alphabetical)
3. `tsconfig.json` plan: start with `strict: false` and enumerate which specific flags (`noImplicitAny`, `strictNullChecks`, etc.) get turned on and in what order — full strict mode on day one is the most common reason these migrations stall halfway
4. Framework-specific calls: HOC typing approach (React), DI typing approach (Angular), Options-vs-Composition API decision (Vue), module system target (Node)
5. Where `any`/`// @ts-expect-error` will be deliberately used as a tracked placeholder, and how those will be tracked (issue list, TODO with ticket reference) so they don't silently become permanent
6. Build tool config changes needed (ts-loader/babel-preset-typescript for Webpack, Vite's built-in TS support, `ts-node`/`tsx` for Node scripts) — confirm this works before converting the first real file, not after

## Phase 3 — EXECUTE
- Convert file-by-file in the planned priority order, verifying the project still builds/runs after each file — never batch-convert the whole project in one pass
- Derive types from real runtime shapes (sample data, existing JSDoc, API contracts, prop-types) rather than defaulting to broad `any`/`object` types
- Apply the framework-specific patterns decided in Phase 2 (HOC generics, DI service typing, `defineComponent`, module system) consistently across files, not ad hoc per file
- Every deliberate `any`/`@ts-expect-error` gets a short inline comment explaining why it's deferred, matching the tracking plan from Phase 2 — never a silent suppression
- Do not change a file's public interface/exports as a side effect of typing it, unless explicitly asked — this is a typing pass, not a refactor, and mixing the two makes the diff unreviewable and the risk unclear

## Verification checklist (report status per item, not just "migration complete")
- [ ] Project builds and runs after each converted file, not just at the very end
- [ ] No new `any` types beyond what was explicitly planned as deferred and tracked
- [ ] Framework-specific typing verified: HOCs/props render correctly with no widened union types (React), DI resolves correctly at compile time (Angular), component props/emits are correctly typed (Vue), module resolution works in both dev and built output (Node)
- [ ] Existing test suite still passes after each converted file
- [ ] tsconfig strictness matches the agreed rollout plan — not accidentally full-strict or accidentally left permissive after the migration was declared "done"

## Security Rules (never violate)
- **No `curl | bash`** — Use only `npm install` / `npm uninstall` for package management.
- **No `eval`** — Never use `eval` or equivalent dynamic code execution.
- **No file operations outside project** — Never read, write, or modify files outside the project directory being migrated.
- **No secrets in output** — Never print API keys, tokens, or credentials in reports or logs.
- **Backup before destructive ops** — Always create a git commit or stash before renaming `.js` to `.ts`, modifying `package.json`, or rewriting imports.
- **Validate before write** — Validate `package.json` is valid JSON before editing. Validate TypeScript compiles before declaring a file done.
- **No silent dependency installs** — Tell the user which packages will be installed and get implicit confirmation before running `npm install`.
- **Never change public API surface** — Exported function signatures, class names, and module paths must remain identical during the typing pass.
