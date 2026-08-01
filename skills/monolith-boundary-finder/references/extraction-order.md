# Extraction Ordering and Distributed Monolith Prevention

## The Golden Rule

**Start with the least-coupled, least business-critical candidate.** The first extraction is a proof of pattern — it should be low-risk so you learn the operational lessons (deployment pipeline, monitoring, inter-service communication) before touching core domains.

## Recommended Extraction Order

### Phase 0 — Prerequisites (do before any extraction)
- [ ] CI/CD pipeline supports deploying individual services
- [ ] Service discovery / API gateway in place
- [ ] Logging and tracing infrastructure (correlation IDs across services)
- [ ] Team alignment on communication patterns (REST vs gRPC vs async events)
- [ ] Rollback plan for each extraction

### Phase 1 — Stateless, Low-Coupling Service
**Example**: Email notification service, PDF generation, report export.

**Why first**: No state to migrate, no shared tables, easy to verify independently.

**Risks**: Minimal — the main risk is the operational pipeline itself.

### Phase 2 — Read-Heavy, Own-Data Service
**Example**: Content catalog, reference data, lookup tables.

**Why second**: The service owns its data, so no shared-table problem. Reads are easier to migrate than writes.

**Risks**: Cache invalidation, data sync timing if other services still read the same data from the monolith's DB.

### Phase 3 — Write-Heavy, Own-Data Service
**Example**: User profiles, product catalog (with admin writes).

**Why third**: The service owns its data and handles both reads and writes. Other services must now call this service's API instead of reading its tables directly.

**Risks**: Data consistency guarantees change from ACID to eventual consistency. Need to handle the "other services still reading from shared DB" transition period.

### Phase 4 — Transactional / Shared-Data Service
**Example**: Order management, billing, inventory.

**Why last**: These have the most shared-table dependencies and transactional coupling. Extracting them requires the most infrastructure (event bus, saga orchestration, CQRS patterns).

**Risks**: Distributed transactions, saga failure modes, data inconsistency under load.

## Distributed Monolith Warning Signs

| Symptom | Cause | Fix |
|---------|-------|-----|
| Every request touches 5+ services | Chatty service boundaries | Redesign boundary or use GraphQL/BFF layer |
| Services share a database | Table coupling not resolved | Assign data ownership per service |
| Synchronous call chains > 3 deep | Over-reliance on sync communication | Introduce async events or circuit breakers |
| Deploying one service requires deploying others | Tight coupling at deployment level | Enforce independent deployability |
| "We need a transaction across services" | Transactional coupling | Accept eventual consistency or redesign |
| Services need to be updated in lockstep | Shared contracts not versioned | Version APIs, use consumer-driven contracts |

## Extraction Readiness Checklist

For each candidate service, answer:

- [ ] Does it own all the data it needs? (No shared tables with other services)
- [ ] Can it be deployed independently? (No lockstep deployment requirements)
- [ ] Can it be developed independently? (No shared code that changes frequently)
- [ ] Does it have a well-defined API boundary? (Not just "expose the same functions over HTTP")
- [ ] Can it be tested independently? (Integration tests don't need the whole monolith running)
- [ ] Is the team structure aligned? (One team owns the service end-to-end)
- [ ] Is there a rollback plan? (Can we revert the extraction without data loss?)

## Rollback Plan Template

```markdown
## Rollback: Extract [Service Name]

### If extraction fails within 24 hours:
1. Revert the service code to the monolith
2. Re-point any callers to the monolith's original endpoints
3. Drop the new service's database (no data loss — it was a copy)

### If extraction fails after 1 week:
1. Keep the new service running (data may have diverged)
2. Write a backfill script to sync data from service → monolith
3. Revert callers to monolith endpoints
4. Decommission the service after data sync is verified
```
