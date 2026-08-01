# Data Coupling and Cohesion Analysis Guide

## The Core Principle

**Cohesion** = how tightly the things *inside* a module belong together (high = good).
**Coupling** = how much a module depends on things *outside* itself (low = good).

A good extraction candidate has **high cohesion** and **low coupling**.

## Coupling Types (Ranked by Extraction Difficulty)

| Type | Example | Extraction Difficulty | Notes |
|------|---------|---------------------|-------|
| **No coupling** | Module has no imports from other modules | Trivial | Rare in practice |
| **Interface coupling** | Module calls another via a well-defined interface/function | Low | Easy to replace with API call |
| **Data coupling** | Module shares data structures/types with another | Medium | Duplicate or share type definitions |
| **Table coupling** | Modules share a database table (read/write same table) | High | **#1 cause of distributed monoliths** |
| **Transactional coupling** | Multiple modules participate in the same DB transaction | Very High | Needs eventual consistency redesign |
| **State coupling** | Module depends on in-memory state set by another module | Very High | Needs explicit state propagation |

## Cohesion Types (Ranked by Extraction Suitability)

| Type | Example | Extraction Suitability |
|------|---------|----------------------|
| **Functional cohesion** | All functions in a module contribute to a single well-defined task | Excellent |
| **Sequential cohesion** | Output of one function is input to the next in the same module | Good |
| **Communicational cohesion** | Functions operate on the same data | Good |
| **Procedural cohesion** | Functions follow a sequence of steps | Medium |
| **Temporal cohesion** | Functions are grouped because they run at the same time | Poor |
| **Logical cohesion** | Functions are grouped by category, not by what they do | Poor |
| **Coincidental cohesion** | Functions are grouped arbitrarily | Very Poor |

## Call Graph Analysis

Build a directed graph of module dependencies:

```
users/
  ├── calls: auth (validate), email (send), billing (getPlan)
  └── tables: users, subscriptions

auth/
  ├── calls: users (getById)
  └── tables: users, sessions

email/
  ├── calls: (none)
  └── tables: email_queue

billing/
  ├── calls: users (getById), email (sendInvoice)
  └── tables: subscriptions, invoices, users
```

### Analysis

| Module | Cohesion | Coupling | Tables Shared | Extract? |
|--------|----------|----------|---------------|----------|
| **email** | High (sends emails) | Low (no calls out) | 0 shared | ✅ Best candidate |
| **auth** | High (auth only) | Medium (calls users) | 1 shared (users) | ⚠️ Needs data ownership resolved |
| **users** | Medium (CRUD + auth) | High (called by 3 modules) | 2 shared | ❌ Too coupled |
| **billing** | High (billing only) | Medium (calls 2 modules) | 1 shared (users) | ⚠️ Needs data ownership resolved |

## Shared-Table Detection

The most dangerous pattern. A table written by module A and read by module B means neither can be extracted independently without duplicating or syncing that data.

```sql
-- Shared table: users
-- Written by: auth module (register, login)
-- Read by: users module (profile), billing module (getPlan), orders module (getCustomer)
```

**Extraction rule**: If a table has more than 2 readers/writers across different modules, do NOT extract any of those modules until the table is split or an ownership boundary is established.

## Data Ownership Resolution Strategies

| Strategy | When to Use | Cost |
|----------|-------------|------|
| **Service owns the table, others call API** | One service is the clear primary writer | Low — add API endpoint |
| **Duplicate the data** | Read-heavy, stale data is acceptable | Medium — sync job needed |
| **Split the table** | Different services need different subsets | High — schema migration |
| **Event-driven sync** | Near-real-time consistency needed | High — event bus + eventual consistency |
| **Shared database (keep as is)** | Extraction isn't worth the cost | None — but don't extract |

## Conway's Law Check

> Organizations design systems that mirror their communication structures.

If team A owns modules X and Y, and team B owns module Z, then extracting X into a service owned by team A while leaving Y in the monolith owned by team A creates a cross-team dependency that didn't exist before.

**Ask**: Does the proposed boundary match who owns and deploys the code? If not, the process pain of coordinating across teams may outweigh the technical benefits of the split.
