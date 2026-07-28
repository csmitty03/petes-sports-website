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
      // Shop is a static public/shop/index.html (vanilla JS) so it is not
      // overwritten by a Nuxt route. Do not prerender /shop here.
      crawlLinks: true,
      routes: ['/'],
    },
  },
})
