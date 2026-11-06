// druid_swipe_targets();
// How many enemies (including the Druid's target) are close enough to the target to be hit by Swipe.
/////////////////////////////////////////////////////////////////////////////////////////////////////
var n;
n = 0;
if(!units_exists(_target)) return 0;
with(obj_unit) {
    if(_faction != other._faction && !dead) {
        if(point_distance(x, y, other._target.x, other._target.y) < range_melee * 1.5) n += 1;
    }
}
return n;
