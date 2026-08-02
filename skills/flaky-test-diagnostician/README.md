# Flaky Test Diagnostician

> Flaky test diagnostician — reruns a failing test N times, isolates it from the suite, and classifies which of six root causes is likely.

Flaky tests erode trust in your test suite. Teams spend 5-10 hours a week rerunning builds, approving over failures, and chasing ghosts — and every flaky build that passes on rerun is a real defect that could have been caught. Instead of guessing, this skill systematically isolates the test, reruns it in controlled conditions, and classifies the failure against six known root causes.

## What It Does

- **Four-Phase Process** — Think → Isolate → Classify → Report
- **Controlled Reruns** — Runs the test N times in isolation, records pass/fail per run
- **Suite Context Analysis** — Runs in full suite, reverse order, and with varied timing to isolate the root cause
- **Six Root Cause Classification** — Timing, shared state, network dependencies, selector fragility, environment differences, order dependency
- **Actionable Recommendations** — Each diagnosis includes a specific fix recommendation, not just a label
- **Evidence-Based** — Every classification is backed by rerun evidence, not guesswork

## Quick Start

```bash
# Install
npx skills add theamitv/skills --skill flaky-test-diagnostician

# Use in Claude Code
/flaky-test-diagnostician Diagnose why UserService test is flaky
```

## When It Won't Work

- **No reproduction** — The test must fail at least intermittently. A test that always passes or always fails isn't flaky — it's either correct or broken.
- **No test runner** — Requires a test runner (Jest, Vitest, Playwright, Cypress, Mocha, pytest, etc.) to execute the test. Manual testing scenarios can't be diagnosed.
- **Infrastructure flakiness** — If the CI runner itself is unreliable (OOM kills, network timeouts on package install, disk full), that's an infrastructure problem, not a test problem. Fix the CI environment first.
- **Production-only failures** — Tests that fail only in production-like environments you can't access can't be diagnosed. You need at least CI logs or a reproduction environment.
- **Non-deterministic application code** — If the *application* (not the test) has race conditions or non-deterministic behavior, the test may be correctly catching real bugs. Diagnose the app code, not the test.

## Structure

```
flaky-test-diagnostician/
├── SKILL.md                          # Skill metadata and instructions
├── README.md                         # This file
├── references/
│   └── root-causes.md                     # Six root causes reference with signatures and fixes
├── examples/
│   └── usage.md                           # Usage examples
└── scripts/
    └── diagnose-flaky-test.sh             # Flaky test diagnosis runner
```

## Verification Checklist

- [ ] Test confirmed flaky (not always passing or always failing)
- [ ] N reruns completed and pass/fail recorded
- [ ] Suite context analysis done (isolation vs suite)
- [ ] Reverse order run completed
- [ ] Varied timing run completed
- [ ] Root cause classified with supporting evidence
- [ ] Specific fix recommendation provided

## License

MIT
