# AI Code Walkthrough

> Walks you through AI-generated code line by line before you commit — explains what each block does, surfaces silent assumptions the AI made, and flags correctness, security, and performance risks.

45% of developers say debugging AI-generated code takes longer than writing it themselves. The problem isn't that AI writes bad code — it's that developers accept code they haven't fully read, and the silent assumptions the AI made only surface later as bugs. This skill reads AI-generated code and produces a structured walkthrough before you commit.

## What It Does

- **Five-Step Process** — Collect → Segment → Walk through → Surface cross-cutting concerns → Deliver verdict
- **Line-by-Line Explanation** — Every line explained in plain language
- **Assumption Surfacing** — Silent bets the AI made, and what breaks if they're wrong
- **Cross-Cutting Analysis** — Security, performance, correctness, maintainability, test coverage
- **Clear Verdict** — Safe to commit, needs review, or fix before commit
- **Diff-Aware** — Works on `git diff` output, not just full files
- **Language Agnostic** — Works on any language or framework

## Quick Start

```bash
# Install
npx skills add theamitv/skills --skill ai-code-walkthrough

# Use in Claude Code
/ai-code-walkthrough Walk me through this code before I commit it
```

## When It Won't Work

- **No code provided** — Requires code to analyze. Cannot review code that doesn't exist yet.
- **External dependencies without context** — If the code references APIs or functions not defined anywhere in the provided context, the analysis will note them as assumptions but cannot verify them.
- **Binary or generated files** — Works on source code only. Minified, compiled, or obfuscated code cannot be meaningfully walked through.
- **Design-level review** — This skill reviews the code as written. It does not evaluate whether the architecture or design is correct for your use case — that requires broader context.
- **Not a linter** — Does not check formatting, style, or syntax. Use your existing linter/formatter for that.

## Structure

```
ai-code-walkthrough/
├── SKILL.md                          # Skill metadata and instructions
├── README.md                         # This file
├── references/
│   └── assumption-patterns.md             # Common AI assumption patterns to watch for
├── examples/
│   └── usage.md                           # Usage examples
└── scripts/
    └── extract-diff-context.sh            # Extract context around diff hunks for review
```

## Verification Checklist

- [ ] Code segmented into logical blocks
- [ ] Each segment explained line by line
- [ ] Silent assumptions surfaced with risk assessment
- [ ] Cross-cutting concerns checked (security, performance, correctness, maintainability)
- [ ] Verdict delivered (safe / needs review / fix before commit)
- [ ] If ⚠️ or ❌, specific fix instructions provided with line numbers

## License

MIT
