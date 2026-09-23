<script setup lang="ts">
withDefaults(defineProps<{ to?: string; label?: string }>(), {
  to: '/staff/orders',
  label: 'Back to orders',
})
</script>

<template>
  <NuxtLink :to="to" class="staff-back">← {{ label }}</NuxtLink>
</template>
