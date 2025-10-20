<script setup>
import Header from './components/Header.vue'
import Hero from './components/Hero.vue'
import About from './components/About.vue'
import Skills from './components/Skills.vue'
import Projects from './components/Projects.vue'
import Contact from './components/Contact.vue'
import Footer from './components/Footer.vue'
</script>

<template>
  <div class="app-container">
    <Header />
    <main>
      <Hero />
      <About />
      <Skills />
      <Projects />
      <Contact />
    </main>
    <Footer />
  </div>
</template>

<style scoped>
.app-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

main {
  flex: 1;
}
</style>
