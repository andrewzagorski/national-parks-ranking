<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { supabase } from '../utils/supabase'
import { useUserStore } from '../stores/user'
import { Mountain, Award, Globe } from 'lucide-vue-next'
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
  return mode.value === 'global' ? leaderboard.value : personalLeaderboard.value
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
  <div class="mx-auto max-w-6xl px-4 py-8 md:py-12">
    <div class="mb-12 text-center">
      <h1 class="mb-6 text-4xl md:text-5xl">The Parks Rubric</h1>

      <!-- Mode Toggle -->
      <div
        class="bg-background-highlight border-accent/5 inline-flex rounded-xl border p-1"
      >
        <button
          class="font-display flex items-center gap-2 rounded-lg px-6 py-2 text-sm font-bold transition-all"
          :class="
            mode === 'global'
              ? 'text-primary bg-white shadow-sm'
              : 'hover:text-writing'
          "
          @click="mode = 'global'"
        >
          <Globe :size="16" />
          Global
        </button>
        <button
          class="font-display flex items-center gap-2 rounded-lg px-6 py-2 text-sm font-bold transition-all"
          :class="
            mode === 'personal'
              ? 'text-secondary bg-white shadow-sm'
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
      <div
        v-if="currentLeaderboard.length === 0"
        class="border-background-highlight rounded-3xl border-2 border-dashed bg-white py-20 text-center"
      >
        <div class="mb-4 flex justify-center">
          <Award :size="64" />
        </div>
        <h3 class="font-display text-2xl font-bold">No rankings yet</h3>
        <p class="mt-2">
          Start rating parks to build your personal leaderboard.
        </p>
        <RouterLink
          to="/"
          class="btn-primary mt-8 inline-block"
          @click="mode = 'global'"
        >
          View All Parks
        </RouterLink>
      </div>

      <div v-else class="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
        <div
          v-for="park in currentLeaderboard"
          :key="park.park_id"
          class="group relative flex flex-col overflow-hidden transition-all duration-300"
        >
          <Postcard
            :id="park.park_id"
            class="hover:-translate-y-1"
            :name="park.park_name"
            :slug="park.park_slug"
            :rater-count="park.rater_count"
            :aggregate-score="park.aggregate_score"
            :size="'sm'"
          />
        </div>
      </div>
    </div>
  </div>
</template>
