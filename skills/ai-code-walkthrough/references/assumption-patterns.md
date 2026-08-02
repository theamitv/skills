# Common AI Assumption Patterns

AI code generators make characteristic kinds of assumptions. These are the
most common patterns to watch for during a walkthrough.

## 1. API Contract Assumptions

The AI assumes an external API behaves a certain way without evidence.

**Signals:**
- Hardcoded response shapes without error handling for unexpected fields
- Assuming HTTP 200 for all responses (no 4xx/5xx handling)
- Assuming a third-party API endpoint exists and is stable
- Assuming rate limits won't be hit
- Assuming authentication tokens never expire

**Example:**
```python
# AI-generated
response = requests.get("https://api.example.com/users/1")
user = response.json()  # Assumption: always returns valid JSON with expected fields
name = user["name"]     # Assumption: "name" key always exists
# Missing: status check, timeout, retry, error handling
```

## 2. Environment Assumptions

The AI assumes the runtime environment has specific capabilities.

**Signals:**
- Hardcoded file paths that assume a specific OS (e.g., `/tmp/` on Linux vs `C:\Temp\` on Windows)
- Assuming environment variables are always set
- Assuming a specific Python/Node/Java version
- Assuming Docker or specific system packages are installed
- Assuming the filesystem is case-sensitive or case-insensitive
- Assuming UTC timezone (no explicit timezone handling)

**Example:**
```python
# AI-generated
db_url = os.environ["DATABASE_URL"]  # Assumption: always set
# Missing: fallback, check for None, descriptive error
```

## 3. Data Shape Assumptions

The AI assumes data has a specific shape that may not hold at runtime.

**Signals:**
- No null/None checks on fields that could be missing
- Assuming list indices exist (no bounds checking)
- Assuming dictionary keys exist (no `.get()` with default)
- Assuming numeric values are always positive or non-zero
- Assuming string values match a specific format (email, phone, UUID)
- Assuming dates are in a specific format
- Assuming nested data structures have consistent depth

**Example:**
```javascript
// AI-generated
const total = items.reduce((sum, item) => sum + item.price, 0);
// Assumption: items is always a non-empty array
// Assumption: every item has a price field that is a number
// Missing: Array.isArray check, price existence check, NaN guard
```

## 4. Concurrency Assumptions

The AI assumes operations are safe in concurrent contexts.

**Signals:**
- No locks around shared state mutations
- Assuming async operations complete before the next line (missing `await`)
- Assuming database transactions are atomic without explicit transaction blocks
- Assuming file writes are atomic
- Assuming no concurrent access to in-memory caches
- Assuming webhook handlers don't run in parallel

**Example:**
```python
# AI-generated
cache[user_id] = {"status": "processing"}
result = await process_user(user_id)
cache[user_id] = result
# Assumption: no other coroutine reads cache[user_id] between the two writes
# Risk: stale read if another coroutine checks cache[user_id] between lines 1 and 3
```

## 5. Error Handling Assumptions

The AI assumes operations succeed and skips error paths.

**Signals:**
- Bare `except:` or `catch` without specific exception types
- Swallowing exceptions with empty catch blocks
- No timeout on network calls (infinite wait)
- No retry logic on transient failures
- Assuming file open/create always succeeds
- Assuming database writes always succeed
- No cleanup in finally blocks (file handles, connections)

**Example:**
```python
# AI-generated
try:
    result = api_call()
    return result
except Exception:
    pass  # Assumption: failing silently is acceptable
# Missing: logging, specific exception handling, fallback value
```

## 6. Security Assumptions

The AI assumes inputs are safe and trust boundaries are respected.

**Signals:**
- String concatenation in SQL queries (SQL injection risk)
- Direct user input in HTML without escaping (XSS risk)
- User input passed to shell commands without sanitization
- Hardcoded secrets, API keys, or tokens
- Assuming user input matches a specific format without validation
- Missing authentication or authorization checks
- Assuming internal APIs don't need auth (SSRF risk)

**Example:**
```python
# AI-generated
query = f"SELECT * FROM users WHERE id = {user_input}"
# Assumption: user_input is always a safe integer
# Risk: SQL injection — user_input could be "1; DROP TABLE users;"
```

## 7. Performance Assumptions

The AI assumes operations are cheap without evidence.

**Signals:**
- N+1 database queries in loops
- Loading entire datasets into memory without pagination
- Repeated expensive computations inside loops (no memoization)
- Synchronous blocking calls in async contexts
- Creating new connections per request instead of pooling
- Unbounded list/dict growth in long-running processes

**Example:**
```python
# AI-generated
for user_id in user_ids:
    user = db.query(User).get(user_id)  # N+1: one query per user
    process(user)
# Better: db.query(User).filter(User.id.in_(user_ids)).all()
```

## 8. Type Coercion Assumptions

The AI assumes implicit type conversions work as expected.

**Signals:**
- Comparing values of different types without explicit conversion
- Assuming `None`/`null`/`undefined` behaves like a default value
- Assuming string-to-number conversion always succeeds
- Assuming `0`, `""`, `false` are equivalent
- Assuming JavaScript `==` behaves like `===`
- Assuming Python 2-style string/bytes compatibility

**Example:**
```javascript
// AI-generated
if (userInput == true) {  // Assumption: == coercion is intentional
    // This also matches 1, "1", [1], etc.
}
// Better: strict comparison or explicit check
```

## 9. Configuration Assumptions

The AI assumes specific configuration values without checking.

**Signals:**
- Hardcoded port numbers, timeouts, or batch sizes
- Assuming default config values are appropriate
- Assuming feature flags are enabled
- Assuming database connection pool sizes
- Assuming cache TTL values

**Example:**
```python
# AI-generated
timeout = 30  # Assumption: 30 seconds is right for all environments
# Better: configurable via env var with a reasonable default
```

## 10. Dependency Assumptions

The AI assumes specific libraries or versions are available.

**Signals:**
- Using functions from libraries not listed in imports/requirements
- Assuming a specific API from a library that changed across versions
- Using Python 3.10+ features (pattern matching, etc.) without checking the runtime version
- Using Node.js 18+ features (fetch, etc.) without checking
- Assuming a package is installed without checking

**Example:**
```python
# AI-generated
match value:  # Assumption: Python 3.10+ (structural pattern matching)
    case 1: return "one"
    case 2: return "two"
# Fails on Python 3.9 and earlier with SyntaxError
```
