#!/usr/bin/env bash
# AI Code Walkthrough - Diff Context Extractor
# Usage: ./extract-diff-context.sh [diff-source]
# Extracts surrounding context for each changed hunk in a diff, making it
# easier to review AI-generated changes in context.
# Safe: read-only, no file modifications. Input-validated, injection-safe.
#
# Examples:
#   ./extract-diff-context.sh                    # reads git diff (unstaged)
#   ./extract-diff-context.sh --cached           # reads git diff --cached (staged)
#   ./extract-diff-context.sh main...HEAD        # reads diff between branches
#   ./extract-diff-context.sh HEAD~3             # reads last 3 commits
#   ./extract-diff-context.sh path/to/file.diff  # reads a diff file

set -euo pipefail

DIFF_SOURCE="${1:-}"
CONTEXT_LINES="${2:-5}"
OUTPUT_FILE="diff-context-review.md"

usage() {
  echo "Usage: $0 [diff-source] [context-lines]"
  echo "Extracts surrounding context for each changed hunk in a diff."
  echo ""
  echo "Arguments:"
  echo "  diff-source    Git revision, range, or path to diff file (default: unstaged changes)"
  echo "  context-lines  Number of context lines around each hunk (default: 5, max: 20)"
  echo ""
  echo "Examples:"
  echo "  $0                     # unstaged changes"
  echo "  $0 --cached            # staged changes"
  echo "  $0 main...HEAD         # changes on current branch vs main"
  echo "  $0 HEAD~3              # last 3 commits"
  echo "  $0 changes.diff 10     # diff file with 10 context lines"
  exit 1
}

# --- Validation ---

# Validate context-lines is a positive integer
case "$CONTEXT_LINES" in
  ''|*[!0-9]*) echo "Error: context-lines must be a positive integer, got: $CONTEXT_LINES"; exit 1 ;;
esac
[ "$CONTEXT_LINES" -gt 0 ] || { echo "Error: context-lines must be greater than 0"; exit 1; }
[ "$CONTEXT_LINES" -le 20 ] || { echo "Error: context-lines must be 20 or fewer (got $CONTEXT_LINES)"; exit 1; }

# --- Get the diff ---

DIFF_CONTENT=""

if [ -z "$DIFF_SOURCE" ]; then
  # Default: unstaged changes
  DIFF_CONTENT=$(git diff 2>/dev/null || true)
elif [ -f "$DIFF_SOURCE" ]; then
  # It's a file path — read the diff file
  # Validate: no path traversal
  case "$DIFF_SOURCE" in
    *"/../"*|*"/.." ) echo "Error: path traversal detected in: $DIFF_SOURCE"; exit 1 ;;
  esac
  [ -r "$DIFF_SOURCE" ] || { echo "Error: diff file not readable: $DIFF_SOURCE"; exit 1; }
  DIFF_CONTENT=$(cat "$DIFF_SOURCE")
else
  # It's a git revision/range
  DIFF_CONTENT=$(git diff "$DIFF_SOURCE" 2>/dev/null || true)
  if [ -z "$DIFF_CONTENT" ]; then
    # Try git diff with the argument as-is (could be --cached, etc.)
    DIFF_CONTENT=$(git diff "$DIFF_SOURCE" 2>/dev/null || true)
  fi
fi

if [ -z "$DIFF_CONTENT" ]; then
  echo "No diff content found. Check your git status or diff source."
  exit 0
fi

# --- Parse the diff ---

echo "🔍 AI Code Walkthrough — Diff Context Extractor"
echo "================================================"
echo "Context lines: $CONTEXT_LINES"
echo ""

# Count files changed
FILE_COUNT=$(echo "$DIFF_CONTENT" | grep -c '^diff --git' || true)
echo "Files changed: $FILE_COUNT"
echo ""

# Generate the review document
{
  echo "# AI Code Walkthrough — Diff Context Review"
  echo ""
  echo "Generated: $(date)"
  echo "Context lines: $CONTEXT_LINES"
  echo ""

  # Process each file
  CURRENT_FILE=""
  while IFS= read -r line; do
    case "$line" in
      diff\ --git\ *)
        # Extract the file path from "diff --git a/path b/path"
        CURRENT_FILE=$(echo "$line" | sed 's/.* b\///')
        echo "## File: $CURRENT_FILE"
        echo ""
        ;;
      @@*)
        # Hunk header — extract line numbers
        echo "### Hunk: $line"
        echo ""
        echo '```diff'
        echo "$line"
        # Collect context lines around this hunk
        HUNK_LINES=$(echo "$DIFF_CONTENT" | grep -A "$CONTEXT_LINES" "^$line$" || true)
        echo "$HUNK_LINES" | tail -n +2
        echo '```'
        echo ""
        echo "**Review notes:**"
        echo "- What changed:"
        echo "- Assumptions in this change:"
        echo "- Risks:"
        echo ""
        ;;
    esac
  done <<< "$DIFF_CONTENT"

  echo "## Cross-Cutting Review"
  echo ""
  echo "- **Security:**"
  echo "- **Performance:**"
  echo "- **Correctness:**"
  echo "- **Maintainability:**"
  echo ""
  echo "## Verdict"
  echo ""
  echo "- [ ] ✅ Safe to commit"
  echo "- [ ] ⚠️ Needs review before commit"
  echo "- [ ] ❌ Fix before commit"
} > "$OUTPUT_FILE"

echo "📄 Review template saved to: $OUTPUT_FILE"
echo ""
echo "💡 Next: Run the AI Code Walkthrough skill with this file for a full walkthrough."
echo "   /ai-code-walkthrough Walk me through $OUTPUT_FILE"
