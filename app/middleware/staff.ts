export default defineNuxtRouteMiddleware(async (to) => {
  if (to.path === '/staff/login') return

  const { ready, isLoggedIn, refresh } = useStaffAuth()
  if (!ready.value) await refresh()
  if (!staffConfigured()) return
  if (!isLoggedIn.value) return navigateTo('/staff/login')
})
