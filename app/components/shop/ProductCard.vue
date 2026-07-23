<script setup lang="ts">
import type { CatalogProduct } from '~/composables/useCatalog'
import { formatCad } from '~/composables/useCatalog'

defineProps<{
  product: CatalogProduct
}>()
</script>

<template>
  <NuxtLink :to="{ path: '/shop/product', query: { id: product.id } }" class="product-card">
    <div class="product-card-image">
      <img
        v-if="product.imageThumb || product.image"
        :src="product.imageThumb || product.image || ''"
        :alt="product.name"
        loading="lazy"
      >
      <div v-else class="product-card-placeholder">
        <span>Pete's Sports</span>
      </div>
    </div>
    <div class="product-card-body">
      <p v-if="product.brand" class="product-card-brand">{{ product.brand }}</p>
      <h3 class="product-card-title">{{ product.name }}</h3>
      <p v-if="product.category" class="product-card-meta">{{ product.category }}</p>
      <p class="product-card-price">{{ formatCad(product.price) }}</p>
    </div>
  </NuxtLink>
</template>
