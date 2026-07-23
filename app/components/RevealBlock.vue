<script setup lang="ts">
const { element, isVisible } = useReveal()
</script>

<template>
  <div ref="element" class="reveal" :class="{ visible: isVisible }">
    <slot />
  </div>
</template>