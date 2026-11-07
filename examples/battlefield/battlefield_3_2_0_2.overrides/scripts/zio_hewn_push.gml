// zio_hewn_push(unit, distance);
// Hewn throws a unit away from Zio inside a vortex of dust and debris (the vortex is the Call to Arms
// effect, spr_hewn_vortex, drawn as it drew it: obj_fx_vortex). Bosses don't move. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var u, d, ox, oy, k, n, p;
u = argument0;
if(!units_exists(u)) exit;
with(instance_create(u.x, u.y, obj_fx_vortex)) _master = u;
if(u.dead || u._bossid != -1) exit;
d = point_direction(x, y, u.x, u.y);
ox = u.x; oy = u.y;
u.x = max(16, min(room_width - 16, u.x + lengthdir_x(argument1, d)));
u.y = max(16, min(room_height - 16, u.y + lengthdir_y(argument1, d)));
u._destx = u.x;
u._desty = u.y;
// (gm-revive overrides) a gust trail and dust along the line it was thrown
p = fx_make(5, u.x, u.y, u.sprite_height * 0.5, make_color_rgb(220, 235, 255), 0.3, 14);
p._x1 = ox; p._y1 = oy; p._h1 = u.sprite_height * 0.5;
n = max(1, floor(point_distance(ox, oy, u.x, u.y) / 10));
for(k = 0; k <= n; k += 1) {
    p = fx_make(0, ox + (u.x - ox) * k / n, oy + (u.y - oy) * k / n, 2, make_color_rgb(175, 155, 115), 0.3, 18 + k * 2);
    p._add = false; p._squash = 0.55; p._grow = 1.8; p._alpha = 0.5;
}
