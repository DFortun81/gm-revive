// (gm-revive overrides) the game's own code, with distances between units measured edge to edge
// (unit_dist: bosses have a hit box, so melee can stand at their edge instead of on top of them)
// units_inrange(faction, jobclass, range);
///////////////////////////////////////////
var count;
count = 0;
with(job_get_object(argument1)) {
    if(_faction == argument0) {
        if(unit_dist(id, other) < argument2) count += 1;
    }
}
return count;