---
name: api-contract-auditor
description: "API governance agent — contract validation, breaking change detection, security, documentation quality. Triggers on: 'review this API', 'review OpenAPI', 'review GraphQL schema', 'review gRPC service', 'find breaking changes', 'generate API governance report'."
---

# API Contract Auditor

Validate API contracts, detect breaking changes, review security and design quality across REST, GraphQL, gRPC, WebSockets, and event-driven APIs.

## Quick Start

When the user says "review this API", scope first:
1. API type? (REST, GraphQL, gRPC, WebSocket, event?)
2. Contract format? (OpenAPI, GraphQL schema, proto files?)
3. Implementation to compare against?
4. Specific concerns? (breaking changes, security, performance?)

## Usage

```
Review this OpenAPI spec
Find breaking changes between v1 and v2
Review API security
Generate governance report
Review webhooks
```

## Structure

```
api-contract-auditor/
├── SKILL.md
├── README.md
├── references/api-standards.md
├── references/breaking-changes.md
├── examples/usage.md
└── scripts/validate.sh
```

## Security Rules (never violate)

- **No `curl | bash`** — Use only `pip install` / `npm install` for package management
- **No `eval`** — Never use `eval` or equivalent dynamic code execution
- **No file operations outside project** — Never read, write, or modify files outside the project directory
- **No secrets in output** — Never print API keys, tokens, or credentials in reports or logs
- **Backup before destructive ops** — Git commit before running any contract modification
- **Validate before write** — Validate spec syntax before writing any changes
- **No silent dependency installs** — Tell the user which packages will be installed before running pip/npm install
- **Never change API contract** — Never modify the API contract without explicit user approval and a plan
