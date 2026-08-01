#!/usr/bin/env bash
# Express → NestJS Migrator - Middleware Audit Scanner
# Usage: ./audit-middleware.sh [project-directory]
# Scans Express middleware registrations and generates an audit report.
# Safe: read-only, no file modifications. Input-validated, injection-safe.

set -euo pipefail

PROJECT_DIR="${1:-}"
REPORT_FILE="middleware-audit-report.md"

usage() {
  echo "Usage: $0 <project-directory>"
  echo "Scans Express middleware registrations and generates an audit report."
  echo "Example: $0 /path/to/my-express-app"
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

echo "🔍 Scanning Express middleware in: $PROJECT_DIR"
echo ""

# Find JS/TS source files (exclude node_modules)
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

# --- Scan 1: app-level middleware registrations ---
echo "--- App-Level Middleware (app.use) ---"
APP_USE=$(echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n '\.use(' 2>/dev/null || true)
if [ -z "$APP_USE" ]; then
  echo "  (none found)"
else
  echo "$APP_USE" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 2: Route definitions ---
echo "--- Route Definitions (app.get/post/put/delete) ---"
ROUTES=$(echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n '\.\(get\|post\|put\|delete\|patch\|options\|all\)(' 2>/dev/null || true)
if [ -z "$ROUTES" ]; then
  echo "  (none found)"
else
  echo "$ROUTES" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 3: Router usage ---
echo "--- Router Usage (express.Router) ---"
ROUTERS=$(echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'Router\|\.route(' 2>/dev/null || true)
if [ -z "$ROUTERS" ]; then
  echo "  (none found)"
else
  echo "$ROUTERS" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 4: Error handlers ---
echo "--- Error Handlers (4-arg middleware) ---"
ERROR_HANDLERS=$(echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n '(err, req, res, next)\|(error, req, res, next)' 2>/dev/null || true)
if [ -z "$ERROR_HANDLERS" ]; then
  echo "  (none found)"
else
  echo "$ERROR_HANDLERS" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 5: req mutation patterns ---
echo "--- req Mutation Patterns ---"
REQ_MUTATION=$(echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'req\.' 2>/dev/null | grep -v 'req\.\(body\|params\|query\|headers\|method\|url\|path\|protocol\|hostname\|ip\|originalUrl\|baseUrl\|xhr\|accepts\|cookies\|signedCookies\|get\|header\|res\)' | grep 'req\.' || true)
if [ -z "$REQ_MUTATION" ]; then
  echo "  (none found)"
else
  echo "$REQ_MUTATION" | head -20 | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
  total=$(echo "$REQ_MUTATION" | wc -l | tr -d ' ')
  if [ "$total" -gt 20 ]; then
    echo "  ... and $((total - 20)) more occurrences"
  fi
fi
echo ""

# --- Generate report ---
{
  echo "# Express → NestJS Middleware Audit Report"
  echo ""
  echo "Generated: $(date)"
  echo "Project: $PROJECT_DIR"
  echo ""
  echo "## App-Level Middleware (app.use)"
  echo ""
  echo '```'
  echo "$APP_USE"
  echo '```'
  echo ""
  echo "## Route Definitions"
  echo ""
  echo '```'
  echo "$ROUTES"
  echo '```'
  echo ""
  echo "## Router Usage"
  echo ""
  echo '```'
  echo "$ROUTERS"
  echo '```'
  echo ""
  echo "## Error Handlers"
  echo ""
  echo '```'
  echo "$ERROR_HANDLERS"
  echo '```'
  echo ""
  echo "## req Mutation Patterns"
  echo ""
  echo '```'
  echo "$REQ_MUTATION"
  echo '```'
} > "$PROJECT_DIR/$REPORT_FILE"

echo "✅ Scan complete. Report: $PROJECT_DIR/$REPORT_FILE"
