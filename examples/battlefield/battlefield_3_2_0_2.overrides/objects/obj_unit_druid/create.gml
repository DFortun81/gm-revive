/* Call default Unit Create Method */
event_inherited();

_healerlist = ds_list_create();
_maxhealth = 160;
_health = _maxhealth;
_canheal = true;

_normal_movespeed = 2;
_movespeed = _normal_movespeed; // This value changes
_damagereduction = -0.05;

// Druid Special Ability: Shapeshift
// The druid transforms into an animal in order to better match
// the situation at hand.
_shapeshift_cooldown = 0;
_shapeshift_cooldown_time = room_speed * 0.5;
_shapeshift_maxhealth_bear = 420;
_shapeshift_maxhealth_kitty = 190;
_shapeshift_maxhealth_normal = _maxhealth;
_shapeshift_speed_bear = 1;
_shapeshift_speed_kitty = 3;
_shapeshift_speed_normal = 2;
_shapeshift_damagereduction_bear = 0.20;
_shapeshift_damagereduction_kitty = 0;
_shapeshift_damagereduction_normal = -0.05;
_shapeshift_form = druid_form_normal; // druid_form_normal: Healer, druid_form_kitty: DPS, druid_form_bear: Tank

// Druid Special Ability: Uses -All- Mana Types
_manatype_maxmana = 450;
_manatype_mana = _manatype_maxmana;
_manatype_rage = 0;
_manatype_energy = 100;
_manatype = manatype_mana;

//////////////////////////////////
// Druid Bear Form Abilities
//////////////////////////////////
// Druid Special Ability: Ironskin
// Reduces all damage by 40% for 6 seconds
_ironskin_cooldown = 0;
_ironskin_cooldown_time = room_speed * 120; // Roughly 2 minute CD
_ironskin_duration = 0;
_ironskin_duration_time = room_speed * 6; // Roughly 6 seconds
_ironskin_damagereduction = 0.40; // 40% additional damage reduction
_ironskin_active = false;

// Druid Special Ability: Survival Instincts
// Increases maximum health by 30% for 6 seconds.
_survivalinstincts_cooldown = 0;
_survivalinstincts_cooldown_time = room_speed * 120; // Roughly 2 minute CD
_survivalinstincts_duration = 0;
_survivalinstincts_duration_time = room_speed * 6; // Roughly 6 seconds
_survivalinstincts_addition = 0.30; // Roughly 30% additional health
_survivalinstincts_active = false;

// Druid Special Ability: Swipe (Kitty or Bear only)
// Deals 30 damage as well as cleave the nearest two targets to the druid's target for 15.
_swipe_cooldown = 0;
_swipe_cooldown_time = room_speed * 3;
_swipe_manacost = 15;
_swipe_amount = 30;
_swipe_cleave_percent = 0.50; // 50% damage to cleave targets
_swipe_cleave_count = 2; // 2 Additional Targets



//////////////////////////////////
// Druid Normal Form Abilities
//////////////////////////////////
// Druid Special Ability: Nourish
// Heals the druid's target for 80 damage and places an additional 40 healing over time on the targe for 6 seconds.
// Recasting this ability will refresh the duration of the Heal Over Time effect
_nourish_casting = false;
_nourish_casttime = room_speed * 0.8;
_nourish_amount = 80;
_nourish_healovertime = 40;
_nourish_healovertime_time = 6;
_nourish_manacost = 1;

// Druid Special Ability: Regrowth
// Heals the druid's target for 150 damage over 8 seconds.
_regrowth_cooldown = 0;
_regrowth_cooldown_time = 1;
_regrowth_healovertime = 150;
_regrowth_healovertime_time = 8;
_regrowth_manacost = 1;

// Druid Special Ability: Innervate
// Restores mana equal to the Druid's maximum mana to a friendly target over 12 seconds.
_innervate_cooldown = 0;
_innervate_cooldown_time = room_speed * 120; // 1 Minute CD


//////////////////////////////////
// Druid Cat Form Abilities (added via overrides)
//////////////////////////////////
// Cat form attacks fast and spends Energy (regained like a Rogue's)
_kitty_attackdamage = 16; // was 12 (Nov 2026 buff)
_kitty_attackspeed = room_speed * 1;
_kitty_energy_rate = 0.5; // 30 energy regained per second

// Druid Special Ability: Rake (Cat)
// A bleed: 10 damage now and 6 every second for 9 seconds. Only one Rake is kept up at a time.
_rake_cost = 35;
_rake_damage = 10;
_rake_tick_damage = 8; // was 6
_rake_duration = room_speed * 9;
_rake_timer = 0;
_rake_target = -1;

// Druid Special Ability: Shred (Cat)
// A big claw attack for 2.25x normal damage.
_shred_cost = 40;
_shred_multiplier = 2.5; // was 2.25

// Druid Special Ability: Ferocious Bite (Cat)
// Finisher on a target under 25% health: spends all remaining Energy for extra damage.
_bite_cooldown = 0;
_bite_cooldown_time = room_speed * 6;
_bite_threshold = 0.25;
_bite_damage = 25;

//////////////////////////////////
// Druid Bear Form Abilities (added via overrides)
//////////////////////////////////
_bear_attackdamage = 11;
_bear_attackspeed = room_speed * 1.5;
_bear_rage_per_hit = 4;
_ironskin_threshold = 0.40;        // Ironskin when below 40% health
_survivalinstincts_threshold = 0.25; // Survival Instincts when below 25% health
_survivalinstincts_health = 0;

// Druid Special Ability: Growl (Bear)
// Taunts an enemy that is attacking one of our Healers or Casters.
_growl_cooldown = 0;
_growl_cooldown_time = room_speed * 8;

// Shapeshift less often than before (was every half second) so the Druid commits to a form
_shapeshift_cooldown_time = room_speed * 3;
