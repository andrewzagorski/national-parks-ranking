import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
// @ts-expect-error - vite-plugin-eslint has no types
import eslintPlugin from 'vite-plugin-eslint'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue(), eslintPlugin()]
})
