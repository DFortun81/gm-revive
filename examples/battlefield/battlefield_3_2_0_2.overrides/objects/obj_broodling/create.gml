// Broodling: hatched by the Broodmother (gm-revive overrides; a new object, child of obj_unit, so every
// class's AI treats it as an enemy unit). Weak, fast, and it goes for healers and casters.
event_inherited();
_jobclass = -1;
_bossid = -1;
_maxhealth = 110;
_health = _maxhealth;
_manatype = -1;
_normal_movespeed = 1.6;
_movespeed = _normal_movespeed;
_animate = true;
_blendcolor = c_white;
_attackdamage = 14;
_attackspeed = room_speed;
_attackcooldown = room_speed div 2;
_attackrange = range_melee;
_mother = -1;
_target = -1;
