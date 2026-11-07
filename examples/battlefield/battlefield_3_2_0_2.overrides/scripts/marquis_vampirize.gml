// marquis_vampirize(unit, marquis);
// Marquis Elmdor's Vampire: the unit turns against its side and fights for him until _vamp_timer runs
// out, it is beaten down to a quarter of its health, or he dies (see marquis_unvamp; the timer runs in
// obj_unit's begin step). At most _vamp_max at once; never his tank, and never a unit that heals
// (vampires attack, they don't heal). Returns true if it took. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var u, b, n;
u = argument0; b = argument1;
if(!units_exists(u) || !instance_exists(b)) return false;
if(u.dead || u._canheal || u._jobclass < 0 || u._jobclass == class_mirrorimage || u._bossid != -1 || u._faction == b._faction) return false;
if(u == b._target) return false; // never his tank
if(unit_divine(u)) return false; // (gm-revive overrides) immune inside Divine Shield
with(u) if(!variable_local_exists("_vamp_timer")) _vamp_timer = 0;
if(u._vamp_timer > 0) return false;
n = 0;
with(obj_unit) if(variable_local_exists("_vamp_timer")) { if(_vamp_timer > 0 && !dead) n += 1; }
if(n >= b._vamp_max) return false;
with(u) {
    _vamp_faction = _faction;
    _faction = b._faction;
    _vamp_timer = b._vamp_duration;
    _vamp_boss = b;
    _blendcolor = make_color_rgb(255, 120, 120);
    _target = -1;
    _casting = false;
    _attackcastwait = 0;
    _raid_threat = 0;
    _message = "...the blood... it calls...";
    create_text_effect(x, y, c_red, "-vampire-");
}
with(instance_create(u.x, u.y, obj_fx_aura)) { _master = u; _kind = 6; }
b._vamps += 1;
return true;
