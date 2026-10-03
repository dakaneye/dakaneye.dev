# Design System: dakaneye.dev

**Style:** Quiet terminal. Dark graphite, one monospace family, amber accent,
section headers written as shell prompts.

## Colors

Dark only. `color-scheme: dark`.

```css
--bg: #141312;           /* Page background */
--surface: #1b1a18;      /* Cards, code blocks, blockquotes */
--line: #2a2826;         /* Rules and borders */
--ink: #e7e3dc;          /* Body text */
--ink-strong: #f6f3ee;   /* Headings */
--muted: #96918a;        /* Labels, secondary text */
--soft: #b9b4ac;         /* Paragraph text under headings */
--accent: #f2b256;       /* Prompts, dates, links, stats */
--accent-hover: #ffd08a; /* Link hover */
```

All text colors meet 4.5:1 contrast on `--bg`.

## Typography

**Font:** JetBrains Mono 400, 500, 700, 800 from Google Fonts.

| Element | Size | Weight |
|---------|------|--------|
| Home headline | clamp(36px, 5.4vw, 64px) | 800 |
| Page title | clamp(32px, 4.4vw, 48px) | 800 |
| Section title | 22px | 700 |
| Body | 16px, line height 1.75 | 400 |
| Prompt, list text | 15px | 400 |
| Labels, tags | 13px | 400–500 |

## Layout

- Max width 1240px. Sidebar `flex: 1 1 220px`; main `flex: 999 1 640px`.
- Below 860px the sidebar stacks above the content and its links wrap in a row.
- Sections are 112px apart. Text blocks cap at 660–720px.

## Patterns

- **Prompt:** `partial "prompt.html" "<command>"` renders `$ <command>` above a section.
- **Tagged list:** an accent tag column beside a text column.
- **Career log:** accent dates beside company, role, and one-line summary.
- **Card:** `--surface` fill, 4px radius, no border.

## Rules

- No emoji. No decorative animation; `prefers-reduced-motion` respected.
- Visible focus rings. Skip link to main content. Nav targets at least 44px tall.
- Every number on the site comes from the current resume.
