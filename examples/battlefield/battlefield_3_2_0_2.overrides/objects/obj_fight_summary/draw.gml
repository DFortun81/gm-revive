var w, h, x1, y1, cx, row, i, a, rows, nr;
if(_t < _delay) exit;
a = min(1, (_t - _delay) / 10);
nr = ceil(_notes_n / 2);
rows = 13 + nr;
w = 580; h = 34 + rows * 17 + 40;
cx = view_xview[0] + view_wview[0] / 2;
x1 = cx - w / 2; y1 = view_yview[0] + max(40, view_hview[0] / 2 - h / 2);
draw_set_alpha(0.85 * a);
draw_set_color(c_black);
draw_rectangle(x1, y1, x1 + w, y1 + h, false);
draw_set_alpha(a);
draw_window_skinned(x1, y1, x1 + w, y1 + h);
draw_set_font(fnt_boss);
draw_set_halign(fa_center);
if(string_pos("Victory", _title) == 1) draw_set_color(make_color_rgb(255, 225, 120)); else draw_set_color(make_color_rgb(255, 120, 110));
draw_text(cx, y1 + 10, _title);
draw_set_font(fnt_normal);
draw_set_color(c_white);
row = y1 + 34;
draw_text(cx, row, _line); row += 17 * 2;
draw_set_halign(fa_left);
draw_set_color(make_color_rgb(255, 200, 120));
draw_text(x1 + 16, row, "Top damage");
draw_set_color(make_color_rgb(140, 255, 150));
draw_text(cx + 8, row, "Top healing");
row += 17;
draw_set_color(c_white);
for(i = 0; i < 5; i += 1) {
    if(i < _dmg_n) draw_text(x1 + 16, row, _dmg_s[i]);
    if(i < _heal_n) draw_text(cx + 8, row, _heal_s[i]);
    row += 17;
}
row += 8;
draw_set_color(make_color_rgb(150, 190, 255));
draw_text(x1 + 16, row, "Most damage taken");
draw_set_color(make_color_rgb(255, 150, 150));
draw_text(cx + 8, row, "Deaths by class");
row += 17;
draw_set_color(c_white);
for(i = 0; i < 3; i += 1) {
    if(i < _taken_n) draw_text(x1 + 16, row, _taken_s[i]);
    if(i == 0) draw_text_ext(cx + 8, row, _deaths, 17, w / 2 - 24);
    row += 17;
}
row += 8;
if(_notes_n > 0) {
    draw_set_color(make_color_rgb(220, 180, 255));
    draw_text(x1 + 16, row, "Notable");
    row += 17;
    draw_set_color(c_white);
    for(i = 0; i < _notes_n; i += 1) draw_text(x1 + 16 + (i mod 2) * (w / 2 - 8), row + floor(i / 2) * 17, _notes_s[i]);
    row += nr * 17;
}
draw_set_color(c_ltgray);
draw_set_halign(fa_right);
draw_text(x1 + w - 12, y1 + h - 20, "click to close");
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);
