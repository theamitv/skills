# SaaS Code Generator

> Full SaaS code generator — from blueprint to working application. Generates full-stack code with auth, database, API, frontend, tests, and deployment config.

Transform a product blueprint into a complete, working application. This skill is the **implementation counterpart** to [saas-product-generator](https://github.com/theamitv/skills/tree/main/saas-product-generator): where that skill produces documents (PRDs, architecture docs, pricing), this one produces **working code**.

## What It Does

- **Full-Stack Generation** — Scaffolds complete applications with frontend, backend, database, and deployment
- **Blueprint-Aware** — Takes output from `saas-product-generator` and builds the actual product
- **Multi-Stack** — Supports Next.js, React, Vue, FastAPI, Express, Go Gin, PostgreSQL, MongoDB, SQLite
- **Auth Included** — JWT, OAuth, session-based, or passwordless auth out of the box
- **Production-Ready** — Generates tests, Docker config, CI/CD pipelines, and environment templates
- **Layer-Specific** — Generate only what you need: frontend, backend, database, or deployment

## Quick Start

```bash
# Install
npx skills add theamitv/saas-code-generator

# Use in Claude Code
/saas-code-generator Generate code for a gym management SaaS
/saas-code-generator Build the app from my SaaS blueprint
/saas-code-generator Generate a Next.js + FastAPI interview prep platform
```

## When It Won't Work

- **No blueprint** — Works best with a product blueprint from `saas-product-generator`. Without one, output quality depends on the specificity of your prompt.
- **Complex migrations** — Generates greenfield applications. Migrating existing codebases or adding to large projects may need manual integration.
- **Third-party API integrations** — Generates integration patterns but cannot register for third-party services or obtain API keys on your behalf.
- **Production deployment** — Generates Docker and CI/CD config but does not deploy to production or manage cloud infrastructure.
- **Custom UI/UX** — Generates functional UI with standard component libraries. Custom design systems and complex animations need manual styling.

## Supported Tech Stacks

| Layer | Options |
|-------|---------|
| **Frontend** | Next.js (React), React + Vite, Vue 3 + Vite |
| **Backend** | FastAPI (Python), Express (Node.js), Gin (Go) |
| **Database** | PostgreSQL, MongoDB, SQLite |
| **Auth** | JWT, OAuth (Google/GitHub), session-based, passwordless |
| **Deployment** | Docker + Compose, Vercel, Railway, AWS ECS |

## Structure

```
saas-code-generator/
├── SKILL.md              # Skill metadata and triggers
├── README.md             # This file
├── references/
│   ├── stacks.md         # Supported tech stacks with patterns
│   └── patterns.md       # Reusable code patterns
├── examples/
│   └── usage.md          # Usage examples
└── scripts/
    ├── scaffold.sh       # Project scaffold creator
    └── generate-env.sh   # Environment config generator
```

## Requirements

- [Claude Code](https://claude.ai/code) (recommended)
- [Node.js](https://nodejs.org/) 18+ for `npx skills`
- Stack-specific tools as needed (Python 3.11+, Go 1.21+, Docker, etc.)

## License

MIT
