// src/composables/useTheme.js
//
// Manages the active theme by toggling a data-theme attribute on <html>.
// Persists the choice to localStorage so it survives page reloads.
//
// Usage:
//   import { useTheme } from '@/composables/useTheme'
//   const { theme, setTheme, themes } = useTheme()

import { ref, watch } from 'vue'

// ─── Theme registry ──────────────────────────────────────────────────────────
// Each entry describes one theme for use in the picker UI.
// The `id` must match the [data-theme="..."] attribute in themes.css.
// `swatches` are just display hints — use any valid CSS color string.

export const themes = [
  {
    id: 'parks',
    label: 'Parks',
    description: 'Default parks theme',
    swatches: {
      primary: 'oklch(0.48 0.029 167)',
      secondary: 'oklch(0.6 0.11 195)',
      accent: 'oklch(0.72 0.13 210)',
      background: 'oklch(0.97 0.01 240)',
      text: 'oklch(0.15 0.03 240)'
    }
  },
  {
    id: 'ocean',
    label: 'Ocean',
    description: 'Cool blues and cyans',
    swatches: {
      primary: 'oklch(0.32 0.09 240)',
      secondary: 'oklch(0.60 0.11 195)',
      accent: 'oklch(0.72 0.13 210)',
      background: 'oklch(0.97 0.01 240)',
      text: 'oklch(0.15 0.03 240)'
    }
  },
  {
    id: 'forest',
    label: 'Forest',
    description: 'Muted greens and warm earth tones',
    swatches: {
      primary: 'oklch(0.35 0.10 145)',
      secondary: 'oklch(0.60 0.08 140)',
      accent: 'oklch(0.72 0.14 75)',
      background: 'oklch(0.97 0.01 90)',
      text: 'oklch(0.18 0.03 60)'
    }
  },
  {
    id: 'ember',
    label: 'Ember',
    description: 'Warm oranges, reds, and golds',
    swatches: {
      primary: 'oklch(0.55 0.17 38)',
      secondary: 'oklch(0.42 0.16 20)',
      accent: 'oklch(0.78 0.14 68)',
      background: 'oklch(0.97 0.01 60)',
      text: 'oklch(0.16 0.02 38)'
    }
  },
  {
    id: 'dusk',
    label: 'Dusk',
    description: 'Purples and mauves',
    swatches: {
      primary: 'oklch(0.40 0.14 285)',
      secondary: 'oklch(0.55 0.10 330)',
      accent: 'oklch(0.72 0.10 300)',
      background: 'oklch(0.97 0.01 285)',
      text: 'oklch(0.16 0.04 285)'
    }
  },
  {
    id: 'mono',
    label: 'Mono',
    description: 'Ultra clean grayscale',
    swatches: {
      primary: 'oklch(0.28 0.01 250)',
      secondary: 'oklch(0.55 0.01 250)',
      accent: 'oklch(0.20 0.02 250)',
      background: 'oklch(0.97 0.00 250)',
      text: 'oklch(0.15 0.01 250)'
    }
  }
]

// TODO sync to user profile in supabase
const STORAGE_KEY = 'app-theme'
const DEFAULT_THEME = 'parks'

function getInitialTheme() {
  const stored = localStorage.getItem(STORAGE_KEY)
  if (stored && themes.some((t) => t.id === stored)) return stored
  return DEFAULT_THEME
}

const theme = ref(getInitialTheme())

// Apply immediately on module load (before Vue mounts) to prevent flash
document.documentElement.setAttribute('data-theme', theme.value)

// Keep the DOM attribute in sync with the reactive ref
watch(theme, (newTheme) => {
  document.documentElement.setAttribute('data-theme', newTheme)
  localStorage.setItem(STORAGE_KEY, newTheme)
})

export function useTheme() {
  function setTheme(id: string) {
    if (!themes.some((t) => t.id === id)) {
      console.warn(`[useTheme] Unknown theme: "${id}"`)
      return
    }
    theme.value = id
  }

  function cycleTheme() {
    const idx = themes.findIndex((t) => t.id === theme.value)
    theme.value = themes[(idx + 1) % themes.length].id
  }

  return {
    /** The currently active theme id (reactive) */
    theme,
    /** All registered themes */
    themes,
    /** Switch to a specific theme by id */
    setTheme,
    /** Rotate to the next theme in the list */
    cycleTheme
  }
}
