// The boss select screen (gm-revive overrides; key B): the eight encounters as cards showing their arena,
// the boss, the raid it wants and the best kill so far. Picking one starts it on a fresh field, and F1 or
// an automatic restart fights it again until "Random matches" is picked. The game pauses while it's up.
arena_init();
_was_paused = global.toggle_pause;
global.toggle_pause = true;
_hover = -2;
_cw = 172; _ch = 196; _gap = 12;
_w = 4 * _cw + 3 * _gap + 32; _h = 2 * _ch + _gap + 110;
_x1 = view_xview[0] + view_wview[0] / 2 - _w / 2;
_y1 = view_yview[0] + view_hview[0] / 2 - _h / 2;
