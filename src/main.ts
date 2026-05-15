import { createApp } from 'vue'
import { createPinia } from 'pinia'
import './assets/themes.css'
import './assets/main.css'
import App from './App.vue'
import router from './router'
import { useUserStore } from './stores/user'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

// Initialize user store
const userStore = useUserStore()
userStore.setup()

app.mount('#app')
