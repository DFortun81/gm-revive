// healer_prayer();
// Called every step by a Healer. Prayer of Healing heals every ally within _poh_radius of the Healer
// for _poh_amount: worth it when at least _poh_min_targets of them have lost _poh_min_missing health
// or more (raid-wide damage, a pack of broodlings). Checked only between other casts; while it's
// being cast the Healer stands still. Returns true while the Healer is busy with it.
////////////////////////////////////////////////////////////////////////////////////////////
var me, n;
me = id;
if(_poh_casting) {
    _destx = x;
    _desty = y;
    _attackcastwait += 1;
    if(_attackcastwait >= _attackcasttime) {
        with(obj_unit) {
            if(_faction == me._faction && !dead && _jobclass != class_mirrorimage && unit_dist(id, me) < me._poh_radius) {
                if(_health < _maxhealth) with(me) { unit_heal(other.id, _poh_amount); fx_spell(other.id, "prayer of healing"); }
            }
        }
        with(instance_create(x, y, obj_pulse)) {
            image_blend = make_color_rgb(255, 250, 200);
            _range = me._poh_radius;
        }
        unit_mana(id, -_poh_manacost);
        _poh_casting = false;
        _attackcastwait = 0;
        _attackcasttime = _normal_attackcasttime;
        _message = "";
    }
    return true;
}
if((_attackcastwait > 0 && !_smite_casting) || _manatype_mana < _poh_manacost) return false;
n = 0;
with(obj_unit) {
    if(_faction == me._faction && !dead && _jobclass != class_mirrorimage && unit_dist(id, me) < me._poh_radius) {
        if(_maxhealth - _health >= me._poh_min_missing) n += 1;
    }
}
if(n < _poh_min_targets) return false;
_smite_casting = false; // healing comes first
_poh_casting = true;
_attackcastwait = 1;
_attackcasttime = _poh_casttime;
_destx = x;
_desty = y;
_message = "Prayer of Healing!";
return true;
