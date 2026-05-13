import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'leaderboard',
      component: () => import('../views/LeaderboardView.vue')
    },
    {
      path: '/rate/:slug',
      name: 'rate',
      component: () => import('../views/RateParkView.vue')
    },
    {
      path: '/weights',
      name: 'weights',
      component: () => import('../views/WeightsView.vue')
    },
    {
      path: '/id',
      name: 'park-id',
      component: () => import('../views/ParkIdView.vue')
    },
    {
      path: '/privacy',
      name: 'privacy',
      component: () => import('../views/PrivacyView.vue')
    }
  ]
})

export default router
