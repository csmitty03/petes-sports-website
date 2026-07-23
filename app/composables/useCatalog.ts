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

export function formatCad(price: number | null | undefined) {
  if (price == null || Number.isNaN(price)) return 'Call for price'
  return new Intl.NumberFormat('en-CA', {
    style: 'currency',
    currency: 'CAD',
  }).format(price)
}

function catalogUrl() {
  const config = useRuntimeConfig()
  const base = config.app.baseURL || '/'
  const normalized = base.endsWith('/') ? base : `${base}/`
  // Absolute path from site root (works on GitHub Pages with baseURL)
  return `${normalized}data/catalog.json`
}

/**
 * Load catalog on the client only.
 * A 22k-product JSON is too large to embed in SSR HTML; the previous
 * server fetch failed during generate and left the shop stuck empty.
 */
export async function useCatalog() {
  const { data, error, pending, refresh, status } = await useFetch<Catalog>(catalogUrl(), {
    key: 'petes-catalog-v3',
    default: () => emptyCatalog,
    server: false,
    lazy: false,
    // Large file (~22MB) — give the browser time on slower connections
    timeout: 180000,
  })

  if (error.value) {
    console.warn('[catalog] Failed to load catalog.json', error.value)
  }

  return {
    catalog: computed(() => data.value || emptyCatalog),
    products: computed(() => data.value?.products || []),
    categories: computed(() => data.value?.categories || []),
    brands: computed(() => data.value?.brands || []),
    syncedAt: computed(() => data.value?.syncedAt || null),
    productCount: computed(() => data.value?.productCount || 0),
    pending,
    error,
    status,
    refresh,
  }
}
