<script setup lang="ts">
import { onMounted, computed } from 'vue'
import Fuse from 'fuse.js'
import { useUserStore } from '../stores/user'
import { Mountain, Award, Globe } from 'lucide-vue-next'
import { RouterLink } from 'vue-router'
import Postcard from '../components/Postcard.vue'
import { useMetricsStore } from '../stores/metrics'
import { storeToRefs } from 'pinia'
import { useLeaderboardStore } from '../stores/leaderboard'
import { useParksStore } from '../stores/parks'

const userStore = useUserStore()

const metricsStore = useMetricsStore()
const { userWeights } = storeToRefs(metricsStore)
const leaderboardStore = useLeaderboardStore()
const {
  personalLeaderboard,
  isLoadingPersonalLeaderboard,
  globalLeaderboard,
  isLoadingGlobalLeaderboard,
  mode,
  searchQuery
} = storeToRefs(leaderboardStore)
const parksStore = useParksStore()
const { parks } = storeToRefs(parksStore)

const noRankingsHeader = computed(() => {
  return searchQuery.value ? 'No parks found' : 'No rankings yet'
})

const noRankingsMessage = computed(() => {
  return searchQuery.value
    ? 'You have a beautiful mind. Try another search?'
    : 'Start rating parks to build your personal leaderboard'
})

const currentLeaderboard = computed(() => {
  const source =
    mode.value === 'global'
      ? globalLeaderboard.value
      : personalLeaderboard.value
  const query = searchQuery.value.trim()
  if (!query) return source
  const fuse = new Fuse(source, { keys: ['park_name'], threshold: 0.4 })
  return fuse
    .search(query)
    .map((r) => r.item)
    .sort((a, b) => a.rank - b.rank)
})

const doFetchPersonalLeaderboard = async () => {
  isLoadingPersonalLeaderboard.value = true
  await Promise.all([
    metricsStore.fetchMetrics(),
    metricsStore.fetchWeights(userStore.userId),
    parksStore.fetchParks()
  ])

  await leaderboardStore.fetchPersonalLeaderboard(
    userStore.userId,
    parks.value,
    userWeights.value
  )
  isLoadingPersonalLeaderboard.value = false
}

const doFetchGlobalLeaderboard = async () => {
  isLoadingGlobalLeaderboard.value = true
  await leaderboardStore.fetchGlobalLeaderboard()
  isLoadingGlobalLeaderboard.value = false
}

onMounted(async () => {
  doFetchPersonalLeaderboard()
  doFetchGlobalLeaderboard()
})
</script>

<template>
  <div class="mx-auto px-4 py-4">
    <div class="mb-4 text-center md:mb-6">
      <!-- Mode Toggle -->
      <div
        class="bg-background-highlight border-accent/5 inline-flex rounded-xl border p-1"
      >
        <button
          class="font-display flex cursor-pointer items-center gap-2 rounded-lg px-4 py-1 text-sm font-bold transition-all md:px-6 md:py-2"
          :class="
            mode === 'global'
              ? 'text-primary-tint shadow-sm'
              : 'hover:text-writing'
          "
          @click="mode = 'global'"
        >
          <Globe :size="16" />
          Global
        </button>
        <button
          class="font-display flex cursor-pointer items-center gap-2 rounded-lg px-4 py-1 text-sm font-bold transition-all md:px-6 md:py-2"
          :class="
            mode === 'personal'
              ? 'text-secondary-tint shadow-sm'
              : 'hover:text-writing'
          "
          @click="mode = 'personal'"
        >
          <Award :size="16" />
          My Rankings
        </button>
      </div>
    </div>

    <div
      v-if="
        (mode === 'global' && isLoadingGlobalLeaderboard) ||
        (mode === 'personal' && isLoadingPersonalLeaderboard)
      "
      class="flex justify-center py-20"
    >
      <div class="text-primary animate-spin">
        <Mountain :size="48" />
      </div>
    </div>

    <div v-else>
      <div
        v-if="currentLeaderboard.length === 0"
        class="border-background-highlight rounded-3xl border-2 border-dashed bg-white py-20 text-center"
      >
        <div class="mb-4 flex justify-center">
          <Award :size="64" />
        </div>
        <h3 class="font-display text-2xl font-bold">{{ noRankingsHeader }}</h3>
        <p class="mt-2">
          {{ noRankingsMessage }}
        </p>
        <RouterLink
          to="/"
          class="btn-primary mt-8 inline-block"
          @click="mode = 'global'"
        >
          View All Parks
        </RouterLink>
      </div>
      <div v-else>
        <div class="flex flex-wrap justify-center gap-4 md:gap-6">
          <div v-for="park in currentLeaderboard" :key="park.park_id" class="">
            <Postcard
              :id="park.park_id"
              class="transition-all duration-300 hover:-translate-y-1"
              :name="park.park_name"
              :slug="park.park_slug"
              :rater-count="park.rater_count"
              :aggregate-score="park.aggregate_score"
              :size="'sm'"
              :mode="mode"
              :rank="park.rank"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
