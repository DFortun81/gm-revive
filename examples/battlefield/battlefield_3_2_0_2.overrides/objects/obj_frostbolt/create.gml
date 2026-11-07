// A frostbolt from the Lichcaller's Frostbolt Volley (gm-revive overrides; a new object). Homes in on
// _master and deals _damage when it arrives, with a burst of ice. Drawn from spr_fx_misc.
_master = -1;
_damage = 0;
_x = x; _y = y;
_h = 30;           // height above the ground: starts at the Lichcaller's hands, ends at the target's chest
_height = 16;
_speed = 5;
_shadow = false;   // a Shadow Bolt (purple, from the Lichcaller's Shadow Bolt and Shadow Volley)
_quiet = false;
_web = 0;          // a strand of the Broodmother's web: wraps the unit for _web steps instead    // no damage number (Shadow Volley hits everyone)
image_speed = 0;
