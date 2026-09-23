<script setup lang="ts">
import { canCreateJobs, canManageUsers, shortLocationLabels, statusLabels, type StaffOrder, type StaffStatus } from '~/data/staff'

definePageMeta({
  layout: 'staff',
  middleware: 'staff',
})

useSeoMeta({ title: "Staff orders | Pete's Sports", robots: 'noindex, nofollow' })

const { profile, refresh } = useStaffAuth()
await refresh()

const supabase = useSupabase()
const orders = ref<StaffOrder[]>([])
const query = ref('')
const filter = ref('open')
const loadError = ref('')

const filters = [
  { id: 'open', label: 'Open' },
  { id: 'new_era', label: 'At New Era' },
  { id: 'ready', label: 'Ready for pickup' },
  { id: 'transit', label: 'In transit' },
  { id: 'all', label: 'All' },
]

async function load() {
  if (!supabase) return
  const { data, error } = await supabase
    .from('orders')
    .select('*')
    .order('updated_at', { ascending: false })
  if (error) loadError.value = error.message
  else orders.value = (data || []) as StaffOrder[]
}

await load()

const visible = computed(() => {
  const q = query.value.trim().toLowerCase()
  return orders.value.filter((order) => {
    if (filter.value === 'open' && ['picked_up', 'shipped'].includes(order.status)) return false
    if (filter.value === 'new_era' && !['sent_to_new_era', 'at_new_era_received', 'in_production', 'ready_at_new_era'].includes(order.status)) return false
    if (filter.value === 'ready' && !['ready_pickup_london', 'ready_pickup_strathroy', 'ready_at_new_era'].includes(order.status)) return false
    if (filter.value === 'transit' && order.current_location !== 'in_transit') return false
    if (!q) return true
    return [order.job_number, order.customer_name, order.team, order.customer_phone]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
      .includes(q)
  })
})

function pillClass(status: StaffStatus) {
  if (status.startsWith('ready')) return 'ready'
  if (status === 'on_hold' || status === 'waiting_on_blanks') return 'warn'
  return ''
}
</script>

<template>
  <div>
    <div class="staff-toolbar">
      <input v-model="query" type="search" placeholder="Search job #, customer, team, phone">
      <select v-model="filter">
        <option v-for="item in filters" :key="item.id" :value="item.id">{{ item.label }}</option>
      </select>
      <NuxtLink v-if="profile && canCreateJobs(profile.role)" to="/staff/orders/new" class="staff-action accent" style="min-width: 140px; text-align: center;">New job</NuxtLink>
      <NuxtLink v-if="profile && canManageUsers(profile.role)" to="/staff/users" class="staff-action light" style="min-width: 140px; text-align: center;">Users</NuxtLink>
    </div>
    <p v-if="loadError" class="staff-error">{{ loadError }}</p>
    <p v-else-if="!visible.length">No jobs match this view.</p>
    <NuxtLink v-for="order in visible" :key="order.id" :to="`/staff/orders/${order.id}`" class="staff-card">
      <h3>{{ order.job_number }} · {{ order.customer_name }}</h3>
      <p>{{ order.team || 'No team' }}</p>
      <div class="staff-meta">
        <span class="staff-pill" :class="pillClass(order.status)">{{ statusLabels[order.status] }}</span>
        <span class="staff-pill">{{ shortLocationLabels[order.current_location] }}</span>
      </div>
    </NuxtLink>
  </div>
</template>
