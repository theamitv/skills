# AI-Powered Development Skills for Claude Code

A collection of 10 specialized skills for Claude Code covering trading, API governance, cloud cost optimization, codebase analysis, database performance, system design, PR review, incident investigation, SaaS generation, and security compliance.

## Skills

| Skill | Description |
|-------|-------------|
| [algorithmic-trading-assistant](./algorithmic-trading-assistant/) | Quantitative trading research — strategy design, backtesting, risk management |
| [api-contract-auditor](./api-contract-auditor/) | API governance — contract validation, breaking change detection, security |
| [cloud-cost-optimizer](./cloud-cost-optimizer/) | FinOps advisor — cloud cost analysis, K8s optimization, rightsizing |
| [codebase-knowledge-builder](./codebase-knowledge-builder/) | Repository knowledge — architecture, code flow, dependency graph, onboarding |
| [database-performance-optimizer](./database-performance-optimizer/) | Database performance — schema review, query optimization, indexing |
| [enterprise-system-design](./enterprise-system-design/) | System design — HLD, LLD, capacity planning, FAANG interview prep |
| [github-pr-intelligence](./github-pr-intelligence/) | PR review — architecture, security, performance, testing, deployment risk |
| [production-incident-investigator](./production-incident-investigator/) | SRE incident investigation — RCA, timeline, postmortem, remediation |
| [saas-product-generator](./saas-product-generator/) | SaaS blueprint — from idea to PRD, architecture, marketing, financials |
| [security-compliance-auditor](./security-compliance-auditor/) | Security audit — app, cloud, K8s, CI/CD, SOC2, ISO27001, GDPR, HIPAA |

## Install

```bash
# Install all skills
npx skills add theamitv/skills --all

# Install specific skills
npx skills add theamitv/skills --skill github-pr-intelligence
npx skills add theamitv/skills --skill security-compliance-auditor

# List available skills
npx skills add theamitv/skills --list
```

## Structure

```
skills/
├── README.md
├── .claude/
│   ├── agents/          # Agent definitions (concise, single-persona)
│   └── skills/          # Symlinks to skill directories
├── algorithmic-trading-assistant/
│   ├── SKILL.md         # Skill metadata and triggers
│   ├── README.md
│   ├── references/      # Reference documentation
│   ├── examples/        # Usage examples
│   └── scripts/         # Helper scripts (secure, validated)
├── api-contract-auditor/
├── cloud-cost-optimizer/
├── codebase-knowledge-builder/
├── database-performance-optimizer/
├── enterprise-system-design/
├── github-pr-intelligence/
├── production-incident-investigator/
├── saas-product-generator/
└── security-compliance-auditor/
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
