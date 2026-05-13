<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '../utils/supabase'
import { useUserStore } from '../stores/user'
import { ChevronLeft, Save, Mountain } from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

interface Park {
  id: number
  name: string
  slug: string
}

interface Metric {
  id: number
  key: string
  label: string
}

interface Rating {
  metric_id: number
  score: number
}

const park = ref<Park | null>(null)
const metrics = ref<Metric[]>([])
const ratings = ref<Record<number, number>>({})
const loading = ref(true)
const saving = ref(false)

const fetchData = async () => {
  loading.value = true
  const slug = route.params.slug as string
  
  // Fetch park
  const { data: parkData } = await supabase
    .from('parks')
    .select('*')
    .eq('slug', slug)
    .single()
  
  if (parkData) {
    park.value = parkData
    
    // Fetch metrics
    const { data: metricsData } = await supabase
      .from('metrics')
      .select('*')
      .order('sort_order')
    
    metrics.value = metricsData || []
    
    // Fetch existing ratings
    const { data: ratingsData } = await supabase
      .from('ratings')
      .select('metric_id, score')
      .eq('park_id', parkData.id)
      .eq('user_id', userStore.userId)
    
    if (ratingsData) {
      ratingsData.forEach(r => {
        ratings.value[r.metric_id] = r.score
      })
    }
  }
  
  loading.value = false
}

const setRating = (metricId: number, score: number) => {
  ratings.value[metricId] = score
}

const saveRatings = async () => {
  if (!park.value) return
  saving.value = true
  
  const upserts = Object.entries(ratings.value).map(([metricId, score]) => ({
    user_id: userStore.userId,
    park_id: park.value!.id,
    metric_id: parseInt(metricId),
    score
  }))
  
  const { error } = await supabase
    .from('ratings')
    .upsert(upserts, { onConflict: 'user_id, park_id, metric_id' })
  
  if (error) {
    console.error('Error saving ratings:', error)
  } else {
    router.push('/')
  }
  saving.value = false
}

onMounted(() => {
  fetchData()
})
</script>

<template>
  <div class="max-w-3xl mx-auto px-4 py-8">
    <button @click="router.back()" class="flex items-center gap-2 text-charcoal/40 hover:text-sage mb-8 group">
      <ChevronLeft :size="20" class="group-hover:-translate-x-1 transition-transform" />
      <span class="font-bold uppercase tracking-widest text-xs">Back to Rankings</span>
    </button>

    <div v-if="loading" class="animate-pulse">
      <div class="h-12 bg-sand w-1/2 rounded mb-4"></div>
      <div class="space-y-6 mt-12">
        <div v-for="i in 5" :key="i" class="h-24 bg-sand rounded"></div>
      </div>
    </div>

    <div v-else-if="park">
      <h1 class="text-4xl md:text-5xl mb-2 text-charcoal">{{ park.name }}</h1>
      <p class="text-charcoal/60 italic mb-12 font-serif text-lg leading-relaxed">
        Record your impressions of this park. Every detail counts toward the rubric.
      </p>

      <div class="space-y-10">
        <div v-for="metric in metrics" :key="metric.id" class="relative">
          <h3 class="font-display font-bold text-lg mb-4 flex items-center gap-2">
            <span class="w-2 h-2 rounded-full bg-sage"></span>
            {{ metric.label }}
          </h3>
          
          <div class="flex justify-between gap-2">
            <button 
              v-for="score in 5" 
              :key="score"
              @click="setRating(metric.id, score)"
              class="flex-1 py-4 rounded-lg border-2 transition-all font-display font-bold text-xl"
              :class="[
                ratings[metric.id] === score 
                  ? 'bg-sage border-charcoal text-white shadow-sticker -translate-y-1' 
                  : 'bg-white border-sand-container text-charcoal/20 hover:border-sage/40 hover:text-charcoal/40'
              ]"
            >
              {{ score }}
            </button>
          </div>
          
          <div class="mt-4 flex justify-between text-[10px] font-bold uppercase tracking-widest text-charcoal/30">
            <span>Poor</span>
            <span>Exceptional</span>
          </div>
          
          <div class="hand-drawn-divider mt-8"></div>
        </div>
      </div>

      <div class="mt-16 flex flex-col items-center">
        <button 
          @click="saveRatings" 
          :disabled="saving"
          class="btn-primary w-full max-w-sm flex items-center justify-center gap-3 py-4 text-lg"
        >
          <Save v-if="!saving" :size="20" />
          <div v-else class="animate-spin"><Mountain :size="20" /></div>
          {{ saving ? 'Recording Notes...' : 'Save Field Notes' }}
        </button>
      </div>
    </div>
  </div>
</template>
