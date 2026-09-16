<script setup lang="ts">
import { navLinks } from '~/data/site'

const isScrolled = ref(false)
const isMenuOpen = ref(false)
const route = useRoute()
const { handleAnchorClick } = useSmoothScroll()
const { siteHref, shopHref } = useSiteHref()
const isHome = computed(() => route.path === '/' || route.path === '')

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
  if (isHome.value && (href.startsWith('#') || href.startsWith('/#'))) {
    handleAnchorClick(event, href.startsWith('/#') ? href.slice(1) : href)
  }
  closeMenu()
}

function linkHref(href: string) {
  if (href.startsWith('/#') || href.startsWith('#')) {
    const hash = href.startsWith('/#') ? href.slice(1) : href
    return isHome.value ? hash : siteHref(href.startsWith('#') ? `/${href}` : href)
  }
  return siteHref(href)
}

function onHomeClick() {
  closeMenu()
  if (isHome.value && import.meta.client) {
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
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
          <a
            v-if="link.href.startsWith('/#') || link.href.startsWith('#')"
            :href="linkHref(link.href)"
            @click="onNavClick($event, link.href)"
          >
            {{ link.label }}
          </a>
          <NuxtLink
            v-else
            :to="link.href"
            @click="link.href === '/' ? onHomeClick() : closeMenu()"
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
        v-if="link.href.startsWith('/#') || link.href.startsWith('#')"
        :href="linkHref(link.href)"
        @click="onNavClick($event, link.href)"
      >
        {{ link.label }}
      </a>
      <NuxtLink
        v-else
        :to="link.href"
        @click="link.href === '/' ? onHomeClick() : closeMenu()"
      >
        {{ link.label }}
      </NuxtLink>
    </template>
    <a :href="shopHref" class="nav-cta" @click="closeMenu">Shop</a>
  </div>
</template>
