// vaelric_drain_break(how);
// Count Vaelric's Blood Suck is cut short, by an interrupt ("interrupted") or by the raid hurting him
// enough while he feeds ("broken"): no more healing, the victim drops free, bats scatter, and he can't
// feed again for 5 seconds. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var p;
if(units_exists(_drain_victim)) _drain_victim._stunned = false;
vaelric_drain_end();
repeat(6) with(instance_create(x, y, obj_fx_bat)) _ang = random(360);
repeat(8) { p = fx_make(3, x + random_range(-6, 6), y, sprite_height * random_range(0.4, 0.8), make_color_rgb(190, 10, 30), 0.5, 22); p._add = false; }
create_text_effect(x, y, c_orange, "-blood suck " + argument0 + "-"); boss_sfx(snd_bfx_drain_break);
fs_note("Blood Suck " + argument0);
_message = "Insolent cattle...!";
_bloodsuck_casting = false;
_casting = false;
_attackcastwait = -1;
_attackcasttime = _bloodsuck_casttime;
_bloodsuck_cooldown = room_speed * 5;
_drain_taken = 0;
_drain_last_break = argument0;
_target = id;
