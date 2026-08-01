# Usage Examples

## Python 2 → 3 Migration

```
Migrate this Django app from Python 2 to Python 3
Run 2to3 on our project
```

Triggers the full three-phase process: audit → plan → execute.

## Django Version Bump

```
Upgrade Django from 2.2 to 3.2
Bump Django from 3.2 to 4.2
```

The skill will check the specific version range and map breaking changes to the codebase.

## String/Bytes Issues

```
We're getting UnicodeDecodeError after the Python 3 migration
```

The skill will scan for implicit string/bytes mixing in I/O, sockets, and serialization code.

## Middleware Migration

```
Our middleware stopped working after the Django upgrade
```

The skill will detect deprecated middleware signatures and map them to the current style.

## ORM Behavior Change

```
Our queries return different results after the Django upgrade
```

The skill will identify ORM behavior changes for the specific version jump and verify against real data.

## URL Pattern Migration

```
Migrate from url() to path() in Django URLs
```

The skill will convert `url()` patterns to `path()` and `re_path()` equivalents.

## Example Migration Output

### Phase 1 — Risk Audit
```
This Django app (Python 2, Django 1.11 → Python 3, Django 3.2):
- 12 files with raw I/O (open() without encoding) — HIGH RISK
- 4 files with socket/network I/O — HIGH RISK
- 3 serialization modules (pickle, JSON, custom) — HIGH RISK
- 8 ForeignKey fields without on_delete — will break on Django 2.0+
- 2 old-style middleware classes (process_request/process_response)
- 1 file using django.utils.six (removed in Django 3.0)
- 3 files using url() instead of path()/re_path()
- 0 test coverage on I/O modules — ⚠️ add tests before migrating
```

### Phase 2 — Migration Plan
```
Priority order (by blast radius):
1. settings.py + middleware (highest blast radius — everything depends on it)
2. I/O modules (highest risk — string/bytes silent corruption)
3. Serialization modules (high risk — data corruption)
4. ORM model definitions (on_delete, JSONField)
5. URL patterns (url() → path()/re_path())
6. Remaining files (lower risk)

Django 1.11 → 3.2 breaking changes:
- on_delete required → 8 ForeignKey fields (models.py)
- MIDDLEWARE_CLASSES → MIDDLEWARE → 2 middleware classes
- django.utils.six removed → 1 file
- url() deprecated → 3 URL files
- django.core.urlresolvers → django.urls → 5 files

Test gaps: I/O modules (0 tests) — add tests before migrating
```

### Phase 3 — Verification
```
✅ No implicit string/bytes coercion errors (tested with UTF-8, Latin-1, binary input)
✅ ORM queries return same result sets (verified on production DB copy)
✅ Middleware execution order and behavior unchanged
✅ Test coverage added for I/O modules before migration
```
