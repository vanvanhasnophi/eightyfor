import { createRouter, createWebHistory } from 'vue-router'
import App from '../App.vue'
import Gift4U from '../components/Gift4U.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: App
  },
  {
    path: '/lol',
    name: 'Lol',
    component: Gift4U
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
