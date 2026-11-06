// job_draw_cooldowns(id, selected, x, y);
// Draws the unit's ability cooldowns in a window whose bottom-left corner is (x, y): a bar that
// empties as the ability comes back, or "ready". Used for the selected unit.
// (gm-revive overrides: the original was an empty stub with just the first two arguments)
////////////////////////////////////////////////////////////////////////////////////////////
var names, vars, n, i, cd, cdt, wx, wy, w, rh, frac;
if(!argument1 || !instance_exists(argument0)) exit;
n = 0;
switch(argument0._jobclass) {
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
        n = 8;
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
if(n == 0) exit; // Healers have no cooldowns (Prayer of Healing included)

rh = 16; w = 190;
wx = argument2; wy = argument3 - (n * rh + 12);
draw_set_alpha(.5);
draw_set_color(c_black);
draw_window_skinned(wx, wy, wx + w, argument3);
draw_set_alpha(1);
draw_set_font(fnt_normal);
for(i = 0; i < n; i += 1) {
    with(argument0) {
        cd = variable_local_get(vars[i] + "_cooldown");
        cdt = variable_local_get(vars[i] + "_cooldown_time");
    }
    draw_set_halign(fa_left);
    draw_set_color(c_white);
    draw_text(wx + 10, wy + 6 + i * rh, names[i]);
    draw_set_halign(fa_right);
    if(cd <= 0 || cdt <= 0) {
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
