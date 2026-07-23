<script setup lang="ts">
import { managers, salesReps } from '~/data/site'
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
        <PersonCard v-for="person in managers" :key="person.email ?? person.name" :person="person" reveal />
      </div>

      <RevealBlock class="team-divider" />

      <RevealBlock class="section-header">
        <span class="section-label">Main Store</span>
        <h2 class="section-title">Meet the Sales Reps</h2>
        <p class="section-desc">Our London store team is here to help you find the right gear.</p>
      </RevealBlock>

      <div class="sales-reps-grid">
        <PersonCard v-for="person in salesReps" :key="person.name" :person="person" reveal />
      </div>
    </div>
  </section>
</template>