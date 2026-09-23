import { createClient, type SupabaseClient } from '@supabase/supabase-js'

let browserClient: SupabaseClient | null = null

export function staffConfigured() {
  const config = useRuntimeConfig()
  return Boolean(config.public.supabaseUrl && config.public.supabaseAnonKey)
}

export function useSupabase() {
  const config = useRuntimeConfig()
  const url = String(config.public.supabaseUrl || '').trim().replace(/^["']|["']$/g, '').replace(/\/$/, '')
  const key = String(config.public.supabaseAnonKey || '').trim().replace(/^["']|["']$/g, '')

  if (!url || !key) return null

  if (import.meta.server) {
    return createClient(url, key, {
      auth: { persistSession: false, autoRefreshToken: false },
    })
  }

  if (!browserClient) {
    browserClient = createClient(url, key, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true,
      },
    })
  }

  return browserClient
}
