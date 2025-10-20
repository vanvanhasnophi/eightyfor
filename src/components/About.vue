<template>
  <section id="about" class="section about">
    <h2 class="section-title">About Me</h2>
    <div class="about-content">
      <div class="about-text">
        <p>
          I'm a passionate full-stack developer with a love for creating elegant solutions 
          to complex problems. With expertise in modern web technologies, I specialize in 
          building responsive, user-friendly applications that deliver exceptional user experiences.
        </p>
        <p>
          When I'm not coding, you can find me exploring new technologies, contributing to 
          open-source projects, or sharing knowledge with the developer community.
        </p>
      </div>
    </div>
  </section>
</template>

<script setup>
</script>

<style scoped>
.about {
  background: var(--color-background-soft);
}

.about-content {
  max-width: 800px;
  margin: 0 auto;
}

.about-text {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.about-text p {
  font-size: 1.1rem;
  line-height: 1.8;
  color: var(--color-text);
  text-align: center;
}

@media (max-width: 768px) {
  .about-text p {
    font-size: 1rem;
  }
}
</style>
