# Report Template and File Output

## Rendered structure

Blank line between sections, bold section titles, numbered categories,
plain lines (no bullet markers) under each category, and a closing
unnumbered **Summary**:

```markdown
**<Title> Project Update (<Window Label>)**

Key Milestones:

**1. <Category Name>**

<line 1>
<line 2>

**2. <Category Name>**

<line 1>
<line 2>

**Summary**

- <Category Name 1>: <crisp pointer, no ticket IDs>
- <Category Name 2>: <crisp pointer, no ticket IDs>
```

`<Window Label>` is:
- `<Month>` (e.g. "July") for a month-based window, or
- `<start date> – <end date>` (e.g. "14 Jul – 29 Jul 2026") for an explicit
  date-range window.

## Summary section rules

- One `- ` bulleted pointer per category above, same order, max ~12-15
  words each.
- Must be a genuine compression of that category's own lines — never
  introduce a new fact that isn't already covered above it.
- **Never include ticket IDs, PR/MR numbers, or other reference codes** —
  those belong only in the numbered category details; the Summary is the
  plain-English takeaway a busy stakeholder reads first.

## Saving the file

Always save the rendered report as a standalone `.md` file — this is meant
to be forwarded to management, not just read in chat.

- **Location**: `project-updates/` at the workspace root (create the
  folder if it doesn't exist). Don't nest it inside the skill's own folder.
- **Filename**: `<title-slug>-project-update-<window-slug>.md`, e.g.
  - `acme-project-update-2026-07.md` for a month window
  - `acme-project-update-2026-07-14_2026-07-29.md` for a date-range window
- **File content**: the rendered report above, plus a light document
  wrapper suitable for forwarding as-is:
  - A top-level `# <Title> Project Update — <Window Label, Year>` heading
    (a real markdown heading, not just bold, since this is now a
    standalone document).
  - A one-line generated-on/date-range footnote under the heading, e.g.
    `_Covering <Month> 1–<last day>, <Year>. Generated <today's date>._` for
    a month window, or `_Covering <start date>–<end date>. Generated
    <today's date>._` for a date-range window.
  - The categories/Summary from above, unchanged, below that.
  - If any data source was inaccessible, add a short `_Note: ..._` line at
    the very end — never bury a data-quality caveat inside the milestone
    content itself.
- If a file with that name already exists, ask before overwriting — an
  existing report may be a manually edited/approved version.
- After saving, still show the rendered report in chat, and tell the user
  the file path.

See [../examples/sample-report.md](../examples/sample-report.md) for a full
worked example of the final saved file.
