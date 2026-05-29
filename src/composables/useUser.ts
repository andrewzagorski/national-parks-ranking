import { ref } from "vue";
import { v4 as uuidv4 } from "uuid";
// import FingerprintJS from '@fingerprintjs/fingerprintjs'

const STORAGE_KEY = "national_park_rubric_user_id";
const COOKIE_NAME = "national_park_rubric_user_id";
// const fpPromise = FingerprintJS.load()

export function useUser() {
  const userId = ref<string | null>(null);

  const getCookie = (name: string): string | null => {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop()?.split(";").shift() || null;
    return null;
  };

  const setCookie = (name: string, value: string, days = 365) => {
    const date = new Date();
    date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000);
    const expires = `; expires=${date.toUTCString()}`;
    document.cookie = `${name}=${value || ""}${expires}; path=/; SameSite=Lax`;
  };

  // const getFingerprint = async () => {
  //   const fp = await fpPromise
  //   const result = await fp.get()
  //   const fingerprintStr = result.visitorId

  //   const msgUint8 = new TextEncoder().encode(fingerprintStr)
  //   const hashBuffer = await crypto.subtle.digest('SHA-256', msgUint8)
  //   const hashArray = Array.from(new Uint8Array(hashBuffer))
  //   return hashArray.map((b) => b.toString(16).padStart(2, '0')).join('')
  // }

  const initUser = async () => {
    // 1. Check cookies
    let id = getCookie(COOKIE_NAME);
    if (id) {
      userId.value = id;
      // Sync to localStorage
      localStorage.setItem(STORAGE_KEY, id);
      return id;
    }

    // 2. Check cache (localStorage)
    id = localStorage.getItem(STORAGE_KEY);
    if (id) {
      userId.value = id;
      setCookie(COOKIE_NAME, id);
      localStorage.setItem(STORAGE_KEY, id);
      return id;
    }

    return null;
  };

  const generateAndSetNewUserId = () => {
    const id = uuidv4();
    userId.value = id;
    setCookie(COOKIE_NAME, id);
    localStorage.setItem(STORAGE_KEY, id);
    return id;
  };

  const setExistingUserId = (id: string) => {
    userId.value = id;
    setCookie(COOKIE_NAME, id);
    localStorage.setItem(STORAGE_KEY, id);
  };

  return {
    userId,
    initUser,
    // getFingerprint,
    generateAndSetNewUserId,
    setExistingUserId,
  };
}
