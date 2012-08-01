(function() {
  var Edge, Graph, Node;

  Edge = (function() {

    function Edge(start, end) {
      this.start = start;
      this.end = end;
    }

    return Edge;

  })();

  Node = (function() {

    function Node() {
      this.edges = [];
    }

    Node.prototype.adj = function() {
      var edge, _i, _len, _ref, _results;
      _ref = this.edges;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        edge = _ref[_i];
        _results.push(edge.start === this ? edge.end : edge.start);
      }
      return _results;
    };

    Node.prototype.remove = function(edge) {
      var edge2, index, _len, _ref, _results;
      _ref = this.edges;
      _results = [];
      for (index = 0, _len = _ref.length; index < _len; index++) {
        edge2 = _ref[index];
        if (edge2 === edge) {
          _results.push(this.edges.splice(index, 1));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return Node;

  })();

  Graph = (function() {

    function Graph() {
      this.nodes = [];
      this.edges = [];
    }

    Graph.prototype.add = function(node) {
      return this.nodes.push(node);
    };

    Graph.prototype.remove = function(node) {
      var edge, edge2, index, node2, _i, _len, _len2, _len3, _ref, _ref2, _ref3, _results;
      _ref = this.nodes;
      for (index = 0, _len = _ref.length; index < _len; index++) {
        node2 = _ref[index];
        if (node2 === node) this.nodes.splice(index, 1);
      }
      _ref2 = node.edges;
      _results = [];
      for (_i = 0, _len2 = _ref2.length; _i < _len2; _i++) {
        edge = _ref2[_i];
        _ref3 = this.edges;
        for (index = 0, _len3 = _ref3.length; index < _len3; index++) {
          edge2 = _ref3[index];
          if (edge2 === edge) this.edges.splice(index, 1);
        }
        edge.start.remove(edge);
        _results.push(edge.end.remove(edge));
      }
      return _results;
    };

    Graph.prototype.link = function(node1, node2) {
      var edge;
      edge = new Edge(node1, node2);
      this.edges.push(edge);
      node1.edges.push(edge);
      return node2.edges.push(edge);
    };

    return Graph;

  })();

  window.Graph = Graph;

  window.Edge = Edge;

  window.Node = Node;

}).call(this);
