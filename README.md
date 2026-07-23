# Pete's Sports Website (Nuxt)

Nuxt 4 version of the Pete's Sports website — London & Strathroy, Ontario.

Live site: https://csmitty03.github.io/petes-sports-website/

Shop (inventory): https://csmitty03.github.io/petes-sports-website/shop

## Lightspeed inventory (X-Series)

The **Shop** page is a browse-only catalog synced from Lightspeed Retail (X-Series).

### How it works

1. `scripts/sync-lightspeed.mjs` calls the X-Series API (default version **`2026-07`**)
2. Active products are written to `public/data/catalog.json` (no API token is published)
3. Nuxt generates static `/shop` pages from that file
4. GitHub Actions re-syncs on every deploy and every **6 hours**

### One-time setup (required for live products)

1. In Lightspeed X-Series (admin), create a **Personal Token** with **`products:read`**
2. Note your **domain prefix** (from `https://YOURPREFIX.retail.lightspeed.app`)
3. In GitHub → **Settings → Secrets and variables → Actions**, add:

| Secret | Value |
|--------|--------|
| `LIGHTSPEED_DOMAIN_PREFIX` | e.g. `petessports` |
| `LIGHTSPEED_TOKEN` | your personal token |

Optional repository variable:

| Variable | Default | Meaning |
|----------|---------|---------|
| `LIGHTSPEED_API_VERSION` | `2026-07` | API path segment |

4. Re-run the **Deploy to GitHub Pages** workflow (or push any commit)

### Local sync

```bash
copy .env.example .env.local
# edit .env.local with your domain prefix + token

npm install
npm run sync:lightspeed
npm run dev
```

Open http://localhost:3000/shop

**Never commit** `.env.local` or real tokens.

### API note

Products endpoint used by the sync:

```http
GET https://{domain_prefix}.retail.lightspeed.app/api/2026-07/products
Authorization: Bearer {token}
Accept: application/json
```

## Development

```bash
npm install
npm run dev
```

## Build

```bash
npm run build
npm run generate   # static site (GitHub Pages)
```

## Project structure

```
app/
  components/     # Page sections + shop/ProductCard
  composables/    # useCatalog, scroll, reveal
  data/           # Site content
  pages/          # Routes including shop/
public/
  data/catalog.json   # Synced inventory (safe to commit)
  assets/             # Logos
scripts/
  sync-lightspeed.mjs # Lightspeed → catalog.json
```
