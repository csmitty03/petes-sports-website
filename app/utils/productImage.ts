/**
 * Resolve catalog image URLs for GitHub Pages (baseURL /petes-sports-website/).
 * - Absolute http(s) CDN URLs pass through
 * - Placeholder Lightspeed images → null (show branded placeholder UI)
 * - Local paths like assets/products/x.jpg → prefixed with baseURL
 */
export function resolveProductImage(url: string | null | undefined): string | null {
  if (!url) return null
  const trimmed = String(url).trim()
  if (!trimmed) return null

  if (/^https?:\/\//i.test(trimmed)) {
    if (/placeholder|no-image|no_image/i.test(trimmed)) return null
    return trimmed
  }

  if (/placeholder|no-image|no_image/i.test(trimmed)) return null

  const config = useRuntimeConfig()
  const base = (config.app.baseURL || '/').replace(/\/?$/, '/')
  const path = trimmed.replace(/^\//, '')
  // Avoid double base if path already includes it
  if (path.startsWith(base.replace(/^\//, '')) || path.startsWith('petes-sports-website/')) {
    return path.startsWith('/') ? path : `/${path}`
  }
  return `${base}${path}`
}

export function isPlaceholderImage(url: string | null | undefined): boolean {
  if (!url) return true
  return /placeholder|no-image|no_image/i.test(String(url))
}
