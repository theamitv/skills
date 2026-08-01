---
name: monolith-boundary-finder
description: "Identify service boundaries in a monolith for microservices extraction. Triggers on: 'break a monolith into microservices', 'how should I split this codebase', 'extract a service from a monolith', 'evaluate microservices readiness'. Do NOT trigger to actually perform the split immediately — this skill's job is boundary analysis and planning, not execution."
---

# Monolith → Microservices Boundary Finder

## Phase 1 — THINK (this phase IS most of the value here — do not rush it)
This is the single highest-stakes decision in this entire pack — a wrong service boundary creates a "distributed monolith" that's worse than the original. Analyze, don't guess:
- Build an actual call graph / data coupling map: which modules call which, and which database tables/models are read or written by which modules — folder structure lies, actual coupling doesn't
- Identify modules with high internal cohesion and low external coupling — these are legitimate extraction candidates
- Explicitly flag modules that share database tables with many other modules, or that are called synchronously from many places in a request's critical path — these are NOT safe to extract yet without more work (shared-table extraction is the #1 cause of "distributed monolith" outcomes)
- Look at team structure if known — Conway's Law means a boundary that doesn't match who actually owns/deploys what tends to create process pain even if the code split is clean

## Phase 2 — PLAN (this is the primary deliverable — treat it as such)
Produce, explicitly for human review before any extraction begins:
1. Ranked list of extraction candidates (highest cohesion / lowest coupling first), each with the specific evidence from Phase 1 (not vibes)
2. For each candidate: what data it owns, what would need duplicating/syncing if extracted, and what synchronous calls would need to become async/event-driven
3. Explicit "do not extract yet" list — modules where coupling is currently too high, with what would need to change first (e.g., "split shared table X before extracting")
4. A recommended extraction order (usually: start with the least-coupled, least business-critical candidate as a proof of the pattern before touching core domains)

## Phase 3 — EXECUTE (only with explicit user confirmation, and only one boundary at a time)
- Extract exactly one service per the agreed plan — never batch multiple boundary extractions in one pass, since each needs independent verification
- Replace synchronous in-process calls with explicit API calls or async events per the plan, preserving exact behavior/data consistency guarantees the monolith had
- Do not extract shared-table dependencies without the data ownership question being resolved first (which service now owns this data, how do others read it)

## Verification checklist
- [ ] Extracted service has no direct database access to tables it doesn't own
- [ ] All former synchronous call sites now handle the new service being unavailable/slow (timeout, retry, or async fallback — not a blocking assumption it's always up)
- [ ] Data consistency between old and new service verified under real traffic, not just a smoke test

## Security Rules (never violate)
- **No `curl | bash`** — Use only `npm install` / `npm uninstall` for package management.
- **No `eval`** — Never use `eval` or equivalent dynamic code execution.
- **No file operations outside project** — Never read, write, or modify files outside the project directory.
- **No secrets in output** — Never print API keys, tokens, or credentials in reports or logs.
- **Backup before destructive ops** — Always create a git commit or stash before extracting a service.
- **Validate before write** — Validate extracted service builds and tests pass before declaring it done.
- **No silent dependency installs** — Tell the user which packages will be installed and get implicit confirmation before running `npm install`.
- **Never extract shared-table dependencies without resolving data ownership first** — This is the #1 cause of distributed monoliths. The question "which service owns this data now?" must be answered before extraction.
