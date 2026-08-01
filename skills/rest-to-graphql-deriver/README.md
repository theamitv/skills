# REST → GraphQL Schema Deriver

> Derive a GraphQL schema from existing REST endpoints with N+1-safe resolvers and preserved access control.

Adding GraphQL to an existing REST API is common, but naive resolvers silently introduce N+1 queries that don't surface until production traffic hits. This skill catalogs every endpoint, maps shared entities to GraphQL types, and writes batched resolvers from day one.

## What It Does

- **Three-Phase Process** — Catalog → Plan (with user approval) → Execute
- **Endpoint Catalog** — Maps every REST endpoint to response shapes, query patterns, and N+1 risk
- **N+1 Prevention** — Flags every "many" relationship for DataLoader/batched resolution
- **Auth Preservation** — Maps REST auth checks to resolver-level or field-level GraphQL auth
- **Additive or Full Replacement** — Recommends additive (GraphQL alongside REST) for gradual rollout

## Quick Start

```bash
# Install
npx skills add theamitv/skills --skill rest-to-graphql-deriver

# Use in Claude Code
/rest-to-graphql-deriver Derive a GraphQL schema from my REST API
```

## When It Won't Work

- **No REST API** — Designed for adding GraphQL to an existing REST API. Greenfield GraphQL projects don't need this skill.
- **No endpoint access** — Requires access to route definitions, response shapes, or API documentation to catalog endpoints.
- **Complex auth flows** — REST APIs with deeply nested or context-dependent auth may need manual resolver-level auth wiring.
- **File upload endpoints** — GraphQL handles file uploads differently (multipart request spec). REST file upload endpoints need special handling.
- **Full REST replacement** — This skill derives a GraphQL layer. Existing REST endpoints remain unchanged unless you explicitly deprecate them.

## Structure

```
rest-to-graphql-deriver/
├── SKILL.md                    # Skill metadata and instructions
├── README.md                   # This file
├── references/
│   ├── n-plus-one-prevention.md    # N+1 query prevention guide
│   └── auth-mapping.md             # REST auth → GraphQL auth mapping
├── examples/
│   └── usage.md                     # Usage examples
└── scripts/
    └── catalog-endpoints.sh          # REST endpoint catalog scanner
```

## Verification Checklist

- [ ] Query a nested/relational field and confirm it doesn't produce N+1 queries
- [ ] Auth checks produce the same allow/deny behavior as the original REST endpoints
- [ ] Schema types match real response shapes, not idealized ones

## License

MIT
