// caster_blizzard_channel();
// Called every step by a Caster that is channelling Blizzard. Damages enemies inside the storm
// every _blizzard_tick_time steps (sheep are left alone so we don't break our own crowd control)
// and stops when the channel runs out, the mage runs dry, or the storm only covers one enemy.
////////////////////////////////////////////////////////////////////////////////////////////
var stop, hits, lst, i, me;
me = id;
stop = false;
if(global.cutscene_active) stop = true;
if(point_distance(x, y, _blizzard_x, _blizzard_y) > range_cast) stop = true;
if(_attackcastwait >= _attackcasttime) stop = true;
if(_manatype_mana < _blizzard_manacost) stop = true;

_blizzard_tick -= 1;
if(!stop && _blizzard_tick <= 0) {
    _blizzard_tick = _blizzard_tick_time;
    lst = ds_list_create();
    with(obj_unit) {
        if(_faction != me._faction && !dead && !_polymorphed) {
            if(point_distance(x, y, me._blizzard_x, me._blizzard_y) < me._blizzard_radius) ds_list_add(lst, id);
        }
    }
    hits = 0;
    for(i = 0; i < ds_list_size(lst); i += 1) {
        if(ds_list_find_value(lst, i)._jobclass != class_mirrorimage) hits += 1;
        unit_damage(ds_list_find_value(lst, i), c_aqua, _blizzard_amount, true);
    }
    ds_list_destroy(lst);
    unit_mana(id, -_blizzard_manacost);
    if(hits < 2) stop = true;
}

if(stop) {
    _blizzard_casting = false;
    _casting = false;
    _attackcastwait = 0;
    _attackcasttime = _normal_attackcasttime;
    _blizzard_cooldown = _blizzard_cooldown_time;
    _target = -1;
}
