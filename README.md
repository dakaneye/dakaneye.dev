# dakaneye.dev

Personal website for Sam Dacanay. Built with Hugo and hand-written layouts; no theme.

## Local Development

```bash
# Install Hugo extended 0.158.0 (macOS)
brew install hugo

# Run local server
hugo server

# Build for production
hugo --minify
```

The site will be available at http://localhost:1313

## Site Checks

```bash
scripts/check-site.sh
```

The script builds the site with `--panicOnWarning`, so any Hugo warning fails it.
It then checks that each page renders its key content, that `/contact/` redirects,
and that no street address or phone number appears in the output. Set `HUGO` to
use a specific Hugo binary.

## Project Structure

```
content/
├── _index.md              # Home: headline and intro paragraph
├── projects.md
├── resume.md              # Uses the resume layout
└── writing/               # Posts

data/
├── about.yaml             # Home sections: stats, shipped, leadership, AI, principles
├── projects.yaml          # Featured projects and contributions
└── resume.yaml            # Jobs, skills, education; shared by home and resume

layouts/
├── _default/              # baseof, list, single, projects, resume
├── partials/              # head, sidebar, prompt, project cards
├── index.html             # Home
└── 404.html

assets/css/main.css        # All styles; tokens in design-system/MASTER.md
static/resume.pdf          # Downloadable resume
```

## Cloudflare Pages Deployment

1. Go to [Cloudflare Pages](https://pages.cloudflare.com/)
2. Connect your GitHub account
3. Select the `dakaneye/dakaneye.dev` repository
4. Configure build settings:
   - **Framework preset:** Hugo
   - **Build command:** `hugo --minify`
   - **Build output directory:** `public`
   - **Environment variable:** `HUGO_VERSION` = `0.158.0`
5. Deploy

### Custom Domain Setup

1. In Cloudflare Pages, go to your project settings
2. Add custom domain: `dakaneye.dev`
3. If using Cloudflare DNS, it will configure automatically
4. If using external DNS, add the CNAME record Cloudflare provides

## Adding Blog Posts

```bash
hugo new writing/your-post-title.md
```

Edit the generated file in `content/writing/`. Remove `draft: true` when ready to publish.
