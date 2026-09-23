import { createClient } from '@supabase/supabase-js'

const roles = ['admin', 'london', 'strathroy', 'newera', 'view'] as const

export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig()
  const url = String(config.public.supabaseUrl || '')
  const anon = String(config.public.supabaseAnonKey || '')
  const service = String(config.supabaseServiceRoleKey || '')
  if (!url || !anon || !service) {
    throw createError({ statusCode: 500, statusMessage: 'Staff database is not configured.' })
  }

  const authHeader = getHeader(event, 'authorization') || getHeader(event, 'Authorization') || ''
  const token = authHeader.replace(/^Bearer\s+/i, '') || getCookie(event, 'sb-access-token') || ''

  const body = await readBody<{ full_name?: string; email?: string; password?: string; role?: string }>(event)
  if (!body.full_name?.trim() || !body.email?.trim() || !body.password || !body.role || !roles.includes(body.role as typeof roles[number])) {
    throw createError({ statusCode: 400, statusMessage: 'Name, email, password, and role are required.' })
  }

  const userClient = createClient(url, anon, { global: { headers: token ? { Authorization: `Bearer ${token}` } : {} } })
  const { data: userData, error: userError } = await userClient.auth.getUser(token || undefined)
  if (userError || !userData.user) {
    throw createError({ statusCode: 401, statusMessage: 'Sign in as admin to add users.' })
  }

  const { data: profile } = await userClient.from('profiles').select('role').eq('id', userData.user.id).maybeSingle()
  if (profile?.role !== 'admin') {
    throw createError({ statusCode: 403, statusMessage: 'Only admin can add staff accounts.' })
  }

  const admin = createClient(url, service)
  const { data: created, error: createError } = await admin.auth.admin.createUser({
    email: body.email.trim(),
    password: body.password,
    email_confirm: true,
    user_metadata: { full_name: body.full_name.trim() },
  })
  if (createError || !created.user) {
    throw createError({ statusCode: 400, statusMessage: createError?.message || 'Could not create login.' })
  }

  const { error: profileError } = await admin.from('profiles').insert({
    id: created.user.id,
    full_name: body.full_name.trim(),
    role: body.role,
  })
  if (profileError) {
    throw createError({ statusCode: 400, statusMessage: profileError.message })
  }

  return { ok: true }
})
