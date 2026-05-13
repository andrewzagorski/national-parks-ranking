<template>
  <div class="max-w-4xl mx-auto px-4 py-8 text-center">
    <h1 class="text-4xl mb-6">Your Park ID</h1>
    <div class="bg-sand p-8 rounded-xl border-2 border-dashed border-charcoal/20">
      <p class="font-mono text-xl break-all">{{ userStore.userId }}</p>
    </div>
    <p class="mt-6 text-charcoal/60 italic">Keep this ID safe to recover your rankings on other devices.</p>
  </div>
</template>

<script setup lang="ts">
import { useUserStore } from '../stores/user'
const userStore = useUserStore()
</script>
