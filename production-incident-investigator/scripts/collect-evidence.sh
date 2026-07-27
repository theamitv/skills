#!/usr/bin/env bash
# Production Incident Investigator - Evidence Collection Script
# Usage: ./collect-evidence.sh <incident-id>
# Collects system state for incident analysis. Read-only operations.

set -euo pipefail

INCIDENT_ID="${1:-}"

usage() {
  echo "Usage: $0 <incident-id>"
  echo "Example: $0 INC-2024-07-15"
  exit 1
}

[ -z "$INCIDENT_ID" ] && usage

# Validate incident ID format (alphanumeric, hyphens, underscores only)
id_re='^[A-Za-z0-9_-]+$'
[[ "$INCIDENT_ID" =~ $id_re ]] || { echo "Error: incident ID must contain only letters, numbers, hyphens, and underscores"; exit 1; }

echo "🔍 Collecting evidence for incident: $INCIDENT_ID"
echo ""

# Collect Kubernetes pod status (read-only)
if command -v kubectl &>/dev/null; then
  echo "=== Kubernetes Pod Status ==="
  kubectl get pods --all-namespaces --sort-by=.status.startTime 2>/dev/null | tail -20 || echo "Kubernetes API not accessible"
  echo ""
fi

# Collect recent system logs (read-only, safe)
echo "=== Recent System Logs ==="
if command -v journalctl &>/dev/null; then
  journalctl --since "1 hour ago" --no-pager -n 100 2>/dev/null || echo "journalctl not available"
else
  echo "journalctl not available (not a systemd system)"
fi
echo ""

# Collect Docker events (read-only)
if command -v docker &>/dev/null; then
  echo "=== Recent Docker Events ==="
  docker events --since 1h --until 0s 2>/dev/null | tail -20 || echo "Docker daemon not accessible"
  echo ""
fi

# Collect system resources (read-only)
echo "=== System Resources ==="
if command -v top &>/dev/null; then
  top -l 1 -n 0 2>/dev/null | head -10 || echo "top not available"
fi
echo ""

echo "✅ Evidence collection complete. Feed this output into the skill for analysis."
