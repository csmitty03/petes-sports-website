// https://nuxt.com/docs/api/configuration/nuxt-config
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
      // Shop is a static public/shop/index.html (vanilla JS), not a Nuxt page.
      // Crawler still sees /shop links from the homepage — ignore those 404s.
      crawlLinks: true,
      routes: ['/'],
      failOnError: false,
      ignore: ['/shop', '/shop/', '/shop/**'],
    },
  },
  // Ensure static shop is never treated as a SPA fallback-only path
  routeRules: {
    '/shop/**': { prerender: false },
  },
})
