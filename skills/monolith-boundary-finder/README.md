# Monolith → Microservices Boundary Finder

> Identify safe service boundaries in a monolith before extracting a single service.

A wrong service boundary creates a "distributed monolith" that's worse than the original — all the latency and coordination pain of microservices with none of the independence. This skill analyzes actual call graphs and data coupling (not folder structure) to find legitimate extraction candidates.

## What It Does

- **Three-Phase Process** — Analyze → Plan (with user approval) → Execute
- **Call Graph Analysis** — Maps which modules call which, and which database tables each module touches
- **Cohesion/Coupling Scoring** — Identifies high-cohesion, low-coupling modules as extraction candidates
- **Shared-Table Detection** — Flags modules that share tables with many others (not safe to extract yet)
- **Conway's Law Check** — Considers team structure when recommending boundaries
- **One-at-a-Time Extraction** — Never batches multiple boundary extractions in one pass

## Quick Start

```bash
# Install
npx skills add theamitv/skills --skill monolith-boundary-finder

# Use in Claude Code
/monolith-boundary-finder Find service boundaries in this monolith
```

## Structure

```
monolith-boundary-finder/
├── SKILL.md                        # Skill metadata and instructions
├── README.md                       # This file
├── references/
│   ├── coupling-patterns.md             # Data coupling and cohesion analysis guide
│   └── extraction-order.md              # Extraction ordering and distributed monolith prevention
├── examples/
│   └── usage.md                         # Usage examples
└── scripts/
    └── audit-coupling.sh                # Module coupling audit scanner
```

## Verification Checklist

- [ ] Extracted service has no direct database access to tables it doesn't own
- [ ] All former synchronous call sites now handle the new service being unavailable/slow
- [ ] Data consistency between old and new service verified under real traffic

## License

MIT
