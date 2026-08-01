# Usage Examples

## Boundary Analysis

```
Find service boundaries in this monolith
How should I split this codebase into microservices?
```

Triggers the full three-phase process: analyze → plan → execute (one service at a time).

## Extraction Readiness

```
Is this monolith ready for microservices?
Evaluate our microservices readiness
```

The skill will assess coupling, shared tables, and team alignment without proposing an extraction.

## Specific Candidate

```
Can we extract the notification module into its own service?
```

The skill will analyze the specific module's coupling, data ownership, and extraction readiness.

## Distributed Monolith Concern

```
I'm worried about creating a distributed monolith
```

The skill will focus on shared-table detection and synchronous call chain analysis.

## Team Structure

```
Our team structure doesn't match the code — how should we split?
```

The skill will apply Conway's Law analysis to recommend boundaries that match team ownership.

## Data Ownership

```
How do we split the shared database before extracting services?
```

The skill will analyze shared tables and recommend data ownership resolution strategies.

## Example Analysis Output

### Phase 1 — Call Graph Summary
```
This monolith has 8 modules across 3 teams:
- 3 modules with high cohesion and low coupling: email, pdf-gen, reports
- 2 modules with shared-table coupling: orders + billing share "invoices" table
- 1 critical-path chain: API → auth → users → billing → payment (5 sync calls)
- 2 modules that own their data: email (email_queue), pdf-gen (temp storage)
```

### Phase 2 — Extraction Plan
```
Ranked extraction candidates:
1. email — high cohesion, no shared tables, stateless → ✅ extract first (proof of pattern)
2. pdf-gen — high cohesion, own data, low coupling → ✅ extract second
3. reports — medium cohesion, read-heavy, own data → ✅ extract third
4. billing — high cohesion but shares "invoices" with orders → ⚠️ split table first
5. orders — shares "invoices" with billing → ❌ do not extract yet

Do not extract yet:
- orders + billing: share "invoices" table — split into orders.invoices + billing.invoices first
- auth: called synchronously in every request's critical path — add caching/async first

Recommended order: email → pdf-gen → reports → (split invoices) → billing → orders
```

### Phase 3 — Verification (after first extraction)
```
✅ email service has no DB access to non-email tables
✅ All call sites handle timeout/retry (3 callers updated)
✅ Email delivery verified under production traffic (99.9% delivery rate)
```
