/**
 * Pull active products from Lightspeed Retail (X-Series) into public/data/catalog.json
 *
 * Env (local: .env.local | CI: GitHub Secrets):
 *   LIGHTSPEED_DOMAIN_PREFIX  e.g. petessports
 *   LIGHTSPEED_TOKEN          Personal token or OAuth access token (products:read)
 *
 * Usage:
 *   node scripts/sync-lightspeed.mjs
 *   npm run sync:lightspeed
 */

import { writeFile, mkdir, readFile } from 'node:fs/promises'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const root = join(__dirname, '..')
const outPath = join(root, 'public', 'data', 'catalog.json')

async function loadEnvFile() {
  for (const name of ['.env.local', '.env']) {
    try {
      const raw = await readFile(join(root, name), 'utf8')
      for (const line of raw.split(/\r?\n/)) {
        const trimmed = line.trim()
        if (!trimmed || trimmed.startsWith('#')) continue
        const eq = trimmed.indexOf('=')
        if (eq === -1) continue
        const key = trimmed.slice(0, eq).trim()
        let val = trimmed.slice(eq + 1).trim()
        if (
          (val.startsWith('"') && val.endsWith('"')) ||
          (val.startsWith("'") && val.endsWith("'"))
        ) {
          val = val.slice(1, -1)
        }
        if (!process.env[key]) process.env[key] = val
      }
    } catch {
      /* file optional */
    }
  }
}

function stripHtml(html) {
  if (!html) return ''
  return String(html)
    .replace(/<[^>]+>/g, ' ')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/\s+/g, ' ')
    .trim()
}

function mapProduct(p) {
  const brand = p.brand?.name || null
  const category =
    p.product_category?.name ||
    p.type?.name ||
    p.categories?.[0]?.name ||
    null
  const tags = (p.categories || []).map((c) => c.name).filter(Boolean)
  const image =
    p.image_url ||
    p.images?.[0]?.url ||
    p.skuImages?.[0]?.url ||
    null
  const imageThumb =
    p.image_thumbnail_url ||
    p.images?.[0]?.url ||
    image

  return {
    id: p.id,
    sku: p.sku || '',
    name: p.name || p.variant_name || 'Product',
    description: stripHtml(p.description),
    price: typeof p.price_including_tax === 'number' ? p.price_including_tax : null,
    priceExTax: typeof p.price_excluding_tax === 'number' ? p.price_excluding_tax : null,
    brand,
    category,
    tags,
    image,
    imageThumb,
    hasInventory: Boolean(p.has_inventory),
    variantName: p.variant_name || null,
    handle: p.handle || null,
  }
}

async function fetchPage(baseUrl, token, after) {
  const url = new URL(`${baseUrl}/products`)
  url.searchParams.set('page_size', '200')
  url.searchParams.set('deleted', 'false')
  url.searchParams.set('include_images', 'true')
  if (after != null) url.searchParams.set('after', String(after))

  const res = await fetch(url, {
    headers: {
      Authorization: `Bearer ${token}`,
      Accept: 'application/json',
      'User-Agent': 'PetesSportsWebsite/1.0 (inventory-sync)',
    },
  })

  if (!res.ok) {
    const body = await res.text().catch(() => '')
    throw new Error(`Lightspeed API ${res.status} ${res.statusText}: ${body.slice(0, 400)}`)
  }

  return res.json()
}

async function main() {
  await loadEnvFile()

  const domain = (process.env.LIGHTSPEED_DOMAIN_PREFIX || '').trim()
  const token = (process.env.LIGHTSPEED_TOKEN || '').trim()
  const skipIfMissing = process.env.LIGHTSPEED_SYNC_OPTIONAL === '1'

  if (!domain || !token) {
    if (skipIfMissing) {
      console.warn(
        '[sync-lightspeed] LIGHTSPEED_DOMAIN_PREFIX or LIGHTSPEED_TOKEN missing — skipping (optional mode).',
      )
      try {
        await readFile(outPath, 'utf8')
        console.warn('[sync-lightspeed] Keeping existing catalog.json')
        return
      } catch {
        const empty = {
          syncedAt: null,
          source: 'lightspeed-x-series',
          productCount: 0,
          products: [],
          categories: [],
          brands: [],
        }
        await mkdir(dirname(outPath), { recursive: true })
        await writeFile(outPath, JSON.stringify(empty, null, 2) + '\n', 'utf8')
        console.warn('[sync-lightspeed] Wrote empty catalog.json')
        return
      }
    }
    console.error(
      'Missing credentials.\n' +
        'Set LIGHTSPEED_DOMAIN_PREFIX and LIGHTSPEED_TOKEN in .env.local or GitHub Secrets.',
    )
    process.exit(1)
  }

  // Dated API path per X-Series docs (e.g. 2026-07); override with LIGHTSPEED_API_VERSION
  const apiVersion = (process.env.LIGHTSPEED_API_VERSION || '2026-07').trim()
  const baseUrl = `https://${domain}.retail.lightspeed.app/api/${apiVersion}`

  console.log(`[sync-lightspeed] Fetching products from ${domain} (api ${apiVersion})...`)

  const all = []
  let after = null
  let pages = 0
  const maxPages = 500

  while (pages < maxPages) {
    const json = await fetchPage(baseUrl, token, after)
    const batch = Array.isArray(json.data) ? json.data : []
    pages += 1

    if (!batch.length) break

    for (const p of batch) {
      if (p.deleted_at) continue
      if (p.active === false || p.is_active === false) continue
      all.push(mapProduct(p))
    }

    const maxVersion = json.version?.max
    if (maxVersion == null) break
    if (after != null && maxVersion <= after) break
    after = maxVersion

    if (batch.length < 200) {
      const probe = await fetchPage(baseUrl, token, after)
      const more = Array.isArray(probe.data) ? probe.data : []
      if (!more.length) break
      for (const p of more) {
        if (p.deleted_at) continue
        if (p.active === false || p.is_active === false) continue
        all.push(mapProduct(p))
      }
      break
    }

    await new Promise((r) => setTimeout(r, 150))
  }

  const byId = new Map()
  for (const p of all) byId.set(p.id, p)
  const products = [...byId.values()].sort((a, b) =>
    a.name.localeCompare(b.name, 'en', { sensitivity: 'base' }),
  )

  const categories = [
    ...new Set(products.map((p) => p.category).filter(Boolean)),
  ].sort((a, b) => a.localeCompare(b))
  const brands = [
    ...new Set(products.map((p) => p.brand).filter(Boolean)),
  ].sort((a, b) => a.localeCompare(b))

  const catalog = {
    syncedAt: new Date().toISOString(),
    source: 'lightspeed-x-series',
    domainPrefix: domain,
    apiVersion,
    productCount: products.length,
    products,
    categories,
    brands,
  }

  await mkdir(dirname(outPath), { recursive: true })
  await writeFile(outPath, JSON.stringify(catalog, null, 2) + '\n', 'utf8')

  console.log(
    `[sync-lightspeed] Wrote ${products.length} products → public/data/catalog.json (${pages} page(s))`,
  )
}

main().catch((err) => {
  console.error('[sync-lightspeed] Failed:', err.message || err)
  process.exit(1)
})
