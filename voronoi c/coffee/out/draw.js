var canvas, ctx, edges, i, r, s, sites, v, _i, _len;
r = function(max, min) {
  if (min == null) {
    min = 0;
  }
  return Math.random() * (max - min) + min;
};
sites = [];
for (i = 1; i < 100; i++) {
  sites.push(new Point(r(1000), r(1000)));
}
canvas = document.createElement('canvas');
canvas.width = 1000;
canvas.height = 1000;
ctx = canvas.getContext('2d');
for (_i = 0, _len = sites.length; _i < _len; _i++) {
  s = sites[_i];
  ctx.fillRect(s.x - 1, s.y - 1, 3, 3);
}
document.body.appendChild(canvas);
v = new Voronoi();
edges = v.GetEdges(sites, 1000, 1000);
console.log(edges);