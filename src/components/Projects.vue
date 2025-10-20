<template>
  <section id="projects" class="section projects">
    <h2 class="section-title">Featured Projects</h2>
    <div class="projects-grid">
      <div class="project-card" v-for="project in projects" :key="project.name">
        <div class="project-header">
          <h3>{{ project.name }}</h3>
          <div class="project-tags">
            <span class="tag" v-for="tag in project.tags" :key="tag">{{ tag }}</span>
          </div>
        </div>
        <p class="project-description">{{ project.description }}</p>
        <div class="project-links">
          <a :href="project.github" class="project-link" target="_blank" rel="noopener">
            View Code
          </a>
          <a :href="project.demo" class="project-link" target="_blank" rel="noopener">
            Live Demo
          </a>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
const projects = [
  {
    name: 'E-Commerce Platform',
    description: 'A full-featured e-commerce platform with shopping cart, payment integration, and admin dashboard.',
    tags: ['Vue.js', 'Node.js', 'MongoDB'],
    github: '#',
    demo: '#'
  },
  {
    name: 'Task Management App',
    description: 'Collaborative task management application with real-time updates and team collaboration features.',
    tags: ['React', 'Firebase', 'Material-UI'],
    github: '#',
    demo: '#'
  },
  {
    name: 'Weather Dashboard',
    description: 'Beautiful weather dashboard with forecasts, interactive maps, and location-based services.',
    tags: ['Vue.js', 'API', 'Charts.js'],
    github: '#',
    demo: '#'
  }
]
</script>

<style scoped>
.projects {
  background: var(--color-background-soft);
}

.projects-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.project-card {
  background: var(--color-background);
  padding: 2rem;
  border-radius: 12px;
  border: 1px solid var(--color-border);
  transition: all 0.3s;
  display: flex;
  flex-direction: column;
}

.project-card:hover {
  transform: translateY(-10px);
  border-color: var(--color-accent);
  box-shadow: 0 10px 30px rgba(0, 212, 255, 0.2);
}

.project-header {
  margin-bottom: 1rem;
}

.project-card h3 {
  font-size: 1.5rem;
  margin-bottom: 1rem;
  color: var(--color-heading);
}

.project-tags {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
  margin-bottom: 1rem;
}

.tag {
  background: var(--color-background-mute);
  color: var(--color-accent);
  padding: 0.3rem 0.8rem;
  border-radius: 20px;
  font-size: 0.85rem;
  border: 1px solid var(--color-border);
}

.project-description {
  color: var(--color-text);
  line-height: 1.6;
  margin-bottom: 1.5rem;
  flex: 1;
}

.project-links {
  display: flex;
  gap: 1rem;
}

.project-link {
  flex: 1;
  text-align: center;
  padding: 0.75rem 1rem;
  background: transparent;
  border: 2px solid var(--color-accent);
  border-radius: 6px;
  color: var(--color-accent);
  text-decoration: none;
  transition: all 0.3s;
  font-weight: 600;
}

.project-link:hover {
  background: var(--color-accent);
  color: var(--color-background);
}

@media (max-width: 768px) {
  .projects-grid {
    grid-template-columns: 1fr;
  }
}
</style>
