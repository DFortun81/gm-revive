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
// While Zio or Count Vaelric is on the field both armies fight him together (a common enemy): the Horde
// joins the Alliance, and goes back to its own side when he's gone (gm-revive overrides; their totems
// switch in obj_battlefield's step)
if(_bossid == -1) {
    if(instance_exists(obj_boss_zio) || instance_exists(obj_boss_elmdor)) {
        if(_faction == "Horde") { _zio_faction = "Horde"; _faction = "Alliance"; _target = -1; }
    }
    else if(variable_local_exists("_zio_faction")) {
        if(_zio_faction != "") { _faction = _zio_faction; _zio_faction = ""; _target = -1; }
    }
}
// Zio's Black Wave curse hurts every second until the unit is healed to full (gm-revive overrides)
if(variable_local_exists("_zio_curse")) {
    if(_zio_curse > 0) {
        if(dead || _health >= _maxhealth) { _zio_curse = 0; if(!dead) create_text_effect(x, y, c_white, "-curse lifted-"); }
        else if(!global.toggle_pause && !global.cutscene_active) {
            if(!variable_local_exists("_zio_curse_tick")) _zio_curse_tick = 0;
            _zio_curse_tick += 1;
            if(_zio_curse_tick >= room_speed) {
                _zio_curse_tick = 0;
                if(instance_exists(obj_boss_zio)) { with(obj_boss_zio) unit_damage(other.id, c_purple, other._zio_curse); }
                else unit_damage(id, c_purple, _zio_curse);
            }
        }
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

// (gm-revive overrides) Count Vaelric's thralls crumble when their time's up or he's gone
if(variable_local_exists("_thrall_timer")) {
    if(_thrall_timer > 0 && !dead) {
        var ta; ta = false;
        with(obj_boss_elmdor) if(!dead) ta = true;
        _thrall_timer -= 1;
        if(_thrall_timer <= 0 || !ta) { _thrall_timer = 0; _health = 0; create_text_effect(x, y, c_white, "-crumbles to dust-"); }
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
