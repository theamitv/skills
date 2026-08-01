# Usage Examples

## Full Project Migration

```
Migrate this React app to TypeScript
Add TypeScript to this project
Convert this to TS
```

Triggers the full 4-phase process: identify → think → plan → execute.

## React-Specific

```
Convert this React app from JS to TypeScript
We use PropTypes everywhere — convert to TS interfaces
Type our HOCs properly
```

The skill will identify React, map PropTypes to interfaces, and handle HOC generics.

## Vue-Specific

```
Migrate this Vue 2 project to TypeScript
Add types to our Vue 3 Composition API components
```

The skill will determine Options vs. Composition API and apply `defineComponent` or `<script setup lang="ts">` patterns.

## Node/Express-Specific

```
Add TypeScript to our Express backend
Convert this Node.js project to TypeScript
```

The skill will check CommonJS vs. ESM, handle `require()` patterns, and set up `@types/node`.

## Angular-Specific

```
We have an old AngularJS project — add TypeScript
Type our Angular services properly
```

The skill will identify AngularJS vs. Angular 2+ and apply DI typing patterns.

## Vanilla JS / Library

```
Add types to this vanilla JS library
Convert this utility package to TypeScript
```

The skill will set up a minimal tsconfig and type the public API surface.

## Specific File or Component

```
Type the API client module
Convert src/components/UserCard.jsx to TypeScript
```

The skill will convert the specific file and update imports across the codebase.

## Incremental Strictness

```
Enable strict mode gradually
Turn on strictNullChecks
```

The skill will enable strictness flags one at a time and fix the resulting errors.

## Example Migration Output

### Phase 0 — Identify
```
Project type: React (CRA-based, no Vite)
Framework detected: React 18 with react-scripts 5
JS files: 47 .js/.jsx files across 6 directories
```

### Phase 1 — Priority Analysis
```
High-leverage files (imported by 10+ modules):
  - src/api/client.js (boundary code, 14 imports)
  - src/utils/helpers.js (shared utils, 11 imports)
  - src/config/index.js (zero deps, pure data shapes)

JSDoc candidates: 5 files with existing annotations
Dynamic patterns: src/utils/merge.js (spread construction), src/components/FormBuilder.jsx (dynamic keys)
Bug history: src/validation.js (12 bug-fix commits in last month)
```

### Phase 2 — Migration Plan
```
1. Priority order:
   - Phase A: config/index.js (zero deps, pure data shapes)
   - Phase B: api/client.js (boundary code, high leverage)
   - Phase C: utils/helpers.js (shared utils, JSDoc exists)
   - Phase D: validation.js (high bug rate, high value from types)
   - Phase E: remaining files
2. tsconfig: start with strict: false, enable noImplicitAny week 2
3. HOC approach: generic constraints with Omit<>
4. Deferred: FormBuilder.jsx (dynamic patterns need redesign)
5. Coexistence: allowJs: true, .js and .ts side by side
```

### Phase 3 — Verification
```
✅ Project compiles after converting config/index.js (0 errors)
✅ Project compiles after converting api/client.js (2 @ts-expect-error added, tracked in TODO.md)
✅ Project compiles after converting utils/helpers.js (JSDoc converted mechanically, 0 errors)
✅ No new any types beyond planned deferrals
✅ All 5 deferred type gaps tracked in ISSUES.md
✅ tsconfig strictness matches agreed plan (strict: false, noImplicitAny planned for week 2)
```
