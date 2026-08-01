---
name: github-pr-intelligence
description: "Enterprise PR review — architecture, security, performance, testing, and deployment risk analysis. Triggers on: 'review my latest PR', 'review PR #', 'review this pull request', 'review security', 'review performance', 'review architecture', 'generate HTML dashboard', 'generate executive summary'."
---

# GitHub PR Intelligence

Review Pull Requests like a Staff Engineer. 12-phase pipeline: architecture, security, performance, reliability, scalability, code quality, testing, and deployment risk. Evidence-based findings with file:line references.

## Quick Start

When the user says "review my PR":
1. Fetch PR metadata: `gh pr view <number> --json title,body,author,headRefName,baseRefName,additions,deletions,files,changedFiles`
2. Fetch full diff: `gh pr diff <number>`
3. Understand repo structure and tech stack
4. Run the full 12-phase review pipeline

## Usage

```
Review my latest PR
Review PR #124
Review security of this PR
Review performance
Generate HTML dashboard
Generate executive summary
```

## Structure

```
github-pr-intelligence/
├── SKILL.md
├── README.md
├── references/review-dimensions.md
├── examples/usage.md
└── scripts/review.sh
```
