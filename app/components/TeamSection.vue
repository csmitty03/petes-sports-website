<script setup lang="ts">
import { managers as defaultManagers, salesReps as defaultSalesReps, type Person } from '~/data/site'

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
    </div>
  </section>
</template>