/* Call default Unit Create Method */
event_inherited();

_maxhealth = 250;
_health = _maxhealth;

// Rogues have a maximum of 100% Energy and start full. Energy is regained at a variable rate per second.
_manatype_energy = 100;
_manatype = manatype_energy;
_attackrange = range_melee;
_stealthed = true;

// Energy
_normal_energy_rate = 0.50; // 30 regained per second
_energy_rate = _normal_energy_rate;

// Movespeed
_normal_movespeed = 2;
_movespeed = _normal_movespeed; // This value changes

// Main-hand
_mainhand_damage = 6;
_mainhand_normal_attackspeed = 32;
_mainhand_cooldown = 0;
_mainhand_attackspeed = _mainhand_normal_attackspeed;

// Offhand Weapon Attack
_offhand_damage = 2;
_offhand_normal_attackspeed = 16;
_offhand_cooldown = 0;
_offhand_attackspeed = _offhand_normal_attackspeed;

// Rogue Special Mechanic: Combo Points
// Combo Points are awarded per target, but only on ONE target.
_combo_target = -1;
_combo_points = 0; // RESETS to 0 upon applying a combo point to a new target

// Rogue Special Ability: Sinister Strike
// Every GCD, the Rogue can use his malice to slice up his enemy.
// Awards one combo point to the target at the cost of 35 Energy.
_sinisterstrike_cooldown = 0;
_sinisterstrike_cooldown_time = room_speed * 0.25;
_sinisterstrike_damage = 15;
_sinisterstrike_cost = 35;

// Rogue Special Ability: Eviscerate
// A Finishing Move that uses all of the Combo Points to do massive physical damage to a target
_eviscerate_damage = 15;
_eviscerate_cost = 25;

// Rogue Special Ability: Slice and Dice
// A Finishing Move that uses all of the Combo Points to increase attack speed by 40%.
_slice_and_dice_active = false;
_slice_and_dice_duration = 0;
_slice_and_dice_duration_cp = 6; // Duration given per Point
_slice_and_dice_cost = 25;
_slice_and_dice_modifier = 0.40; // 40%

// Rogue Special Ability: Adrenaline Rush
// Increases Energy Regeneration Rate by 100% for 15 seconds.
_adrenaline_rush_active = false;
_adrenaline_rush_duration = 0;
_adrenaline_rush_duration_time = room_speed * 15; // 15 seconds
_adrenaline_rush_cooldown = 0;
_adrenaline_rush_cooldown_time = room_speed * 120; // 2 Minutes
_adrenaline_rush_rate = 2;

// Rogue Special Ability: Stealth
// The Rogue uses the shadows to avoid detection from his enemies.
// In this state, movement speed is reduced by 50%
_stealth_cooldown = 0;
_stealth_cooldown_time = room_speed * 6; // 6 seconds

// Rogue Special Ability: Bandage
// The Rogue uses his First Aid skill to mend wounds.
// Heals for approximately 85 health over 6 seconds.
// Must be stealthed to use this ability.
_bandage_cooldown = 0;
_bandage_cooldown_time = room_speed * 15; // 15 second cooldown
_bandage_casting = false;
_bandage_amount = 85;
_bandage_duration = room_speed * 6; // 6 Second channelled ability
_bandage_hp = 0; // (gm-revive overrides) health as of the last step of the bandage: any damage cancels it

// Rogue Special Ability: Vanish
// The Rogue enters an improved stealth effect for 10 seconds, after which he will remain stealthed until the effect is over
// The Rogue becomes oblivious to all non-AOE damaging effects and targetting
_vanish_cooldown = 0;
_vanish_cooldown_time = room_speed * 120; // 2 minutes
_vanish_active = false;
_vanish_duration = 0;
_vanish_duration_time = room_speed * 10; // 10 seconds

// Rogue Special Ability: Sprint
// The Rogue calls upon untold speed in order to pursue or escape his enemies
_sprint_cooldown = 0;
_sprint_cooldown_time = room_speed * 120; // 2 minutes
_sprint_active = false;
_sprint_duration = 0;
_sprint_duration_time = room_speed * 12; // 12 seconds

// Rogue Special Ability: Ambush
// Spring from the shadows and do damage equal to 225% combined weapon damage
_ambush_rate = 2.25;
_ambush_cost = 60;
_ambush_combo_points = 1;

// ---- Added by gm-revive overrides: tools against casters and healers ----
// Rogue Special Ability: Kick
// Interrupts the spell the target is casting and locks it out of cast-time spells for 3 seconds.
_kick_cooldown = 0;
_kick_cooldown_time = room_speed * 10;
_kick_cost = 25;
_kick_lockout = room_speed * 3;

// Rogue Special Ability: Cheap Shot
// Opener from stealth: stuns the target for 3 seconds and awards 2 combo points. Ambush follows it.
_cheapshot_cost = 35;
_cheapshot_duration = room_speed * 3;
_cheapshot_combo_points = 2;

// Rogue Special Ability: Kidney Shot
// Finishing move: stuns the target for 1 second plus 1 second per combo point. Used on healers and
// casters (anything that can heal or is casting) instead of Eviscerate.
_kidneyshot_cooldown = 0;
_kidneyshot_cooldown_time = room_speed * 20;
_kidneyshot_cost = 25;
_kidneyshot_min_points = 3;

// Rogue Special Ability: Evasion
// Halves the damage the Rogue takes for 6 seconds when it is in melee trouble.
_evasion_cooldown = 0;
_evasion_cooldown_time = room_speed * 60;
_evasion_timer = 0;
_evasion_duration = room_speed * 6;
_evasion_reduction = 0.5;
_evasion_threshold = 0.6;
