// (gm-revive overrides) the game's own code, with distances between units measured edge to edge
// (unit_dist: bosses have a hit box, so melee can stand at their edge instead of on top of them)
// calculate_incoming_effects(target, master);
//////////////////////////////////////////////
// Results are returned through these two variables:
global.calc_healing = 0;
global.calc_damage = 0;
//////////////////////////////////////////////
if(!instance_exists(argument0)) return 0;

// Calculate Unit-Contributed Damage and Healing
with(obj_unit) {
    if(id == argument0) {
        if(_renewtimer >= 0) global.calc_healing += max(_maxhealth * 0.01, 2);
        continue;
    }
    
    if(_target == argument0) {
        if(_faction == argument0._faction) {
            if(_jobclass == class_healer) {
                // Specific Healer only heals
                if(_flashheal_casting) global.calc_healing += _flashheal_amount;
                else if(_greaterheal_casting) global.calc_healing += _greaterheal_amount;
            }
        }
        else {
            // Enemies
            // Damage calculation
            if(_jobclass == class_warrior) {
                if(_mana >= 20) global.calc_damage += 20;
                global.calc_damage += _attackdamage;
            }
            else if(_jobclass == class_caster) {
                if(_attackcastwait > 0 && !_polymorph_casting && !_evocation_casting) global.calc_damage += _attackdamage;
            }
            else if(_jobclass == class_mirrorimage) {
                if(_attackcastwait > 0) global.calc_damage += _attackdamage;
            }
            else if(_jobclass == class_shaman) {
                if(_attackcastwait > 0) {
                    if(_lightningbolt_casting) global.calc_damage += _lightningbolt_amount;
                    else if(_chainlightning_casting) global.calc_damage += _chainlightning_amount;
                }
                else {
                    if(_shock_cooldown <= 2) global.calc_damage += _shock_frost_amount;
                    global.calc_damage += _attackdamage;
                }
            }
        }
    }
}

// Blizzard doesn't effect CC'd targets
if(argument0._polymorphed) return 0;
with(obj_blizzard) {
    dist = unit_dist(id, argument0);
    if(dist < (range_cast / 2)) global.calc_damage += 8;
}