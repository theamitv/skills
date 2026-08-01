---
name: monthly-project-update
description: >
  Generate a management-ready periodic project status update (a monthly
  recap or a custom date-range report) by mining REAL completed and
  in-progress work — git history, merged PRs/MRs, and linked issue-tracker
  tickets — across every repo in the current workspace. Produces a
  categorized markdown report ending in a crisp bullet Summary, and saves
  it as a standalone .md file suitable for forwarding to stakeholders.
  Works with any git-based multi-repo (or single-repo) workspace and any
  issue tracker (GitHub, GitLab, Jira, Azure DevOps, Linear) — nothing here
  is specific to one project or team. Use when asked to "give a project
  update", "monthly summary", "status report", "sprint recap", "what did
  we ship in <month>", or "build the project update".
argument-hint: '<month> [year] | <start date> to <end date> [title]  e.g. "July", "July 2026", or "14-07-2026 to 29-07-2026"'
---

# Periodic Project Update

Produces a stakeholder-ready status report by pulling **real** work out of
this workspace's repos — never invent or guess milestones. If there isn't
enough evidence for a line, leave it out (or ask the user). This skill is
project-agnostic: it derives the project name, ticket-key prefix, and repo
list fresh from whatever workspace it's run in.

## When to Use

- Asked for a periodic (monthly, sprint, custom-range) project update,
  status report, or "what did we complete in `<month>`" summary.
- Trigger words: "project update", "monthly summary", "status report",
  "sprint recap", "key milestones", "what did we ship".

## Inputs

- **Time window** (required, flexible form):
  1. **Month** [+ optional year] — e.g. "July" or "July 2026". Assumes the
     current year if omitted.
  2. **Explicit date range** — e.g. "14-07-2026 to 29-07-2026" or
     "2026-07-14..2026-07-29".
  If neither is given, ask which one the user means before proceeding.
- **Title** (optional) — report heading is `<Title> Project Update`. If not
  given explicitly, derive it (see [categorization reference](./references/categorization.md#deriving-the-project-title))
  from context, the dominant ticket-key prefix, or the workspace folder
  name. Never reuse a brand name from an unrelated example/past report.
- **In report prose, always use each repo's real name** (folder/repo name
  as it actually exists) — never substitute an invented or example alias.

## Quick Start

1. **Compute the window** from the inputs above (see step 1 below).
2. **Collect raw activity** with the bundled helper script — see
   [data-sources reference](./references/data-sources.md) for the exact
   command, provider-specific enrichment (GitHub/GitLab/Jira/Azure/Linear),
   and known pitfalls.
3. **Classify and write** each item — see
   [categorization reference](./references/categorization.md) for status
   verbs and dynamic category rules.
4. **Render and save** the report — see
   [report template reference](./references/report-template.md) for the
   exact structure, Summary rules, and file-naming convention.
5. Compare against [examples/sample-report.md](./examples/sample-report.md)
   before presenting — it shows the expected tone, crispness, and shape.

## Procedure

### 1. Discover repos and compute the window

Run the bundled script once per report — it discovers every repo under the
workspace root, computes the date window, pulls filtered commit history
from all branches, and auto-detects the ticket-key prefix, in one
deterministic pass:

```
node <this-skill-folder>/scripts/collect-git-activity.js --root <workspace-root> --month July --year 2026
# or, for an explicit range:
node <this-skill-folder>/scripts/collect-git-activity.js --root <workspace-root> --since 14-07-2026 --until 29-07-2026
```

Read its JSON output (see the script's header comment for the exact shape).
Treat any repo with `"reachable": false` as a caveat, not a failure — keep
going with the rest. Full details, fallback behavior if Node/git aren't
available, and provider-specific enrichment are in
[references/data-sources.md](./references/data-sources.md).

### 2. Enrich with PRs/MRs and tracker tickets

For each unique ticket reference and each repo, try to fetch richer
titles/descriptions/status from whatever provider this workspace actually
uses (GitHub, GitLab, Jira, Azure DevOps, Linear). Degrade gracefully if a
tool/integration isn't accessible — don't fail the whole report. See the
provider tool-mapping table in
[references/data-sources.md](./references/data-sources.md).

### 3. Consolidate and dedupe

Merge PR/MR + commits + tracker ticket that reference the same piece of
work into a **single** item. Prefer the PR/ticket title over raw commit
subjects when available — commit subjects are often terse or noisy (`fix`,
`wip`, `pr comments`).

### 4. Determine status per item

Infer a status verb from the evidence — see the status table in
[references/categorization.md](./references/categorization.md). Don't
default to "deployed" for everything.

### 5. Classify into categories (dynamic, not fixed)

Group items under whatever category names genuinely fit this period's work
— see [references/categorization.md](./references/categorization.md) for
guidance and reusable category name ideas. Never emit an empty category.

### 6. Write one-line summaries per item

One concise, factual line per item — past tense for done work,
present/gerund for ongoing work. No leading bullet dash. See style examples
in [references/report-template.md](./references/report-template.md).

### 7. Render the final report

Follow the exact structure (heading, numbered categories, closing
**Summary**) in
[references/report-template.md](./references/report-template.md).

### 8. Save a shareable markdown file

Always save the rendered report as a standalone `.md` file — see the
location/filename convention and document-wrapper format in
[references/report-template.md](./references/report-template.md). Ask
before overwriting an existing file with the same name.

### 9. Present with caveats

Show the rendered report in chat and give the saved file's path. If any
data source was inaccessible, mention it once as a caveat — never bury a
data-quality caveat inside the milestone content itself.

## Quality Checklist

- [ ] Every line traces back to a real commit, PR/MR, or tracker ticket —
      nothing fabricated.
- [ ] No empty categories.
- [ ] Status verbs match the evidence (don't call something "deployed" if
      it's still an open PR).
- [ ] Repos untouched in the window are simply absent, not called out as
      "no activity".
- [ ] Any inaccessible data source is mentioned once as a caveat, not
      silently guessed around.
- [ ] The report was saved as a `.md` file with a proper heading and
      date-window footnote — not left chat-only.
- [ ] The report ends with a **Summary** section: one crisp bullet per
      category, no ticket IDs/PR numbers, no new facts.
- [ ] Nothing in the output is a leftover brand name, project name, or
      repo alias from an example/past report — it matches this workspace.
