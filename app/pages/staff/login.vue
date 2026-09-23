<script setup lang="ts">
import '~/assets/css/staff.css'

definePageMeta({
  layout: false,
  middleware: 'staff-guest',
})

useSeoMeta({
  title: "Staff login | Pete's Sports",
  robots: 'noindex, nofollow',
})

const { siteHref } = useSiteHref()
const { login, error } = useStaffAuth()
const email = ref('')
const password = ref('')
const busy = ref(false)

async function submit() {
  busy.value = true
  try {
    await login(email.value.trim(), password.value)
    await navigateTo('/staff/orders')
  }
  catch {
    busy.value = false
  }
}
</script>

<template>
  <div class="staff-login">
    <form class="staff-login-card staff-form" @submit.prevent="submit">
      <img :src="siteHref('/assets/petes-sports-logo.png')" alt="Pete's Sports">
      <h1>Staff login</h1>
      <p>Use the Netlify staff link your manager sent, then sign in with your own email.</p>
      <div v-if="!staffConfigured()" class="staff-setup">
        Staff login is not connected yet. Add the Supabase keys on Netlify, then create accounts.
      </div>
      <p v-if="error" class="staff-error">{{ error }}</p>
      <label for="staff-email">Email</label>
      <input id="staff-email" v-model="email" type="email" autocomplete="username" required>
      <label for="staff-password">Password</label>
      <input id="staff-password" v-model="password" type="password" autocomplete="current-password" required>
      <button class="staff-action accent" type="submit" :disabled="busy || !staffConfigured()">
        {{ busy ? 'Signing in…' : 'Sign in' }}
      </button>
    </form>
  </div>
</template>
