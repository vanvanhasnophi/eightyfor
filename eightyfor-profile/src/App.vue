<script setup>
import ProfileContent from './components/ProfileContent.vue'
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
const quoteData = ref(null)
const isLoadingQuote = ref(false)
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
    target.style.filter = `drop-shadow(0 0 5px rgba(255,255,255, ${controlGlowOpacity.value * 0.8})) drop-shadow(0 0 2em rgba(255,255,255, ${controlGlowOpacity.value * 0.5}))`
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

function showQuote() {
  isLoadingQuote.value = true

  const today = new Date()
  const isAprilFools = today.getMonth() === 3 && today.getDate() === 1

  if (isAprilFools) {
    quoteData.value = {
      content: "You are an idiot!=)",
      author: "Entity 67"
    }
    isLoadingQuote.value = false
    setTimeout(() => {
      router.push('/lol')
    }, 3000)
    return
  }

  if (rng.next() < 0.1) {
    fetch('https://tea.qingnian8.com/api/geng/random?pageSize=1')
      .then(response => response.json())
      .then(data => {
        // Parse API response which looks like: { errCode, errMsg, data: [ ... ] }
        const payload = data && data.data ? data : { data };
        const item = Array.isArray(payload.data) ? payload.data[0] : (payload.data || {});
        quoteData.value = {
          // show some identifier or fallback text as content
          content: item._id || item.createTime || 'Meme',
          // use the item's author or the top-level author
          author: item.author || payload.author || 'Meme',
          // image URL field in the example is `url`
          imageUrl: item.url || item.imageUrl || ''
        }
      })
      .catch(error => {
        console.error('Error fetching meme:', error)
        // Fallback to normal quote if meme fails
        return fetch('https://v1.hitokoto.cn/')
          .then(response => response.json())
          .then(data => {
            quoteData.value = {
              content: data.hitokoto,
              author: `${data.from ? `${data.from == '原创' ? '原创' : '《' + data.from + '》'}`:'Unknown'} ${data.from_who ? `by ${data.from_who}` : ''}`.trim(),
            }
          })
      })
      .finally(() => {
        isLoadingQuote.value = false
      })
    return
  }

  fetch('https://v1.hitokoto.cn/')
    .then(response => response.json())
    .then(data => {
      quoteData.value = {
        content: data.hitokoto,
        author: `${data.from ? `${data.from == '原创' ? '原创' : '《' + data.from + '》'}`:'Unknown'} ${data.from_who ? `by ${data.from_who}` : ''}`.trim(),
      }
    })
    .catch(error => {
      console.error('Error fetching quote:', error)
      alert('Failed to fetch quote. Please try again later.')
    })
    .finally(() => {
      isLoadingQuote.value = false
    })
}

// 简单的伪随机数生成器
class SeededRandom {
  constructor(seed) {
    this.seed = seed;
  }

  // 生成 0 到 1 之间的随机数
  next() {
    const x = Math.sin(this.seed++) * 10000;
    return x - Math.floor(x);
  }
}

const rng = new SeededRandom(Date.now());

function startSpawningBugs() {
  bugs.value = []
  bugSpawnInterval = setInterval(() => {
    if (rng.next() < 0.3 && bugs.value.length < 5) {
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
  const isSmile = rng.next() < 0.01 // 1% 概率是礼物盒
  const bug = {
    id: Date.now() + rng.next(),
    x: rng.next() * window.innerWidth,
    y: rng.next() * window.innerHeight,
    rotation: rng.next() * 360,
    speed: isSmile ? 0 : 1.5 + rng.next() * 1, // 礼物盒不移动
    directionX: isSmile ? 0 : (rng.next() - 0.5) * 2,
    directionY: isSmile ? 0 : (rng.next() - 0.5) * 2,
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
      if (rng.next() < 0.01) {
        bugRef.directionX = (rng.next() - 0.5) * 2
        bugRef.directionY = (rng.next() - 0.5) * 2
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
    // 点击礼物盒，导航到 /lol 路由
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
        <div v-for="bug in bugs" :key="bug.id" class="bug" @click="removeBug(bug)" @mouseenter="bug.isHovered = true"
          @mouseleave="bug.isHovered = false" :style="{
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
      <img src="/avatar.png" class="avatar" alt="Avatar" />
    </a>

    <div v-show="glowVisible && !glowAttached" class="glow" :style="{
      left: glowPos.x + 'px',
      top: glowPos.y + 'px',
      opacity: glowOpacity,
      transform: `translate(-50%, -50%) scale(${glowScale})`
    }"></div>
  </div style="">
  <ProfileContent name="Vincent Chen 陈宇凡" mail1="j13811593@163.com" mail2="chenyufa23@mails.tsinghua.edu.cn" />
  <div style="text-align: center; margin: 2em;">
    <a href="./blog">
      <button class="primary">Blogs →</button>
    </a>

    <transition name="fade" mode="out-in">
      <div v-if="quoteData"
        style="margin-left: 1em; display: inline-block; vertical-align: middle; max-width: 600px; text-align: left;">
        <template v-if="quoteData.imageUrl">
          <img :src="quoteData.imageUrl"
            style="max-width: 100%; max-height: 300px; border-radius: 8px; display: block; margin-bottom: 0.5em;" />
          <span style="opacity: 0.7; font-size: 0.9em;">{{ quoteData.content }} — {{ quoteData.author }}</span>
        </template>
        <template v-else>
          "{{ quoteData.content }}" <br> <span style="opacity: 0.7; font-size: 0.9em;">— {{ quoteData.author }}</span>
        </template>
      </div>
      <button v-else style="margin-left: 1em;" @click="showQuote" :disabled="isLoadingQuote">
        {{ isLoadingQuote ? 'Loading...' : 'Quote Me' }}
      </button>
    </transition>
  </div>
</template>

<style scoped>
.avatar {
  height: 8em;
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
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.fade-enter-to,
.fade-leave-from {
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
