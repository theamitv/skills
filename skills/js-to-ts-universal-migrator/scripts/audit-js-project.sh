#!/usr/bin/env bash
# JS → TS Universal Migrator - JS Project Audit Scanner
# Usage: ./audit-js-project.sh [project-directory]
# Scans JS files and generates a migration priority report.
# Safe: read-only, no file modifications. Input-validated, injection-safe.

set -euo pipefail

PROJECT_DIR="${1:-}"
REPORT_FILE="js-to-ts-audit-report.md"

usage() {
  echo "Usage: $0 <project-directory>"
  echo "Scans JS files and generates a migration priority report."
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

echo "🔍 Scanning JavaScript project in: $PROJECT_DIR"
echo ""

# Find all JS/JSX files (exclude node_modules, dist, .git)
JS_FILES=$(
  find "$PROJECT_DIR" -type f \( -name '*.js' -o -name '*.jsx' -o -name '*.mjs' -o -name '*.cjs' -o -name '*.vue' \) \
    -not -path '*/node_modules/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' \
    -not -path '*/.git/*' \
    2>/dev/null || true
)

if [ -z "$JS_FILES" ]; then
  echo "⚠️  No JavaScript files found."
  exit 0
fi

TOTAL_FILES=$(echo "$JS_FILES" | wc -l | tr -d ' ')
echo "📄 Found $TOTAL_FILES source files to scan."
echo ""

# --- Scan 1: Detect framework ---
echo "--- Framework Detection ---"
if [ -f "$PROJECT_DIR/package.json" ]; then
  if grep -q '"react"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    echo "  Detected: React"
  fi
  if grep -q '"vue"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    echo "  Detected: Vue"
  fi
  if grep -q '"@angular/core"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    echo "  Detected: Angular"
  fi
  if grep -q '"express"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    echo "  Detected: Express/Node"
  fi
  if grep -q '"next"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    echo "  Detected: Next.js"
  fi
fi
echo ""

# --- Scan 2: File count by directory ---
echo "--- Files by Directory ---"
echo "$JS_FILES" | while IFS= read -r f; do
  dirname "$f"
done | sort | uniq -c | sort -rn | while IFS= read -r line; do
  count=$(echo "$line" | awk '{print $1}')
  dir=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^ //')
  rel_dir="${dir#$PROJECT_DIR/}"
  echo "  $count  $rel_dir"
done
echo ""

# --- Scan 3: Files with JSDoc annotations ---
echo "--- Files with JSDoc Annotations (mechanical conversion candidates) ---"
JSDOC_FILES=$(echo "$JS_FILES" | tr '\n' '\0' | xargs -0 grep -l '/\*\*' 2>/dev/null || true)
if [ -z "$JSDOC_FILES" ]; then
  echo "  (none found)"
else
  echo "$JSDOC_FILES" | while IFS= read -r f; do
    rel_path="${f#$PROJECT_DIR/}"
    annotations=$(grep -c '/\*\*' "$f" 2>/dev/null || echo "0")
    echo "  - $rel_path ($annotations JSDoc blocks)"
  done
fi
echo ""

# --- Scan 4: Files with dynamic patterns ---
echo "--- Files with Dynamic Patterns (may resist typing) ---"
DYNAMIC_PATTERNS="Object\.keys\|Object\.values\|\.\.\.\|arguments\|prototype\.\|callbacks\."
DYNAMIC_FILES=$(echo "$JS_FILES" | tr '\n' '\0' | xargs -0 grep -l "$DYNAMIC_PATTERNS" 2>/dev/null || true)
if [ -z "$DYNAMIC_FILES" ]; then
  echo "  (none found)"
else
  echo "$DYNAMIC_FILES" | while IFS= read -r f; do
    rel_path="${f#$PROJECT_DIR/}"
    echo "  - $rel_path"
  done
fi
echo ""

# --- Scan 5: Files with require() (CommonJS) ---
echo "--- Files Using CommonJS (require/module.exports) ---"
CJS_FILES=$(echo "$JS_FILES" | tr '\n' '\0' | xargs -0 grep -l 'require\|module\.exports' 2>/dev/null || true)
if [ -z "$CJS_FILES" ]; then
  echo "  (none found)"
else
  echo "$CJS_FILES" | while IFS= read -r f; do
    rel_path="${f#$PROJECT_DIR/}"
    requires=$(grep -c 'require(' "$f" 2>/dev/null || echo "0")
    echo "  - $rel_path ($requires require calls)"
  done
fi
echo ""

# --- Scan 6: Check for existing tsconfig ---
echo "--- Existing TypeScript Configuration ---"
if [ -f "$PROJECT_DIR/tsconfig.json" ]; then
  echo "  ✅ tsconfig.json found"
  grep -E '"strict"|"noImplicitAny"|"strictNullChecks"|"allowJs"|"checkJs"' "$PROJECT_DIR/tsconfig.json" 2>/dev/null || echo "  (no strictness flags set)"
else
  echo "  ❌ No tsconfig.json found"
fi
echo ""

# --- Scan 7: Check for existing .ts files ---
echo "--- Existing TypeScript Files ---"
TS_FILES=$(find "$PROJECT_DIR" -type f \( -name '*.ts' -o -name '*.tsx' \) -not -path '*/node_modules/*' -not -path '*/dist/*' 2>/dev/null || true)
if [ -z "$TS_FILES" ]; then
  echo "  (no .ts files yet)"
else
  TS_COUNT=$(echo "$TS_FILES" | wc -l | tr -d ' ')
  echo "  $TS_COUNT .ts/.tsx files already exist"
fi
echo ""

# --- Scan 8: Check for PropTypes (React) ---
echo "--- PropTypes Usage (React) ---"
PROPTYPES_FILES=$(echo "$JS_FILES" | tr '\n' '\0' | xargs -0 grep -l 'PropTypes\.' 2>/dev/null || true)
if [ -z "$PROPTYPES_FILES" ]; then
  echo "  (none found)"
else
  echo "$PROPTYPES_FILES" | while IFS= read -r f; do
    rel_path="${f#$PROJECT_DIR/}"
    echo "  - $rel_path"
  done
fi
echo ""

# --- Generate report ---
{
  echo "# JS → TS Migration Audit Report"
  echo ""
  echo "Generated: $(date)"
  echo "Project: $PROJECT_DIR"
  echo ""
  echo "## Overview"
  echo ""
  echo "- Total source files: $TOTAL_FILES"
  echo "- Directories with source files: $(echo "$JS_FILES" | xargs -I {} dirname {} | sort -u | wc -l | tr -d ' ')"
  echo ""
  echo "## Framework Detection"
  echo ""
  if [ -f "$PROJECT_DIR/package.json" ]; then
    grep -E '"(react|vue|@angular/core|express|next)"' "$PROJECT_DIR/package.json" 2>/dev/null || echo "(none detected)"
  fi
  echo ""
  echo "## Files by Directory"
  echo ""
  echo '```'
  echo "$JS_FILES" | while IFS= read -r f; do dirname "$f"; done | sort | uniq -c | sort -rn
  echo '```'
  echo ""
  echo "## Files with JSDoc Annotations (Mechanical Conversion)"
  echo ""
  echo "$JSDOC_FILES" | while IFS= read -r f; do
    [ -z "$f" ] && continue
    rel_path="${f#$PROJECT_DIR/}"
    annotations=$(grep -c '/\*\*' "$f" 2>/dev/null || echo "0")
    echo "- $rel_path ($annotations JSDoc blocks)"
  done
  echo ""
  echo "## Files with Dynamic Patterns (May Resist Typing)"
  echo ""
  echo "$DYNAMIC_FILES" | while IFS= read -r f; do
    [ -z "$f" ] && continue
    rel_path="${f#$PROJECT_DIR/}"
    echo "- $rel_path"
  done
  echo ""
  echo "## Files Using CommonJS"
  echo ""
  echo "$CJS_FILES" | while IFS= read -r f; do
    [ -z "$f" ] && continue
    rel_path="${f#$PROJECT_DIR/}"
    requires=$(grep -c 'require(' "$f" 2>/dev/null || echo "0")
    echo "- $rel_path ($requires require calls)"
  done
  echo ""
  echo "## TypeScript Configuration"
  echo ""
  if [ -f "$PROJECT_DIR/tsconfig.json" ]; then
    echo "tsconfig.json: present"
  else
    echo "tsconfig.json: missing"
  fi
  echo ""
  echo "## PropTypes Usage"
  echo ""
  echo "$PROPTYPES_FILES" | while IFS= read -r f; do
    [ -z "$f" ] && continue
    rel_path="${f#$PROJECT_DIR/}"
    echo "- $rel_path"
  done
} > "$PROJECT_DIR/$REPORT_FILE"

echo "✅ Scan complete. Report: $PROJECT_DIR/$REPORT_FILE"
