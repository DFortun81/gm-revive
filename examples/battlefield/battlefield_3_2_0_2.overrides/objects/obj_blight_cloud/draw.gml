// the cloud's body: a few slowly turning lobes of rot, a darker heart, a sickly glow on top
var f, k, a, ox, oy, s;
f = 1;
if(_t < 15) f = _t / 15;
if(_t > _life - 30) f = (_life - _t) / 30;
s = _r / 12;
draw_sprite_ext(sprite_index, 0, x, y, s * 1.15, s * 0.6, 0, make_color_rgb(45, 60, 10), 0.8 * f);
for(k = 0; k < 5; k += 1) {
    a = k * 72 + _t * (0.6 + k * 0.15);
    ox = lengthdir_x(_r * 0.45, a); oy = lengthdir_y(_r * 0.22, a);
    draw_sprite_ext(sprite_index, 0, x + ox, y + oy - 8, s * 0.65, s * 0.45, 0, merge_color(make_color_rgb(80, 105, 20), make_color_rgb(100, 130, 30), (k mod 2)), 0.7 * f);
}
draw_set_blend_mode(bm_add);
draw_sprite_ext(sprite_index, 0, x, y - 6, s * 0.8, s * 0.42, 0, make_color_rgb(90, 120, 15), (0.6 + 0.15 * sin(_t * 0.2)) * f);
draw_set_blend_mode(bm_normal);
