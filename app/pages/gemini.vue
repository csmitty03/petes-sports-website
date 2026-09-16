<script setup lang="ts">
import { geminiManagers, geminiSalesReps } from '~/data/site'

useSeoMeta({
  title: "Gemini Pro Shop | Pete's Sports | Strathroy, Ontario",
  description: "Pete's Sports Gemini Pro Shop inside the Gemini Sportsplex in Strathroy. Open 7 days a week. Hockey and baseball gear, team products, and expert service.",
})

const { handleAnchorClick } = useSmoothScroll()
</script>

<template>
  <div class="gemini-page">
    <SiteAnnouncement />
    <SiteNav />

    <header class="hero gemini-hero">
      <div class="hero-bg" />
      <div class="hero-pattern" />
      <div class="container hero-content">
        <div>
          <div class="hero-badge">
            <span class="hero-badge-dot" />
            Inside Gemini Sportsplex — Strathroy
          </div>
          <h1>Gemini<br>Pro Shop.</h1>
          <p class="hero-text">
            Pete's Sports at the Gemini Sportsplex. Open <strong>7 days a week</strong>
            for hockey gear, baseball equipment, and products for local teams.
          </p>
          <div class="hero-actions">
            <a href="#visit" class="btn btn-primary" @click="handleAnchorClick($event, '#visit')">Location &amp; Hours</a>
            <a href="#managers" class="btn btn-outline" @click="handleAnchorClick($event, '#managers')">Meet the Team</a>
          </div>
          <div class="hero-features">
            <div class="hero-feature">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" /></svg>
              Open 7 days a week
            </div>
            <div class="hero-feature">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" /></svg>
              Weekdays 3–9
            </div>
            <div class="hero-feature">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" /></svg>
              Weekends 8–6
            </div>
          </div>
        </div>
        <div class="hero-visual">
          <div class="hero-logo-card">
            <img src="/assets/petes-sports-logo.png" alt="Pete's Sports Logo">
          </div>
          <div class="hero-stats">
            <div class="hero-stat">
              <div class="hero-stat-value">7</div>
              <div class="hero-stat-label">Days Open</div>
            </div>
            <div class="hero-stat">
              <div class="hero-stat-value">3–9</div>
              <div class="hero-stat-label">Weekdays</div>
            </div>
            <div class="hero-stat">
              <div class="hero-stat-value">8–6</div>
              <div class="hero-stat-label">Weekends</div>
            </div>
          </div>
        </div>
      </div>
    </header>

    <GeminiVisitSection />

    <TeamSection
      :managers="geminiManagers"
      :sales-reps="geminiSalesReps"
      sales-label="Gemini Pro Shop"
      sales-title="Meet the Sales Reps"
      sales-desc="Our Strathroy team is here to help you find the right gear at the Gemini Sportsplex."
    />

    <GeminiTeamsSection />
    <ContactSection />
    <SiteFooter />
  </div>
</template>
