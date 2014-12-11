window.AudioContext = window.AudioContext || window.webkitAudioContext

window.world = new World document.getElementById('canvas')

buttons = document.body.querySelectorAll '.button'

onWindowFocus = ->
  window.world.start()
  return

onWindowBlur =->
  window.world.stop()
  return

onButtonClick = (e) ->
  if e and e.currentTarget.classList.contains 'lq'
    window.world.resize null, .25

  window.world.start()

  document.body.querySelector('#intro').classList.add 'hide'
  window.addEventListener 'focus', onWindowFocus
  window.addEventListener 'blur', onWindowBlur
  return

for button in buttons
  button.addEventListener 'click', onButtonClick

# onButtonClick()