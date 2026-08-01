#!/usr/bin/env bash
# Redux → Zustand Migrator - Redux Store Audit Scanner
# Usage: ./audit-redux-store.sh [project-directory]
# Scans Redux store definitions and generates a migration audit report.
# Safe: read-only, no file modifications. Input-validated, injection-safe.

set -euo pipefail

PROJECT_DIR="${1:-}"
REPORT_FILE="redux-store-audit.md"

usage() {
  echo "Usage: $0 <project-directory>"
  echo "Scans Redux store definitions and generates a migration audit report."
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

echo "🔍 Scanning Redux store in: $PROJECT_DIR"
echo ""

# Find JS/TS source files
SOURCE_FILES=$(
  find "$PROJECT_DIR" -type f \( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' \) \
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

# --- Scan 1: Store configuration ---
echo "--- Store Configuration (configureStore / createStore) ---"
STORE_CONFIG=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'configureStore\|createStore\|createSlice' 2>/dev/null || true
)
if [ -z "$STORE_CONFIG" ]; then
  echo "  (none found)"
else
  echo "$STORE_CONFIG" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 2: Reducer definitions ---
echo "--- Reducer Definitions (createSlice / combineReducers / reducer) ---"
REDUCERS=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'createSlice\|combineReducers\|reducers:\|reducer:' 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$REDUCERS" ]; then
  echo "  (none found)"
else
  echo "$REDUCERS" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 3: Middleware ---
echo "--- Middleware Usage (thunk/saga/observable/custom) ---"
MIDDLEWARE=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'redux-thunk\|redux-saga\|redux-observable\|middleware:\|applyMiddleware\|createSagaMiddleware\|sagaMiddleware' 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$MIDDLEWARE" ]; then
  echo "  (none found)"
else
  echo "$MIDDLEWARE" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 4: Memoized selectors ---
echo "--- Memoized Selectors (createSelector / reselect) ---"
SELECTORS=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'createSelector\|reselect' 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$SELECTORS" ]; then
  echo "  (none found)"
else
  echo "$SELECTORS" | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
fi
echo ""

# --- Scan 5: Normalized data (createEntityAdapter) ---
echo "--- Normalized Data (createEntityAdapter / entities) ---"
NORMALIZED=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'createEntityAdapter\|entities:\|ids:\|getInitialState' 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$NORMALIZED" ]; then
  echo "  (none found)"
else
  echo "$NORMALIZED" | head -20 | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
  total=$(echo "$NORMALIZED" | wc -l | tr -d ' ')
  if [ "$total" -gt 20 ]; then
    echo "  ... and $((total - 20)) more occurrences"
  fi
fi
echo ""

# --- Scan 6: Async thunks ---
echo "--- Async Thunks (createAsyncThunk / dispatch) ---"
THUNKS=$(
  echo "$SOURCE_FILES" | tr '\n' '\0' | xargs -0 grep -n 'createAsyncThunk\|dispatch.*async\|dispatch.*await' 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$THUNKS" ]; then
  echo "  (none found)"
else
  echo "$THUNKS" | head -20 | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
  total=$(echo "$THUNKS" | wc -l | tr -d ' ')
  if [ "$total" -gt 20 ]; then
    echo "  ... and $((total - 20)) more occurrences"
  fi
fi
echo ""

# --- Scan 7: useSelector / useDispatch ---
echo "--- React-Redux Hooks (useSelector / useDispatch) ---"
HOOKS=$(
  echo "$SOURCE_FILES" | tr '\n'\0' | xargs -0 grep -n 'useSelector\|useDispatch' 2>/dev/null \
    | grep -v 'node_modules' || true
)
if [ -z "$HOOKS" ]; then
  echo "  (none found)"
else
  HOOK_COUNT=$(echo "$HOOKS" | wc -l | tr -d ' ')
  echo "  $HOOK_COUNT total useSelector/useDispatch calls"
  echo "$HOOKS" | head -15 | while IFS=: read -r file line content; do
    rel_path="${file#$PROJECT_DIR/}"
    echo "  - $rel_path:$line  $content"
  done
  if [ "$HOOK_COUNT" -gt 15 ]; then
    echo "  ... and $((HOOK_COUNT - 15)) more"
  fi
fi
echo ""

# --- Generate report ---
{
  echo "# Redux Store Audit Report"
  echo ""
  echo "Generated: $(date)"
  echo "Project: $PROJECT_DIR"
  echo ""
  echo "## Store Configuration"
  echo ""
  echo '```'
  echo "$STORE_CONFIG"
  echo '```'
  echo ""
  echo "## Reducer Definitions"
  echo ""
  echo '```'
  echo "$REDUCERS"
  echo '```'
  echo ""
  echo "## Middleware"
  echo ""
  echo '```'
  echo "$MIDDLEWARE"
  echo '```'
  echo ""
  echo "## Memoized Selectors"
  echo ""
  echo '```'
  echo "$SELECTORS"
  echo '```'
  echo ""
  echo "## Normalized Data"
  echo ""
  echo '```'
  echo "$NORMALIZED"
  echo '```'
  echo ""
  echo "## Async Thunks"
  echo ""
  echo '```'
  echo "$THUNKS"
  echo '```'
  echo ""
  echo "## React-Redux Hooks"
  echo ""
  echo '```'
  echo "$HOOKS"
  echo '```'
} > "$PROJECT_DIR/$REPORT_FILE"

echo "✅ Scan complete. Report: $PROJECT_DIR/$REPORT_FILE"
