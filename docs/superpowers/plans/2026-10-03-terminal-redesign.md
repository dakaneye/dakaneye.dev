# Terminal Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace PaperMod with hand-built Hugo layouts in the quiet-terminal style.

**Architecture:** One `baseof.html` with a sidebar partial wraps every page. Page
content comes from Markdown front matter and two data files: `data/about.yaml`
for home-page sections and `data/resume.yaml` for jobs, shared by the home
career log and the resume page. One stylesheet goes through Hugo Pipes.

**Tech Stack:** Hugo 0.158.0 extended, Go templates, plain CSS, Bash.

**Spec:** `docs/superpowers/specs/2026-10-03-terminal-redesign.md`

**Visual reference:** the B3 v2 artboard on the design canvas. Its markup
and copy are the source for every template below.

## Global Constraints

- Hugo version `0.158.0` (Cloudflare Pages `HUGO_VERSION`).
- No theme. Remove the `themes/PaperMod` submodule and the `theme` key.
- No JavaScript.
- Colors only from the spec token table.
- No home address, phone number, or testimonial section in output HTML.

## Review Focus

1. A phone-width viewer (375px): sidebar stacks above content, nav wraps, no horizontal scroll. Pinned by the CSS media query in Task 1.
2. Old `/contact/` URL: must redirect, not 404. Pinned by a check in Task 5.
3. RSS readers at `/index.xml`: must still build with the post in it. Pinned by a check in Task 4.
4. A Markdown post with code, tables, and blockquotes: must be readable on the dark background. Pinned by prose CSS in Task 4.
5. A job with no bullets or no summary in `resume.yaml`: templates must skip the empty element, not print an empty list. Pinned by `with` guards in Tasks 2 and 5.

---

### Task 1: Site check script, base layout, and theme removal

**Files:**
- Create: `scripts/check-site.sh`, `layouts/_default/baseof.html`, `layouts/partials/sidebar.html`, `layouts/partials/head.html`, `layouts/partials/prompt.html`, `assets/css/main.css`
- Create: stub `layouts/index.html`, `layouts/_default/list.html`, `layouts/_default/single.html` so the build has a layout for every page kind (Tasks 2 and 4 replace them)
- Modify: `hugo.toml` (drop `theme`, PaperMod `params`, JSON output; add `disableKinds`, `params.role`, social links), `static/site.webmanifest` (name, dark colors)
- Delete: `themes/PaperMod` submodule, `.gitmodules`, `assets/css/extended/custom.css`

**Interfaces:**
- Produces: `partial "prompt.html" "<command>"` renders `<p class="prompt"><span>$</span> <command></p>`.
- Produces: CSS classes `layout`, `sidebar`, `main`, `prompt`, `section`, `section-title`, `sr-only`, `muted`, `soft`.
- Produces: `scripts/check-site.sh` builds with `hugo --panicOnWarning --minify` to a temp dir, so any Hugo warning fails it, and runs `assert_contains <file> <text>` and `assert_absent <file> <text>` checks; exits non-zero on the first failure.

- [ ] Step 1: Write `scripts/check-site.sh` with checks: `index.html` contains `class="sidebar"` and `JetBrains+Mono`; no output file contains `PaperMod`.
- [ ] Step 2: Run it. Expected: FAIL on `class="sidebar"`.
- [ ] Step 3: Remove the submodule (`git submodule deinit -f`, `git rm -f`, clear `.git/modules`). Write the base layout, sidebar, head (favicons, manifest, RSS, Open Graph), prompt partial, and CSS tokens. Stub `index.html`, `list.html`, and `single.html` with `{{ define "main" }}{{ .Content }}{{ end }}`.
- [ ] Step 4: Run the check. Expected: PASS with zero Hugo warnings.
- [ ] Step 5: Commit `feat: replace papermod with terminal base layout`.

### Task 2: Home page

**Files:**
- Create: `data/about.yaml` (`stats`, `shipped`, `leadership`, `ai`, `principles`), `data/resume.yaml` (`summary`, `jobs[]` with `company`, `role`, `short_role`, `dates`, `long_dates`, `summary`, `bullets[]`; `skills[]`; `education`; `awards[]`; `languages`)
- Modify: `layouts/index.html`, `content/_index.md` (front matter `title`, `heading`, `aliases`; body is the intro paragraph)

- [ ] Step 1: Add checks: `index.html` contains `I build software that leaves the building.`, `ls shipped/`, `cat leadership.md`, `cat ai.md`, `git log --career`, `cat principles.txt`, `Kind and direct.`, `NetBox Labs`, `500k+`.
- [ ] Step 2: Run. Expected: FAIL.
- [ ] Step 3: Write the data files and template from the B3 v2 reference. Guard optional fields with `with`.
- [ ] Step 4: Run. Expected: PASS.
- [ ] Step 5: Commit `feat: build terminal home page`.

### Task 3: Projects page

**Files:** Modify `layouts/_default/projects.html`, `layouts/partials/project-card.html`, `layouts/partials/contribution-row.html`.

- [ ] Step 1: Add checks: `projects/index.html` contains `ls projects/`, `claude-sandbox`, `anchore/syft`.
- [ ] Step 2: Run. Expected: FAIL on the prompt.
- [ ] Step 3: Rewrite the templates as a grid of cards and a contribution list.
- [ ] Step 4: Run. Expected: PASS.
- [ ] Step 5: Commit `feat: restyle projects page`.

### Task 4: Writing list, post page, and 404

**Files:** Create `layouts/_default/list.html`, `layouts/_default/single.html`, `layouts/404.html`. Prose styles go in `assets/css/main.css`.

- [ ] Step 1: Add checks: `writing/index.html` contains `ls writing/` and `Quarkus vs. Spring Boot`; `writing/quarkus-vs-spring/index.html` contains `class="prose"`; `index.xml` contains `Quarkus vs. Spring Boot`; `404.html` contains `cd ~`.
- [ ] Step 2: Run. Expected: FAIL.
- [ ] Step 3: Write the templates and prose CSS (links, code, pre, tables, blockquote).
- [ ] Step 4: Run. Expected: PASS.
- [ ] Step 5: Commit `feat: add writing and 404 layouts`.

### Task 5: Resume page and contact removal

**Files:** Create `layouts/_default/resume.html`. Modify `content/resume.md` (`layout: resume`). Delete `content/contact.md`; drop its menu entry.

- [ ] Step 1: Add checks: `resume/index.html` contains `cat resume.md`, `Download PDF`, and `Keycloak`; no output HTML contains `Kunkle` or `405`; `contact/index.html` contains `http-equiv="refresh"`.
- [ ] Step 2: Run. Expected: FAIL.
- [ ] Step 3: Write the template from `data/resume.yaml`. Add `aliases: ["/contact/"]` to `content/_index.md`.
- [ ] Step 4: Run. Expected: PASS.
- [ ] Step 5: Commit `feat: render resume as html`.

### Task 6: Docs

**Files:** Modify `README.md` (no theme, check script, structure), `design-system/MASTER.md` (spec tokens).

- [ ] Step 1: Rewrite both docs to match what shipped.
- [ ] Step 2: Run the check script. Expected: PASS.
- [ ] Step 3: Commit `docs: describe terminal layout and site checks`.
