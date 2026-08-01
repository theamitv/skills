# API Standards Reference

## REST API Naming Conventions

| Resource | GET (List) | GET (Single) | POST (Create) | PUT (Update) | DELETE |
|----------|-----------|--------------|--------------|--------------|--------|
| /users | Returns list | - | Creates user | - | - |
| /users/{id} | - | Returns user | - | Updates user | Deletes user |
| /users/{id}/orders | Returns orders | - | Creates order | - | - |

## HTTP Status Codes

| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Validation error, malformed request |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Authenticated but not authorized |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Resource conflict (e.g., duplicate) |
| 422 | Unprocessable Entity | Business logic validation failure |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Unexpected server failure |
| 503 | Service Unavailable | Temporary outage or maintenance |

## Pagination Standards

```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalItems": 100,
    "totalPages": 5,
    "nextPage": 2,
    "prevPage": null
  }
}
```
