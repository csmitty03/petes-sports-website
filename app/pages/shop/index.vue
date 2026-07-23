<script setup lang="ts">
useSeoMeta({
  title: "Shop | Pete's Sports",
  description: "Browse Pete's Sports inventory — hockey, baseball, and sporting goods from our London & Strathroy stores.",
})

const { products, categories, brands, syncedAt, productCount } = await useCatalog()

const search = ref('')
const category = ref('')
const brand = ref('')

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
            <span v-if="productCount"> · {{ productCount }} items</span>
          </p>
        </header>

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
          Showing {{ filtered.length }}
          {{ filtered.length === 1 ? 'product' : 'products' }}
        </p>

        <div v-if="filtered.length" class="product-grid">
          <ProductCard v-for="p in filtered" :key="p.id" :product="p" />
        </div>

        <div v-else class="shop-empty">
          <h2 v-if="!productCount">Inventory coming soon</h2>
          <h2 v-else>No products match your filters</h2>
          <p v-if="!productCount">
            We're connecting our Lightspeed inventory to the website.
            Call us anytime for gear and availability.
          </p>
          <p v-else>Try a different search or clear your filters.</p>
          <div class="shop-empty-actions">
            <a href="tel:+15194339555" class="btn btn-primary">(519) 433-9555</a>
            <NuxtLink to="/#contact" class="btn btn-outline">Contact the team</NuxtLink>
          </div>
        </div>

        <p class="shop-disclaimer">
          Prices from store inventory may change. Confirm availability in store or by phone.
          Online checkout is not available yet — we're happy to help you order by phone or email.
        </p>
      </div>
    </main>

    <SiteFooter />
  </div>
</template>
