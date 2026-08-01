# Common CRA → Vite Breakage Points

## 1. SVG Imports

**CRA** supports SVG as React component natively:
```jsx
import { ReactComponent as Logo } from './logo.svg';
<Logo />
```

**Vite** requires `@svgr/rollup` plugin:
```js
// vite.config.js
import svgr from '@svgr/rollup';

export default {
  plugins: [react(), svgr()],
};
```

Then import as:
```jsx
import Logo from './logo.svg?react';
// or with svgr exportType: 'default':
import Logo from './logo.svg';
```

## 2. Absolute Imports

**CRA** uses `jsconfig.json` / `tsconfig.json` `baseUrl`:
```json
{
  "compilerOptions": {
    "baseUrl": "src"
  }
}
```
```jsx
import Button from 'components/Button'; // resolves to src/components/Button
```

**Vite** needs explicit alias in config:
```js
// vite.config.js
import path from 'path';

export default {
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
};
```
Then update imports to use the alias prefix.

## 3. CSS Modules

**CRA** supports `.module.css` out of the box — same in Vite. But:
- CRA allows global class name interpolation in module imports; Vite is stricter.
- If you use `composes:` in CSS Modules, ensure the source file path is correct post-migration.

## 4. process.env Polyfills

**CRA** polyfills `process.env` globally. **Vite does not**. Any code using `process.env.X` (outside of `import.meta.env`) will throw:

```js
// ❌ Breaks in Vite
const nodeEnv = process.env.NODE_ENV;

// ✅ Works in Vite
const mode = import.meta.env.MODE;
```

## 5. CRACO / react-app-rewired

CRACO overrides are webpack-specific. Each override must be mapped to a Vite/Rollup equivalent:

| CRACO Override | Vite Equivalent |
|----------------|-----------------|
| `webpack.config.module.rules` | `vite.config.js` `plugins` or `config.rollupOptions` |
| `webpack.config.resolve.alias` | `vite.config.js` `resolve.alias` |
| `webpack.config.plugins` | `vite.config.js` `plugins` (Vite/Rollup plugins) |
| `babel-loader` config | `@vitejs/plugin-react` handles Babel via `vite.react.babel` |
| `eslint-loader` / `eslint-webpack-plugin` | `vite-plugin-eslint` |
| `style-loader` / `css-loader` overrides | `vite.config.css` options |
| `file-loader` / `url-loader` | Vite's built-in asset handling (no plugin needed) |
| `DefinePlugin` | Vite's `define` config option |
| `HtmlWebpackPlugin` | Vite's built-in HTML handling (no plugin needed) |
| `CopyWebpackPlugin` | `vite-plugin-static-copy` |

## 6. TypeScript

**CRA** handles TS compilation via Babel. **Vite** uses esbuild for transpilation:
- Faster, but no type checking during build (run `tsc --noEmit` separately)
- Add `vite-env.d.ts` for `import.meta.env` types
- Ensure `tsconfig.json` has `"module": "ESNext"` and `"moduleResolution": "bundler"`

## 7. Test Configuration

**CRA** ships Jest with `react-scripts test`. Options:

| Approach | Pros | Cons |
|----------|------|------|
| **Migrate to Vitest** | Same API as Jest, Vite-native, faster | May need test file adjustments |
| **Keep Jest standalone** | Zero test changes | Jest won't use Vite's config; may need manual jest.config.js |

### Vitest migration:
```bash
npm install -D vitest @testing-library/jest-dom
```

```js
// vite.config.js
/// <reference types="vitest" />
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/setupTests.js',
  },
});
```

## 8. index.html Location

**CRA**: `public/index.html` with `%PUBLIC_URL%` templating.
**Vite**: `index.html` at project root with plain paths.

```diff
- <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
+ <link rel="icon" href="/favicon.ico" />
- <script src="/src/index.jsx"></script>  <!-- not in CRA -->
+ <script type="module" src="/src/index.jsx"></script>
```

## 9. Proxy

**CRA** `package.json`:
```json
{
  "proxy": "http://localhost:4000"
}
```

**Vite** `vite.config.js`:
```js
export default {
  server: {
    proxy: {
      '/api': 'http://localhost:4000',
    },
  },
};
```

## 10. Global Styles / CSS Imports

CRA allows importing CSS in JS files anywhere. Vite handles this too, but:
- `@import url('./fonts.css')` in CSS files works identically
- Importing CSS in `main.jsx` / `index.jsx` works identically
- PostCSS config (`.postcssrc` / `postcss.config.js`) works identically
