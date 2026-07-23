<script setup lang="ts">
import { formatCad } from '~/composables/useCatalog'

const route = useRoute()
const { products, pending, error, refresh, productCount } = await useCatalog()

const product = computed(() => {
  const id = String(route.query.id || '')
  if (!id) return null
  return products.value.find((p) => p.id === id) || null
})

useSeoMeta({
  title: () => `${product.value?.name || 'Product'} | Pete's Sports`,
  description: () =>
    product.value?.description?.slice(0, 160) ||
    `Shop ${product.value?.name || 'gear'} at Pete's Sports — London & Strathroy.`,
})

const mailHref = computed(() => {
  const p = product.value
  if (!p) return 'mailto:sales@petessports.com'
  const subject = encodeURIComponent(`Inquiry: ${p.name} (${p.sku || p.id})`)
  const body = encodeURIComponent(
    `Hi Pete's Sports,\n\nI'm interested in:\n${p.name}\nSKU: ${p.sku || 'n/a'}\nPrice shown: ${formatCad(p.price)}\n\nPlease let me know availability.\n\nThanks`,
  )
  return `mailto:sales@petessports.com?subject=${subject}&body=${body}`
})

const isLoading = computed(() => pending.value && !product.value)
</script>

<template>
  <div>
    <SiteAnnouncement />
    <SiteNav />

    <main class="shop-page product-detail-page">
      <div class="container">
        <nav class="product-breadcrumb">
          <NuxtLink to="/shop">Shop</NuxtLink>
          <span aria-hidden="true">/</span>
          <span>{{ product?.name || 'Product' }}</span>
        </nav>

        <div v-if="isLoading" class="shop-empty">
          <h2>Loading product…</h2>
          <p>Loading catalog details. This can take a few seconds.</p>
        </div>

        <div v-else-if="error && !productCount" class="shop-empty">
          <h2>Couldn’t load product</h2>
          <div class="shop-empty-actions">
            <button type="button" class="btn btn-primary" @click="refresh()">Retry</button>
            <NuxtLink to="/shop" class="btn btn-outline">Back to shop</NuxtLink>
          </div>
        </div>

        <div v-else-if="product" class="product-detail">
          <div class="product-detail-media">
            <img
              v-if="product.image || product.imageThumb"
              :src="product.image || product.imageThumb || ''"
              :alt="product.name"
            >
            <div v-else class="product-card-placeholder product-detail-placeholder">
              <span>Pete's Sports</span>
            </div>
          </div>

          <div class="product-detail-info">
            <p v-if="product.brand" class="product-card-brand">{{ product.brand }}</p>
            <h1>{{ product.name }}</h1>
            <p class="product-detail-price">{{ formatCad(product.price) }}</p>

            <dl class="product-meta-list">
              <div v-if="product.sku">
                <dt>SKU</dt>
                <dd>{{ product.sku }}</dd>
              </div>
              <div v-if="product.category">
                <dt>Category</dt>
                <dd>{{ product.category }}</dd>
              </div>
              <div v-if="product.variantName && product.variantName !== product.name">
                <dt>Variant</dt>
                <dd>{{ product.variantName }}</dd>
              </div>
            </dl>

            <p v-if="product.description" class="product-description">
              {{ product.description }}
            </p>

            <div class="product-detail-actions">
              <a :href="mailHref" class="btn btn-primary">Email us about this item</a>
              <a href="tel:+15194339555" class="btn btn-outline">Call (519) 433-9555</a>
            </div>

            <p class="product-detail-note">
              Browse-only catalog — order by phone or email. We'll confirm stock at London or Strathroy.
            </p>
          </div>
        </div>

        <div v-else class="shop-empty">
          <h2>Product not found</h2>
          <p>That item may have been removed or the link is incomplete.</p>
          <div class="shop-empty-actions">
            <NuxtLink to="/shop" class="btn btn-primary">Back to shop</NuxtLink>
          </div>
        </div>

        <p class="shop-back">
          <NuxtLink to="/shop">← Back to shop</NuxtLink>
        </p>
      </div>
    </main>

    <SiteFooter />
  </div>
</template>
