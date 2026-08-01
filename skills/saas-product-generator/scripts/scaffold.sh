#!/usr/bin/env bash
# SaaS Product Generator - Project Scaffold Script
# Usage: ./scaffold.sh <product-name>
# Creates a safe project directory structure.

set -euo pipefail

PRODUCT_NAME="${1:-}"

usage() {
  echo "Usage: $0 <product-name>"
  echo "Example: $0 gym-management"
  exit 1
}

[ -z "$PRODUCT_NAME" ] && usage

# Validate product name: alphanumeric, hyphens, underscores only
name_re='^[a-z0-9][a-z0-9_-]*$'
[[ "$PRODUCT_NAME" =~ $name_re ]] || {
  echo "Error: product name must start with a lowercase letter or number and contain only lowercase letters, numbers, hyphens, and underscores"
  exit 1
}

# Prevent path traversal
case "$PRODUCT_NAME" in
  *..*|*/*|*\\*) echo "Error: invalid product name (path separators not allowed)"; exit 1 ;;
esac

DIR="./$PRODUCT_NAME"

# Check if directory already exists
if [ -d "$DIR" ]; then
  echo "Error: directory '$DIR' already exists"
  exit 1
fi

mkdir -p "$DIR"/{docs,src,infra,tests}

echo "📁 Scaffolding project: $PRODUCT_NAME"
echo "  ├── docs/"
echo "  ├── src/"
echo "  ├── infra/"
echo "  └── tests/"
echo ""
echo "✅ Project scaffold created at $DIR"
echo "Run the skill in Claude Code to generate the full blueprint."
