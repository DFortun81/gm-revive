// paladin_aura_update();
// Called by a Paladin: adds Devotion Aura to allies that came into range and removes it from
// allies that left (or died). A dead Paladin removes the aura from everyone.
////////////////////////////////////////////////////////////////////////////////////////////
var i, u, inrange;

for(i = ds_list_size(_aura_list) - 1; i >= 0; i -= 1) {
    u = ds_list_find_value(_aura_list, i);
    inrange = false;
    if(!dead && instance_exists(u)) {
        if(!u.dead && point_distance(x, y, u.x, u.y) < _aura_range) inrange = true;
    }
    if(!inrange) {
        if(instance_exists(u)) {
            u._devotion_sources -= 1;
            if(u._devotion_sources <= 0) {
                u._devotion_sources = 0;
                u._damagereduction -= _aura_reduction;
            }
        }
        ds_list_delete(_aura_list, i);
    }
}

if(dead) exit;

with(obj_unit) {
    if(_faction == other._faction && !dead && _jobclass != class_mirrorimage) {
        if(point_distance(x, y, other.x, other.y) < other._aura_range) {
            if(ds_list_find_index(other._aura_list, id) == -1) {
                ds_list_add(other._aura_list, id);
                _devotion_sources += 1;
                if(_devotion_sources == 1) _damagereduction += other._aura_reduction;
            }
        }
    }
}
