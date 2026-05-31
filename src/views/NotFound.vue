<template>
  <div>
    <div class="flex flex-col items-center gap-4 pt-20">
      <h1 class="text-4xl font-bold">{{ message.title }}</h1>
      <p class="text-lg">{{ message.message }}</p>
      <p
        class="text-primary hover:text-primary-highlight cursor-pointer text-lg"
        @click="$router.back()"
      >
        Go back
      </p>
    </div>
  </div>
</template>
<script setup lang="ts">
import { onMounted, ref } from 'vue'
const messages: { title: string; message: string }[] = [
  {
    title: 'Not all who wander are lost...',
    message: 'But you happen to be.'
  },
  { title: 'Blazing a new trail?', message: "Let's get you back on course." },
  {
    title: 'Is this what they call "backcountry?"',
    message: "Unfortunately, you don't have a permit."
  },
  {
    title: 'Holy smokes is that bigfoot?!?',
    message: 'Nope, just a lost hiker.'
  }
]

const message = ref({ title: '', message: '' })

onMounted(() => {
  message.value = messages[Math.floor(Math.random() * messages.length)]
})
</script>
