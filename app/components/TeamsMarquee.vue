<script setup lang="ts">
import { localTeams } from '~/data/site'

const marqueeTeams = [...localTeams, ...localTeams]
</script>

<template>
  <section class="teams">
    <h2>Proudly supporting local teams &amp; associations</h2>
    <div class="marquee">
      <div class="marquee-track">
        <span v-for="(team, index) in marqueeTeams" :key="`${team}-${index}`">{{ team }}</span>
      </div>
    </div>
  </section>
</template>