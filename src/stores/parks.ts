import { defineStore } from 'pinia'
import { ref } from 'vue'
import { supabase } from '../utils/supabase'
import type { Database } from '../utils/database.types'

export const useParksStore = defineStore('parks', () => {
  const parks = ref<Database['public']['Tables']['parks']['Row'][]>([])

  const fetchParks = async () => {
    if (parks.value.length > 0) {
      return
    }
    const { data } = await supabase.from('parks').select('*')
    parks.value = data || []
  }

  return {
    parks,
    fetchParks
  }
})
