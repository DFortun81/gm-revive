// (gm-revive overrides: the game's own unit_damage, plus hooks for Zio's Magic Barrier and Marquis Elmdor below)
// unit_damage(id, color, damage, disallow_text);
///////////////////////////////////////////////////
var dmg, v, vb;
v = argument2 * 0.25; // Variant
dmg = argument2 + round(random(v) - (v / 2));
if(instance_exists(argument0)) {
    // (gm-revive overrides) Zio's Magic Barrier: holy power (Paladins, Healers) breaks it four times as
    // fast (4x); anything else only scratches it, at 15% strength. Like the Psycho Wand in Phantasy Star IV.
    if(argument0.object_index == obj_boss_zio) {
        if(argument0._absorbamount > 0) dmg *= zio_barrier_factor(argument0, id);
    }
    // (gm-revive overrides) Marquis Elmdor's Shirahadori catches melee blows
    if(argument0.object_index == obj_boss_marquis) {
        if(marquis_shirahadori(argument0, id, dmg)) return 0;
    }
    // (gm-revive overrides) A vampire hits its old friends at half strength (it's half out of its mind),
    // and its melee hits can turn its victim too
    if(variable_local_exists("_vamp_timer")) {
        if(_vamp_timer > 0 && instance_exists(_vamp_boss)) {
            dmg *= 0.5;
            vb = _vamp_boss;
            if(point_distance(x, y, argument0.x, argument0.y) <= range_melee * 1.6 && random(1) < vb._vamp_spread) marquis_vampirize(argument0, vb);
        }
    }
    dmg = max(0, dmg - (dmg * argument0._damagereduction));
    
    // Rage Generation - 5% of the damage they take becomes rage
    if(argument0._manatype == manatype_rage) {
        unit_mana(argument0, round(dmg * 0.05));
    }
    
    // Stealthed Classes get their stealth broken by damage
    if(argument0._stealthed) {
        if(argument0._jobclass = class_rogue) {
            // Verify that Vanish is not active
            if(argument0._vanish_active) return 0;
            else argument0._stealthed = false;
        }
        else argument0._stealthed = false;
    }
        
    // Is the user bubbled for less than the amount of damage?
    if(dmg > argument0._absorbamount) {
        dmg -= argument0._absorbamount;
        argument0._absorbamount = 0;
        argument0._absorbmax = 0;
        
        argument0._health = max(0, argument0._health - dmg);
        if(argument0._health <= 0 && argument0._bossid == -1) argument0.dead = true;
        recount_damage(id, argument0, dmg);
        if(!argument3) create_text_effect(argument0.x, argument0.y, argument1, string(round(dmg))); // (gm-revive overrides) shown rounded: "126", not "126.00"
    }
    else {
        argument0._absorbamount -= dmg;
    }
}