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

## When It Won't Work

- **No contract file** — Requires an OpenAPI, GraphQL SDL, proto, or AsyncAPI spec to analyze. Cannot review APIs from code alone.
- **Runtime behavior** — Validates contract structure, not runtime behavior. Cannot detect logic bugs, performance issues in production, or actual auth bypasses.
- **Custom formats** — Works with standard formats only. Proprietary or undocumented contract formats are not supported.
- **Implementation drift** — Cannot verify that the implementation matches the spec unless both are provided for comparison.
- **Auto-fixing** — Identifies issues and suggests fixes but does not auto-modify your spec files without approval.

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
