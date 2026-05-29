import { createApp } from "vue";
import { createPinia } from "pinia";
import "floating-vue/dist/style.css";
import "./assets/themes.css";
import "./assets/main.css";
import App from "./App.vue";
import router from "./router";
import { useUserStore } from "./stores/user";
import FloatingVue from "floating-vue";

const app = createApp(App);
const pinia = createPinia();

app.use(pinia);
app.use(router);
app.use(FloatingVue);

// Initialize user store
const userStore = useUserStore();
userStore.setup().then(() => {
    app.mount("#app");
});
