var canvas, ctx, edge, edges, i, r, s, sites, v, _i, _j, _len, _len2;
r = function(max, min) {
  if (min == null) {
    min = 0;
  }
  return Math.random() * (max - min) + min;
};
sites = [];
for (i = 1; i <= 50; i++) {
  sites.push(new Point(r(500), r(500)));
}
canvas = document.createElement('canvas');
canvas.width = 500;
canvas.height = 500;
ctx = canvas.getContext('2d');
for (_i = 0, _len = sites.length; _i < _len; _i++) {
  s = sites[_i];
  ctx.fillRect(s.x - 1, s.y - 1, 3, 3);
}
document.body.appendChild(canvas);
v = new Voronoi();
edges = v.GetEdges(sites, 500, 500);
for (_j = 0, _len2 = edges.length; _j < _len2; _j++) {
  edge = edges[_j];
  ctx.beginPath();
  ctx.moveTo(edge.start.x, edge.start.y);
  ctx.lineTo(edge.end.x, edge.end.y);
  ctx.stroke();
}