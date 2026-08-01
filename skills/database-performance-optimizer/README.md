# Database Performance Optimizer

> Database performance engineer — schema review, query optimization, indexing, replication, capacity planning.

Analyze relational and NoSQL databases to find bottlenecks. Schema review, query optimization, index analysis, execution plan interpretation, and capacity planning.

## What It Does

- **Schema Review** — Normalization, data types, keys, constraints, naming
- **Query Analysis** — Execution plans, table scans, joins, sorts, temp tables
- **Index Analysis** — Missing, unused, duplicate, covering, composite, maintenance cost
- **Transaction Analysis** — Isolation levels, locks, deadlocks, long-running transactions
- **Architecture** — Partitioning, sharding, replication, caching
- **ORM Review** — N+1 queries, lazy/eager loading, connection pooling

## Quick Start

```bash
# Install
npx skills add theamitv/database-performance-optimizer

# Use in Claude Code
/database-performance-optimizer Analyze database performance
```

## When It Won't Work

- **No query access** — Requires actual queries, schema DDL, or execution plans to analyze. Cannot optimize blindly without workload context.
- **Production data** — Does not connect to live databases. Provide anonymized schemas, slow query logs, or EXPLAIN plans.
- **Vendor-specific features** — Covers PostgreSQL, MySQL, MongoDB, DynamoDB, SQL Server, Oracle at the general level. Deep vendor-specific features (e.g., Oracle RAC, SQL Server Always On) may need additional context.
- **Hardware tuning** — Focuses on query/schema/index level optimization. Storage hardware, kernel parameters, and filesystem tuning are out of scope.
- **Real-time monitoring** — Provides recommendations based on static analysis. Does not set up monitoring or alerting.

## Structure

```
database-performance-optimizer/
├── SKILL.md          # Skill metadata and triggers
├── README.md         # This file
├── references/
│   └── query-patterns.md  # Anti-patterns, indexing guidelines
├── examples/
│   └── usage.md      # Usage examples
└── scripts/
    └── analyze-queries.sh  # Query analysis command generator
```

## License

MIT
