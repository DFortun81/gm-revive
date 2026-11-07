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
// ...and only while it has mana to spare (Smite and Shadow Word: Pain are for spare mana)
_offense_min_mana = 0.6;

// Healer Special Ability: Prayer of Healing (gm-revive overrides)
// Heals every ally within _poh_radius for _poh_amount; cast when 3 or more of them are 20+ down
_poh_casting = false;
_poh_casttime = room_speed * 1.5;
_poh_amount = 70;
_poh_manacost = 6;
_poh_radius = 160;
_poh_min_targets = 3;
_poh_min_missing = 20;

// (gm-revive overrides) Wand: see unit_fallback
_wand_cooldown = 0;
_wand_cooldown_time = room_speed * 1.5;
// (gm-revive overrides) Psychic Scream: when melee enemies are on the Healer, it screams and everything
// within reach is frozen in terror for 4 s (any stun-immune or Divine Shielded unit shrugs it off)
_scream_cooldown = 0;
_scream_cooldown_time = room_speed * 30;
_scream_range = 70;
_scream_duration = room_speed * 4;
