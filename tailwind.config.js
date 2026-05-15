/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: 'oklch(var(--color-primary) / <alpha-value>)',
          highlight: 'oklch(var(--color-primary-highlight) / <alpha-value>)',
          tint: 'oklch(var(--color-primary-tint) / <alpha-value>)',
        },
        secondary: {
          DEFAULT: 'oklch(var(--color-secondary) / <alpha-value>)',
          highlight: 'oklch(var(--color-secondary-highlight) / <alpha-value>)',
          tint: 'oklch(var(--color-secondary-tint) / <alpha-value>)',
        },
        accent: {
          DEFAULT: 'oklch(var(--color-accent) / <alpha-value>)',
          highlight: 'oklch(var(--color-accent-highlight) / <alpha-value>)',
          tint: 'oklch(var(--color-accent-tint) / <alpha-value>)',
        },
        background: {
          DEFAULT: 'oklch(var(--color-background) / <alpha-value>)',
          highlight: 'oklch(var(--color-background-highlight) / <alpha-value>)',
          tint: 'oklch(var(--color-background-tint) / <alpha-value>)',
        },
        writing: {
          DEFAULT: 'oklch(var(--color-on-background) / <alpha-value>)',
          onprimary: 'oklch(var(--color-on-primary) / <alpha-value>)',
          onsecondary: 'oklch(var(--color-on-secondary) / <alpha-value>)',
          onaccent: 'oklch(var(--color-on-accent) / <alpha-value>)',
          onbackground: 'oklch(var(--color-on-background) / <alpha-value>)',
        },

      },
      fontFamily: {
        sans: ['Quicksand', 'sans-serif'],
        serif: ['Literata', 'serif'],
        display: ['Quicksand', 'sans-serif'],
      },
      borderRadius: {
        'sm': '0.25rem',
        'DEFAULT': '0.5rem',
        'md': '0.75rem',
        'lg': '1rem',
        'xl': '1.5rem',
      },
      boxShadow: {
        'sticker': '4px 4px 0px 0px rgba(27, 28, 27, 1)',
        'sticker-hover': '2px 2px 0px 0px rgba(27, 28, 27, 1)',
      }
    },
  },
  plugins: [],
}
