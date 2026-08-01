# System Design Patterns Reference

## Common System Design Problems

| System | Key Challenge | Pattern |
|--------|--------------|---------|
| URL Shortener | Key generation, redirection | Base62 encoding, consistent hashing |
| Chat System | Real-time messaging, ordering | WebSockets, event sourcing, message ordering |
| Rate Limiter | Distributed counting, low latency | Token bucket, sliding window, Redis |
| News Feed | Fan-out, ranking | Push/Pull hybrid, async fan-out |
| Payment System | Idempotency, consistency | Two-phase commit, saga pattern, outbox |
| Search Engine | Crawling, indexing, ranking | Inverted index, MapReduce, PageRank |

## Trade-off Framework

When comparing options, always evaluate:
1. **Consistency vs Availability** (CAP theorem)
2. **Latency vs Throughput**
3. **Read vs Write Optimization**
4. **Strong vs Eventual Consistency**
5. **Synchronous vs Asynchronous**
6. **Monolith vs Microservices**
7. **SQL vs NoSQL**
8. **Cost vs Performance**
