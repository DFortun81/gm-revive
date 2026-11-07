// zio_curse(unit, damage_per_second);
// Black Wave's curse (from the Call to Arms version of the fight): the unit takes this much every second
// until it's healed to full (obj_unit's begin step runs it). A dark haze shows who has it.
// (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var u;
u = argument0;
if(!units_exists(u)) exit;
if(u.dead) exit;
with(u) {
    if(!variable_local_exists("_zio_curse")) _zio_curse = 0;
    if(_zio_curse <= 0) {
        with(instance_create(x, y, obj_fx_aura)) { _master = other.id; _kind = 8; }
        create_text_effect(x, y, c_purple, "-cursed-"); boss_sfx(snd_bfx_cursed);
    }
    _zio_curse = max(_zio_curse, argument1);
}
