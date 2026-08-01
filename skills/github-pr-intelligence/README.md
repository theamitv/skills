# GitHub PR Intelligence

> Enterprise PR review — architecture, security, performance, testing, and deployment risk analysis.

Review Pull Requests like a Staff Engineer. 12-phase pipeline: architecture, security, performance, reliability, scalability, code quality, testing, and deployment risk.

## What It Does

- **12-Phase Review Pipeline** — Context → Categorize → Dependencies → Architecture → Security → Performance → Reliability → Scalability → Code Quality → Testing → Deployment → Summary
- **Evidence-Based** — Every finding cites specific files and line numbers
- **Severity Scoring** — Critical/High/Medium/Low/Suggestion with business and technical impact
- **HTML Dashboard** — Dark mode, charts, issue cards, heat maps
- **Merge Recommendation** — Go/no-go with overall score (0-100)

## Quick Start

```bash
# Install
npx skills add theamitv/github-pr-intelligence

# Use in Claude Code
/github-pr-intelligence Review PR #124
```

## When It Won't Work

- **No `gh` CLI** — Requires GitHub CLI (`gh`) installed and authenticated to fetch PR metadata and diffs.
- **Non-GitHub repos** — Designed for GitHub PRs. GitLab MRs and Bitbucket PRs are not directly supported.
- **Private repos without access** — Requires read access to the repository. Cannot review PRs in repos you don't have access to.
- **Binary-only diffs** — Cannot review image, binary, or minified file changes. Source code diffs only.
- **Auto-approve** — Provides recommendations and findings. Does not auto-approve, merge, or apply changes.
- **Large PRs** — Very large diffs (500+ files) may need focused scoping to stay within context limits.

## Structure

```
github-pr-intelligence/
├── SKILL.md                    # Skill metadata and triggers
├── README.md                   # This file
├── references/
│   ├── review-dimensions.md    # Severity levels, checklists
│   └── security-checklist.md   # OWASP security review checklist
├── examples/
│   └── usage.md                # Usage examples
└── scripts/
    └── review.sh               # PR data fetcher
```

## License

MIT
