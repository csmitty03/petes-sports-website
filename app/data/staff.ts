export type StaffRole = 'admin' | 'london' | 'strathroy' | 'newera' | 'view'

export type StaffLocation = 'london' | 'strathroy' | 'new_era' | 'in_transit' | 'customer'

export type StaffStatus =
  | 'draft'
  | 'order_confirmed'
  | 'waiting_on_blanks'
  | 'at_london'
  | 'at_strathroy'
  | 'sent_to_new_era'
  | 'at_new_era_received'
  | 'in_production'
  | 'ready_at_new_era'
  | 'in_transit_london'
  | 'in_transit_strathroy'
  | 'ready_pickup_london'
  | 'ready_pickup_strathroy'
  | 'picked_up'
  | 'shipped'
  | 'on_hold'

export type PickupRelationship = 'self' | 'parent' | 'teammate' | 'coach' | 'other'

export interface StaffProfile {
  id: string
  full_name: string
  role: StaffRole
}

export interface JobItem {
  style: string
  colour: string
  sizes: string
  qty: number
  decoration: string
}

export interface StaffOrder {
  id: string
  job_number: string
  new_era_job_number: string | null
  customer_name: string
  customer_phone: string | null
  customer_email: string | null
  team: string | null
  pickup_wanted: 'london' | 'strathroy' | null
  due_date: string | null
  items: JobItem[]
  blanks_start: string | null
  sold_by: string | null
  notes: string | null
  art_link: string | null
  status: StaffStatus
  current_location: StaffLocation
  created_by: string | null
  created_at: string
  updated_at: string
}

export interface StaffMovement {
  id: string
  order_id: string
  logged_by: string | null
  from_location: StaffLocation | null
  to_location: StaffLocation | null
  action: string
  notes: string | null
  created_at: string
  profiles?: { full_name: string } | null
}

export interface StaffPickup {
  id: string
  order_id: string
  released_by: string | null
  pickup_name: string
  pickup_phone: string | null
  relationship: PickupRelationship
  what_taken: string
  confirmed: boolean
  created_at: string
  profiles?: { full_name: string } | null
}

export interface StaffTransition {
  id: string
  label: string
  action: string
  toLocation: StaffLocation
  toStatus: StaffStatus
  roles: StaffRole[]
  fromLocations?: StaffLocation[]
  fromStatuses?: StaffStatus[]
}

export const locationLabels: Record<StaffLocation, string> = {
  london: "Pete's London — 900 Oxford St E",
  strathroy: "Pete's Strathroy — Gemini",
  new_era: 'New Era Grafix — 153 Towerline Pl',
  in_transit: 'In transit',
  customer: 'Customer',
}

export const shortLocationLabels: Record<StaffLocation, string> = {
  london: 'London',
  strathroy: 'Strathroy',
  new_era: 'New Era',
  in_transit: 'In transit',
  customer: 'Customer',
}

export const statusLabels: Record<StaffStatus, string> = {
  draft: 'Draft / quoted',
  order_confirmed: 'Order confirmed',
  waiting_on_blanks: 'Waiting on blanks',
  at_london: 'At London',
  at_strathroy: 'At Strathroy',
  sent_to_new_era: 'Sent to New Era',
  at_new_era_received: 'At New Era — received',
  in_production: 'In production',
  ready_at_new_era: 'Ready at New Era',
  in_transit_london: 'In transit to London',
  in_transit_strathroy: 'In transit to Strathroy',
  ready_pickup_london: 'Ready for pickup — London',
  ready_pickup_strathroy: 'Ready for pickup — Strathroy',
  picked_up: 'Picked up',
  shipped: 'Shipped to customer',
  on_hold: 'On hold / problem',
}

export const statusOptions = (Object.keys(statusLabels) as StaffStatus[]).map(value => ({
  value,
  label: statusLabels[value],
}))

export const locationOptions = (Object.keys(locationLabels) as StaffLocation[]).map(value => ({
  value,
  label: locationLabels[value],
}))

export const roleLabels: Record<StaffRole, string> = {
  admin: 'Admin',
  london: 'London staff',
  strathroy: 'Strathroy staff',
  newera: 'New Era',
  view: 'View only',
}

export const decorationOptions = ['Screen print', 'Embroidery', 'Heat press', 'Other'] as const

export const blanksOptions = [
  { value: 'london_stock', label: 'London stock' },
  { value: 'strathroy_stock', label: 'Strathroy stock' },
  { value: 'new_era_stock', label: 'New Era stock' },
  { value: 'order_in', label: 'Need to order in' },
] as const

export const relationshipOptions: { value: PickupRelationship; label: string }[] = [
  { value: 'self', label: 'Self (customer)' },
  { value: 'parent', label: 'Parent' },
  { value: 'teammate', label: 'Teammate' },
  { value: 'coach', label: 'Coach' },
  { value: 'other', label: 'Other' },
]

export const staffTransitions: StaffTransition[] = [
  {
    id: 'send_new_era',
    label: 'Send to New Era',
    action: 'signed_out',
    toLocation: 'in_transit',
    toStatus: 'sent_to_new_era',
    roles: ['admin', 'london', 'strathroy'],
    fromLocations: ['london', 'strathroy'],
  },
  {
    id: 'drop_new_era',
    label: 'Dropped at New Era',
    action: 'signed_in',
    toLocation: 'new_era',
    toStatus: 'sent_to_new_era',
    roles: ['admin', 'london', 'strathroy'],
    fromLocations: ['london', 'strathroy', 'in_transit'],
  },
  {
    id: 'receive_new_era',
    label: 'Receive at New Era',
    action: 'received',
    toLocation: 'new_era',
    toStatus: 'at_new_era_received',
    roles: ['admin', 'newera'],
    fromLocations: ['in_transit', 'new_era'],
    fromStatuses: ['sent_to_new_era'],
  },
  {
    id: 'in_production',
    label: 'In production',
    action: 'production',
    toLocation: 'new_era',
    toStatus: 'in_production',
    roles: ['admin', 'newera'],
    fromLocations: ['new_era'],
  },
  {
    id: 'ready_new_era',
    label: 'Ready at New Era',
    action: 'ready',
    toLocation: 'new_era',
    toStatus: 'ready_at_new_era',
    roles: ['admin', 'newera'],
    fromLocations: ['new_era'],
  },
  {
    id: 'out_to_london',
    label: 'Sign out to London',
    action: 'signed_out',
    toLocation: 'in_transit',
    toStatus: 'in_transit_london',
    roles: ['admin', 'newera', 'london', 'strathroy'],
    fromLocations: ['new_era', 'strathroy'],
  },
  {
    id: 'out_to_strathroy',
    label: 'Sign out to Strathroy',
    action: 'signed_out',
    toLocation: 'in_transit',
    toStatus: 'in_transit_strathroy',
    roles: ['admin', 'newera', 'london', 'strathroy'],
    fromLocations: ['new_era', 'london'],
  },
  {
    id: 'receive_london',
    label: 'Receive at London',
    action: 'received',
    toLocation: 'london',
    toStatus: 'ready_pickup_london',
    roles: ['admin', 'london'],
    fromLocations: ['in_transit', 'new_era', 'strathroy'],
  },
  {
    id: 'receive_strathroy',
    label: 'Receive at Strathroy',
    action: 'received',
    toLocation: 'strathroy',
    toStatus: 'ready_pickup_strathroy',
    roles: ['admin', 'strathroy'],
    fromLocations: ['in_transit', 'new_era', 'london'],
  },
  {
    id: 'hold',
    label: 'On hold / problem',
    action: 'hold',
    toLocation: 'london',
    toStatus: 'on_hold',
    roles: ['admin', 'london', 'strathroy', 'newera'],
  },
]

export function transitionsFor(order: StaffOrder, role: StaffRole) {
  if (role === 'view') return []
  if (order.status === 'picked_up' || order.status === 'shipped') return []

  return staffTransitions.filter((transition) => {
    if (!transition.roles.includes(role) && role !== 'admin') return false
    if (transition.fromLocations && !transition.fromLocations.includes(order.current_location)) return false
    if (transition.fromStatuses && !transition.fromStatuses.includes(order.status)) return false
    return true
  })
}

export function canCreateJobs(role: StaffRole) {
  return role === 'admin' || role === 'london' || role === 'strathroy'
}

export function canRecordPickup(role: StaffRole) {
  return role === 'admin' || role === 'london' || role === 'strathroy'
}

export function canManageUsers(role: StaffRole | string | null | undefined) {
  return String(role || '').trim().toLowerCase() === 'admin'
}

export function startingLocation(blanks: string | null, role: StaffRole): { location: StaffLocation; status: StaffStatus } {
  if (blanks === 'strathroy_stock') return { location: 'strathroy', status: 'at_strathroy' }
  if (blanks === 'new_era_stock') return { location: 'new_era', status: 'sent_to_new_era' }
  if (blanks === 'order_in') return { location: 'london', status: 'waiting_on_blanks' }
  if (role === 'strathroy') return { location: 'strathroy', status: 'at_strathroy' }
  return { location: 'london', status: 'at_london' }
}
