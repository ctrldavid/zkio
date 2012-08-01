// Generated by CoffeeScript 1.3.3
(function() {
  var Canvas;

  Canvas = (function() {

    function Canvas(width, height) {
      var _this = this;
      this.width = width;
      this.height = height;
      this.element = document.createElement('canvas');
      this.element.width = this.width;
      this.element.height = this.height;
      document.body.appendChild(this.element);
      this.ctx = this.element.getContext('2d');
      this.element.addEventListener('mousedown', function(e) {
        if (e.metaKey) {
          return _this.save();
        }
      });
    }

    Canvas.prototype.center = function() {
      return this.ctx.setTransform(1, 0, 0, 1, this.width / 2, this.height / 2);
    };

    Canvas.prototype.save = function() {
      console.log(this.element.toDataURL());
      return window.open(this.element.toDataURL(), "");
    };

    Canvas.prototype.inside = function(_arg) {
      var x, y;
      x = _arg.x, y = _arg.y;
      if (x < -this.width / 2) {
        return false;
      }
      if (y < -this.height / 2) {
        return false;
      }
      if (x > this.width / 2) {
        return false;
      }
      if (y > this.height / 2) {
        return false;
      }
      return true;
    };

    Canvas.prototype.clear = function() {
      this.ctx.fillStyle = Colour.Black.rgba();
      return this.ctx.fillRect(-this.width / 2, -this.height / 2, this.width, this.height);
    };

    Canvas.prototype.circle = function(x, y, colour, size) {
      this.ctx.fillStyle = Colour.Black.rgba();
      this.ctx.strokeStyle = colour.rgba();
      this.ctx.lineWidth = 2;
      this.ctx.beginPath();
      this.ctx.arc(x, y, size, 0, Math.PI * 2, true);
      this.ctx.closePath();
      this.ctx.fill();
      return this.ctx.stroke();
    };

    Canvas.prototype.basePlate = function(x, y, type) {
      var w;
      this.ctx.fillStyle = Colour.BasePlate.rgba();
      if (type === 'Obstacle') {
        w = 45;
      } else {
        w = 15;
      }
      this.ctx.beginPath();
      this.ctx.arc(x, y, w, 0, Math.PI * 2, true);
      this.ctx.closePath();
      return this.ctx.fill();
    };

    Canvas.prototype.basePlateBorder = function(x, y, type) {
      var w;
      this.ctx.strokeStyle = Colour.BasePlateBorder.rgba();
      this.ctx.lineWidth = 2;
      if (type === 'Obstacle') {
        w = 45;
      } else {
        w = 15;
      }
      this.ctx.beginPath();
      this.ctx.arc(x, y, w, 0, Math.PI * 2, true);
      this.ctx.closePath();
      return this.ctx.stroke();
    };

    Canvas.prototype.line = function(sx, sy, ex, ey, colour, width) {
      this.ctx.strokeStyle = colour.rgba();
      this.ctx.lineWidth = width || 1;
      this.ctx.beginPath();
      this.ctx.moveTo(sx, sy);
      this.ctx.lineTo(ex, ey);
      return this.ctx.stroke();
    };

    return Canvas;

  })();

  window.Canvas = Canvas;

}).call(this);
