#!/usr/bin/env bash
# Enterprise System Design - Capacity Estimation Script
# Usage: ./estimate.sh <daily-active-users> <requests-per-user>
# Performs back-of-the-envelope capacity calculations.

set -euo pipefail

DAU="${1:-}"
RPU="${2:-}"

usage() {
  echo "Usage: $0 <daily-active-users> <requests-per-user>"
  echo "Example: $0 1000000 10"
  exit 1
}

[ -z "$DAU" ] || [ -z "$RPU" ] && usage

# Validate numeric inputs
num_re='^[0-9]+$'
[[ "$DAU" =~ $num_re ]] || { echo "Error: daily-active-users must be a positive integer"; exit 1; }
[[ "$RPU" =~ $num_re ]] || { echo "Error: requests-per-user must be a positive integer"; exit 1; }

echo "📊 Capacity Estimation"
echo "======================"
echo ""

TOTAL_REQUESTS=$((DAU * RPU))
RPS=$((TOTAL_REQUESTS / 86400))
PEAK_RPS=$((RPS * 2))

# Format numbers with commas
format_num() {
  python3 -c "print(f'{int($1):,}')" 2>/dev/null || echo "$1"
}

echo "Daily Active Users:    $(format_num "$DAU")"
echo "Requests/User/Day:     $(format_num "$RPU")"
echo "Total Requests/Day:    $(format_num "$TOTAL_REQUESTS")"
echo "Avg Requests/Second:   $(format_num "$RPS")"
echo "Peak Requests/Second:  $(format_num "$PEAK_RPS")"
echo ""

# Storage estimate (assuming 1KB per request)
STORAGE_BYTES=$((TOTAL_REQUESTS * 1024))
STORAGE_GB=$((STORAGE_BYTES / 1073741824))
STORAGE_TB=$((STORAGE_GB / 1024))

echo "Daily Storage:         $(format_num "$STORAGE_GB") GB"
echo "Monthly Storage:       $(format_num "$((STORAGE_GB * 30))") GB"
echo "Yearly Storage:        $(format_num "$STORAGE_TB") TB"
echo ""

# Bandwidth estimate
BANDWIDTH_MB=$((STORAGE_BYTES / 1048576))
echo "Daily Bandwidth:       $(format_num "$BANDWIDTH_MB") MB"
echo "Monthly Bandwidth:     $(format_num "$((BANDWIDTH_MB * 30))") MB"
echo ""

# Cache estimate (20% of daily data)
CACHE_GB=$((STORAGE_GB * 20 / 100))
echo "Cache Size (20%):      $(format_num "$CACHE_GB") GB"
echo ""

# Database connection estimate
DB_CONNS=$((RPS / 10 + 50))
echo "DB Connections (est):  $(format_num "$DB_CONNS")"
