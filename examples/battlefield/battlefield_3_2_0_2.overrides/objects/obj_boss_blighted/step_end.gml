var i, u, n, pick, k, dmg, me, cands;
event_inherited();
if(dead || global.toggle_pause || !_fight_started) exit;
me = id;

// Blight Aura
_aura_timer -= 1;
if(_aura_timer <= 0) {
    _aura_timer = _aura_time;
    dmg = (_aura_base + _fight_steps div _aura_ramp) * _enrage_mult;
    _peak_aura = max(_peak_aura, dmg);
    for(i = 0; i < ds_list_size(_enemylist); i += 1) {
        u = ds_list_find_value(_enemylist, i);
        if(!u.dead) unit_damage(u, c_lime, dmg, true);
    }
    with(instance_create(x, y, obj_pulse)) {
        image_blend = make_color_rgb(110, 200, 60);
        _range = 140;
    }
}

// Festering Blight: infect someone who isn't already diseased
_blight_timer -= 1;
if(_blight_timer <= 0 && ds_list_size(_enemylist) > 0) {
    _blight_timer = _blight_time;
    cands = 0;
    for(i = 0; i < ds_list_size(_enemylist); i += 1) {
        u = ds_list_find_value(_enemylist, i);
        if(u._blight_timer_on <= 0) cands += 1;
    }
    if(cands > 0) {
        pick = irandom(cands - 1);
        k = 0;
        for(i = 0; i < ds_list_size(_enemylist); i += 1) {
            u = ds_list_find_value(_enemylist, i);
            if(u._blight_timer_on > 0) continue;
            if(k == pick) {
                u._blight_timer_on = _blight_duration;
                create_text_effect(u.x, u.y, c_lime, "-festering blight-");
                break;
            }
            k += 1;
        }
    }
}

// Disease ticks, and bursts from the diseased dead
with(obj_unit) {
    if(_blight_timer_on > 0 && _faction != me._faction) {
        if(dead) {
            _blight_timer_on = 0;
            me._bursts += 1;
            create_text_effect(x, y, c_lime, "-blight bursts-");
            with(instance_create(x, y, obj_pulse)) {
                image_blend = make_color_rgb(110, 200, 60);
                _range = me._blight_burst_range;
            }
            with(obj_unit) {
                if(_faction != me._faction && !dead && id != other.id && unit_dist(id, other) < me._blight_burst_range) {
                    unit_damage(id, c_lime, me._blight_burst_damage * me._enrage_mult);
                    if(_blight_timer_on <= 0) _blight_timer_on = me._blight_duration;
                }
            }
        }
        else {
            _blight_timer_on -= 1;
            if(_blight_timer_on mod room_speed == 0) {
                unit_damage(id, c_lime, me._blight_tick * me._enrage_mult, true);
                create_evocation_effect(x, y, make_color_rgb(110, 200 + random(55), 60));
            }
        }
    }
}
