// Generated by CoffeeScript 1.3.3
(function() {

  window.addEventListener('load', function() {
    window.test3 = new Visualisation();
    window.test3.placeObstacles();
    window.test3.draw();
    return window.setInterval(function() {
      var x, _i, _results;
      _results = [];
      for (x = _i = 1; _i <= 10; x = ++_i) {
        _results.push(window.test3.gen());
      }
      return _results;
    }, 1);
  });

}).call(this);
