<script setup lang="ts">
import { computed } from 'vue'
import { Award, Users } from 'lucide-vue-next'
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
  },
  mode: {
    type: String,
    required: false,
    default: 'global',
    validator: (value: string) => ['global', 'personal', 'none'].includes(value)
  },
  rank: {
    type: Number,
    required: false,
    default: undefined
  }
})

const images = import.meta.glob<{ default: string }>('../assets/parks/*.webp', {
  eager: true
})

const imageSrc = computed(() => {
  const path = `../assets/parks/${props.slug}.webp`
  const mod = images[path]
  return mod?.default || (mod as unknown as string)
})

// TODO: if park data is not provided, fetch it from the API using slug
// TODO ranking of park shown (helps when searching)
</script>

<template>
  <div>
    <div
      class="border-accent bg-primary-tint relative flex w-xs flex-col overflow-hidden rounded-sm border-2 font-sans text-2xl font-semibold shadow"
      :class="[imageSrc ? 'h-[220px]' : 'max-h-[220px]']"
    >
      <div
        class="bg-primary border-accent z-10 flex place-content-center gap-2 border-b px-2 pb-1 font-serif"
      >
        <div class="grow">
          {{ props.name }}
        </div>
        <div
          v-if="mode === 'global'"
          class="flex shrink place-content-center gap-1 py-2 pr-2"
        >
          <Users :size="14" class="" />
          <span class="text-xxs">{{ props.raterCount }}</span>
        </div>
      </div>
      <div class="group relative flex min-h-0 flex-1 flex-col justify-end">
        <img
          v-if="imageSrc"
          :src="imageSrc"
          loading="lazy"
          alt=""
          class="absolute inset-0 z-0 h-full w-full object-cover"
        />
        <div
          v-if="rank"
          :key="mode"
          class="z-10 flex grow justify-end pt-2 pr-2"
        >
          <div v-if="rank > 3" class="flex flex-col">
            <div
              class="tape border-gray z-5 h-[10px] w-[20px] -rotate-2 place-self-center bg-amber-200/90"
            ></div>
            <div
              class="sticky-note bg-secondary-highlight mt-[-5px] flex rotate-2 flex-col items-center px-2 py-1 text-sm"
            >
              #{{ rank }}
            </div>
          </div>
          <div
            v-else
            class="relative flex rotate-3 flex-col items-center gap-0 text-sm text-slate-900"
          >
            <Award
              stroke-width="1"
              :size="40"
              :fill="
                rank === 1
                  ? 'var(--color-amber-400)'
                  : rank === 2
                    ? 'var(--color-slate-300)'
                    : 'var(--color-amber-700)'
              "
            />
            <span class="-mt-9.5" :class="rank === 3 ? 'text-stone-200' : ''">
              {{ rank }}
            </span>
          </div>
        </div>
        <div
          v-if="mode !== 'none'"
          class="z-10 flex items-center justify-between px-4 pb-4"
          :class="[imageSrc ? '' : 'pt-4']"
        >
          <div class="flex flex-col">
            <div
              class="tape border-gray z-5 h-[10px] w-[20px] -rotate-2 place-self-center bg-amber-200/90"
            ></div>
            <div
              class="sticky-note bg-secondary mt-[-5px] flex -rotate-2 flex-col items-center px-2 py-1"
            >
              <span
                v-if="mode === 'personal' || props.raterCount > 0"
                class="text-xxs"
                >{{ mode === 'global' ? 'Global Score' : 'Your Score' }}</span
              >
              <div v-else class="text-xxs flex flex-col items-center">
                <span>No</span><span>ratings</span><span>yet!</span>
              </div>
              <span
                v-if="mode === 'personal' || props.raterCount > 0"
                class="text-lg font-bold"
                >{{ props.aggregateScore }}</span
              >
            </div>
          </div>
          <div>
            <RouterLink
              :to="`/rate/${slug}`"
              class="btn-primary border-accent z-10 border-2 font-serif text-sm"
            >
              {{ mode === 'global' ? 'Rate Park' : 'Edit Rating' }}
            </RouterLink>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@reference '../assets/main.css';

.tape {
  clip-path: polygon(
    5% 0%,
    0% 10%,
    10% 25%,
    0% 50%,
    10% 75%,
    5% 100%,
    95% 100%,
    100% 75%,
    90% 50%,
    100% 25%,
    90% 10%,
    95% 0%
  );
}

.sticky-note {
  @apply font-display rounded-xs border border-black/10 shadow-[3px_3px_0_rgba(0,0,0,0.35)];
}
</style>
