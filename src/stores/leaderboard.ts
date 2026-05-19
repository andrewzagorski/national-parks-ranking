import { defineStore } from 'pinia'
import { ref } from 'vue'
import { supabase } from '../utils/supabase'
import type { Database } from '../utils/database.types'
import type { ParkScore } from '../utils/database.types'

export const useLeaderboardStore = defineStore('leaderboard', () => {
  const personalRatings = ref<Database['public']['Tables']['ratings']['Row'][]>(
    []
  )
  const personalLeaderboard = ref<ParkScore[]>([])
  const isLoadingPersonalLeaderboard = ref(false)
  const globalLeaderboard = ref<ParkScore[]>([])
  const isLoadingGlobalLeaderboard = ref(false)
  const mode = ref<'global' | 'personal'>('global')
  const searchQuery = ref('')

  const fetchPersonalRatings = async (userId: string | null) => {
    if (!userId) {
      personalRatings.value = []
      return
    }

    const { data } = await supabase
      .from('ratings')
      .select('*')
      .eq('user_id', userId)

    personalRatings.value = data || []
  }

  const fetchPersonalLeaderboard = async (
    userId: string | null,
    parks: Database['public']['Tables']['parks']['Row'][],
    userWeights: Record<number, number>
  ) => {
    await fetchPersonalRatings(userId)
    const results: ParkScore[] = parks.map((park) => {
      const parkRatings =
        personalRatings.value.filter((r) => r.park_id === park.id) || []

      let totalScore = 0
      let ratedCount = 0

      parkRatings.forEach((r) => {
        const weight = userWeights[r.metric_id] || 0
        totalScore += ((r.score - 1) / 4.0) * weight
        ratedCount++
      })

      return {
        park_id: park.id,
        park_name: park.name,
        park_slug: park.slug,
        aggregate_score: Math.round(totalScore * 10) / 10,
        rater_count: ratedCount > 0 ? 1 : 0,
        rank: 0
      }
    })

    personalLeaderboard.value = results
      .filter((r) => r.rater_count > 0)
      .sort((a, b) => b.aggregate_score - a.aggregate_score)
      .map((item, index) => ({
        ...item,
        rank: index + 1
      }))
  }

  const fetchGlobalLeaderboard = async () => {
    // TODO cache timeout every x minutes; also update after user updates weights or rates a park
    if (globalLeaderboard.value.length > 0) {
      return
    }
    const { data, error } = await supabase.from('aggregate_scores').select('*')

    if (error) {
      console.error('Error fetching global leaderboard:', error)
    } else {
      globalLeaderboard.value = data.map((item, index) => ({
        ...item,
        rank: index + 1
      }))
    }
  }

  return {
    fetchPersonalLeaderboard,
    fetchGlobalLeaderboard,
    personalLeaderboard,
    isLoadingPersonalLeaderboard,
    globalLeaderboard,
    isLoadingGlobalLeaderboard,
    mode,
    searchQuery
  }
})
