(function() {
  var __slice = Array.prototype.slice;

  Snake.EventEmitter = (function() {

    function EventEmitter() {}

    EventEmitter.prototype.on = function(name, fnc) {
      var _base;
      this.listeners || (this.listeners = {});
      (_base = this.listeners)[name] || (_base[name] = []);
      return this.listeners[name].push(fnc);
    };

    EventEmitter.prototype.emit = function() {
      var args, fnc, name, _i, _len, _ref, _ref2, _results;
      name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if ((name != null) && ((_ref = this.listeners) != null ? _ref[name] : void 0)) {
        _ref2 = this.listeners[name];
        _results = [];
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          fnc = _ref2[_i];
          _results.push(fnc.apply(this, args));
        }
        return _results;
      }
    };

    return EventEmitter;

  })();

}).call(this);
