<template>
  <div>
    <div class="mx-auto max-w-4xl px-4 py-8 text-center">
      <h1 class="mb-6 text-4xl">Your Park ID</h1>
      <div
        class="bg-background border-accent/20 rounded-xl border-2 border-dashed p-8"
      >
        <p class="font-mono text-xl break-all">{{ userStore.userId }}</p>
      </div>
      <p class="mt-6 italic">
        Keep this ID safe to recover your rankings on other devices.
      </p>
    </div>
    <Themepicker />
  </div>
</template>

<script setup lang="ts">
import { useUserStore } from '../stores/user'
import Themepicker from '../components/Themepicker.vue'
const userStore = useUserStore()
</script>
