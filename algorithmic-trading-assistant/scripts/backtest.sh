#!/usr/bin/env bash
# Algorithmic Trading Assistant - Backtest Script
# Usage: ./backtest.sh <strategy-file> <start-date> <end-date>
# Securely validates inputs and generates backtest configuration.

set -euo pipefail

STRATEGY="${1:-}"
START="${2:-}"
END="${3:-}"

usage() {
  echo "Usage: $0 <strategy-file> <start-date> <end-date>"
  echo "Example: $0 strategy.py 2023-01-01 2024-01-01"
  exit 1
}

# Validate required args
[ -z "$STRATEGY" ] || [ -z "$START" ] || [ -z "$END" ] && usage

# Validate date format (YYYY-MM-DD)
date_re='^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
[[ "$START" =~ $date_re ]] || { echo "Error: start-date must be YYYY-MM-DD"; exit 1; }
[[ "$END" =~ $date_re ]] || { echo "Error: end-date must be YYYY-MM-DD"; exit 1; }

# Validate strategy file exists and has safe extension
STRATEGY_DIR="."
STRATEGY_PATH="${STRATEGY_DIR}/${STRATEGY}"
[ -f "$STRATEGY_PATH" ] || { echo "Error: strategy file not found: $STRATEGY_PATH"; exit 1; }

case "${STRATEGY##*.}" in
  py|js|ts|ipynb) ;;
  *) echo "Error: unsupported strategy file type (.${STRATEGY##*.}). Supported: .py, .js, .ts, .ipynb"; exit 1 ;;
esac

echo "📈 Backtest Configuration"
echo "========================"
echo "Strategy: $STRATEGY"
echo "Period:   $START to $END"
echo ""

# Generate backtest config as JSON (safe, no eval)
cat <<EOF
{
  "strategy": "$STRATEGY",
  "start_date": "$START",
  "end_date": "$END",
  "framework": "python3",
  "status": "configured"
}
EOF

echo ""
echo "✅ Backtest configuration complete. Run the skill in Claude Code for analysis."
