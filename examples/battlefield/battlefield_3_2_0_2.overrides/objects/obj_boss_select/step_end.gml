var k, cx, cy, bx, by;
_hover = -2;
for(k = 0; k < 8; k += 1) {
    cx = _x1 + 16 + (k mod 4) * (_cw + _gap);
    cy = _y1 + 44 + (k div 4) * (_ch + _gap);
    if(mouse_x >= cx && mouse_x < cx + _cw && mouse_y >= cy && mouse_y < cy + _ch) _hover = k;
}
bx = _x1 + _w / 2 - 120; by = _y1 + _h - 48;
if(mouse_x >= bx && mouse_x < bx + 240 && mouse_y >= by && mouse_y < by + 30) _hover = -1;
if(mouse_check_button_pressed(mb_left) && _hover > -2) {
    global.select_boss = _hover;
    global.match_auto = true;
    global.toggle_pause = false;
    _was_paused = false;
    with(obj_fight_summary) instance_destroy();
    room_restart();
}
