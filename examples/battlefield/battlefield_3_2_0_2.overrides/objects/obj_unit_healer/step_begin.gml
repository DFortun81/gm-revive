// (gm-revive overrides) the game's own code, with distances between units measured edge to edge
// (unit_dist: bosses have a hit box, so melee can stand at their edge instead of on top of them)
if(global.toggle_pause) exit;

_replenishcooldown -= 1;

// The Healer class also grants Replenishment - Which awards all mana users with 1% mana regen every 5 seconds (effect stacks with multiple healers)
if(_replenishcooldown <= 0) {
    _replenishcooldown = room_speed * 5;
    with(obj_unit) {
        if(_faction == other._faction && _manatype == manatype_mana && !_replenished) {
            if(unit_dist(id, other) < other._attackrange) {
                _manatype_mana = min(_manatype_maxmana, _manatype_mana + _manatype_maxmana * 0.01);
                create_text_effect(x, y, c_blue, string(_manatype_maxmana * 0.01));
                _replenished = true;
                _replenished_cooldown = other._replenishcooldown;
            }
        }
    }
}

event_inherited();