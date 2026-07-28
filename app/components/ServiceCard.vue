<script setup lang="ts">
import type { Service } from '~/data/site'

const props = defineProps<{
  service: Service
  icon: string
}>()

const { element, isVisible } = useReveal()
const { handleAnchorClick } = useSmoothScroll()
const { siteHref, shopHref } = useSiteHref()

const isHash = computed(() => (props.service.link || '').startsWith('#'))
const isExternal = computed(() => /^https?:/i.test(props.service.link || ''))
const isShop = computed(() => {
  const l = (props.service.link || '').replace(/\/$/, '')
  return l.endsWith('shop')
})
const resolvedHref = computed(() => {
  if (!props.service.link) return '#'
  if (isShop.value) return shopHref.value
  if (isHash.value || isExternal.value) return props.service.link
  return siteHref(props.service.link)
})
</script>

<template>
  <div ref="element" class="service-card reveal" :class="{ visible: isVisible }">
    <div class="service-icon" v-html="icon" />
    <h3>{{ service.title }}</h3>
    <p>{{ service.description }}</p>
    <span v-if="service.tag" class="service-tag">
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" /></svg>
      {{ service.tag }}
    </span>
    <a
      v-if="service.link && isHash"
      :href="service.link"
      class="service-link"
      @click="handleAnchorClick($event, service.link)"
    >
      {{ service.linkLabel || 'Learn more' }}
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3" /></svg>
    </a>
    <a
      v-else-if="service.link && isExternal"
      :href="service.link"
      class="service-link"
      target="_blank"
      rel="noopener noreferrer"
    >
      {{ service.linkLabel || 'Learn more' }}
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3" /></svg>
    </a>
    <!-- Plain <a> so static pages like /shop/ get a full browser load (not Nuxt SPA 404) -->
    <a
      v-else-if="service.link"
      :href="resolvedHref"
      class="service-link"
    >
      {{ service.linkLabel || 'Learn more' }}
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3" /></svg>
    </a>
  </div>
</template>
