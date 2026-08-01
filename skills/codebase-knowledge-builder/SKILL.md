---
name: codebase-knowledge-builder
description: "Repository knowledge builder — architecture, code flow, dependency graph, onboarding, technical debt analysis. Triggers on: 'explain this repository', 'explain the architecture', 'how does authentication work', 'trace this request', 'find duplicate code', 'generate onboarding guide', 'generate architecture documentation'."
---

# Codebase Knowledge Builder

Ingest a repository, build a comprehensive knowledge model, and answer deep technical questions about architecture, business logic, dependencies, and workflows. Evidence-based answers with file:line references.

## Quick Start

When the user says "explain this repository":
1. Run `scripts/analyze.sh <path>` for repo stats
2. Read key config files (package.json, tsconfig, Dockerfile, CI)
3. Understand folder structure and module organization
4. Detect technology stack
5. Answer questions based on evidence

## Usage

```
Explain this repository
How does authentication work?
Trace this request from API to database
Find duplicate code
Generate onboarding guide
Generate architecture documentation
```

## Structure

```
codebase-knowledge-builder/
├── SKILL.md
├── README.md
├── references/architecture-patterns.md
├── examples/usage.md
└── scripts/analyze.sh
```
