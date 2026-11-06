/* Call default Unit Create Method */
event_inherited();

_maxhealth = 250;
_health = _maxhealth;

_manatype_maxmana = 320;
_manatype_mana = _manatype_maxmana;
_manatype = manatype_mana;

_normal_movespeed = 1;
_movespeed = _normal_movespeed; // This value changes

// Default attack
_canheal = true;
_attackrange = range_melee;
_attackdamage = 2;
_normal_attackcasttime = 0;
_attackcasttime = _normal_attackcasttime;
_attackspeed = room_speed * 0.5;

// Shaman Special Ability: Lightning Bolt
_lightningbolt_casttime = room_speed * 1;
_lightningbolt_casting = false;
_lightningbolt_amount = 60; // (gm-revive overrides) was 70
_lightningbolt_manacost = 4;

// Shaman Special Ability: Chain Lightning
_chainlightning_casttime = room_speed * 1.4;
_chainlightning_casting = false;
_chainlightning_amount = 52; // (gm-revive overrides) was 70: hit every target in a group at full strength
_chainlightning_manacost = 12;
_chainlightning_cooldown = 0;
_chainlightning_cooldown_time = room_speed * 6; // 6 second CD

/////////////////////////////////////
// Shaman Special Spell Class: Shock
/////////////////////////////////////
_shock_cooldown = 0;
_shock_cooldown_time = room_speed * 6; // 6 Second GCD
_shock_manacost = 1;

// Shaman Special Ability: Earth Shock (Shock)
_shock_earth_amount = 10;

// Shaman Special Ability: Flame Shock (Shock)
_shock_flame_amount = 23;
_shock_flame_amount_dot = 36; // damage done over the course of 18 seconds
_shock_flame_dot_duration = room_speed * 18;

// Shaman Special Ability: Frost Shock (Shock)
_shock_frost_amount = 36;
/////////////////////////////////////

// Shaman Special Ability: Wind Sheer
_windshear_cooldown = 0;
_windshear_cooldown_time = room_speed * 8;

// Shaman Special Ability: Purge
_purge_cooldown = 0;
_purge_cooldown_time = room_speed * 0.25;


// Shaman Special Ability: Healing Wave
_healingwave_amount = 130; // (gm-revive overrides) was 160
_healingwave_manacost = 4;
_healingwave_casting = false;
_healingwave_casttime = room_speed * 0.8;

// Shaman Special Ability: Lesser Healing Wave
_lesserhealingwave_amount = 50; // (gm-revive overrides) was 60
_lesserhealingwave_manacost = 2;
_lesserhealingwave_casting = false;
_lesserhealingwave_casttime = room_speed * 0.45;

// Shaman Special Ability: Chain Heal
_chainheal_amount = 60; // (gm-revive overrides) was 80
_chainheal_manacost = 6;
_chainheal_casting = false;
_chainheal_casttime = room_speed;


/////////////////////////////////////
// Shaman Special Spell Class: Totem
// Totems are Area of Effect Buffs
/////////////////////////////////////
_totem_fire = -1;
_totem_earth = -1;
_totem_wind = -1;
_totem_water = -1;
_totem_manacost = 2;
_totem_duration = room_speed * (60 * 5);

// Individual (special) Totem Cooldowns
_totem_fire_magma_amount = 12;
_totem_fire_magma_duration = room_speed * 20;
_totem_fire_magma_cooldown = 0;
_totem_fire_magma_cooldown_time = room_speed * 20;

_totem_wind_shear_duration = room_speed * 5;
_totem_wind_shear_cooldown = 0;
_totem_wind_shear_cooldown_time = room_speed * 60;

_totem_water_manatide_duration = room_speed * 12;
_totem_water_manatide_cooldown = 0;
_totem_water_manatide_cooldown_time = room_speed * (60 * 3);
/////////////////////////////////////
