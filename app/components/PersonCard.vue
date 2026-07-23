<script setup lang="ts">
import type { Person } from '~/data/site'

defineProps<{
  person: Person
  reveal?: boolean
}>()

const { element, isVisible } = useReveal()
</script>

<template>
  <div
    ref="element"
    class="manager-card"
    :class="{ lead: person.lead, reveal, visible: reveal && isVisible }"
  >
    <div class="manager-avatar">{{ person.initials }}</div>
    <h3>{{ person.name }}</h3>
    <p class="manager-role">{{ person.role }}</p>
    <p class="manager-location">{{ person.location }}</p>
    <a v-if="person.email" :href="`mailto:${person.email}`" class="manager-email">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75" />
      </svg>
      {{ person.email }}
    </a>
  </div>
</template>