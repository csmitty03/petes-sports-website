<script setup lang="ts">
import { teamwearItems } from '~/data/site'

const { handleAnchorClick } = useSmoothScroll()
</script>

<template>
  <section id="teamwear" class="section teamwear">
    <div class="container">
      <RevealBlock class="teamwear-grid">
        <div class="teamwear-content">
          <span class="section-label">Teamwear</span>
          <h2>Custom Teamwear &amp; Jerseys</h2>
          <p>Whether you need customized jerseys for hockey or baseball — we've got exactly what your team needs.</p>
          <ul class="teamwear-list">
            <li v-for="item in teamwearItems" :key="item">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" /></svg>
              {{ item }}
            </li>
          </ul>
          <a href="embroidery-order.html" class="btn btn-accent">Get a Team Quote / Order Form</a>
        </div>
        <div class="teamwear-visual">
          <img src="/assets/petes-sports-logo.png" alt="Pete's Sports">
          <p class="teamwear-visual-text">Outfitting local teams across London &amp; Southwestern Ontario</p>
        </div>
      </RevealBlock>

      <RevealBlock class="teamwear-brands">
        <div class="teamwear-brand-card">
          <div class="teamwear-brand-logo">
            <img src="/assets/bluewater-hawks-logo.jpg" alt="BlueWater Hawks Girls Hockey">
          </div>
          <div class="teamwear-brand-copy">
            <span class="teamwear-brand-label">Featured Teamwear Brand</span>
            <p>Shop official BlueWater Hawks jerseys, apparel, and team gear through our live online store.</p>
          </div>
          <div class="teamwear-brand-action">
            <a
              href="https://www.petessports.com/bluewater-hawks"
              class="btn btn-accent teamwear-brand-btn"
              target="_blank"
              rel="noopener noreferrer"
            >
              Shop BlueWater Hawks
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 6H5.25A2.25 2.25 0 0 0 3 8.25v10.5A2.25 2.25 0 0 0 5.25 21h10.5A2.25 2.25 0 0 0 18 18.75V10.5M21 3l-9 9m0 0h5.25M12 12V3" /></svg>
            </a>
          </div>
        </div>
      </RevealBlock>
    </div>
  </section>
</template>