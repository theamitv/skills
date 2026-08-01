#!/usr/bin/env bash
# SaaS Code Generator - Environment Config Generator
# Usage: ./generate-env.sh [--env-file <path>] [--force]
# Generates a .env file with secure random secrets from .env.example.
#
# Security: reads from .env.example only, validates output, no secrets in logs.

set -euo pipefail

ENV_FILE=".env"
FORCE=false

usage() {
  echo "Usage: $0 [--env-file <path>] [--force]"
  echo "  --env-file <path>  Path to write .env file (default: ./.env)"
  echo "  --force            Overwrite existing .env file"
  exit 1
}

# ── Parse Arguments ─────────────────────────────────────────────────────────

while [ $# -gt 0 ]; do
  case "$1" in
    --env-file)
      shift
      ENV_FILE="${1:-}"
      [ -z "$ENV_FILE" ] && usage
      ;;
    --force) FORCE=true ;;
    *) usage ;;
  esac
  shift
done

# ── Validation ─────────────────────────────────────────────────────────────

EXAMPLE_FILE="$(dirname "$ENV_FILE")/.env.example"
[ ! -f "$EXAMPLE_FILE" ] && EXAMPLE_FILE=".env.example"

if [ ! -f "$EXAMPLE_FILE" ]; then
  echo "Error: .env.example not found in $(dirname "$ENV_FILE") or current directory"
  exit 1
fi

if [ -f "$ENV_FILE" ] && [ "$FORCE" = false ]; then
  echo "Error: $ENV_FILE already exists. Use --force to overwrite."
  exit 1
fi

# Prevent path traversal
case "$ENV_FILE" in
  *..*) echo "Error: invalid path (path traversal detected)"; exit 1 ;;
esac

# ── Generate Secrets ───────────────────────────────────────────────────────

generate_secret() {
  openssl rand -hex 32 2>/dev/null || python3 -c "import secrets; print(secrets.token_hex(32))" 2>/dev/null || {
    echo "Error: need openssl or python3 to generate secrets"
    exit 1
  }
}

generate_jwt_secret() {
  openssl rand -base64 48 2>/dev/null || python3 -c "import secrets; print(secrets.token_urlsafe(48))" 2>/dev/null || {
    echo "Error: need openssl or python3 to generate secrets"
    exit 1
  }
}

# ── Process Template ───────────────────────────────────────────────────────

process_template() {
  local line key value
  while IFS= read -r line || [ -n "$line" ]; do
    # Skip comments and empty lines
    case "$line" in
      ''|\#*) echo "$line"; continue ;;
    esac

    # Extract key (everything before =)
    key="${line%%=*}"

    # Check if this is a secret field
    case "$key" in
      JWT_SECRET)
        value="$(generate_jwt_secret)"
        echo "$key=$value"
        ;;
      *SECRET*|*SECRET_KEY*|*API_KEY*|*PASSWORD*)
        value="$(generate_secret)"
        echo "$key=$value"
        ;;
      *)
        # Keep default value from example
        echo "$line"
        ;;
    esac
  done < "$EXAMPLE_FILE"
}

# ── Write Output ───────────────────────────────────────────────────────────

process_template > "$ENV_FILE"

# Validate: ensure file is not empty and contains key=value pairs
if [ ! -s "$ENV_FILE" ]; then
  echo "Error: generated .env file is empty"
  rm -f "$ENV_FILE"
  exit 1
fi

line_count=$(grep -c '=' "$ENV_FILE" 2>/dev/null || true)
if [ "$line_count" -eq 0 ]; then
  echo "Error: generated .env file contains no key=value pairs"
  rm -f "$ENV_FILE"
  exit 1
fi

# Set restrictive permissions
chmod 600 "$ENV_FILE"

echo "✅ Generated $ENV_FILE with $line_count configuration values"
echo "   File permissions set to 600 (owner read/write only)"
echo ""
echo "⚠️  Review the generated values before using in production"
