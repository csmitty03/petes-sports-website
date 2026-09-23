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
  runtimeConfig: {
    supabaseServiceRoleKey: (process.env.NUXT_SUPABASE_SERVICE_ROLE_KEY || '').trim().replace(/^["']|["']$/g, ''),
    public: {
      supabaseUrl: (process.env.NUXT_PUBLIC_SUPABASE_URL || '').trim().replace(/^["']|["']$/g, '').replace(/\/$/, ''),
      supabaseAnonKey: (process.env.NUXT_PUBLIC_SUPABASE_ANON_KEY || '').trim().replace(/^["']|["']$/g, ''),
    },
  },
  nitro: {
    prerender: {
      // Shop is a static public/shop/index.html (vanilla JS), not a Nuxt page.
      // Crawler still sees /shop links from the homepage — ignore those 404s.
      crawlLinks: true,
      routes: ['/', '/gemini'],
      failOnError: false,
      ignore: ['/shop', '/shop/', '/shop/**', '/staff', '/staff/**'],
    },
  },
  // Ensure static shop is never treated as a SPA fallback-only path
  routeRules: {
    '/shop/**': { prerender: false },
    '/staff/**': { ssr: false, prerender: false },
  },
})
