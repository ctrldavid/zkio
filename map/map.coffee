class Point
  constructor: (@x,@y) ->


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


width = 800
height = 800
floor = -10

draw = (ctx) ->
  x = new PointSpread width, height, 35
  console.log x.points

  points = x.points

  bbox = {xl:0, xr:width, yt:0, yb:height};
  voronoi = new Voronoi();

  result = voronoi.compute(points, bbox);
    
  for cell in result.cells
    ctx.fillStyle = "rgba(64,64,64,1.0)"
    ctx.beginPath()
    ctx.moveTo cell.halfedges[0].getStartpoint().x, cell.halfedges[0].getStartpoint().y
    for halfedge in cell.halfedges
      ctx.lineTo halfedge.getEndpoint().x,halfedge.getEndpoint().y
      
    ctx.closePath()
    ctx.fill()

  ctx.strokeStyle = "rgba(127,127,127,1.0)"
  for edge in result.edges
    ctx.beginPath()
    ctx.moveTo edge.va.x, edge.va.y
    ctx.lineTo edge.vb.x, edge.vb.y
    ctx.stroke()

# Three.js stuff
WIDTH = 800
HEIGHT = 600

VIEW_ANGLE = 45
ASPECT = WIDTH / HEIGHT
NEAR = 0.1
FAR = 10000

renderer = new THREE.WebGLRenderer()
camera = new THREE.PerspectiveCamera VIEW_ANGLE, ASPECT, NEAR, FAR

scene = new THREE.Scene();

scene.add camera

camera.position.set WIDTH/2, HEIGHT/2, 100
camera.lookAt new THREE.Vector3(WIDTH/2, HEIGHT/2, 0)

renderer.setSize WIDTH, HEIGHT

document.body.appendChild renderer.domElement


material = new THREE.LineBasicMaterial({
    color: 0x4488ff
})


x = new PointSpread width, height, 35
console.log x.points

points = x.points

bbox = {xl:0, xr:width, yt:0, yb:height};
voronoi = new Voronoi();

result = voronoi.compute(points, bbox);

console.log result

# fiddle with result to set border cells.
for cell in result.cells
  cell.isBorder = false
  for halfedge in cell.halfedges
    unless halfedge.edge.lSite? && halfedge.edge.rSite? 
      cell.isBorder = true
  cell.isBorder = true if Math.random() < 0.3
  cell.height = Math.floor(Math.random() * 5) * 10 #Math.random()*50
  cell.height = floor if cell.isBorder
  cell.site.height = cell.height

  
# for cell in result.cells
#   continue if cell.isBorder
#   geometry = new THREE.Geometry()
#   for halfedge in cell.halfedges
#     geometry.vertices.push(new THREE.Vector3(halfedge.getEndpoint().x, cell.height, halfedge.getEndpoint().y))
#   # close it  
#   geometry.vertices.push(new THREE.Vector3(cell.halfedges[0].getEndpoint().x, cell.height, cell.halfedges[0].getEndpoint().y))
#   line = new THREE.Line(geometry, material)
#   scene.add(line);

#  Creating faces:
# The surface will be triangles sharing vertex 0.
# So 0,1,2; 0,2,3; 0,3,4 = pentagon
# edges will be squares/rects between 2 cells.

for cell in result.cells
  continue if cell.isBorder
  if Math.random() < 0.00
    pointLightx = new THREE.PointLight(0xff0000)
    pointLightx.position.x = cell.site.x
    pointLightx.position.y = cell.height+5
    pointLightx.position.z = cell.site.y
    scene.add(pointLightx)

  geometry = new THREE.Geometry()
  vert0 = new THREE.Vector3(cell.halfedges[0].getEndpoint().x, cell.height, cell.halfedges[0].getEndpoint().y)
  vert1 = new THREE.Vector3(cell.halfedges[1].getEndpoint().x, cell.height, cell.halfedges[1].getEndpoint().y)
  geometry.vertices.push vert0
  geometry.vertices.push vert1


  for halfedge, index in cell.halfedges
    continue if index < 2
    vert2 = new THREE.Vector3(cell.halfedges[index].getEndpoint().x, cell.height, cell.halfedges[index].getEndpoint().y)
    geometry.vertices.push vert2
    geometry.faces.push new THREE.Face3( 0, index-1, index )
    vert1 = vert2

  geometry.computeFaceNormals()
  # object = new THREE.Mesh( geometry, new THREE.MeshNormalMaterial() )
  if Math.random() < 0.0001 
    mat = new THREE.MeshPhongMaterial({color: 0x00ff00})
  else
    mat = new THREE.MeshPhongMaterial({color: 0x886622})
  object = new THREE.Mesh( geometry, mat )
  scene.add(object)
  cell.site.isBorder = cell.isBorder


for edge in result.edges
  continue if not edge.rSite? or edge.rSite.isBorder
  continue if not edge.lSite? or edge.lSite.isBorder
  
  vert0 = new THREE.Vector3(edge.va.x, edge.rSite.height, edge.va.y)
  vert1 = new THREE.Vector3(edge.vb.x, edge.rSite.height, edge.vb.y)
  vert3 = new THREE.Vector3(edge.va.x, edge.lSite.height, edge.va.y)
  vert2 = new THREE.Vector3(edge.vb.x, edge.lSite.height, edge.vb.y)
  geometry = new THREE.Geometry()
  geometry.vertices.push vert0
  geometry.vertices.push vert1
  geometry.vertices.push vert2
  geometry.vertices.push vert3
  geometry.faces.push new THREE.Face4( 0, 1, 2, 3)
  #geometry.faces.push new THREE.Face3( 0, 2, 3)
  geometry.computeFaceNormals()
  mat = new THREE.MeshPhongMaterial({color: 0x886622})
  object = new THREE.Mesh( geometry, mat )
  scene.add(object)

# FLOOR

fvert0 = new THREE.Vector3(0,floor,0)
fvert3 = new THREE.Vector3(width,floor,0)
fvert2 = new THREE.Vector3(width,floor,height)
fvert1 = new THREE.Vector3(0,floor,height)

fgeometry = new THREE.Geometry()
fgeometry.vertices.push fvert0
fgeometry.vertices.push fvert1
fgeometry.vertices.push fvert2
fgeometry.vertices.push fvert3
fgeometry.faces.push new THREE.Face4(0, 1, 2, 3)
fgeometry.computeFaceNormals()
fmat = new THREE.MeshPhongMaterial({color: 0x002288})
fobject = new THREE.Mesh( fgeometry, fmat )
scene.add(fobject)
console.log 'fob', fobject

################


pointLight = new THREE.PointLight(0xEEDDFF)

pointLight.position.x = WIDTH/2
pointLight.position.y = 100
pointLight.position.z = HEIGHT/2

scene.add(pointLight)

directionalLight = new THREE.DirectionalLight(0x111111);
directionalLight.position.set(1, 10, 1).normalize()
scene.add(directionalLight)

ambientLight = new THREE.AmbientLight 0x111111
scene.add(ambientLight);

cx = width/2
cy = height/2 #- 600
r = 600
z = 500
t = 0;
window.setInterval () ->
  #y=y-1
  t=t+0.001
  x = cx + r * Math.sin(t)
  y = cy + r * Math.cos(t)
  pointLight.position.set cx + 300 * Math.sin(50*t), 100 ,cx + 300 * Math.cos(40*t)
  camera.position.set x,z,y
  camera.lookAt new THREE.Vector3(width/2, 0,height/2)
  renderer.render(scene,camera);
, 10




###
   o
  / \
 /   \
o     o
 \   /
  o-o


###