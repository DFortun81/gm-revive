// zio_hewn_push(unit, distance);
// Hewn throws a unit away from Zio inside a vortex of dust and debris (the vortex is the Call to Arms
// effect, spr_hewn_vortex). Bosses don't move. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var u, d;
u = argument0;
if(!units_exists(u)) exit;
with(instance_create(u.x, u.y, obj_fx_strip)) { _spr = spr_hewn_vortex; _f0 = 0; _f1 = 2; _len = 15; }
if(u.dead || u._bossid != -1) exit;
d = point_direction(x, y, u.x, u.y);
u.x = max(16, min(room_width - 16, u.x + lengthdir_x(argument1, d)));
u.y = max(16, min(room_height - 16, u.y + lengthdir_y(argument1, d)));
u._destx = u.x;
u._desty = u.y;
