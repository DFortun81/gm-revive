/* Call default Unit Create Method */
event_inherited();

_maxhealth = 180;
_health = _maxhealth;

_manatype_maxmana = 360;
_manatype_mana = _manatype_maxmana;
_manatype = manatype_mana;

_normal_movespeed = 2;
_movespeed = _normal_movespeed; // This value changes

_canheal = true;
_attackrange = range_heal;
_attackdamage = 60;
_attackcasttime = 24;

// Healer Special Ability: Replenish
_replenishcooldown = room_speed * 5;

// Healer Special Ability: Flash Heal
_flashheal_casttime = room_speed * 0.25;
_flashheal_casting = false;
_flashheal_amount = 20;
_flashheal_manacost = 1;

// Healer Special Ability: Greater Heal
_greaterheal_casttime = room_speed * 0.75;
_greaterheal_casting = false;
_greaterheal_amount = 150;
_greaterheal_manacost = 4;

// Healer Special Ability: Power Word: Shield
// (No variables required)

// Healer Special Ability: Renew
_renew_manacost = 4;

// ---- Added by gm-revive overrides: damage spells for when nobody needs healing ----
// Healer Special Ability: Smite
_smite_casting = false;
_smite_target = -1;
_smite_casttime = room_speed;
_smite_amount = 18;
_smite_manacost = 3;
_smite_range = range_cast;

// Healer Special Ability: Shadow Word: Pain (one enemy at a time, 5 damage a second for 12 seconds)
_swp_target = -1;
_swp_timer = 0;
_swp_duration = room_speed * 12;
_swp_tick_amount = 5;
_swp_manacost = 4;

// Only attack while every ally in sight is missing less than this much health (with incoming damage)
_offense_threshold = 25;
// ...and drop a Smite to heal when an ally falls below this fraction of its health
_offense_panic = 0.7;
