/**
 * Build absolute-on-site hrefs that include the GitHub Pages baseURL
 * and force a full browser navigation (important for static /shop/).
 */
export function useSiteHref() {
  const config = useRuntimeConfig()

  function siteHref(path: string) {
    if (!path) return path
    if (/^(https?:|mailto:|tel:)/i.test(path)) return path

    const base = (config.app.baseURL || '/').replace(/\/?$/, '/')

    // In-page hash links stay as-is
    if (path.startsWith('#')) return path
    // Homepage section links need the GitHub Pages base path
    if (path.startsWith('/#')) return `${base}${path.slice(1)}`

    const clean = path.replace(/^\//, '')
    return `${base}${clean}`
  }

  const shopHref = computed(() => siteHref('/shop/'))
  const geminiHref = computed(() => siteHref('/gemini/'))

  return { siteHref, shopHref, geminiHref }
}
