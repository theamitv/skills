# Document Templates

These are the exact section structures for the three generated documents.
Follow them in order. Do not invent your own section headers — consistency
across runs is the point. The prose inside each section should be natural
and grounded in the actual code, not formulaic filler.

---

## architecture-overview.md

```
# [Application Name] — Architecture Overview
```

### Summary
2-3 sentences: what the system does and who it's for. Lead with the
business purpose, not the tech stack.

### Tech Stack
Table with columns: Layer | Technology | Version (if known). Layers to
cover: frontend, backend, database, cache, queue, infrastructure/cloud.

### System Architecture
Component breakdown + how they connect. Prose description of the major
components (web server, worker, database, cache, queue, external APIs).
Include a simple mermaid-style text diagram in a ` ```mermaid ` code block
if the architecture has 3+ components — Confluence renders mermaid natively.
Do NOT embed actual images.

### Data Model
Key entities and their relationships. Use a bullet list or a small table
for each major entity. Not a full schema dump — just the entities a new
engineer needs to know about first. Mention the database technology and
any notable patterns (e.g. soft deletes, event sourcing, CQRS).

### External Integrations
Third-party services/APIs this app depends on. For each: what it's used
for, how it's configured (env vars), and any notable failure modes.

### Deployment & Environments
How the application is built, tested, and deployed. What environments exist
(dev, staging, production). CI/CD pipeline overview. Infrastructure-as-code
tools used.

### Key Design Decisions
Anything non-obvious a new engineer should know, with the "why", not just
the "what". Examples: why a particular database was chosen, why a certain
pattern is used, what trade-offs were made. 3-5 items max.

---

## api-reference.md

```
# [Application Name] — API Reference
```

### Overview
Base URL(s), versioning scheme (URL prefix, header, or none), and the
authentication method at a glance.

### Authentication
How to authenticate: token format, where to get credentials, how to pass
them (header, cookie, query param). Include a short code example if the
auth flow is non-trivial.

### Endpoints
Grouped by resource/module. Each endpoint as a subsection:

```
### METHOD /path/to/resource
```

- **Description** — one line: what this endpoint does
- **Auth required** — yes/no + which auth method
- **Parameters** — table: Name | In (path/query/header) | Type | Required | Description
- **Request body** — schema description and/or a short JSON example in a
  ` ```json ` code block (only for POST/PUT/PATCH)
- **Response** — notable status codes and a short JSON example of the
  success response body in a ` ```json ` code block
- **Errors** — notable error codes (4xx/5xx) and what triggers them

### Rate Limits
Only include if rate limiting is discoverable in the code or config.
Otherwise omit this section entirely.

---

## user-guide.md

```
# [Application Name] — User Guide
```

### What this application does
Plain-language summary, no jargon. A non-technical stakeholder should
understand what this app is for after reading this paragraph.

### Getting Started
Account creation, login, first steps — if the app has a user-facing
interface. For libraries/APIs, describe how to get started using it
(install, configure, first call). Omit if there's no end-user surface.

### Core Features
One subsection per major feature, written for an end user, not a
developer. No code, no internal terminology. Use `### Feature Name`
headings. 3-6 features depending on app complexity.

### Common Workflows
Step-by-step for the 3-5 things users do most often. Numbered steps.
Each step is a short sentence. Only include if the app has a UI or
a well-defined CLI workflow.

### FAQ / Troubleshooting
Only include if genuinely inferable from the code — error messages,
validation rules, support docs found in the repo. Do not invent
generic FAQ filler.
