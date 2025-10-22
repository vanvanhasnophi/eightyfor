<script setup>
import HelloWorld from './components/HelloWorld.vue'
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const glowPos = ref({ x: 0, y: 0 })
const glowVisible = ref(false)
const glowAttached = ref(false)
const currentGlowTarget = ref(null)
const glowOpacity = ref(0)
const controlGlowOpacity = ref(0)
const glowScale = ref(0.4)
const lightsOff = ref(false)
const bugs = ref([])
let hideTimeout = null
let bugSpawnInterval = null

function handleMouseMove(e) {
  glowPos.value = { x: e.clientX, y: e.clientY }

  // 取消之前的隐藏定时器
  if (hideTimeout) {
    clearTimeout(hideTimeout)
    hideTimeout = null
  }

  if (!glowVisible.value) {
    glowVisible.value = true
    glowScale.value = 0.4
    // 延迟触发渐入动画
    setTimeout(() => {
      glowOpacity.value = 0.6
      glowScale.value = 1
    }, 10)
  } else if (!glowAttached.value) {
    glowOpacity.value = 0.6
    glowScale.value = 1
  }

  // 检测是否悬停在可发光控件上
  const target = e.target.closest('.glowable')
  if (target && target !== currentGlowTarget.value) {
    attachGlow(target)
  } else if (!target && currentGlowTarget.value) {
    detachGlow()
  }
}

function handleMouseLeave() {
  glowOpacity.value = 0
  glowScale.value = 0.4
  hideTimeout = setTimeout(() => {
    glowVisible.value = false
    hideTimeout = null
  }, 300) // 等待动画完成后隐藏
  detachGlow()
}

function attachGlow(target) {
  currentGlowTarget.value = target
  glowAttached.value = true


  // 延迟后渐入控件发光
  setTimeout(() => {
    controlGlowOpacity.value = 1
    target.style.filter = `drop-shadow(0 0 2em rgba(255,255,255, ${controlGlowOpacity.value * 0.533}))`
    target.style.transition = 'filter 200ms ease-out'
  }, 0)
}

function detachGlow() {
  if (currentGlowTarget.value) {
    // 渐出控件发光
    controlGlowOpacity.value = 0
    currentGlowTarget.value.style.filter = 'drop-shadow(0 0 2em rgba(255,255,255, 0))'

    // 同时渐入指针发光
    setTimeout(() => {
      glowOpacity.value = 0.6
      glowScale.value = 1
    }, 10)

    setTimeout(() => {
      if (currentGlowTarget.value) {
        currentGlowTarget.value.style.filter = ''
        currentGlowTarget.value = null
      }
    }, 300)
  }
  glowAttached.value = false
}

function toggleLights() {
  lightsOff.value = !lightsOff.value
  
  if (lightsOff.value) {
    startSpawningBugs()
  } else {
    stopSpawningBugs()
  }
}

function startSpawningBugs() {
  bugs.value = []
  bugSpawnInterval = setInterval(() => {
    if (Math.random() < 0.3 && bugs.value.length < 5) {
      spawnBug()
    }
  }, 3000)
}

function stopSpawningBugs() {
  if (bugSpawnInterval) {
    clearInterval(bugSpawnInterval)
    bugSpawnInterval = null
  }
  bugs.value = []
}

function spawnBug() {
  const isSmile = Math.random() < 0.01 // 1% 概率是礼物盒
  const bug = {
    id: Date.now() + Math.random(),
    x: Math.random() * window.innerWidth,
    y: Math.random() * window.innerHeight,
    rotation: Math.random() * 360,
    speed: isSmile ? 0 : 1.5 + Math.random() * 1, // 礼物盒不移动
    directionX: isSmile ? 0 : (Math.random() - 0.5) * 2,
    directionY: isSmile ? 0 : (Math.random() - 0.5) * 2,
    isSmile: isSmile,
    emoji: isSmile ? '🎁' : '🪲',
    isHovered: false // 新增：跟踪 hover 状态
  }
  bugs.value.push(bug)
  if (!isSmile) {
    animateBug(bug) // 只有虫子需要动画
  }
}

function animateBug(bug) {
  const animate = () => {
    const bugRef = bugs.value.find(b => b.id === bug.id)
    if (!bugRef) return
    
    // 如果虫子被 hover，则停止移动
    if (!bugRef.isHovered) {
      // 更新位置
      bugRef.x += bugRef.directionX * bugRef.speed
      bugRef.y += bugRef.directionY * bugRef.speed
      
      // 计算朝向角度（根据移动方向），额外顺时针旋转90度
      bugRef.rotation = Math.atan2(bugRef.directionY, bugRef.directionX) * (180 / Math.PI) + 90
      
      // 边界检测
      if (bugRef.x < 0 || bugRef.x > window.innerWidth) {
        bugRef.directionX *= -1
        bugRef.x = Math.max(0, Math.min(window.innerWidth, bugRef.x))
      }
      if (bugRef.y < 0 || bugRef.y > window.innerHeight) {
        bugRef.directionY *= -1
        bugRef.y = Math.max(0, Math.min(window.innerHeight, bugRef.y))
      }
      
      // 随机改变方向
      if (Math.random() < 0.01) {
        bugRef.directionX = (Math.random() - 0.5) * 2
        bugRef.directionY = (Math.random() - 0.5) * 2
      }
    }
    
    // 强制触发响应式更新
    bugs.value = [...bugs.value]
    
    requestAnimationFrame(animate)
  }
  animate()
}

function removeBug(bug) {
  if (bug.isSmile) {
    // 点击笑脸，导航到 /lol 路由
    router.push('/lol')
  } else {
    // 点击虫子，正常移除
    bugs.value = bugs.value.filter(b => b.id !== bug.id)
  }
}

function generateMask() {
  if (!glowVisible.value && !glowAttached.value) {
    return 'radial-gradient(circle at 50% 50%, transparent 0%, black 0%)'
  }
  
  const x = glowPos.value.x
  const y = glowPos.value.y
  const size = glowAttached.value ? 140 : 140 * glowScale.value
  const opacity = glowAttached.value ? controlGlowOpacity.value : glowOpacity.value
  
  if (opacity === 0) {
    return 'radial-gradient(circle at 50% 50%, transparent 0%, black 0%)'
  }
  
  return `radial-gradient(circle ${size}px at ${x}px ${y}px, transparent 0%, black 100%)`
}

onMounted(() => {
  document.addEventListener('mousemove', handleMouseMove)
  document.addEventListener('mouseleave', handleMouseLeave)
})

onUnmounted(() => {
  document.removeEventListener('mousemove', handleMouseMove)
  document.removeEventListener('mouseleave', handleMouseLeave)
  detachGlow()
  stopSpawningBugs()
})
</script>

<template>
  <div>
    <!-- 关灯按钮 -->
    <button @click="toggleLights" class="lights-toggle" style="cursor:pointer">
      {{ lightsOff ? '\u005f\u0070\u6f00' : '\u0051\u7370\u6f00' }}
    </button>
    
    <!-- 暗色遮罩层 -->
    <transition name="fade">
      <div v-if="lightsOff" class="dark-overlay">
        <!-- 使用 radial-gradient mask 创建聚光孔 -->
        <div class="mask-layer" :style="{
          maskImage: generateMask(),
          WebkitMaskImage: generateMask()
        }"></div>
      </div>
    </transition>
    
    <!-- 虫子图层 -->
    <transition name="fade">
      <div v-if="lightsOff" class="bug-layer">
        <div v-for="bug in bugs" :key="bug.id" 
             class="bug"
             @click="removeBug(bug)"
             @mouseenter="bug.isHovered = true"
             @mouseleave="bug.isHovered = false"
             :style="{
               left: bug.x + 'px',
               top: bug.y + 'px',
               transform: bug.isSmile 
                 ? 'translate(-50%, -50%)' 
                 : `translate(-50%, -50%) rotate(${bug.rotation}deg)`
             }">
          {{ bug.emoji }}
        </div>
      </div>
    </transition>
    
    <a href="https://github.com/vanvanhasnophi" target="_blank" class="glowable">
      <img src="/avatar.svg" class="avatar" alt="Avatar" />
    </a>
    <div v-show="glowVisible && !glowAttached" class="glow" :style="{
      left: glowPos.x + 'px',
      top: glowPos.y + 'px',
      opacity: glowOpacity,
      transform: `translate(-50%, -50%) scale(${glowScale})`
    }"></div>
  </div>
  <HelloWorld name="Vincent Chen" />
</template>

<style scoped>
.avatar {
  height: 6em;
  padding: 1.5em;
  will-change: filter;
  transition: filter 300ms;
}

.glowable {
  cursor: pointer;
  transition: filter 300ms;
}

.glow {
  position: fixed;
  pointer-events: none;
  width: 160px;
  height: 160px;
  border-radius: 50%;
  background: radial-gradient(circle, #ffffff48 0%, #ffffff25 30%, #ffffff11 60%, transparent 100%);
  mix-blend-mode: screen;
  transform: translate(-50%, -50%);
  z-index: 9999;
  transition: opacity 0.3s ease-out, transform 0.3s ease-out;
  filter: blur(8px);
}

.lights-toggle {
  position: fixed;
  top: 20px;
  right: 20px;
  padding: 10px 20px;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  color: white;
  cursor: pointer;
  font-size: 16px;
  z-index: 10001;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
  outline: none;
}

.lights-toggle:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: scale(1.05);
}

.lights-toggle:focus {
  outline: none;
}

.dark-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 9998;
  pointer-events: none;
}

/* 淡入淡出过渡效果 */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.5s ease;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
.fade-enter-to, .fade-leave-from {
  opacity: 1;
}

.mask-layer {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 1);
  transition: mask-position 0.1s ease-out;
}

.bug-layer {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 9997;
  pointer-events: none;
}

.bug {
  position: absolute;
  font-size: 24px;
  cursor: pointer;
  pointer-events: auto;
  user-select: none;
  transition: none;
}

.bug:hover {
  transform: translate(-50%, -50%) scale(1.2) !important;
}

.bug:active {
  transform: translate(-50%, -50%) scale(0.8) !important;
}

.spotlight {
  position: fixed;
  pointer-events: none;
  width: 300px;
  height: 300px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0, 0, 0, 0) 0%, rgba(0, 0, 0, 0) 30%, rgba(0, 0, 0, 1) 70%);
  mix-blend-mode: lighten;
  transform: translate(-50%, -50%);
  transition: opacity 0.3s ease-out, transform 0.3s ease-out;
  filter: blur(30px);
}
</style>

