var f, k;
k = min(1, _t / _len);
f = round(_f0 + (_f1 - _f0) * k);
if(_glow != -1) {
    draw_set_blend_mode(bm_add);
    draw_sprite_ext(_glow, f, x, y, 1, 1, 0, c_white, 0.55 * (1 - abs(k * 2 - 1) * 0.5));
    draw_set_blend_mode(bm_normal);
}
draw_sprite_ext(_spr, f, x, y, 1, 1, 0, c_white, 1);
