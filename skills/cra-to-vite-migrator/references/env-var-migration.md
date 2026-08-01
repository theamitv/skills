# Environment Variable Migration: REACT_APP_ → VITE_

## The Rule

| CRA | Vite |
|-----|------|
| `REACT_APP_FOO` | `VITE_FOO` |
| `process.env.REACT_APP_FOO` | `import.meta.env.VITE_FOO` |
| `process.env.NODE_ENV` | `import.meta.env.MODE` |
| `process.env.PUBLIC_URL` | `import.meta.env.BASE_URL` |

## What Changes

### 1. Prefix rename
All `REACT_APP_` env vars must be renamed to `VITE_`. Vite only exposes vars prefixed with `VITE_` to client code.

### 2. Access pattern
- CRA: `process.env.REACT_APP_API_URL`
- Vite: `import.meta.env.VITE_API_URL`

### 3. .env files
Rename keys in all `.env*` files (`.env`, `.env.development`, `.env.production`, `.env.local`):

```diff
- REACT_APP_API_URL=https://api.example.com
+ VITE_API_URL=https://api.example.com
```

### 4. Source code
Replace all occurrences:

```diff
- const apiUrl = process.env.REACT_APP_API_URL;
+ const apiUrl = import.meta.env.VITE_API_URL;
```

### 5. public/index.html
CRA's `%PUBLIC_URL%` becomes a relative path in Vite. Move `index.html` to project root and use:

```html
<link rel="icon" href="/favicon.ico" />
```

## What Stays the Same

- `.env` files remain in the project root
- `.env.local` is still git-ignored
- `.env.development` / `.env.production` still apply per mode

## What to Watch For

- **Runtime env vars**: CRA inlines `REACT_APP_` vars at build time. Vite does the same with `VITE_` vars. Neither supports runtime env injection out of the box — if you need runtime env vars in Vite, use `import.meta.env.VITE_*` with a `.env` file or a Vite plugin like `vite-plugin-environment`.
- **`process.env` references**: Any `process.env.X` that isn't `NODE_ENV` or `PUBLIC_URL` will throw at runtime. Vite does not polyfill `process.env`. Use `import.meta.env.X` instead.
- **TypeScript**: Add `VITE_` types to `vite-env.d.ts`:

```ts
/// <reference types="vite/client" />
interface ImportMetaEnv {
  readonly VITE_API_URL: string;
  readonly VITE_APP_TITLE: string;
}
interface ImportMeta {
  readonly env: ImportMetaEnv;
}
```
