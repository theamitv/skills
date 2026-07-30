# monthly-project-update

An agent skill that generates a **management-ready periodic project status
update** — a monthly recap or a custom date-range report — by mining real
completed and in-progress work out of your workspace's git repos, merged
PRs/MRs, and linked issue-tracker tickets. It writes a categorized markdown
report ending in a crisp bullet **Summary**, and saves it as a standalone
`.md` file ready to forward to stakeholders.

It is **project-agnostic**: nothing in this skill is hardcoded to a
specific team, repo, or ticket-tracker prefix. It re-derives the project
title, ticket-key prefix, and repo list fresh every time it runs, from
whatever workspace it's invoked in.

## What it produces

```markdown
**<Your Project> Project Update (July)**

Key Milestones:

**1. <Category inferred from real work>**

<one crisp line per completed/in-progress item>

**2. <Another category>**

...

**Summary**

- <one crisp bullet per category, plain-English, no ticket IDs>
```

...saved as `project-updates/<project>-project-update-<window>.md`, plus
shown in chat. See [examples/sample-report.md](./examples/sample-report.md)
for a full worked example.

## Why use this instead of writing the update by hand

- Pulls from **real** git/PR/ticket history — the model is instructed to
  never invent a milestone it can't trace back to actual evidence.
- Works across **every repo in your workspace** in one pass, not just the
  one you happen to have open.
- Status wording ("deployed" vs "in progress" vs "identified") is derived
  from actual merge/branch/ticket state, not guessed.
- Categories are inferred fresh each time from what actually happened, so
  the report never forces this month's work into last month's shape.
- Ships as a ready-to-forward `.md` file, not just a chat reply.

## Requirements

- **Git** installed and on `PATH`.
- **Node.js** (any reasonably recent version) — used by the bundled
  zero-dependency helper script, `scripts/collect-git-activity.js`.
- Optional, for richer descriptions than raw commit messages:
  - A GitHub/GitLab/Azure DevOps PR or MR search/fetch tool.
  - A Jira/Linear/Azure Boards/GitHub Issues lookup tool.
  - Neither is required — the skill falls back to commit history alone and
    says so once as a caveat in the report.

## Installation

Copy this whole folder into one of the standard skill locations for your
tool, keeping the folder name `monthly-project-update`:

| Location | Scope |
|---|---|
| `.github/skills/monthly-project-update/` | Project (shared with your team via version control) |
| `.agents/skills/monthly-project-update/` | Project |
| `.claude/skills/monthly-project-update/` | Project |
| `~/.agents/skills/monthly-project-update/` | Personal, across all your workspaces |

## Usage

Just ask, in plain language, from a workspace containing one or more git
repos:

- "Give me a project update for July"
- "Monthly summary for last month"
- "Build a status report for 14-07-2026 to 29-07-2026"
- "What did we ship in June 2026?"

Or invoke it directly with `/monthly-project-update <month> [year]` or
`/monthly-project-update <start date> to <end date>`.

The title defaults to whatever this project is actually called (see
[references/categorization.md](./references/categorization.md#deriving-the-project-title))
— you can also just say "call it the Acme update" to override it.

## Folder structure

```
monthly-project-update/
├── SKILL.md                        # Entry point the agent loads first
├── README.md                       # This file (human-facing overview)
├── scripts/
│   └── collect-git-activity.js     # Deterministic, dependency-free repo/commit collector
├── references/
│   ├── data-sources.md             # Provider tool mapping + known pitfalls
│   ├── categorization.md           # Title derivation, status verbs, dynamic categories
│   └── report-template.md          # Exact render structure + file-saving convention
└── examples/
    └── sample-report.md            # Full worked example (fictitious "Acme Platform")
```

## Known limitations

- PR/MR search APIs can occasionally return zero results even when merged
  PRs exist — the skill cross-checks against commit messages and fetches
  specific PR numbers directly when this happens (see
  [references/data-sources.md](./references/data-sources.md)).
- Ticket-tracker lookups (Jira, Linear, Azure Boards) often need a one-time
  interactive sign-in; if unavailable, the report is still generated using
  commit/PR text alone, with a caveat noted at the end.
- The helper script only scans repos one level directly under the given
  `--root`; deeply nested or monorepo-in-monorepo layouts aren't
  auto-discovered.
