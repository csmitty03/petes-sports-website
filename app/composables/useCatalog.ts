export interface CatalogProduct {
  id: string
  sku: string
  name: string
  description: string
  price: number | null
  priceExTax: number | null
  brand: string | null
  category: string | null
  tags: string[]
  image: string | null
  imageThumb: string | null
  hasInventory: boolean
  variantName: string | null
  handle: string | null
}

export interface Catalog {
  syncedAt: string | null
  source: string
  domainPrefix?: string
  apiVersion?: string
  productCount: number
  products: CatalogProduct[]
  categories: string[]
  brands: string[]
}

const emptyCatalog: Catalog = {
  syncedAt: null,
  source: 'lightspeed-x-series',
  productCount: 0,
  products: [],
  categories: [],
  brands: [],
}

export function formatCad(price: number | string | null | undefined) {
  if (price == null || price === '') return 'Call for price'
  const n = typeof price === 'number' ? price : Number(price)
  if (Number.isNaN(n)) return 'Call for price'
  return new Intl.NumberFormat('en-CA', {
    style: 'currency',
    currency: 'CAD',
  }).format(n)
}

function buildCatalogUrls(): string[] {
  const config = useRuntimeConfig()
  const base = (config.app.baseURL || '/').replace(/\/?$/, '/')
  const urls: string[] = []

  if (import.meta.client && typeof window !== 'undefined') {
    // Most reliable on GitHub Pages
    urls.push(`${window.location.origin}${base}data/catalog.json`)
  }

  // Relative to current path (shop/ -> ../data won't work; use root-relative with base)
  urls.push(`${base}data/catalog.json`)
  // Nuxt-style path (in case $fetch adds base again — last resort)
  urls.push('/data/catalog.json')

  return [...new Set(urls)]
}

/**
 * Client-only catalog loader using native fetch (more reliable for large JSON on GH Pages).
 */
export async function useCatalog() {
  const data = useState<Catalog>('petes-catalog-v5', () => emptyCatalog)
  const pending = useState<boolean>('petes-catalog-pending-v5', () => true)
  const error = useState<Error | null>('petes-catalog-error-v5', () => null)
  const status = useState<'idle' | 'pending' | 'success' | 'error'>(
    'petes-catalog-status-v5',
    () => 'idle',
  )

  async function load() {
    if (!import.meta.client) {
      pending.value = false
      status.value = 'idle'
      return
    }

    pending.value = true
    error.value = null
    status.value = 'pending'

    const urls = buildCatalogUrls()
    let lastErr: Error | null = null

    for (const url of urls) {
      try {
        const res = await fetch(url, { cache: 'default' })
        if (!res.ok) {
          lastErr = new Error(`HTTP ${res.status} for ${url}`)
          continue
        }
        const json = (await res.json()) as Catalog
        if (!json || !Array.isArray(json.products)) {
          lastErr = new Error(`Invalid catalog shape from ${url}`)
          continue
        }
        data.value = {
          ...emptyCatalog,
          ...json,
          products: json.products,
          productCount: json.productCount ?? json.products.length,
          categories: json.categories || [],
          brands: json.brands || [],
        }
        pending.value = false
        status.value = 'success'
        error.value = null
        return
      } catch (e: any) {
        lastErr = e instanceof Error ? e : new Error(String(e))
      }
    }

    pending.value = false
    status.value = 'error'
    error.value = lastErr
    console.warn('[catalog] All fetch attempts failed', lastErr)
  }

  if (import.meta.client) {
    // Load once per session state; allow refresh()
    if (status.value === 'idle' || (status.value === 'error' && !data.value.products?.length)) {
      await load()
    } else if (status.value === 'success') {
      pending.value = false
    } else if (data.value.productCount > 0) {
      pending.value = false
      status.value = 'success'
    } else {
      await load()
    }
  } else {
    pending.value = true
    status.value = 'pending'
  }

  return {
    catalog: computed(() => data.value || emptyCatalog),
    products: computed(() => data.value?.products || []),
    categories: computed(() => data.value?.categories || []),
    brands: computed(() => data.value?.brands || []),
    syncedAt: computed(() => data.value?.syncedAt || null),
    productCount: computed(() => data.value?.productCount || data.value?.products?.length || 0),
    pending: computed(() => pending.value),
    error: computed(() => error.value),
    status: computed(() => status.value),
    refresh: load,
  }
}
