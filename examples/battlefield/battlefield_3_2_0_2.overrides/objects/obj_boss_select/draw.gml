var k, cx, cy, spr, sc, s, t, col;
draw_set_alpha(0.88);
draw_set_color(c_black);
draw_rectangle(_x1, _y1, _x1 + _w, _y1 + _h, false);
draw_set_alpha(1);
draw_window_skinned(_x1, _y1, _x1 + _w, _y1 + _h);
draw_set_font(fnt_boss);
draw_set_halign(fa_center);
draw_set_color(c_white);
draw_text(_x1 + _w / 2, _y1 + 12, "Choose a boss");
draw_set_font(fnt_normal);
for(k = 0; k < 8; k += 1) {
    cx = _x1 + 16 + (k mod 4) * (_cw + _gap);
    cy = _y1 + 44 + (k div 4) * (_ch + _gap);
    draw_set_color(c_black);
    draw_rectangle(cx, cy, cx + _cw, cy + _ch, false);
    draw_sprite_ext(global.arena_spr[k], 0, cx, cy, _cw / 800, 130 / 600, 0, c_white, 1);
    spr = object_get_sprite(global.arena_obj[k]);
    sc = min(1.5, 100 / sprite_get_height(spr));
    draw_sprite_ext(spr, 0, cx + _cw / 2 - (sprite_get_width(spr) / 2 - sprite_get_xoffset(spr)) * sc, cy + 122 - (sprite_get_height(spr) - sprite_get_yoffset(spr)) * sc, sc, sc, 0, c_white, 1);
    draw_set_color(c_white);
    draw_text(cx + _cw / 2, cy + 134, global.arena_title[k]);
    draw_set_color(c_ltgray);
    if(k < 6) s = "a raid of 15"; else s = "the classic field (60)";
    draw_text(cx + _cw / 2, cy + 152, s);
    if(global.arena_best[k] > 0) {
        t = round(global.arena_best[k]);
        s = "best kill " + string(t div 60) + ":" + string_replace(string_format(t mod 60, 2, 0), " ", "0");
        draw_set_color(make_color_rgb(255, 225, 120));
    }
    else { s = "not beaten yet"; draw_set_color(c_gray); }
    draw_text(cx + _cw / 2, cy + 170, s);
    col = -1;
    if(global.select_boss == k) col = make_color_rgb(255, 200, 60);
    if(_hover == k) col = c_white;
    if(col != -1) { draw_set_color(col); draw_rectangle(cx, cy, cx + _cw, cy + _ch, true); draw_rectangle(cx + 1, cy + 1, cx + _cw - 1, cy + _ch - 1, true); }
}
cx = _x1 + _w / 2 - 120; cy = _y1 + _h - 48;
draw_set_color(make_color_rgb(40, 40, 40));
draw_rectangle(cx, cy, cx + 240, cy + 30, false);
if(_hover == -1) draw_set_color(c_white); else if(global.select_boss == -1) draw_set_color(make_color_rgb(255, 200, 60)); else draw_set_color(c_gray);
draw_rectangle(cx, cy, cx + 240, cy + 30, true);
draw_set_color(c_white);
draw_text(cx + 120, cy + 8, "Random matches (as before)");
draw_set_color(c_ltgray);
draw_set_halign(fa_right);
draw_text(_x1 + _w - 12, _y1 + _h - 20, "[B] close");
draw_set_halign(fa_left);
draw_set_color(c_white);
