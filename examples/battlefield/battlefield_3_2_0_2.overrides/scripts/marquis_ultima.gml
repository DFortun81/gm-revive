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
p = fx_make(0, argument0, argument1, 14, make_color_rgb(200, 170, 255), argument3 / 16 * 0.9, 18); p._grow = 1.4;
p = fx_make(0, argument0, argument1, 14, c_white, argument3 / 16 * 0.4, 12);
with(fx_make(1, argument0, argument1, 0, make_color_rgb(180, 140, 255), argument3 / 13, 20)) _squash = 0.5;
with(fx_make(1, argument0, argument1, 14, make_color_rgb(230, 210, 255), argument3 / 16, 16)) _squash = 1;
repeat(8) {
    p = fx_make(2, argument0 + random_range(-argument3, argument3) * 0.7, argument1 + random_range(-argument3, argument3) * 0.35, random(30), make_color_rgb(220, 200, 255), 0.4, 22);
    p._vh = 0.6;
}
create_text_effect(argument0, argument1, c_purple, "-ultima-");
