# Webpack-Specific Features and Their Vite Equivalents

## 1. require.context

Webpack's `require.context` creates a context module for bulk imports:

```js
// Webpack: require.context
const svgs = require.context('./icons', false, /\.svg$/);
svgs.keys().forEach(svgs);
```

```js
// Vite: import.meta.glob
const svgs = import.meta.glob('./icons/*.svg');

// Eager (synchronous, like require.context)
const svgs = import.meta.glob('./icons/*.svg', { eager: true });

// With import assertions
const modules = import.meta.glob('./locales/*.json', {
  eager: true,
  query: '?raw',
  import: 'default',
});
```

### Pattern Mapping

| Webpack | Vite |
|---------|------|
| `require.context('./dir', false, /pattern/)` | `import.meta.glob('./dir/*pattern', { eager: true })` |
| `require.context('./dir', true, /pattern/)` | `import.meta.glob('./dir/**/*pattern', { eager: true })` |
| `context(key)` | `modules[key]()` or `modules[key]` (eager) |
| `context.keys()` | `Object.keys(modules)` |

## 2. Dynamic require()

```js
// Webpack: dynamic require with variable
function loadModule(name) {
  return require(`./modules/${name}`);
}
```

```js
// Vite: import.meta.glob with computed key
const modules = import.meta.glob('./modules/*.js');

async function loadModule(name) {
  const path = `./modules/${name}.js`;
  if (modules[path]) {
    return await modules[path]();
  }
  throw new Error(`Module not found: ${name}`);
}
```

**Note**: Vite's `import.meta.glob` only supports static glob patterns, not fully dynamic paths. The glob must be a string literal — no variables in the pattern itself.

## 3. DefinePlugin

```js
// Webpack: DefinePlugin
new webpack.DefinePlugin({
  __VERSION__: JSON.stringify('1.0.0'),
  __DEV__: JSON.stringify(true),
  'process.env.API_URL': JSON.stringify('https://api.example.com'),
});
```

```js
// Vite: define config
export default defineConfig({
  define: {
    __VERSION__: JSON.stringify('1.0.0'),
    __DEV__: true,
    'process.env.API_URL': JSON.stringify('https://api.example.com'),
  },
});
```

**Note**: Vite's `define` performs simple global replacement during build. For env vars, prefer Vite's built-in `.env` file support with the `VITE_` prefix instead of `DefinePlugin`.

## 4. ProvidePlugin

```js
// Webpack: ProvidePlugin (auto-imports modules)
new webpack.ProvidePlugin({
  React: 'react',
  $: 'jquery',
  _: 'lodash',
});
```

```js
// Vite: @rollup/plugin-inject
import inject from '@rollup/plugin-inject';

export default defineConfig({
  plugins: [
    inject({
      React: 'react',
      $: 'jquery',
      _: 'lodash',
    }),
  ],
});
```

**Note**: Both approaches are considered an anti-pattern in modern codebases. Prefer explicit imports instead.

## 5. ContextReplacementPlugin

```js
// Webpack: ContextReplacementPlugin
new webpack.ContextReplacementPlugin(
  /moment[/\\]locale$/,
  /en|fr|es/
);
```

```js
// Vite: resolve.alias or manual import
// Option A: Use resolve.alias to limit locale imports
export default defineConfig({
  resolve: {
    alias: {
      'moment/locale': '/path/to/custom-locale-dir',
    },
  },
});

// Option B: Import only needed locales explicitly
import 'moment/locale/en';
import 'moment/locale/fr';
import 'moment/locale/es';
```

## 6. IgnorePlugin

```js
// Webpack: IgnorePlugin
new webpack.IgnorePlugin({ resourceRegExp: /^\.\/locale$/, contextRegExp: /moment$/ });
```

```js
// Vite: build.rollupOptions.external
export default defineConfig({
  build: {
    rollupOptions: {
      external: [/moment\/locale/],
    },
  },
});
```

## 7. Magic Comments (Code Splitting)

```js
// Webpack: dynamic import with magic comments
const Component = React.lazy(() => import(
  /* webpackChunkName: "admin" */
  /* webpackPrefetch: true */
  './Admin'
));
```

```js
// Vite: dynamic import (some magic comments supported)
const Component = React.lazy(() => import(
  /* vite: { chunkName: 'admin' } */
  './Admin'
));
```

**Note**: Vite supports `webpackChunkName` via Rollup's `output.chunkFileNames`. Prefetch/preload is handled differently — use `<link rel="modulepreload">` or Vite's built-in prefetching.

## 8. publicPath

```js
// Webpack
output: { publicPath: '/assets/' }
```

```js
// Vite
base: '/assets/'
```

## 9. DevServer Proxy

```js
// Webpack devServer
devServer: {
  proxy: {
    '/api': { target: 'http://localhost:4000', changeOrigin: true },
  },
}
```

```js
// Vite
server: {
  proxy: {
    '/api': { target: 'http://localhost:4000', changeOrigin: true },
  },
}
```

## 10. Source Maps

```js
// Webpack
devtool: 'source-map'
```

```js
// Vite
build: { sourcemap: true }
// Dev: always enabled
```

## 11. Resolve Aliases

```js
// Webpack
resolve: {
  alias: { '@': path.resolve(__dirname, 'src') },
  extensions: ['.js', '.jsx', '.ts', '.tsx'],
}
```

```js
// Vite
resolve: {
  alias: { '@': '/src' },
  // .js, .ts, .jsx, .tsx, .json resolved automatically
}
```

## 12. Multiple Entry Points

```js
// Webpack
entry: { main: './src/index.js', admin: './src/admin.js' },
output: { filename: '[name].[contenthash].js' },
```

```js
// Vite: use rollupOptions.input
export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        main: '/index.html',
        admin: '/admin.html',
      },
    },
  },
});
```

Each HTML file becomes an entry point with its own `<script type="module">` tag.
