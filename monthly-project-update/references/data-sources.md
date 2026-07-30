# Data Sources

How to gather the raw "what actually happened" facts for a periodic project
update, for any provider stack. Degrade gracefully at every step — a
missing integration is a caveat to mention once, never a reason to fabricate
or fail the whole report.

## 1. Repo discovery

Prefer the bundled script (`../scripts/collect-git-activity.js`) — it
handles repo discovery, the git log pull, stash-noise filtering, and
ticket-prefix detection in one deterministic pass. See its header comment
for full usage and output shape.

If Node isn't available for some reason, do it manually:

1. List the top-level folders in the workspace root.
2. Keep any folder containing a `.git` entry — that's a repo in scope. Don't
   hardcode a repo list; re-detect it every run so added/removed repos are
   picked up automatically.
3. For each repo, `cd`/pass `directory` into that specific folder before
   running any git command — the workspace root itself is usually not a
   git repo when it contains multiple nested repos.
4. Run:
   ```
   git fetch --all --quiet
   git log --all --since="<since>" --until="<until>" --pretty=format:"%H|%ad|%an|%s" --date=short
   ```
5. **Drop local stash artifacts.** `git log --all` includes `refs/stash` if
   a stash exists, surfacing fake "commits" with subjects starting `WIP on
   ` or `index on `. These are not real history — exclude them.
6. Extract ticket references from commit subjects/branch names with a
   regex like `[A-Z][A-Z0-9]{1,9}-\d+` (e.g. `PALM-1234`, `ABC-9`). The
   most frequent prefix across all repos is very likely this project's
   ticket-key prefix.

## 2. Merged PR/MR enrichment (richest source — has titles + descriptions)

Prefer PR/MR titles and descriptions over raw commit subjects, which are
often terse or noisy (`fix`, `wip`, `pr comments`, `address comments`).

| Provider | How to search merged PRs/MRs in the window | How to fetch one by number/ID |
|---|---|---|
| GitHub | GitHub PR search tool with a query like `repo:<owner>/<repo> is:pr is:merged merged:<since>..<until>` | GitHub issue/PR fetch tool with the PR number |
| GitLab | GitLab MR search/list tool scoped to the project, filtered by merged state and date | GitLab MR detail tool with the MR ID |
| Azure DevOps | Azure PR list/search scoped to the project/repo | Azure PR detail tool with the PR ID |
| Jira / Linear / Trello (issue-only trackers, no PR concept) | N/A — these track tickets, not PRs; go straight to ticket lookup below | Issue detail tool with the ticket ID/key |

**Known pitfall:** PR/MR search tools can silently return zero results even
when merged PRs genuinely exist (seen with a GitHub search returning
`totalIssues: 0` for a repo with a confirmed, fetchable merged PR). If a
search comes back empty, don't conclude "no PRs merged" — cross-check
against the commit log for `Merge pull request #N` / `Merge branch` style
messages, then fetch that specific PR number directly instead of relying on
search.

## 3. Issue-tracker ticket enrichment (optional)

For each unique ticket key found in step 1, try to look up its title/status
for a more authoritative description than the commit message alone.

| Provider | Tool |
|---|---|
| Jira | Issue-detail tool with `provider: jira`, `issue_id: <KEY-123>` |
| Linear | Issue-detail tool with `provider: linear` |
| Azure Boards | Issue-detail tool with `provider: azure` (needs org/project) |
| GitHub Issues | GitHub issue fetch tool with the issue number |

**Known pitfall:** Issue-tracker MCP tools frequently require a one-time
interactive sign-in (e.g. a GitKraken/Jira OAuth link). If the tool returns
an auth-required message instead of data, treat that tracker as
unavailable for this run — don't retry repeatedly, don't block the report,
and mention it once as a caveat: *"Jira lookup unavailable (auth required),
descriptions are derived from commit/PR text only."*

## 4. Consolidating multiple signals

When a PR/MR, several commits, and a tracker ticket all describe the same
piece of work, merge them into **one** report item. Priority for which text
to use as the description:

1. PR/MR title (or tracker ticket title if there's no PR/MR)
2. PR/MR body, only if the title alone is too vague
3. Commit subjects, only as a last resort — and only the meaningful ones
   (skip routine noise like `version bump`, `merge branch`, `wip`)
