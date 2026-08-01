# Webpack Loader/Plugin → Vite/Turbopack Mapping

## Classification Key

- **(a)** Clean equivalent — behavior matches closely
- **(b)** Partial equivalent — works but behavior differs in edge cases
- **(c)** No real equivalent — needs workaround or manual redesign

## Loaders

| Webpack Loader | Vite Equivalent | Category | Notes |
|---------------|-----------------|----------|-------|
| `babel-loader` | `@vitejs/plugin-react` (JSX/TSX) or esbuild (TS) | (a) | Vite uses esbuild for TS, `@vitejs/plugin-react` for JSX. Custom Babel plugins need `vite.react.babel` config. |
| `ts-loader` | esbuild (built-in) | (a) | Vite transpiles TS with esbuild — no loader needed. Type checking requires separate `tsc --noEmit`. |
| `css-loader` + `style-loader` | Built-in CSS handling | (a) | Vite handles CSS imports natively. No loader needed. |
| `sass-loader` / `less-loader` | Built-in pre-processor support | (a) | Install `sass`/`less` package, Vite auto-detects. |
| `postcss-loader` | Built-in PostCSS support | (a) | Vite auto-detects `postcss.config.js`. |
| `file-loader` | Built-in asset handling | (a) | Vite handles images/fonts natively. Use `?url` import for file URL. |
| `url-loader` | Built-in asset inlining | (a) | Vite inlines assets < 4 KiB by default. Configure via `build.assetsInlineLimit`. |
| `svg-url-loader` | `?url` import suffix | (a) | `import url from './icon.svg?url'` |
| `@svgr/webpack` | `@svgr/rollup` plugin | (b) | Import syntax differs: `import Logo from './logo.svg?react'` |
| `raw-loader` | `?raw` import suffix | (a) | `import source from './file.txt?raw'` |
| `json-loader` | Built-in JSON support | (a) | Vite handles JSON imports natively. |
| `html-loader` | Built-in HTML handling | (a) | Vite handles HTML as entry point. |
| `markdown-loader` | Custom plugin or `?raw` + parse | (b) | No direct equivalent; use `?raw` and parse manually. |
| `graphql-loader` | `@graphql-tools/webpack-loader` via Vite plugin | (b) | Needs custom Vite plugin wrapping the loader. |
| `eslint-loader` | `vite-plugin-eslint` | (a) | Drop-in replacement. |
| `thread-loader` | Not needed | (a) | Vite's esbuild is already multi-threaded. |
| `cache-loader` | Not needed | (a) | Vite has built-in caching. |
| `i18n-loader` / custom string replace | Custom Vite plugin | (b) | Needs custom `transform` hook in Vite plugin. |
| `worker-loader` | Built-in worker support | (a) | `new Worker(new URL('./worker.js', import.meta.url))` |
| `istanbul-instrumenter-loader` | `vite-plugin-istanbul` | (a) | For code coverage. |

## Plugins

| Webpack Plugin | Vite Equivalent | Category | Notes |
|---------------|-----------------|----------|-------|
| `HtmlWebpackPlugin` | Built-in HTML handling | (a) | Vite uses `index.html` at root as entry. No plugin needed. |
| `MiniCssExtractPlugin` | Built-in CSS extraction | (a) | Vite extracts CSS automatically in production build. |
| `DefinePlugin` | Vite `define` config | (a) | `define: { __VERSION__: JSON.stringify('1.0.0') }` |
| `ProvidePlugin` | `@rollup/plugin-inject` | (b) | Different syntax; may need manual import additions. |
| `CopyWebpackPlugin` | `vite-plugin-static-copy` | (a) | Drop-in replacement. |
| `CleanWebpackPlugin` | Built-in | (a) | Vite cleans `outDir` automatically. |
| `ForkTsCheckerWebpackPlugin` | `fork-ts-checker-webpack-plugin` for Vite | (b) | Install and configure as Vite plugin. |
| `CaseSensitivePathsPlugin` | Not needed | (a) | Vite is case-sensitive by default. |
| `IgnorePlugin` | `build.rollupOptions.external` | (a) | Use Rollup's external option. |
| `ContextReplacementPlugin` | `resolve.alias` or custom plugin | (b) | Depends on specific use case. |
| `ModuleFederationPlugin` | `@originjs/vite-plugin-federation` | (c) | **No clean equivalent.** The Vite federation plugin exists but has different capabilities and limitations. Test thoroughly. |
| `BundleAnalyzerPlugin` | `vite-plugin-bundle-analyzer` or `rollup-plugin-visualizer` | (a) | Drop-in replacement. |
| `CompressionPlugin` | `vite-plugin-compression` | (a) | Drop-in replacement. |
| `InlineChunkHtmlPlugin` | `vite-plugin-singlefile` | (b) | For inlining all assets into HTML. |
| `ReactRefreshWebpackPlugin` | `@vitejs/plugin-react` includes HMR | (a) | Built into the React plugin. |
| `DotenvPlugin` | Built-in env var support | (a) | Vite loads `.env` files automatically. Use `VITE_` prefix. |
| `ProgressPlugin` | `vite-plugin-progress` | (a) | Drop-in replacement. |
| `WebpackManifestPlugin` | `vite-plugin-manifest` | (a) | For generating asset manifest. |
| `CircularDependencyPlugin` | `vite-plugin-circular-dependency` | (a) | Drop-in replacement. |
| `DuplicatePackageCheckerPlugin` | `vite-plugin-checker` | (b) | Partial equivalent. |

## CSS-in-JS Setups

| Library | Vite Support | Category | Notes |
|---------|-------------|----------|-------|
| Styled Components | `@vitejs/plugin-react` includes support | (a) | Works out of the box. |
| Emotion | `@emotion/babel-plugin` via `vite.react.babel` | (a) | Configure in `vite.config.js` under `react.babel`. |
| Linaria | `@linaria/vite` | (a) | Dedicated Vite plugin available. |
| CSS Modules | Built-in | (a) | Vite supports `.module.css` natively. |
| Vanilla Extract | `@vanilla-extract/vite-plugin` | (a) | Dedicated Vite plugin. |
| Stitches | No plugin needed | (a) | Runtime CSS-in-JS, works without build config. |
| Tailwind CSS | `@tailwindcss/vite` | (a) | Official Vite plugin available. |

## Module Federation

```js
// Webpack: ModuleFederationPlugin
new ModuleFederationPlugin({
  name: 'app1',
  remotes: { app2: 'app2@http://...' },
  shared: { react: { singleton: true } },
});
```

```js
// Vite: @originjs/vite-plugin-federation (category c — test thoroughly)
import federation from '@originjs/vite-plugin-federation';

export default {
  plugins: [
    federation({
      name: 'app1',
      remotes: { app2: 'http://.../assets/remoteEntry.js' },
      shared: ['react'],
    }),
  ],
};
```

**⚠️ Category (c)**: The Vite federation plugin has different capabilities and limitations. Test shared dependency resolution, singleton behavior, and fallback scenarios thoroughly before deploying.

## Config Structure Comparison

```js
// Webpack
module.exports = {
  entry: './src/index.js',
  output: { filename: 'bundle.js', path: './dist' },
  module: { rules: [ /* loaders */ ] },
  plugins: [ /* plugins */ ],
  resolve: { alias: { '@': './src' }, extensions: ['.js', '.jsx'] },
  devServer: { port: 3000, hot: true },
};
```

```js
// Vite
export default defineConfig({
  root: '.',
  build: { outDir: 'dist', rollupOptions: { input: './index.html' } },
  plugins: [react()],
  resolve: { alias: { '@': '/src' } },
  server: { port: 3000 },
});
```
