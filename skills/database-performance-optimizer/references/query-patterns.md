# Query Patterns Reference

## Common Anti-Patterns

| Anti-Pattern | Problem | Solution |
|-------------|---------|----------|
| SELECT * | Returns unnecessary columns | Specify only needed columns |
| N+1 Queries | Loop queries for related data | Use JOIN or batch loading |
| Missing WHERE | Full table scan | Add filter conditions |
| Implicit type conversion | Index not used | Match types exactly |
| Functions on indexed columns | Index not used | Use computed columns or expression indexes |
| Large IN clauses | Slow query planning | Use JOIN or temp table |
| Cursor-based pagination | Inefficient for large sets | Use keyset pagination |

## Indexing Guidelines

- Index columns used in WHERE, JOIN, ORDER BY, GROUP BY
- Prefer composite indexes over multiple single-column indexes
- Order columns in composite indexes: high selectivity first
- Consider partial indexes for filtered queries
- Monitor index usage and remove unused indexes
- Be aware of write amplification from too many indexes

## Execution Plan Signs

| Sign | Meaning |
|------|---------|
| Sequential scan | No suitable index, or small table |
| Index scan | Using index but reading many rows |
| Index seek | Efficient row lookup |
| Nested loop | Small result set join |
| Hash join | Large unsorted join |
| Merge join | Sorted inputs join |
| Sort operation | ORDER BY without index |
| Spill to temp | Memory pressure during sort/hash |
