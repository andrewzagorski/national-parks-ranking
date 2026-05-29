import { createClient } from "@supabase/supabase-js";
import type { Database } from "./database.types";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY;

const STORAGE_KEY = "national_park_rubric_user_id";
const COOKIE_NAME = "national_park_rubric_user_id";

if (!supabaseUrl || !supabaseKey) {
    console.warn(
        "Supabase credentials missing. Please set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY in your .env file.",
    );
}

const getCookie = (name: string): string | null => {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop()?.split(";").shift() || null;
    return null;
};

export const supabase = createClient<Database>(supabaseUrl, supabaseKey, {
    global: {
        fetch: (url, options) => {
            const id = localStorage.getItem(STORAGE_KEY) ||
                getCookie(COOKIE_NAME);
            if (id && options) {
                const headers = new Headers(options.headers);
                headers.set("x-app-user-id", id);
                options.headers = headers;
            }
            return fetch(url, options);
        },
    },
});
