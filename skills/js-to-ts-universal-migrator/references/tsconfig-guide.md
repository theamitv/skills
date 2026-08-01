# Incremental tsconfig Strictness Roadmap

## The Golden Rule

Start with `strict: false`. Turn on individual strict flags one at a time. This is the #1 reason JS→TS migrations stall — teams enable full strict mode day one and drown in errors.

## Recommended Strictness Phases

### Phase 0 — Minimal (day 1)
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "moduleResolution": "node",
    "esModuleInterop": true,
    "allowJs": true,
    "checkJs": false,
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": false,
    "skipLibCheck": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**Goal**: Get TypeScript compiling. `.js` files are allowed but not checked. Only `.ts` files get type-checked.

### Phase 1 — noImplicitAny
```json
{ "compilerOptions": { "noImplicitAny": true } }
```

**Goal**: Every function parameter and return value must have an explicit type or be inferable. This catches the most common class of bugs without being overwhelming.

**Typical error count**: 50–500 depending on codebase size.

### Phase 2 — strictNullChecks
```json
{ "compilerOptions": { "strictNullChecks": true } }
```

**Goal**: `null` and `undefined` are no longer assignable to every type. This catches the second most common class of bugs.

**Typical error count**: 100–1000+. This is the hardest phase — expect to add many `| null` / `| undefined` unions and optional chaining.

### Phase 3 — noUnusedLocals + noUnusedParameters
```json
{ "compilerOptions": { "noUnusedLocals": true, "noUnusedParameters": true } }
```

**Goal**: Dead code elimination. These are usually low-error-count flags that clean up the codebase.

### Phase 4 — strictFunctionTypes + strictBindCallApply
```json
{ "compilerOptions": { "strictFunctionTypes": true, "strictBindCallApply": true } }
```

**Goal**: Variance checking on function types. Usually low impact for most codebases.

### Phase 5 — Full strict
```json
{ "compilerOptions": { "strict": true } }
```

**Goal**: All strict flags enabled. By this point, you've already handled the hard ones individually.

## allowJs and checkJs Strategy

| Setting | Effect | When |
|---------|--------|------|
| `allowJs: true, checkJs: false` | `.js` files compile but aren't checked | Phase 0 — start here |
| `allowJs: true, checkJs: true` | `.js` files are type-checked too (uses JSDoc) | After most files are `.ts` |
| `allowJs: false` | Only `.ts` files allowed | After full migration |

## Framework-Specific tsconfig Notes

### React
```json
{
  "compilerOptions": {
    "jsx": "react-jsx",
    "jsxImportSource": "react"
  }
}
```
- `jsx: "react-jsx"` for React 17+ (automatic runtime). Use `"preserve"` if Babel handles JSX.
- Files with JSX must use `.tsx` extension.

### Vue
```json
{
  "compilerOptions": {
    "jsx": "preserve",
    "jsxImportSource": "vue"
  }
}
```
- Vue 3 + Vite handles TS natively. No extra loader config needed.
- Vue 2 + Webpack needs `vue-template-compiler` and `ts-loader` or `babel-preset-typescript`.

### Node/Express
```json
{
  "compilerOptions": {
    "module": "commonjs",
    "moduleResolution": "node",
    "esModuleInterop": true,
    "types": ["node"]
  }
}
```
- Use `@types/node` for Node.js built-in types.
- For ESM Node projects: `"module": "node16"` or `"module": "nodenext"`.

## Strict Flag Reference

| Flag | What It Does | Impact |
|------|-------------|--------|
| `noImplicitAny` | Error on inferred `any` | High |
| `strictNullChecks` | `null`/`undefined` not assignable to all types | Very High |
| `strictFunctionTypes` | Bivariant parameter types error | Low |
| `strictBindCallApply` | `bind`/`call`/`apply` type-checked | Low |
| `strictPropertyInitialization` | Class properties must be initialized | Medium |
| `noImplicitThis` | `this` must have implicit type | Medium |
| `alwaysStrict` | Emit `"use strict"` | Low |
| `noUnusedLocals` | Error on unused local variables | Medium |
| `noUnusedParameters` | Error on unused parameters | Medium |
| `exactOptionalPropertyTypes` | `?` properties can't be `undefined` | Low |
| `noImplicitReturns` | All paths must return a value | Medium |
| `noFallthroughCasesInSwitch` | Fallthrough in switch is an error | Low |
| `forceConsistentCasingInFileNames` | File import casing must match disk | Low |
