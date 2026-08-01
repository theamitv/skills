#!/usr/bin/env bash
# Mongoose → Prisma/Drizzle Migrator - Mongoose Schema Audit Scanner
# Usage: ./audit-mongoose-schemas.sh [project-directory]
# Scans Mongoose schema definitions and generates a migration audit report.
# Safe: read-only, no file modifications. Input-validated, injection-safe.

set -euo pipefail

PROJECT_DIR="${1:-}"
REPORT_FILE="mongoose-schema-audit.md"

usage() {
  echo "Usage: $0 <project-directory>"
  echo "Scans Mongoose schema definitions and generates a migration audit report."
  echo "Example: $0 /path/to/my-app"
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

echo "🔍 Scanning Mongoose schemas in: $PROJECT_DIR"
echo ""

# Find JS/TS source files
SOURCE_FILES=$(
  find "$PROJECT_DIR" -type f \( -name '*.js' -o -name '*.ts' \) \
    -not -path '*/node_modules/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' \
    -not -path '*/.git/*' \
    2>/dev/null || true
)

if [ -z "$SOURCE_FILES" ]; then
  echo "⚠️  No source files found."
  exit 0
fi

echo "📄 Found $(echo "$SOURCE_FILES" | wc -l | tr -d ' ') source files to scan."
echo ""

# --- Scan 1: Mongoose schema definitions ---
echo "--- Mongoose Schema Definitions ---"
SCHEMAS=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'new mongoose.Schema\|new Schema\|mongoose\.model\|\.model(' 2>/dev/null || true
)
if [ -z "$SCHEMAS" ]; then
  echo "  (none found)"
else
  echo "$SCHEMAS" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 2: Mixed / schema-less types ---
echo "--- Mixed / Schema-Less Types ---"
MIXED=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'Mixed\|Schema\.Types\.Mixed\|type:.*Mixed' 2>/dev/null || true
)
if [ -z "$MIXED" ]; then
  echo "  (none found)"
else
  echo "$MIXED" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  ⚠️  $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 3: Populate calls ---
echo "--- .populate() Calls ---"
POPULATE=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n '\.populate(' 2>/dev/null || true
)
if [ -z "$POPULATE" ]; then
  echo "  (none found)"
else
  POPULATE_COUNT=$(echo "$POPULATE" | wc -l | tr -d ' ')
  echo "  $POPULATE_COUNT total .populate() calls"
  echo "$POPULATE" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 4: Embedded / nested schemas ---
echo "--- Embedded / Nested Schemas ---"
EMBEDDED=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n '\[.*{.*type:\|embedded\|nested.*schema\|sub.*doc' 2>/dev/null || true
)
if [ -z "$EMBEDDED" ]; then
  echo "  (none found)"
else
  echo "$EMBEDDED" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 5: Multi-document transactions ---
echo "--- Multi-Document Transactions ---"
TRANSACTIONS=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'startSession\|withTransaction\|session\|transaction' 2>/dev/null || true
)
if [ -z "$TRANSACTIONS" ]; then
  echo "  (none found — app may rely on eventual consistency)"
else
  echo "$TRANSACTIONS" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 6: ObjectId references ---
echo "--- ObjectId References (ref:) ---"
REF=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n "ref:\|ref:'\|ref:\"" 2>/dev/null || true
)
if [ -z "$REF" ]; then
  echo "  (none found)"
else
  echo "$REF" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Generate report ---
{
  echo "# Mongoose Schema Audit Report"
  echo ""
  echo "Generated: $(date)"
  echo "Project: $PROJECT_DIR"
  echo ""
  echo "## Mongoose Schema Definitions"
  echo ""
  echo '```'
  echo "$SCHEMAS"
  echo '```'
  echo ""
  echo "## Mixed / Schema-Less Types (need explicit decision)"
  echo ""
  echo '```'
  echo "$MIXED"
  echo '```'
  echo ""
  echo "## .populate() Calls (need relation mapping)"
  echo ""
  echo '```'
  echo "$POPULATE"
  echo '```'
  echo ""
  echo "## Embedded / Nested Schemas"
  echo ""
  echo '```'
  echo "$EMBEDDED"
  echo '```'
  echo ""
  echo "## Multi-Document Transactions"
  echo ""
  echo '```'
  echo "$TRANSACTIONS"
  echo '```'
  echo ""
  echo "## ObjectId References (ref:)"
  echo ""
  echo '```'
  echo "$REF"
  echo '```'
} > "$PROJECT_DIR/$REPORT_FILE"

echo "✅ Scan complete. Report: $PROJECT_DIR/$REPORT_FILE"
