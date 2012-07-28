

r = (max,min = 0) -> Math.random() * (max-min) + min

sites = []
#sites.push new Point r(500), r(500) for i in [1..50]
sites.push new Point 100, 100
sites.push new Point 200, 100
sites.push new Point 200, 200
#sites.push new Point 100, 200



canvas = document.createElement 'canvas'
canvas.width = 500
canvas.height = 500
ctx = canvas.getContext '2d'

ctx.fillRect s.x-1, s.y-1, 3, 3 for s in sites

document.body.appendChild canvas

v = new Voronoi()
edges = v.GetEdges(sites, 500, 500)
#console.log edges

for edge in edges
	ctx.beginPath()
	ctx.moveTo edge.start.x, edge.start.y
	ctx.lineTo edge.end.x, edge.end.y
	ctx.stroke()
	#console.log "#{edge.start.x}, #{edge.start.y} - #{edge.end.x}, #{edge.end.y}"