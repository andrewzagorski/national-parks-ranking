<script setup lang="ts">
import { RouterView, RouterLink } from 'vue-router'
import { Mountain, Award, Settings, Fingerprint } from 'lucide-vue-next'
</script>

<template>
  <div class="min-h-screen flex flex-col">
    <!-- Header -->
    <header class="bg-white border-b border-sand-container sticky top-0 z-50">
      <div class="max-w-6xl mx-auto px-4 h-16 flex items-center justify-between">
        <RouterLink to="/" class="flex items-center gap-2 group">
          <div class="bg-sage text-white p-1.5 rounded-lg group-hover:rotate-6 transition-transform">
            <Mountain :size="20" />
          </div>
          <span class="font-display font-bold text-xl tracking-tight text-sage">Wilderness Rubric</span>
        </RouterLink>
        
        <nav class="hidden md:flex items-center gap-6">
          <RouterLink to="/" class="nav-link">Leaderboard</RouterLink>
          <RouterLink to="/weights" class="nav-link">Weights</RouterLink>
          <RouterLink to="/id" class="nav-link text-terracotta">My ID</RouterLink>
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
    <footer class="bg-sand-container/10 border-t border-sand-container py-8 pb-24 md:pb-8">
      <div class="max-w-6xl mx-auto px-4 flex flex-col md:flex-row justify-between items-center gap-4">
        <div class="text-charcoal/40 text-sm font-display font-bold uppercase tracking-widest">
          &copy; 2026 Wilderness Rubric
        </div>
        <div class="flex items-center gap-6">
          <RouterLink to="/privacy" class="text-charcoal/40 hover:text-sage text-sm font-bold transition-colors">
            Privacy & Identity
          </RouterLink>
          <a href="https://github.com" target="_blank" class="text-charcoal/40 hover:text-sage text-sm font-bold transition-colors">
            GitHub
          </a>
        </div>
      </div>
    </footer>

    <!-- Mobile Navigation -->
    <nav class="md:hidden fixed bottom-0 left-0 right-0 bg-white border-t border-sand-container px-6 py-3 flex justify-between items-center z-50">
      <RouterLink to="/" class="mobile-nav-link" active-class="text-sage">
        <Award :size="24" />
        <span class="text-[10px] font-bold uppercase mt-1">Rankings</span>
      </RouterLink>
      <RouterLink to="/weights" class="mobile-nav-link" active-class="text-sage">
        <Settings :size="24" />
        <span class="text-[10px] font-bold uppercase mt-1">Weights</span>
      </RouterLink>
      <RouterLink to="/id" class="mobile-nav-link" active-class="text-terracotta">
        <Fingerprint :size="24" />
        <span class="text-[10px] font-bold uppercase mt-1">ID</span>
      </RouterLink>
    </nav>
  </div>
</template>

<style scoped>
@reference "./style.css";

.nav-link {
  @apply font-display font-bold text-sm uppercase tracking-wider text-charcoal/60 hover:text-sage transition-colors;
}
.nav-link.router-link-active {
  @apply text-sage;
}
.mobile-nav-link {
  @apply flex flex-col items-center text-charcoal/40 transition-colors;
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
