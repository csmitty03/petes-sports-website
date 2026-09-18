<script setup lang="ts">
import { managers as defaultManagers, salesReps as defaultSalesReps, staffInbox, type Person } from '~/data/site'

const props = withDefaults(defineProps<{
  managers?: Person[]
  salesReps?: Person[]
  salesLabel?: string
  salesTitle?: string
  salesDesc?: string
}>(), {
  salesLabel: 'Main Store',
  salesTitle: 'Meet the Sales Reps',
  salesDesc: "Our London store team is here to help you find the right gear.",
})

const teamManagers = computed(() => props.managers ?? defaultManagers)
const teamSalesReps = computed(() => props.salesReps ?? defaultSalesReps)
</script>

<template>
  <section id="managers" class="section managers">
    <div class="container">
      <RevealBlock class="section-header">
        <span class="section-label">Leadership</span>
        <h2 class="section-title">Meet the Managers</h2>
        <p class="section-desc">Pete's Sports is under new ownership and management. Get to know the team leading the way forward.</p>
      </RevealBlock>

      <div class="managers-grid">
        <PersonCard v-for="person in teamManagers" :key="person.email ?? person.name" :person="person" reveal />
      </div>

      <RevealBlock class="team-divider" />

      <RevealBlock class="section-header">
        <span class="section-label">{{ salesLabel }}</span>
        <h2 class="section-title">{{ salesTitle }}</h2>
        <p class="section-desc">{{ salesDesc }}</p>
      </RevealBlock>

      <div class="sales-reps-grid">
        <PersonCard v-for="person in teamSalesReps" :key="person.name" :person="person" reveal />
      </div>

      <RevealBlock id="ask-staff" class="ask-staff">
        <h3>{{ staffInbox.title }}</h3>
        <p>{{ staffInbox.description }}</p>
        <a :href="`mailto:${staffInbox.email}`" class="manager-email">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75" />
          </svg>
          {{ staffInbox.email }}
        </a>
      </RevealBlock>
    </div>
  </section>
</template>