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
            <div class="location-icon">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 21v-7.5a.75.75 0 0 1 .75-.75h3a.75.75 0 0 1 .75.75V21m-4.5 0H2.36a11.239 11.239 0 0 1-.5-2.186 10.374 10.374 0 0 1 .5-4.244 11.217 11.217 0 0 1 2.5-3.864M13.5 21h5.238a11.222 11.222 0 0 0-2.5-3.864M8.25 9.75h7.5M8.25 12.75h7.5m-7.5 3h3.375c.621 0 1.125-.504 1.125-1.125V9.75M8.25 6.75h7.5" /></svg>
            </div>
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
        </div>
      </RevealBlock>
    </div>
  </section>
</template>