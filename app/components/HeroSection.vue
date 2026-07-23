<script setup lang="ts">
const { handleAnchorClick } = useSmoothScroll()
</script>

<template>
  <header class="hero">
    <div class="hero-bg" />
    <div class="hero-pattern" />
    <div class="container hero-content">
      <div>
        <div class="hero-badge">
          <span class="hero-badge-dot" />
          Serving London &amp; Strathroy Since 1978
        </div>
        <h1>Quality Gear.<br>Real Service.<br><span>Since 1978.</span></h1>
        <p class="hero-text">
          London's trusted source for hockey and baseball equipment —
          plus custom teamwear and professional embroidery.
        </p>
        <div class="hero-actions">
          <a href="#services" class="btn btn-primary" @click="handleAnchorClick($event, '#services')">Browse Services</a>
          <a href="#contact" class="btn btn-outline" @click="handleAnchorClick($event, '#contact')">Contact the Team</a>
        </div>
        <div class="hero-features">
          <div class="hero-feature">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" /></svg>
            Expert fitting
          </div>
          <div class="hero-feature">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" /></svg>
            Custom embroidery
          </div>
          <div class="hero-feature">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" /></svg>
            Team stores
          </div>
        </div>
      </div>
      <div class="hero-visual">
        <div class="hero-logo-card">
          <img src="/assets/petes-sports-logo.png" alt="Pete's Sports Logo">
        </div>
        <div class="hero-stats">
          <div class="hero-stat">
            <div class="hero-stat-value">48</div>
            <div class="hero-stat-label">Years</div>
          </div>
          <div class="hero-stat">
            <div class="hero-stat-value">2</div>
            <div class="hero-stat-label">Locations</div>
          </div>
          <div class="hero-stat">
            <div class="hero-stat-value">1K+</div>
            <div class="hero-stat-label">Teams Outfitted</div>
          </div>
        </div>
      </div>
    </div>
  </header>
</template>