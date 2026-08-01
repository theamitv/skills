# Usage Examples

## Full Config Translation

```
Translate this webpack.config.js to Vite
Migrate our Webpack build to Vite
```

Triggers the full three-phase process: catalog → plan → execute.

## Loader/Plugin Specific

```
We use ModuleFederationPlugin — can we migrate to Vite?
How do I port our SVG loader setup to Vite?
```

The skill will classify the specific loader/plugin and provide the equivalent or workaround.

## Non-CRA Project

```
We have a custom Webpack setup (not CRA) — migrate to Vite
```

The skill will handle custom Webpack configurations with loaders, plugins, and resolve aliases.

## Turbopack

```
Migrate to Turbopack instead of Vite
```

The skill will note where Turbopack equivalents differ from Vite equivalents.

## Webpack Feature Migration

```
We use require.context everywhere — how do we handle that in Vite?
```

The skill will rewrite `require.context` calls to `import.meta.glob`.

## Example Migration Output

### Phase 1 — Loader/Plugin Catalog
```
This Webpack config has:
- 6 loaders: babel-loader, css-loader, sass-loader, file-loader, @svgr/webpack, eslint-loader
- 4 plugins: HtmlWebpackPlugin, MiniCssExtractPlugin, DefinePlugin, ModuleFederationPlugin
- 2 webpack features: require.context (3 uses), resolve.alias (@/ → src/)
- Classification:
  (a) babel-loader, css-loader, sass-loader, file-loader, eslint-loader, HtmlWebpackPlugin, MiniCssExtractPlugin, DefinePlugin
  (b) @svgr/webpack (import syntax differs)
  (c) ModuleFederationPlugin (no clean equivalent — test thoroughly)
```

### Phase 2 — Migration Plan
```
1. Base config: Vite + @vitejs/plugin-react
2. Loader migration order:
   - Step 1: Base Vite config (verify build)
   - Step 2: Add CSS/SASS support (built-in, verify)
   - Step 3: Add @svgr/rollup for SVGs (verify)
   - Step 4: Add vite-plugin-eslint (verify)
   - Step 5: Add vite-plugin-federation for module federation (verify, test thoroughly)
3. require.context → import.meta.glob (3 files)
4. resolve.alias → Vite resolve.alias
5. DefinePlugin → Vite define config
```

### Phase 3 — Verification
```
✅ Build output matches Webpack output (file-by-file comparison on main page)
✅ All 6 loaders ported or explicitly flagged
✅ ModuleFederationPlugin: ported with @originjs/vite-plugin-federation, shared deps tested
✅ require.context replaced with import.meta.glob in all 3 files
✅ CSS extraction, asset hashing, chunk splitting match expected output
```
