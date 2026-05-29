import { defineStore } from "pinia";
import { ref } from "vue";
import { useUser } from "../composables/useUser";
import { supabase } from "../utils/supabase";

export const useUserStore = defineStore("user", () => {
  const {
    userId,
    initUser,
    // getFingerprint,
    generateAndSetNewUserId,
    setExistingUserId,
  } = useUser();
  const initialized = ref(false);
  const showAuthModal = ref(false);

  // Promise resolution handlers for the pending auth request
  let authResolve: ((id: string) => void) | null = null;
  let authReject: ((reason?: unknown) => void) | null = null;

  const setup = async () => {
    if (initialized.value) return;
    const id = await initUser();

    if (id) {
      // User is returning, update last_seen
      try {
        // const fingerprint = await getFingerprint()

        const { error } = await supabase.from("users").upsert(
          {
            id,
            // fingerprint,
            last_seen: new Date().toISOString(),
          },
          {
            onConflict: "id",
          },
        );

        if (error) {
          console.error("Failed to update last_seen for user:", error);
        }
      } catch (err) {
        console.error("Failed to sync user with Supabase:", err);
      }
    }

    initialized.value = true;
  };

  const requireAuth = (): Promise<string> => {
    if (userId.value) {
      return Promise.resolve(userId.value);
    }

    showAuthModal.value = true;
    return new Promise((resolve, reject) => {
      authResolve = resolve;
      authReject = reject;
    });
  };

  const resolveAuth = (id: string) => {
    showAuthModal.value = false;
    if (authResolve) {
      authResolve(id);
      authResolve = null;
      authReject = null;
    }
  };

  const cancelAuth = () => {
    showAuthModal.value = false;
    if (authReject) {
      authReject("Authentication cancelled");
      authResolve = null;
      authReject = null;
    }
  };

  const loginWithId = (id: string) => {
    setExistingUserId(id);
    resolveAuth(id);
  };

  const registerNewUser = async () => {
    const newId = generateAndSetNewUserId();

    // Insert the new user into the users table before resolving
    const { error } = await supabase.from("users").insert({
      id: newId,
      last_seen: new Date().toISOString(),
    });

    if (error) {
      console.error("Failed to create user in database:", error);
    }

    resolveAuth(newId);
  };

  return {
    userId,
    setup,
    showAuthModal,
    requireAuth,
    resolveAuth,
    cancelAuth,
    loginWithId,
    registerNewUser,
  };
});
