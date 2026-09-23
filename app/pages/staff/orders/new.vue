<script setup lang="ts">
import { blanksOptions, canCreateJobs, decorationOptions, startingLocation, type JobItem } from '~/data/staff'

definePageMeta({
  layout: 'staff',
  middleware: 'staff',
})

useSeoMeta({ title: "New job | Pete's Sports", robots: 'noindex, nofollow' })

const { profile, refresh } = useStaffAuth()
await refresh()
if (!profile.value || !canCreateJobs(profile.value.role)) {
  await navigateTo('/staff/orders')
}

const supabase = useSupabase()
const error = ref('')
const busy = ref(false)
const form = reactive({
  customer_name: '',
  customer_phone: '',
  customer_email: '',
  team: '',
  pickup_wanted: 'london' as 'london' | 'strathroy',
  due_date: '',
  new_era_job_number: '',
  blanks_start: 'london_stock',
  notes: '',
  art_link: '',
})
const items = ref<JobItem[]>([{ style: '', colour: '', sizes: '', qty: 1, decoration: 'Embroidery' }])

function addItem() {
  items.value.push({ style: '', colour: '', sizes: '', qty: 1, decoration: 'Embroidery' })
}

async function submit() {
  if (!supabase || !profile.value) return
  busy.value = true
  error.value = ''
  try {
    const { data: numberData, error: numberError } = await supabase.rpc('next_job_number')
    if (numberError) throw numberError
    const start = startingLocation(form.blanks_start, profile.value.role)
    const { data, error: insertError } = await supabase.from('orders').insert({
      job_number: numberData,
      new_era_job_number: form.new_era_job_number || null,
      customer_name: form.customer_name.trim(),
      customer_phone: form.customer_phone.trim() || null,
      customer_email: form.customer_email.trim() || null,
      team: form.team.trim() || null,
      pickup_wanted: form.pickup_wanted,
      due_date: form.due_date || null,
      items: items.value.filter(item => item.style || item.qty),
      blanks_start: form.blanks_start,
      sold_by: profile.value.full_name,
      notes: form.notes.trim() || null,
      art_link: form.art_link.trim() || null,
      status: start.status,
      current_location: start.location,
      created_by: profile.value.id,
    }).select('id').single()
    if (insertError) throw insertError
    await supabase.from('movements').insert({
      order_id: data.id,
      logged_by: profile.value.id,
      from_location: null,
      to_location: start.location,
      action: 'created',
      notes: 'Job opened',
    })
    await navigateTo(`/staff/orders/${data.id}`)
  }
  catch (err) {
    error.value = err instanceof Error ? err.message : 'Could not create job'
    busy.value = false
  }
}
</script>

<template>
  <form class="staff-form" @submit.prevent="submit">
    <StaffBack />
    <h2>New job</h2>
    <p v-if="error" class="staff-error">{{ error }}</p>
    <div class="staff-grid-2">
      <div>
        <label>Customer name</label>
        <input v-model="form.customer_name" required>
      </div>
      <div>
        <label>Phone</label>
        <input v-model="form.customer_phone" type="tel">
      </div>
      <div>
        <label>Email</label>
        <input v-model="form.customer_email" type="email">
      </div>
      <div>
        <label>Team / association</label>
        <input v-model="form.team" placeholder="Bluewater Hawks">
      </div>
      <div>
        <label>Pickup location wanted</label>
        <select v-model="form.pickup_wanted">
          <option value="london">London</option>
          <option value="strathroy">Strathroy</option>
        </select>
      </div>
      <div>
        <label>Needed by</label>
        <input v-model="form.due_date" type="date">
      </div>
      <div>
        <label>Where blanks start</label>
        <select v-model="form.blanks_start">
          <option v-for="option in blanksOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
        </select>
      </div>
      <div>
        <label>New Era job #</label>
        <input v-model="form.new_era_job_number">
      </div>
    </div>

    <h3>Items</h3>
    <div v-for="(item, index) in items" :key="index" class="staff-card">
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
          <input v-model="item.sizes" placeholder="YTH M, AD L x2">
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
    <button type="button" class="staff-action light" @click="addItem">Add another item</button>

    <label>Art file link</label>
    <input v-model="form.art_link" placeholder="https://">
    <label>Notes</label>
    <textarea v-model="form.notes" rows="3" />
    <button class="staff-action accent" type="submit" :disabled="busy">{{ busy ? 'Saving…' : 'Create job' }}</button>
  </form>
</template>
