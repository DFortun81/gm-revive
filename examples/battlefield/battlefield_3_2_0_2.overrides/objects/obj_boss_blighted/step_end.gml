var i, j, u, w, n, pick, k, dmg, me, cands, best, bn;
event_inherited();
if(dead || global.toggle_pause || !_fight_started) exit;
me = id;

// Blight Aura
_aura_timer -= 1;
if(_aura_timer <= 0) {
    _aura_timer = _aura_time;
    dmg = (_aura_base + _fight_steps div _aura_ramp) * _enrage_mult;
    _peak_aura = max(_peak_aura, dmg);
    for(i = 0; i < ds_list_size(_arealist); i += 1) {
        u = ds_list_find_value(_arealist, i);
        if(!u.dead) unit_damage(u, c_lime, dmg, true);
    }
    blighted_aura_fx();
}

// (gm-revive overrides) Miasma: a cloud of rot on the thickest knot of the raid
_miasma_timer -= 1;
if(_miasma_timer <= 0) {
    _miasma_timer = _miasma_time;
    best = -1; bn = -1;
    for(i = 0; i < ds_list_size(_enemylist); i += 1) {
        u = ds_list_find_value(_enemylist, i);
        if(u.dead) continue;
        n = 0;
        for(j = 0; j < ds_list_size(_enemylist); j += 1) {
            w = ds_list_find_value(_enemylist, j);
            if(!w.dead && point_distance(u.x, u.y, w.x, w.y) < _miasma_radius) n += 1;
        }
        if(n > bn) { bn = n; best = u; }
    }
    if(best != -1) {
        with(instance_create(best.x, best.y, obj_blight_cloud)) { _master = me; _r = me._miasma_radius; _tick = me._miasma_tick * me._enrage_mult; }
        create_text_effect(x, y, c_lime, "-miasma-");
        _clouds += 1;
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
                blighted_infect_fx(u);
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
            blighted_burst_fx(me._blight_burst_range);
            with(obj_unit) {
                if(_faction != me._faction && !dead && id != other.id && unit_dist(id, other) < me._blight_burst_range) {
                    unit_damage(id, c_lime, me._blight_burst_damage * me._enrage_mult);
                    if(_blight_timer_on <= 0) { _blight_timer_on = me._blight_duration; blighted_infect_fx(id); }
                }
            }
        }
        else {
            _blight_timer_on -= 1;
            if(_blight_timer_on mod room_speed == 0) {
                unit_damage(id, c_lime, me._blight_tick * me._enrage_mult, true);
                // a sore weeps: a drip of pus and a puff of rot
                with(fx_make(0, x + random_range(-6, 6), y, random_range(8, sprite_height * 0.8), make_color_rgb(150, 170, 40), 0.14, 22)) { _add = false; _vh = -0.4; _grow = 0.7; }
            }
        }
    }
}
