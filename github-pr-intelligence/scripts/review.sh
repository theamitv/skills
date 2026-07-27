#!/usr/bin/env bash
# GitHub PR Intelligence - PR Review Script
# Usage: ./review.sh <pr-number>
# Fetches PR metadata and diff for analysis.

set -euo pipefail

PR_NUMBER="${1:-}"

usage() {
  echo "Usage: $0 <pr-number>"
  echo "Example: $0 124"
  exit 1
}

[ -z "$PR_NUMBER" ] && usage

# Validate PR number is numeric
num_re='^[0-9]+$'
[[ "$PR_NUMBER" =~ $num_re ]] || { echo "Error: PR number must be a positive integer"; exit 1; }

# Check gh CLI availability
command -v gh &>/dev/null || { echo "Error: GitHub CLI (gh) not installed. Install: brew install gh"; exit 1; }

# Check authentication
gh auth status 2>/dev/null || { echo "Error: not authenticated with GitHub. Run: gh auth login"; exit 1; }

echo "🔍 Fetching PR #${PR_NUMBER} details..."
echo ""

# Fetch PR metadata
if ! gh pr view "$PR_NUMBER" --json title,body,author,headRefName,baseRefName,additions,deletions,files,changedFiles,reviews,comments,commits,createdAt,mergedAt,closedAt,state,mergeable,rebaseable 2>/dev/null; then
  echo "Error: PR #${PR_NUMBER} not found or not accessible"
  exit 1
fi

echo ""
echo "📂 Fetching PR diff..."
echo ""

if ! gh pr diff "$PR_NUMBER" 2>/dev/null; then
  echo "Error: could not fetch diff for PR #${PR_NUMBER}"
  exit 1
fi

echo ""
echo "✅ Review data collected. Run the skill in Claude Code to analyze."
