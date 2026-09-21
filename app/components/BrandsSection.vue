<script setup lang="ts">
import { brandGroups } from '~/data/site'

const { siteHref } = useSiteHref()
</script>

<template>
  <section id="brands" class="section brands">
    <div class="container">
      <RevealBlock class="section-header">
        <span class="section-label">Brands</span>
        <h2 class="section-title">The names we carry</h2>
        <p class="section-desc">Some of our main hockey, baseball, and apparel brands. Ask the staff if you need something you don't see here.</p>
      </RevealBlock>

      <div class="brands-groups">
        <RevealBlock v-for="group in brandGroups" :key="group.label" class="brands-group">
          <h3>{{ group.label }}</h3>
          <div class="brands-list">
            <div v-for="brand in group.brands" :key="`${group.label}-${brand.name}`" class="brand-item">
              <div v-if="brand.logo" class="brand-logo">
                <img :src="siteHref(brand.logo)" :alt="`${brand.name} logo`">
              </div>
              <span>{{ brand.name }}</span>
            </div>
          </div>
        </RevealBlock>
      </div>
    </div>
  </section>
</template>
