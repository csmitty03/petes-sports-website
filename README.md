# Pete's Sports Website (Nuxt)

Nuxt 4 version of the Pete's Sports website — London & Strathroy, Ontario.

## Development

```bash
npm install
npm run dev
```

Open http://localhost:3000

## Build

```bash
# Production server build
npm run build

# Static site (GitHub Pages)
npm run generate
```

## Deploy to GitHub Pages

Pushes to `main` automatically deploy via GitHub Actions.

1. Push code: `powershell -ExecutionPolicy Bypass -File .\push-to-github.ps1`
2. In GitHub: **Settings → Pages → Build and deployment → Source: GitHub Actions**

Live site: https://csmitty03.github.io/petes-sports-website/

## Project structure

```
app/
  components/   # Page sections (Hero, Team, Contact, etc.)
  composables/  # Scroll, reveal animations
  data/         # Site content (team, services, locations)
  pages/        # Routes
public/assets/  # Logo images
```