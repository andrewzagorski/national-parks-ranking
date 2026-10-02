<template>
  <div>
    <div class="mx-auto max-w-4xl px-4 py-8 text-center">
      <h1 class="mb-6 text-4xl">Your User ID</h1>
      <div v-if="userStore.userId">
        <div
          class="border-accent/20 flex justify-center gap-2 rounded-xl border-2 border-dashed p-8"
        >
          <button
            class="hover:cursor-pointer hover:drop-shadow-sm sm:hover:drop-shadow-lg"
            @click="idHidden = !idHidden"
          >
            <Eye v-if="idHidden" />
            <EyeClosed v-else />
          </button>
          <p class="font-mono text-xl break-all">
            {{
              idHidden
                ? '••••••••-••••-••••-••••-••••••••••••'
                : userStore.userId
            }}
          </p>
          <button
            class="hover:cursor-pointer hover:drop-shadow-sm sm:hover:drop-shadow-lg"
            @click="copyId"
          >
            <Copy v-if="!copied" />
            <CopyCheck v-else />
          </button>
        </div>
        <p class="mt-6 italic">
          Keep this ID safe to recover your rankings on other devices.
        </p>
      </div>
      <div v-else class="py-12">
        <p class="mb-6">
          Is out there somewhere...<br />
          Click the button to sign up or log in.
        </p>
        <button
          class="btn-primary font-display font-semibold"
          @click="userStore.requireAuth()"
        >
          Log in/Sign up
        </button>
      </div>
    </div>
    <!-- TODO logout button -->
    <Themepicker class="px-4" />
  </div>
</template>

<script setup lang="ts">
import { useUserStore } from '../stores/user'
import Themepicker from '../components/Themepicker.vue'
import { Copy, CopyCheck, Eye, EyeClosed } from 'lucide-vue-next'
import { ref } from 'vue'

const idHidden = ref(true)
const copied = ref(false)

const userStore = useUserStore()

const copyId = async () => {
  if (!userStore.userId) return
  try {
    await navigator.clipboard.writeText(userStore.userId)
    copied.value = true
    setTimeout(() => (copied.value = false), 2000)
  } catch (err) {
    console.error('Failed to copy ID:', err)
  }
}
</script>
