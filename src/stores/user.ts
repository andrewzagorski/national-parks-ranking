import { defineStore } from 'pinia'
import { ref } from 'vue'
import { useUser } from '../composables/useUser'
import { supabase } from '../utils/supabase'

export const useUserStore = defineStore('user', () => {
  const { userId, initUser, getFingerprint } = useUser()
  const initialized = ref(false)

  const setup = async () => {
    if (initialized.value) return
    const id = await initUser(supabase)

    // Upsert user to ensure they exist and update last_seen/fingerprint
    try {
      const fingerprint = await getFingerprint()

      const { error } = await supabase
        .from('users')
        .upsert({
          id,
          fingerprint,
          last_seen: new Date().toISOString()
        }, {
          onConflict: 'id'
        })

      if (error) {
        console.error('Failed to upsert user:', error)
      }
    } catch (err) {
      console.error('Failed to sync user with Supabase:', err)
    }

    initialized.value = true
  }

  return {
    userId,
    setup
  }
})
