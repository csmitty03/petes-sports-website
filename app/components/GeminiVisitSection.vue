<script setup lang="ts">
import { geminiHours, locations } from '~/data/site'

const gemini = locations.find(location => location.pageHref === '/gemini') ?? locations[1]
const mapsHref = 'https://maps.google.com/?q=667+Adair+Blvd+Strathroy+ON+N7G+3H8'
</script>

<template>
  <section id="visit" class="section gemini-visit">
    <div class="container">
      <RevealBlock class="section-header">
        <span class="section-label">Find Us</span>
        <h2 class="section-title">Visit the Gemini Pro Shop</h2>
        <p class="section-desc">
          Located inside the Gemini Sportsplex in Strathroy. We're open 7 days a week —
          drop in before a game, after practice, or anytime you need gear.
        </p>
      </RevealBlock>

      <div class="gemini-visit-grid">
        <RevealBlock class="gemini-visit-card">
          <div class="location-header">
            <div class="location-icon">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" /><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z" /></svg>
            </div>
            <div>
              <h3>{{ gemini.title }}</h3>
              <p class="location-subtitle">{{ gemini.subtitle }}</p>
            </div>
          </div>
          <p class="location-address">
            <template v-for="(line, index) in gemini.address" :key="line">
              {{ line }}<br v-if="index < gemini.address.length - 1">
            </template>
          </p>
          <p class="location-note">{{ gemini.note }}</p>
          <div class="location-details">
            <div><strong>Phone:</strong> <a href="tel:+15194339555">{{ gemini.phone }}</a></div>
            <div><strong>Email:</strong> <a :href="`mailto:${gemini.email}`">{{ gemini.email }}</a></div>
          </div>
          <a :href="mapsHref" class="btn btn-accent gemini-map-btn" target="_blank" rel="noopener noreferrer">
            Get directions
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 6H5.25A2.25 2.25 0 0 0 3 8.25v10.5A2.25 2.25 0 0 0 5.25 21h10.5A2.25 2.25 0 0 0 18 18.75V10.5M21 3l-9 9m0 0h5.25M12 12V3" /></svg>
          </a>
        </RevealBlock>

        <RevealBlock class="gemini-hours-card">
          <span class="gemini-open-badge">Open 7 days a week</span>
          <h3>Store Hours</h3>
          <p class="gemini-hours-intro">Come see us any day of the week at the Gemini Sportsplex.</p>
          <ul class="gemini-hours-list">
            <li v-for="row in geminiHours" :key="row.label">
              <span>{{ row.label }}</span>
              <strong>{{ row.time }}</strong>
            </li>
          </ul>
        </RevealBlock>
      </div>
    </div>
  </section>
</template>
