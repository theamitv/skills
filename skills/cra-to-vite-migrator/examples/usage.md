# Usage Examples

## Basic Migration

```
Migrate this CRA project to Vite
```

Triggers the full three-phase process: inspect → plan → execute.

## Targeted Requests

```
CRA is deprecated, let's move to Vite
Speed up our dev server — it's too slow
Why is our build so slow?
```

## Error-Driven

```
[Paste a CRA build error here]
```

The skill will diagnose whether the error is a CRA limitation and propose migration.

## CRACO Projects

```
We use CRACO with custom webpack config — migrate to Vite
```

The skill will inspect the CRACO overrides and map each one to a Vite/Rollup equivalent.

## Test Migration

```
Migrate CRA to Vite and move tests to Vitest
```

The skill will install Vitest, configure it in `vite.config.js`, and update test imports.

## TypeScript & Absolute Imports

```
Migrate CRA to Vite with TypeScript and @/ imports
```

The skill will configure `resolve.alias` and `tsconfig.json` paths for absolute imports.

## Example Migration Output

### Phase 1 — Risk Summary
```
This project has:
- 3 REACT_APP_ env vars (API_URL, SENTRY_DSN, FEATURE_FLAGS)
- SVG-as-component imports in 12 files
- CRACO override adding a custom webpack loader for GraphQL files
- Jest tests (15 test files)
- jsconfig.json with baseUrl: "src" for absolute imports
```

### Phase 2 — Migration Plan
```
1. Move index.html to root, add module script tag
2. Rename REACT_APP_API_URL → VITE_API_URL (and 2 others)
3. Install @svgr/rollup for SVG components
4. Add resolve.alias for @/ → src/
5. Map CRACO GraphQL loader to @graphql-tools/webpack-loader via Vite plugin
6. Keep Jest (no migration to Vitest this round)
7. Tag current branch as pre-vite before any changes
```

### Phase 3 — Verification
```
✅ Dev server starts on port 5173, HMR works
✅ Production build completes (2.3s vs 18s before)
✅ Env vars resolve: VITE_API_URL = https://api.example.com
✅ SVG imports render correctly
✅ All 15 Jest tests pass
```
