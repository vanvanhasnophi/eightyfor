<template>
  <footer class="footer">
    <div class="footer-content">
      <p>&copy; {{ currentYear }} EightyFor. Built with Vue.js</p>
    </div>
  </footer>
</template>

<script setup>
import { computed } from 'vue'

const currentYear = computed(() => new Date().getFullYear())
</script>

<style scoped>
.footer {
  background: var(--color-background-soft);
  border-top: 1px solid var(--color-border);
  padding: 2rem;
  margin-top: auto;
}

.footer-content {
  max-width: 1200px;
  margin: 0 auto;
  text-align: center;
  color: var(--color-text);
}
</style>
