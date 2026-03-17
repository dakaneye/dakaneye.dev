# dakaneye.dev

Personal website for Sam Dacanay. Built with Hugo and the PaperMod theme.

## Local Development

```bash
# Install Hugo (macOS)
brew install hugo

# Run local server
hugo server -D

# Build for production
hugo --minify
```

The site will be available at http://localhost:1313

## Project Structure

```
content/
├── _index.md              # About/landing page
├── experience/
│   └── _index.md          # Career case studies
├── writing/
│   ├── _index.md          # Blog listing
│   └── verifying-supply-chains.md
├── resume.md
└── contact.md

static/
├── resume.pdf             # (placeholder - add actual PDF)
└── favicon.ico            # (placeholder - add actual favicon)

assets/css/extended/
└── custom.css             # Theme customizations
```

## Placeholders to Replace

Before deploying, replace these placeholders:

1. **Resume PDF**: Add `static/resume.pdf` and delete `static/resume.pdf.placeholder`
2. **Favicon**: Add `static/favicon.ico` and delete `static/favicon.ico.placeholder`
3. **LinkedIn URL**: Search for "PLACEHOLDER" in:
   - `hugo.toml`
   - `content/resume.md`
   - `content/contact.md`
4. **Email**: Update email in `content/resume.md` and `content/contact.md`

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

## Theme

Using [PaperMod](https://github.com/adityatelange/hugo-PaperMod) as a git submodule.

To update the theme:
```bash
git submodule update --remote themes/PaperMod
```
