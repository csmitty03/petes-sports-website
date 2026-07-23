<script setup lang="ts">
import { inquiries, type InquiryType } from '~/data/site'

const activeInquiry = ref<InquiryType>('sales')

const form = reactive({
  name: '',
  email: '',
  topic: '',
  message: '',
})

const inquiryOptions = Object.entries(inquiries).map(([key, value]) => ({
  key: key as InquiryType,
  ...value,
}))

const activeRecipient = computed(() => inquiries[activeInquiry.value])

function setInquiry(type: InquiryType) {
  activeInquiry.value = type
}

function handleSubmit() {
  const info = inquiries[activeInquiry.value]
  const subject = form.topic ? `${info.subject}: ${form.topic}` : info.subject
  const body = [
    `Name: ${form.name.trim()}`,
    `Reply-To: ${form.email.trim()}`,
    form.topic.trim() ? `Topic: ${form.topic.trim()}` : '',
    '',
    form.message.trim(),
  ].filter(Boolean).join('\n')

  window.location.href = `mailto:${info.email}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`
}
</script>

<template>
  <section id="contact" class="section contact">
    <div class="container">
      <RevealBlock class="section-header">
        <span class="section-label">Get in Touch</span>
        <h2 class="section-title">Let's talk</h2>
        <p class="section-desc">Choose who you'd like to reach and we'll get you to the right person.</p>
      </RevealBlock>

      <RevealBlock class="contact-wrapper">
        <form class="contact-form" @submit.prevent="handleSubmit">
          <div class="inquiry-tabs" role="tablist" aria-label="Inquiry type">
            <button
              v-for="option in inquiryOptions"
              :key="option.key"
              type="button"
              class="inquiry-tab"
              :class="{ active: activeInquiry === option.key }"
              role="tab"
              :aria-selected="activeInquiry === option.key"
              @click="setInquiry(option.key)"
            >
              {{ option.label }}
            </button>
          </div>

          <div class="inquiry-recipient">
            <span class="inquiry-recipient-label">Sending to:</span>
            <strong>{{ activeRecipient.name }}</strong>
            <a :href="`mailto:${activeRecipient.email}`">{{ activeRecipient.email }}</a>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="name">Full Name</label>
              <input id="name" v-model="form.name" type="text" name="name" placeholder="Your name" required>
            </div>
            <div class="form-group">
              <label for="email">Email Address</label>
              <input id="email" v-model="form.email" type="email" name="email" placeholder="you@email.com" required>
            </div>
          </div>

          <div class="form-group">
            <label for="topic">Topic</label>
            <input id="topic" v-model="form.topic" type="text" name="topic" placeholder="e.g. Teamwear quote, equipment question, store hours...">
          </div>

          <div class="form-group">
            <label for="message">Message</label>
            <textarea id="message" v-model="form.message" name="message" placeholder="Tell us about your team, order, or question..." required />
          </div>

          <button type="submit" class="btn btn-accent form-submit">Open Email to Send</button>
          <p class="form-note">This will open your email app addressed to the right team member. We usually reply within 1 business day.</p>
        </form>
      </RevealBlock>
    </div>
  </section>
</template>