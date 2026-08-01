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
