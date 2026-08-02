# Usage Examples

## Walk Through a Pasted Code Block

```
Walk me through this code before I commit it:

def fetch_user_data(user_id):
    response = requests.get(f"https://api.example.com/users/{user_id}")
    data = response.json()
    return {"id": data["id"], "name": data["name"], "email": data["email"]}
```

Triggers the full five-step process: collect → segment → walk through → surface concerns → verdict.

## Walk Through a File

```
Walk me through src/services/payment.ts
Review the AI-generated code in src/handlers/webhook.ts before I commit
```

The skill reads the file and walks through it line by line.

## Walk Through a Git Diff

```
Walk me through my staged changes
Review this diff before I push: git diff main...HEAD
Check the uncommitted changes in this branch
```

The skill reads the diff and walks through each changed hunk, comparing old vs new behavior.

## Walk Through a PR

```
Review the AI-generated parts of PR #42
Walk me through the changes in this PR
```

The skill fetches the PR diff and walks through it.

## Focused Review

```
Just check the error handling in this generated code
What assumptions did the AI make about the database in this code?
Are there any security issues in this generated block?
```

The skill focuses on a specific dimension of the walkthrough.

## Example Walkthrough Output

### Input
```python
def sync_users(api_url):
    response = requests.get(api_url)
    users = response.json()
    for user in users:
        db.session.add(User(name=user["name"], email=user["email"]))
    db.session.commit()
```

### Output

```
### Imports & Setup — lines 1-5

**What it does:** Fetches user data from an API and bulk-inserts into a database.

**Line-by-line:**
- Line 1: Defines sync_users taking an api_url parameter
- Line 2: GET request to the API URL
  → Assumption: api_url is always valid and reachable
  → Risk: No timeout — could hang forever if the API is down
  → Risk: No auth handling — assumes the endpoint is public
- Line 3: Parses response as JSON
  → Assumption: Response is always valid JSON
  → Risk: A 404 or 500 response would fail JSON parsing with a cryptic error
- Line 4-6: Iterates and inserts users
  → Assumption: Response body is always a list
  → Risk: If API returns {"error": "..."}, iteration fails
  → Assumption: Every user object has "name" and "email" keys
  → Risk: KeyError if fields are missing or renamed
- Line 7: Commits the transaction
  → Assumption: All inserts succeed — no partial-failure handling
  → Risk: A single bad record fails the entire batch

**Assumptions made:**
1. API always returns 200 — risk: unhandled error responses
2. Response is always a list of objects — risk: TypeError on unexpected shape
3. Every user has name and email — risk: KeyError on missing fields
4. No timeout needed — risk: hanging connection
5. Batch commit is safe — risk: no partial-failure recovery

**Verdict:** ⚠️ Needs review before commit

**Cross-cutting concerns:**
- Security: No input validation on api_url (SSRF if user-controlled)
- Performance: No pagination — will fail on large datasets
- Correctness: No error handling at all — any failure crashes the function
- Maintainability: Magic strings "name" and "email" — should use constants or model fields

**Fix before commit (priority order):**
1. Add timeout: requests.get(api_url, timeout=10)
2. Check response status: response.raise_for_status()
3. Validate response shape before iterating
4. Use .get() with defaults for optional fields
5. Add pagination or batch processing for large datasets
6. Wrap in try/except with proper error logging
```
