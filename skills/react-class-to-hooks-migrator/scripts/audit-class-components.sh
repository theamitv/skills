#!/usr/bin/env bash
# Class → Hooks Migrator - Class Component Audit Scanner
# Usage: ./audit-class-components.sh [project-directory]
# Scans React class components and generates a migration audit report.
# Safe: read-only, no file modifications. Input-validated, injection-safe.

set -euo pipefail

PROJECT_DIR="${1:-}"
REPORT_FILE="class-component-audit.md"

usage() {
  echo "Usage: $0 <project-directory>"
  echo "Scans React class components and generates a migration audit report."
  echo "Example: $0 /path/to/my-react-app"
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

echo "🔍 Scanning React class components in: $PROJECT_DIR"
echo ""

# Find JS/TSX source files
SOURCE_FILES=$(
  find "$PROJECT_DIR" -type f \( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' \) \
    -not -path '*/node_modules/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' \
    -not -path '*/.git/*' \
    2>/dev/null || true
)

if [ -z "$SOURCE_FILES" ]; then
  echo "⚠️  No React source files found."
  exit 0
fi

echo "📄 Found $(echo "$SOURCE_FILES" | wc -l | tr -d ' ') source files to scan."
echo ""

# --- Scan 1: Class component declarations ---
echo "--- Class Component Declarations ---"
CLASS_COMPONENTS=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -ln 'extends React\.Component\|extends Component\|extends React\.PureComponent\|extends PureComponent' 2>/dev/null || true
)
if [ -z "$CLASS_COMPONENTS" ]; then
  echo "  ✅ No class components found — codebase may already be hooks-based."
else
  CLASS_COUNT=$(echo "$CLASS_COMPONENTS" | wc -l | tr -d ' ')
  echo "  Found $CLASS_COUNT files with class components:"
  echo ""
  echo "$CLASS_COMPONENTS" | while IFS= read -r f; do
    rel_path="${f#$PROJECT_DIR/}"
    # Extract component name
    name=$(grep -o 'class [A-Za-z]* extends' "$f" 2>/dev/null | head -1 | sed 's/class //;s/ extends//' || echo "unknown")
    echo "  - $rel_path ($name)"
  done
fi
echo ""

# --- Scan 2: Lifecycle methods ---
echo "--- Lifecycle Methods Found ---"
LIFECYCLE_PATTERN="componentDidMount\|componentDidUpdate\|componentWillUnmount\|shouldComponentUpdate\|componentWillReceiveProps\|componentWillMount\|getDerivedStateFromProps\|getSnapshotBeforeUpdate"
LIFECYCLE=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n "$LIFECYCLE_PATTERN" 2>/dev/null || true
)
if [ -z "$LIFECYCLE" ]; then
  echo "  (none found)"
else
  echo "$LIFECYCLE" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 3: Legacy lifecycle methods ---
echo "--- Legacy Lifecycle Methods (need redesign) ---"
LEGACY=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'componentWillReceiveProps\|componentWillMount' 2>/dev/null || true
)
if [ -z "$LEGACY" ]; then
  echo "  ✅ No legacy lifecycle methods found"
else
  echo "$LEGACY" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  ⚠️  $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 4: this.state usage ---
echo "--- this.state / this.setState Usage ---"
STATE_USAGE=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'this\.state\|this\.setState' 2>/dev/null || true
)
if [ -z "$STATE_USAGE" ]; then
  echo "  (none found)"
else
  echo "$STATE_USAGE" | head -30 | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
  total=$(echo "$STATE_USAGE" | wc -l | tr -d ' ')
  if [ "$total" -gt 30 ]; then
    echo "  ... and $((total - 30)) more occurrences"
  fi
fi
echo ""

# --- Scan 5: this.instance variables (non-state) ---
echo "--- Instance Variables (this.xxx — may need useRef) ---"
INSTANCE_VARS=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'this\.\(interval\|timer\|timeout\|subscription\|cancelToken\|abort\|_\|instance\|ref\|node\|el\|current\)' 2>/dev/null \
    | grep -v 'this\.state\|this\.props\|this\.setState\|this\.refs' || true
)
if [ -z "$INSTANCE_VARS" ]; then
  echo "  (none found)"
else
  echo "$INSTANCE_VARS" | head -20 | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
  total=$(echo "$INSTANCE_VARS" | wc -l | tr -d ' ')
  if [ "$total" -gt 20 ]; then
    echo "  ... and $((total - 20)) more occurrences"
  fi
fi
echo ""

# --- Scan 6: React.createRef ---
echo "--- React.createRef Usage ---"
CREATEREF=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'createRef\|React\.createRef' 2>/dev/null || true
)
if [ -z "$CREATEREF" ]; then
  echo "  (none found)"
else
  echo "$CREATEREF" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Generate report ---
{
  echo "# React Class Component Audit Report"
  echo ""
  echo "Generated: $(date)"
  echo "Project: $PROJECT_DIR"
  echo ""
  echo "## Class Component Files"
  echo ""
  echo "$CLASS_COMPONENTS" | while IFS= read -r f; do
    [ -z "$f" ] && continue
    rel_path="${f#$PROJECT_DIR/}"
    name=$(grep -o 'class [A-Za-z]* extends' "$f" 2>/dev/null | head -1 | sed 's/class //;s/ extends//' || echo "unknown")
    echo "- $rel_path ($name)"
  done
  echo ""
  echo "## Lifecycle Methods"
  echo ""
  echo '```'
  echo "$LIFECYCLE"
  echo '```'
  echo ""
  echo "## Legacy Lifecycle Methods"
  echo ""
  echo '```'
  echo "$LEGACY"
  echo '```'
  echo ""
  echo "## this.state / this.setState Usage"
  echo ""
  echo '```'
  echo "$STATE_USAGE"
  echo '```'
  echo ""
  echo "## Instance Variables (may need useRef)"
  echo ""
  echo '```'
  echo "$INSTANCE_VARS"
  echo '```'
  echo ""
  echo "## React.createRef Usage"
  echo ""
  echo '```'
  echo "$CREATEREF"
  echo '```'
} > "$PROJECT_DIR/$REPORT_FILE"

echo "✅ Scan complete. Report: $PROJECT_DIR/$REPORT_FILE"
