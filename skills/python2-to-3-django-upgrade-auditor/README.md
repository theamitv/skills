# Python 2→3 / Django Version Bump Auditor

> Migrate Python 2 to Python 3 or bump Django across major versions without silent string/bytes corruption or ORM behavior changes.

Automated tools like `2to3` handle syntax, but the real bugs are semantic and invisible until runtime — implicit string/bytes handling, and Django ORM query behavior that quietly changed between major versions. This skill audits the real risk areas before any automated tool runs.

## What It Does

- **Three-Phase Process** — Audit → Plan (with user approval) → Execute
- **String/Bytes Scan** — Flags every file handling raw I/O, sockets, or serialization for explicit `.encode()`/`.decode()` fixes
- **Version-Specific Breaking Changes** — Maps Django breaking changes for the *specific* version jump, not a generic list
- **Middleware Signature Audit** — Detects deprecated `process_request`/`process_response` style middleware
- **Blast Radius Prioritization** — Core I/O and shared base classes first, not alphabetical order
- **Test Coverage Gap Check** — Recommends adding tests before migrating high-risk areas

## Quick Start

```bash
# Install
npx skills add theamitv/skills --skill python2-to-3-django-upgrade-auditor

# Use in Claude Code
/python2-to-3-django-upgrade-auditor Audit this Django app for Python 3 migration
```

## Structure

```
python2-to-3-django-upgrade-auditor/
├── SKILL.md                            # Skill metadata and instructions
├── README.md                           # This file
├── references/
│   ├── string-bytes-guide.md               # String/bytes handling migration guide
│   └── django-breaking-changes.md          # Django version-specific breaking changes
├── examples/
│   └── usage.md                             # Usage examples
└── scripts/
    └── audit-python-django.sh              # Python/Django upgrade audit scanner
```

## Verification Checklist

- [ ] No implicit string/bytes coercion errors under real I/O (test with actual encoded input, not just ASCII sample data)
- [ ] ORM queries verified to return the same result sets pre/post migration on production-like data
- [ ] Middleware execution order and behavior unchanged
- [ ] Test coverage added for any high-risk area that lacked it before migrating

## License

MIT
