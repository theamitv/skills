# Categorization, Status, and Title Derivation

## Deriving the project title

The report heading is `<Title> Project Update`. Unless the user gives an
explicit title, derive it in this priority order:

1. A project/product name the user has already used in conversation for
   this workspace (e.g. they call it "Acme" or "PALM").
2. The dominant ticket-key prefix shared across the repos' commits/branches
   (e.g. most references are `PALM-####` → title = "PALM"). The bundled
   script auto-detects this for you (`ticketPrefix` field).
3. The workspace root folder name, uppercased if it reads like a short
   acronym (e.g. `palm` → "PALM"), or title-cased otherwise (e.g.
   `acme-platform` → "Acme Platform").

Never default to an unrelated sample/brand name from a previous report or
example — each workspace gets its own real project name derived from
itself.

## Determining status per item

Infer a status verb from the evidence — don't default to "deployed" for
everything:

| Evidence | Status phrasing |
|---|---|
| PR/MR merged to the repo's default/release branch | "deployed", "resolved", "implemented", "merged" |
| PR/MR merged to a non-default branch (e.g. a shared QA/staging branch), or tracker status "In QA"/"In Review" | "in QA", "in review" |
| Open PR/MR, draft PR/MR, or tracker status "In Progress" | "in progress" |
| Tracker ticket only, status "To Do"/"Backlog"/newly created with no code yet | "identified", "planned" |

Don't call something "deployed" or "shipped" just because a branch exists —
verify it actually merged to the default/release branch first.

## Classifying into categories (dynamic, not fixed)

Do **not** force items into a fixed, memorized set of categories. Read the
actual work for this period and group it under whatever category names
best fit it. Reusable category name ideas (use only the ones that
genuinely apply, and freely rename/merge/split/add/drop to match reality):

- Deployments & Fixes / Bug Fixes
- New Features
- UI & Branding
- Infrastructure & Upgrades
- Security & Compliance
- Package & Runtime Upgrades
- AI / Data / Translation Features
- Research & POCs
- In Progress / Upcoming

Every category must have at least one real item — never emit an empty
category just to match a past report's shape or a fixed template.

Order categories roughly by stakeholder importance: shipped work and fixes
first, then features/UI, infra, security/compliance, exploratory work, and
open/in-progress items last.

## Writing one-line item summaries

One concise, factual line per item. Past tense for done work,
present/gerund for ongoing work. No leading bullet dash. Mention what
changed and where — never a vague catch-all:

```
Footer UI, navigation font size, and primary button styling fixes deployed
Login failure on staging and non-functional help icon bugs identified and in progress
```

Avoid: "various bug fixes", "several improvements made", "some UI updates".
