<script setup lang="ts">
import { Users } from 'lucide-vue-next'
const props = defineProps({
  slug: {
    type: String,
    required: true
  },
  id: {
    type: Number,
    required: false,
    default: 0
  },
  name: {
    type: String,
    required: false,
    default: ''
  },
  raterCount: {
    type: Number,
    required: false,
    default: 0
  },
  aggregateScore: {
    type: Number,
    required: false,
    default: 0
  },
  size: {
    type: String,
    required: false,
    default: 'sm',
    validator: (value: string) => ['sm', 'xl'].includes(value)
  }
})

// TODO: if park data is not provided, fetch it from the API using slug
</script>

<template>
  <div class="m-4 p-4">
    <div
      :class="[
        'bg-background-tint border-accent rounded-sm border-2 font-sans text-2xl font-semibold',
        props.size === 'sm' ? 'h-48 max-w-xs' : 'h-64 max-w-lg'
      ]"
    >
      <div
        class="bg-primary border-accent flex place-content-center gap-2 border-b px-2 pb-1"
      >
        <div class="grow">
          {{ props.name }}
        </div>
        <div class="flex shrink place-content-center gap-0 py-2 pr-2">
          <Users :size="16" class="" />
          <span class="text-sm">{{ props.raterCount }}</span>
        </div>
      </div>
      <div class="text-secondary">{{ props.aggregateScore }}</div>
    </div>
  </div>
</template>
