// unit_interrupt(id, lockout_steps);
// Cancels whatever the unit is casting and locks it out of cast-time spells for a while.
// The lockout is enforced in obj_unit's begin step by holding _attackcastwait at 0, which works for
// every class because they all finish a cast when _attackcastwait reaches _attackcasttime.
////////////////////////////////////////////////////////////////////////////////////////////
var u;
u = argument0;
if(!units_exists(u)) exit;
with(u) {
    if(_jobclass == class_caster) {
        if(_evocation_casting) _evocation_cooldown = _evocation_cooldown_time;
        if(_blizzard_casting) _blizzard_cooldown = _blizzard_cooldown_time;
    }
    if(_raid_casting) _raid_cast_interrupted = true; // a raid boss cancels its own cast
    _casting = false;
    _attackcastwait = 0;
    _attackcasttime = _normal_attackcasttime;
    _flashheal_casting = false;
    _greaterheal_casting = false;
    _smite_casting = false;
    _polymorph_casting = false;
    _blizzard_casting = false;
    _evocation_casting = false;
    _lightningbolt_casting = false;
    _chainlightning_casting = false;
    _healingwave_casting = false;
    _lesserhealingwave_casting = false;
    _chainheal_casting = false;
    _heal_casting = false;
    _nourish_casting = false;
    _silenced = max(_silenced, argument1);
    create_text_effect(x, y, c_orange, "-interrupted-");
}
