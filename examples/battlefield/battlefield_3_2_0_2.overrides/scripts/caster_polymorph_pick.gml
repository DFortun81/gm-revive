// caster_polymorph_pick();
// Called by a Caster: returns the enemy most worth turning into a sheep right now, or -1.
// Worth it means: the melee unit beating on me, an enemy healer, or a caster that nobody on my
// side is already hitting (any damage breaks Polymorph, so sheeping a unit we are attacking is wasted).
// Never sheeps the last enemy standing: that only delays the fight. Polymorph reaches a little
// further than Fireball (_polymorph_range) so it can catch healers standing back at healing range.
////////////////////////////////////////////////////////////////////////////////////////////
var i, size, u, n, best, bestscore, sc, taken, hitters, dist;

if(_polymorph_cooldown > 0 || _manatype_mana < _polymorph_manacost || _silenced > 0) return -1;
// One sheep at a time
if(units_exists(_polymorph_victim)) {
    if(_polymorph_victim._polymorphed) return -1;
}

size = ds_list_size(_enemylist);
n = 0;
for(i = 0; i < size; i += 1) {
    u = ds_list_find_value(_enemylist, i);
    if(!u.dead && !u._polymorphed && u._jobclass != class_mirrorimage) n += 1;
}
if(n < 2) return -1;

best = -1;
bestscore = 0;
for(i = 0; i < size; i += 1) {
    u = ds_list_find_value(_enemylist, i);
    if(u.dead || u._polymorphed || u._stunned || u._stealthed) continue;
    if(u._jobclass == class_mirrorimage || u._bossid != -1) continue;
    dist = point_distance(x, y, u.x, u.y);
    if(dist >= _polymorph_range) continue;
    // The one we are about to kill is only worth a sheep if it is the melee unit on top of me
    if(u == _target && !(u._target == id && dist <= range_melee * 2)) continue;

    // Is another Caster on my side already sheeping it?
    taken = false;
    with(obj_unit_caster) {
        if(id != other.id && _faction == other._faction && _polymorph_casting && _target == u) taken = true;
    }
    if(taken) continue;

    sc = 0;
    if(u._target == id) {
        if(dist <= range_melee * 2) sc += 30; // peel the unit that is hitting me
        else sc += 10;
    }
    if(u._jobclass == class_healer) sc += 20;
    else if(u._jobclass == class_shaman || u._jobclass == class_paladin || u._jobclass == class_caster) sc += 10;
    if(u._attackcastwait > 0) sc += 5;

    // Allies hitting it would break the sheep straight away
    hitters = 0;
    with(obj_unit) {
        if(_faction == other._faction && !dead && _target == u) hitters += 1;
    }
    sc -= hitters * 5;

    if(sc > bestscore) {
        bestscore = sc;
        best = u;
    }
}
return best;
