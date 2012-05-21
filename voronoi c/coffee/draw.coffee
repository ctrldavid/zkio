

r = (max,min = 0) -> Math.random() * (max-min) + min

sites = []
sites.push new Point r(1000), r(1000) for i in [1...100]



canvas = document.createElement 'canvas'
canvas.width = 1000
canvas.height = 1000
ctx = canvas.getContext '2d'

ctx.fillRect s.x-1, s.y-1, 3, 3 for s in sites

document.body.appendChild canvas

v = new Voronoi()
edges = v.GetEdges(sites, 1000, 1000)
console.log edges