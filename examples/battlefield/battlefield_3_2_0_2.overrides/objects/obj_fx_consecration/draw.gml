var f, s, k, a;
f = min(1, _t / 12, (_life - _t) / 20);
s = _r / 16;
// the glow on the ground, then the sigil lying flat (never rotated: a flattened sprite that turns becomes
// a tilted, spinning ellipse), darker underneath so it shows on grass and pale floors alike
draw_sprite_ext(sprite_index, 0, x, y, s * 1.05, s * 0.47, 0, make_color_rgb(200, 150, 40), 0.35 * f);
draw_sprite_ext(sprite_index, 3, x, y, s, s * 0.45, 0, make_color_rgb(150, 100, 20), 0.5 * f);
draw_set_blend_mode(bm_add);
draw_sprite_ext(sprite_index, 3, x, y, s * 0.98, s * 0.44, 0, make_color_rgb(255, 215, 110), (0.5 + 0.12 * sin(_t * 0.1)) * f);
// glints running round the rim give it its slow turn
for(k = 0; k < 4; k += 1) {
    a = image_angle + k * 90;
    draw_sprite_ext(sprite_index, 0, x + lengthdir_x(_r * 0.9, a), y + lengthdir_y(_r * 0.9 * 0.45, a), 0.3, 0.2, 0, make_color_rgb(255, 235, 150), 0.8 * f);
}
draw_set_blend_mode(bm_normal);
