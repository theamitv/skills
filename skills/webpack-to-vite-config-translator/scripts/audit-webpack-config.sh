#!/usr/bin/env bash
# Webpack → Vite Config Translator - Webpack Config Audit Scanner
# Usage: ./audit-webpack-config.sh [project-directory]
# Scans webpack configuration files and generates a migration audit report.
# Safe: read-only, no file modifications. Input-validated, injection-safe.

set -euo pipefail

PROJECT_DIR="${1:-}"
REPORT_FILE="webpack-config-audit.md"

usage() {
  echo "Usage: $0 <project-directory>"
  echo "Scans webpack configuration files and generates a migration audit report."
  echo "Example: $0 /path/to/my-project"
  exit 1
}

# Validate: directory argument is required
[ -n "$PROJECT_DIR" ] || usage

# Validate: directory exists and is readable
[ -d "$PROJECT_DIR" ] || { echo "Error: directory not found: $PROJECT_DIR"; exit 1; }
[ -r "$PROJECT_DIR" ] || { echo "Error: directory not readable: $PROJECT_DIR"; exit 1; }

# Validate: no path traversal
case "$PROJECT_DIR" in
  *"/../"*|*"/.." ) echo "Error: path traversal detected in: $PROJECT_DIR"; exit 1 ;;
esac

# Resolve to absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd -P)" || { echo "Error: cannot resolve path: $PROJECT_DIR"; exit 1; }

echo "🔍 Scanning Webpack configuration in: $PROJECT_DIR"
echo ""

# Find webpack config files
WEBPACK_CONFIGS=$(
  find "$PROJECT_DIR" -maxdepth 2 -type f \( \
    -name 'webpack.config.*' -o \
    -name 'webpack.*.config.*' -o \
    -name '*.webpack.config.*' -o \
    -name 'craco.config.*' -o \
    -name 'react-app-rewired*' \
  \) -not -path '*/node_modules/*' 2>/dev/null || true
)

if [ -z "$WEBPACK_CONFIGS" ]; then
  echo "⚠️  No webpack configuration files found."
  echo "   (Searching broader for webpack references in JS/TS files...)"
  WEBPACK_REF=$(
    find "$PROJECT_DIR" -type f \( -name '*.js' -o -name '*.ts' \) \
      -not -path '*/node_modules/*' \
      -not -path '*/dist/*' \
      -not -path '*/build/*' \
      -not -path '*/.git/*' \
      2>/dev/null | head -1 || true
  )
  if [ -n "$WEBPACK_REF" ]; then
    echo "   Checking for webpack references in source files..."
  fi
fi

echo ""

# Find JS/TS source files for broader scanning
SOURCE_FILES=$(
  find "$PROJECT_DIR" -type f \( -name '*.js' -o -name '*.ts' \) \
    -not -path '*/node_modules/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' \
    -not -path '*/.git/*' \
    2>/dev/null || true
)

# --- Scan 1: Webpack config files ---
echo "--- Webpack Configuration Files ---"
if [ -z "$WEBPACK_CONFIGS" ]; then
  echo "  (none found)"
else
  echo "$WEBPACK_CONFIGS" | while IFS= read -r f; do
    rel_path="${f#$PROJECT_DIR/}"
    size=$(wc -l < "$f" | tr -d ' ')
    echo "  - $rel_path ($size lines)"
  done
fi
echo ""

# --- Scan 2: Loaders in use ---
echo "--- Loaders Referenced ---"
LOADER_PATTERN="loader:|use:|babel-loader\|ts-loader\|css-loader\|sass-loader\|less-loader\|style-loader\|file-loader\|url-loader\|svg-loader\|raw-loader\|html-loader\|markdown-loader\|graphql-loader\|eslint-loader\|thread-loader\|cache-loader\|worker-loader\|istanbul-loader\|@svgr/webpack"
LOADERS=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n "$LOADER_PATTERN" 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$LOADERS" ]; then
  echo "  (none found)"
else
  echo "$LOADERS" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 3: Plugins in use ---
echo "--- Plugins Referenced ---"
PLUGIN_PATTERN="new.*Plugin\|plugins:"
PLUGINS=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n "$PLUGIN_PATTERN" 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$PLUGINS" ]; then
  echo "  (none found)"
else
  echo "$PLUGINS" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 4: Webpack-specific features ---
echo "--- Webpack-Specific Features ---"
echo "  require.context:"
RC=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'require\.context' 2>/dev/null || true
)
if [ -z "$RC" ]; then
  echo "    (none found)"
else
  echo "$RC" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "    - $rel_path:$line"
  done
fi

echo "  DefinePlugin:"
DP=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'DefinePlugin\|__DEV__\|__VERSION__\|__PROD__' 2>/dev/null || true
)
if [ -z "$DP" ]; then
  echo "    (none found)"
else
  echo "$DP" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "    - $rel_path:$line  $content"
  done
fi

echo "  ProvidePlugin:"
PP=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'ProvidePlugin' 2>/dev/null || true
)
if [ -z "$PP" ]; then
  echo "    (none found)"
else
  echo "$PP" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "    - $rel_path:$line  $content"
  done
fi

echo "  ModuleFederationPlugin:"
MF=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'ModuleFederationPlugin\|ModuleFederation' 2>/dev/null || true
)
if [ -z "$MF" ]; then
  echo "    (none found)"
else
  echo "$MF" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "    - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 5: Resolve aliases ---
echo "--- Resolve Aliases ---"
ALIASES=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'alias:\|resolve\.alias' 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$ALIASES" ]; then
  echo "  (none found)"
else
  echo "$ALIASES" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 6: DevServer config ---
echo "--- DevServer / Proxy Config ---"
DEVSERVER=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'devServer\|proxy:' 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$DEVSERVER" ]; then
  echo "  (none found)"
else
  echo "$DEVSERVER" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Generate report ---
{
  echo "# Webpack Configuration Audit Report"
  echo ""
  echo "Generated: $(date)"
  echo "Project: $PROJECT_DIR"
  echo ""
  echo "## Webpack Configuration Files"
  echo ""
  echo "$WEBPACK_CONFIGS" | while IFS= read -r f; do
    [ -z "$f" ] && continue
    rel_path="${f#$PROJECT_DIR/}"
    echo "- $rel_path"
  done
  echo ""
  echo "## Loaders Referenced"
  echo ""
  echo '```'
  echo "$LOADERS"
  echo '```'
  echo ""
  echo "## Plugins Referenced"
  echo ""
  echo '```'
  echo "$PLUGINS"
  echo '```'
  echo ""
  echo "## Webpack-Specific Features"
  echo ""
  echo "### require.context"
  echo '```'
  echo "$RC"
  echo '```'
  echo ""
  echo "### DefinePlugin / Global Constants"
  echo '```'
  echo "$DP"
  echo '```'
  echo ""
  echo "### ProvidePlugin"
  echo '```'
  echo "$PP"
  echo '```'
  echo ""
  echo "### ModuleFederationPlugin"
  echo '```'
  echo "$MF"
  echo '```'
  echo ""
  echo "## Resolve Aliases"
  echo ""
  echo '```'
  echo "$ALIASES"
  echo '```'
  echo ""
  echo "## DevServer / Proxy Config"
  echo ""
  echo '```'
  echo "$DEVSERVER"
  echo '```'
} > "$PROJECT_DIR/$REPORT_FILE"

echo "✅ Scan complete. Report: $PROJECT_DIR/$REPORT_FILE"
