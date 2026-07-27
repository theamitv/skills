# Codebase Knowledge Builder

> Repository knowledge builder — architecture, code flow, dependency graph, onboarding, technical debt analysis.

Ingest a repository, build a comprehensive knowledge model, and answer deep technical questions about architecture, business logic, dependencies, and workflows.

## What It Does

- **Repository Ingestion** — Analyze source code, config, infra, tests, docs, CI/CD
- **Architecture Analysis** — Monolith, microservices, event-driven, layered, clean/hexagonal, CQRS, DDD
- **Code Flow** — HTTP → controller → service → DB, event → handler → worker, auth flow
- **Dependency Graph** — Internal/external, circular deps, unused/outdated packages
- **Technical Debt** — Large files, god classes, dead code, security risks, test gaps
- **Developer Onboarding** — Structured plan from Day 1 through Week 3+

## Quick Start

```bash
# Install
npx skills add theamitv/codebase-knowledge-builder

# Use in Claude Code
/codebase-knowledge-builder Explain this repository
```

## Structure

```
codebase-knowledge-builder/
├── SKILL.md          # Skill metadata and triggers
├── README.md         # This file
├── references/
│   └── architecture-patterns.md  # Pattern descriptions and detection
├── examples/
│   └── usage.md      # Usage examples
└── scripts/
    └── analyze.sh    # Repository analysis
```

## License

MIT
