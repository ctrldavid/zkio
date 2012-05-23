class Point
  constructor: (@x,@y) ->
    @dx = 0#Math.random()-0.5
    @dy = 0#Math.random()-0.5
    @down = true#Math.random() < 0.5
    @heat = 50#100- ((@x/width)*20 +40) #Math.random() * 40


class PointSpread
  constructor: (@width, @height, @spacing) ->
    @points = []
    @points.push new Point @width/2, @height/2
    @generate()
  rw: -> Math.random() * @width
  rh: -> Math.random() * @height
  dist: (a,b) ->
    return Math.sqrt (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)
  generate: ->
    # ideal = @width / @spacing * @height / @spacing
    attempts = 0
    fails = 0
    while attempts < 1000 || fails/attempts < 0.99
      newPoint = new Point @rw(), @rh()
      fail = false
      for point in @points
        dist = @dist point, newPoint
        fail = true if dist < @spacing
      @points.push newPoint unless fail
      attempts++
      fails++ if fail

  settle: ->
    # for point in @points
    #   point.dx = 0
    #   point.dy = 0

    for point1 in @points
      for point2 in @points
        continue if point1 == point2
        d = @dist point1, point2
        if d < 30
          #xfer heat:
          old1 = point1.heat
          old2 = point2.heat
          x = 0.999
          point1.heat = x*old1 + (1-x) * old2
          point2.heat = x*old2 + (1-x) * old1
          point1.dx += (point2.dx-point1.dx) * 0.001
          point1.dy += (point2.dy-point1.dy) * 0.001
          if d > 20
            # pull
            point1.dx += (point2.x-point1.x) * 0.0001/(d-19)
            point1.dy += (point2.y-point1.y) * 0.0001/(d-19)
          else if d > 0 && d < 20
            # push
            point1.dx -= (point2.x-point1.x) * 0.2 / (d+0) 
            point1.dy -= (point2.y-point1.y) * 0.2 / (d+0) 

    for point in @points
      point.x += point.dx*3
      point.y += point.dy*3
      point.dx = point.dx * 0.99
      point.dy = point.dy * 0.99

      point.dy = point.dy - 0.0004 * (point.heat-50)
      #point.heat = point.heat * 0.9995
      point.heat -= 0.05
      if point.y < 50 && point.heat > 0
        point.heat-=0.003
      if point.y > @height-100 && point.heat < 100
        point.heat+=0.4

      # point.dy += 0.006 if point.down
      # point.dy -= 0.006 if !point.down
      # if point.y < 30
      #   point.down = true
      # if point.y > 570
      #   point.down = false

width = 400
height = 700

canvas = document.createElement 'canvas'
canvas.width = width
canvas.height = height
ctx = canvas.getContext '2d'



document.body.appendChild canvas

x = new PointSpread width, height, 15
console.log x.points

# x.settle() for x in [1...100]

points = x.points

bbox = {xl:0, xr:width, yt:0, yb:height};
voronoi = new Voronoi();


canvas.addEventListener 'click', -> 
  x.generate()
  for p in x.points
    p.dx = Math.random() - 0.5
    p.dy = Math.random() - 0.5

window.setInterval ->

  result = voronoi.compute(points, bbox);

  #console.log result

  ctx.clearRect 0,0,width,height

  ctx.fillStyle = "rgba(0,64,0,0.5)"
  
  for cell in result.cells
    # if cell.site.down
    #   ctx.fillStyle = "rgba(0,0,64,0.5)"
    # else
    #   ctx.fillStyle = "rgba(64,0,0,0.5)"
    c = cell.site.heat/100
    r = Math.floor(c*256)
    b = Math.floor((1-c)*256)
    ctx.fillStyle = "rgba(#{r},0,#{b},0.5)"
    ctx.beginPath()
    ctx.moveTo cell.halfedges[0].getStartpoint().x, cell.halfedges[0].getStartpoint().y
    for halfedge in cell.halfedges
      ctx.lineTo halfedge.getEndpoint().x,halfedge.getEndpoint().y
      
    ctx.closePath()
    #ctx.stroke()
    ctx.fill()

  ctx.strokeStyle = "rgba(127,0,127,0.1)"
  for edge in result.edges
    ctx.beginPath()
    ctx.moveTo edge.va.x, edge.va.y
    ctx.lineTo edge.vb.x, edge.vb.y
    ctx.stroke()
    #console.log "#{edge.start.x}, #{edge.start.y} - #{edge.end.x}, #{edge.end.y}"


  ctx.fillStyle = "rgba(255,255,255,0.7)"
  ctx.fillRect s.x-1, s.y-1, 3, 3 for s in x.points
  x.settle()
  for p in points
    if p.x < 0
      p.x = 0
      p.dx = -p.dx
    if p.y < 0
      p.y = 0
      p.dy = -p.dy
    if p.x > width
      p.x = width
      p.dx = -p.dx
    if p.y > height
      p.y = height
      p.dy = -p.dy

, 10