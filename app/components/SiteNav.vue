<script setup lang="ts">
import { navLinks } from '~/data/site'

const isScrolled = ref(false)
const isMenuOpen = ref(false)
const { handleAnchorClick } = useSmoothScroll()

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
  handleAnchorClick(event, href)
  closeMenu()
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
      <a href="#" class="nav-logo" @click="handleAnchorClick($event, '#')">
        <img src="/assets/petes-sports-logo.png" alt="Pete's Sports — Est. 1978">
      </a>
      <div class="nav-links">
        <a
          v-for="link in navLinks"
          :key="link.href"
          :href="link.href"
          @click="handleAnchorClick($event, link.href)"
        >
          {{ link.label }}
        </a>
      </div>
      <a href="#contact" class="nav-cta nav-cta-desktop" @click="handleAnchorClick($event, '#contact')">
        Contact Us
      </a>
      <button class="nav-toggle" aria-label="Toggle menu" @click="toggleMenu">
        <span v-html="isMenuOpen ? closeIcon : menuIcon" />
      </button>
    </div>
  </nav>

  <div class="mobile-menu" :class="{ open: isMenuOpen }">
    <a
      v-for="link in navLinks"
      :key="`mobile-${link.href}`"
      :href="link.href"
      @click="onNavClick($event, link.href)"
    >
      {{ link.label }}
    </a>
    <a href="#contact" class="nav-cta" @click="onNavClick($event, '#contact')">Contact Us</a>
  </div>
</template>