#!/usr/bin/env bash
# Python 2→3 / Django Version Bump Auditor - Upgrade Audit Scanner
# Usage: ./audit-python-django.sh [project-directory]
# Scans Python/Django code for upgrade risk areas.
# Safe: read-only, no file modifications. Input-validated, injection-safe.

set -euo pipefail

PROJECT_DIR="${1:-}"
REPORT_FILE="python-django-upgrade-audit.md"

usage() {
  echo "Usage: $0 <project-directory>"
  echo "Scans Python/Django code for upgrade risk areas."
  echo "Example: $0 /path/to/my-django-app"
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

echo "🔍 Scanning Python/Django code in: $PROJECT_DIR"
echo ""

# Find Python source files
PY_FILES=$(
  find "$PROJECT_DIR" -type f \( -name '*.py' \) \
    -not -path '*/node_modules/*' \
    -not -path '*/venv/*' \
    -not -path '*/env/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' \
    -not -path '*/.git/*' \
    -not -path '*/__pycache__/*' \
    -not -path '*/migrations/*' \
    2>/dev/null || true
)

if [ -z "$PY_FILES" ]; then
  echo "⚠️  No Python files found."
  exit 0
fi

echo "📄 Found $(echo "$PY_FILES" | wc -l | tr -d ' ') Python files to scan."
echo ""

# --- Scan 1: Python version ---
echo "--- Python Version Indicators ---"
PY_VERSION=$(
  echo "$PY_FILES" | tr '\n' '\0' | xargs -0 grep -n 'print\s\|print(\|from __future__\|unicode_literals\|division\|absolute_import' 2>/dev/null || true
)
if [ -z "$PY_VERSION" ]; then
  echo "  (no clear Python 2/3 indicators)"
else
  echo "$PY_VERSION" | head -20 | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 2: String/bytes risk areas ---
echo "--- String/Bytes Risk Areas ---"
echo "  open() without encoding:"
OPEN_NOENC=$(
  echo "$PY_FILES" | tr '\n' '\0' | xargs -0 grep -n "open(" 2>/dev/null \
    | grep -v 'encoding=' | grep -v 'node_modules' || true
)
if [ -z "$OPEN_NOENC" ]; then
  echo "    (none found)"
else
  echo "$OPEN_NOENC" | head -15 | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "    - $rel_path:$line  $content"
  done
fi

echo "  socket.send() with str:"
SOCKET=$(
  echo "$PY_FILES" | tr '\n' '\0' | xargs -0 grep -n 'socket\.\|\.send(\|\.recv(' 2>/dev/null || true
)
if [ -z "$SOCKET" ]; then
  echo "    (none found)"
else
  echo "$SOCKET" | head -10 | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "    - $rel_path:$line  $content"
  done
fi

echo "  basestring / unicode references:"
BASESTR=$(
  echo "$PY_FILES" | tr '\n' '\0' | xargs -0 grep -n 'basestring\|unicode(' 2>/dev/null || true
)
if [ -z "$BASESTR" ]; then
  echo "    (none found)"
else
  echo "$BASESTR" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "    ⚠️  $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 3: Django-specific patterns ---
echo "--- Django-Specific Patterns ---"
echo "  ForeignKey without on_delete:"
FK=$(
  echo "$PY_FILES" | tr '\n' '\0' | xargs -0 grep -n 'ForeignKey(' 2>/dev/null \
    | grep -v 'on_delete' || true
)
if [ -z "$FK" ]; then
  echo "    (none found)"
else
  echo "$FK" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "    ⚠️  $rel_path:$line  $content"
  done
fi

echo "  Old-style middleware (process_request/process_response):"
OLD_MW=$(
  echo "$PY_FILES" | tr '\n' '\0' | xargs -0 grep -n 'process_request\|process_response\|MIDDLEWARE_CLASSES' 2>/dev/null || true
)
if [ -z "$OLD_MW" ]; then
  echo "    (none found)"
else
  echo "$OLD_MW" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "    ⚠️  $rel_path:$line  $content"
  done
fi

echo "  django.utils.six references:"
SIX=$(
  echo "$PY_FILES" | tr '\n' '\0' | xargs -0 grep -n 'django\.utils\.six\|from six import' 2>/dev/null || true
)
if [ -z "$SIX" ]; then
  echo "    (none found)"
else
  echo "$SIX" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "    ⚠️  $rel_path:$line  $content"
  done
fi

echo "  url() instead of path()/re_path():"
URL_PATTERN=$(
  echo "$PY_FILES" | tr '\n' '\0' | xargs -0 grep -n "from django.conf.urls import\|url(" 2>/dev/null || true
)
if [ -z "$URL_PATTERN" ]; then
  echo "    (none found)"
else
  echo "$URL_PATTERN" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "    ⚠️  $rel_path:$line  $content"
  done
fi

echo "  django.core.urlresolvers:"
URLRESOLVERS=$(
  echo "$PY_FILES" | tr '\n' '\0' | xargs -0 grep -n 'django\.core\.urlresolvers' 2>/dev/null || true
)
if [ -z "$URLRESOLVERS" ]; then
  echo "    (none found)"
else
  echo "$URLRESOLVERS" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "    ⚠️  $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 4: Python 2-only features ---
echo "--- Python 2-Only Features ---"
PY2_FEATURES=$(
  echo "$PY_FILES" | tr '\n' '\0' | xargs -0 grep -n 'print\s[^(]\|`[^`]*`\|\.iteritems()\|\.itervalues()\|\.iterkeys()\|xrange(\|raw_input(\|cmp(\|apply(\|execfile(\|file(' 2>/dev/null || true
)
if [ -z "$PY2_FEATURES" ]; then
  echo "  (none found)"
else
  echo "$PY2_FEATURES" | head -20 | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  ⚠️  $rel_path:$line  $content"
  done
fi
echo ""

# --- Generate report ---
{
  echo "# Python/Django Upgrade Audit Report"
  echo ""
  echo "Generated: $(date)"
  echo "Project: $PROJECT_DIR"
  echo ""
  echo "## Python Version Indicators"
  echo ""
  echo '```'
  echo "$PY_VERSION"
  echo '```'
  echo ""
  echo "## String/Bytes Risk Areas"
  echo ""
  echo "### open() without encoding"
  echo '```'
  echo "$OPEN_NOENC"
  echo '```'
  echo ""
  echo "### Socket I/O"
  echo '```'
  echo "$SOCKET"
  echo '```'
  echo ""
  echo "### basestring / unicode references"
  echo '```'
  echo "$BASESTR"
  echo '```'
  echo ""
  echo "## Django-Specific Patterns"
  echo ""
  echo "### ForeignKey without on_delete"
  echo '```'
  echo "$FK"
  echo '```'
  echo ""
  echo "### Old-style middleware"
  echo '```'
  echo "$OLD_MW"
  echo '```'
  echo ""
  echo "### django.utils.six references"
  echo '```'
  echo "$SIX"
  echo '```'
  echo ""
  echo "### url() instead of path()/re_path()"
  echo '```'
  echo "$URL_PATTERN"
  echo '```'
  echo ""
  echo "### django.core.urlresolvers"
  echo '```'
  echo "$URLRESOLVERS"
  echo '```'
  echo ""
  echo "## Python 2-Only Features"
  echo ""
  echo '```'
  echo "$PY2_FEATURES"
  echo '```'
} > "$PROJECT_DIR/$REPORT_FILE"

echo "✅ Scan complete. Report: $PROJECT_DIR/$REPORT_FILE"
