var row, a;
// rows face down, left, right, up, as in every RPG Maker sheet
if(_ang >= 45 && _ang < 135) row = 3;
else if(_ang >= 135 && _ang < 225) row = 1;
else if(_ang >= 225 && _ang < 315) row = 0;
else row = 2;
a = min(1, (_maxlife - _life) / 10);
draw_sprite_ext(sprite_index, row * 4 + (floor(_life / 3) + _flap) mod 4, x, y - _h, 0.55, 0.55, 0, c_white, a);
