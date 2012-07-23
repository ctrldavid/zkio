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
height = 600
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

WIDTH = window.innerWidth
HEIGHT = window.innerHeight


VIEW_ANGLE = 45
ASPECT = WIDTH / HEIGHT
NEAR = 0.1
FAR = 10000

renderer = new THREE.WebGLRenderer()
camera = new THREE.PerspectiveCamera VIEW_ANGLE, ASPECT, NEAR, FAR

scene = new THREE.Scene()
#scene.fog = new THREE.Fog(0xffffff, 100,1000)
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
  cell.site.isBorder = cell.isBorder
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
texture = THREE.ImageUtils.loadTexture("dirt.png")
console.log texture

texture.wrapT = texture.wrapS = THREE.RepeatWrapping
texture.repeat.x = texture.repeat.y = 3

for cell in result.cells
  continue if cell.isBorder
  if Math.random() < 0.00
    pointLightx = new THREE.PointLight(0xff0000)
    pointLightx.position.x = cell.site.x
    pointLightx.position.y = cell.height+5
    pointLightx.position.z = cell.site.y
    scene.add(pointLightx)

  # spike
  geometry = new THREE.Geometry()
  geometry.vertices.push new THREE.Vector3(cell.site.x, cell.height, cell.site.y-5)
  geometry.vertices.push new THREE.Vector3(cell.site.x+4, cell.height, cell.site.y+3)
  geometry.vertices.push new THREE.Vector3(cell.site.x-4, cell.height, cell.site.y+3)
  geometry.vertices.push new THREE.Vector3(cell.site.x, cell.height+15, cell.site.y)

  geometry.faces.push new THREE.Face3( 1, 0, 3 )
  geometry.faces.push new THREE.Face3( 0, 2, 3 )
  geometry.faces.push new THREE.Face3( 2, 1, 3 )

  geometry.computeFaceNormals()
  geometry.computeBoundingSphere()
  mat = new THREE.MeshPhongMaterial({color: 0x00ff00, wireframe:false})
  object = new THREE.Mesh( geometry, mat )  
  scene.add(object)

  # surface
  geometry = new THREE.Geometry()
  uvs = []
  vert0 = new THREE.Vector3(cell.halfedges[0].getEndpoint().x, cell.height, cell.halfedges[0].getEndpoint().y)
  vert1 = new THREE.Vector3(cell.halfedges[1].getEndpoint().x, cell.height, cell.halfedges[1].getEndpoint().y)
  geometry.vertices.push vert0
  geometry.vertices.push vert1
  uv0 = new THREE.UV cell.halfedges[0].getEndpoint().x/width, cell.halfedges[0].getEndpoint().y/height
  uv1 = new THREE.UV cell.halfedges[1].getEndpoint().x/width, cell.halfedges[1].getEndpoint().y/height
  uvx = null
  geometry.faceUvs = [[]];
  geometry.faceVertexUvs = [[]];

  for halfedge, index in cell.halfedges
    continue if index < 2
    vert2 = new THREE.Vector3(cell.halfedges[index].getEndpoint().x, cell.height, cell.halfedges[index].getEndpoint().y)
    geometry.vertices.push vert2
    geometry.faces.push new THREE.Face3( 0, index-1, index )
    uvx = new THREE.UV cell.halfedges[index].getEndpoint().x/width, cell.halfedges[index].getEndpoint().y/height
    geometry.faceVertexUvs[0].push [uv0, uv1, uvx]
    geometry.faceUvs[0].push new THREE.UV 0,0.5
    vert1 = vert2
    uv1 = uvx

    

  
  geometry.computeFaceNormals()
  geometry.computeBoundingSphere()

  # object = new THREE.Mesh( geometry, new THREE.MeshNormalMaterial() )
  if Math.random() < 1.5 
    mat = new THREE.MeshPhongMaterial({color: 0xaaaaaa, wireframe:false, map:texture})
  else
    mat = new THREE.MeshPhongMaterial({color: 0x886622})
  object = new THREE.Mesh( geometry, mat )
  
  scene.add(object)
  cell.site.isBorder = cell.isBorder


for edge in result.edges
  #console.log edge
  continue if not edge.rSite? #or edge.rSite.isBorder
  continue if not edge.lSite? #or edge.lSite.isBorder
  
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

  geometry.faceUvs = [[]];
  geometry.faceVertexUvs = [[]];
  geometry.faceUvs[0].push(new THREE.UV(0,1));
  # geometry.faceVertexUvs[0].push([
  #   new THREE.UV(0,0), new THREE.UV(0,1), new THREE.UV(1,1), new THREE.UV(1,0)
  # ])

  geometry.faceVertexUvs[0].push([
    new THREE.UV(edge.va.x/width, edge.va.y/height), 
    new THREE.UV(edge.vb.x/width, edge.vb.y/height), 
    new THREE.UV(edge.vb.x/width, edge.vb.y/height), 
    new THREE.UV(edge.va.x/width, edge.va.y/height)
  ])


  geometry.computeFaceNormals()
  mat = new THREE.MeshPhongMaterial({color: 0xFFFFFF, wireframe:false,map:texture})
  #console.log mat
  object = new THREE.Mesh( geometry, mat )
  scene.add(object)

# FLOOR

fvert0 = new THREE.Vector3(0,floor,0)
fvert3 = new THREE.Vector3(width,floor,0)
fvert2 = new THREE.Vector3(width,floor,height)
fvert1 = new THREE.Vector3(0,floor,height)

# fvert0 = new THREE.Vector3(-10000,floor-10,-10000)
# fvert3 = new THREE.Vector3(10000,floor-10,-10000)
# fvert2 = new THREE.Vector3(10000,floor-10,10000)
# fvert1 = new THREE.Vector3(-10000,floor-10,10000)


fgeometry = new THREE.Geometry()
fgeometry.vertices.push fvert0
fgeometry.vertices.push fvert1
fgeometry.vertices.push fvert2
fgeometry.vertices.push fvert3
fgeometry.faces.push new THREE.Face4(0, 1, 2, 3)
fgeometry.computeFaceNormals()
fmat = new THREE.MeshPhongMaterial({color: 0x444444})
fobject = new THREE.Mesh( fgeometry, fmat )
scene.add(fobject)
console.log 'fob', fobject

################


pointLight = new THREE.PointLight(0xEEDDFF)

pointLight.position.x = WIDTH/2
pointLight.position.y = 100
pointLight.position.z = HEIGHT/2

scene.add(pointLight)

directionalLight = new THREE.DirectionalLight(0xFFFFFF);
directionalLight.position.set(1, 2, 1).normalize()
scene.add(directionalLight)

ambientLight = new THREE.AmbientLight 0x222222
scene.add(ambientLight);

cx = width/2
cy = height/2 #- 600
r = 600
z = 400
t = 0;
go = () ->
  
  #y=y-1
  t=t+0.005
  x = cx + 4/3 * r * Math.sin(t)
  y = cy + r * Math.cos(1.2*t)
  pointLight.position.set cx + 300 * Math.sin(7*t), 100 ,cx + 300 * Math.cos(5*t)
  camera.position.set x,z,y-50
  camera.lookAt new THREE.Vector3(width/2, 0,height/2)
  #camera.lookAt new THREE.Vector3(x, 0, y)
  renderer.render(scene,camera);
  webkitRequestAnimationFrame go
  #window.setTimeout go, 10
go()



###
   o
  / \
 /   \
o     o
 \   /
  o-o


###