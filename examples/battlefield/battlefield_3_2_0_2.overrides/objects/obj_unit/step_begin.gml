if(global.toggle_pause || global.cutscene_ending) exit;

// (gm-revive overrides) Stuns from unit_stun (Cheap Shot, Kidney Shot) and Kick's spell lockout
if(_stun_timer > 0) {
    _stun_timer -= 1;
    if(_stun_timer <= 0) {
        var held;
        held = false;
        with(obj_unit_paladin) if(_hoj_timer > 0 && _hoj_target == other.id) held = true;
        if(!held) _stunned = false;
    }
}
// Zio's Magic Barrier glows round him while it holds (gm-revive overrides; the glow strips are the
// ones drawn for the later version of the game)
if(object_index == obj_boss_zio) {
    if(!variable_local_exists("_fx_barrier")) {
        _fx_barrier = instance_create(x, y, obj_fx_aura);
        _fx_barrier._master = id;
        _fx_barrier._kind = 7;
    }
}
// Stars over anyone stunned, however they were stunned (gm-revive overrides)
if(!variable_local_exists("_fx_stun")) _fx_stun = -1;
if(_stunned && !dead && !instance_exists(_fx_stun)) {
    _fx_stun = instance_create(x, y, obj_fx_aura);
    _fx_stun._master = id;
    _fx_stun._kind = 0;
}
// Marquis Elmdor's Vampire wears off after a while, or once the vampire is beaten down to a quarter of
// its health (the stand-in for being knocked out and raised), or if the Marquis is gone
if(variable_local_exists("_vamp_timer")) {
    if(_vamp_timer > 0) {
        _vamp_timer -= 1;
        if(_vamp_timer <= 0) { _vamp_timer = 1; marquis_unvamp(id); }
        else if(dead || _health < _maxhealth * 0.25 || !instance_exists(_vamp_boss)) marquis_unvamp(id);
        else if(_vamp_boss.dead) marquis_unvamp(id);
    }
}
if(_silenced > 0) {
    _silenced -= 1;
    _attackcastwait = 0;
}

_message = "";
_attackcooldown -= 1; // Decrement the restricter
if(global.cutscene_active) _message = _cutscenemessage;

_taunted_duration -= 1;
_replenished_cooldown -= 1;
if(_replenished_cooldown <= 0) _replenished = false;

_weakenedsoul -= 1;
_renewtimer -= 1;
_regrowth_timer -= 1;
_nourish_tick_timer -= 1;
_innervating_timer -= 1;
_manaspring_tick_timer -= 1;
if(_renewtimer >= 0) {
    if(_renewtimer mod room_speed == 0) {
        // Give a tick of Renew to them (1% max health)
        // (gm-revive overrides) tell the damage meter which class cast the heal-over-time
        global._recount_hot_job = class_healer + 1;
        if(_maxhealth > _health) unit_heal(id, max(_maxhealth * 0.01, 2));
        global._recount_hot_job = 0;
    }
}
if(_regrowth_timer >= 0) {
    if(_regrowth_timer mod room_speed == 0) {
        // Give a tick of Regrowth to them (150 / 8)
        global._recount_hot_job = class_druid + 1;
        if(_maxhealth > _health) unit_heal(id, _regrowth_timer_amount / _regrowth_timer_seconds);
        global._recount_hot_job = 0;
    }
}
if(_nourish_tick_timer >= 0) {
    if(_nourish_tick_timer mod room_speed == 0) {
        // Give a tick of Nourish to them (40 / 6)
        global._recount_hot_job = class_druid + 1;
        if(_maxhealth > _health) unit_heal(id, _nourish_tick_amount / _nourish_tick_seconds);
        global._recount_hot_job = 0;
    }
}

if(_manatype == manatype_mana) {
    if(_innervating_timer >= 0) {
        if(_innervating_timer mod room_speed == 0) {
            // Give a tick of Innervate to them
            unit_mana(id, _innervating_amount / _innervating_seconds);
        }
    }
    
    if(_manaspring_tick_timer >= 0) {
        unit_mana(id, (_manatype_maxmana * 0.01) / (room_speed * 5));
    }
}

// Am I dead? We only want to do this stuff once
if(_health <= 0 && !dead) {
    dead = true;
    sound_play(snd_dead);
    }

// Fade out
if(dead) {
    _blendcolor = c_red;
    image_alpha -= .1;
    if(image_alpha <= 0.05) instance_destroy();
    exit;
}

// Is this unit CC'd?
if(_polymorphed) {
    sprite_index = spr_hide;
    image_index = _dir * 4;
    
    _polymorphed_timer -= 1;
    if(_polymorphed_timer <= 0 || _health < _polymorphed_health) {
        _polymorphed = false;
        _polymorphed_timer = 0;
        // Put back whatever sprite it had before the sheep. Looking it up by class only knows the
        // playable classes, so a polymorphed broodling used to come back wearing Zio's sprite.
        sprite_index = _polymorphed_sprite;
    }
    else exit;
}

// Who is near me?
//_enemies_insight = enemies_inrange(_faction, _sightdistance);
//_enemies_inrange = enemies_inrange(_faction, _attackrange);
//_allies_insight = allies_inrange(_faction, _sightdistance);
//_allies_inrange = allies_inrange(_faction, _attackrange);
