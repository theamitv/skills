# Usage Examples

## Full Project Migration

```
Add TypeScript to this project
Migrate to TypeScript
Add types to my project
```

Triggers the full three-phase process: analyze → plan → execute.

## Where to Start

```
Where should I start typing this large JS codebase?
What files should I convert to TypeScript first?
```

The skill will run a priority analysis based on import frequency and git churn.

## Specific File Conversion

```
Convert this file to TypeScript
Add types to src/utils/api.js
```

The skill will convert the specific file and update imports across the codebase.

## JSDoc-Rich Codebase

```
We have JSDoc annotations everywhere — convert to TS
```

The skill will mechanically convert JSDoc types to TypeScript annotations.

## Incremental Approach

```
I want to do this incrementally, not all at once
Let .js and .ts files coexist during migration
```

The skill will set up `allowJs: true` and plan a phased strictness rollout.

## Strictness Tuning

```
Enable strict mode gradually
Turn on strictNullChecks for my project
```

The skill will enable strictness flags one at a time and fix the resulting errors.

## Example Migration Output

### Phase 1 — Priority Analysis
```
This codebase has:
- 47 .js files across 6 directories
- 3 high-leverage files (imported by 10+ other modules): api/client.js, utils/helpers.js, config/index.js
- 5 files with existing JSDoc annotations (mechanical conversion candidates)
- 2 files with heavy dynamic patterns (Object.keys, spread construction): utils/merge.js, components/FormBuilder.js
- 12 bug-related commits in the last month touching validation.js
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
3. Deferred: FormBuilder.js (dynamic patterns need redesign, not just types)
4. Coexistence: allowJs: true, .js and .ts side by side
```

### Phase 3 — Verification
```
✅ Project compiles after converting config/index.js (0 errors)
✅ Project compiles after converting api/client.js (2 @ts-expect-error added, tracked in TODO.md)
✅ Project compiles after converting utils/helpers.js (JSDoc converted mechanically, 0 errors)
✅ No new any types beyond planned deferrals
✅ All 5 deferred type gaps tracked in ISSUES.md
```
