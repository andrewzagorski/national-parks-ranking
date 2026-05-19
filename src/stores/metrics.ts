import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { supabase } from '../utils/supabase'
import type { Database } from '../utils/database.types'

export const useMetricsStore = defineStore('metrics', () => {
  const metrics = ref<Database['public']['Tables']['metrics']['Row'][]>([])
  const weights = ref<Database['public']['Tables']['user_weights']['Row'][]>([])

  const userWeights = computed(() => {
    const weightMap: Record<number, number> = {}
    metrics.value.forEach((m) => {
      const userWeight = weights.value.find((w) => w.metric_id === m.id)
      weightMap[m.id] = userWeight ? userWeight.weight : m.default_weight
    })
    return weightMap
  })

  const fetchMetrics = async () => {
    const { data } = await supabase.from('metrics').select('*')
    metrics.value = data || []
  }

  const fetchWeights = async (userId: string | null) => {
    if (!userId) {
      weights.value = []
      return
    }
    const { data } = await supabase
      .from('user_weights')
      .select('*')
      .eq('user_id', userId)
    weights.value = data || []
  }

  return {
    metrics,
    weights,
    userWeights,
    fetchMetrics,
    fetchWeights
  }
})
