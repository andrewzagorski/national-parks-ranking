<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '../utils/supabase'
import { useUserStore } from '../stores/user'
import { ChevronLeft, Save, Mountain, ChevronDown } from 'lucide-vue-next'
import rubric, { type RubricItem } from '../utils/rubric'

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
const metricsDetails = ref<
  Record<
    number,
    Metric & {
      expanded: boolean
      rubric: RubricItem[]
    }
  >
>({})

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

    metrics.value.forEach((m) => {
      metricsDetails.value[m.id] = {
        ...m,
        expanded: false,
        rubric: rubric[m.key as keyof typeof rubric] as RubricItem[]
      }
    })

    // Fetch existing ratings
    const { data: ratingsData } = await supabase
      .from('ratings')
      .select('metric_id, score')
      .eq('park_id', parkData.id)
      .eq('user_id', userStore.userId)

    if (ratingsData) {
      ratingsData.forEach((r) => {
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
  <div class="mx-auto max-w-3xl px-4 py-8">
    <button
      class="hover:text-primary group mb-8 flex items-center gap-2"
      @click="router.back()"
    >
      <ChevronLeft
        :size="20"
        class="transition-transform group-hover:-translate-x-1"
      />
      <span class="text-xs font-bold tracking-widest uppercase"
        >Back to Rankings</span
      >
    </button>

    <div v-if="loading" class="animate-pulse">
      <div class="bg-background mb-4 h-12 w-1/2 rounded"></div>
      <div class="mt-12 space-y-6">
        <div v-for="i in 5" :key="i" class="bg-background h-24 rounded"></div>
      </div>
    </div>

    <div v-else-if="park">
      <h1 class="mb-2 text-4xl md:text-5xl">{{ park.name }}</h1>
      <p class="mb-12 font-serif text-lg leading-relaxed italic">
        Record your impressions of this park. Every detail counts toward the
        rubric.
      </p>

      <div class="space-y-10">
        <div v-for="metric in metricsDetails" :key="metric.id" class="relative">
          <div
            class="hover:text-primary mb-4 flex cursor-pointer items-center gap-2 transition-all duration-200"
            :class="metric.expanded ? 'col-span-2' : 'col-start-1 row-start-1'"
            @click="metric.expanded = !metric.expanded"
          >
            <h3 class="font-display flex items-center gap-2 text-lg font-bold">
              <span class="bg-primary h-2 w-2 rounded-full"></span>
              {{ metric.label }}
            </h3>

            <ChevronDown :class="{ 'rotate-180': metric.expanded }" />
          </div>
          <div
            v-if="metric.expanded"
            class="bg-background-highlight col-span-2 mb-4 grid grid-cols-3 justify-center text-sm text-gray-600"
          >
            <div
              v-for="item in metric.rubric"
              :key="item.score"
              class="flex flex-col items-center p-2 shadow"
            >
              <div
                class="text-primary border-secondary font-display w-full border-b pb-2 text-center font-bold"
              >
                {{ item.score }}
              </div>
              <div class="flex grow flex-col justify-center text-center">
                {{ item.description }}
              </div>
            </div>
          </div>
          <div class="flex justify-between gap-2">
            <button
              v-for="score in 5"
              :key="score"
              class="font-display flex-1 rounded-lg border-2 py-4 text-xl font-bold transition-all"
              :class="[
                ratings[metric.id] === score
                  ? 'bg-primary border-accent shadow-sticker -translate-y-1 text-white'
                  : 'border-background-highlight/20 hover:border-primary/40 hover:text-writing/40 bg-white'
              ]"
              @click="setRating(metric.id, score)"
            >
              {{ score }}
            </button>
          </div>

          <div
            class="tracking-widest/30 mt-4 flex justify-between text-[10px] font-bold uppercase"
          >
            <span>Poor</span>
            <span>Exceptional</span>
          </div>

          <div class="hand-drawn-divider mt-8"></div>
        </div>
      </div>

      <div class="mt-16 flex flex-col items-center">
        <button
          :disabled="saving"
          class="btn-primary flex w-full max-w-sm items-center justify-center gap-3 py-4 text-lg"
          @click="saveRatings"
        >
          <Save v-if="!saving" :size="20" />
          <div v-else class="animate-spin"><Mountain :size="20" /></div>
          {{ saving ? 'Recording Notes...' : 'Save Field Notes' }}
        </button>
      </div>
    </div>
  </div>
</template>
