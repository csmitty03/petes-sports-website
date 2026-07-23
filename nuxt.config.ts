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
      // Product detail uses query ?id= on /shop/product (one static page)
      // so we do not prerender tens of thousands of product URLs.
      crawlLinks: true,
      routes: ['/shop', '/shop/product'],
    },
  },
})
