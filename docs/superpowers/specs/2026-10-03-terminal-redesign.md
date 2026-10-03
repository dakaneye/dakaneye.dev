# Terminal Redesign Spec

## Goal

Replace the PaperMod theme with a hand-built Hugo layout in the "quiet
terminal" style: a dark graphite page, JetBrains Mono throughout, an amber
accent, a left sidebar, and section headers written as shell prompts.

The site must show four things with evidence, not adjectives: leadership,
technical depth, shipping speed (before and with AI), and that Sam is easy
to work with.

## Pages

| URL | Source | Content |
|---|---|---|
| `/` | `content/_index.md`, `data/about.yaml`, `data/resume.yaml` | `whoami` hero, stat row, `ls shipped/`, `cat leadership.md`, `cat ai.md`, `git log --career`, `cat principles.txt` |
| `/projects/` | `content/projects.md`, `data/projects.yaml` | Featured project grid, Anchore contributions |
| `/writing/` | `content/writing/_index.md` | Post list: date, title, description, tags |
| `/writing/<slug>/` | `content/writing/*.md` | Post page with prose styles |
| `/resume/` | `content/resume.md`, `data/resume.yaml` | HTML resume and a PDF download link |
| `/404.html` | layout only | Not-found page |

`/contact/` is removed. An alias on the home page redirects it to `/`.
Contact links live in the sidebar on every page.

## Visual tokens

| Token | Value | Use |
|---|---|---|
| `--bg` | `#141312` | Page background |
| `--surface` | `#1B1A18` | Cards, code blocks |
| `--line` | `#2A2826` | Rules and borders |
| `--ink` | `#E7E3DC` | Body text |
| `--ink-strong` | `#F6F3EE` | Headings |
| `--muted` | `#96918A` | Labels, secondary text |
| `--soft` | `#B9B4AC` | Paragraph text under headings |
| `--accent` | `#F2B256` | Prompts, dates, links, stats |
| `--accent-hover` | `#FFD08A` | Link hover |

- Font: JetBrains Mono 400/500/700/800 from Google Fonts.
- Body 16px, line height 1.75. Hero h1 `clamp(36px, 5.4vw, 64px)`, weight 800.
- Layout: max width 1240px. Sidebar `flex: 1 1 220px`. Main `flex: 999 1 640px`.
  Below about 900px the sidebar stacks above the main column.
- Dark only. `color-scheme: dark`. No theme toggle.

## Content rules

- Every number on the site comes from the September 2026 resume.
- No home address or phone number anywhere in the HTML.
- No testimonial or feedback section.
- No "10x" or similar self-labels.

## Accessibility

- Skip link to main content. Visible focus rings.
- Every section has a real heading. Prompt-only sections use a visually
  hidden heading.
- Link targets are at least 44px tall in the nav.
- `prefers-reduced-motion` respected.

## Out of scope

- Light theme, search, comments, analytics.
- A new resume PDF layout.
