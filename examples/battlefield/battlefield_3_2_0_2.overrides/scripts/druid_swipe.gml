// druid_swipe();
// Druid Special Ability: Swipe (Cat or Bear)
// Deals full damage to the target and cleaves the nearest two enemies around it for half.
/////////////////////////////////////////////////////////////////////////////////////////////////////
var i, n, best, bestdist, dist, hit;
if(!units_exists(_target)) exit;
create_text_effect(x, y, c_yellow, "-swipe-");
create_heroicstrike_effect(_target.x, _target.y);
unit_damage(_target, c_yellow, _swipe_amount);

hit = ds_list_create();
ds_list_add(hit, _target);
for(n = 0; n < _swipe_cleave_count; n += 1) {
    best = -1;
    bestdist = range_melee * 1.5;
    with(obj_unit) {
        if(_faction != other._faction && !dead && ds_list_find_index(hit, id) == -1) {
            dist = point_distance(x, y, other._target.x, other._target.y);
            if(dist < bestdist) {
                bestdist = dist;
                best = id;
            }
        }
    }
    if(best == -1) break;
    ds_list_add(hit, best);
    create_heroicstrike_effect(best.x, best.y);
    unit_damage(best, c_yellow, _swipe_amount * _swipe_cleave_percent);
}
ds_list_destroy(hit);
_swipe_cooldown = _swipe_cooldown_time;
