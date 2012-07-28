# VPoint
class Point
  constructor: (@x,@y) ->

# VEdge
# /*
#   A class that stores an edge in Voronoi diagram

#   start   : pointer to start point
#   end     : pointer to end point
#   left    : pointer to Voronoi place on the left side of edge
#   right   : pointer to Voronoi place on the right side of edge

#   neighbour : some edges consist of two parts, so we add the pointer to another part to connect them at the end of an algorithm

#   direction : directional vector, from "start", points to "end", normal of |left, right|
#   f, g    : directional coeffitients satisfying equation y = f*x + g (edge lies on this line)
# */

class Edge
  # s a b
  constructor: (@start, @left, @right) ->  
    @end = null
    @neighbour = null


    @f = (@right.x - @left.x) / (@left.y - @right.y)
    @g = @start.y - @f * @start.x ;
    @direction = new Point @right.y - @left.y, -(@right.x - @left.x)
    

# VParabola
# /*
#   A class that stores information about an item in beachline sequence (see Fortune's algorithm). 
#   It can represent an arch of parabola or an intersection between two archs (which defines an edge).
#   In my implementation I build a binary tree with them (internal nodes are edges, leaves are archs).
# */

# /*
#   isLeaf    : flag whether the node is Leaf or internal node
#   site    : pointer to the focus point of parabola (when it is parabola)
#   edge    : pointer to the edge (when it is an edge)
#   cEvent    : pointer to the event, when the arch disappears (circle event)
#   parent    : pointer to the parent node in tree
# */

class Parabola
  constructor: (@site = null) ->
    @isLeaf  = @site != null
    @cEvent  = null
    @edge  = null
    @parent  = null

    @_left = null
    @_right = null



  # void    SetLeft (VParabola * p) {_left  = p; p->parent = this;}
  # void    SetRight(VParabola * p) {_right = p; p->parent = this;}

  # VParabola * Left () { return _left;  }
  # VParabola * Right() { return _right; }

  Right: () -> @_right
  SetRight: (val) -> 
    @_right = val
    val.parent = this

  Left: () -> @_left
  SetLeft: (val) -> 
    @_left = val
    val.parent = this



  GetLeft: () ->
    @GetLeftParent.GetLeftChild()

  GetRight: () ->
    @GetRightParent.GetRightChild()

  GetLeftParent: () ->
    par = @parent
    pLast = this

    while par.Left() == pLast
      return null unless par.parent
      pLast = par
      par = par.parent

    return par

  GetRightParent: () ->
    par = @parent
    pLast = this

    while par.Right() == pLast
      return null unless par.parent 
      pLast = par
      par = par.parent

    return par

  GetLeftChild: () ->
    return null unless this
    par = @Left()
    while !par.isLeaf
      par = par.Right()  # check for infinite loop
    return par

  GetRightChild: () ->
    return null unless this
    par = @Right()
    while !par.isLeaf
      par = par.Left()  # check for infinite loop
    return par

# VEvent
# /*
#   The class for storing place / circle event in event queue.

#   point   : the point at which current event occurs (top circle point for circle event, focus point for place event)
#   pe      : whether it is a place event or not
#   y     : y coordinate of "point", events are sorted by this "y"
#   arch    : if "pe", it is an arch above which the event occurs
# */

class Event
  constructor: (@point, @pe) ->
    @y = @point.y #why does he do this?
    @arch = null

  compareTo: (otherEvent) ->
    return @y < otherEvent.y



# *************************
# /*
#         places    : container of places with which we work
#         edges   : container of edges which will be teh result
#         width   : width of the diagram
#         height    : height of the diagram
#         root    : the root of the tree, that represents a beachline sequence
#         ly      : current "y" position of the line (see Fortune's algorithm)
# */

# /*
#         deleted   : set  of deleted (false) Events (since we can not delete from PriorityQueue
#         points    : list of all new points that were created during the algorithm
#         queue   : priority queue with events to process
# */




class Voronoi
  constructor: (@sites) ->
    @width = 0
    @height = 0

    @places = []
    @edges = []
    @root = null
    @ly = 0

    # deleted = {}
    @points = []
    @queue = []


    # Vertices *    places;
    # Edges *     edges;
    # double      width, height;
    # VParabola *   root;
    # double      ly;

    # std::set<VEvent *>  deleted;
    # std::list<VPoint *> points;
    # std::priority_queue<VEvent *, std::vector<VEvent *>, VEvent::CompareEvent> queue;
    


  GetEdges: (@places, @width, @height) -> # Rename to recalculate or something?
    @root = null
    
    @points = [] #?
    @edges = [] #?
    @queue = [] #?

    # 'true' denotes a place event. This is adding all the places to the event queue.
    @queue.push new Event place, true for place in @places


    # work through the queue
    while @queue.length > 0
      @queue.sort (a,b) -> b.y - a.y
      console.log @queue.map (e) -> "#{e.y.toFixed(2)}, #{e.point.x.toFixed(2)}"

      e = @queue.shift() # this may need to be queue.shift() to keep teh logics the same.
      @ly = e.point.y
      # stupid deleted list check thing
      
      if e.pe then @InsertParabola e.point else @RemoveParabola e

    @FinishEdge @root

    (edge.start = edge.neighbour.end if edge.neighbour?) for edge in @edges

    return @edges

  InsertParabola: (p) ->
    unless @root
      @root = new Parabola p
      return

    if @root.isLeaf && @root.site.y - p.y < 1 # translate: degenerate EVENT - both of the lower places at the same height
      fp = @root.site
      @root.isLeaf = false
      @root.SetLeft new Parabola fp
      @root.SetRight new Parabola p

      s = new Point (p.x + fp.x)/2, @height # translate: The beginning of the middle edge points
      @points.push s

      # translate: decide who left to right
      if p.x > fp.x  
        @root.edge = new Edge s, fp, p 
      else
        @root.edge = new Edge s, p, fp

      @edges.push @root.edge

      return  # instead of else + indent?

    par = @GetParabolaByX p.x

    if par.cEvent
      # deleted.insert par.cEvent
      @queue.splice @queue.indexOf(par.cEvent), 1
      par.cEvent = 0
  
    start = new Point p.x, @GetY par.site, p.x

    @points.push start

    el = new Edge start, par.site, p
    er = new Edge start, p, par.site

    el.neighbour = er  # Why is this one sided?

    @edges.push el

    par.edge = er
    par.isLeaf = false

    p0 = new Parabola par.site
    p1 = new Parabola p
    p2 = new Parabola par.site

    par.SetRight p2
    par.SetLeft new Parabola()
    par.Left().edge = el

    par.Left().SetLeft p0
    par.Left().SetRight p1

    @CheckCircle p0
    @CheckCircle p2

  RemoveParabola: (e) -> # e is an event? o_O
    p1 = e.arch
    xl = p1.GetLeftParent()
    xr = p1.GetRightParent()

    p0 = xl.GetLeftChild()
    p2 = xr.GetRightChild()
  
    throw new Error "error - right and left parabola has the same focus!" if (p0 == p2)

    if p0.cEvent?
      #deleted.insert p0.cEvent
      @queue.splice @queue.indexOf(p0.cEvent), 1
      p0.cEvent = null

    if p2.cEvent?
      #deleted.insert p2.cEvent
      @queue.splice @queue.indexOf(p2.cEvent), 1
      p2.cEvent = null

    p = new Point e.point.x, @GetY p1.site, e.point.x
    @points.push p

    xl.edge.end = p
    xr.edge.end = p

    #higher = null
    par = p1  

    while par != @root
      par = par.parent
      higher = xl if par == xl
      higher = xr if par == xr

    higher.edge = new Edge p, p0.site, p2.site
    @edges.push higher.edge

    gparent = p1.parent.parent #naming?

    if p1.parent.Left() == p1
      gparent.SetLeft p1.parent.Right() if gparent.Left() == p1.parent
      gparent.SetRight p1.parent.Right() if gparent.Right() == p1.parent
    else
      gparent.SetLeft p1.parent.Left() if gparent.Left() == p1.parent
      gparent.SetRight p1.parent.Left() if gparent.Right() == p1.parent


    @CheckCircle p0
    @CheckCircle p2


  FinishEdge: (n) ->  # n is parabola
    return if n.isLeaf
    # mx = 0.0

    if n.edge.direction.x > 0.0
      mx = Math.max @width, n.edge.start.x + 10  # wtf + 10? that can't be right.
    else
      mx = Math.min 0.0, n.edge.start.x - 10 # is the 10 how far over the edge it goes?

  
    end = new Point mx, mx * n.edge.f + n.edge.g
    n.edge.end = end

    @points.push end
  
    @FinishEdge n.Left()
    @FinishEdge n.Right()
      

  GetXOfEdge: (par, y) ->
    left= par.GetLeftChild()
    right = par.GetRightChild()

    p = left.site
    r = right.site

    dp = 2.0 * (p.y - y)
    a1 = 1.0 / dp
    b1 = -2.0 * p.x / dp
    c1 = y + dp / 4 + p.x * p.x / dp


    dp = 2.0 * (r.y - y)      
    a2 = 1.0 / dp
    b2 = -2.0 * r.x / dp
    c2 = @ly + dp / 4 + r.x * r.x / dp
       
    a = a1 - a2
    b = b1 - b2
    c = c1 - c2

    disc = b * b - 4 * a * c
    x1 = (-b + Math.sqrt(disc)) / (2*a)
    x2 = (-b - Math.sqrt(disc)) / (2*a)

    # ry = 0.0
    if p.y < r.y
      ry = Math.max x1, x2      
    else
      ry = Math.min x1, x2

    return ry


  GetParabolaByX: (xx) ->
    par = @root
    # x = 0.0
    while !par.isLeaf # translate: walk until you hit a tree on the appropriate sheet
      x = @GetXOfEdge par, @ly
      if x > xx
        par = par.Left() 
      else
        par = par.Right()

    return par


  GetY: (p, x) -> # translate: focus/focal point, x-coordinates
    dp = 2 * (p.y - @ly)
    a1 = 1 / dp
    b1 = -2 * p.x / dp
    c1 = @ly + dp / 4 + p.x * p.x / dp

    return a1 * x * x + b1 * x + c1
    
  CheckCircle: (b) ->
    lp = b.GetLeftParent()
    rp = b.GetRightParent()
    
    a = lp.GetLeftChild() if lp?
    c = rp.GetRightChild() if rp?

    #return if (!a || !c || a.site == c.site)  #switch to below
    return unless a? && c? && a.site != c.site 

    s = @GetEdgeIntersection lp.edge, rp.edge
    return unless s?

    dx = a.site.x - s.x
    dy = a.site.y - s.y

    d = Math.sqrt dx * dx + dy * dy

    return if s.y - d >= @ly

    e = new Event new Point(s.x, s.y - d), false
    @points.push e.point
    b.cEvent = e
    e.arch = b
    
    @queue.push e

  GetEdgeIntersection: (a, b) ->      
    x = (b.g - a.g) / (a.f - b.f)
    x = Infinity if isNaN x
    y = a.f * x + a.g
    y = Infinity if isNaN y
    
    

    console.log x,y, a.f, a.g
    # This shit is silly, remove the costly / and just check sign.
    return null if (x - a.start.x) / (a.direction.x) < 0
    return null if (y - a.start.y) / (a.direction.y) < 0
    return null if (x - b.start.x) / (b.direction.x) < 0
    return null if (y - b.start.y) / (b.direction.y) < 0



    p = new Point x, y
    @points.push p
    return p












