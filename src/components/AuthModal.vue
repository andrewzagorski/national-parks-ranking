<template>
  <div
    v-if="userStore.showAuthModal"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm"
  >
    <div
      class="bg-background-tint flex w-full max-w-md flex-col overflow-hidden rounded-xl border shadow-xl"
    >
      <div class="p-6 pb-0">
        <h2 class="text-2xl font-bold">
          {{ showSavedStep ? 'Your ID' : 'Been here before?' }}
        </h2>
        <p v-if="!showSavedStep" class="mt-2 text-sm">
          If you have an ID, enter it below. Otherwise, we'll generate one for
          you.
        </p>
      </div>

      <div v-if="!showSavedStep" class="border-border mt-4 flex border-b">
        <button
          class="flex-1 py-3 text-sm font-medium transition-colors"
          :class="isNewUser ? 'text-primary border-primary border-b-2' : ''"
          @click="isNewUser = true"
        >
          New User
        </button>
        <button
          class="flex-1 py-3 text-sm font-medium transition-colors"
          :class="!isNewUser ? 'text-primary border-primary border-b-2' : ''"
          @click="isNewUser = false"
        >
          Returning User
        </button>
      </div>

      <div class="flex-1 overflow-y-auto p-6 pt-4">
        <div v-if="showSavedStep" class="space-y-4">
          <p class="text-card-foreground text-sm">
            This is your unique ID. Make sure it's saved in your password
            manager or somewhere safe. You'll need it to access your data on
            other devices.
          </p>
          <code
            class="bg-background block w-full rounded-md border px-3 py-2 text-sm break-all select-all"
          >
            {{ generatedId }}
          </code>
          <div class="mt-6 flex justify-end gap-3">
            <button
              type="button"
              class="btn-transparent text-sm"
              @click="copyGeneratedId"
            >
              {{ copied ? 'Copied' : 'Copy ID' }}
            </button>
            <button
              type="button"
              class="btn-primary text-sm"
              @click="handleContinue"
            >
              I've saved it, continue
            </button>
          </div>
        </div>

        <form
          v-else-if="isNewUser"
          class="space-y-4"
          @submit.prevent="handleRegister"
        >
          <input
            type="text"
            name="username"
            autocomplete="username"
            :value="AUTH_USERNAME"
            class="sr-only"
            tabindex="-1"
            aria-hidden="true"
          />
          <input
            v-model="generatedId"
            type="password"
            name="password"
            autocomplete="new-password"
            class="sr-only"
            tabindex="-1"
            aria-hidden="true"
          />

          <p class="text-card-foreground text-sm">
            We will generate a unique ID for you. Your browser or password
            manager will offer to save it. Please save it if you want to access
            your data on other devices.
          </p>
          <div class="my-4 flex justify-center">
            <vue-turnstile
              v-model="turnstileToken"
              :site-key="siteKey"
              @error="onTurnstileError"
              @expired="onTurnstileExpire"
            />
          </div>
          <p v-if="registrationError" class="text-sm font-medium text-red-600">
            {{ registrationError }}
          </p>
          <div class="mt-6 flex justify-end gap-3">
            <button
              type="button"
              class="btn-transparent text-sm"
              @click="handleCancel"
            >
              Cancel
            </button>
            <button
              type="submit"
              class="btn-primary text-sm"
              :class="{
                'cursor-not-allowed opacity-50':
                  !turnstileVerified || isSubmitting
              }"
              :disabled="!turnstileVerified || isSubmitting"
            >
              <span v-if="isSubmitting">Registering...</span>
              <span v-else>Generate ID</span>
            </button>
          </div>
        </form>

        <div v-else class="space-y-4">
          <form class="space-y-4" @submit.prevent="handleLogin">
            <!-- Hidden username field for password managers -->
            <input
              type="text"
              name="username"
              autocomplete="username"
              :value="AUTH_USERNAME"
              class="sr-only"
              tabindex="-1"
              aria-hidden="true"
            />

            <div class="space-y-2">
              <label for="uuid" class="text-sm font-medium"
                >Your Unique ID</label
              >
              <input
                id="uuid"
                v-model="inputUuid"
                name="password"
                type="password"
                autocomplete="current-password"
                placeholder="Enter your user ID..."
                class="bg-background focus:ring-primary w-full rounded-md border px-3 py-2 focus:border-transparent focus:ring-2 focus:outline-none"
                required
              />
            </div>

            <p v-if="loginError" class="text-sm font-medium">
              {{ loginError }}
            </p>

            <div class="mt-6 flex justify-end gap-3">
              <button
                type="button"
                class="btn-transparent text-sm"
                @click="handleCancel"
              >
                Cancel
              </button>
              <button
                type="submit"
                class="btn-primary text-sm"
                :disabled="!inputUuid || isSubmitting"
                :class="{
                  'cursor-not-allowed opacity-50': !inputUuid || isSubmitting
                }"
              >
                <span v-if="isSubmitting">Logging in...</span>
                <span v-else>Log In</span>
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// TODO verify all styling, functionality, button styles. Try each auth state/process on local and in cloud

import { ref, watch } from 'vue'
import { useUserStore } from '../stores/user'
import VueTurnstile from 'vue-turnstile'
import { supabase } from '../utils/supabase'
import { v4 as uuidv4 } from 'uuid'

const userStore = useUserStore()

const AUTH_USERNAME = 'Parkgoer'

const isNewUser = ref(true)
const turnstileToken = ref('')
const turnstileVerified = ref(false)
const inputUuid = ref('')
const generatedId = ref(uuidv4())
const showSavedStep = ref(false)
const copied = ref(false)
const isSubmitting = ref(false)
const loginError = ref('')
const registrationError = ref('')

const siteKey = import.meta.env.VITE_TURNSTILE_SITE_KEY || ''

const onTurnstileError = () => {
  turnstileToken.value = ''
  turnstileVerified.value = false
}

const onTurnstileExpire = () => {
  turnstileToken.value = ''
  turnstileVerified.value = false
}

// Set turnstileVerified when token is received via v-model
watch(turnstileToken, (newVal) => {
  turnstileVerified.value = !!newVal
})

// Reset state when modal opens
watch(
  () => userStore.showAuthModal,
  (isOpen) => {
    if (isOpen) {
      turnstileToken.value = ''
      turnstileVerified.value = false
      inputUuid.value = ''
      generatedId.value = uuidv4()
      showSavedStep.value = false
      copied.value = false
      registrationError.value = ''
      loginError.value = ''
      isNewUser.value = true
    }
  }
)

const handleCancel = () => {
  userStore.cancelAuth()
}

const handleRegister = async () => {
  if (!turnstileToken.value) return

  isSubmitting.value = true
  registrationError.value = ''

  try {
    // Verify turnstile token via Supabase Edge Function
    const { data, error } = await supabase.functions.invoke(
      'verify-turnstile',
      {
        body: { token: turnstileToken.value }
      }
    )

    if (error) throw error
    if (!data?.success) throw new Error('Captcha verification failed')

    showSavedStep.value = true
  } catch (err: unknown) {
    console.error('Registration error:', err)
    registrationError.value =
      err instanceof Error ? err.message : 'Registration failed'
    // Reset token so they can try again
    turnstileToken.value = ''
    turnstileVerified.value = false
  } finally {
    isSubmitting.value = false
  }
}

const handleContinue = () => {
  userStore.registerNewUser(generatedId.value)
}

const copyGeneratedId = async () => {
  try {
    await navigator.clipboard.writeText(generatedId.value)
    copied.value = true
    setTimeout(() => (copied.value = false), 2000)
  } catch (err) {
    console.error('Copy failed:', err)
  }
}

const handleLogin = async () => {
  if (!inputUuid.value) return

  isSubmitting.value = true
  loginError.value = ''

  try {
    // Validate UUID format roughly
    if (
      !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(
        inputUuid.value.trim()
      )
    ) {
      throw new Error('Invalid ID format. It should be a standard UUID.')
    }

    // Check if user exists in DB via secure RPC
    const { data, error } = await (supabase as any).rpc('verify_user_exists', {
      p_id: inputUuid.value.trim()
    })

    if (error || !data) {
      throw new Error('ID not found.')
    }

    userStore.loginWithId(inputUuid.value.trim())
  } catch (err: unknown) {
    console.error('Login error:', err)
    loginError.value = err instanceof Error ? err.message : 'Login failed'
  } finally {
    isSubmitting.value = false
  }
}
</script>
