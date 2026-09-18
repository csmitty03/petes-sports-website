<script setup lang="ts">
import { geminiLocalTeams } from '~/data/site'

const { siteHref } = useSiteHref()
</script>

<template>
  <section id="gemini-teams" class="section gemini-teams">
    <div class="container">
      <RevealBlock class="section-header">
        <span class="section-label">Local Teams</span>
        <h2 class="section-title">Gear for the teams around us</h2>
        <p class="section-desc">
          We'll have products available in the Gemini Pro Shop for local teams in the
          Strathroy and Park Hill area — stop in for team gear, apparel, and equipment.
        </p>
      </RevealBlock>

      <div class="gemini-teams-grid">
        <RevealBlock v-for="team in geminiLocalTeams" :key="team.name" class="gemini-team-card">
          <div v-if="team.logo" class="gemini-team-logo">
            <img :src="siteHref(team.logo)" :alt="`${team.name} logo`">
          </div>
          <div v-else class="gemini-team-initials">
            {{ team.initials }}
          </div>
          <h3>{{ team.name }}</h3>
          <p class="gemini-team-sport">{{ team.sport }}</p>
          <p v-if="team.area" class="gemini-team-area">{{ team.area }}</p>
          <p class="gemini-team-note">Products available in the Pro Shop</p>
        </RevealBlock>
      </div>
    </div>
  </section>
</template>
