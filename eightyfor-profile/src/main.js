import { createApp } from 'vue'
import './style.css'
import Root from './Root.vue'
import router from './router'

createApp(Root).use(router).mount('#app')

// 判断是否为苹果系统，并设置字体变量
if (/Mac|iPhone|iPad|iPod/i.test(navigator.userAgent)) {
	document.documentElement.style.setProperty('--app-font-stack', 'var(--app-font-stack-system)');
} else {
	document.documentElement.style.setProperty('--app-font-stack', 'var(--app-font-stack-inter)');
}
