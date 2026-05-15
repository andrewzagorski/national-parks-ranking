<script setup lang="ts">
import { RouterView, RouterLink } from 'vue-router'
import { Mountain, Award, Settings, Fingerprint } from 'lucide-vue-next'
import { useTheme } from './composables/useTheme'

useTheme()
</script>

<template>
  <div class="flex min-h-screen flex-col">
    <!-- Header -->
    <header
      class="border-background-highlight sticky top-0 z-50 border-b bg-white"
    >
      <div
        class="mx-auto flex h-16 max-w-6xl items-center justify-between px-4"
      >
        <RouterLink to="/" class="group flex items-center gap-2">
          <div
            class="bg-primary rounded-lg p-1.5 text-white transition-transform group-hover:rotate-6"
          >
            <Mountain :size="20" />
          </div>
          <span
            class="font-display text-primary text-xl font-bold tracking-tight"
            >The Parks Rubric</span
          >
        </RouterLink>

        <nav class="hidden items-center gap-6 md:flex">
          <RouterLink to="/" class="nav-link">Leaderboard</RouterLink>
          <RouterLink to="/weights" class="nav-link">Weights</RouterLink>
          <RouterLink to="/id" class="nav-link text-secondary"
            >My ID</RouterLink
          >
        </nav>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1">
      <RouterView v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </RouterView>
    </main>

    <!-- Footer -->
    <footer
      class="bg-background-highlight/10 border-background-highlight border-t py-8 pb-24 md:pb-8"
    >
      <div
        class="mx-auto flex max-w-6xl flex-col items-center justify-between gap-4 px-4 md:flex-row"
      >
        <div class="font-display text-sm font-bold tracking-widest uppercase">
          &copy; 2026 The Parks Rubric
        </div>
        <div class="flex items-center gap-6">
          <RouterLink
            to="/privacy"
            class="hover:text-primary text-sm font-bold transition-colors"
          >
            Privacy & Identity
          </RouterLink>
          <a
            href="https://github.com"
            target="_blank"
            class="hover:text-primary text-sm font-bold transition-colors"
          >
            GitHub
          </a>
        </div>
      </div>
    </footer>

    <!-- Mobile Navigation -->
    <nav
      class="border-background-highlight fixed right-0 bottom-0 left-0 z-50 flex items-center justify-between border-t bg-white px-6 py-3 md:hidden"
    >
      <RouterLink to="/" class="mobile-nav-link" active-class="text-primary">
        <Award :size="24" />
        <span class="mt-1 text-[10px] font-bold uppercase">Rankings</span>
      </RouterLink>
      <RouterLink
        to="/weights"
        class="mobile-nav-link"
        active-class="text-primary"
      >
        <Settings :size="24" />
        <span class="mt-1 text-[10px] font-bold uppercase">Weights</span>
      </RouterLink>
      <RouterLink
        to="/id"
        class="mobile-nav-link"
        active-class="text-secondary"
      >
        <Fingerprint :size="24" />
        <span class="mt-1 text-[10px] font-bold uppercase">ID</span>
      </RouterLink>
    </nav>
  </div>
</template>

<style scoped>
@reference "./assets/main.css";

.nav-link {
  @apply font-display hover:text-primary text-sm font-bold tracking-wider uppercase transition-colors;
}
.nav-link.router-link-active {
  @apply text-primary;
}
.mobile-nav-link {
  @apply flex flex-col items-center transition-colors;
}
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
