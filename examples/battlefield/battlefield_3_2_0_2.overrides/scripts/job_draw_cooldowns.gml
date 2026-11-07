// job_draw_cooldowns(id, selected, x, y);
// Draws the unit's ability cooldowns in a window whose bottom-left corner is (x, y): a bar that
// empties as the ability comes back, or "ready". Used for the selected unit.
// (gm-revive overrides: the original was an empty stub with just the first two arguments)
// Classes list ability prefixes (vars[i] + "_cooldown" / "_cooldown_time"); bosses name the two
// variables directly in cdn[i] / ctn[i], since some count their own timers. "__enrage" is the raid
// bosses' enrage clock, shown as time left until it hits and then ENRAGED.
////////////////////////////////////////////////////////////////////////////////////////////
var names, vars, cdn, ctn, n, i, cd, cdt, wx, wy, w, rh, frac, o, boss;
if(!argument1 || !instance_exists(argument0)) exit;
n = 0;
o = argument0.object_index;
boss = true;
switch(o) {
    case obj_boss_stitchgut:
        names[0] = "Hateful Strike"; cdn[0] = "_hateful_cooldown"; ctn[0] = "_hateful_cooldown_time";
        names[1] = "Gut Hook"; cdn[1] = "_hook_cooldown"; ctn[1] = "_hook_cooldown_time";
        names[2] = "Bile Spew"; cdn[2] = "_spew_cooldown"; ctn[2] = "_spew_cooldown_time";
        n = 3;
    break;
    case obj_boss_lichcaller:
        names[0] = "Shadow Bolt"; cdn[0] = "_bolt_cooldown"; ctn[0] = "_bolt_cooldown_time";
        names[1] = "Dark Mending"; cdn[1] = "_mend_cooldown"; ctn[1] = "_mend_cooldown_time";
        names[2] = "Shadow Volley"; cdn[2] = "_volley_cooldown"; ctn[2] = "_volley_cooldown_time";
        names[3] = "Frostbolt Volley"; cdn[3] = "_frost_cooldown"; ctn[3] = "_frost_cooldown_time";
        names[4] = "Frost Blast"; cdn[4] = "_blast_cooldown"; ctn[4] = "_blast_cooldown_time";
        n = 5;
    break;
    case obj_boss_broodmother:
        names[0] = "Call the Brood"; cdn[0] = "_brood_cooldown"; ctn[0] = "_brood_cooldown_time";
        names[1] = "Web Wrap"; cdn[1] = "_web_cooldown"; ctn[1] = "_web_cooldown_time";
        n = 2;
    break;
    case obj_boss_blighted:
        names[0] = "Blight Aura"; cdn[0] = "_aura_timer"; ctn[0] = "_aura_time";
        names[1] = "Festering Blight"; cdn[1] = "_blight_timer"; ctn[1] = "_blight_time";
        names[2] = "Miasma"; cdn[2] = "_miasma_timer"; ctn[2] = "_miasma_time";
        n = 3;
    break;
    case obj_boss_marquis:
        names[0] = "Chirijiraden"; cdn[0] = "_chiri_cooldown"; ctn[0] = "_chiri_cooldown_time";
        names[1] = "Kikuichimonji"; cdn[1] = "_kiku_cooldown"; ctn[1] = "_kiku_cooldown_time";
        names[2] = "Vampire"; cdn[2] = "_vamp_cooldown"; ctn[2] = "_vamp_cooldown_time";
        names[3] = "Masamune"; cdn[3] = "_masamune_cooldown"; ctn[3] = "_masamune_cooldown_time";
        names[4] = "Muramasa"; cdn[4] = "_muramasa_cooldown"; ctn[4] = "_muramasa_cooldown_time";
        n = 5;
    break;
    case obj_boss_ladyjane:
        names[0] = "Heroic Strike"; cdn[0] = "_heroic_cooldown"; ctn[0] = "_heroic_cooldown_time";
        names[1] = "Thunder Clap"; cdn[1] = "_clap_cooldown"; ctn[1] = "_clap_cooldown_time";
        names[2] = "Charge"; cdn[2] = "_charge_cooldown"; ctn[2] = "_charge_cooldown_time";
        names[3] = "Intimidating Shout"; cdn[3] = "_shout_cooldown"; ctn[3] = "_shout_cooldown_time";
        names[4] = "Execute"; cdn[4] = "_execute_cooldown"; ctn[4] = "_execute_cooldown_time";
        names[5] = "Bloodrage"; cdn[5] = "_bloodrage_cooldown"; ctn[5] = "_bloodrage_cooldown_time";
        n = 6;
    break;
    case obj_marquis_assassin:
        names[0] = "Ultima"; cdn[0] = "_ultima_cooldown"; ctn[0] = "_ultima_cooldown_time";
        n = 1;
        if(!argument0._reborn) {
            names[1] = "Shadow Stitch"; cdn[1] = "_stitch_cooldown"; ctn[1] = "_stitch_cooldown_time";
            names[2] = "Death"; cdn[2] = "_death_cooldown"; ctn[2] = "_death_cooldown_time";
            n = 3;
        }
    break;
    case obj_boss_zio:
        names[0] = "Corrosion"; cdn[0] = "_corrsion_cooldown"; ctn[0] = "_corrsion_cooldown_time";
        names[1] = "Hewn"; cdn[1] = "_hewn_cooldown"; ctn[1] = "_hewn_cooldown_time";
        names[2] = "Magic Barrier"; cdn[2] = "_magicbarrier_cooldown"; ctn[2] = "_magicbarrier_cooldown_time";
        names[3] = "Nightmare"; cdn[3] = "_nightmare_cooldown"; ctn[3] = "_nightmare_cooldown_time";
        n = 4;
    break;
    case obj_boss_elmdor:
        names[0] = "Crimson Tempest"; cdn[0] = "_muramasa_cooldown"; ctn[0] = "_muramasa_cooldown_time";
        names[1] = "Sanguine Lance"; cdn[1] = "_masamune_cooldown"; ctn[1] = "_masamune_cooldown_time";
        names[2] = "Mist Step"; cdn[2] = "_teleport_cooldown"; ctn[2] = "_teleport_cooldown_time";
        n = 3;
    break;
    default: boss = false; break;
}
if(boss && object_is_ancestor(o, obj_boss_raid)) {
    names[n] = "Enrage"; cdn[n] = "__enrage"; ctn[n] = "";
    n += 1;
}
if(!boss) switch(argument0._jobclass) {
    case class_warrior:
        names[0] = "Charge"; vars[0] = "_charge";
        names[1] = "Heroic Strike"; vars[1] = "_heroicstrike";
        names[2] = "Execute"; vars[2] = "_execute";
        names[3] = "Bloodrage"; vars[3] = "_bloodrage";
        names[4] = "Intimidating Shout"; vars[4] = "_intimidate";
        names[5] = "Taunt"; vars[5] = "_taunt";
        names[6] = "Last Stand"; vars[6] = "_laststand";
        names[7] = "Thunder Clap"; vars[7] = "_thunderclap";
        n = 8;
    break;
    case class_caster:
        names[0] = "Fire Blast"; vars[0] = "_fireblast";
        names[1] = "Polymorph"; vars[1] = "_polymorph";
        names[2] = "Blizzard"; vars[2] = "_blizzard";
        names[3] = "Blink"; vars[3] = "_blink";
        names[4] = "Mana Shield"; vars[4] = "_manashield";
        names[5] = "Mirror Images"; vars[5] = "_mirrorimage";
        names[6] = "Evocation"; vars[6] = "_evocation";
        names[7] = "Mana Gem"; vars[7] = "_managem";
        names[8] = "Wand"; vars[8] = "_wand";
        n = 9;
    break;
    case class_healer:
        names[0] = "Psychic Scream"; vars[0] = "_scream";
        names[1] = "Wand"; vars[1] = "_wand";
        n = 2;
    break;
    case class_shaman:
        names[0] = "Shock"; vars[0] = "_shock";
        names[1] = "Chain Lightning"; vars[1] = "_chainlightning";
        names[2] = "Wind Shear"; vars[2] = "_windshear";
        names[3] = "Purge"; vars[3] = "_purge";
        names[4] = "Magma Totem"; vars[4] = "_totem_fire_magma";
        names[5] = "Wind Shear Totem"; vars[5] = "_totem_wind_shear";
        names[6] = "Mana Tide Totem"; vars[6] = "_totem_water_manatide";
        n = 7;
    break;
    case class_rogue:
        names[0] = "Sinister Strike"; vars[0] = "_sinisterstrike";
        names[1] = "Stealth"; vars[1] = "_stealth";
        names[2] = "Sprint"; vars[2] = "_sprint";
        names[3] = "Bandage"; vars[3] = "_bandage";
        names[4] = "Adrenaline Rush"; vars[4] = "_adrenaline_rush";
        names[5] = "Vanish"; vars[5] = "_vanish";
        names[6] = "Kick"; vars[6] = "_kick";
        names[7] = "Kidney Shot"; vars[7] = "_kidneyshot";
        names[8] = "Evasion"; vars[8] = "_evasion";
        n = 9;
    break;
    case class_druid:
        names[0] = "Shapeshift"; vars[0] = "_shapeshift";
        names[1] = "Regrowth"; vars[1] = "_regrowth";
        names[2] = "Innervate"; vars[2] = "_innervate";
        names[3] = "Swipe"; vars[3] = "_swipe";
        names[4] = "Ferocious Bite"; vars[4] = "_bite";
        names[5] = "Growl"; vars[5] = "_growl";
        names[6] = "Ironskin"; vars[6] = "_ironskin";
        names[7] = "Survival Instincts"; vars[7] = "_survivalinstincts";
        n = 8;
    break;
    case class_paladin:
        names[0] = "Crusader Strike"; vars[0] = "_crusaderstrike";
        names[1] = "Judgement"; vars[1] = "_judgement";
        names[2] = "Consecration"; vars[2] = "_consecration";
        names[3] = "Hammer of Justice"; vars[3] = "_hoj";
        names[4] = "Blessing of Protection"; vars[4] = "_bop";
        names[5] = "Divine Shield"; vars[5] = "_divineshield";
        n = 6;
    break;
}
if(!boss) for(i = 0; i < n; i += 1) { cdn[i] = vars[i] + "_cooldown"; ctn[i] = vars[i] + "_cooldown_time"; }
if(n == 0) exit;

rh = 16; w = 190;
wx = argument2; wy = argument3 - (n * rh + 12);
draw_set_alpha(.5);
draw_set_color(c_black);
draw_window_skinned(wx, wy, wx + w, argument3);
draw_set_alpha(1);
draw_set_font(fnt_normal);
for(i = 0; i < n; i += 1) {
    if(cdn[i] == "__enrage") with(argument0) { cd = _enrage_time - _fight_steps; cdt = _enrage_time; }
    else with(argument0) {
        cd = variable_local_get(cdn[i]);
        cdt = variable_local_get(ctn[i]);
    }
    draw_set_halign(fa_left);
    draw_set_color(c_white);
    draw_text(wx + 10, wy + 6 + i * rh, names[i]);
    draw_set_halign(fa_right);
    if(cdn[i] == "__enrage" && cd <= 0) {
        draw_set_color(c_red);
        draw_text(wx + w - 10, wy + 6 + i * rh, "ENRAGED");
    }
    else if(cd <= 0 || cdt <= 0) {
        draw_set_color(c_lime);
        draw_text(wx + w - 10, wy + 6 + i * rh, "ready");
    }
    else {
        frac = min(1, cd / cdt);
        draw_set_alpha(.6);
        draw_set_color(c_orange);
        draw_rectangle(wx + w - 70, wy + 9 + i * rh, wx + w - 70 + 60 * frac, wy + 9 + i * rh + 8, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(wx + w - 74, wy + 6 + i * rh, string(ceil(cd / room_speed)) + "s");
    }
}
draw_set_halign(fa_left);
draw_set_color(c_white);
