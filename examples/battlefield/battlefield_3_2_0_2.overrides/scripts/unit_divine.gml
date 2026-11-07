// unit_divine(id);
// True while a Paladin is inside Divine Shield (gm-revive overrides). The shield makes it immune to damage
// (through _damagereduction) and, as in WoW, to every harmful effect: Polymorph, stuns and fears (unit_stun),
// the Marquis's vampire bite and Stitchgut's Gut Hook.
////////////////////////////////////////////////////////////////////////////////////////////
var r;
r = false;
with(argument0) if(variable_local_exists("_divineshield_timer")) r = (_divineshield_timer > 0);
return r;
