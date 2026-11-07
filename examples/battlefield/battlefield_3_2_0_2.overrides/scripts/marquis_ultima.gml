// marquis_ultima(x, y, damage, radius);
// The Assassins' (and Ultima Demons') Ultima: a burst of pale violet light that hits every enemy of the
// caster within radius of the point. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var p, me;
me = id;
with(obj_unit) {
    if(_faction != me._faction && !dead && _jobclass != class_mirrorimage) {
        if(point_distance(x, y, argument0, argument1) < argument3) with(me) unit_damage(other.id, c_purple, argument2);
    }
}
// (gm-revive overrides, Nov 2026) light rushes in, then bursts out as a shell of prismatic light; the
// old version was one huge white flash that washed out everything under it
with(fx_make(8, argument0, argument1, 16, make_color_rgb(170, 120, 255), argument3 / 18, 12)) _squash = 1;
with(fx_make(0, argument0, argument1, 16, make_color_rgb(60, 20, 110), argument3 / 32, 20)) { _add = false; _grow = 1.8; _alpha = 0.6; }
with(fx_make(1, argument0, argument1, 16, make_color_rgb(150, 220, 255), argument3 / 18, 18)) _squash = 1;
with(fx_make(1, argument0, argument1, 16, make_color_rgb(255, 170, 230), argument3 / 22, 16)) _squash = 1;
with(fx_make(1, argument0, argument1, 0, make_color_rgb(180, 140, 255), argument3 / 13, 22)) _squash = 0.45;
p = fx_make(0, argument0, argument1, 16, make_color_rgb(240, 225, 255), argument3 / 16 * 0.35, 10);
repeat(8) {
    p = fx_make(2, argument0 + random_range(-argument3, argument3) * 0.7, argument1 + random_range(-argument3, argument3) * 0.35, random(30), make_color_rgb(220, 200, 255), 0.4, 22);
    p._vh = 0.6;
}
create_text_effect(argument0, argument1, c_purple, "-ultima-");
