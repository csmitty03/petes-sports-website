<script setup lang="ts">
const { handleAnchorClick } = useSmoothScroll()
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
            <span><strong>Strathroy</strong> — 667 Adair Blvd</span>
            <span>Gemini Sportsplex Pro Shop</span>
            <a href="tel:+15194339555">(519) 433-9555</a>
          </div>
        </div>
        <div>
          <h4>Quick Links</h4>
          <div class="footer-links">
            <NuxtLink to="/shop">Shop</NuxtLink>
            <a href="/#managers" @click="handleAnchorClick($event, '#managers')">Our Team</a>
            <a href="/#services" @click="handleAnchorClick($event, '#services')">Services</a>
            <a href="/#teamwear" @click="handleAnchorClick($event, '#teamwear')">Teamwear</a>
            <a href="/#locations" @click="handleAnchorClick($event, '#locations')">Locations</a>
            <a href="/#contact" @click="handleAnchorClick($event, '#contact')">Contact</a>
            <a href="mailto:sales@petessports.com">sales@petessports.com</a>
          </div>
        </div>
      </div>
      <div class="footer-bottom">
        <span>&copy; {{ new Date().getFullYear() }} Pete's Sports. All rights reserved.</span>
        <div class="footer-legal">
          <NuxtLink to="/shop">Shop inventory</NuxtLink>
          <a href="#">Privacy</a>
          <a href="#">Legal</a>
        </div>
      </div>
    </div>
  </footer>
</template>