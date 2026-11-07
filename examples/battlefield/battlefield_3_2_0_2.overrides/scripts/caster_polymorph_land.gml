// caster_polymorph_land();
// Called by a Caster when its Polymorph cast finishes: turns _target into a sheep for
// _polymorph_duration steps. Any damage breaks it (handled by obj_unit's begin step).
////////////////////////////////////////////////////////////////////////////////////////////
var u;
u = _target;
if(units_exists(u)) {
    // (gm-revive overrides) a Paladin that bubbled during the cast is immune: the spell is wasted
    if(unit_divine(u)) create_text_effect(u.x, u.y, c_yellow, "-immune-");
    else if(!u.dead && !u._polymorphed && !u._stunned) {
        u._polymorphed_sprite = u.sprite_index; // restored when it ends (broodlings etc. have no class sprite)
        u._polymorphed = true;
        u._polymorphed_timer = _polymorph_duration;
        u._polymorphed_health = u._health;
        u._casting = false;
        u._attackcastwait = 0;
        with(instance_create(u.x, u.y, obj_polymorph)) _master = u;
        create_text_effect(u.x, u.y, c_fuchsia, "-polymorph-");
        _polymorph_victim = u;
        unit_mana(id, -_polymorph_manacost);
    }
}
_polymorph_cooldown = _polymorph_cooldown_time;
_polymorph_casting = false;
_casting = false;
_attackcastwait = 0;
_attackcasttime = _normal_attackcasttime;
_target = -1;
