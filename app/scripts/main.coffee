window.AudioContext = window.AudioContext || window.webkitAudioContext

window.world = new World document.getElementById('canvas')

buttons = document.body.querySelectorAll '.button'

if !window.chrome
  document.body.querySelector('#intro .error-chrome').classList.remove 'hide'

if window.innerWidth < 640 and Modernizr.touch
  document.body.querySelector('#error-mobile').classList.remove 'hide'
  document.body.querySelector('#intro p').classList.add 'hide'

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

onSpaceDown = (e) ->
  if e.keyCode is 32
    document.body.querySelector('#outro').classList.add 'hide'
    window.removeEventListener 'keydown', onSpaceDown
    window.world.progressionHandler.gotoLevel(window.world.progressionHandler.level + 1)
    window.world.soundsMatrix.setSoundAt 'HO_Chi Lead128E-01', [0, 32]
  return

onChangeLevel = (level) ->
  if level >= window.world.soundsMatrix.sounds.length - 1
    window.world.onChangeLevel.remove onChangeLevel
    setTimeout ->
      document.body.querySelector('#outro').classList.remove 'hide'
      window.addEventListener 'keydown', onSpaceDown
      return
    , 1000
  return

window.world.onChangeLevel.add onChangeLevel
window.world.soundsMatrix.onLoad.add =>
  document.body.querySelector('#intro .loading').classList.add 'hide'
  for button in buttons
    button.classList.remove 'hide'

for button in buttons
  button.addEventListener 'click', onButtonClick

# onButtonClick()