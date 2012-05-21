var Edge, Event, Parabola, Point, Voronoi;
Point = (function() {
  function Point(x, y) {
    this.x = x;
    this.y = y;
  }
  return Point;
})();
Edge = (function() {
  function Edge(start, left, right) {
    this.start = start;
    this.left = left;
    this.right = right;
    this.end = null;
    this.neighbour = null;
    this.f = (this.right.x - this.left.x) / (this.left.y - this.right.y);
    this.g = this.start.y - this.f * this.start.x;
    this.direction = new Point(this.right.y - this.left.y, -(this.right.x - this.left.x));
  }
  return Edge;
})();
Parabola = (function() {
  function Parabola(site) {
    this.site = site != null ? site : null;
    this.isLeaf = this.site !== null;
    this.cEvent = null;
    this.edge = null;
    this.parent = null;
    this._left = null;
    this._right = null;
  }
  Parabola.prototype.Right = function() {
    return this._right;
  };
  Parabola.prototype.SetRight = function(val) {
    return this._right = val;
  };
  Parabola.prototype.Left = function() {
    return this._left;
  };
  Parabola.prototype.SetLeft = function(val) {
    return this._left = val;
  };
  Parabola.prototype.GetLeft = function() {
    return this.GetLeftParent.GetLeftChild();
  };
  Parabola.prototype.GetRight = function() {
    return this.GetRightParent.GetRightChild();
  };
  Parabola.prototype.GetLeftParent = function() {
    var pLast, par;
    par = this.parent;
    pLast = this;
    console.log(this, par);
    if (par == null) {
      return;
    }
    while (par.Left() === pLast) {
      if (!par.parent) {
        return null;
      }
      pLast = par;
      par = par.parent;
    }
    return par;
  };
  Parabola.prototype.GetRightParent = function() {
    var pLast, par;
    par = this.parent;
    pLast = this;
    console.log(this, par);
    if (par == null) {
      return;
    }
    while (par.Right() === pLast) {
      if (!par.parent) {
        return null;
      }
      pLast = par;
      par = par.parent;
    }
    return par;
  };
  Parabola.prototype.GetLeftChild = function() {
    var par;
    if (!this) {
      return null;
    }
    par = this.Left();
    while (!par.isLeaf) {
      par = par.Right();
    }
    return par;
  };
  Parabola.prototype.GetRightChild = function() {
    var par;
    if (!this) {
      return null;
    }
    par = this.Right();
    while (!par.isLeaf) {
      par = par.Left();
    }
    return par;
  };
  return Parabola;
})();
Event = (function() {
  function Event(point, pe) {
    this.point = point;
    this.pe = pe;
    this.y = this.point.y;
    this.arch = null;
  }
  Event.prototype.compareTo = function(otherEvent) {
    return this.y < otherEvent.y;
  };
  return Event;
})();
Voronoi = (function() {
  function Voronoi(sites) {
    this.sites = sites;
    this.width = 999;
    this.height = 999;
    this.places = [];
    this.edges = [];
    this.root = null;
    this.ly = 0;
    this.points = [];
    this.queue = [];
  }
  Voronoi.prototype.GetEdges = function(places, width, height) {
    var e, edge, place, _i, _j, _len, _len2, _ref, _ref2;
    this.places = places;
    this.width = width;
    this.height = height;
    this.root = null;
    this.points = [];
    this.edges = [];
    this.queue = [];
    _ref = this.places;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      place = _ref[_i];
      this.queue.push(new Event(place, true));
    }
    while (this.queue.length > 0) {
      e = this.queue.shift();
      this.ly = e.point.y;
      if (e.pe) {
        this.InsertParabola(e.point);
      } else {
        this.RemoveParabola(e);
      }
    }
    this.FinishEdge(this.root);
    _ref2 = this.edges;
    for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
      edge = _ref2[_j];
      if (edge.neighbor != null) {
        edge.start = edge.neighbour.end;
      }
    }
    return this.edges;
  };
  Voronoi.prototype.InsertParabola = function(p) {
    var el, er, fp, p0, p1, p2, par, s, start;
    if (!this.root) {
      this.root = new Parabola(p);
      return;
    }
    if (this.root.isLeaf && this.root.site.y - p.y < 1) {
      fp = this.root.site;
      this.root.isLeaf = false;
      this.root.SetLeft(new Parabola(fp));
      this.root.SetRight(new Parabola(p));
      s = new Point((p.x + fp.x) / 2, this.height);
      this.points.push(s);
      if (p.x > fp.x) {
        this.root.edge = new Edge(s, fp, p);
      } else {
        this.root.edge = new Edge(s, p, fp);
      }
      this.edges.push(this.root.edge);
      return;
    }
    par = this.GetParabolaByX(p.x);
    if (par.cEvent) {
      queue.splice(queue.indexOf(par.cEvent), 1);
      par.cEvent = 0;
    }
    start = new Point(p.x, this.GetY(par.site, p.x));
    this.points.push(start);
    el = new Edge(start, par.site, p);
    er = new Edge(start, p, par.site);
    el.neighbor = er;
    this.edges.push(el);
    par.edge = er;
    par.isLeaf = false;
    p0 = new Parabola(par.site);
    p1 = new Parabola(p);
    p2 = new Parabola(par.site);
    par.SetRight(p2);
    par.SetLeft(new Parabola());
    par.Left().edge = el;
    par.Left().SetLeft(p0);
    par.Left().SetRight(p1);
    this.CheckCircle(p0);
    return this.CheckCircle(p2);
  };
  Voronoi.prototype.RemoveParabola = function(e) {
    var gparent, higher, p, p0, p1, p2, par, xl, xr;
    p1 = e.arch;
    xl = p1.GetLeftParent();
    xr = p1.GetRightParent();
    p0 = xl.GetLeftChild();
    p2 = xr.GetRightChild();
    if (p0 === p2) {
      throw new Error("error - right and left parabola has the same focus!");
    }
    if (p0.cEvent != null) {
      queue.splice(queue.indexOf(p0.cEvent), 1);
      p0.cEvent = null;
    }
    if (p2.cEvent != null) {
      queue.splice(queue.indexOf(p2.cEvent), 1);
      p2.cEvent = null;
    }
    p = new Point(e.point.x, this.GetY(p1.site, e.point.x));
    this.points.push(p);
    xl.edge.end = p;
    xr.edge.end = p;
    par = p1;
    while (par !== this.root) {
      par = par.parent;
      if (par === xl) {
        higher = xl;
      }
      if (par === xr) {
        higher = xr;
      }
    }
    higher.edge = new Edge(p, p0.site, p2.site);
    this.edges.push(higher.edge);
    gparent = p1.parent.parent;
    if (p1.parent.Left() === p1) {
      if (gparent.Left() === p1.parent) {
        gparent.SetLeft(p1.parent.Right());
      }
      if (gparent.Right() === p1.parent) {
        gparent.SetRight(p1.parent.Right());
      }
    } else {
      if (gparent.Left() === p1.parent) {
        gparent.SetLeft(p1.parent.Left());
      }
      if (gparent.Right() === p1.parent) {
        gparent.SetRight(p1.parent.Left());
      }
    }
    this.CheckCircle(p0);
    return this.CheckCircle(p2);
  };
  Voronoi.prototype.FinishEdge = function(n) {
    var end, mx;
    if (n.isLeaf) {
      return;
    }
    if (n.edge.direction.x > 0.0) {
      mx = Math.max(this.width, n.edge.start.x + 10);
    } else {
      mx = Math.min(0.0, n.edge.start.x - 10);
    }
    end = new Point(mx, mx * n.edge.f + n.edge.g);
    n.edge.end = end;
    this.points.push(end);
    this.FinishEdge(n.Left());
    return this.FinishEdge(n.Right());
  };
  Voronoi.prototype.GetXOfEdge = function(par, y) {
    var a, a1, a2, b, b1, b2, c, c1, c2, disc, dp, left, p, r, right, ry, x1, x2;
    left = par.GetLeftChild();
    right = par.GetRightChild();
    p = left.site;
    r = right.site;
    dp = 2.0 * (p.y - y);
    a1 = 1.0 / dp;
    b1 = -2.0 * p.x / dp;
    c1 = y + dp / 4 + p.x * p.x / dp;
    dp = 2.0 * (r.y - y);
    a2 = 1.0 / dp;
    b2 = -2.0 * r.x / dp;
    c2 = this.ly + dp / 4 + r.x * r.x / dp;
    a = a1 - a2;
    b = b1 - b2;
    c = c1 - c2;
    disc = b * b - 4 * a * c;
    x1 = (-b + Math.sqrt(disc)) / (2 * a);
    x2 = (-b - Math.sqrt(disc)) / (2 * a);
    if (p.y < r.y) {
      ry = Math.max(x1, x2);
    } else {
      ry = Math.min(x1, x2);
    }
    return ry;
  };
  Voronoi.prototype.GetParabolaByX = function(xx) {
    var par, x;
    par = this.root;
    while (!par.isLeaf) {
      x = this.GetXOfEdge(par, this.ly);
      if (x > xx) {
        par = par.Left();
      } else {
        par = par.Right();
      }
    }
    return par;
  };
  Voronoi.prototype.GetY = function(p, x) {
    var a1, b1, c1, dp;
    dp = 2 * (p.y - this.ly);
    a1 = 1 / dp;
    b1 = -2 * p.x / dp;
    c1 = this.ly + dp / 4 + p.x * p.x / dp;
    return a1 * x * x + b1 * x + c1;
  };
  Voronoi.prototype.CheckCircle = function(b) {
    var a, c, d, dx, dy, e, lp, rp, s;
    lp = b.GetLeftParent();
    rp = b.GetRightParent();
    a = lp.GetLeftChild();
    c = rp.GetRightChild();
    if (!a || !c || a.site === c.site) {
      return;
    }
    s = this.GetEdgeIntersection(lp.edge, rp.edge);
    if (s == null) {
      return;
    }
    dx = a.site.x - s.x;
    dy = a.site.y - s.y;
    d = Math.sqrt(dx * dx + dy * dy);
    if (s.y - d >= this.ly) {
      return;
    }
    e = new Event(new Point(s.x, s.y - d), false);
    this.points.push(e.point);
    b.cEvent = e;
    e.arch = b;
    return this.queue.push(e);
  };
  Voronoi.prototype.GetEdgeIntersection = function(a, b) {
    var p, x, y;
    x = (b.g - a.g) / (a.f - b.f);
    y = a.f * x + a.g;
    if ((x - a.start.x) / a.direction.x < 0) {
      return null;
    }
    if ((y - a.start.y) / a.direction.y < 0) {
      return null;
    }
    if ((x - b.start.x) / b.direction.x < 0) {
      return null;
    }
    if ((y - b.start.y) / b.direction.y < 0) {
      return null;
    }
    p = new Point(x, y);
    this.points.push(p);
    return p;
  };
  return Voronoi;
})();