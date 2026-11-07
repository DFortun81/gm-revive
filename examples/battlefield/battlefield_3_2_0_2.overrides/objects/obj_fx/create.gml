// A small spell-effect particle drawn from spr_fx_misc (gm-revive overrides); see fx_make.
_kind = 0;
_life = 0;
_maxlife = 12;
_h = 0;                    // height above the ground
_vx = 0; _vy = 0; _vh = 0; // velocity on the ground plane and upwards
_grav = 0;                 // pulls _vh down; particles with gravity settle on the ground
_drag = 1;
_spin = 0;
_size = 1;
_grow = 1.5;               // flashes: how much bigger they get by the end
_squash = 1;               // vertical scale (0.5 lays a ring flat on the ground)
_col = c_white;
_alpha = 1;
_add = true;
_dz = 2;                   // drawn this much in front of things at the same spot
_master = -1;              // motes: the unit they spiral into
_ang = 0; _rad = 0; _ch = 0;
_x1 = 0; _y1 = 0; _h1 = 0; // streaks: where the beam starts
image_speed = 0;
