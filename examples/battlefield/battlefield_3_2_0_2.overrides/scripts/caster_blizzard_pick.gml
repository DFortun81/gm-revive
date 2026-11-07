// caster_blizzard_pick();
// Called by a Caster: returns the enemy in casting range whose position would catch the most
// enemies in a Blizzard, as long as that is at least _blizzard_min_targets. Otherwise -1.
////////////////////////////////////////////////////////////////////////////////////////////
var i, size, u, n, best, bestn;
if(_blizzard_cooldown > 0 || _manatype_mana < _blizzard_manacost * 20 || _silenced > 0) return -1;
best = -1;
bestn = _blizzard_min_targets - 1;
size = ds_list_size(_enemylist);
for(i = 0; i < size; i += 1) {
    u = ds_list_find_value(_enemylist, i);
    if(u.dead || u._polymorphed || u._jobclass == class_mirrorimage) continue;
    if(unit_dist(id, u) >= range_cast) continue;
    n = caster_blizzard_count(u.x, u.y);
    if(n > bestn) {
        bestn = n;
        best = u;
    }
}
return best;
