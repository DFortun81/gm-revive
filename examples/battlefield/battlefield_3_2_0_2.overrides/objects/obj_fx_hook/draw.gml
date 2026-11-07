var sx, sy, ex, ey, n, i, t, px, py, lx, ly, a, h1, h2;
if(!instance_exists(_master) || !units_exists(_victim)) exit;
h1 = _master.sprite_height * 0.5; h2 = _victim.sprite_height * 0.5;
sx = _master.x; sy = _master.y - h1;
ex = _hx; ey = _hy - h2;
n = max(2, floor(point_distance(sx, sy, ex, ey) / 7));
// the chain: dark links with a glint, sagging a little
lx = sx; ly = sy;
for(i = 1; i <= n; i += 1) {
    t = i / n;
    px = sx + (ex - sx) * t;
    py = sy + (ey - sy) * t + sin(t * pi) * 6;
    draw_set_color(make_color_rgb(40, 35, 30)); draw_line_width(lx, ly, px, py, 3);
    draw_set_color(make_color_rgb(150, 145, 135)); draw_line_width(lx, ly - 0.5, px, py - 0.5, 1);
    lx = px; ly = py;
}
// the hook
a = point_direction(sx, sy, ex, ey);
draw_sprite_ext(sprite_index, 4, ex, ey, 0.45, 0.45, a + 90, make_color_rgb(200, 195, 185), 1);
draw_sprite_ext(sprite_index, 0, ex, ey, 0.25, 0.25, 0, make_color_rgb(255, 230, 200), 0.6);
draw_set_color(c_white);
