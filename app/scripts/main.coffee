window.AudioContext = window.AudioContext || window.webkitAudioContext

window.world = new World document.getElementById('canvas')

onWindowFocus = ->
  window.world.start()
  return

onWindowBlur =->
  window.world.stop()
  return

window.addEventListener 'focus', @onWindowFocus
window.addEventListener 'blur', @onWindowBlur