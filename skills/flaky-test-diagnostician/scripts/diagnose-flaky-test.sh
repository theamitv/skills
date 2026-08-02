#!/usr/bin/env bash
# Flaky Test Diagnostician - Diagnosis Runner
# Usage: ./diagnose-flaky-test.sh <test-file> [test-name] [runs]
# Runs a test N times, records pass/fail, and outputs structured evidence for classification.
# Safe: read-only, no file modifications. Input-validated, injection-safe.
#
# Examples:
#   ./diagnose-flaky-test.sh src/users/UserService.test.ts
#   ./diagnose-flaky-test.sh src/users/UserService.test.ts "should create user" 20
#   ./diagnose-flaky-test.sh src/components/Login.test.tsx 10

set -euo pipefail

TEST_FILE="${1:-}"
TEST_NAME="${2:-}"
RUNS="${3:-10}"
REPORT_FILE="flaky-test-diagnosis.md"

# Secure temp files
OUTPUT_FILE="$(mktemp /tmp/flaky-test-output-XXXXXX 2>/dev/null || echo "/tmp/flaky-test-output-$$")"
FIRST_FAILURE_FILE="$(mktemp /tmp/flaky-test-first-failure-XXXXXX 2>/dev/null || echo "/tmp/flaky-test-first-failure-$$")"
cleanup() { rm -f "$OUTPUT_FILE" "$FIRST_FAILURE_FILE"; }
trap cleanup EXIT

usage() {
  echo "Usage: $0 <test-file> [test-name] [runs]"
  echo "Runs a test N times and records pass/fail for flaky test diagnosis."
  echo ""
  echo "Arguments:"
  echo "  test-file   Path to the test file (required)"
  echo "  test-name   Specific test name to run (optional, runs all tests in file if omitted)"
  echo "  runs        Number of times to rerun (default: 10, max: 100)"
  echo ""
  echo "Examples:"
  echo "  $0 src/users/UserService.test.ts"
  echo "  $0 src/users/UserService.test.ts \"should create user\" 20"
  echo "  $0 src/components/Login.test.tsx 10"
  exit 1
}

# --- Validation ---

[ -n "$TEST_FILE" ] || usage

# Validate: file exists and is readable
[ -f "$TEST_FILE" ] || { echo "Error: test file not found: $TEST_FILE"; exit 1; }
[ -r "$TEST_FILE" ] || { echo "Error: test file not readable: $TEST_FILE"; exit 1; }

# Validate: no path traversal
case "$TEST_FILE" in
  *"/../"*|*"/.." ) echo "Error: path traversal detected in: $TEST_FILE"; exit 1 ;;
esac

# Validate: runs is a positive integer
case "$RUNS" in
  ''|*[!0-9]*) echo "Error: runs must be a positive integer, got: $RUNS"; exit 1 ;;
esac
[ "$RUNS" -gt 0 ] || { echo "Error: runs must be greater than 0"; exit 1; }
[ "$RUNS" -le 100 ] || { echo "Error: runs must be 100 or fewer (got $RUNS)"; exit 1; }

# Validate: test name contains only safe characters (alphanumeric, spaces, common punctuation)
if [ -n "$TEST_NAME" ]; then
  # Safe pattern: letters, numbers, spaces, and common punctuation (no shell metacharacters)
  name_re='^[A-Za-z0-9 _.,!@#$%^&()=+\[\]{}:;\"'"'"'-]+$'
  if ! [[ "$TEST_NAME" =~ $name_re ]]; then
    echo "Error: test name contains invalid or unsafe characters"
    exit 1
  fi
fi

# --- Detect test runner ---
detect_runner() {
  # Resolve to absolute path to avoid infinite loop with dirname on relative paths
  local test_dir
  test_dir="$(dirname "$TEST_FILE")"
  test_dir="$(cd "$test_dir" && pwd -P)" || { echo "Error: cannot resolve test file directory"; exit 1; }
  local dir="$test_dir"
  local max_depth=20

  # Walk up to find package.json (max 20 levels to prevent infinite loop)
  while [ "$dir" != "/" ] && [ "$max_depth" -gt 0 ]; do
    if [ -f "$dir/package.json" ]; then
      if grep -q '"vitest"' "$dir/package.json" 2>/dev/null; then
        echo "vitest"
        return
      elif grep -q '"jest"' "$dir/package.json" 2>/dev/null; then
        echo "jest"
        return
      elif grep -q '"playwright"' "$dir/package.json" 2>/dev/null; then
        echo "playwright"
        return
      elif grep -q '"cypress"' "$dir/package.json" 2>/dev/null; then
        echo "cypress"
        return
      fi
    fi
    dir="$(dirname "$dir")"
    max_depth=$((max_depth - 1))
  done

  # Fallback: check for config files in the test file's directory
  if [ -f "$test_dir/vitest.config.ts" ] || [ -f "$test_dir/vitest.config.js" ]; then
    echo "vitest"
  elif [ -f "$test_dir/jest.config.ts" ] || [ -f "$test_dir/jest.config.js" ] || [ -f "$test_dir/jest.config.mjs" ]; then
    echo "jest"
  elif [ -f "$test_dir/playwright.config.ts" ] || [ -f "$test_dir/playwright.config.js" ]; then
    echo "playwright"
  elif [ -f "$test_dir/cypress.config.ts" ] || [ -f "$test_dir/cypress.config.js" ]; then
    echo "cypress"
  else
    echo "unknown"
  fi
}

RUNNER=$(detect_runner)
echo "🔍 Flaky Test Diagnostician"
echo "================================"
echo "Test file: $TEST_FILE"
if [ -n "$TEST_NAME" ]; then
  echo "Test name: $TEST_NAME"
fi
echo "Runs:      $RUNS"
echo "Runner:    $RUNNER"
echo ""

# --- Build runner command (as array to avoid eval) ---
CMD_ARGS=()
case "$RUNNER" in
  vitest)
    CMD_ARGS=(npx vitest run "$TEST_FILE" --reporter=verbose)
    if [ -n "$TEST_NAME" ]; then
      CMD_ARGS+=(-t "$TEST_NAME")
    fi
    ;;
  jest)
    CMD_ARGS=(npx jest "$TEST_FILE" --verbose --no-coverage)
    if [ -n "$TEST_NAME" ]; then
      CMD_ARGS+=(-t "$TEST_NAME")
    fi
    ;;
  playwright)
    CMD_ARGS=(npx playwright test "$TEST_FILE" --reporter=line)
    if [ -n "$TEST_NAME" ]; then
      CMD_ARGS+=(-g "$TEST_NAME")
    fi
    ;;
  cypress)
    CMD_ARGS=(npx cypress run --spec "$TEST_FILE")
    if [ -n "$TEST_NAME" ]; then
      CMD_ARGS+=(--env "grep=$TEST_NAME")
    fi
    ;;
  *)
    if ! command -v npx &>/dev/null; then
      echo "Error: no test runner detected and npx not available"
      exit 1
    fi
    CMD_ARGS=(npx vitest run "$TEST_FILE" --reporter=verbose)
    if [ -n "$TEST_NAME" ]; then
      CMD_ARGS+=(-t "$TEST_NAME")
    fi
    ;;
esac

# --- Run the test N times ---
echo "Running test $RUNS times..."
echo ""

PASSES=0
FAILURES=0
RESULTS=()

for i in $(seq 1 "$RUNS"); do
  printf "  Run %2d/$RUNS ... " "$i"

  # Run the test and capture exit code (array execution, no eval)
  set +e
  "${CMD_ARGS[@]}" > "$OUTPUT_FILE" 2>&1
  EXIT_CODE=$?
  set -e

  if [ "$EXIT_CODE" -eq 0 ]; then
    echo "✅ PASS"
    PASSES=$((PASSES + 1))
    RESULTS+=("pass")
  else
    echo "❌ FAIL"
    FAILURES=$((FAILURES + 1))
    RESULTS+=("fail")
    # Capture failure output (first run only)
    if [ "$FAILURES" -eq 1 ]; then
      cp "$OUTPUT_FILE" "$FIRST_FAILURE_FILE"
    fi
  fi
done

# --- Results ---
echo ""
echo "================================"
echo "📊 Results"
echo "================================"
echo "Total runs: $RUNS"
echo "Passes:     $PASSES"
echo "Failures:   $FAILURES"
echo "Pass rate:  $(awk "BEGIN { printf \"%.1f%%\", ($PASSES / $RUNS) * 100 }")"

# Determine flakiness level
if [ "$PASSES" -eq "$RUNS" ]; then
  echo "Verdict:    ✅ Not flaky (always passes)"
elif [ "$FAILURES" -eq "$RUNS" ]; then
  echo "Verdict:    ❌ Not flaky (always fails — test is broken)"
else
  echo "Verdict:    ⚠️  Flaky confirmed"
fi

echo ""

# --- Generate report ---
{
  echo "# Flaky Test Diagnosis Report"
  echo ""
  echo "Generated: $(date)"
  echo "Test file: $TEST_FILE"
  if [ -n "$TEST_NAME" ]; then
    echo "Test name: $TEST_NAME"
  fi
  echo "Runs: $RUNS"
  echo "Runner: $RUNNER"
  echo ""
  echo "## Results"
  echo ""
  echo "| Metric | Value |"
  echo "|--------|-------|"
  echo "| Total runs | $RUNS |"
  echo "| Passes | $PASSES |"
  echo "| Failures | $FAILURES |"
  echo "| Pass rate | $(awk "BEGIN { printf \"%.1f%%\", ($PASSES / $RUNS) * 100 }") |"
  echo ""
  echo "## Run Sequence"
  echo ""
  echo '```'
  for ((idx=0; idx<${#RESULTS[@]}; idx++)); do
    echo "  Run $((idx+1)): ${RESULTS[$idx]}"
  done
  echo '```'
  echo ""
  echo "## First Failure Output"
  echo ""
  echo '```'
  if [ -f "$FIRST_FAILURE_FILE" ]; then
    cat "$FIRST_FAILURE_FILE"
  else
    echo "(no failures recorded)"
  fi
  echo '```'
  echo ""
  echo "## Next Steps"
  echo ""
  echo "Feed this report into the Flaky Test Diagnostician skill for root cause classification."
  echo "The skill will run additional isolation steps (suite context, reverse order, varied timing)"
  echo "and classify the failure against the six root causes."
} > "$REPORT_FILE"

echo "📄 Report saved to: $REPORT_FILE"
echo ""
echo "💡 Next: Run the Flaky Test Diagnostician skill with this report for classification."
echo "   /flaky-test-diagnostician Diagnose flaky test using $REPORT_FILE"
