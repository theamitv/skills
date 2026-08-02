# Confluence Markdown Rules

What Confluence Cloud's "paste as Markdown" feature reliably converts and
what it doesn't. Follow these rules so the generated docs paste cleanly
with zero manual reformatting.

## Reliable — use freely

| Construct | Syntax | Notes |
|---|---|---|
| **Headings** | `#`, `##`, `###` | H1-H3 work perfectly. H4-H6 also work but render smaller. |
| **Bold** | `**text**` | |
| **Italic** | `*text*` | |
| **Inline code** | `` `code` `` | |
| **Fenced code blocks** | ` ```language ` ... ` ``` ` | **Must** include a language tag (e.g. ` ```python `, ` ```json `, ` ```bash `). Untagged fences may not render as code blocks. |
| **Ordered lists** | `1. item` | Up to ~3 levels of nesting. |
| **Unordered lists** | `- item` or `* item` | Up to ~3 levels of nesting. Deeper nesting renders inconsistently. |
| **Tables** | Standard pipe syntax | Simple tables only. No merged cells, no nested tables. |
| **Links** | `[text](url)` | External and relative links both work. |
| **Horizontal rules** | `---` | |
| **Blockquotes** | `> text` | Renders as a plain indented quote, not a colored info panel. Do not rely on blockquotes to convey "warning" semantics — use "**Note:**" or "**Warning:**" in the text itself. |
| **Mermaid diagrams** | ` ```mermaid ` ... ` ``` ` | Confluence renders these natively. Use for architecture diagrams. |

## Not reliable — avoid

| Construct | Why it fails |
|---|---|
| **Raw HTML tags** | Confluence paste-markdown does not reliably render arbitrary HTML. Some tags like `<br>` and `<hr>` may work, but `<div>`, `<span>`, `<table>` (HTML tables), and custom elements will not. |
| **Footnotes** | `[^1]` syntax is not supported. Inline the footnote content or use a parenthetical note. |
| **Task list checkboxes** | `- [ ]` and `- [x]` render inconsistently across Confluence versions. |
| **Nested tables** | Tables inside table cells are not supported. |
| **Embedded images via Markdown** | `![alt](url)` will not upload the image. If you must reference an image, link to it: `[screenshot](url)`. |
| **Confluence-specific macros** | `{excerpt}`, `{info}`, `{warning}`, `{code}` etc. cannot be expressed in Markdown at all. Do not try. |
| **YAML frontmatter** | `---` blocks at the top of a file will not render. Never include frontmatter in the output docs. |
| **Definition lists** | `term : definition` syntax is not supported. Use a table instead. |
| **Strikethrough** | `~~text~~` may or may not render depending on Confluence version. Use sparingly. |

## General guidelines

- **Prefer the simplest structure** that conveys the information — plain
  headings, short paragraphs, and tables. Confluence docs get read by people
  scanning quickly, not reading top to bottom.
- **Always tag code fences** with a language. Untagged fences may not render
  as code blocks in Confluence.
- **Keep tables simple** — no merged cells, no block-level content inside
  cells, no nested tables. A table with 3-5 columns and plain text cells
  is ideal.
- **Don't over-nest lists** — 3 levels max. Deeper nesting renders
  inconsistently.
- **Don't use raw HTML** for layout. Confluence paste-markdown will strip
  or mangle it.
- **Test by pasting** into a Confluence draft if you're unsure about a
  specific construct. The rules above cover the common cases.

When in doubt, prefer the simplest structure that conveys the information —
plain headings, short paragraphs, and tables. Confluence docs get read by
people scanning quickly, not reading top to bottom.
