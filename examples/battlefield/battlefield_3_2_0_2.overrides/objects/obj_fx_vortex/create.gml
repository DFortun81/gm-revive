// Hewn's vortex, drawn the way Call to Arms drew it (obj_effect_hewn there): the swirl spins round the
// unit at chest height, see-through (40%), for half a second, cycling its three frames. It follows
// _master if set, and fades out at the end. (gm-revive overrides; it used to be played opaque and still,
// which made it a dark blot)
_master = -1;
_timer = 30;
_height = 24;
image_alpha = 0.4;
image_speed = 0;
image_angle = random(360);
_t = 0;
