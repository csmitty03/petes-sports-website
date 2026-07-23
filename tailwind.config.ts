import type { Config } from 'tailwindcss'

export default {
  theme: {
    extend: {
      colors: {
        accent: {
          DEFAULT: '#e30613',
          dark: '#c00510',
        },
        charcoal: '#1a1a1a',
        slate: '#2d2d2d',
        ice: '#e8f4fc',
      },
      fontFamily: {
        display: ['"Bebas Neue"', 'sans-serif'],
        body: ['"DM Sans"', 'system-ui', 'sans-serif'],
      },
      borderRadius: {
        DEFAULT: '16px',
        lg: '24px',
      },
    },
  },
} satisfies Config