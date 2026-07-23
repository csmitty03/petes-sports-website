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
  return `${normalized}data/catalog.json`
}

export async function useCatalog() {
  const { data, error } = await useFetch<Catalog>(catalogUrl(), {
    key: 'petes-catalog',
    default: () => emptyCatalog,
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
  }
}

export async function useProduct(id: string) {
  const { products, catalog } = await useCatalog()
  const product = computed(() => products.value.find((p) => p.id === id) || null)
  return { product, catalog }
}
