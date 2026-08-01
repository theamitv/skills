# Express → NestJS Migrator

> Migrate Express.js apps to NestJS with structure, DI, and zero API contract breaks.

NestJS brings dependency injection, modular architecture, decorators, and a standardized request pipeline to Node.js backends. This skill handles the full migration — middleware mapping, route conversion, DI integration, and execution order preservation.

## What It Does

- **Three-Phase Process** — Inspect → Plan (with user approval) → Execute
- **Middleware Mapping** — Every Express middleware gets mapped to the correct Nest primitive (guard, interceptor, pipe, filter, or module config)
- **Execution Order Preservation** — Identifies ordering dependencies that don't translate cleanly to Nest's pipeline
- **API Contract Safety** — Never changes route paths, status codes, or response shapes
- **Incremental or Full Rewrite** — Recommends incremental for production apps

## Quick Start

```bash
# Install
npx skills add theamitv/skills --skill express-to-nestjs-migrator

# Use in Claude Code
/express-to-nestjs-migrator Migrate this Express app to NestJS
```

## Structure

```
express-to-nestjs-migrator/
├── SKILL.md                    # Skill metadata and instructions
├── README.md                   # This file
├── references/
│   ├── middleware-mapping.md       # Express middleware → Nest concept mapping
│   └── common-breakage.md          # Known Express→Nest breakage points
├── examples/
│   └── usage.md                     # Usage examples
└── scripts/
    └── audit-middleware.sh          # Middleware audit scanner
```

## Verification Checklist

- [ ] Every original route responds with the same method/path/status/shape
- [ ] Middleware execution order preserved (test with a request that hits every layer)
- [ ] Auth/guard behavior identical for both authorized and unauthorized requests
- [ ] Error handling produces the same error responses as before

## License

MIT
