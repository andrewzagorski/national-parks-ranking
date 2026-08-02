// src/composables/useTheme.js
//
// Manages the active theme by toggling a data-theme attribute on <html>.
// Persists the choice to localStorage so it survives page reloads.
//
// Usage:
//   import { useTheme } from '@/composables/useTheme'
//   const { theme, setTheme, themes } = useTheme()

import { ref, watch } from "vue";

// ─── Theme registry ──────────────────────────────────────────────────────────
// Each entry describes one theme for use in the picker UI.
// The `id` must match the [data-theme="..."] attribute in themes.css.
// `swatches` are just display hints — use any valid CSS color string.

export const themes = [
  {
    id: "parks",
    label: "Parks",
    description: "Default parks theme",
    swatches: {
      primary: "oklch(0.48 0.029 167)",
      secondary: "oklch(0.82 0.0985 33.92)",
      background: "oklch(0.9831 0.0034 67.78)",
      text: "oklch(0.225 0.0024 145.49)",
    },
  },
  {
    id: "parks-dark",
    label: "Parks Dark",
    description: "Default parks dark mode theme",
    swatches: {
      primary: "oklch(0.48 0.029 167)",
      secondary: "oklch(0.82 0.0985 33.92)",
      background: "oklch(0.225 0.0024 145.49)",
      text: "oklch(0.9831 0.0034 67.78)",
    },
  },
];

// TODO sync to user profile in supabase
const STORAGE_KEY = "app-theme";
const DEFAULT_THEME = "parks";

function getInitialTheme() {
  const stored = localStorage.getItem(STORAGE_KEY);
  if (stored && themes.some((t) => t.id === stored)) return stored;
  return DEFAULT_THEME;
}

const theme = ref(getInitialTheme());

// Apply immediately on module load (before Vue mounts) to prevent flash
document.documentElement.setAttribute("data-theme", theme.value);

// Keep the DOM attribute in sync with the reactive ref
watch(theme, (newTheme) => {
  document.documentElement.setAttribute("data-theme", newTheme);
  localStorage.setItem(STORAGE_KEY, newTheme);
});

export function useTheme() {
  function setTheme(id: string) {
    if (!themes.some((t) => t.id === id)) {
      console.warn(`[useTheme] Unknown theme: "${id}"`);
      return;
    }
    theme.value = id;
  }

  function cycleTheme() {
    const idx = themes.findIndex((t) => t.id === theme.value);
    theme.value = themes[(idx + 1) % themes.length].id;
  }

  return {
    /** The currently active theme id (reactive) */
    theme,
    /** All registered themes */
    themes,
    /** Switch to a specific theme by id */
    setTheme,
    /** Rotate to the next theme in the list */
    cycleTheme,
  };
}
