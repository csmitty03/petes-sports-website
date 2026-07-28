/**
 * Build absolute-on-site hrefs that include the GitHub Pages baseURL
 * and force a full browser navigation (important for static /shop/).
 */
export function useSiteHref() {
  const config = useRuntimeConfig()

  function siteHref(path: string) {
    if (!path) return path
    if (/^(https?:|mailto:|tel:)/i.test(path)) return path
    // In-page hash links stay as-is on the homepage SPA
    if (path.startsWith('#')) return path
    if (path.startsWith('/#')) return path

    const base = (config.app.baseURL || '/').replace(/\/?$/, '/')
    const clean = path.replace(/^\//, '')
    return `${base}${clean}`
  }

  const shopHref = computed(() => siteHref('/shop/'))

  return { siteHref, shopHref }
}
