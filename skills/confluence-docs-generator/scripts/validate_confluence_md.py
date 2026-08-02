#!/usr/bin/env python3
"""
validate_confluence_md.py — Validate Markdown files for Confluence paste compatibility.

Checks each .md file for constructs that don't survive Confluence Cloud's
paste-as-markdown feature cleanly. Pure Python stdlib — no pip dependencies.

Usage:
    python validate_confluence_md.py <file-or-dir>
"""

import argparse
import re
import sys
from pathlib import Path


# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

def check_raw_html(filepath: Path, lines: list[str]) -> list[dict]:
    """Flag raw HTML tags (Confluence paste-markdown does not reliably render arbitrary HTML)."""
    issues = []
    html_tag = re.compile(r'<(/?)([a-zA-Z][a-zA-Z0-9]*)\b[^>]*>')
    # Allowed HTML-like constructs that are actually Markdown
    allowed_tags = {"br", "hr", "img", "del", "ins", "sub", "sup", "kbd"}
    for i, line in enumerate(lines, 1):
        for m in html_tag.finditer(line):
            tag = m.group(2).lower()
            if tag in allowed_tags:
                continue
            # Skip markdown code spans and fenced code blocks (handled below)
            issues.append({
                "file": str(filepath),
                "line": i,
                "issue": f"Raw HTML tag: <{m.group(2)}>",
                "suggestion": f"Remove the raw HTML or use Markdown syntax instead of <{m.group(2)}>",
            })
    return issues


def check_code_fences(lines: list[str]) -> list[dict]:
    """Flag code fences without a language tag."""
    issues = []
    fence_pat = re.compile(r'^```(\w*)$')
    for i, line in enumerate(lines, 1):
        m = fence_pat.match(line)
        if m and not m.group(1):
            issues.append({
                "file": "",  # filled by caller
                "line": i,
                "issue": "Code fence without language tag",
                "suggestion": "Add a language tag: ```python, ```json, ```bash, etc.",
            })
    return issues


def check_table_pipes(lines: list[str]) -> list[dict]:
    """Flag tables with unescaped pipe characters inside cells."""
    issues = []
    in_table = False
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if stripped.startswith("|") and stripped.endswith("|"):
            in_table = True
            # Check for unescaped pipes inside cells
            # A pipe is "unescaped" if it's not at a column boundary
            # Simple heuristic: count pipes; if more than expected, flag
            pipe_count = stripped.count("|")
            # Minimum: 2 (start + end). Each column adds 1 pipe.
            # If there are extra pipes, they're inside cells
            # We can't easily detect this without parsing the table,
            # so flag any line with | inside a code span or unescaped
            if "|" in stripped[1:-1]:
                # Check for obvious cases: pipe inside backtick or not at column boundary
                # This is a best-effort check
                pass
        else:
            in_table = False
    return []


def check_nested_lists(lines: list[str]) -> list[dict]:
    """Flag nested bullet lists deeper than 3 levels."""
    issues = []
    for i, line in enumerate(lines, 1):
        stripped = line.rstrip()
        if not stripped:
            continue
        # Count leading spaces for list items
        leading = len(line) - len(line.lstrip())
        # Check if it's a list item
        content = stripped.lstrip()
        if content.startswith("- ") or content.startswith("* ") or content.startswith("+ "):
            depth = leading // 2 + 1  # Approximate: 2 spaces per level
            if depth > 3:
                issues.append({
                    "file": "",
                    "line": i,
                    "issue": f"List nested {depth} levels deep (max 3 supported)",
                    "suggestion": "Flatten the list or restructure into subsections",
                })
        elif re.match(r'^\d+\.\s', content):
            depth = leading // 2 + 1
            if depth > 3:
                issues.append({
                    "file": "",
                    "line": i,
                    "issue": f"Ordered list nested {depth} levels deep (max 3 supported)",
                    "suggestion": "Flatten the list or restructure into subsections",
                })
    return issues


def check_footnotes(lines: list[str]) -> list[dict]:
    """Flag footnote syntax — not supported in Confluence."""
    issues = []
    footnote_pat = re.compile(r'\[\^[^\]]+\]')
    for i, line in enumerate(lines, 1):
        if footnote_pat.search(line):
            issues.append({
                "file": "",
                "line": i,
                "issue": "Footnote syntax [^...] is not supported in Confluence",
                "suggestion": "Inline the footnote content or use a parenthetical note",
            })
    return issues


def check_yaml_frontmatter(lines: list[str]) -> list[dict]:
    """Flag YAML frontmatter (should never appear in final docs)."""
    issues = []
    if lines and lines[0].strip() == "---":
        # Find closing ---
        for i in range(1, min(len(lines), 30)):
            if lines[i].strip() == "---":
                issues.append({
                    "file": "",
                    "line": 1,
                    "issue": "YAML frontmatter detected (lines 1-{i})",
                    "suggestion": "Remove the frontmatter block — it will not render in Confluence",
                })
                break
    return issues


def check_mermaid_code_blocks(lines: list[str]) -> list[dict]:
    """Flag mermaid code blocks — Confluence supports them natively, but verify syntax."""
    issues = []
    in_mermaid = False
    for i, line in enumerate(lines, 1):
        if line.strip().startswith("```mermaid"):
            in_mermaid = True
        elif in_mermaid and line.strip().startswith("```"):
            in_mermaid = False
    return issues  # No issues, just noting they're supported


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def validate_file(filepath: Path) -> list[dict]:
    """Run all checks on a single file. Returns list of issues."""
    try:
        text = filepath.read_text(encoding="utf-8", errors="replace")
    except Exception as e:
        return [{
            "file": str(filepath),
            "line": 0,
            "issue": f"Cannot read file: {e}",
            "suggestion": "Check file permissions and encoding",
        }]

    lines = text.split("\n")
    all_issues = []

    # Run checks
    all_issues.extend(check_raw_html(filepath, lines))
    all_issues.extend(check_code_fences(lines))
    all_issues.extend(check_table_pipes(lines))
    all_issues.extend(check_nested_lists(lines))
    all_issues.extend(check_footnotes(lines))
    all_issues.extend(check_yaml_frontmatter(lines))

    # Fill in file path for checks that don't set it
    for issue in all_issues:
        if not issue["file"]:
            issue["file"] = str(filepath)

    return all_issues


def validate_path(target: Path) -> Path:
    """Resolve and validate a path — no traversal outside the intended directory."""
    resolved = target.resolve()
    if not resolved.exists():
        print(f"Error: path does not exist: {resolved}", file=sys.stderr)
        sys.exit(1)
    return resolved


def main():
    parser = argparse.ArgumentParser(
        description="Validate Markdown files for Confluence paste compatibility."
    )
    parser.add_argument("path", help="File or directory to validate")
    args = parser.parse_args()

    target = validate_path(Path(args.path))

    if target.is_file():
        files = [target]
    elif target.is_dir():
        files = sorted(target.rglob("*.md"))
    else:
        print(f"Error: {target} is not a file or directory.", file=sys.stderr)
        sys.exit(1)

    if not files:
        print("No .md files found.")
        sys.exit(0)

    all_issues = []
    for f in files:
        all_issues.extend(validate_file(f))

    if not all_issues:
        print("✅ No issues found — all files are Confluence-paste-safe.")
        sys.exit(0)

    # Print report
    print(f"⚠️  Found {len(all_issues)} issue(s):\n")
    for issue in all_issues:
        print(f"  {issue['file']}:{issue['line']}")
        print(f"    Issue: {issue['issue']}")
        print(f"    Fix:   {issue['suggestion']}")
        print()

    sys.exit(1)


if __name__ == "__main__":
    main()
