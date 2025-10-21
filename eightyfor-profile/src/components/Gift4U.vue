<template>
  <div class="idiot-screen" @click="triggerMore">
    <audio ref="idiotAudio" loop autoplay>
      <source src="/lol.mp3" type="audio/mpeg">
    </audio>
    <img 
      src="/smiles.gif" 
      alt="You are an idiot" 
      class="idiot-fullscreen-gif">
  </div>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue'

let childWindows = []

function triggerMore() {
  // 点击时再打开更多窗口
  const baseUrl = window.location.origin
  for (let i = 0; i < 3; i++) {
    setTimeout(() => {
      const newWindow = window.open(
        `${baseUrl}/lol`, 
        '_blank', 
        'width=400,height=300,menubar=no,toolbar=no,location=no,status=no'
      )
      if (newWindow) {
        childWindows.push(newWindow)
        randomMoveWindow(newWindow)
      }
    }, i * 50)
  }
}

function randomMoveWindow(targetWindow) {
  let xPos = Math.random() * (screen.width - 400)
  let yPos = Math.random() * (screen.height - 300)
  let xOff = (Math.random() - 0.5) * 20
  let yOff = (Math.random() - 0.5) * 20
  
  const moveLoop = () => {
    if (targetWindow.closed) return
    
    xPos += xOff
    yPos += yOff
    
    if (xPos > screen.width - 400 || xPos < 0) xOff *= -1
    if (yPos > screen.height - 300 || yPos < 0) yOff *= -1
    
    try {
      targetWindow.moveTo(xPos, yPos)
    } catch (e) {
      // 浏览器可能阻止移动
    }
    
    setTimeout(moveLoop, 10)
  }
  
  moveLoop()
}

onMounted(() => {
  // 启动当前窗口的移动
  let x = 0
  let y = 0
  let xDirection = 1
  let yDirection = 1
  
  setInterval(() => {
    x += xDirection * 5
    y += yDirection * 5
    
    if (x > 200 || x < -200) xDirection *= -1
    if (y > 200 || y < -200) yDirection *= -1
    
    try {
      window.moveBy(xDirection * 5, yDirection * 5)
    } catch (e) {
      // 浏览器可能阻止移动
    }
  }, 50)
})
</script>

<style scoped>
.idiot-screen {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: #000;
  z-index: 99999;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  cursor: pointer;
}

.idiot-fullscreen-gif {
  width: 100%;
  height: 100%;
  object-fit: cover;
  image-rendering: pixelated;
  transition: transform 0.05s linear;
  will-change: transform;
}
</style>
