<template>
  <section id="contact" class="section contact">
    <h2 class="section-title">Get In Touch</h2>
    <div class="contact-content">
      <p class="contact-intro">
        I'm always open to new opportunities and collaborations. 
        Feel free to reach out!
      </p>
      <div class="contact-methods">
        <a href="mailto:hello@eightyfor.dev" class="contact-method">
          <span class="contact-icon">✉️</span>
          <span>hello@eightyfor.dev</span>
        </a>
        <a href="https://github.com/vanvanhasnophi" class="contact-method" target="_blank" rel="noopener">
          <span class="contact-icon">🐙</span>
          <span>GitHub</span>
        </a>
        <a href="https://linkedin.com/in/yourprofile" class="contact-method" target="_blank" rel="noopener">
          <span class="contact-icon">💼</span>
          <span>LinkedIn</span>
        </a>
        <a href="https://twitter.com/yourprofile" class="contact-method" target="_blank" rel="noopener">
          <span class="contact-icon">🐦</span>
          <span>Twitter</span>
        </a>
      </div>
    </div>
  </section>
</template>

<script setup>
</script>

<style scoped>
.contact {
  background: var(--color-background);
}

.contact-content {
  max-width: 800px;
  margin: 0 auto;
  text-align: center;
}

.contact-intro {
  font-size: 1.2rem;
  color: var(--color-text);
  margin-bottom: 3rem;
  line-height: 1.8;
}

.contact-methods {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.contact-method {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  padding: 2rem 1rem;
  background: var(--color-background-soft);
  border-radius: 12px;
  border: 1px solid var(--color-border);
  transition: all 0.3s;
  text-decoration: none;
  color: var(--color-text);
}

.contact-method:hover {
  transform: translateY(-5px);
  border-color: var(--color-accent);
  box-shadow: 0 10px 20px rgba(0, 212, 255, 0.2);
  color: var(--color-accent);
}

.contact-icon {
  font-size: 2.5rem;
}

@media (max-width: 768px) {
  .contact-methods {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .contact-intro {
    font-size: 1rem;
  }
}
</style>
