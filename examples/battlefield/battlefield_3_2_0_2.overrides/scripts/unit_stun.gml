// unit_stun(id, steps);
// Stuns a unit for at least the given number of steps (not bosses or other stun-immune units).
// obj_unit's begin step counts _stun_timer down and lets the unit go, unless a Paladin's Hammer
// of Justice is still holding it. Returns true if the stun landed.
////////////////////////////////////////////////////////////////////////////////////////////
var u;
u = argument0;
if(!units_exists(u)) return false;
if(u.dead || u._stunimmune) return false;
u._stunned = true;
u._stun_timer = max(u._stun_timer, argument1);
u._attackcastwait = 0;
return true;
