<script setup lang="ts">
import { canManageUsers, roleLabels, type StaffProfile, type StaffRole } from '~/data/staff'

definePageMeta({
  layout: 'staff',
  middleware: 'staff',
})

useSeoMeta({ title: "Staff users | Pete's Sports", robots: 'noindex, nofollow' })

const { profile, refresh } = useStaffAuth()
await refresh()
if (!profile.value || !canManageUsers(profile.value.role)) {
  await navigateTo('/staff/orders')
}

const supabase = useSupabase()
const people = ref<StaffProfile[]>([])
const error = ref('')
const busy = ref(false)
const form = reactive({
  full_name: '',
  email: '',
  password: '',
  role: 'london' as StaffRole,
})

async function load() {
  if (!supabase) return
  const { data } = await supabase.from('profiles').select('id, full_name, role').order('full_name')
  people.value = (data || []) as StaffProfile[]
}

await load()

async function createUser() {
  if (!supabase) return
  busy.value = true
  error.value = ''
  try {
    const { data: sessionData } = await supabase.auth.getSession()
    const token = sessionData.session?.access_token
    if (!token) throw new Error('Sign in again to add accounts.')
    await $fetch('/api/staff/users', {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
      body: { ...form },
    })
    form.full_name = ''
    form.email = ''
    form.password = ''
    await load()
  }
  catch (err: unknown) {
    const fetchError = err as { data?: { statusMessage?: string }; message?: string }
    error.value = fetchError.data?.statusMessage || fetchError.message || 'Could not create user'
  }
  finally {
    busy.value = false
  }
}
</script>

<template>
  <div>
    <h2>Staff accounts</h2>
    <p>Give each person their own login. Do not share passwords.</p>
    <p v-if="error" class="staff-error">{{ error }}</p>
    <form class="staff-card staff-form" @submit.prevent="createUser">
      <label>Name</label>
      <input v-model="form.full_name" required>
      <label>Email</label>
      <input v-model="form.email" type="email" required>
      <label>Temporary password</label>
      <input v-model="form.password" type="text" minlength="8" required>
      <label>Role</label>
      <select v-model="form.role">
        <option value="admin">Admin</option>
        <option value="london">London staff</option>
        <option value="strathroy">Strathroy staff</option>
        <option value="newera">New Era</option>
        <option value="view">View only</option>
      </select>
      <button class="staff-action accent" type="submit" :disabled="busy">{{ busy ? 'Saving…' : 'Add account' }}</button>
    </form>
    <div v-for="person in people" :key="person.id" class="staff-card">
      <strong>{{ person.full_name }}</strong>
      <p>{{ roleLabels[person.role] }}</p>
    </div>
  </div>
</template>
