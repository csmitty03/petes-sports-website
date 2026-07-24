/** Resolve catalog image URLs (absolute CDN or local public path) with Nuxt baseURL. */
export function resolveProductImage(url: string | null | undefined): string | null {
  if (!url) return null
  if (/^https?:\/\//i.test(url)) return url
  if (url.includes('placeholder') || url.includes('no-image')) return null

  const config = useRuntimeConfig()
  const base = (config.app.baseURL || '/').replace(/\/?$/, '/')
  const path = url.replace(/^\//, '')
  return `${base}${path}`
}

export function isPlaceholderImage(url: string | null | undefined): boolean {
  if (!url) return true
  return /placeholder|no-image|no_image/i.test(url)
}
