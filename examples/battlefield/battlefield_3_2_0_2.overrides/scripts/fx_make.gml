// fx_make(kind, x, y, h, colour, size, life);
// Creates one obj_fx particle and returns it, so the caller can set anything else (velocity, spin...).
// Kinds: 0 flash (a glow that swells and fades), 1 ring (expands; _squash 0.5 lies it on the ground),
// 2 sparkle, 3 shard, 4 mote (spirals into _master), 5 streak (a beam from _x1,_y1,_h1 to here),
// 6 star, 7 slash (a crescent at image_angle), 8 implode (a ring that collapses inward), 9 bubble (swells
// and pops into a little ring). Particles are additive unless _add is set to false.
// (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var p;
p = instance_create(argument1, argument2, obj_fx);
p._kind = argument0;
p._h = argument3;
p._col = argument4;
p._size = argument5;
p._maxlife = argument6;
return p;
