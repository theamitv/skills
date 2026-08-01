# API Contract Auditor

> API governance agent — contract validation, breaking change detection, security, documentation quality.

Validate API contracts, detect breaking changes, review security and design quality across REST, GraphQL, gRPC, WebSockets, and event-driven APIs.

## What It Does

- **Contract Validation** — Required fields, types, enums, patterns, oneOf/anyOf, circular refs
- **Breaking Change Detection** — Removed/renamed fields, type changes, auth changes, consumer impact
- **Security Review** — OWASP API Top 10, auth (OAuth2/OIDC/JWT/mTLS), rate limiting
- **Design Review** — RESTfulness, naming, pagination, error format, idempotency, versioning
- **Documentation Review** — Completeness, examples, error docs, migration guide

## Quick Start

```bash
# Install
npx skills add theamitv/api-contract-auditor

# Use in Claude Code
/api-contract-auditor Review this OpenAPI spec
```

## Structure

```
api-contract-auditor/
├── SKILL.md                  # Skill metadata and triggers
├── README.md                 # This file
├── references/
│   ├── api-standards.md      # REST naming, status codes, pagination standards
│   └── breaking-changes.md   # Breaking change detection reference
├── examples/
│   └── usage.md              # Usage examples
└── scripts/
    └── validate.sh           # Spec format validation
```

## License

MIT
