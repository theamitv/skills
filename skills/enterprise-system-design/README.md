# Enterprise System Design

> System design generator — HLD, LLD, capacity planning, architecture for FAANG interview or production.

Transform a product idea or scaling problem into a complete system design. Supports FAANG interview mode and enterprise production mode.

## What It Does

- **Interview Mode** — FAANG-style: clarify → estimate → design → deep dive → trade-offs
- **Production Mode** — Full enterprise architecture with ADRs and migration plans
- **Capacity Planning** — DAU, RPS, storage, bandwidth, cache, connections
- **HLD** — Services, gateways, databases, caches, queues, CDN, blob storage
- **LLD** — Per-service: APIs, data contracts, logic, error handling, caching, retries
- **Design Domains** — Caching, distributed systems, security, observability, K8s, cost

## Quick Start

```bash
# Install
npx skills add theamitv/enterprise-system-design

# Use in Claude Code
/enterprise-system-design Design a URL shortener
```

## When It Won't Work

- **Implementation** — Produces design documents and architecture, not production code. Does not generate runnable applications.
- **Exact cost estimates** — Capacity planning uses rough estimates (DAU, RPS, storage). Actual cloud costs depend on specific pricing and discounts.
- **One-size-fits-all** — Designs are tailored to the specific requirements given. Vague requirements produce generic designs.
- **Real-time collaboration** — Single-designer output. Does not support multi-person architecture discussions or whiteboarding.
- **Certification** — Does not provide certified architecture reviews or compliance audits. Use for design exploration and interview prep.

## Structure

```
enterprise-system-design/
├── SKILL.md          # Skill metadata and triggers
├── README.md         # This file
├── references/
│   └── patterns.md   # System design patterns and trade-off framework
├── examples/
│   └── usage.md      # Usage examples
└── scripts/
    └── estimate.sh   # Capacity estimation calculator
```

## License

MIT
