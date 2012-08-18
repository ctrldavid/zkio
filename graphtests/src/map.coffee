class Town extends Node
  type: 'Town'
  constructor: (@x,@y) ->
    super()

class Route extends Node
  type: 'Route'
  constructor: (@x, @y) ->
    super()

class Instance extends Node
  type: 'Instance'
  constructor: (@x, @y) ->
    super()

class Obstacle extends Node
  type: 'Obstacle'
  constructor: (@x, @y) ->
    super()


class Map
  constructor: (opts) ->
    @graph = new Graph()
    @active = []

    # create a new Town at position 0,0
    @graph.add new Town(0,0)
    @active.push @graph.nodes[0]

  distance: (n1, n2) -> Math.sqrt(Math.pow(n1.x - n2.x, 2) + Math.pow(n1.y - n2.y, 2))

  clearance: (node, threshold) ->
    for node2 in @graph.nodes
      if @distance(node, node2) < threshold then return false
      if node2.type == 'Obstacle' && @distance(node, node2) < threshold*2 then return false
    return true

  edgeCheck: (node) ->
    max = {Town:4, Route:3, Instance:1, Obstacle:0}[node.type]
    return node.edges.length < max

  cull: () ->
    toCull = []
    for node in @graph.nodes
      if node.type == 'Route'
        if node.edges.length < 2
          toCull.push node 
        else
          orphan = true
          for node2 in node.adj()
            if node2.type != 'Route'
              orphan = false
          #toCull.push node if orphan



    console.log 'culling', toCull.length, toCull

    for node in toCull
      @graph.remove node

  genObs: () ->
    
    x = (Math.random()-0.5)*window.innerWidth
    y = (Math.random()-0.5)*window.innerHeight

    #x = ((Math.random()*0.95 + 0.05)/2 * (if Math.random() < 0.5 then -1 else 1))*1600
    #y = ((Math.random()*0.95 + 0.05)/2 * (if Math.random() < 0.5 then -1 else 1))*1300

    # return false unless -(1512-30) < x < (1512-30)
    # return false unless -(1256-30) < y < (1256-30)
    return false unless -(window.innerWidth/2-30) < x < (window.innerWidth/2-30)
    return false unless -(window.innerHeight/2-30) < y < (window.innerHeight/2-30)

    d = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
    return false unless d > 60

    node = new Obstacle x, y

    @graph.add node
    @active.push node


  gen1: () ->
    # pick a random node
    # tries = 2000
    # while tries > 0 and not src?
    #   src = @graph.nodes[ Math.floor(Math.random() * @graph.nodes.length) ]
    #   src = null unless @edgeCheck src

    #   tries--
    # return false unless src
    if @active.length == 0
      for node in @graph.nodes
        continue unless @edgeCheck node
        @active.push(node)
        node.tries = 0

    src = null
    tries = 2000
    while tries > 0 and not src?
      tries--
      node = @active[ Math.floor(Math.random() * @active.length) ]
      continue unless node
      unless node.tries? 
        node.tries = 0
      if node.tries > 50
        @active.splice @active.indexOf(node), 1  
        return
      if @edgeCheck(node)
        src = node
      else 
        node.tries = 50
        @active.splice @active.indexOf(node), 1  
      

    # @active.forEach (node) =>
    #   unless node.tries? 
    #     node.tries = 0
    #   if node.tries > 100
    #     @active.splice @active.indexOf(node), 1  
    #     return
    #   if @edgeCheck(node)
    #     src = node
    #   else 
    #     @active.splice @active.indexOf(node), 1  
    
    return false unless src

    # console.log window.hax.toFixed(2)

    # pick a new location
    dist = 15
    x = src.x + (Math.random()-0.5) * dist
    y = src.y + (Math.random()-0.5) * dist

    # better new location
    dir = Math.random() * Math.PI * 2
    x = src.x + dist * Math.sin(dir)
    y = src.y + dist * Math.cos(dir)

    src.tries = src.tries + 1

    return false unless -(1512-30) < x < (1512-30)
    return false unless -(1256-30) < y < (1256-30)
    return false unless -(window.innerWidth/2-30) < x < (window.innerWidth/2-30)
    return false unless -(window.innerHeight/2-30) < y < (window.innerHeight/2-30)

    return false unless @edgeCheck src
    return false unless @clearance {x, y}, 15

    src.tries = src.tries - 1

    # create a node that is a different type
    if src.type == 'Town'
      if Math.random() < -0.3
        node = new Instance x,y
      else if Math.random() < 0.1 
        node = new Town x,y
      else
        node = new Route x,y
    else if src.type == 'Instance'
      if Math.random() < 0.1
        node = new Instance x,y
      else
        node = new Route x,y
    else
      if Math.random() < 0.65
        node = new Route x,y
      else
        node = new Town x,y
    @graph.add node
    @active.push node

    @graph.link src, node

    for node2 in @graph.nodes
      if node2 != node and node2 != src and 10 < @distance(node, node2) < 20 and (node.type == 'Route' or (true and node.type != node2.type)) and @edgeCheck(node) and @edgeCheck(node2)
        @graph.link node, node2

    return true


window.Map = Map
window.Town = Town
window.Route = Route