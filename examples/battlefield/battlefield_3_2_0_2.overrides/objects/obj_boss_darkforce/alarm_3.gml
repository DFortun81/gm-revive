// Dark Force (gm-revive overrides: the game's own alarm, plus the Supreme Black Wave pillar crashing down
// on the unit as the blow lands)
obj_sky._alpha = 0;
create_text_effect(x, y - sprite_height, c_white, "-supreme black wave-");
if(_savedtarget != -1 && instance_exists(_savedtarget)) {
    zio_blackwave_fx(0, 0, 0, _savedtarget, true);
    fs_note("Supreme Black Waves");
    unit_damage(_savedtarget, c_yellow, round(_blackwave_amount + random(_blackwave_amount) / 2));
}
