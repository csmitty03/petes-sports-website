<script setup lang="ts">
import '~/assets/css/staff.css'
import { roleLabels } from '~/data/staff'

const { profile, isLoggedIn, logout } = useStaffAuth()
const { siteHref } = useSiteHref()
</script>

<template>
  <div class="staff-shell">
    <header class="staff-top">
      <NuxtLink to="/staff/orders" class="staff-brand">
        <img :src="siteHref('/assets/petes-sports-logo.png')" alt="Pete's Sports">
        Staff
      </NuxtLink>
      <div v-if="isLoggedIn" class="staff-user">
        <span>{{ profile?.full_name }} · {{ profile ? roleLabels[profile.role] : '' }}</span>
        <button type="button" @click="logout">Log out</button>
      </div>
    </header>
    <nav v-if="isLoggedIn" class="staff-nav">
      <NuxtLink to="/staff/orders">Orders</NuxtLink>
      <NuxtLink v-if="profile && (profile.role === 'admin' || profile.role === 'london' || profile.role === 'strathroy')" to="/staff/orders/new">New job</NuxtLink>
      <NuxtLink v-if="profile?.role === 'admin'" to="/staff/users">Users</NuxtLink>
    </nav>
    <main class="staff-main">
      <slot />
    </main>
  </div>
</template>
