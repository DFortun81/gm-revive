if(global.toggle_pause || global.cutscene_ending) exit;

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
        sprite_index = faction_get_unit_sprite(_faction, _jobclass);
    }
    else exit;
}

// Who is near me?
//_enemies_insight = enemies_inrange(_faction, _sightdistance);
//_enemies_inrange = enemies_inrange(_faction, _attackrange);
//_allies_insight = allies_inrange(_faction, _sightdistance);
//_allies_inrange = allies_inrange(_faction, _attackrange);
