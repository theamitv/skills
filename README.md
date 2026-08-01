# AI-Powered Development Skills for Claude Code

A collection of 22 specialized skills for Claude Code covering trading, API governance, cloud cost optimization, codebase analysis, database performance, system design, PR review, incident investigation, project updates, CRA→Vite migration, Express→NestJS migration, JS→TS migration, REST→GraphQL derivation, React class→hooks migration, Redux→Zustand migration, Webpack→Vite migration, monolith boundary analysis, Mongoose→Prisma/Drizzle migration, Python 2→3 / Django upgrade, SaaS blueprinting, SaaS code generation, and security compliance.

## Skills

| Skill | Description |
|-------|-------------|
| [algorithmic-trading-assistant](./skills/algorithmic-trading-assistant/) | Quantitative trading research — strategy design, backtesting, risk management |
| [api-contract-auditor](./skills/api-contract-auditor/) | API governance — contract validation, breaking change detection, security |
| [cloud-cost-optimizer](./skills/cloud-cost-optimizer/) | FinOps advisor — cloud cost analysis, K8s optimization, rightsizing |
| [codebase-knowledge-builder](./skills/codebase-knowledge-builder/) | Repository knowledge — architecture, code flow, dependency graph, onboarding |
| [database-performance-optimizer](./skills/database-performance-optimizer/) | Database performance — schema review, query optimization, indexing |
| [enterprise-system-design](./skills/enterprise-system-design/) | System design — HLD, LLD, capacity planning, FAANG interview prep |
| [github-pr-intelligence](./skills/github-pr-intelligence/) | PR review — architecture, security, performance, testing, deployment risk |
| [monthly-project-update](./skills/monthly-project-update/) | Project status reports — git/PR/ticket mining, categorized summaries, stakeholder-ready markdown |
| [production-incident-investigator](./skills/production-incident-investigator/) | SRE incident investigation — RCA, timeline, postmortem, remediation |
| [saas-product-generator](./skills/saas-product-generator/) | SaaS blueprint — from idea to PRD, architecture, marketing, financials |
| [saas-code-generator](./skills/saas-code-generator/) | SaaS code generator — from blueprint to working full-stack application |
| [cra-to-vite-migrator](./skills/cra-to-vite-migrator/) | CRA → Vite migration — env vars, SVG imports, CRACO overrides, tests, rollback planning |
| [express-to-nestjs-migrator](./skills/express-to-nestjs-migrator/) | Express → NestJS migration — middleware mapping, DI, route conversion, API contract safety |
| [js-to-ts-incremental-migrator](./skills/js-to-ts-incremental-migrator/) | JS → TS incremental migration — priority analysis, JSDoc conversion, phased strictness |
| [rest-to-graphql-deriver](./skills/rest-to-graphql-deriver/) | REST → GraphQL schema derivation — N+1-safe resolvers, DataLoader, auth preservation |
| [react-class-to-hooks-migrator](./skills/react-class-to-hooks-migrator/) | React class → hooks migration — lifecycle mapping, stale closure prevention, useRef |
| [redux-to-zustand-migrator](./skills/redux-to-zustand-migrator/) | Redux → Zustand/Context migration — store mapping, middleware, normalized data, memoization |
| [webpack-to-vite-config-translator](./skills/webpack-to-vite-config-translator/) | Webpack → Vite/Turbopack config translation — loader/plugin mapping, import.meta.glob, incremental migration |
| [monolith-boundary-finder](./skills/monolith-boundary-finder/) | Monolith → microservices boundary analysis — call graph, data coupling, extraction ordering |
| [mongoose-to-prisma-drizzle-migrator](./skills/mongoose-to-prisma-drizzle-migrator/) | Mongoose → Prisma/Drizzle migration — schema mapping, populate conversion, dual-write strategy |
| [python2-to-3-django-upgrade-auditor](./skills/python2-to-3-django-upgrade-auditor/) | Python 2→3 / Django version bump — string/bytes audit, version-specific breaking changes, ORM verification |
| [security-compliance-auditor](./skills/security-compliance-auditor/) | Security audit — app, cloud, K8s, CI/CD, SOC2, ISO27001, GDPR, HIPAA |

## Install

```bash
# Install all skills
npx skills add theamitv/skills --all

# Install specific skills
npx skills add theamitv/skills --skill algorithmic-trading-assistant
npx skills add theamitv/skills --skill api-contract-auditor
npx skills add theamitv/skills --skill cloud-cost-optimizer
npx skills add theamitv/skills --skill codebase-knowledge-builder
npx skills add theamitv/skills --skill cra-to-vite-migrator
npx skills add theamitv/skills --skill database-performance-optimizer
npx skills add theamitv/skills --skill enterprise-system-design
npx skills add theamitv/skills --skill express-to-nestjs-migrator
npx skills add theamitv/skills --skill github-pr-intelligence
npx skills add theamitv/skills --skill js-to-ts-incremental-migrator
npx skills add theamitv/skills --skill mongoose-to-prisma-drizzle-migrator
npx skills add theamitv/skills --skill monolith-boundary-finder
npx skills add theamitv/skills --skill monthly-project-update
npx skills add theamitv/skills --skill production-incident-investigator
npx skills add theamitv/skills --skill python2-to-3-django-upgrade-auditor
npx skills add theamitv/skills --skill react-class-to-hooks-migrator
npx skills add theamitv/skills --skill redux-to-zustand-migrator
npx skills add theamitv/skills --skill rest-to-graphql-deriver
npx skills add theamitv/skills --skill saas-code-generator
npx skills add theamitv/skills --skill saas-product-generator
npx skills add theamitv/skills --skill security-compliance-auditor
npx skills add theamitv/skills --skill webpack-to-vite-config-translator

# List available skills
npx skills add theamitv/skills --list
```

## Structure

```
repo-root/
├── README.md
├── skills-lock.json
├── .claude/
│   ├── agents/          # Agent definitions (concise, single-persona)
│   └── skills/          # Symlinks to skill directories
├── skills/
│   ├── algorithmic-trading-assistant/
│   │   ├── SKILL.md     # Skill metadata and triggers
│   │   ├── README.md
│   │   ├── references/  # Reference documentation
│   │   ├── examples/    # Usage examples
│   │   └── scripts/     # Helper scripts (secure, validated)
│   ├── api-contract-auditor/
│   ├── cloud-cost-optimizer/
│   ├── codebase-knowledge-builder/
│   ├── database-performance-optimizer/
│   ├── enterprise-system-design/
│   ├── github-pr-intelligence/
│   ├── monthly-project-update/
│   ├── production-incident-investigator/
│   ├── saas-product-generator/
│   ├── saas-code-generator/
│   ├── cra-to-vite-migrator/
│   ├── express-to-nestjs-migrator/
│   ├── js-to-ts-incremental-migrator/
│   ├── rest-to-graphql-deriver/
│   ├── react-class-to-hooks-migrator/
│   ├── redux-to-zustand-migrator/
│   ├── webpack-to-vite-config-translator/
│   ├── monolith-boundary-finder/
│   ├── mongoose-to-prisma-drizzle-migrator/
│   ├── python2-to-3-django-upgrade-auditor/
│   └── security-compliance-auditor/
```

## Each Skill Contains

- **SKILL.md** — Frontmatter with `name` and `description` (used by `npx skills` for discovery)
- **README.md** — Overview, install, and usage instructions
- **references/** — Domain-specific reference documentation
- **examples/** — Usage examples and patterns
- **scripts/** — Helper shell scripts (input-validated, injection-safe)

## Requirements

- [Claude Code](https://claude.ai/code) (recommended)
- [Node.js](https://nodejs.org/) 18+ for `npx skills`
- Some skills require additional CLI tools (noted in their READMEs)

## License

MIT
