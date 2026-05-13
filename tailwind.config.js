/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        sage: {
          DEFAULT: '#4e635a',
          container: '#8da399',
          fixed: '#d1e8dd',
        },
        terracotta: {
          DEFAULT: '#8b4e3f',
          container: '#fdad9a',
          fixed: '#ffdad2',
        },
        sand: {
          DEFAULT: '#f5f3f1',
          container: '#efeeec',
        },
        cream: '#fbf9f7',
        charcoal: '#1b1c1b',
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
