<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { supabase } from '../utils/supabase'
import { useUserStore } from '../stores/user'
import { Save, RefreshCw, Mountain } from 'lucide-vue-next'

const userStore = useUserStore()

interface Metric {
  id: number
  key: string
  label: string
  default_weight: number
}

const metrics = ref<Metric[]>([])
const weights = ref<Record<number, number>>({})
const loading = ref(true)
const saving = ref(false)

const fetchData = async () => {
  loading.value = true
  
  // Fetch metrics
  const { data: metricsData } = await supabase
    .from('metrics')
    .select('*')
    .order('sort_order')
  
  metrics.value = metricsData || []
  
  // Fetch existing weights
  const { data: weightsData } = await supabase
    .from('user_weights')
    .select('metric_id, weight')
    .eq('user_id', userStore.userId)
  
  if (weightsData && weightsData.length > 0) {
    weightsData.forEach(w => {
      weights.value[w.metric_id] = w.weight
    })
  } else {
    // Use defaults
    metrics.value.forEach(m => {
      weights.value[m.id] = m.default_weight
    })
  }
  
  loading.value = false
}

const totalWeight = computed(() => {
  return Object.values(weights.value).reduce((a, b) => a + b, 0)
})

const saveWeights = async () => {
  saving.value = true
  
  const upserts = Object.entries(weights.value).map(([metricId, weight]) => ({
    user_id: userStore.userId,
    metric_id: parseInt(metricId),
    weight
  }))
  
  const { error } = await supabase
    .from('user_weights')
    .upsert(upserts, { onConflict: 'user_id, metric_id' })
  
  if (error) {
    console.error('Error saving weights:', error)
  }
  saving.value = false
}

const resetWeights = () => {
  metrics.value.forEach(m => {
    weights.value[m.id] = m.default_weight
  })
}

onMounted(() => {
  fetchData()
})
</script>

<template>
  <div class="max-w-3xl mx-auto px-4 py-8 md:py-12">
    <div class="mb-12">
      <h1 class="text-4xl md:text-5xl mb-4 text-charcoal">Customize Rubric</h1>
      <p class="text-lg text-charcoal/60 leading-relaxed">
        What makes a park great is personal. Adjust the sliders to reflect your values. 
        Your rankings will update automatically to match your unique rubric.
      </p>
    </div>

    <div v-if="loading" class="space-y-8 animate-pulse">
      <div v-for="i in 5" :key="i" class="h-20 bg-sand rounded"></div>
    </div>

    <div v-else class="space-y-12">
      <div v-for="metric in metrics" :key="metric.id" class="group">
        <div class="flex justify-between items-end mb-4">
          <div>
            <h3 class="font-display font-bold text-xl group-hover:text-sage transition-colors">{{ metric.label }}</h3>
            <span class="text-[10px] font-bold uppercase tracking-widest text-charcoal/30">Importance Weight</span>
          </div>
          <span class="text-3xl font-display font-bold text-sage bg-white border border-sand-container px-3 py-1 rounded shadow-sm">
            {{ weights[metric.id] }}%
          </span>
        </div>
        
        <input 
          type="range" 
          v-model.number="weights[metric.id]" 
          min="0" 
          max="50"
          class="w-full h-2 bg-sand-container rounded-lg appearance-none cursor-pointer accent-sage"
        >
      </div>

      <!-- Footer Actions -->
      <div class="sticky bottom-20 md:bottom-8 bg-white/80 backdrop-blur-md p-6 rounded-2xl border-2 border-charcoal shadow-sticker mt-16 flex flex-col md:flex-row gap-4 items-center justify-between">
        <div class="text-center md:text-left">
          <span class="text-[10px] font-bold uppercase tracking-widest text-charcoal/40 block">Total Distribution</span>
          <span class="text-2xl font-display font-bold" :class="totalWeight === 100 ? 'text-sage' : 'text-terracotta'">
            {{ totalWeight }}%
          </span>
          <p v-if="totalWeight !== 100" class="text-xs text-terracotta italic mt-1 font-bold">Recommended: 100%</p>
        </div>

        <div class="flex gap-4 w-full md:w-auto">
          <button @click="resetWeights" class="flex-1 md:flex-none flex items-center justify-center gap-2 px-6 py-3 font-display font-bold text-sm uppercase tracking-widest text-charcoal/60 hover:text-charcoal transition-colors">
            <RefreshCw :size="16" />
            Reset
          </button>
          <button @click="saveWeights" :disabled="saving" class="btn-primary flex-1 md:flex-none flex items-center justify-center gap-2">
            <Save v-if="!saving" :size="20" />
            <div v-else class="animate-spin"><Mountain :size="20" /></div>
            {{ saving ? 'Saving...' : 'Save Rubric' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@reference "../style.css";

input[type=range]::-webkit-slider-thumb {
  @apply appearance-none w-6 h-6 bg-sage border-2 border-charcoal rounded-full shadow-sm cursor-pointer hover:scale-110 transition-transform;
}
</style>
