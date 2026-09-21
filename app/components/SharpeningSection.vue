<script setup lang="ts">
import { skateSharpening } from '~/data/site'
</script>

<template>
  <section id="sharpening" class="section sharpening-section">
    <div class="container">
      <div class="sharpening">
        <RevealBlock class="sharpening-card">
          <div class="sharpening-price">
            <span>{{ skateSharpening.price }}</span>
            <small>{{ skateSharpening.priceLabel }}</small>
          </div>
          <div class="sharpening-copy">
            <span class="section-label">In Store</span>
            <h3>{{ skateSharpening.title }}</h3>
            <p>{{ skateSharpening.intro }}</p>
            <ul>
              <li v-for="point in skateSharpening.points" :key="point">{{ point }}</li>
            </ul>
          </div>
        </RevealBlock>

        <RevealBlock class="sharpening-bundles">
          <div class="sharpening-bundles-header">
            <span class="section-label">{{ skateSharpening.cardsTitle }}</span>
            <h3>Skate Sharpening Cards</h3>
            <p>{{ skateSharpening.cardsIntro }}</p>
          </div>
          <div class="sharpening-bundles-grid">
            <div v-for="card in skateSharpening.cards" :key="card.label" class="sharpening-bundle">
              <span class="sharpening-bundle-label">{{ card.label }}</span>
              <strong>{{ card.price }}</strong>
              <small>{{ card.each }}</small>
            </div>
          </div>
        </RevealBlock>
      </div>
    </div>
  </section>
</template>
