<script setup lang="ts">
const { handleAnchorClick } = useSmoothScroll()
</script>

<template>
  <div class="announcement-bar">
    <span>
      Under new ownership &amp; management — same great service, fresh energy.
      <a href="#managers" @click="handleAnchorClick($event, '#managers')">Meet the team</a>
    </span>
  </div>
</template>