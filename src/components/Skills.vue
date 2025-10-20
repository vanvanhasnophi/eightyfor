<template>
  <section id="skills" class="section skills">
    <h2 class="section-title">Skills & Technologies</h2>
    <div class="skills-grid">
      <div class="skill-card" v-for="skill in skills" :key="skill.name">
        <div class="skill-icon">{{ skill.icon }}</div>
        <h3>{{ skill.name }}</h3>
        <p>{{ skill.description }}</p>
      </div>
    </div>
  </section>
</template>

<script setup>
const skills = [
  {
    name: 'Frontend',
    icon: '🎨',
    description: 'Vue.js, React, HTML5, CSS3, JavaScript'
  },
  {
    name: 'Backend',
    icon: '⚙️',
    description: 'Node.js, Python, Java, RESTful APIs'
  },
  {
    name: 'Database',
    icon: '🗄️',
    description: 'MongoDB, MySQL, PostgreSQL, Redis'
  },
  {
    name: 'DevOps',
    icon: '🚀',
    description: 'Docker, Git, CI/CD, Cloud Services'
  },
  {
    name: 'Design',
    icon: '✨',
    description: 'UI/UX, Figma, Responsive Design'
  },
  {
    name: 'Tools',
    icon: '🛠️',
    description: 'VS Code, Webpack, Vite, npm/yarn'
  }
]
</script>

<style scoped>
.skills {
  background: var(--color-background);
}

.skills-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.skill-card {
  background: var(--color-background-soft);
  padding: 2rem;
  border-radius: 12px;
  text-align: center;
  transition: all 0.3s;
  border: 1px solid var(--color-border);
}

.skill-card:hover {
  transform: translateY(-10px);
  border-color: var(--color-accent);
  box-shadow: 0 10px 30px rgba(0, 212, 255, 0.2);
}

.skill-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.skill-card h3 {
  font-size: 1.5rem;
  margin-bottom: 1rem;
  color: var(--color-heading);
}

.skill-card p {
  color: var(--color-text);
  line-height: 1.6;
}

@media (max-width: 768px) {
  .skills-grid {
    grid-template-columns: 1fr;
  }
}
</style>
