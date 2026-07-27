#!/usr/bin/env bash
# Database Performance Optimizer - Query Analysis Script
# Usage: ./analyze-queries.sh <database-type>
# Securely generates database analysis commands (does not execute them directly).

set -euo pipefail

DB_TYPE="${1:-}"

usage() {
  echo "Usage: $0 <database-type>"
  echo "Example: $0 postgresql"
  echo "Example: $0 mysql"
  echo "Example: $0 mongodb"
  exit 1
}

[ -z "$DB_TYPE" ] && usage

# Validate database type
case "$DB_TYPE" in
  postgresql|postgres|mysql|mongodb|dynamodb|redis) ;;
  *) echo "Error: unsupported database type '$DB_TYPE'. Supported: postgresql, mysql, mongodb, dynamodb, redis"; exit 1 ;;
esac

echo "🔍 Database Query Analysis"
echo "=========================="
echo "Type: $DB_TYPE"
echo ""

case "$DB_TYPE" in
  postgresql|postgres)
    echo "=== Slow Queries (pg_stat_statements) ==="
    cat <<'SQL'
SELECT query, calls, total_time, mean_time, rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;
SQL
    echo ""
    echo "=== Index Usage ==="
    cat <<'SQL'
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC
LIMIT 10;
SQL
    echo ""
    echo "=== Connection Status ==="
    cat <<'SQL'
SELECT state, count(*) FROM pg_stat_activity GROUP BY state;
SQL
    echo ""
    echo "To run: psql <connection-string> -f <this-script>"
    ;;
  mysql)
    echo "=== Slow Query Log ==="
    echo "SHOW VARIABLES LIKE 'slow_query_log%';"
    echo ""
    echo "=== Process List ==="
    echo "SHOW FULL PROCESSLIST;"
    echo ""
    echo "=== InnoDB Status ==="
    echo "SHOW ENGINE INNODB STATUS\\G;"
    echo ""
    echo "To run: mysql <connection-options> < this-script"
    ;;
  mongodb)
    echo "=== Slow Queries ==="
    echo 'db.currentOp({ "secs_running": { "$gt": 5 } })'
    echo ""
    echo "=== Index Usage ==="
    echo 'db.collection.aggregate([{ $indexStats: {} }])'
    echo ""
    echo "=== Profiling ==="
    echo 'db.setProfilingLevel(1, { slowms: 100 })'
    echo 'db.system.profile.find().sort({ ts: -1 }).limit(10)'
    echo ""
    echo "To run: mongosh <connection-string>"
    ;;
  dynamodb)
    echo "=== CloudWatch Metrics ==="
    echo "aws dynamodb describe-table --table-name <table>"
    echo "aws cloudwatch get-metric-statistics ... ConsumedReadCapacityUnits"
    echo ""
    echo "=== Throttling ==="
    echo "aws dynamodb describe-table --table-name <table> --query 'Table.ProvisionedThroughput'"
    ;;
  redis)
    echo "=== Slow Log ==="
    echo "SLOWLOG GET 10"
    echo ""
    echo "=== Memory ==="
    echo "INFO memory"
    echo ""
    echo "=== Command Stats ==="
    echo "INFO commandstats"
    echo ""
    echo "To run: redis-cli"
    ;;
esac

echo ""
echo "✅ Query analysis commands generated. Run against your database for data."
