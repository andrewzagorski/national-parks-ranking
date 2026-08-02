<script setup>
/**
 * ThemePicker.vue
 *
 * Drop-in theme switcher. Shows each theme's five color swatches
 * and highlights the active one.
 *
 * Usage:
 *   <ThemePicker />
 *   <ThemePicker label="Choose a theme" />
 */
import { useTheme } from '../composables/useTheme'

defineProps({
  /** Optional label shown above the picker */
  label: {
    type: String,
    default: 'Theme'
  }
})

const { theme, themes, setTheme } = useTheme()

const swatchOrder = ['primary', 'secondary', 'background', 'text']
</script>

<template>
  <div class="theme-picker">
    <p v-if="label" class="theme-picker__label">{{ label }}</p>

    <div class="theme-picker__grid" role="radiogroup" :aria-label="label">
      <button
        v-for="t in themes"
        :key="t.id"
        class="theme-picker__card"
        :class="{ 'theme-picker__card--active': theme === t.id }"
        role="radio"
        :aria-checked="theme === t.id"
        :aria-label="`${t.label} theme — ${t.description}`"
        @click="setTheme(t.id)"
      >
        <!-- Swatch strip -->
        <span class="theme-picker__swatches" aria-hidden="true">
          <span
            v-for="key in swatchOrder"
            :key="key"
            class="theme-picker__swatch"
            :style="{ background: t.swatches[key] }"
          />
        </span>

        <!-- Label row -->
        <span class="theme-picker__name">
          {{ t.label }}
          <span
            v-if="theme === t.id"
            class="theme-picker__checkmark"
            aria-hidden="true"
            >✓</span
          >
        </span>
        <span class="theme-picker__description">{{ t.description }}</span>
      </button>
    </div>
  </div>
</template>

<style scoped>
.theme-picker {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.theme-picker__label {
  font-size: 0.75rem;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: oklch(var(--color-text-highlight));
}

.theme-picker__grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(9rem, 1fr));
  gap: 0.625rem;
}

.theme-picker__card {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
  padding: 0.625rem;
  border-radius: 0.625rem;
  border: 2px solid transparent;
  background: oklch(var(--color-background-tint));
  cursor: pointer;
  text-align: left;
  transition:
    border-color 150ms ease,
    box-shadow 150ms ease,
    transform 100ms ease;
}

.theme-picker__card:hover {
  border-color: oklch(var(--color-primary-highlight));
  transform: translateY(-1px);
}

.theme-picker__card:focus-visible {
  outline: 2px solid oklch(var(--color-background));
  outline-offset: 2px;
}

.theme-picker__card--active {
  border-color: oklch(var(--color-primary));
  box-shadow: 0 0 0 1px oklch(var(--color-primary) / 0.3);
}

.theme-picker__swatches {
  display: flex;
  height: 1.25rem;
  border-radius: 0.375rem;
  overflow: hidden;
}

.theme-picker__swatch {
  flex: 1;
}

.theme-picker__name {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 0.875rem;
  font-weight: 600;
  color: oklch(var(--color-text));
}

.theme-picker__checkmark {
  font-size: 0.75rem;
  color: oklch(var(--color-primary));
}

.theme-picker__description {
  font-size: 0.7rem;
  color: oklch(var(--color-text-highlight));
  line-height: 1.3;
}
</style>
