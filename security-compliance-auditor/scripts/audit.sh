#!/usr/bin/env bash
# Security & Compliance Auditor - Audit Script
# Usage: ./audit.sh <target-directory>
# Performs initial security scan of a codebase. Read-only operations.

set -euo pipefail

TARGET="${1:-}"

usage() {
  echo "Usage: $0 <target-directory>"
  echo "Example: $0 ./my-project"
  exit 1
}

[ -z "$TARGET" ] && usage

# Resolve to absolute path and validate
TARGET_ABS="$(cd "$TARGET" 2>/dev/null && pwd -P)" || {
  echo "Error: cannot access directory: $TARGET"
  exit 1
}

[ -d "$TARGET_ABS" ] || { echo "Error: not a directory: $TARGET"; exit 1; }

echo "🔒 Security Audit: $TARGET_ABS"
echo "========================"
echo ""

# Dependency audit (safe: only if package.json exists)
echo "=== Dependency Audit ==="
if [ -f "$TARGET_ABS/package.json" ]; then
  if command -v npm &>/dev/null; then
    echo "Running npm audit..."
    (cd "$TARGET_ABS" && npm audit --production 2>/dev/null) || echo "npm audit completed with warnings"
  else
    echo "npm not installed"
  fi
else
  echo "No package.json found (skipping npm audit)"
fi
echo ""

# Secrets scan (safe: no eval, no glob injection)
echo "=== Secrets Scan ==="
secrets_found=0
while IFS= read -r -d '' file; do
  # Skip vendor directories
  case "$file" in
    */node_modules/*|*/.git/*|*/vendor/*|*/dist/*|*/build/*|*/.next/*) continue ;;
  esac
  if grep -EHn '(password|secret|api_key|apiKey|access_key|private_key|token|credential)\s*[:=]\s*['"'"'"'"]['"'"'"'"]' "$file" 2>/dev/null; then
    secrets_found=1
  fi
done < <(find "$TARGET_ABS" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.go" -o -name "*.rb" -o -name "*.php" -o -name "*.yml" -o -name "*.yaml" -o -name "*.json" -o -name "*.tf" \) -print0 2>/dev/null)

if [ "$secrets_found" -eq 0 ]; then
  echo "No obvious secrets found in source files"
fi
echo ""

# Check for hardcoded IP URLs
echo "=== Hardcoded URLs Check ==="
urls_found=0
while IFS= read -r -d '' file; do
  case "$file" in
    */node_modules/*|*/.git/*|*/vendor/*|*/dist/*|*/build/*) continue ;;
  esac
  if grep -EHn 'https?://[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' "$file" 2>/dev/null; then
    urls_found=1
  fi
done < <(find "$TARGET_ABS" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.go" -o -name "*.rb" -o -name "*.php" \) -print0 2>/dev/null)

if [ "$urls_found" -eq 0 ]; then
  echo "No hardcoded IP URLs found"
fi
echo ""

echo "✅ Initial audit complete. Feed results into the skill for detailed analysis."
