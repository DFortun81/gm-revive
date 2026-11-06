// caster_blizzard_count(x, y);
// Called by a Caster: how many enemy units (not sheep, not Mirror Images) stand within
// Blizzard's radius of the point.
////////////////////////////////////////////////////////////////////////////////////////////
var n, bx, by, me;
n = 0; bx = argument0; by = argument1; me = id;
with(obj_unit) {
    if(_faction != me._faction && !dead && !_polymorphed && _jobclass != class_mirrorimage) {
        if(point_distance(x, y, bx, by) < me._blizzard_radius) n += 1;
    }
}
return n;
