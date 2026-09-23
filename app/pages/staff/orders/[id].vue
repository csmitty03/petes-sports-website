<script setup lang="ts">
import {
  blanksOptions,
  canManageUsers,
  canRecordPickup,
  decorationOptions,
  locationLabels,
  locationOptions,
  relationshipOptions,
  shortLocationLabels,
  statusLabels,
  statusOptions,
  transitionsFor,
  type JobItem,
  type PickupRelationship,
  type StaffLocation,
  type StaffMovement,
  type StaffOrder,
  type StaffPickup,
  type StaffStatus,
  type StaffTransition,
} from '~/data/staff'

definePageMeta({
  layout: 'staff',
  middleware: 'staff',
})

const route = useRoute()
const { profile, refresh } = useStaffAuth()
await refresh()
const supabase = useSupabase()

const order = ref<StaffOrder | null>(null)
const movements = ref<StaffMovement[]>([])
const pickups = ref<StaffPickup[]>([])
const error = ref('')
const notes = ref('')
const showPickup = ref(false)
const showEdit = ref(false)
const savingEdit = ref(false)
const edit = reactive({
  customer_name: '',
  customer_phone: '',
  customer_email: '',
  team: '',
  pickup_wanted: 'london' as 'london' | 'strathroy',
  due_date: '',
  new_era_job_number: '',
  sold_by: '',
  blanks_start: 'london_stock',
  notes: '',
  art_link: '',
  status: 'at_london' as StaffStatus,
  current_location: 'london' as StaffLocation,
})
const editItems = ref<JobItem[]>([])
const isAdmin = computed(() => Boolean(profile.value && canManageUsers(profile.value.role)))
const pickup = reactive({
  pickup_name: '',
  pickup_phone: '',
  relationship: 'self' as PickupRelationship,
  what_taken: 'Full order',
})

useSeoMeta({
  title: computed(() => order.value ? `${order.value.job_number} | Pete's Sports staff` : "Job | Pete's Sports"),
  robots: 'noindex, nofollow',
})

const actions = computed(() => {
  if (!order.value || !profile.value) return []
  return transitionsFor(order.value, profile.value.role)
})

async function load() {
  if (!supabase) return
  const id = String(route.params.id)
  const [{ data: orderData, error: orderError }, { data: movementData }, { data: pickupData }] = await Promise.all([
    supabase.from('orders').select('*').eq('id', id).single(),
    supabase.from('movements').select('*, profiles!logged_by(full_name)').eq('order_id', id).order('created_at', { ascending: false }),
    supabase.from('pickups').select('*, profiles!released_by(full_name)').eq('order_id', id).order('created_at', { ascending: false }),
  ])
  if (orderError) error.value = orderError.message
  order.value = orderData as StaffOrder | null
  movements.value = (movementData || []) as StaffMovement[]
  pickups.value = (pickupData || []) as StaffPickup[]
}

function openEdit() {
  if (!order.value) return
  edit.customer_name = order.value.customer_name
  edit.customer_phone = order.value.customer_phone || ''
  edit.customer_email = order.value.customer_email || ''
  edit.team = order.value.team || ''
  edit.pickup_wanted = order.value.pickup_wanted || 'london'
  edit.due_date = order.value.due_date || ''
  edit.new_era_job_number = order.value.new_era_job_number || ''
  edit.sold_by = order.value.sold_by || ''
  edit.blanks_start = order.value.blanks_start || 'london_stock'
  edit.notes = order.value.notes || ''
  edit.art_link = order.value.art_link || ''
  edit.status = order.value.status
  edit.current_location = order.value.current_location
  editItems.value = (order.value.items || []).map(item => ({ ...item }))
  if (!editItems.value.length) editItems.value.push({ style: '', colour: '', sizes: '', qty: 1, decoration: 'Embroidery' })
  showEdit.value = true
}

async function saveEdit() {
  if (!supabase || !order.value || !profile.value) return
  savingEdit.value = true
  error.value = ''
  const { error: updateError } = await supabase.from('orders').update({
    customer_name: edit.customer_name.trim(),
    customer_phone: edit.customer_phone.trim() || null,
    customer_email: edit.customer_email.trim() || null,
    team: edit.team.trim() || null,
    pickup_wanted: edit.pickup_wanted,
    due_date: edit.due_date || null,
    new_era_job_number: edit.new_era_job_number.trim() || null,
    sold_by: edit.sold_by.trim() || null,
    blanks_start: edit.blanks_start,
    notes: edit.notes.trim() || null,
    art_link: edit.art_link.trim() || null,
    status: edit.status,
    current_location: edit.current_location,
    items: editItems.value.filter(item => item.style || item.qty),
  }).eq('id', order.value.id)
  if (updateError) {
    error.value = updateError.message
    savingEdit.value = false
    return
  }
  await supabase.from('movements').insert({
    order_id: order.value.id,
    logged_by: profile.value.id,
    from_location: order.value.current_location,
    to_location: edit.current_location,
    action: 'corrected',
    notes: `Admin edit. Status set to ${statusLabels[edit.status]}. Location set to ${shortLocationLabels[edit.current_location]}.`,
  })
  showEdit.value = false
  savingEdit.value = false
  await load()
}

await load()

async function apply(transition: StaffTransition) {
  if (!supabase || !order.value || !profile.value) return
  error.value = ''
  const toLocation = transition.id === 'hold' ? order.value.current_location : transition.toLocation
  const { error: moveError } = await supabase.from('movements').insert({
    order_id: order.value.id,
    logged_by: profile.value.id,
    from_location: order.value.current_location,
    to_location: toLocation,
    action: transition.action,
    notes: notes.value.trim() || transition.label,
  })
  if (moveError) {
    error.value = moveError.message
    return
  }
  const { error: updateError } = await supabase.from('orders').update({
    status: transition.toStatus,
    current_location: toLocation,
  }).eq('id', order.value.id)
  if (updateError) {
    error.value = updateError.message
    return
  }
  notes.value = ''
  await load()
}

async function recordPickup() {
  if (!supabase || !order.value || !profile.value) return
  error.value = ''
  const { error: pickupError } = await supabase.from('pickups').insert({
    order_id: order.value.id,
    released_by: profile.value.id,
    pickup_name: pickup.pickup_name.trim(),
    pickup_phone: pickup.pickup_phone.trim() || null,
    relationship: pickup.relationship,
    what_taken: pickup.what_taken.trim(),
    confirmed: true,
  })
  if (pickupError) {
    error.value = pickupError.message
    return
  }
  await supabase.from('movements').insert({
    order_id: order.value.id,
    logged_by: profile.value.id,
    from_location: order.value.current_location,
    to_location: 'customer',
    action: 'picked_up',
    notes: `Picked up by ${pickup.pickup_name.trim()} (${pickup.relationship})`,
  })
  await supabase.from('orders').update({
    status: 'picked_up',
    current_location: 'customer',
  }).eq('id', order.value.id)
  showPickup.value = false
  await load()
}

function when(value: string) {
  return new Date(value).toLocaleString('en-CA', { timeZone: 'America/Toronto' })
}
</script>

<template>
  <div v-if="order">
    <StaffBack />
    <h2>{{ order.job_number }}</h2>
    <p>{{ order.customer_name }} · {{ order.customer_phone || 'No phone' }}</p>
    <div class="staff-meta">
      <span class="staff-pill ready">{{ statusLabels[order.status] }}</span>
      <span class="staff-pill">{{ locationLabels[order.current_location] }}</span>
    </div>
    <p v-if="error" class="staff-error">{{ error }}</p>

    <div v-if="actions.length || (profile && canRecordPickup(profile.role) && order.status.startsWith('ready_pickup'))" class="staff-card">
      <label>Movement note</label>
      <input v-model="notes" placeholder="Box count, who is driving, left at receiving…">
      <div class="staff-actions">
        <button
          v-for="action in actions"
          :key="action.id"
          type="button"
          class="staff-action"
          :class="{ accent: action.id.includes('ready') || action.id.includes('receive') }"
          @click="apply(action)"
        >
          {{ action.label }}
        </button>
        <button
          v-if="profile && canRecordPickup(profile.role) && (order.status.startsWith('ready_pickup') || order.current_location === 'london' || order.current_location === 'strathroy')"
          type="button"
          class="staff-action accent"
          @click="showPickup = true"
        >
          Customer pickup
        </button>
        <button v-if="isAdmin" type="button" class="staff-action light" @click="openEdit">
          Edit job
        </button>
      </div>
    </div>
    <button v-else-if="isAdmin" type="button" class="staff-action light" style="margin: 16px 0;" @click="openEdit">
      Edit job
    </button>

    <form v-if="showPickup" class="staff-card staff-form" @submit.prevent="recordPickup">
      <h3>Who is picking this up?</h3>
      <p>If it is not the person on the order, get a name and number before it leaves the counter.</p>
      <label>Name of person picking up</label>
      <input v-model="pickup.pickup_name" required>
      <label>Phone</label>
      <input v-model="pickup.pickup_phone" type="tel">
      <label>Relationship</label>
      <select v-model="pickup.relationship">
        <option v-for="option in relationshipOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
      </select>
      <label>What they took</label>
      <input v-model="pickup.what_taken" required>
      <button class="staff-action accent" type="submit">I confirm this person took the order</button>
      <button class="staff-action light" type="button" @click="showPickup = false">Cancel</button>
    </form>

    <form v-if="showEdit && isAdmin" class="staff-card staff-form" @submit.prevent="saveEdit">
      <h3>Edit job</h3>
      <p>Use this to fix a mistake. The change is saved in the history.</p>
      <div class="staff-grid-2">
        <div>
          <label>Customer name</label>
          <input v-model="edit.customer_name" required>
        </div>
        <div>
          <label>Phone</label>
          <input v-model="edit.customer_phone" type="tel">
        </div>
        <div>
          <label>Email</label>
          <input v-model="edit.customer_email" type="email">
        </div>
        <div>
          <label>Team / association</label>
          <input v-model="edit.team">
        </div>
        <div>
          <label>Pickup wanted</label>
          <select v-model="edit.pickup_wanted">
            <option value="london">London</option>
            <option value="strathroy">Strathroy</option>
          </select>
        </div>
        <div>
          <label>Needed by</label>
          <input v-model="edit.due_date" type="date">
        </div>
        <div>
          <label>New Era job #</label>
          <input v-model="edit.new_era_job_number">
        </div>
        <div>
          <label>Sold by</label>
          <input v-model="edit.sold_by">
        </div>
        <div>
          <label>Where blanks started</label>
          <select v-model="edit.blanks_start">
            <option v-for="option in blanksOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
          </select>
        </div>
        <div>
          <label>Status</label>
          <select v-model="edit.status">
            <option v-for="option in statusOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
          </select>
        </div>
        <div>
          <label>Current location</label>
          <select v-model="edit.current_location">
            <option v-for="option in locationOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
          </select>
        </div>
      </div>
      <h3>Items</h3>
      <div v-for="(item, index) in editItems" :key="index" class="staff-card">
        <div class="staff-grid-2">
          <div>
            <label>Style</label>
            <input v-model="item.style">
          </div>
          <div>
            <label>Colour</label>
            <input v-model="item.colour">
          </div>
          <div>
            <label>Sizes</label>
            <input v-model="item.sizes">
          </div>
          <div>
            <label>Qty</label>
            <input v-model.number="item.qty" type="number" min="1">
          </div>
          <div>
            <label>Decoration</label>
            <select v-model="item.decoration">
              <option v-for="option in decorationOptions" :key="option" :value="option">{{ option }}</option>
            </select>
          </div>
        </div>
      </div>
      <button type="button" class="staff-action light" @click="editItems.push({ style: '', colour: '', sizes: '', qty: 1, decoration: 'Embroidery' })">Add item</button>
      <label>Art file link</label>
      <input v-model="edit.art_link">
      <label>Notes</label>
      <textarea v-model="edit.notes" rows="3" />
      <button class="staff-action accent" type="submit" :disabled="savingEdit">{{ savingEdit ? 'Saving…' : 'Save correction' }}</button>
      <button class="staff-action light" type="button" @click="showEdit = false">Cancel</button>
    </form>

    <div class="staff-card">
      <h3>Job details</h3>
      <p><strong>Team:</strong> {{ order.team || '—' }}</p>
      <p><strong>Pickup wanted:</strong> {{ order.pickup_wanted || '—' }}</p>
      <p><strong>Needed by:</strong> {{ order.due_date || '—' }}</p>
      <p><strong>Sold by:</strong> {{ order.sold_by || '—' }}</p>
      <p><strong>New Era #:</strong> {{ order.new_era_job_number || '—' }}</p>
      <p v-if="order.art_link"><a :href="order.art_link" target="_blank" rel="noopener">Art file</a></p>
      <p v-if="order.notes">{{ order.notes }}</p>
      <ul>
        <li v-for="(item, index) in order.items" :key="index">
          {{ item.qty }} × {{ item.style }} {{ item.colour }} ({{ item.sizes }}) — {{ item.decoration }}
        </li>
      </ul>
    </div>

    <h3>History</h3>
    <ol class="staff-history">
      <li v-for="move in movements" :key="move.id">
        <time>{{ when(move.created_at) }}</time>
        <strong>{{ move.profiles?.full_name || 'Staff' }}</strong>
        — {{ move.action.replace('_', ' ') }}
        <span v-if="move.from_location && move.to_location">
          · {{ shortLocationLabels[move.from_location] }} → {{ shortLocationLabels[move.to_location] }}
        </span>
        <p v-if="move.notes">{{ move.notes }}</p>
      </li>
    </ol>

    <div v-if="pickups.length">
      <h3>Pickups</h3>
      <div v-for="entry in pickups" :key="entry.id" class="staff-card">
        <p><strong>{{ entry.pickup_name }}</strong> ({{ entry.relationship }}) took {{ entry.what_taken }}</p>
        <p>{{ entry.pickup_phone || 'No phone' }} · released by {{ entry.profiles?.full_name || 'staff' }}</p>
        <time>{{ when(entry.created_at) }}</time>
      </div>
    </div>
  </div>
  <p v-else-if="error" class="staff-error">{{ error }}</p>
  <p v-else>Loading job…</p>
</template>
