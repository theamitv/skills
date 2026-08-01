#!/usr/bin/env bash
# Monolith Boundary Finder - Module Coupling Audit Scanner
# Usage: ./audit-coupling.sh [project-directory]
# Scans module dependencies and generates a coupling analysis report.
# Safe: read-only, no file modifications. Input-validated, injection-safe.

set -euo pipefail

PROJECT_DIR="${1:-}"
REPORT_FILE="module-coupling-audit.md"

usage() {
  echo "Usage: $0 <project-directory>"
  echo "Scans module dependencies and generates a coupling analysis report."
  echo "Example: $0 /path/to/my-monolith"
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

echo "🔍 Scanning module coupling in: $PROJECT_DIR"
echo ""

# Find source files
SOURCE_FILES=$(
  find "$PROJECT_DIR" -type f \( -name '*.js' -o -name '*.ts' -o -name '*.py' -o -name '*.rb' -o -name '*.java' -o -name '*.go' \) \
    -not -path '*/node_modules/*' \
    -not -path '*/vendor/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' \
    -not -path '*/.git/*' \
    -not -path '*/__pycache__/*' \
    2>/dev/null || true
)

if [ -z "$SOURCE_FILES" ]; then
  echo "⚠️  No source files found."
  exit 0
fi

echo "📄 Found $(echo "$SOURCE_FILES" | wc -l | tr -d ' ') source files to scan."
echo ""

# Identify top-level module directories
echo "--- Top-Level Module Directories ---"
MODULE_DIRS=$(
  find "$PROJECT_DIR" -maxdepth 2 -type d \
    -not -path '*/node_modules/*' \
    -not -path '*/vendor/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' \
    -not -path '*/.git/*' \
    -not -path '*/__pycache__/*' \
    -not -path '*/.*' \
    2>/dev/null | sort || true
)
if [ -z "$MODULE_DIRS" ]; then
  echo "  (none found)"
else
  echo "$MODULE_DIRS" | while IFS= read -r d; do
    rel_path="${d#$PROJECT_DIR/}"
    file_count=$(find "$d" -type f \( -name '*.js' -o -name '*.ts' -o -name '*.py' -o -name '*.rb' -o -name '*.java' -o -name '*.go' \) 2>/dev/null | wc -l | tr -d ' ')
    echo "  - $rel_path/ ($file_count files)"
  done
fi
echo ""

# --- Scan 1: Import/require dependencies ---
echo "--- Import/Require Dependencies ---"
IMPORT_PATTERN="import.*from\|require(\|from.*import"
IMPORTS=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n "$IMPORT_PATTERN" 2>/dev/null \
    | grep -v 'node_modules' | grep -v 'vendor/' || true
)
if [ -z "$IMPORTS" ]; then
  echo "  (none found)"
else
  TOTAL_IMPORTS=$(echo "$IMPORTS" | wc -l | tr -d ' ')
  echo "  $TOTAL_IMPORTS total import/require statements"
  echo ""
  # Show imports by source module
  echo "$IMPORTS" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    module=$(echo "$rel_path" | cut -d'/' -f1)
    echo "  [$module] $rel_path:$line  $content"
  done | head -40
  if [ "$TOTAL_IMPORTS" -gt 40 ]; then
    echo "  ... and $((TOTAL_IMPORTS - 40)) more"
  fi
fi
echo ""

# --- Scan 2: Database table references ---
echo "--- Database Table References ---"
DB_PATTERN="\.find\|\.findAll\|\.findOne\|\.create\|\.update\|\.destroy\|\.save\|\.delete\|SELECT\|INSERT INTO\|UPDATE\|DELETE FROM\|db\.\|knex\.\|prisma\.\|Model\.\|query\."
DB_REFS=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n "$DB_PATTERN" 2>/dev/null \
    | grep -v 'node_modules' | grep -v 'vendor/' || true
)
if [ -z "$DB_REFS" ]; then
  echo "  (none found)"
else
  TOTAL_DB=$(echo "$DB_REFS" | wc -l | tr -d ' ')
  echo "  $TOTAL_DB total database references"
  echo "$DB_REFS" | head -30 | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
  if [ "$TOTAL_DB" -gt 30 ]; then
    echo "  ... and $((TOTAL_DB - 30)) more"
  fi
fi
echo ""

# --- Scan 3: Synchronous call chains ---
echo "--- Synchronous Call Chains (await/call/then) ---"
SYNC_PATTERN="await\|\.then(\|\.call(\|\.invoke("
SYNC_CALLS=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n "$SYNC_PATTERN" 2>/dev/null \
    | grep -v 'node_modules' | grep -v 'vendor/' || true
)
if [ -z "$SYNC_CALLS" ]; then
  echo "  (none found)"
else
  TOTAL_SYNC=$(echo "$SYNC_CALLS" | wc -l | tr -d ' ')
  echo "  $TOTAL_SYNC total synchronous call sites"
fi
echo ""

# --- Scan 4: Module boundary candidates ---
echo "--- Module Boundary Candidates (high-level summary) ---"
echo "  (See report for detailed coupling analysis)"
echo ""

# --- Generate report ---
{
  echo "# Module Coupling Audit Report"
  echo ""
  echo "Generated: $(date)"
  echo "Project: $PROJECT_DIR"
  echo ""
  echo "## Module Directories"
  echo ""
  echo "$MODULE_DIRS" | while IFS= read -r d; do
    [ -z "$d" ] && continue
    rel_path="${d#$PROJECT_DIR/}"
    file_count=$(find "$d" -type f \( -name '*.js' -o -name '*.ts' -o -name '*.py' -o -name '*.rb' -o -name '*.java' -o -name '*.go' \) 2>/dev/null | wc -l | tr -d ' ')
    echo "- $rel_path/ ($file_count files)"
  done
  echo ""
  echo "## Import/Require Dependencies"
  echo ""
  echo '```'
  echo "$IMPORTS"
  echo '```'
  echo ""
  echo "## Database Table References"
  echo ""
  echo '```'
  echo "$DB_REFS"
  echo '```'
  echo ""
  echo "## Synchronous Call Chains"
  echo ""
  echo '```'
  echo "$SYNC_CALLS"
  echo '```'
} > "$PROJECT_DIR/$REPORT_FILE"

echo "✅ Scan complete. Report: $PROJECT_DIR/$REPORT_FILE"
