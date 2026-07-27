#!/usr/bin/env bash
# Codebase Knowledge Builder - Repository Analysis Script
# Usage: ./analyze.sh <repository-path>
# Securely analyzes a repository structure and metadata.

set -euo pipefail

REPO_PATH="${1:-}"

usage() {
  echo "Usage: $0 <repository-path>"
  echo "Example: $0 ./my-project"
  exit 1
}

[ -z "$REPO_PATH" ] && usage

# Resolve to absolute path and validate it's a directory
REPO_ABS="$(cd "$REPO_PATH" 2>/dev/null && pwd -P)" || {
  echo "Error: cannot access directory: $REPO_PATH"
  exit 1
}

[ -d "$REPO_ABS" ] || { echo "Error: not a directory: $REPO_PATH"; exit 1; }

REPO_NAME="$(basename "$REPO_ABS")"

echo "📊 Repository Analysis: $REPO_NAME"
echo "================================"
echo ""

# Basic stats (safe: no eval, no glob injection)
echo "=== Repository Stats ==="
file_count=$(find "$REPO_ABS" -type f -not -path '*/\.git/*' 2>/dev/null | wc -l | tr -d ' ')
echo "Files:     $file_count"

if [ -d "$REPO_ABS/.git" ]; then
  commit_count=$(git -C "$REPO_ABS" rev-list --count HEAD 2>/dev/null || echo "N/A")
  branch_count=$(git -C "$REPO_ABS" branch -r 2>/dev/null | wc -l | tr -d ' ' || echo "N/A")
  echo "Commits:   $commit_count"
  echo "Branches:  $branch_count"
else
  echo "Commits:   N/A (not a git repository)"
fi
echo ""

# Language detection (safe: no eval)
echo "=== Language Detection ==="
if command -v cloc &>/dev/null; then
  cloc "$REPO_ABS" --quiet --hide-rate 2>/dev/null | head -20
else
  echo "Install cloc for detailed language breakdown: brew install cloc"
  echo ""
  # Fallback: count by extension (safe find usage)
  for ext in py js ts tsx go java rs rb php swift kt scala; do
    count=$(find "$REPO_ABS" -name "*.$ext" -not -path '*/\.git/*' -not -path '*/node_modules/*' 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ] && echo "  .$ext: $count files"
  done
fi
echo ""

# Package managers (safe: ls on known filenames)
echo "=== Package Managers ==="
found=false
for pm_file in package.json yarn.lock pnpm-lock.yaml go.mod Cargo.toml requirements.txt Gemfile composer.json; do
  if [ -f "$REPO_ABS/$pm_file" ]; then
    echo "  Found: $pm_file"
    found=true
  fi
done
$found || echo "  No package manager files found"
echo ""

echo "✅ Analysis data collected. Feed into the skill for detailed knowledge building."
