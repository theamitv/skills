---
name: python2-to-3-django-upgrade-auditor
description: "Migrate Python 2 to Python 3, or bump a Django app across major versions. Triggers on: '2to3', Django version upgrade, deprecation warnings during Python/Django upgrade, deprecated features, string/bytes errors, ORM behavior changes. Do NOT trigger for routine minor/patch version bumps with no known breaking changes."
---

# Python 2→3 / Django Version Bump Auditor

## Phase 1 — THINK
Automated tools like `2to3` handle syntax, but the real bugs in this migration are semantic and invisible until runtime — implicit string/bytes handling, and Django ORM query behavior that quietly changed between major versions.
- Scan for implicit string/bytes mixing (Python 2 let this slide; Python 3 raises or silently misbehaves depending on context) — flag every file handling raw I/O, sockets, or serialization, since that's where this bites hardest
- For Django specifically, check the exact major-version jump being made and pull the real list of breaking ORM/behavior changes for that specific version range (querysets, `on_delete` requirements, middleware signature changes, template autoescaping differences) — don't rely on a generic "Django changed things" assumption, the actual breaking changes are version-range-specific
- Check for deprecated middleware signatures (`process_request`/`process_response` style vs. the newer callable-based middleware) — this is a common silent breakage point
- Identify any code relying on dict ordering being unspecified (pre-3.7 assumption) or on old-style classes/metaclasses — Python 3-only projects moved past both

## Phase 2 — PLAN
1. Prioritized list of files/modules by blast radius — start with core I/O/serialization code (highest risk from string/bytes issues) and shared middleware/ORM base classes (highest blast radius if wrong), not just alphabetical/random order
2. Explicit list of Django breaking changes that apply to *this specific* version jump, each mapped to where in the codebase it applies
3. Test coverage gap check: which of the high-risk areas from Phase 1 currently lack tests — recommend adding tests *before* migrating those areas, since they're exactly where silent behavior changes would go unnoticed

## Phase 3 — EXECUTE
- Migrate in the planned order, verifying tests pass after each module, not at the very end
- Fix string/bytes issues explicitly (proper `.encode()`/`.decode()` at I/O boundaries) rather than blanket-suppressing errors
- Update middleware to the current signature style, preserving exact execution order and behavior
- Update ORM usage per the specific breaking changes identified in Phase 2 — verify query behavior against real data, since some ORM changes alter *results*, not just syntax

## Verification checklist
- [ ] No implicit string/bytes coercion errors under real I/O (test with actual encoded input, not just ASCII sample data)
- [ ] ORM queries verified to return the same result sets pre/post migration on production-like data
- [ ] Middleware execution order and behavior unchanged
- [ ] Test coverage added for any high-risk area that lacked it before migrating

## Security Rules (never violate)
- **No `curl | bash`** — Use only `pip install` / `pip uninstall` for package management.
- **No `eval`** — Never use `eval` or equivalent dynamic code execution.
- **No file operations outside project** — Never read, write, or modify files outside the project directory.
- **No secrets in output** — Never print database connection strings, API keys, or credentials in reports or logs.
- **Backup before destructive ops** — Always create a git commit or stash before running `2to3` or modifying middleware/ORM code.
- **Validate before write** — Validate Python syntax compiles (`python3 -m py_compile`) before declaring a file done. Run tests after each module.
- **No silent dependency installs** — Tell the user which packages will be installed and get implicit confirmation before running `pip install`.
- **Never blanket-suppress string/bytes errors** — Fix `.encode()`/`.decode()` at I/O boundaries explicitly. No silent data corruption.
