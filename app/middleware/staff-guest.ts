export default defineNuxtRouteMiddleware(async () => {
  const { ready, isLoggedIn, refresh } = useStaffAuth()
  if (!ready.value) await refresh()
  if (isLoggedIn.value) return navigateTo('/staff/orders')
})
