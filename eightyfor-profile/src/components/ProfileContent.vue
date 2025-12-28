<script setup>
import { ref } from 'vue'

defineProps({
  name: String,
  mail1: String,
  mail2: String
})

const count = ref(0)

const copyToClipboard = (text) => {
  navigator.clipboard.writeText(text).then(() => {
    alert('Copied to clipboard: ' + text)
  }).catch(err => {
    console.error('Failed to copy: ', err)
  })
}
</script>

<template>
  <h1>{{ name }}</h1>
  Undergraduate in IMIS @ THU&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Download Resume:&nbsp;<a href="./download/resume.pdf" class="glowable">PDF</a>&nbsp;/&nbsp;<a href="./download/resume.html.zip" class="glowable">HTML</a>
  <br>
  Contact:&nbsp;<a href="#" @click.prevent="copyToClipboard(mail1)" class="glowable">{{ mail1 }}</a>&nbsp;|&nbsp;<a href="#" @click.prevent="copyToClipboard(mail2)" class="glowable">{{ mail2 }}</a>



</template>

<style scoped>
.read-the-docs {
  color: #888;
}
</style>
