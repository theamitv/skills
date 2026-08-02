# Usage Examples

## Basic Diagnosis

```
Diagnose flaky test in src/users/UserService.test.ts
Why is the login test flaky?
Investigate flaky test in payments integration
```

Triggers the full four-phase process: think → isolate → classify → report.

## Specific Test

```
Diagnose "should create user" test in UserService.test.ts
```

The skill will focus on a single test case within a test file.

## E2E Test Flakiness

```
The Playwright test for checkout keeps failing intermittently
Our Cypress test for the dashboard is flaky on CI
```

The skill will focus on selector fragility and timing as primary suspects, with environment differences for CI-specific failures.

## CI-Only Flakiness

```
This test passes locally but fails on CI every 3rd run
```

The skill will compare environment differences (Node version, OS, timezone, resources) and run with CI-like conditions.

## Full Suite Investigation

```
Our test suite has 5 flaky tests — investigate all of them
```

The skill will batch-diagnose multiple flaky tests, looking for common patterns across failures.

## After a Fix

```
I added a waitFor — did that fix the flaky test?
```

The skill will rerun the diagnosis to confirm the fix resolved the flakiness.

## Example Diagnosis Output

### Phase 1 — Think
```
Test: src/components/UserList.test.tsx — "renders user list"
Type: React component test (Jest + React Testing Library)
What it touches: API call to /api/users, async rendering, DOM elements
Failure pattern: Fails ~30% of the time on CI, never fails locally
Rerun cost: ~200ms per run — N=50 is feasible
```

### Phase 2 — Isolate
```
N=50 isolated reruns: 35/50 passed (70%)
Suite context: 33/50 passed (66%) — similar to isolated
Reverse order: 34/50 passed (68%) — not order-dependent
Varied timing:
  - 0ms delay: 35/50 passed
  - 100ms delay: 42/50 passed
  - 500ms delay: 50/50 passed ✅
CI run: 30/50 passed (60%) — worse on CI
```

### Phase 3 — Classify
```
Root Cause: Timing (primary) + Environment Differences (contributing)
Evidence:
  - Passes 100% with 500ms delay → timing issue
  - Worse on CI → CI is slower, making the race condition more likely
  - Not order-dependent → not shared state or order dependency
  - No network calls → not network dependency
  - Uses getByText → not selector fragility (but could be improved)
```

### Phase 4 — Report
```
Test: src/components/UserList.test.tsx — "renders user list"
Flakiness: 35/50 passes (70%)
Root Cause: Timing — race condition between data fetch and render assertion
Evidence:
  - Passes with 500ms delay before assertion (50/50)
  - Fails without delay (35/50)
  - Worse on CI (60%) — CI CPU throttling widens the race window
  - Not order-dependent, no network calls, no shared state
Recommendation:
  1. Replace `getByText` with `findByText` (which retries):
     - Before: expect(screen.getByText('Alice')).toBeInTheDocument()
     - After: expect(await screen.findByText('Alice')).toBeInTheDocument()
  2. Pin Node version in CI to match local development
  3. Add retry in CI config for this test as short-term mitigation
```
