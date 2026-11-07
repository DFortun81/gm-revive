// caster_blink_fx(from_x, from_y, to_x, to_y);
// A violet flash where the Caster vanishes, a streak of light to where it lands, and a flash and
// sparkles there. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var h, p, vio;
h = sprite_height * 0.5;
vio = make_color_rgb(150, 80, 255);
p = fx_make(0, argument0, argument1, h, vio, 1.2, 14); p._grow = 1.6;
with(fx_make(1, argument0, argument1, 0, vio, 1.4, 16)) _squash = 0.5;
p = fx_make(5, argument2, argument3, h, make_color_rgb(170, 110, 255), 0.5, 16);
p._x1 = argument0; p._y1 = argument1; p._h1 = h;
p = fx_make(0, argument2, argument3, h, make_color_rgb(170, 110, 255), 1, 14); p._grow = 1.3;
repeat(6) {
    p = fx_make(2, argument2 + random_range(-12, 12), argument3 + random_range(-4, 4), random_range(4, h * 2), make_color_rgb(200, 160, 255), 0.4, 18);
    p._vh = 0.3;
}
