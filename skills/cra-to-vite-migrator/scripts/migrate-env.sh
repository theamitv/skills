#!/usr/bin/env bash
# CRA → Vite Migrator - Env Var Migration Helper
# Usage: ./migrate-env.sh [project-directory]
# Scans for REACT_APP_ env vars and generates a migration report.
# Safe: read-only, no file modifications. Input-validated, injection-safe.

set -euo pipefail

PROJECT_DIR="${1:-}"
REPORT_FILE="env-migration-report.md"

usage() {
  echo "Usage: $0 <project-directory>"
  echo "Scans for REACT_APP_ env vars and generates a migration report."
  echo "Example: $0 /path/to/my-cra-project"
  exit 1
}

# Validate: directory argument is required
[ -n "$PROJECT_DIR" ] || usage

# Validate: directory exists and is readable
[ -d "$PROJECT_DIR" ] || { echo "Error: directory not found: $PROJECT_DIR"; exit 1; }
[ -r "$PROJECT_DIR" ] || { echo "Error: directory not readable: $PROJECT_DIR"; exit 1; }

# Validate: no path traversal (reject paths containing /../)
case "$PROJECT_DIR" in
  *"/../"*|*"/.." ) echo "Error: path traversal detected in: $PROJECT_DIR"; exit 1 ;;
esac

# Resolve to absolute path to avoid cd ambiguity
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd -P)" || { echo "Error: cannot resolve path: $PROJECT_DIR"; exit 1; }

echo "🔍 Scanning for REACT_APP_ env vars in: $PROJECT_DIR"
echo ""

# Find all .env files (use find -exec to handle spaces in paths safely)
ENV_FILES=$(find "$PROJECT_DIR" -maxdepth 2 -name '.env*' -not -path '*/node_modules/*' 2>/dev/null || true)

# Find all source files with REACT_APP_ references
# Using find with -exec to safely handle filenames with spaces
SOURCE_FILES=$(
  find "$PROJECT_DIR" -type f \( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' -o -name '*.json' -o -name '*.html' \) \
    -not -path '*/node_modules/*' \
    -not -path '*/build/*' \
    -not -path '*/dist/*' \
    -not -path '*/.git/*' \
    2>/dev/null || true
)

# Collect unique REACT_APP_ variable names (safe: grep on file list via pipe)
VARS=$(echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -roh 'REACT_APP_[A-Z_]*' 2>/dev/null | sort -u || true)

if [ -z "$VARS" ]; then
  echo "✅ No REACT_APP_ env vars found."
  exit 0
fi

echo "📋 Found REACT_APP_ env vars:"
echo ""
echo "| CRA Var | Vite Var | Source Files |"
echo "|---------|----------|--------------|"

while IFS= read -r var; do
  [ -z "$var" ] && continue
  vite_var="${var/REACT_APP_/VITE_}"
  # Count files containing this var (safe: xargs -0 handles spaces)
  count=$(echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -rl "$var" 2>/dev/null | wc -l | tr -d ' ')
  echo "| \`$var\` | \`$vite_var\` | $count files |"
done <<< "$VARS"

echo ""
echo "📄 .env files found:"
while IFS= read -r f; do
  [ -z "$f" ] && continue
  # Show path relative to project dir
  rel_path="${f#$PROJECT_DIR/}"
  echo "  - $rel_path"
done <<< "$ENV_FILES"

echo ""
echo "📝 Report saved to: $PROJECT_DIR/$REPORT_FILE"

# Generate report (heredoc with quoted delimiter prevents expansion)
cat > "$PROJECT_DIR/$REPORT_FILE" << 'REPORT_EOF'
# CRA → Vite Env Var Migration Report

Generated: REPORT_EOF
date >> "$PROJECT_DIR/$REPORT_FILE"
cat >> "$PROJECT_DIR/$REPORT_FILE" << 'REPORT_EOF'

## Variables to Rename

| CRA Variable | Vite Variable | Occurrences |
|--------------|---------------|-------------|
REPORT_EOF

while IFS= read -r var; do
  [ -z "$var" ] && continue
  vite_var="${var/REACT_APP_/VITE_}"
  count=$(echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -rl "$var" 2>/dev/null | wc -l | tr -d ' ')
  echo "| \`$var\` | \`$vite_var\` | $count files |" >> "$PROJECT_DIR/$REPORT_FILE"
done <<< "$VARS"

{
  echo ""
  echo "## Files to Update"
  echo ""
} >> "$PROJECT_DIR/$REPORT_FILE"

while IFS= read -r var; do
  [ -z "$var" ] && continue
  vite_var="${var/REACT_APP_/VITE_}"
  {
    echo "### $var → $vite_var"
    echo ""
    echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -rl "$var" 2>/dev/null | while IFS= read -r f; do
      [ -z "$f" ] && continue
      rel_path="${f#$PROJECT_DIR/}"
      echo "- \`$rel_path\`"
    done
    echo ""
  } >> "$PROJECT_DIR/$REPORT_FILE"
done <<< "$VARS"

echo "✅ Scan complete. Report: $PROJECT_DIR/$REPORT_FILE"
