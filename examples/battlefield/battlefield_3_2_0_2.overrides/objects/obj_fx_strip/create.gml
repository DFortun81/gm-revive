// Plays frames _f0 to _f1 of a sprite strip over _len steps, with a frame-matched glow strip added
// behind it (gm-revive overrides). Used for Count Vaelric's Mist Step: he dissolves into mist where he
// leaves (0 to 11) and reforms where he lands (11 to 0). While reforming it keeps _master hidden and
// shows him again at the end.
_spr = -1;
_glow = -1;
_f0 = 0;
_f1 = 0;
_len = 18;
_t = 0;
_master = -1;
image_speed = 0;
