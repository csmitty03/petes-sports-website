<script setup lang="ts">
definePageMeta({
  layout: 'staff',
  middleware: 'staff',
})

const { ready, isLoggedIn, refresh } = useStaffAuth()
await refresh()
await navigateTo(isLoggedIn.value ? '/staff/orders' : '/staff/login')
</script>

<template>
  <p v-if="!ready">Loading staff…</p>
</template>
