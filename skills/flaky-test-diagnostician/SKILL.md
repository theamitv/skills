---
name: flaky-test-diagnostician
description: "Flaky test diagnostician — reruns a failing test N times, isolates it from the suite, and classifies which of six root causes is likely. Triggers on: 'diagnose flaky test', 'flaky test', 'test is flaky', 'unreliable test', 'test fails intermittently', 'flaky test investigation', 'why is this test flaky', 'stabilize this test'."
---

# Flaky Test Diagnostician

Flaky tests erode trust in your test suite. Teams spend 5-10 hours a week rerunning builds, approving over failures, and chasing ghosts — and every flaky build that passes on rerun is a real defect that could have been caught.

This skill systematically isolates a flaky test, reruns it in controlled conditions, and classifies the failure against six known root causes — timing, shared state, network dependencies, selector fragility, environment differences, and order dependency — so you fix the cause, not the symptom.

## Phase 1 — THINK

Before running anything, understand the test and its context:

1. **What kind of test is it?** Unit, integration, E2E (Playwright/Cypress), or component test? Each has different flakiness profiles.
2. **What does the test touch?** Filesystem, network, database, time, random values, shared fixtures, global state, other tests' leftovers?
3. **What's the failure pattern?** Does it fail on CI but pass locally? Pass in isolation but fail in the suite? Fail at specific times of day?
4. **What's the rerun cost?** How long does one run take? N=10 vs N=50 vs N=100 depends on test duration.

## Phase 2 — ISOLATE

1. **Confirm flakiness** — Run the test N times in isolation (N=10 for fast tests, N=5 for slow ones). Record pass/fail per run.
2. **Run in suite context** — Run the full suite but only report this test's result. If it passes in isolation but fails in the suite, it's order-dependent or shared-state.
3. **Run in reverse order** — Run the test suite in reverse order. If the failure moves to a different test, it's order-dependent.
4. **Run with varied timing** — Add artificial delays (100ms, 500ms, 1000ms) before assertions. If timing changes the outcome, it's a timing issue.
5. **Run on CI (if applicable)** — If the test passes locally but fails on CI, compare environment differences.

## Phase 3 — CLASSIFY

Map the evidence to one or more of the six root causes:

| Root Cause | Signature | Fix |
|---|---|---|
| **Timing** | Passes with delays, fails without. Race conditions, unawaited promises, missing `waitFor`. | Add proper waits/retries, use `waitFor`/`findBy`, fix race conditions. |
| **Shared State** | Passes in isolation, fails in suite. Test A mutates state test B depends on. | Reset state between tests, use isolated fixtures, avoid mutable globals. |
| **Network Dependencies** | Fails when network is slow/unavailable. Relies on external APIs, no mocking. | Mock external calls, use test doubles, add retry logic, use MSW/nock. |
| **Selector Fragility** | E2E test fails intermittently — element not found, stale reference. | Use data-testid attributes, prefer role selectors, wait for element stability. |
| **Environment Differences** | Passes locally, fails on CI. Different OS, Node version, timezone, locale, screen size. | Containerize tests, pin dependencies, match CI environment locally. |
| **Order Dependency** | Test A passes alone, fails when test B runs before it. Test B leaks state. | Make tests hermetic, use random test order, run `--shard` in CI. |

## Phase 4 — REPORT

Produce a structured diagnosis:

```
Test: src/users/UserService.test.ts — "should create user"
Flakiness: 7/10 passes (N=10, isolated)
Root Cause: Timing — race condition in async user creation
Evidence:
  - Passes with 200ms delay before assertion (10/10)
  - Fails without delay (7/10)
  - Passes in isolation and in suite (not order-dependent)
  - No network calls, no shared state
Recommendation: Add `await` to user creation call, or use `waitFor` in assertion
```

## Security Rules (never violate)

- **No `curl | bash`** — Use only `npm install` / `npm uninstall` for package management.
- **No `eval`** — Never use `eval` or equivalent dynamic code execution.
- **No file operations outside project** — Never read, write, or modify files outside the project directory.
- **No secrets in output** — Never print tokens, API keys, or credentials in reports or logs.
- **No destructive test operations** — Never modify test source files without user confirmation. The diagnosis script is read-only.
- **Backup before changes** — Always create a git commit or stash before modifying test files.
- **Validate before write** — Always run the test suite after applying a fix to confirm the fix works and nothing else broke.
