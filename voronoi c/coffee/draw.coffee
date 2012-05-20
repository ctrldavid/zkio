v = Point: class
  constructor: (@x,@y) ->

r = (max,min = 0) -> Math.random() * (max-min) + min

sites = []
sites.push new v.Point r(1000), r(1000) for i in [1...100]



canvas = document.createElement 'canvas'
canvas.width = 1000
canvas.height = 1000
ctx = canvas.getContext '2d'

ctx.fillRect s.x-1, s.y-1, 3, 3 for s in sites

document.body.appendChild canvas