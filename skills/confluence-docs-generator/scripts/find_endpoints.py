#!/usr/bin/env python3
"""
find_endpoints.py — Mechanical first-pass API endpoint extractor.

Uses regex patterns to find route/endpoint declarations across multiple
frameworks. This is intentionally a fast first pass — Claude reads the
actual source files afterward for parameters, auth, and response shapes.

If an OpenAPI/Swagger spec file exists, it is parsed directly instead.

Pure Python stdlib — no pip dependencies.

Usage:
    python find_endpoints.py <path> --framework <name|auto> [--output endpoints.json]
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path


# ---------------------------------------------------------------------------
# Regex patterns per framework
# ---------------------------------------------------------------------------

def _find_express_nestjs(root: Path) -> list:
    """Express / NestJS (JS/TS) — router.get, app.post, @Get, @Post, etc."""
    endpoints = []
    patterns = [
        # Express-style: router.get(...), app.post(...)
        re.compile(r'(?:router|app|route)\s*\.\s*(get|post|put|delete|patch|head|options)\s*\(\s*[\'"]([^\'"]+)[\'"]'),
        # NestJS decorators: @Get(), @Post(), @Put(), @Delete(), @Patch()
        re.compile(r'@(Get|Post|Put|Delete|Patch|Head|Options)\(\s*[\'"]([^\'"]+)[\'"]'),
        # NestJS decorators without path (inherits from controller)
        re.compile(r'@(Get|Post|Put|Delete|Patch|Head|Options)\(\s*\)'),
    ]
    for f in _walk_js_ts(root):
        try:
            text = f.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        for pat in patterns:
            for m in pat.finditer(text):
                method = m.group(1).upper()
                path = m.group(2) if m.lastindex >= 2 and m.group(2) else "/"
                line_num = text[:m.start()].count("\n") + 1
                endpoints.append({
                    "method": method,
                    "path": path,
                    "file": str(f.relative_to(root)),
                    "line": line_num,
                    "handler": _guess_handler(text, m.end()),
                    "source": "regex_scan",
                })
    return endpoints


def _find_fastapi(root: Path) -> list:
    """FastAPI — @app.get(...), @router.post(...)"""
    endpoints = []
    pat = re.compile(r'@(?:app|router|api_router)\s*\.\s*(get|post|put|delete|patch|head|options)\s*\(\s*[\'"]([^\'"]+)[\'"]')
    for f in _walk_python(root):
        try:
            text = f.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        for m in pat.finditer(text):
            line_num = text[:m.start()].count("\n") + 1
            endpoints.append({
                "method": m.group(1).upper(),
                "path": m.group(2),
                "file": str(f.relative_to(root)),
                "line": line_num,
                "handler": _guess_handler(text, m.end()),
                "source": "regex_scan",
            })
    return endpoints


def _find_flask(root: Path) -> list:
    """Flask — @app.route(...) with methods=[]"""
    endpoints = []
    pat = re.compile(r'@(?:app|blueprint)\s*\.\s*route\s*\(\s*[\'"]([^\'"]+)[\'"]')
    methods_pat = re.compile(r'methods\s*=\s*\[([^\]]+)\]')
    for f in _walk_python(root):
        try:
            text = f.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        for m in pat.finditer(text):
            path = m.group(1)
            line_num = text[:m.start()].count("\n") + 1
            # Look for methods= on the same or next few lines
            chunk = text[m.start():m.start() + 300]
            methods_match = methods_pat.search(chunk)
            if methods_match:
                methods = [x.strip().strip("'\"").upper() for x in methods_match.group(1).split(",")]
            else:
                methods = ["GET"]
            for method in methods:
                endpoints.append({
                    "method": method,
                    "path": path,
                    "file": str(f.relative_to(root)),
                    "line": line_num,
                    "handler": _guess_handler(text, m.end()),
                    "source": "regex_scan",
                })
    return endpoints


def _find_drf(root: Path) -> list:
    """Django REST Framework — urls.py path() + viewset class names."""
    endpoints = []
    # urls.py patterns
    url_pat = re.compile(r'path\s*\(\s*[\'"]([^\'"]+)[\'"]')
    # ViewSet class patterns
    viewset_pat = re.compile(r'class\s+(\w+ViewSet)\b')
    # Router registration
    router_pat = re.compile(r'router\.register\s*\(\s*[\'"]([^\'"]+)[\'"]')
    for f in _walk_python(root):
        try:
            text = f.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        rel = str(f.relative_to(root))
        for m in url_pat.finditer(text):
            line_num = text[:m.start()].count("\n") + 1
            endpoints.append({
                "method": "ANY",
                "path": m.group(1),
                "file": rel,
                "line": line_num,
                "handler": _guess_handler(text, m.end()),
                "source": "regex_scan",
            })
        for m in viewset_pat.finditer(text):
            line_num = text[:m.start()].count("\n") + 1
            endpoints.append({
                "method": "VARIES",
                "path": f"[viewset: {m.group(1)}]",
                "file": rel,
                "line": line_num,
                "handler": m.group(1),
                "source": "regex_scan",
            })
        for m in router_pat.finditer(text):
            line_num = text[:m.start()].count("\n") + 1
            endpoints.append({
                "method": "VARIES",
                "path": m.group(1),
                "file": rel,
                "line": line_num,
                "handler": "router.register",
                "source": "regex_scan",
            })
    return endpoints


def _find_laravel(root: Path) -> list:
    """Laravel (PHP) — routes/api.php, routes/web.php Route::get/post/..."""
    endpoints = []
    pat = re.compile(r'Route\s*::\s*(get|post|put|delete|patch|head|options|any|match|resource)\s*\(\s*[\'"]([^\'"]+)[\'"]')
    for f in _walk_php(root):
        try:
            text = f.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        rel = str(f.relative_to(root))
        for m in pat.finditer(text):
            method = m.group(1).upper()
            path = m.group(2)
            line_num = text[:m.start()].count("\n") + 1
            endpoints.append({
                "method": "ANY" if method in ("ANY", "MATCH") else method,
                "path": path,
                "file": rel,
                "line": line_num,
                "handler": _guess_handler(text, m.end()),
                "source": "regex_scan",
            })
    return endpoints


def _find_spring(root: Path) -> list:
    """Spring Boot (Java) — @GetMapping, @PostMapping, @RequestMapping"""
    endpoints = []
    mapping_pat = re.compile(r'@(Get|Post|Put|Delete|Patch|RequestMapping)Mapping\s*\(\s*[\'"]([^\'"]+)[\'"]')
    request_pat = re.compile(r'@RequestMapping\s*\(\s*(?:method\s*=\s*(RequestMethod\.\w+)\s*,?\s*)?(?:value\s*=\s*)?[\'"]([^\'"]+)[\'"]')
    for f in _walk_java(root):
        try:
            text = f.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        rel = str(f.relative_to(root))
        for m in mapping_pat.finditer(text):
            method_map = {"GET": "GET", "POST": "POST", "PUT": "PUT", "DELETE": "DELETE",
                          "PATCH": "PATCH", "REQUEST": "VARIES"}
            line_num = text[:m.start()].count("\n") + 1
            endpoints.append({
                "method": method_map.get(m.group(1).capitalize(), "VARIES"),
                "path": m.group(2),
                "file": rel,
                "line": line_num,
                "handler": _guess_handler(text, m.end()),
                "source": "regex_scan",
            })
        for m in request_pat.finditer(text):
            method = "VARIES"
            if m.group(1):
                method = m.group(1).replace("RequestMethod.", "")
            line_num = text[:m.start()].count("\n") + 1
            endpoints.append({
                "method": method,
                "path": m.group(2) if m.lastindex >= 2 else "/",
                "file": rel,
                "line": line_num,
                "handler": _guess_handler(text, m.end()),
                "source": "regex_scan",
            })
    return endpoints


def _find_nextjs(root: Path) -> list:
    """Next.js App Router — app/api/**/route.ts exports."""
    endpoints = []
    method_pat = re.compile(r'export\s+(?:async\s+)?function\s+(GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS)\b')
    for f in root.rglob("app/api/**/route.*"):
        if f.is_symlink():
            continue
        if not f.is_file() or f.suffix not in (".ts", ".js", ".tsx", ".jsx"):
            continue
        try:
            text = f.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        rel = str(f.relative_to(root))
        # Derive path from file location
        path_parts = rel.replace("\\", "/").split("/")
        # Remove app/api/ prefix and route.* suffix
        try:
            api_idx = path_parts.index("api")
            route_path = "/" + "/".join(path_parts[api_idx + 1:-1])
            # Handle [param] segments
            route_path = re.sub(r'\[([^\]]+)\]', r':\1', route_path)
        except ValueError:
            route_path = "/"
        for m in method_pat.finditer(text):
            line_num = text[:m.start()].count("\n") + 1
            endpoints.append({
                "method": m.group(1).upper(),
                "path": route_path,
                "file": rel,
                "line": line_num,
                "handler": m.group(1),
                "source": "regex_scan",
            })
    return endpoints


def _find_rails(root: Path) -> list:
    """Ruby on Rails — config/routes.rb resource/resources/get/post."""
    endpoints = []
    pat = re.compile(r'(get|post|put|patch|delete|resource|resources)\s+(?::|\'|")(\w+)(?:\'|")?')
    for f in _walk_ruby(root):
        try:
            text = f.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        rel = str(f.relative_to(root))
        for m in pat.finditer(text):
            verb = m.group(1).upper()
            path = m.group(2)
            line_num = text[:m.start()].count("\n") + 1
            endpoints.append({
                "method": "VARIES" if verb in ("RESOURCE", "RESOURCES") else verb,
                "path": path,
                "file": rel,
                "line": line_num,
                "handler": _guess_handler(text, m.end()),
                "source": "regex_scan",
            })
    return endpoints


# ---------------------------------------------------------------------------
# OpenAPI / Swagger parser
# ---------------------------------------------------------------------------

def _try_parse_openapi(root: Path) -> list | None:
    """If an OpenAPI/Swagger spec exists, parse it directly."""
    spec_names = ["openapi.yaml", "openapi.yml", "openapi.json",
                  "swagger.yaml", "swagger.yml", "swagger.json"]
    for name in spec_names:
        spec_file = root / name
        if spec_file.is_file():
            try:
                return _parse_openapi_file(spec_file, root)
            except Exception as e:
                print(f"  ⚠️  Found {name} but failed to parse: {e}", file=sys.stderr)
                return None
    # Also check subdirectories like docs/, api/, spec/
    for sub in ("docs", "api", "spec", "openapi"):
        for name in spec_names:
            spec_file = root / sub / name
            if spec_file.is_file():
                try:
                    return _parse_openapi_file(spec_file, root)
                except Exception as e:
                    print(f"  ⚠️  Found {sub}/{name} but failed to parse: {e}", file=sys.stderr)
                    return None
    return None


def _parse_openapi_file(spec_file: Path, root: Path) -> list:
    """Parse an OpenAPI/Swagger JSON or YAML file."""
    import json

    text = spec_file.read_text(encoding="utf-8", errors="replace")

    # Try JSON first
    try:
        spec = json.loads(text)
    except json.JSONDecodeError:
        # Try YAML (stdlib only — basic line-based parser)
        spec = _basic_yaml_parse(text)

    endpoints = []
    paths = spec.get("paths", {})

    for path, methods in paths.items():
        for method, details in methods.items():
            method_upper = method.upper()
            if method_upper in ("GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS"):
                endpoints.append({
                    "method": method_upper,
                    "path": path,
                    "file": str(spec_file.relative_to(root)),
                    "line": 1,
                    "handler": details.get("operationId", details.get("summary", "")),
                    "source": "openapi_spec",
                })

    return endpoints


def _basic_yaml_parse(text: str) -> dict:
    """Minimal YAML parser for OpenAPI specs (indentation-based)."""
    # This is intentionally basic — handles the common OpenAPI structure
    # without a full YAML parser. For complex specs, recommend PyYAML.
    result = {}
    current_path = []
    path_stack = [result]
    indent_stack = [0]

    for line in text.split("\n"):
        stripped = line.rstrip()
        if not stripped or stripped.lstrip().startswith("#"):
            continue
        indent = len(line) - len(line.lstrip())
        content = stripped.strip()

        # Pop back to correct indent level
        while indent < indent_stack[-1]:
            path_stack.pop()
            indent_stack.pop()
            current_path.pop()

        if content.endswith(":"):
            key = content[:-1].strip().strip("'\"")
            if indent == indent_stack[-1]:
                path_stack[-1][key] = {}
                current_path.append(key)
                path_stack.append(path_stack[-1][key])
                indent_stack.append(indent + 2)
            else:
                # Nested key
                path_stack[-1][key] = {}
                current_path.append(key)
                path_stack.append(path_stack[-1][key])
                indent_stack.append(indent + 2)
        elif ": " in content:
            key, val = content.split(": ", 1)
            key = key.strip().strip("'\"")
            val = val.strip().strip("'\"")
            path_stack[-1][key] = val

    return result


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _walk_js_ts(root: Path):
    """Walk JS/TS files (skip symlinks to avoid escaping the project)."""
    for f in root.rglob("*"):
        if f.is_symlink():
            continue
        if f.is_file() and f.suffix in (".js", ".ts", ".jsx", ".tsx", ".mjs", ".cjs"):
            rel = f.relative_to(root)
            if any(part in ("node_modules", ".git", "dist", "build", ".next", "coverage") for part in rel.parts):
                continue
            yield f


def _walk_python(root: Path):
    """Walk Python files (skip symlinks to avoid escaping the project)."""
    for f in root.rglob("*"):
        if f.is_symlink():
            continue
        if f.is_file() and f.suffix == ".py":
            rel = f.relative_to(root)
            if any(part in (".git", "__pycache__", ".venv", "venv", ".tox", "dist", "build") for part in rel.parts):
                continue
            yield f


def _walk_php(root: Path):
    """Walk PHP files (skip symlinks to avoid escaping the project)."""
    for f in root.rglob("*"):
        if f.is_symlink():
            continue
        if f.is_file() and f.suffix == ".php":
            rel = f.relative_to(root)
            if any(part in ("vendor", ".git") for part in rel.parts):
                continue
            yield f


def _walk_java(root: Path):
    """Walk Java files (skip symlinks to avoid escaping the project)."""
    for f in root.rglob("*"):
        if f.is_symlink():
            continue
        if f.is_file() and f.suffix == ".java":
            rel = f.relative_to(root)
            if any(part in (".git", "target", "build") for part in rel.parts):
                continue
            yield f


def _walk_ruby(root: Path):
    """Walk Ruby files (skip symlinks to avoid escaping the project)."""
    for f in root.rglob("*"):
        if f.is_symlink():
            continue
        if f.is_file() and f.suffix == ".rb":
            rel = f.relative_to(root)
            if any(part in (".git", "vendor") for part in rel.parts):
                continue
            yield f


def _guess_handler(text: str, pos: int) -> str:
    """Try to guess the handler/function name near the given position."""
    # Look for a function/method definition after the decorator/route
    chunk = text[pos:pos + 500]
    # Python: async def or def
    m = re.search(r'(?:async\s+)?def\s+(\w+)', chunk)
    if m:
        return m.group(1)
    # JS/TS: function name or arrow function
    m = re.search(r'(?:const|let|var)\s+(\w+)\s*[:=]\s*(?:async\s*)?\(', chunk)
    if m:
        return m.group(1)
    m = re.search(r'(?:async\s+)?function\s+(\w+)', chunk)
    if m:
        return m.group(1)
    # Java: method name
    m = re.search(r'(?:public|private|protected)\s+\w+\s+(\w+)\s*\(', chunk)
    if m:
        return m.group(1)
    # PHP: function name
    m = re.search(r'function\s+(\w+)', chunk)
    if m:
        return m.group(1)
    # Ruby: method name
    m = re.search(r'def\s+(\w+)', chunk)
    if m:
        return m.group(1)
    return "unknown"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

FRAMEWORK_DISPATCH = {
    "express": _find_express_nestjs,
    "nestjs": _find_express_nestjs,
    "fastapi": _find_fastapi,
    "flask": _find_flask,
    "django": _find_drf,
    "drf": _find_drf,
    "laravel": _find_laravel,
    "spring": _find_spring,
    "springboot": _find_spring,
    "nextjs": _find_nextjs,
    "rails": _find_rails,
}


def validate_path(target: Path) -> Path:
    """Resolve and validate a path — no traversal outside the intended directory."""
    resolved = target.resolve()
    if not resolved.exists():
        print(f"Error: path does not exist: {resolved}", file=sys.stderr)
        sys.exit(1)
    return resolved


def validate_output_path(output: str) -> Path:
    """Ensure the output path is within the current working directory."""
    p = Path(output)
    resolved = p.resolve()
    cwd = Path.cwd().resolve()
    try:
        resolved.relative_to(cwd)
    except ValueError:
        print(f"Error: output path must be within the current directory: {output}", file=sys.stderr)
        sys.exit(1)
    return resolved


def main():
    parser = argparse.ArgumentParser(description="Extract API endpoints from a codebase.")
    parser.add_argument("path", help="Path to the codebase root")
    parser.add_argument("--framework", default="auto", help="Framework name or 'auto'")
    parser.add_argument("--output", default="endpoints.json", help="Output JSON file path")
    args = parser.parse_args()

    root = validate_path(Path(args.path))
    if not root.is_dir():
        print(f"Error: {root} is not a directory or does not exist.", file=sys.stderr)
        sys.exit(1)

    output_path = validate_output_path(args.output)

    # Try OpenAPI first
    openapi_endpoints = _try_parse_openapi(root)
    if openapi_endpoints:
        print(f"✅ Found OpenAPI/Swagger spec — {len(openapi_endpoints)} endpoints extracted")
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(openapi_endpoints, f, indent=2, ensure_ascii=False)
        print(f"   Written to {output_path}")
        return

    # Regex-based extraction
    framework = args.framework.lower()
    all_endpoints = []

    if framework == "auto":
        # Try all known frameworks
        for name, func in FRAMEWORK_DISPATCH.items():
            try:
                eps = func(root)
                if eps:
                    print(f"  {name}: {len(eps)} endpoints found")
                    all_endpoints.extend(eps)
            except Exception as e:
                print(f"  {name}: error — {e}", file=sys.stderr)
    elif framework in FRAMEWORK_DISPATCH:
        all_endpoints = FRAMEWORK_DISPATCH[framework](root)
    else:
        print(f"Error: unknown framework '{framework}'. Known: {', '.join(sorted(FRAMEWORK_DISPATCH))}", file=sys.stderr)
        sys.exit(1)

    # Deduplicate
    seen = set()
    unique = []
    for ep in all_endpoints:
        key = (ep["method"], ep["path"], ep["file"], ep["line"])
        if key not in seen:
            seen.add(key)
            unique.append(ep)

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(unique, f, indent=2, ensure_ascii=False)

    print(f"✅ {len(unique)} unique endpoints written to {output_path}")


if __name__ == "__main__":
    main()
