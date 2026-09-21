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
          Strathroy and Park Hill area. They're also available on the team stores.
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
          <p v-if="team.storeHref" class="gemini-team-note">Also available on the team store</p>
          <p v-else class="gemini-team-note">Products available in the Pro Shop</p>
          <a
            v-if="team.storeHref"
            :href="team.storeHref"
            class="btn btn-accent gemini-team-store"
            target="_blank"
            rel="noopener noreferrer"
          >
            Shop now
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 6H5.25A2.25 2.25 0 0 0 3 8.25v10.5A2.25 2.25 0 0 0 5.25 21h10.5A2.25 2.25 0 0 0 18 18.75V10.5M21 3l-9 9m0 0h5.25M12 12V3" /></svg>
          </a>
        </RevealBlock>
      </div>
    </div>
  </section>
</template>
