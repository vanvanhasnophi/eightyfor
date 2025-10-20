<template>
  <section id="home" class="hero">
    <div class="hero-content">
      <h1 class="hero-title">
        Hi, I'm <span class="highlight">EightyFor</span>
      </h1>
      <p class="hero-subtitle">Full Stack Developer & Creative Designer</p>
      <p class="hero-description">
        I build amazing web experiences with modern technologies
      </p>
      <div class="hero-buttons">
        <a href="#projects" class="btn btn-primary">View Projects</a>
        <a href="#contact" class="btn btn-secondary">Get In Touch</a>
      </div>
    </div>
  </section>
</template>

<script setup>
</script>

<style scoped>
.hero {
  min-height: calc(100vh - 80px);
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, var(--color-background) 0%, var(--color-background-soft) 100%);
  position: relative;
  overflow: hidden;
}

.hero::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: radial-gradient(circle at 20% 50%, rgba(0, 212, 255, 0.1) 0%, transparent 50%),
              radial-gradient(circle at 80% 80%, rgba(255, 0, 110, 0.1) 0%, transparent 50%);
  pointer-events: none;
}

.hero-content {
  text-align: center;
  max-width: 800px;
  padding: 2rem;
  position: relative;
  z-index: 1;
}

.hero-title {
  font-size: 4rem;
  font-weight: 700;
  margin-bottom: 1rem;
  color: var(--color-heading);
  line-height: 1.2;
}

.highlight {
  background: linear-gradient(135deg, var(--color-accent), var(--color-secondary));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero-subtitle {
  font-size: 1.5rem;
  color: var(--color-accent);
  margin-bottom: 1rem;
  font-weight: 500;
}

.hero-description {
  font-size: 1.2rem;
  color: var(--color-text);
  margin-bottom: 2rem;
}

.hero-buttons {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

.btn {
  padding: 1rem 2rem;
  border-radius: 8px;
  font-weight: 600;
  transition: all 0.3s;
  cursor: pointer;
  border: 2px solid transparent;
}

.btn-primary {
  background: var(--color-accent);
  color: var(--color-background);
}

.btn-primary:hover {
  background: var(--color-accent-dark);
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(0, 212, 255, 0.3);
}

.btn-secondary {
  background: transparent;
  color: var(--color-accent);
  border-color: var(--color-accent);
}

.btn-secondary:hover {
  background: var(--color-accent);
  color: var(--color-background);
  transform: translateY(-2px);
}

@media (max-width: 768px) {
  .hero-title {
    font-size: 2.5rem;
  }
  
  .hero-subtitle {
    font-size: 1.2rem;
  }
  
  .hero-description {
    font-size: 1rem;
  }
  
  .btn {
    padding: 0.8rem 1.5rem;
  }
}
</style>
