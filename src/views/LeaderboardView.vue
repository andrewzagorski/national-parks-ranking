<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { supabase } from '../utils/supabase'
import { useUserStore } from '../stores/user'
import { Mountain, Users, Award, Globe } from 'lucide-vue-next'
import { RouterLink } from 'vue-router'

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
  const { data, error } = await supabase
    .from('aggregate_scores')
    .select('*')
  
  if (error) {
    console.error('Error fetching global leaderboard:', error)
  } else {
    leaderboard.value = data || []
  }
}

const fetchPersonalLeaderboard = async () => {
  // 1. Get metrics and weights
  const { data: metrics } = await supabase.from('metrics').select('*')
  const { data: weights } = await supabase.from('user_weights').select('*').eq('user_id', userStore.userId)
  
  const weightMap: Record<number, number> = {}
  metrics?.forEach(m => {
    const userWeight = weights?.find(w => w.metric_id === m.id)
    weightMap[m.id] = userWeight ? userWeight.weight : m.default_weight
  })

  // 2. Get user ratings
  const { data: ratings } = await supabase.from('ratings').select('*').eq('user_id', userStore.userId)
  
  // 3. Get all parks
  const { data: parks } = await supabase.from('parks').select('*')

  // 4. Calculate scores
  const results: ParkScore[] = (parks || []).map(park => {
    const parkRatings = ratings?.filter(r => r.park_id === park.id) || []
    
    let totalScore = 0
    let ratedCount = 0

    parkRatings.forEach(r => {
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
    .filter(r => (r as any).is_rated)
    .sort((a, b) => b.aggregate_score - a.aggregate_score)
}

const currentLeaderboard = computed(() => {
  return mode.value === 'global' ? leaderboard.value : personalLeaderboard.value
})

const fetchData = async () => {
  loading.value = true
  await Promise.all([
    fetchGlobalLeaderboard(),
    fetchPersonalLeaderboard()
  ])
  loading.value = false
}

onMounted(() => {
  fetchData()
})
</script>

<template>
  <div class="max-w-6xl mx-auto px-4 py-8 md:py-12">
    <div class="mb-12 text-center">
      <h1 class="text-4xl md:text-5xl mb-6 text-charcoal">The Wilderness Rubric</h1>
      
      <!-- Mode Toggle -->
      <div class="inline-flex p-1 bg-sand-container rounded-xl border border-charcoal/5">
        <button 
          @click="mode = 'global'"
          class="flex items-center gap-2 px-6 py-2 rounded-lg font-display font-bold text-sm transition-all"
          :class="mode === 'global' ? 'bg-white text-sage shadow-sm' : 'text-charcoal/40 hover:text-charcoal'"
        >
          <Globe :size="16" />
          Global
        </button>
        <button 
          @click="mode = 'personal'"
          class="flex items-center gap-2 px-6 py-2 rounded-lg font-display font-bold text-sm transition-all"
          :class="mode === 'personal' ? 'bg-white text-terracotta shadow-sm' : 'text-charcoal/40 hover:text-charcoal'"
        >
          <Award :size="16" />
          My Rankings
        </button>
      </div>
    </div>

    <div v-if="loading" class="flex justify-center py-20">
      <div class="animate-spin text-sage">
        <Mountain :size="48" />
      </div>
    </div>

    <div v-else>
      <div v-if="currentLeaderboard.length === 0" class="text-center py-20 bg-white rounded-3xl border-2 border-dashed border-sand-container">
        <div class="text-charcoal/20 mb-4 flex justify-center">
          <Award :size="64" />
        </div>
        <h3 class="text-2xl font-display font-bold text-charcoal/60">No rankings yet</h3>
        <p class="text-charcoal/40 mt-2">Start rating parks to build your personal leaderboard.</p>
        <RouterLink to="/" @click="mode = 'global'" class="mt-8 inline-block btn-primary">
          View All Parks
        </RouterLink>
      </div>

      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="(park, index) in currentLeaderboard" :key="park.park_id" 
             class="card-postcard group hover:-translate-y-1 transition-all duration-300 flex flex-col relative overflow-hidden">
          
          <div class="flex justify-between items-start mb-4">
            <div :class="[
              'text-white font-display font-bold px-3 py-1 rounded-sm rotate-[-2deg] shadow-sm',
              mode === 'global' ? 'bg-terracotta' : 'bg-sage'
            ]">
              #{{ index + 1 }}
            </div>
            <div v-if="mode === 'global'" class="flex items-center gap-1 text-charcoal/40 text-sm">
              <Users :size="14" />
              <span>{{ park.rater_count }} raters</span>
            </div>
          </div>

          <h3 class="text-2xl mb-2 group-hover:text-sage transition-colors leading-tight">{{ park.park_name }}</h3>
          
          <div class="mt-auto pt-4 flex items-end justify-between border-t border-sand-container">
            <div class="flex flex-col">
              <span class="text-[10px] uppercase font-bold tracking-widest text-charcoal/40">
                {{ mode === 'global' ? 'Aggregate Score' : 'My Rubric Score' }}
              </span>
              <span class="text-3xl font-display font-bold" :class="mode === 'global' ? 'text-sage' : 'text-terracotta'">
                {{ park.aggregate_score }}
              </span>
            </div>
            
            <RouterLink :to="`/rate/${park.park_slug}`" class="btn-primary py-2 px-4 text-sm">
              {{ mode === 'global' ? 'Rate Park' : 'Edit Rating' }}
            </RouterLink>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
