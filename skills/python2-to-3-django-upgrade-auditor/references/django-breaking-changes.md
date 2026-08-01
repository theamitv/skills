# Django Version-Specific Breaking Changes

## How to Use This Reference

**Do not apply this list generically.** Check the user's exact version jump and use only the relevant section. Each major version has different breaking changes.

## Django 1.11 → 2.0

| Change | Impact | Code to Check |
|--------|--------|---------------|
| `on_delete` required for `ForeignKey`/`OneToOneField` | Runtime error on existing migrations | All `ForeignKey`/`OneToOneField` declarations |
| `MIDDLEWARE_CLASSES` → `MIDDLEWARE` | Old-style middleware breaks silently | `settings.py` middleware config |
| `url()` → `path()`/`re_path()` | `url()` still works but deprecated | URL patterns |
| `django.core.urlresolvers` → `django.urls` | ImportError | All `from django.core.urlresolvers import` |
| `request.user` is always `AbstractBaseUser` instance | Code checking `is_anonymous` on non-authenticated users still works but pattern changed | Auth-related template/views |
| `ShortUUIDField` removed | ImportError | Models using ShortUUIDField |
| `extra()` queryset method deprecated | Deprecation warning | Querysets using `.extra()` |
| `LANGUAGES_BIDI` removed | ImportError | Settings or utils importing this |

## Django 2.0 → 2.1

| Change | Impact | Code to Check |
|--------|--------|---------------|
| `QuerySet.reverse()` with `QuerySet.order_by()` | Behavior change | Chained queryset ordering |
| `FileResponse` uses `django.http.FileResponse` | Import path change | File download views |
| `contrib.auth` login rate-limiting | New behavior | Login views |
| `manage.py diffsettings` output format | Scripting breakage | CI/deploy scripts parsing output |

## Django 2.2 → 3.0

| Change | Impact | Code to Check |
|--------|--------|---------------|
| `asgi.py` required for Django 3.0+ ASGI support | Missing file | Project structure |
| `django.utils.six` removed | ImportError | Any `from django.utils import six` |
| `models.CharField.validators` not automatically added | Behavior change | Model field validation |
| `FileField`/`ImageField` `__str__` returns `str` not `url` | Template rendering change | Templates using `{{ field.url }}` |
| `django.contrib.postgres.operations` `CreateExtension` | Migration order change | Postgres-specific migrations |
| `allow_relation` in database routers | New signature | Database router `allow_relation` methods |

## Django 3.0 → 3.1

| Change | Impact | Code to Check |
|--------|--------|---------------|
| `JSONField` for all DB backends | New field available | Models using custom JSONField |
| `django.db.models.fields.json` → `django.db.models` | Import path change | JSONField imports |
| `PASSWORD_RESET_TIMEOUT_DAYS` → `PASSWORD_RESET_TIMEOUT` | Setting name change | Settings and password reset URLs |
| `CSRF_COOKIE_MASKED` removed | Setting removal | CSRF-related config |

## Django 3.2 → 4.0

| Change | Impact | Code to Check |
|--------|--------|---------------|
| `timezone.utc` alias removed | ImportError | `from django.utils import timezone` usage |
| `django.conf.urls.url()` removed | ImportError | URL patterns using `url()` |
| `django.contrib.auth` `is_superuser` check | Behavior change | Admin permission checks |
| `django.core.cache.backends.base` `get_many()` | Signature change | Cache backend customizations |
| `providing_args` removed from `Signal` | TypeError | Custom signal definitions |

## Django 4.0 → 4.1

| Change | Impact | Code to Check |
|--------|--------|---------------|
| `django.forms.Form` default widget for `ImageField` | Widget change | Form rendering |
| `CSRF_TRUSTED_ORIGINS` requires scheme | CSRF failures | Settings and deployment config |
| `FileExtensionValidator` for `FileField` | New validation | File upload fields |
| `FORMS_URLFIELD_ASSUME_HTTPS` transition | Behavior change | URL field validation |

## Django 4.2 → 5.0

| Change | Impact | Code to Check |
|--------|--------|---------------|
| `DatabaseFeatures` class changes | Custom DB backend breakage | Custom database backends |
| `django.contrib.gis` `SphericalMercator` | Import path change | GIS-related imports |
| `Signer` signature algorithm default changed | Signed data invalidation | Any code using `Signer`/`django.core.signing` |
| `collectstatic` `--post-process` hook | Hook signature change | Custom static file processing |

## Common Middleware Migration

### Old-style (pre-Django 2.0)

```python
class OldStyleMiddleware:
    def process_request(self, request):
        # Do something with request
        pass

    def process_response(self, request, response):
        # Do something with response
        return response
```

### New-style (Django 2.0+)

```python
class NewStyleMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # process_request equivalent
        response = self.get_response(request)
        # process_response equivalent
        return response
```

## Common ORM Changes

### on_delete Required (Django 2.0+)

```python
# Before (Django < 2.0)
class Order(models.Model):
    user = models.ForeignKey(User)  # Implicit CASCADE

# After (Django 2.0+)
class Order(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
```

### QuerySet Behavior Changes

```python
# Django < 3.0: queryset ordering with distinct()
qs = Order.objects.filter(...).order_by('id').distinct('id')
# Django 3.0+: fields in distinct() must match order_by() start

# Django < 4.0: union() with different column counts
qs1 = ModelA.objects.all().values('id', 'name')
qs2 = ModelB.objects.all().values('id', 'name')
qs = qs1.union(qs2)
# Django 4.0+: union() requires exact column match
```
