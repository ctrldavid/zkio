// Generated by CoffeeScript 1.3.1
(function() {
  var Point, PointSpread, bbox, canvas, ctx, height, points, voronoi, width, x;

  Point = (function() {

    Point.name = 'Point';

    function Point(x, y) {
      this.x = x;
      this.y = y;
      this.dx = 0;
      this.dy = 0;
      this.down = true;
      this.heat = Math.random() * 20 + 40;
    }

    return Point;

  })();

  PointSpread = (function() {

    PointSpread.name = 'PointSpread';

    function PointSpread(width, height, spacing) {
      this.width = width;
      this.height = height;
      this.spacing = spacing;
      this.points = [];
      this.points.push(new Point(this.width / 2, this.height / 2));
      this.generate();
    }

    PointSpread.prototype.rw = function() {
      return Math.random() * this.width;
    };

    PointSpread.prototype.rh = function() {
      return Math.random() * this.height;
    };

    PointSpread.prototype.dist = function(a, b) {
      return Math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
    };

    PointSpread.prototype.generate = function() {
      var attempts, dist, fail, fails, newPoint, point, _i, _len, _ref, _results;
      attempts = 0;
      fails = 0;
      _results = [];
      while (attempts < 1000 || fails / attempts < 0.99) {
        newPoint = new Point(this.rw(), this.rh());
        fail = false;
        _ref = this.points;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          point = _ref[_i];
          dist = this.dist(point, newPoint);
          if (dist < this.spacing) {
            fail = true;
          }
        }
        if (!fail) {
          this.points.push(newPoint);
        }
        attempts++;
        if (fail) {
          _results.push(fails++);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    PointSpread.prototype.settle = function() {
      var d, old1, old2, point, point1, point2, x, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _results;
      _ref = this.points;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        point1 = _ref[_i];
        _ref1 = this.points;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          point2 = _ref1[_j];
          if (point1 === point2) {
            continue;
          }
          d = this.dist(point1, point2);
          if (d < 30) {
            old1 = point1.heat;
            old2 = point2.heat;
            x = 0.999;
            point1.heat = x * old1 + (1 - x) * old2;
            point2.heat = x * old2 + (1 - x) * old1;
            point1.dx += (point2.dx - point1.dx) * 0.001;
            point1.dy += (point2.dy - point1.dy) * 0.001;
            if (d > 20) {
              point1.dx += (point2.x - point1.x) * 0.0001 / (d - 19);
              point1.dy += (point2.y - point1.y) * 0.0001 / (d - 19);
            } else if (d > 0 && d < 20) {
              point1.dx -= (point2.x - point1.x) * 0.2 / (d + 0);
              point1.dy -= (point2.y - point1.y) * 0.2 / (d + 0);
            }
          }
        }
      }
      _ref2 = this.points;
      _results = [];
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        point = _ref2[_k];
        point.x += point.dx * 3;
        point.y += point.dy * 3;
        point.dx = point.dx * 0.99;
        point.dy = point.dy * 0.99;
        point.dy = point.dy - 0.0004 * (point.heat - 50);
        point.heat -= 0.05;
        if (point.y < 50 && point.heat > 0) {
          point.heat -= 0.003;
        }
        if (point.y > this.height - 50 && point.heat < 100) {
          _results.push(point.heat += 0.7);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return PointSpread;

  })();

  width = 500;

  height = 300;

  canvas = document.getElementById('heat');

  canvas.width = width;

  canvas.height = height;

  ctx = canvas.getContext('2d');


  x = new PointSpread(width, height, 15);

  console.log(x.points);

  points = x.points;

  bbox = {
    xl: 0,
    xr: width,
    yt: 0,
    yb: height
  };

  voronoi = new Voronoi();

  canvas.addEventListener('click', function() {
    var p, _i, _len, _ref, _results;
    x.generate();
    _ref = x.points;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      p = _ref[_i];
      p.dx = Math.random() - 0.5;
      _results.push(p.dy = Math.random() - 0.5);
    }
    return _results;
  });

  window.setInterval(function() {
    var b, c, cell, edge, halfedge, p, r, result, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _results;
    result = voronoi.compute(points, bbox);
    ctx.clearRect(0, 0, width, height);
    ctx.fillStyle = "rgba(0,64,0,0.5)";
    _ref = result.cells;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      cell = _ref[_i];
      c = cell.site.heat / 100;
      r = Math.floor(c * 256);
      b = Math.floor((1 - c) * 256);
      ctx.fillStyle = "rgba(" + r + ",0," + b + ",0.5)";
      ctx.beginPath();
      ctx.moveTo(cell.halfedges[0].getStartpoint().x, cell.halfedges[0].getStartpoint().y);
      _ref1 = cell.halfedges;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        halfedge = _ref1[_j];
        ctx.lineTo(halfedge.getEndpoint().x, halfedge.getEndpoint().y);
      }
      ctx.closePath();
      ctx.fill();
    }
    ctx.strokeStyle = "rgba(127,0,127,0.1)";
    _ref2 = result.edges;
    for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
      edge = _ref2[_k];
      ctx.beginPath();
      ctx.moveTo(edge.va.x, edge.va.y);
      ctx.lineTo(edge.vb.x, edge.vb.y);
      ctx.stroke();
    }
    ctx.fillStyle = "rgba(0,0,0,1.0)";
    x.settle();
    _results = [];
    for (_l = 0, _len3 = points.length; _l < _len3; _l++) {
      p = points[_l];
      if (p.x < 0) {
        p.x = 0;
        p.dx = -p.dx;
      }
      if (p.y < 0) {
        p.y = 0;
        p.dy = -p.dy;
      }
      if (p.x > width) {
        p.x = width;
        p.dx = -p.dx;
      }
      if (p.y > height) {
        p.y = height;
        _results.push(p.dy = -p.dy);
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  }, 50);

}).call(this);
