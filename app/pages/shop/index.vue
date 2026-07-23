<script setup lang="ts">
useSeoMeta({
  title: "Shop | Pete's Sports",
  description: "Browse Pete's Sports inventory — hockey, baseball, and sporting goods from our London & Strathroy stores.",
})

const {
  products,
  categories,
  brands,
  syncedAt,
  productCount,
  pending,
  error,
  status,
  refresh,
} = await useCatalog()

const search = ref('')
const category = ref('')
const brand = ref('')
const page = ref(1)
const pageSize = 48

const filtered = computed(() => {
  const q = search.value.trim().toLowerCase()
  return products.value.filter((p) => {
    if (category.value && p.category !== category.value) return false
    if (brand.value && p.brand !== brand.value) return false
    if (!q) return true
    const hay = [p.name, p.sku, p.brand, p.category, p.description, ...(p.tags || [])]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
    return hay.includes(q)
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filtered.value.length / pageSize)))

const pageItems = computed(() => {
  const start = (page.value - 1) * pageSize
  return filtered.value.slice(start, start + pageSize)
})

watch([search, category, brand], () => {
  page.value = 1
})

const syncedLabel = computed(() => {
  if (!syncedAt.value) return null
  try {
    return new Date(syncedAt.value).toLocaleString('en-CA', {
      dateStyle: 'medium',
      timeStyle: 'short',
    })
  } catch {
    return syncedAt.value
  }
})

function prevPage() {
  if (page.value > 1) page.value -= 1
  if (import.meta.client) window.scrollTo({ top: 0, behavior: 'smooth' })
}

function nextPage() {
  if (page.value < totalPages.value) page.value += 1
  if (import.meta.client) window.scrollTo({ top: 0, behavior: 'smooth' })
}

// Show loading until the client finishes fetching catalog.json (22MB file).
// status stays non-success while idle/pending so we don't flash "coming soon".
const isLoading = computed(() => {
  if (productCount.value > 0) return false
  if (error.value) return false
  return status.value !== 'success'
})
const loadFailed = computed(() => Boolean(error.value) && productCount.value === 0)
</script>

<template>
  <div>
    <SiteAnnouncement />
    <SiteNav />

    <main class="shop-page">
      <div class="container">
        <header class="shop-hero">
          <span class="section-label">Inventory</span>
          <h1>Shop Pete's Sports</h1>
          <p>
            Browse gear from our store inventory. Prices shown for reference —
            contact us to confirm availability and place an order.
          </p>
          <p v-if="syncedLabel" class="shop-synced">
            Catalog updated {{ syncedLabel }}
            <span v-if="productCount"> · {{ productCount.toLocaleString() }} items</span>
          </p>
        </header>

        <div v-if="isLoading" class="shop-empty">
          <h2>Loading inventory…</h2>
          <p>
            Pulling products from our catalog. This can take a few seconds the first time
            (large inventory file).
          </p>
        </div>

        <div v-else-if="loadFailed" class="shop-empty">
          <h2>Couldn’t load inventory</h2>
          <p>Please try again. If it keeps failing, call the store for product help.</p>
          <div class="shop-empty-actions">
            <button type="button" class="btn btn-primary" @click="refresh()">
              Retry
            </button>
            <a href="tel:+15194339555" class="btn btn-outline">(519) 433-9555</a>
          </div>
        </div>

        <template v-else>
          <div class="shop-toolbar">
            <label class="shop-search">
              <span class="sr-only">Search products</span>
              <input
                v-model="search"
                type="search"
                placeholder="Search name, brand, SKU…"
                autocomplete="off"
              >
            </label>
            <label class="shop-select">
              <span class="sr-only">Category</span>
              <select v-model="category">
                <option value="">All categories</option>
                <option v-for="c in categories" :key="c" :value="c">{{ c }}</option>
              </select>
            </label>
            <label class="shop-select">
              <span class="sr-only">Brand</span>
              <select v-model="brand">
                <option value="">All brands</option>
                <option v-for="b in brands" :key="b" :value="b">{{ b }}</option>
              </select>
            </label>
          </div>

          <p class="shop-count">
            Showing
            <template v-if="filtered.length">
              {{ ((page - 1) * pageSize) + 1 }}–{{ Math.min(page * pageSize, filtered.length) }}
              of {{ filtered.length.toLocaleString() }}
            </template>
            <template v-else>0</template>
            {{ filtered.length === 1 ? 'product' : 'products' }}
          </p>

          <div v-if="pageItems.length" class="product-grid">
            <ProductCard v-for="p in pageItems" :key="p.id" :product="p" />
          </div>

          <div v-if="pageItems.length && totalPages > 1" class="shop-pagination">
            <button type="button" class="btn btn-outline" :disabled="page <= 1" @click="prevPage">
              Previous
            </button>
            <span>Page {{ page }} of {{ totalPages }}</span>
            <button type="button" class="btn btn-outline" :disabled="page >= totalPages" @click="nextPage">
              Next
            </button>
          </div>

          <div v-else-if="!productCount" class="shop-empty">
            <h2>Inventory coming soon</h2>
            <p>
              We're connecting our Lightspeed inventory to the website.
              Call us anytime for gear and availability.
            </p>
            <div class="shop-empty-actions">
              <a href="tel:+15194339555" class="btn btn-primary">(519) 433-9555</a>
              <NuxtLink to="/#contact" class="btn btn-outline">Contact the team</NuxtLink>
            </div>
          </div>

          <div v-else-if="!filtered.length" class="shop-empty">
            <h2>No products match your filters</h2>
            <p>Try a different search or clear your filters.</p>
          </div>
        </template>

        <p class="shop-disclaimer">
          Prices from store inventory may change. Confirm availability in store or by phone.
          Online checkout is not available yet — we're happy to help you order by phone or email.
        </p>
      </div>
    </main>

    <SiteFooter />
  </div>
</template>
