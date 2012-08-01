
window.addEventListener 'load', ->
  window.test3 = new Visualisation()
  window.test3.placeObstacles()
  window.test3.draw()

  window.setInterval ->
    window.test3.gen() for x in [1..10]
  , 1

  # window.setInterval ->
  #   test3.map.cull()
  # , 10000  