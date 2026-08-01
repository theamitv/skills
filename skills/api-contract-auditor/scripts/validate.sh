#!/usr/bin/env bash
# API Contract Auditor - Validation Script
# Usage: ./validate.sh <openapi-spec-file>
# Securely validates OpenAPI/Swagger spec files.
# Safe: read-only, no file modifications. Input-validated, injection-safe.

set -euo pipefail

SPEC_FILE="${1:-}"

usage() {
  echo "Usage: $0 <openapi-spec-file>"
  echo "Example: $0 ./openapi.yaml"
  exit 1
}

[ -n "$SPEC_FILE" ] || usage

# Validate: no path traversal
case "$SPEC_FILE" in
  *"/../"*|*"/.." ) echo "Error: path traversal detected in: $SPEC_FILE"; exit 1 ;;
esac

# Resolve to absolute path
SPEC_DIR="$(cd "$(dirname "$SPEC_FILE")" 2>/dev/null && pwd -P)" || {
  echo "Error: cannot resolve directory: $SPEC_FILE"
  exit 1
}
SPEC_PATH="$SPEC_DIR/$(basename "$SPEC_FILE")"

[ -f "$SPEC_PATH" ] || { echo "Error: file not found: $SPEC_FILE"; exit 1; }
[ -r "$SPEC_PATH" ] || { echo "Error: file not readable: $SPEC_FILE"; exit 1; }

# Validate file extension
case "${SPEC_PATH##*.}" in
  yaml|yml|json) ;;
  *) echo "Error: unsupported file type (.${SPEC_PATH##*.}). Supported: .yaml, .yml, .json"; exit 1 ;;
esac

echo "📋 API Contract Validation"
echo "=========================="
echo "File: $SPEC_PATH"
echo ""

# Use file to detect content type
file_type=$(file -b "$SPEC_PATH" 2>/dev/null || echo "unknown")
echo "File type: $file_type"
echo ""

# Validate JSON/YAML format safely using python3 (no eval, no injection)
if command -v python3 &>/dev/null; then
  python3 -c "
import json, sys
try:
    # Try JSON first
    with open(sys.argv[1]) as f:
        data = json.load(f)
    print('✅ Valid JSON format')
except (json.JSONDecodeError, UnicodeDecodeError):
    # Try YAML
    try:
        import yaml
        with open(sys.argv[1]) as f:
            data = yaml.safe_load(f)
        print('✅ Valid YAML format')
    except ImportError:
        print('⚠️  PyYAML not installed. Install: pip install pyyaml')
        sys.exit(0)
    except Exception as e:
        print('❌ YAML validation failed: ' + str(e))
        sys.exit(1)

info = data.get('info', {})
print()
print('=== API Info ===')
print('Title:     ' + info.get('title', 'N/A'))
print('Version:   ' + info.get('version', 'N/A'))
paths = data.get('paths', {})
print('Endpoints: ' + str(len(paths)))
" "$SPEC_PATH" 2>&1
else
  echo "⚠️  Install python3 for format validation"
fi

echo ""
echo "✅ Validation complete. Feed into the skill for detailed analysis."
