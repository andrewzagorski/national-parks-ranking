<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { supabase } from '../utils/supabase'
import { useUserStore } from '../stores/user'
import { Save, RefreshCw, Mountain, Info, CircleCheck } from 'lucide-vue-next'
import type { Database } from '../utils/database.types'

const userStore = useUserStore()

const metrics = ref<Database['public']['Tables']['metrics']['Row'][]>([])
const weights = ref<Record<number, number>>({})
const loading = ref(true)
const saving = ref(false)
const lastUserWeights = ref<Record<number, number>>({})

// TODO rework for pinia

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
    weightsData.forEach((w) => {
      weights.value[w.metric_id] = w.weight
    })
  } else {
    // Use defaults
    metrics.value.forEach((m) => {
      weights.value[m.id] = m.default_weight
    })
  }

  lastUserWeights.value = { ...weights.value }

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

  lastUserWeights.value = { ...weights.value }

  if (error) {
    console.error('Error saving weights:', error)
  }
  saving.value = false
}

const resetWeights = () => {
  weights.value = { ...lastUserWeights.value }
}

onMounted(() => {
  fetchData()
})
</script>

<template>
  <div class="mx-auto max-w-3xl px-4 py-8 md:py-12">
    <div class="mb-12">
      <h1 class="mb-4 text-4xl md:text-5xl">Customize Rubric</h1>
      <p class="text-lg leading-relaxed">
        What makes a park great is personal. Adjust the sliders to reflect your
        values. Your rankings will update automatically to match your unique
        rubric.
      </p>
    </div>

    <div v-if="loading" class="animate-pulse space-y-8">
      <div v-for="i in 5" :key="i" class="bg-background h-20 rounded"></div>
    </div>

    <div v-else class="space-y-12">
      <div v-for="metric in metrics" :key="metric.id" class="group">
        <div class="mb-4 flex items-end justify-between">
          <div>
            <VTooltip
              :triggers="['hover']"
              class="hidden items-center gap-2 sm:flex"
            >
              <h3
                class="font-display group-hover:text-primary text-xl font-bold transition-colors"
              >
                {{ metric.label }}
              </h3>
              <template #popper>
                {{ metric.description }}
              </template>
              <Info :size="12" class="text-primary" />
            </VTooltip>
            <div class="flex items-center gap-2 sm:hidden">
              <h3
                class="font-display group-hover:text-primary text-xl font-bold transition-colors"
              >
                {{ metric.label }}
              </h3>
              <VTooltip
                :triggers="['click', 'touch']"
                :auto-hide="true"
                class="cursor-pointer"
              >
                <Info :size="12" class="text-primary" />
                <template #popper>
                  {{ metric.description }}
                </template>
              </VTooltip>
            </div>
            <span class="tracking-widest/30 text-[10px] font-bold uppercase"
              >Importance Weight</span
            >
          </div>
          <span
            class="font-display text-primary border-background-highlight rounded border bg-white px-3 py-1 text-3xl font-bold shadow-sm"
          >
            {{ weights[metric.id] }}%
          </span>
        </div>

        <input
          v-model.number="weights[metric.id]"
          type="range"
          min="0"
          max="50"
          class="bg-background-highlight accent-primary h-2 w-full cursor-pointer appearance-none rounded-lg"
        />
      </div>

      <!-- Footer Actions -->
      <div
        class="border-accent shadow-sticker sticky bottom-20 mx-auto mt-16 grid grid-cols-2 items-center justify-items-center gap-4 rounded-2xl border-2 bg-white/80 p-4 backdrop-blur-md sm:w-fit md:bottom-8"
      >
        <div class="col-span-1">
          <span
            class="block text-center text-[10px] font-bold tracking-widest uppercase"
            >Total Distribution</span
          >
          <div class="flex items-center gap-2">
            <span
              class="font-display flex grow items-center justify-center text-2xl font-bold"
              :class="totalWeight === 100 ? 'text-primary' : 'text-secondary'"
            >
              {{ totalWeight }}%
            </span>
            <CircleCheck
              v-if="totalWeight === 100"
              :size="20"
              class="text-primary"
            />
            <button
              v-else
              class="font-display hover:text-writing flex flex-1 items-center justify-center gap-2 text-sm font-bold tracking-widest uppercase transition-colors md:flex-none"
              @click="resetWeights"
            >
              <RefreshCw :size="16" />
              Reset
            </button>
          </div>
        </div>

        <div class="col-span-1 flex w-full gap-4 md:w-auto">
          <button
            :disabled="saving"
            class="btn-primary flex flex-1 items-center justify-center gap-2 md:flex-none"
            @click="saveWeights"
          >
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
@reference "../assets/main.css";

input[type='range']::-webkit-slider-thumb {
  @apply bg-primary border-accent h-6 w-6 cursor-pointer appearance-none rounded-full border-2 shadow-sm transition-transform hover:scale-110;
}
</style>
