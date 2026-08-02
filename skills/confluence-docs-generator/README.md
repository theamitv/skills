# Confluence Docs Generator

> Generates three Confluence-ready documentation pages — architecture overview, API reference, and user guide — by analyzing a codebase. Output is clean Markdown that Confluence's paste-as-markdown auto-converts into a properly formatted wiki page with zero manual reformatting.

Point this skill at any codebase — Node, Python, PHP/Laravel, Java/Spring, Next.js, Django, FastAPI, Rails, or Go — and it produces three Confluence-ready Markdown files. Paste each file into a new Confluence Cloud page; the built-in paste-as-markdown feature auto-formats headings, tables, code blocks, and lists. No manual reformatting needed.

## What It Does

- **Inventory Scan** — Scans the codebase, detects framework, finds key files
- **API Extraction** — Regex-based endpoint discovery across 10 frameworks (falls back to OpenAPI if present)
- **Strategic Reading** — Reads only what's needed (README, entry points, config, one file per module)
- **Three Documents** — Architecture overview, API reference, and user guide
- **Confluence-Safe Markdown** — Validated against Confluence's paste-as-markdown rules
- **Framework-Aware** — Knows where routes, controllers, and schemas live for each framework

## Quick Start

```bash
# Install
npx skills add theamitv/skills --skill confluence-docs-generator

# Use in Claude Code
/confluence-docs-generator Document this project for Confluence
```

## When It Won't Work

- **No discoverable API layer** — If the codebase has no routes or endpoints, the API reference will be skipped (not fabricated).
- **No end-user surface** — Pure backend libraries with no UI or CLI will skip the user guide.
- **Large monorepos** — Repos with 150+ files or multiple independent services will prompt you to choose: one set of docs or one per service.
- **Confluence API access** — This skill produces local Markdown files only. It never calls the Confluence API. You paste the files manually.
- **Non-code projects** — Requires actual source code to analyze. Design docs, config-only repos, or binary distributions won't produce meaningful output.

## Structure

```
confluence-docs-generator/
├── SKILL.md                          # Skill metadata and instructions
├── README.md                         # This file
├── scripts/
│   ├── scan_repo.py                  # Inventory scanner (pure Python stdlib)
│   ├── find_endpoints.py             # Regex-based endpoint extractor (10 frameworks)
│   └── validate_confluence_md.py     # Confluence paste-safety validator
├── references/
│   ├── frameworks.md                 # Framework lookup table (10 frameworks)
│   ├── doc-templates.md              # Exact section templates for all 3 docs
│   └── confluence-markdown-rules.md  # What Confluence paste-markdown handles
└── examples/
    └── sample-output/                # Example output (filled during testing)
```

## Verification Checklist

- [ ] Inventory scan completed and read
- [ ] Framework detected and reference consulted
- [ ] API endpoints extracted and source files read for detail
- [ ] Strategic read completed (README, entry points, config, one per module)
- [ ] All three docs drafted following doc-templates.md
- [ ] Confluence-safe Markdown rules applied
- [ ] Validation script run with zero issues
- [ ] Files saved to docs/confluence/ in the target repo

## License

MIT
