---
name: ai-code-walkthrough
description: "Walks you through AI-generated code line by line before you commit — explains what each block does, surfaces silent assumptions the AI made, and flags correctness, security, and performance risks. Triggers on: 'walk me through this code', 'explain this AI-generated code', 'review this before I commit', 'what does this block do', 'check this diff', 'audit this generated code', 'is this safe to commit', 'code review before push'."
---

# AI Code Walkthrough

45% of developers say debugging AI-generated code takes longer than writing it themselves. The problem isn't that AI writes bad code — it's that developers accept code they haven't fully read, and the silent assumptions the AI made only surface later as bugs.

This skill reads AI-generated code (a block, a file, or a diff) and produces a structured walkthrough: what each section does, what assumptions the AI silently made, and what risks those assumptions introduce. Use it before you commit, before you open a PR, or whenever you look at generated code and think "I'm not sure I understand all of this."

## When to use this skill

Use this skill whenever you have AI-generated code you're about to commit and want to understand it before it becomes part of your codebase. It works on any language, any framework, any size — from a single function to a full file. It does not lint or format; it explains intent, surfaces hidden assumptions, and flags risks a quick skim would miss.

## Workflow

### Step 1 — Collect the code

Ask what code to walk through. The user can provide it as:
- A code block pasted directly in the conversation
- A file path (read the file)
- A git diff (`git diff`, `git diff --cached`, or a specific commit range)
- A PR diff (if they provide a URL or PR number)

If they give a file path or diff, read the code. If they paste a block, use that directly. Do not ask for context you don't need — the point is to surface what's *in the code*, not what the user *thinks* the code does.

### Step 2 — Segment the code

Divide the code into logical segments:
- **Imports / dependencies** — what's being pulled in
- **Type definitions / interfaces** — what contracts are defined
- **Core logic** — the main algorithm or flow
- **Error handling** — what happens when things go wrong
- **Edge cases** — what's explicitly handled vs. silently ignored
- **Side effects** — I/O, state mutation, network calls, filesystem access

For each segment, note:
- What it does (one sentence)
- What assumptions the code makes (the AI's silent bets)
- What could go wrong if those assumptions are wrong

### Step 3 — Walk through each segment

For each segment, produce a structured explanation:

```
### [segment name] — [file:lines]

**What it does:** [one-sentence summary]

**Line-by-line:**
- Line N: [what this line does]
- Line M: [what this line does]
  → Assumption: [the silent bet the AI made here]
  → Risk: [what breaks if the assumption is wrong]

**Assumptions made:**
1. [assumption] — [risk if wrong]
2. [assumption] — [risk if wrong]

**Verdict:** ✅ Safe | ⚠️ Needs review | ❌ Fix before commit
```

### Step 4 — Surface cross-cutting concerns

After the per-segment walkthrough, flag any cross-cutting issues:
- **Security**: SQL injection, XSS, command injection, hardcoded secrets, missing auth checks, unsafe deserialization
- **Performance**: N+1 queries, unbounded loops, large allocations in hot paths, missing caching
- **Correctness**: Off-by-one, race conditions, incorrect error propagation, wrong data types, implicit type coercion
- **Maintainability**: Magic numbers, duplicated logic, unclear naming, overly complex expressions, missing error context
- **Testing**: What test cases are missing based on the assumptions above

### Step 5 — Deliver the verdict

Give a clear recommendation:
- **✅ Safe to commit** — no issues found, or only minor style nits
- **⚠️ Needs review before commit** — one or more assumptions need human verification (e.g., "this assumes the API returns 200, but the actual API returns 201")
- **❌ Fix before commit** — a correctness, security, or performance bug that will cause real problems

If the verdict is ⚠️ or ❌, list exactly what to fix, in priority order, with the specific lines to change.

## Handling incomplete code

If the code references functions, types, or APIs that aren't defined in the provided block, note them as "external dependencies" and flag whether the AI assumed a specific behavior for them. Do not fabricate what those external dependencies do — just note that they're assumed to exist and behave a certain way.

## Handling diffs

When given a diff (`git diff` output), focus on the added and modified lines. For each changed hunk, explain:
- What the old code did
- What the new code does differently
- Whether the change is safe (backward compatible, no side effects)
- Whether the AI correctly understood the existing code's intent

## Security Rules (never violate)

- **No `curl | bash`** — Use only `pip install` / `npm install` for package management.
- **No `eval`** — Never use `eval` or equivalent dynamic code execution.
- **No file operations outside project** — Never read, write, or modify files outside the project directory.
- **No secrets in output** — Never print tokens, API keys, or credentials in reports or logs.
- **No fabricated analysis** — Every claim about the code must be grounded in the actual code. If you're unsure what a line does, say so. Do not guess.
- **No destructive operations** — This skill is read-only. Never modify the code being reviewed.
- **No assumptions about intent** — If the code is ambiguous, flag the ambiguity. Do not assume what the developer "probably meant."
