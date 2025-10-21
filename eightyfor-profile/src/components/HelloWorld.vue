<script setup>
import { ref } from 'vue'

defineProps({
  name: String,
})

const count = ref(0)
</script>

<template>
  <h1>{{ name }}</h1>


</template>

<style scoped>
.read-the-docs {
  color: #888;
}
</style>
