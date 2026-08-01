#!/usr/bin/env bash
# REST → GraphQL Schema Deriver - Endpoint Catalog Scanner
# Usage: ./catalog-endpoints.sh [project-directory]
# Scans REST endpoint definitions and generates a catalog report.
# Safe: read-only, no file modifications. Input-validated, injection-safe.

set -euo pipefail

PROJECT_DIR="${1:-}"
REPORT_FILE="rest-endpoint-catalog.md"

usage() {
  echo "Usage: $0 <project-directory>"
  echo "Scans REST endpoint definitions and generates a catalog report."
  echo "Example: $0 /path/to/my-api"
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

echo "🔍 Scanning REST endpoints in: $PROJECT_DIR"
echo ""

# Find JS/TS source files
SOURCE_FILES=$(
  find "$PROJECT_DIR" -type f \( -name '*.js' -o -name '*.ts' \) \
    -not -path '*/node_modules/*' \
    -not -path '*/dist/*' \
    -not -path '*/.git/*' \
    2>/dev/null || true
)

if [ -z "$SOURCE_FILES" ]; then
  echo "⚠️  No JavaScript/TypeScript source files found."
  exit 0
fi

echo "📄 Found $(echo "$SOURCE_FILES" | wc -l | tr -d ' ') source files to scan."
echo ""

# --- Scan 1: Route definitions ---
echo "--- Route Definitions (app.get/post/put/delete/patch) ---"
ROUTES=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n '\.\(get\|post\|put\|delete\|patch\|options\)(' 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$ROUTES" ]; then
  echo "  (none found)"
else
  echo "$ROUTES" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 2: Express Router usage ---
echo "--- Router Definitions (express.Router / router.get/post) ---"
ROUTERS=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'Router\|router\.\(get\|post\|put\|delete\|patch\)' 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$ROUTERS" ]; then
  echo "  (none found)"
else
  echo "$ROUTERS" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 3: Auth middleware ---
echo "--- Auth Middleware (authenticate/authorize/protect) ---"
AUTH=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'authenticate\|authorize\|protect\|requireAuth\|isAuthenticated\|isAdmin' 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$AUTH" ]; then
  echo "  (none found)"
else
  echo "$AUTH" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 4: Response shapes (res.json/res.send) ---
echo "--- Response Definitions (res.json/res.send) ---"
RESPONSES=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'res\.json\|res\.send\|res\.status.*\.json\|return.*Response' 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$RESPONSES" ]; then
  echo "  (none found)"
else
  echo "$RESPONSES" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 5: Database query patterns ---
echo "--- Database Query Patterns (db./knex./prisma./query.) ---"
DB_QUERIES=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'db\.\|knex\.\|prisma\.\|query\.\|Model\.\(find\|findAll\|findOne\|findById\)' 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$DB_QUERIES" ]; then
  echo "  (none found)"
else
  echo "$DB_QUERIES" | head -30 | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
  total=$(echo "$DB_QUERIES" | wc -l | tr -d ' ')
  if [ "$total" -gt 30 ]; then
    echo "  ... and $((total - 30)) more occurrences"
  fi
fi
echo ""

# --- Scan 6: Shared entity patterns ---
echo "--- Shared Entity References (models/schemas/types) ---"
ENTITIES=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'class.*Model\|interface.*\|type.*=\|schema.*=.*mongoose\|\.model(' 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$ENTITIES" ]; then
  echo "  (none found)"
else
  echo "$ENTITIES" | head -20 | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
  total=$(echo "$ENTITIES" | wc -l | tr -d ' ')
  if [ "$total" -gt 20 ]; then
    echo "  ... and $((total - 20)) more occurrences"
  fi
fi
echo ""

# --- Generate report ---
{
  echo "# REST Endpoint Catalog Report"
  echo ""
  echo "Generated: $(date)"
  echo "Project: $PROJECT_DIR"
  echo ""
  echo "## Route Definitions"
  echo ""
  echo '```'
  echo "$ROUTES"
  echo '```'
  echo ""
  echo "## Router Definitions"
  echo ""
  echo '```'
  echo "$ROUTERS"
  echo '```'
  echo ""
  echo "## Auth Middleware"
  echo ""
  echo '```'
  echo "$AUTH"
  echo '```'
  echo ""
  echo "## Response Definitions"
  echo ""
  echo '```'
  echo "$RESPONSES"
  echo '```'
  echo ""
  echo "## Database Query Patterns"
  echo ""
  echo '```'
  echo "$DB_QUERIES"
  echo '```'
  echo ""
  echo "## Shared Entity References"
  echo ""
  echo '```'
  echo "$ENTITIES"
  echo '```'
} > "$PROJECT_DIR/$REPORT_FILE"

echo "✅ Scan complete. Report: $PROJECT_DIR/$REPORT_FILE"
