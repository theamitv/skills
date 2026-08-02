---
name: confluence-docs-generator
description: Generates three Confluence-ready documentation pages — architecture overview, API reference, and user guide — by analyzing a codebase. Output is clean Markdown that Confluence's paste-as-markdown auto-converts into a properly formatted wiki page (headings, tables, code blocks) with zero manual reformatting. Use this skill whenever someone asks to document a codebase, generate API docs, write a wiki page, create onboarding docs, or wants docs "ready to paste into Confluence" — even if they just say "document this app" or "write docs for this repo" without mentioning Confluence.
---

# Confluence Docs Generator

Point this skill at any codebase — Node, Python, PHP/Laravel, Java/Spring, Next.js, Django, FastAPI, Rails, or Go — and it produces three Confluence-ready Markdown files: an architecture overview, a full API reference, and an end-user guide. Paste each file into a new Confluence Cloud page; the built-in paste-as-markdown feature auto-formats headings, tables, code blocks, and lists. No manual reformatting needed.

## When to use this skill

Use this skill whenever someone needs to document a codebase for a Confluence wiki — whether they ask for "architecture docs", "API reference", "user guide", "onboarding docs", or just "can you document this app". The skill handles the full pipeline: inventory scan, framework detection, strategic code reading, and Confluence-safe Markdown generation. It never calls the Confluence API — it only produces paste-ready files.

## Workflow

### Step 1 — Confirm scope

Ask (only if not already given): which directory/repo to document, and whether the user wants all three docs or a subset. Default to all three if unspecified. Do **not** ask about Confluence space names, permissions, or anything about actually posting to Confluence — this skill only produces paste-ready files, it never calls the Confluence API.

### Step 2 — Run the inventory scan

Execute `python scripts/scan_repo.py <path>`. This produces `inventory.json` containing:
- File tree (respecting `.gitignore`-style exclusions)
- Detected language(s) and framework(s)
- A list of "key files" (README\*, package.json, composer.json, requirements.txt, pyproject.toml, go.mod, Gemfile, pom.xml, Dockerfile, docker-compose\*.yml, openapi.\*, swagger.\*, \*.env.example, migrations/\*\*, schema.prisma, etc.)

Read `inventory.json`, not the raw repo listing — this keeps context usage bounded on large codebases.

### Step 3 — Detect the framework and consult references/frameworks.md

Look up the detected framework in `references/frameworks.md` to learn where routes/controllers typically live and which patterns to use for API extraction.

### Step 4 — Extract the API surface

Execute `python scripts/find_endpoints.py <path> --framework <detected>` (or `--framework auto` to try all patterns). This produces `endpoints.json`: a raw list of `{method, path, file, line, handler_name}`. This is a mechanical first pass, not the final docs — Claude still opens each referenced file to read parameters, auth requirements, request/response shape, and error cases before writing prose.

### Step 5 — Read strategically for architecture + user docs

Read, in this priority order, stopping once you have enough to write confidently: README, entry point file(s), config/env files, docker-compose (for service topology), top-level folder structure, one representative file per module/service, and any existing `docs/` or `CHANGELOG`. Do not read every file in the repo — sample deliberately and say in your own summary what you sampled from if the user asks.

### Step 6 — Draft the three documents

Follow the exact section templates in `references/doc-templates.md`. Do not invent your own structure — consistency across runs is the point (someone publishing this skill needs predictable output).

### Step 7 — Apply Confluence-safe Markdown formatting

Follow `references/confluence-markdown-rules.md` while writing — this determines which Markdown constructs are safe to use so the paste-as-markdown conversion works cleanly (e.g., avoid raw HTML, avoid tables nested inside list items, always tag code fences with a language).

### Step 8 — Validate

Execute `python scripts/validate_confluence_md.py <output-dir>` on the three generated files. Fix anything it flags before presenting the docs.

### Step 9 — Deliver

Save the three files to `docs/confluence/` inside the target repo (create the folder if needed). Tell the user, briefly: open a new Confluence page, paste the contents of each file directly into the editor — Confluence Cloud auto-detects and formats Markdown on paste, no manual formatting needed. Do not over-explain this every time; one short line is enough.

## Handling large or monorepo codebases

If `inventory.json` shows more than ~150 files or multiple independent services/packages, ask the user once whether to document the whole monorepo as one set of three docs, or generate a separate set per service/package. Default to "whole repo as one set" if they don't have a preference, but mention the alternative.

## Handling missing information

If the codebase has no discoverable API layer, skip `api-reference.md` and say so rather than fabricating endpoints. If there's no clear end-user surface (e.g. a pure backend library), skip `user-guide.md` and explain why. Never fabricate content not grounded in the actual code — an inaccurate architecture doc is worse than no doc, since teams will trust and act on it.

## Security Rules (never violate)

- **No `curl | bash`** — Use only `pip install` / `npm install` for package management.
- **No `eval`** — Never use `eval` or equivalent dynamic code execution.
- **No file operations outside project** — Never read, write, or modify files outside the project directory.
- **No secrets in output** — Never print tokens, API keys, or credentials in reports or logs.
- **No Confluence API calls** — This skill never posts to Confluence. It only produces local Markdown files.
- **No fabricated content** — Every claim in the generated docs must be grounded in the actual codebase. If you're unsure, say so in the doc rather than guessing.
- **Backup before destructive ops** — Always create a git commit or stash before modifying files.
