// https://nuxt.com/docs/api/configuration/nuxt-config
import { readFileSync, existsSync } from 'node:fs'
import { join } from 'node:path'

function productPrerenderRoutes(): string[] {
  try {
    const catalogPath = join(process.cwd(), 'public', 'data', 'catalog.json')
    if (!existsSync(catalogPath)) return []
    const catalog = JSON.parse(readFileSync(catalogPath, 'utf8')) as {
      products?: { id?: string }[]
    }
    return (catalog.products || [])
      .map((p) => p.id)
      .filter((id): id is string => Boolean(id))
      .map((id) => `/shop/${id}`)
  } catch {
    return []
  }
}

export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: ['@nuxtjs/tailwindcss'],
  css: ['~/assets/css/main.css'],
  tailwindcss: {
    exposeConfig: true,
  },
  app: {
    baseURL: (process.env.NUXT_APP_BASE_URL || '/').trim(),
    head: {
      htmlAttrs: { lang: 'en' },
      link: [
        { rel: 'icon', href: '/assets/petes-sports-logo.png', type: 'image/png' },
      ],
    },
  },
  nitro: {
    prerender: {
      crawlLinks: true,
      routes: ['/shop', ...productPrerenderRoutes()],
    },
  },
})
