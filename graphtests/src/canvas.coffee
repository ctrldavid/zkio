class Canvas
  constructor : (width, height) ->
    @width = width
    @height = height
    
    @element = document.createElement 'canvas'
    @element.width = @width
    @element.height = @height

    document.body.appendChild @element

    @ctx = @element.getContext '2d'
    
    @element.addEventListener 'mousedown', (e) => @save() if e.metaKey

  center: () ->
    @ctx.setTransform 1, 0, 0, 1, @width / 2, @height / 2

  save : () ->
    console.log @element.toDataURL()
    window.open(@element.toDataURL(), "")

  inside: ({x,y}) ->
    return false if x < -@width/2
    return false if y < -@height/2
    return false if x >  @width/2
    return false if y >  @height/2
    return true

  clear : () ->
    #@ctx.clearRect -@width/2, -@height/2, @width, @height
    @ctx.fillStyle = Colour.Black.rgba()
    @ctx.fillRect -@width/2, -@height/2, @width, @height

  circle: (x,y,colour, size) ->
    @ctx.fillStyle = Colour.Black.rgba()
    @ctx.strokeStyle = colour.rgba()
    @ctx.lineWidth = 2
    # @ctx.fillRect x-2, y-2, 4,4
    @ctx.beginPath()
    @ctx.arc x,y,size,0,Math.PI*2, true
    @ctx.closePath()
    @ctx.fill()
    @ctx.stroke()

  basePlate: (x,y, type) ->
    @ctx.fillStyle = Colour.BasePlate.rgba()
    if type == 'Obstacle' then w = 45 else w = 15
    @ctx.beginPath()
    @ctx.arc x,y,w,0,Math.PI*2, true
    @ctx.closePath()
    @ctx.fill()

  basePlateBorder: (x,y, type) ->
    @ctx.strokeStyle = Colour.BasePlateBorder.rgba()
    @ctx.lineWidth = 2
    if type == 'Obstacle' then w = 45 else w = 15
    @ctx.beginPath()
    @ctx.arc x,y,w,0,Math.PI*2, true
    @ctx.closePath()
    @ctx.stroke()

  line : (sx, sy, ex, ey, colour, width) ->
    @ctx.strokeStyle = colour.rgba()
    @ctx.lineWidth = width || 1
    @ctx.beginPath()
    @ctx.moveTo(sx, sy)
    @ctx.lineTo(ex, ey)
    @ctx.stroke()








window.Canvas = Canvas