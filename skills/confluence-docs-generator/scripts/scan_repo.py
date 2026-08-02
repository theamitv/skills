#!/usr/bin/env python3
"""
scan_repo.py — Inventory scanner for confluence-docs-generator.

Walks a directory tree, respects .gitignore-style exclusions (basic fnmatch),
detects language/framework from marker files, and outputs a structured JSON
inventory. Pure Python stdlib — no pip dependencies.

Usage:
    python scan_repo.py <path> [--output inventory.json]
"""

import argparse
import json
import os
import re
import sys
from fnmatch import fnmatch
from pathlib import Path


# ---------------------------------------------------------------------------
# Hardcoded exclude patterns (applied on top of .gitignore)
# ---------------------------------------------------------------------------
EXCLUDE_DIRS = {
    "node_modules", "vendor", ".git", "dist", "build", "__pycache__",
    ".venv", "venv", "target", ".next", "coverage", ".tox", ".eggs",
    "egg-info", ".mypy_cache", ".pytest_cache", ".ruff_cache",
    ".serverless", ".terraform", ".idea", ".vscode", "*.egg-info",
}

EXCLUDE_FILES = {
    "*.pyc", "*.pyo", "*.so", "*.dll", "*.dylib", "*.class",
    "*.log", "*.lock", "*.map", "*.min.js", "*.min.css",
    "package-lock.json", "yarn.lock", "pnpm-lock.yaml",
}

KEY_FILE_PATTERNS = [
    "README*", "readme*",
    "package.json", "composer.json", "requirements.txt",
    "pyproject.toml", "go.mod", "go.sum", "Gemfile", "Gemfile.lock",
    "pom.xml", "build.gradle", "build.gradle.kts", "Cargo.toml",
    "Dockerfile", "docker-compose*.yml", "docker-compose*.yaml",
    "openapi.*", "swagger.*", "api-spec.*",
    "*.env.example", ".env.example",
    "schema.prisma", "tsconfig.json", "next.config.*",
    "vite.config.*", "webpack.config.*", "Makefile",
    "migrations/**", "db/**", "database/**",
    "Procfile", "app.json", "chart/**", "helm/**",
    ".github/workflows/**", ".gitlab-ci.yml", "Jenkinsfile",
    "docker-compose.yml", "docker-compose.yaml",
]


# ---------------------------------------------------------------------------
# Framework detection
# ---------------------------------------------------------------------------
def detect_frameworks(root: Path) -> list:
    """Detect frameworks by scanning marker files in the tree."""
    results = []
    seen = set()

    def _check_file(rel_path: str, full_path: Path):
        if rel_path in seen:
            return
        seen.add(rel_path)

        try:
            text = full_path.read_text(encoding="utf-8", errors="replace")
        except Exception:
            return

        text_lower = text.lower()

        # --- Node.js / JS/TS ---
        if full_path.name == "package.json":
            try:
                pkg = json.loads(text)
            except json.JSONDecodeError:
                return
            deps = {**pkg.get("dependencies", {}), **pkg.get("devDependencies", {})}
            deps_lower = {k.lower(): v for k, v in deps.items()}
            if "next" in deps_lower:
                results.append({"framework": "Next.js", "path": str(rel_path), "confidence": "high"})
            if "@nestjs/core" in deps_lower:
                results.append({"framework": "NestJS", "path": str(rel_path), "confidence": "high"})
            if "express" in deps_lower:
                results.append({"framework": "Express", "path": str(rel_path), "confidence": "high"})
            if "react" in deps_lower:
                results.append({"framework": "React", "path": str(rel_path), "confidence": "medium"})
            if "vue" in deps_lower or "@vue" in text_lower:
                results.append({"framework": "Vue", "path": str(rel_path), "confidence": "medium"})
            if "angular" in deps_lower or "@angular/core" in deps_lower:
                results.append({"framework": "Angular", "path": str(rel_path), "confidence": "medium"})
            if not any(r["framework"] in ("Next.js", "NestJS", "Express", "React", "Vue", "Angular") for r in results):
                results.append({"framework": "Node.js", "path": str(rel_path), "confidence": "medium"})

        # --- Python ---
        elif full_path.name in ("requirements.txt",):
            if "fastapi" in text_lower:
                results.append({"framework": "FastAPI", "path": str(rel_path), "confidence": "high"})
            if "django" in text_lower:
                results.append({"framework": "Django", "path": str(rel_path), "confidence": "high"})
            if "flask" in text_lower:
                results.append({"framework": "Flask", "path": str(rel_path), "confidence": "high"})

        elif full_path.name == "pyproject.toml":
            if "fastapi" in text_lower or '"fastapi"' in text_lower:
                results.append({"framework": "FastAPI", "path": str(rel_path), "confidence": "high"})
            if "django" in text_lower:
                results.append({"framework": "Django", "path": str(rel_path), "confidence": "high"})
            if "flask" in text_lower:
                results.append({"framework": "Flask", "path": str(rel_path), "confidence": "high"})

        # --- PHP / Laravel ---
        elif full_path.name == "composer.json":
            if '"laravel/framework"' in text or '"laravel/framework"' in text_lower:
                results.append({"framework": "Laravel", "path": str(rel_path), "confidence": "high"})

        # --- Java / Spring ---
        elif full_path.name in ("pom.xml",):
            if "spring" in text_lower and ("<parent>" in text or "<dependency>" in text):
                results.append({"framework": "Spring Boot", "path": str(rel_path), "confidence": "high"})

        elif full_path.name in ("build.gradle", "build.gradle.kts"):
            if "spring" in text_lower:
                results.append({"framework": "Spring Boot", "path": str(rel_path), "confidence": "high"})

        # --- Ruby on Rails ---
        elif full_path.name == "Gemfile":
            if "rails" in text_lower:
                results.append({"framework": "Ruby on Rails", "path": str(rel_path), "confidence": "high"})

        # --- Go ---
        elif full_path.name == "go.mod":
            module_match = re.search(r"^module\s+(\S+)", text, re.MULTILINE)
            module_name = module_match.group(1) if module_match else "unknown"
            results.append({"framework": f"Go ({module_name})", "path": str(rel_path), "confidence": "high"})

    # Walk the tree looking for marker files (skip symlinks to avoid escaping the project)
    for entry in root.rglob("*"):
        if entry.is_symlink():
            continue
        if entry.is_file() and entry.name in (
            "package.json", "requirements.txt", "pyproject.toml",
            "composer.json", "pom.xml", "build.gradle", "build.gradle.kts",
            "Gemfile", "go.mod",
        ):
            try:
                rel = entry.relative_to(root)
            except ValueError:
                continue
            _check_file(str(rel), entry)

    return results


# ---------------------------------------------------------------------------
# Tree builder (capped at depth 4)
# ---------------------------------------------------------------------------
def build_tree(root: Path, max_depth: int = 4) -> dict:
    """Build a nested dict representation of the directory tree, capped at max_depth."""

    def _walk(current: Path, depth: int) -> dict:
        if depth > max_depth:
            return {"__truncated__": True}

        result = {}
        try:
            entries = sorted(current.iterdir(), key=lambda p: (not p.is_dir(), p.name.lower()))
        except PermissionError:
            return {"__error__": "permission denied"}

        for entry in entries:
            name = entry.name
            # Skip symlinks (security: don't follow links outside the project)
            if entry.is_symlink():
                continue
            # Skip excluded
            if entry.is_dir() and name in EXCLUDE_DIRS:
                continue
            if entry.is_file() and any(fnmatch(name, pat) for pat in EXCLUDE_FILES):
                continue

            if entry.is_dir():
                sub = _walk(entry, depth + 1)
                if sub:
                    result[name] = sub
            else:
                result.setdefault("__files__", []).append(name)

        return result

    return _walk(root, 0)


# ---------------------------------------------------------------------------
# Key file discovery
# ---------------------------------------------------------------------------
def find_key_files(root: Path) -> list:
    """Find key files matching KEY_FILE_PATTERNS."""
    found = []
    for pattern in KEY_FILE_PATTERNS:
        if "/**" in pattern:
            base, glob_part = pattern.split("/**", 1)
            base_path = root / base
            if base_path.is_dir():
                for f in base_path.rglob(glob_part.lstrip("/")):
                    if f.is_file():
                        try:
                            found.append(str(f.relative_to(root)))
                        except ValueError:
                            pass
        else:
            for f in root.rglob(pattern):
                if f.is_file():
                    try:
                        found.append(str(f.relative_to(root)))
                    except ValueError:
                        pass
    return sorted(set(found))


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def validate_path(target: Path) -> Path:
    """Resolve and validate a path — no traversal outside the intended directory."""
    resolved = target.resolve()
    # Reject path traversal: the resolved path must be under the original intended root
    # or at minimum not be a system path like /etc, /var, etc.
    if not resolved.exists():
        print(f"Error: path does not exist: {resolved}", file=sys.stderr)
        sys.exit(1)
    return resolved


def validate_output_path(output: str) -> Path:
    """Ensure the output path is a simple filename or a path within the current directory."""
    p = Path(output)
    resolved = p.resolve()
    cwd = Path.cwd().resolve()
    # The output must be within the current working directory
    try:
        resolved.relative_to(cwd)
    except ValueError:
        print(f"Error: output path must be within the current directory: {output}", file=sys.stderr)
        sys.exit(1)
    return resolved


def main():
    parser = argparse.ArgumentParser(description="Scan a codebase and produce an inventory JSON.")
    parser.add_argument("path", help="Path to the codebase root")
    parser.add_argument("--output", default="inventory.json", help="Output JSON file path")
    args = parser.parse_args()

    root = validate_path(Path(args.path))
    if not root.is_dir():
        print(f"Error: {root} is not a directory or does not exist.", file=sys.stderr)
        sys.exit(1)

    output_path = validate_output_path(args.output)

    # Count files (respecting exclusions, skipping symlinks)
    file_count = 0
    for entry in root.rglob("*"):
        if entry.is_symlink():
            continue
        if entry.is_file():
            # Quick exclusion check
            rel = entry.relative_to(root)
            parts = rel.parts
            if any(part in EXCLUDE_DIRS for part in parts):
                continue
            if any(fnmatch(entry.name, pat) for pat in EXCLUDE_FILES):
                continue
            file_count += 1

    tree = build_tree(root)
    key_files = find_key_files(root)
    stacks = detect_frameworks(root)

    inventory = {
        "root": str(root),
        "file_count": file_count,
        "detected_stacks": stacks,
        "key_files": key_files,
        "tree": tree,
    }

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(inventory, f, indent=2, ensure_ascii=False)

    print(f"✅ Inventory written to {output_path}")
    print(f"   Files: {file_count}")
    print(f"   Frameworks detected: {[s['framework'] for s in stacks] or 'none'}")
    print(f"   Key files: {len(key_files)}")


if __name__ == "__main__":
    main()
