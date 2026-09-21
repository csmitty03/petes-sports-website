<script setup lang="ts">
import { locations } from '~/data/site'
</script>

<template>
  <section id="locations" class="section">
    <div class="container">
      <RevealBlock class="section-header">
        <span class="section-label">Find Us</span>
        <h2 class="section-title">Visit Us</h2>
        <p class="section-desc">Two Pete's Sports locations serving London and Strathroy.</p>
      </RevealBlock>

      <RevealBlock class="locations-grid">
        <div v-for="location in locations" :key="location.title" class="location-card featured">
          <div class="location-header">
            <div>
              <h3>{{ location.title }}</h3>
              <p v-if="location.subtitle" class="location-subtitle">{{ location.subtitle }}</p>
            </div>
          </div>
          <p class="location-address">
            <template v-for="(line, index) in location.address" :key="line">
              {{ line }}<br v-if="index < location.address.length - 1">
            </template>
          </p>
          <p v-if="location.note" class="location-note">{{ location.note }}</p>
          <div class="location-details">
            <div><strong>Phone:</strong> <a href="tel:+15194339555">{{ location.phone }}</a></div>
            <div><strong>Email:</strong> <a :href="`mailto:${location.email}`">{{ location.email }}</a></div>
          </div>
          <div class="location-hours">
            <strong>Hours</strong><br>
            <template v-for="(hour, index) in location.hours" :key="hour">
              {{ hour }}<br v-if="index < location.hours.length - 1">
            </template>
          </div>
          <div class="location-actions">
            <a
              v-if="location.mapsHref"
              :href="location.mapsHref"
              class="btn btn-accent location-map-btn"
              target="_blank"
              rel="noopener noreferrer"
            >
              {{ location.mapsLabel || 'Get directions' }}
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 6H5.25A2.25 2.25 0 0 0 3 8.25v10.5A2.25 2.25 0 0 0 5.25 21h10.5A2.25 2.25 0 0 0 18 18.75V10.5M21 3l-9 9m0 0h5.25M12 12V3" /></svg>
            </a>
            <NuxtLink v-if="location.pageHref" :to="location.pageHref" class="location-link">
              {{ location.pageLabel }}
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3" /></svg>
            </NuxtLink>
          </div>
        </div>
      </RevealBlock>
    </div>
  </section>
</template>