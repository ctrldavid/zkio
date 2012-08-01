class Edge
  constructor: (@start, @end) ->

class Node
  constructor: () ->
    @edges = []
  # Find adjacent nodes by searching through the edge list.
  adj: () ->
    (if edge.start == this then edge.end else edge.start) for edge in @edges
  remove: (edge) ->
    for edge2, index in @edges
      if edge2 == edge
        @edges.splice index, 1    

class Graph
  constructor: () ->
    @nodes = []
    @edges = []
  add: (node) ->
    @nodes.push node
  
  remove: (node) ->
    # find it in the nodes list and remove it
    for node2, index in @nodes
      if node2 == node
        @nodes.splice index, 1

    # remove its edges
    for edge in node.edges
      # find in the graph
      for edge2, index in @edges
        if edge2 == edge
          @edges.splice index, 1
      # remove from node's edge list
      edge.start.remove edge
      edge.end.remove edge

  link: (node1, node2) ->
    # TODO: check that nodes are in the graph
    edge = new Edge node1, node2
    @edges.push edge
    node1.edges.push edge
    node2.edges.push edge


window.Graph = Graph
window.Edge = Edge
window.Node = Node