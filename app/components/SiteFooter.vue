<script setup lang="ts">
const route = useRoute()
const { handleAnchorClick } = useSmoothScroll()
const { shopHref, siteHref } = useSiteHref()
const isHome = computed(() => route.path === '/' || route.path === '')

function homeHash(hash: string) {
  return isHome.value ? hash : siteHref(`/${hash}`)
}

function onHomeHashClick(event: MouseEvent, hash: string) {
  if (isHome.value) handleAnchorClick(event, hash)
}
</script>

<template>
  <footer class="footer">
    <div class="container">
      <div class="footer-grid">
        <div>
          <div class="footer-logo">
            <img src="/assets/petes-sports-logo.png" alt="Pete's Sports">
          </div>
          <p class="footer-tagline">Est. 1978 &bull; London &amp; Strathroy, Ontario</p>
        </div>
        <div>
          <h4>Our Locations</h4>
          <div class="footer-links">
            <span><strong>London</strong> — 900 Oxford St E, Unit 15</span>
            <span>Mon–Fri 10–6 &bull; Sat 10–4 &bull; Sun Closed</span>
            <span class="footer-location-divider" />
            <NuxtLink to="/gemini">
              <strong>Strathroy</strong> — 667 Adair Blvd
            </NuxtLink>
            <span>Gemini Sportsplex Pro Shop</span>
            <span>Open 7 days a week</span>
            <span>Mon–Fri 3–9 &bull; Sat–Sun 8–6</span>
            <a href="tel:+15194339555">(519) 433-9555</a>
          </div>
        </div>
        <div>
          <h4>Quick Links</h4>
          <div class="footer-links">
            <NuxtLink to="/">Home</NuxtLink>
            <a :href="shopHref">Shop</a>
            <NuxtLink to="/gemini">Gemini Pro Shop</NuxtLink>
            <a :href="homeHash('#managers')" @click="onHomeHashClick($event, '#managers')">Our Team</a>
            <a :href="homeHash('#services')" @click="onHomeHashClick($event, '#services')">Services</a>
            <a :href="homeHash('#teamwear')" @click="onHomeHashClick($event, '#teamwear')">Teamwear</a>
            <a :href="homeHash('#locations')" @click="onHomeHashClick($event, '#locations')">Locations</a>
            <a :href="homeHash('#contact')" @click="onHomeHashClick($event, '#contact')">Contact</a>
            <a href="mailto:sales@petessports.com">sales@petessports.com</a>
          </div>
        </div>
      </div>
      <div class="footer-bottom">
        <span>&copy; {{ new Date().getFullYear() }} Pete's Sports. All rights reserved.</span>
        <div class="footer-legal">
          <a :href="shopHref">Shop inventory</a>
          <a href="#">Privacy</a>
          <a href="#">Legal</a>
        </div>
      </div>
    </div>
  </footer>
</template>
