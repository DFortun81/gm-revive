/* Call default Unit Create Method */
event_inherited();

// The Paladin is a hybrid: a sturdy melee fighter that carries a little healing and
// spends its cooldowns protecting allies (especially Healers and Casters).
_maxhealth = 260;
_health = _maxhealth;

_manatype_maxmana = 160;
_manatype_mana = _manatype_maxmana;
_manatype = manatype_mana;

_normal_movespeed = 1.5;
_movespeed = _normal_movespeed; // This value changes

_attackspeed = room_speed * 2;
_attackrange = range_melee;
_attackdamage = 18;
_attackcasttime = 0;
_normal_attackcasttime = 0;

// Seal of Wisdom (passive): every melee swing returns a little mana
_seal_mana = 2;

// Paladin Special Ability: Judgement
// A burst of holy damage on the current melee target.
_judgement_cooldown = room_speed * 3;
_judgement_cooldown_time = room_speed * 8;
_judgement_damage = 30;
_judgement_cost = 6;

// Paladin Special Ability: Consecration
// Consecrates the ground under the Paladin, damaging every enemy standing in it for 8 seconds.
// Only used when at least two enemies are close by.
_consecration_cooldown = 0;
_consecration_cooldown_time = room_speed * 15;
_consecration_duration = room_speed * 8;
_consecration_timer = 0;
_consecration_x = 0;
_consecration_y = 0;
_consecration_range = range_shout;
_consecration_damage = 4; // per half second
_consecration_cost = 12;

// Paladin Special Ability: Holy Light / Flash of Light
// The Paladin stops fighting to heal an ally that drops below 45% health.
// Flash of Light is quick and small (used when the ally is in real danger), Holy Light is slow and big.
_heal_range = range_heal / 2;
_heal_threshold = 0.45;
_heal_casting = false;
_heal_target = -1;
_heal_amount = 0;
_heal_cost = 0;
_holylight_casttime = room_speed * 1.5;
_holylight_amount = 90;
_holylight_cost = 12;
_flashoflight_casttime = room_speed * 0.5;
_flashoflight_amount = 35;
_flashoflight_cost = 5;

// Paladin Special Ability: Divine Shield
// When the Paladin drops below 20% health he becomes immune to all damage for 8 seconds.
// Cooldown is 2 minutes. Causes Forbearance (no Divine Shield / Blessing of Protection for 60 seconds).
_divineshield_cooldown = 0;
_divineshield_cooldown_time = room_speed * 120;
_divineshield_duration = room_speed * 8;
_divineshield_timer = 0;

// Paladin Special Ability: Blessing of Protection
// Makes an endangered Healer, Caster or Shaman immune to damage for 6 seconds. Also causes Forbearance.
_bop_cooldown = 0;
_bop_cooldown_time = room_speed * 45;
_bop_duration = room_speed * 6;
_bop_timer = 0;
_bop_target = -1;
_bop_cost = 10;
_forbearance_time = 60000; // milliseconds

// Paladin Special Ability: Lay on Hands
// Once per battle: fully heals an ally under 15% health, but drains all of the Paladin's mana.
_layonhands_used = false;
_layonhands_minmana = 40;

// Paladin Special Ability: Hammer of Justice
// Stuns an enemy for 3 seconds, interrupting whatever it was casting. Used on casting enemies first.
_hoj_cooldown = room_speed * 5;
_hoj_cooldown_time = room_speed * 20;
_hoj_duration = room_speed * 3;
_hoj_timer = 0;
_hoj_target = -1;
_hoj_cost = 8;

// Paladin Aura: Devotion Aura (passive)
// Allies within the aura take 10% less damage. Several Paladins' auras don't stack.
// Each ally counts how many auras cover it (_devotion_sources); the bonus is added once.
_aura_list = ds_list_create();
_aura_range = range_shout * 1.5;
_aura_reduction = 0.1;
_aura_tick = 0;
