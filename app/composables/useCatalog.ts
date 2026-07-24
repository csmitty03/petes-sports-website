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
  if (price == null || price === '' || Number.isNaN(Number(price))) {
    return 'Call for price'
  }
  return new Intl.NumberFormat('en-CA', {
    style: 'currency',
    currency: 'CAD',
  }).format(Number(price))
}

/**
 * Catalog lives at {baseURL}data/catalog.json on GitHub Pages.
 * Do NOT pre-bake baseURL into the path — $fetch already applies app.baseURL.
 */
function catalogRequestPath() {
  // Leading slash = site-absolute; Nuxt prefixes app.baseURL (/petes-sports-website/)
  return '/data/catalog.json'
}

/**
 * Load catalog on the client only (file is large; avoid SSR payload bloat).
 */
export async function useCatalog() {
  const { data, error, pending, refresh, status } = await useFetch<Catalog>(catalogRequestPath(), {
    key: 'petes-catalog-v4',
    default: () => emptyCatalog,
    server: false,
    lazy: false,
    timeout: 180000,
    // Ensure we hit the static file, not an API route
    baseURL: undefined,
  })

  // Fallback: if useFetch mishandles baseURL, try an explicit absolute URL once
  if (import.meta.client) {
    watch(
      error,
      async (err) => {
        if (!err) return
        if ((data.value?.productCount || 0) > 0) return
        try {
          const config = useRuntimeConfig()
          const base = (config.app.baseURL || '/').replace(/\/?$/, '/')
          const url = `${window.location.origin}${base}data/catalog.json`
          console.warn('[catalog] primary fetch failed, retrying', url, err)
          const raw = await $fetch<Catalog>(url, { timeout: 180000 })
          if (raw?.products?.length) {
            data.value = raw
          }
        } catch (e) {
          console.warn('[catalog] retry failed', e)
        }
      },
      { immediate: true },
    )
  }

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
