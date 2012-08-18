class Visualisation
  constructor: () ->
    @map = new Map()
    # @canvas = new Canvas(256, 256)
    # @canvas = new Canvas(1024, 512)
    @width = window.innerWidth-8
    @height = window.innerHeight-8
    @canvas = new Canvas(@width, @height)
    @canvas.center()

    @lastUpdate = Date.now()

  placeObstacles: ()->
    @map.genObs() for x in [0..400]

  draw: () ->
    

    for node in @map.graph.nodes
      @canvas.basePlateBorder node.x, node.y, node.type
    for node in @map.graph.nodes
      @canvas.basePlate node.x, node.y, node.type


    for edge in @map.graph.edges
      @canvas.line edge.start.x, edge.start.y, edge.end.x, edge.end.y, 
        if edge.start.type == edge.end.type then Colour[edge.start.type] else Colour.Path,
        if edge.start.type == edge.end.type then 2 else 1,

    for node in @map.graph.nodes
      @canvas.circle node.x, node.y, Colour[node.type], {Town:3, Route:1.5, Instance:2, Obstacle:0}[node.type]

  voronoi: () ->
    voronoi = new Voronoi()
    bbox = {xl:0, xr:@width, yt:0, yb:@height};
    bbox = {xl:-@width, xr:@width, yt:-@height, yb:@height};
    points = @map.graph.nodes.map (node) ->
      {x: node.x, y: node.y, t:node.type, v:1-node.tries/50}
    
    result = voronoi.compute(points, bbox);
    
    ctx = @canvas.ctx
    for cell in result.cells
      c = Colour[cell.site.t]
      c.a = 0.1 + 0.1 * cell.site.v.toFixed(2)
      ctx.fillStyle = c.rgba()
      c.a = 1.0
      
      
      ctx.beginPath()
      ctx.moveTo cell.halfedges[0].getStartpoint().x, cell.halfedges[0].getStartpoint().y
      for halfedge in cell.halfedges
        ctx.lineTo halfedge.getEndpoint().x,halfedge.getEndpoint().y
        
      ctx.closePath()
      #ctx.stroke()
      ctx.fill()

    ctx.strokeStyle = "rgba(255,255,255,0.05)"
    for edge in result.edges
      ctx.beginPath()
      ctx.moveTo edge.va.x, edge.va.y
      ctx.lineTo edge.vb.x, edge.vb.y
      if (edge.lSite.t != edge.rSite.t)
        ctx.stroke()

  gen: () ->
    # @draw() if @map.gen1()
    # unless window.sfsdf?
    #   window.sfsdf = true
    #   window.setTimeout => 
    #     @voronoi()
    #   , 5000
    @map.gen1()
    if Date.now() - @lastUpdate > 3000
      @lastUpdate = Date.now()
      @canvas.clear()      
      @draw()
      @voronoi()
      
    


window.Visualisation = Visualisation