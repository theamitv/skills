# Webpack → Vite/Turbopack Config Translator

> Migrate custom Webpack configurations to Vite or Turbopack, one loader/plugin at a time.

Loaders and plugins are the whole risk surface — some have clean Vite/Rollup equivalents, some don't exist yet, and guessing wrong produces a build that "works" but silently mishandles certain files. This skill classifies every loader/plugin, maps known equivalents, and flags anything that needs manual work.

## What It Does

- **Three-Phase Process** — Catalog → Plan (with user approval) → Execute
- **Loader/Plugin Classification** — Every entry classified as (a) clean equivalent, (b) partial equivalent, or (c) no equivalent
- **Incremental Migration** — Config first, then one loader/plugin at a time, verifying the build after each
- **Webpack-Specific Feature Rewrite** — `require.context` → `import.meta.glob`, `DefinePlugin` → Vite `define`, dynamic requires
- **Explicit Unported Flags** — Category (c) entries get inline comments explaining what manual step is still needed

## Quick Start

```bash
# Install
npx skills add theamitv/skills --skill webpack-to-vite-config-translator

# Use in Claude Code
/webpack-to-vite-config-translator Translate this webpack.config.js to Vite
```

## Structure

```
webpack-to-vite-config-translator/
├── SKILL.md                            # Skill metadata and instructions
├── README.md                           # This file
├── references/
│   ├── loader-plugin-mapping.md            # Webpack loader/plugin → Vite equivalent table
│   └── webpack-features.md                 # require.context, DefinePlugin, dynamic requires
├── examples/
│   └── usage.md                             # Usage examples
└── scripts/
    └── audit-webpack-config.sh              # Webpack config audit scanner
```

## Verification Checklist

- [ ] Build output verified file-by-file against old Webpack output (asset hashing, chunk splitting, CSS extraction)
- [ ] No loader/plugin silently dropped — every original one is either ported or explicitly called out as unported

## License

MIT
