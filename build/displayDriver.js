(function() {
  this.DisplayDriver = (function() {
    var drawRectangle;

    function DisplayDriver() {
      this.c = document.getElementById("coffee100Canvas");
      this.ctx = c.getContext("2d");
    }

    drawRectangle = function(r, g, b, x1, y1, x2, y2) {
      this.ctx.fillStyle = "rgb(" + r + "," + g + "," + b + ")";
      return this.ctx.fillRect(x1, y1, x2, y2);
    };

    return DisplayDriver;

  })();

  drawRectangle(0, 0, 0, 0, 0, 30, 30);

}).call(this);
