// paladin_release();
// Called by a Paladin when it dies or is removed: undoes everything it applied to other units
// (Devotion Aura, Hammer of Justice stun, Blessing of Protection) and to itself (Divine Shield).
////////////////////////////////////////////////////////////////////////////////////////////
var i, u;

for(i = 0; i < ds_list_size(_aura_list); i += 1) {
    u = ds_list_find_value(_aura_list, i);
    if(instance_exists(u)) {
        u._devotion_sources -= 1;
        if(u._devotion_sources <= 0) {
            u._devotion_sources = 0;
            u._damagereduction -= _aura_reduction;
        }
    }
}
ds_list_clear(_aura_list);

if(_hoj_timer > 0) {
    if(instance_exists(_hoj_target)) _hoj_target._stunned = false;
    _hoj_timer = 0;
    _hoj_target = -1;
}

if(_bop_timer > 0) {
    if(instance_exists(_bop_target)) {
        _bop_target._damagereduction -= 1;
        if(!_bop_target.dead) _bop_target._blendcolor = c_white;
    }
    _bop_timer = 0;
    _bop_target = -1;
}

if(_divineshield_timer > 0) {
    _damagereduction -= 1;
    _divineshield_timer = 0;
}
