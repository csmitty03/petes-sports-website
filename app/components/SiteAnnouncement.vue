<script setup lang="ts">
const STORAGE_KEY = 'petes-announcement-dismissed'
const { handleAnchorClick } = useSmoothScroll()
const dismissed = ref(false)

function applyDismissed(value: boolean) {
  dismissed.value = value
  if (import.meta.client) {
    document.documentElement.classList.toggle('announcement-dismissed', value)
  }
}

function dismiss() {
  applyDismissed(true)
  try {
    localStorage.setItem(STORAGE_KEY, '1')
  }
  catch {
    // Ignore storage errors (private browsing, blocked storage)
  }
}

onMounted(() => {
  try {
    if (localStorage.getItem(STORAGE_KEY) === '1') applyDismissed(true)
  }
  catch {
    // Keep the bar visible if storage is unavailable
  }
})
</script>

<template>
  <div v-if="!dismissed" class="announcement-bar">
    <span>
      Under new ownership &amp; management — same great service, fresh energy.
      <a href="#managers" @click="handleAnchorClick($event, '#managers')">Meet the team</a>
    </span>
    <button type="button" class="announcement-close" aria-label="Close announcement" @click="dismiss">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.25" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
      </svg>
    </button>
  </div>
</template>