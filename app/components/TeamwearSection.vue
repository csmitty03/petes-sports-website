<script setup lang="ts">
import { teamwearItems, teamStores } from '~/data/site'

const { shopHref, siteHref } = useSiteHref()
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
          <div class="teamwear-actions" style="display:flex;flex-wrap:wrap;gap:12px">
            <a :href="shopHref" class="btn btn-accent">Browse inventory</a>
            <a href="embroidery-order.html" class="btn btn-outline">Embroidery order form</a>
          </div>
        </div>
        <div class="teamwear-visual">
          <img src="/assets/petes-sports-logo.png" alt="Pete's Sports">
          <p class="teamwear-visual-text">Outfitting local teams across London &amp; Southwestern Ontario</p>
        </div>
      </RevealBlock>

      <RevealBlock class="team-stores">
        <div class="section-header">
          <span class="section-label">Team Stores</span>
          <h2 class="section-title">You made the cut</h2>
          <p class="section-desc">Get your team's apparel here. Each store opens in a new tab with the same checkout you already use.</p>
        </div>

        <div class="team-stores-grid">
          <a
            v-for="store in teamStores"
            :key="store.href"
            :href="store.href"
            class="team-store-card"
            target="_blank"
            rel="noopener noreferrer"
          >
            <div v-if="store.logo" class="team-store-logo">
              <img :src="siteHref(store.logo)" :alt="`${store.name} logo`">
            </div>
            <div v-else class="team-store-initials">
              {{ store.initials }}
            </div>
            <h3>{{ store.name }}</h3>
            <p class="team-store-sport">{{ store.sport }}</p>
            <span class="btn btn-accent team-store-btn">
              Shop now
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 6H5.25A2.25 2.25 0 0 0 3 8.25v10.5A2.25 2.25 0 0 0 5.25 21h10.5A2.25 2.25 0 0 0 18 18.75V10.5M21 3l-9 9m0 0h5.25M12 12V3" /></svg>
            </span>
          </a>
        </div>
      </RevealBlock>
    </div>
  </section>
</template>