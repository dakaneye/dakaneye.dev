# Design System: dakaneye.dev

**Style:** Swiss Modernism 2.0 + Technical Monochrome
**Generated:** 2026-03-22 via UI UX Pro Max

## Design Tokens

### Colors

```css
/* Light Mode */
--primary: #18181B;      /* Zinc 900 - Primary text */
--secondary: #3F3F46;    /* Zinc 700 - Secondary text */
--muted: #71717A;        /* Zinc 500 - Muted text */
--accent: #2563EB;       /* Blue 600 - Links, CTAs */
--accent-hover: #1D4ED8; /* Blue 700 - Hover state */
--background: #FAFAFA;   /* Zinc 50 - Page background */
--surface: #FFFFFF;      /* White - Card/elevated surfaces */
--border: #E4E4E7;       /* Zinc 200 - Borders */

/* Dark Mode */
--primary-dark: #FAFAFA;
--secondary-dark: #A1A1AA;
--muted-dark: #71717A;
--accent-dark: #3B82F6;
--accent-hover-dark: #60A5FA;
--background-dark: #09090B;
--surface-dark: #18181B;
--border-dark: #27272A;
```

### Typography

**Font Stack:** Space Mono (monospace)
- Mood: Technical, precise, developer-focused
- Import: `https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&display=swap`

| Element | Size | Weight | Line Height | Letter Spacing |
|---------|------|--------|-------------|----------------|
| H1 | 2rem (32px) | 700 | 1.2 | -0.02em |
| H2 | 1.5rem (24px) | 700 | 1.3 | -0.01em |
| H3 | 1.25rem (20px) | 700 | 1.4 | 0 |
| Body | 1rem (16px) | 400 | 1.7 | 0 |
| Small | 0.875rem (14px) | 400 | 1.5 | 0 |
| Code | 0.9rem | 400 | 1.6 | 0 |

### Spacing

Based on 4px grid:
- `--space-1`: 4px
- `--space-2`: 8px
- `--space-3`: 12px
- `--space-4`: 16px
- `--space-6`: 24px
- `--space-8`: 32px
- `--space-12`: 48px
- `--space-16`: 64px

### Effects

| Effect | Value |
|--------|-------|
| Border radius | 4px (subtle) |
| Transition | 150ms ease |
| Focus ring | 2px solid var(--accent), 2px offset |
| Link underline | 1px solid, appears on hover |

### Layout

- Max content width: 720px
- Nav width: 1024px
- Responsive breakpoints: 375px, 768px, 1024px

## Anti-Patterns to Avoid

- No emojis as icons (use SVG if needed)
- No decorative animations (respect prefers-reduced-motion)
- No color as only indicator (accessibility)
- No text below 14px

## Accessibility Checklist

- [x] Contrast ratio 4.5:1 minimum (body text)
- [x] Contrast ratio 3:1 minimum (large text, UI)
- [x] Focus states visible
- [x] prefers-reduced-motion respected
- [x] Semantic HTML structure
