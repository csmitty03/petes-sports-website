<script setup lang="ts">
import { navLinks } from '~/data/site'

const isScrolled = ref(false)
const isMenuOpen = ref(false)
const { handleAnchorClick } = useSmoothScroll()
const { siteHref, shopHref } = useSiteHref()

const menuIcon = `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"/></svg>`
const closeIcon = `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12"/></svg>`

function onScroll() {
  isScrolled.value = window.scrollY > 20
}

function toggleMenu() {
  isMenuOpen.value = !isMenuOpen.value
}

function closeMenu() {
  isMenuOpen.value = false
}

function onNavClick(event: MouseEvent, href: string) {
  if (href.startsWith('#') || href.startsWith('/#')) {
    handleAnchorClick(event, href.startsWith('/#') ? href.slice(1) : href)
  }
  closeMenu()
}

function linkHref(href: string) {
  // Shop is a static HTML page — must leave the Nuxt SPA
  if (href.replace(/\/$/, '').endsWith('shop')) return shopHref.value
  if (href.startsWith('/#') || href.startsWith('#')) return href
  return siteHref(href)
}

function isShopLink(href: string) {
  return href.replace(/\/$/, '').endsWith('shop')
}

onMounted(() => {
  window.addEventListener('scroll', onScroll, { passive: true })
  onScroll()
})

onUnmounted(() => {
  window.removeEventListener('scroll', onScroll)
})
</script>

<template>
  <nav class="nav" :class="{ scrolled: isScrolled }">
    <div class="container nav-inner">
      <NuxtLink to="/" class="nav-logo">
        <img src="/assets/petes-sports-logo.png" alt="Pete's Sports — Est. 1978">
      </NuxtLink>
      <div class="nav-links">
        <template v-for="link in navLinks" :key="link.href">
          <!-- Full page load for static shop -->
          <a
            v-if="isShopLink(link.href)"
            :href="shopHref"
          >
            {{ link.label }}
          </a>
          <a
            v-else-if="link.href.startsWith('/#') || link.href.startsWith('#')"
            :href="link.href"
            @click="onNavClick($event, link.href)"
          >
            {{ link.label }}
          </a>
          <NuxtLink
            v-else
            :to="link.href"
          >
            {{ link.label }}
          </NuxtLink>
        </template>
      </div>
      <a :href="shopHref" class="nav-cta nav-cta-desktop">
        Shop
      </a>
      <button class="nav-toggle" aria-label="Toggle menu" @click="toggleMenu">
        <span v-html="isMenuOpen ? closeIcon : menuIcon" />
      </button>
    </div>
  </nav>

  <div class="mobile-menu" :class="{ open: isMenuOpen }">
    <template v-for="link in navLinks" :key="`mobile-${link.href}`">
      <a
        v-if="isShopLink(link.href)"
        :href="shopHref"
        @click="closeMenu"
      >
        {{ link.label }}
      </a>
      <a
        v-else-if="link.href.startsWith('/#') || link.href.startsWith('#')"
        :href="link.href"
        @click="onNavClick($event, link.href)"
      >
        {{ link.label }}
      </a>
      <NuxtLink
        v-else
        :to="link.href"
        @click="closeMenu"
      >
        {{ link.label }}
      </NuxtLink>
    </template>
    <a :href="shopHref" class="nav-cta" @click="closeMenu">Shop inventory</a>
  </div>
</template>
