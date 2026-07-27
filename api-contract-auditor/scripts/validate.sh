#!/usr/bin/env bash
# API Contract Auditor - Validation Script
# Usage: ./validate.sh <openapi-spec-file>
# Securely validates OpenAPI/Swagger spec files.

set -euo pipefail

SPEC_FILE="${1:-}"

usage() {
  echo "Usage: $0 <openapi-spec-file>"
  echo "Example: $0 ./openapi.yaml"
  exit 1
}

[ -z "$SPEC_FILE" ] && usage

# Resolve to absolute path and validate it's within allowed directories
SPEC_PATH="$(cd "$(dirname "$SPEC_FILE")" 2>/dev/null && pwd -P)/$(basename "$SPEC_FILE")" || {
  echo "Error: cannot resolve path: $SPEC_FILE"
  exit 1
}

[ -f "$SPEC_PATH" ] || { echo "Error: file not found: $SPEC_FILE"; exit 1; }

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

# Validate JSON/YAML format safely using python3 (no eval)
if command -v python3 &>/dev/null; then
  python3 -c "
import json, yaml, sys
try:
    with open('$SPEC_PATH') as f:
        if '$SPEC_PATH'.endswith('.json'):
            data = json.load(f)
            print('✅ Valid JSON format')
        else:
            data = yaml.safe_load(f)
            print('✅ Valid YAML format')
    info = data.get('info', {})
    print()
    print('=== API Info ===')
    print('Title:     ' + info.get('title', 'N/A'))
    print('Version:   ' + info.get('version', 'N/A'))
    paths = data.get('paths', {})
    print('Endpoints: ' + str(len(paths)))
except Exception as e:
    print('❌ Validation failed: ' + str(e))
    sys.exit(1)
" 2>&1 || echo "⚠️  Install PyYAML for YAML validation: pip install pyyaml"
else
  echo "⚠️  Install python3 for format validation"
fi

echo ""
echo "✅ Validation complete. Feed into the skill for detailed analysis."
