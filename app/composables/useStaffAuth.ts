import type { StaffProfile, StaffRole } from '~/data/staff'

export function useStaffAuth() {
  const supabase = useSupabase()
  const user = useState<null | { id: string; email?: string }>('staff-user', () => null)
  const profile = useState<StaffProfile | null>('staff-profile', () => null)
  const ready = useState('staff-auth-ready', () => false)
  const error = useState<string>('staff-auth-error', () => '')

  const role = computed<StaffRole | null>(() => profile.value?.role ?? null)
  const isLoggedIn = computed(() => Boolean(user.value && profile.value))

  async function loadProfile(userId: string) {
    if (!supabase) return
    const { data, error: queryError } = await supabase
      .from('profiles')
      .select('id, full_name, role')
      .eq('id', userId)
      .maybeSingle()

    if (queryError) throw queryError
    profile.value = data as StaffProfile | null
  }

  async function refresh() {
    if (!supabase) {
      ready.value = true
      return
    }
    const { data } = await supabase.auth.getSession()
    const sessionUser = data.session?.user
    user.value = sessionUser ? { id: sessionUser.id, email: sessionUser.email } : null
    if (sessionUser) await loadProfile(sessionUser.id)
    else profile.value = null
    ready.value = true
  }

  async function login(email: string, password: string) {
    if (!supabase) throw new Error('Staff login is not configured yet.')
    error.value = ''
    const { data, error: authError } = await supabase.auth.signInWithPassword({ email, password })
    if (authError) {
      error.value = authError.message === 'Failed to fetch'
        ? 'Cannot reach the staff database. Check the Supabase project URL on Netlify, and that the project is not paused.'
        : authError.message
      throw authError
    }
    user.value = data.user ? { id: data.user.id, email: data.user.email } : null
    if (data.user) await loadProfile(data.user.id)
  }

  async function logout() {
    if (supabase) await supabase.auth.signOut()
    user.value = null
    profile.value = null
    await navigateTo('/staff/login')
  }

  return { user, profile, role, ready, error, isLoggedIn, refresh, login, logout }
}
