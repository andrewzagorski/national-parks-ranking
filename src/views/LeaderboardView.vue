<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import Fuse from 'fuse.js'
import { supabase } from '../utils/supabase'
import { useUserStore } from '../stores/user'
import { Mountain, Award, Globe, Search, CircleX } from 'lucide-vue-next'
import { RouterLink } from 'vue-router'
import Postcard from '../components/Postcard.vue'

interface ParkScore {
  park_id: number
  park_name: string
  park_slug: string
  rater_count?: number
  aggregate_score: number
}

const userStore = useUserStore()
const mode = ref<'global' | 'personal'>('global')
const leaderboard = ref<ParkScore[]>([])
const personalLeaderboard = ref<ParkScore[]>([])
const loading = ref(true)
const searchQuery = ref('')

const noRankingsHeader = computed(() => {
  return searchQuery.value ? 'No parks found' : 'No rankings yet'
})

const noRankingsMessage = computed(() => {
  return searchQuery.value
    ? 'You have a beautiful mind. Try another search?'
    : 'Start rating parks to build your personal leaderboard'
})

const fetchGlobalLeaderboard = async () => {
  const { data, error } = await supabase.from('aggregate_scores').select('*')

  if (error) {
    console.error('Error fetching global leaderboard:', error)
  } else {
    leaderboard.value = data || []
  }
}

const fetchPersonalLeaderboard = async () => {
  // 1. Get metrics and weights
  const { data: metrics } = await supabase.from('metrics').select('*')
  const { data: weights } = await supabase
    .from('user_weights')
    .select('*')
    .eq('user_id', userStore.userId)

  const weightMap: Record<number, number> = {}
  metrics?.forEach((m) => {
    const userWeight = weights?.find((w) => w.metric_id === m.id)
    weightMap[m.id] = userWeight ? userWeight.weight : m.default_weight
  })

  // 2. Get user ratings
  const { data: ratings } = await supabase
    .from('ratings')
    .select('*')
    .eq('user_id', userStore.userId)

  // 3. Get all parks
  const { data: parks } = await supabase.from('parks').select('*')

  // 4. Calculate scores
  const results: ParkScore[] = (parks || []).map((park) => {
    const parkRatings = ratings?.filter((r) => r.park_id === park.id) || []

    let totalScore = 0
    let ratedCount = 0

    parkRatings.forEach((r) => {
      const weight = weightMap[r.metric_id] || 0
      totalScore += ((r.score - 1) / 4.0) * weight
      ratedCount++
    })

    return {
      park_id: park.id,
      park_name: park.name,
      park_slug: park.slug,
      aggregate_score: Math.round(totalScore * 10) / 10,
      is_rated: ratedCount > 0
    }
  })

  personalLeaderboard.value = results
    .filter((r) => (r as any).is_rated)
    .sort((a, b) => b.aggregate_score - a.aggregate_score)
}

const currentLeaderboard = computed(() => {
  const source =
    mode.value === 'global' ? leaderboard.value : personalLeaderboard.value
  const query = searchQuery.value.trim()
  if (!query) return source
  const fuse = new Fuse(source, { keys: ['park_name'], threshold: 0.4 })
  return fuse.search(query).map((r) => r.item)
})

const fetchData = async () => {
  loading.value = true
  await Promise.all([fetchGlobalLeaderboard(), fetchPersonalLeaderboard()])
  loading.value = false
}

onMounted(() => {
  fetchData()
})
</script>

<template>
  <div class="mx-auto px-4 py-4 md:py-12">
    <div class="mb-4 text-center md:mb-6">
      <h1 class="mb-4 text-3xl md:mb-6 md:text-5xl">The Parks Rubric</h1>

      <!-- Mode Toggle -->
      <div
        class="bg-background-highlight border-accent/5 inline-flex rounded-xl border p-1"
      >
        <button
          class="font-display flex items-center gap-2 rounded-lg px-4 py-1 text-sm font-bold transition-all md:px-6 md:py-2"
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
          class="font-display flex items-center gap-2 rounded-lg px-4 py-1 text-sm font-bold transition-all md:px-6 md:py-2"
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

    <div v-if="loading" class="flex justify-center py-20">
      <div class="text-primary animate-spin">
        <Mountain :size="48" />
      </div>
    </div>

    <div v-else>
      <div class="flex items-center justify-center pb-6">
        <input
          v-model="searchQuery"
          type="text"
          class="focus:border-primary-highlight text-md bg-background-highlight border-primary-tint w-2xs rounded-lg border py-1 pr-10 pl-4 md:w-sm"
          :class="[mode === 'personal' ? '' : '']"
        />
        <div class="text-secondary-tint relative flex items-center">
          <Search :size="20" class="-ml-10" />
          <CircleX
            v-if="searchQuery"
            :size="14"
            class="text-secondary-tint cursor-pointer"
            @click="searchQuery = ''"
          />
        </div>
      </div>
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
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
