// F2: remove every unit (gm-revive overrides: and clear the damage meter, like F1 does). The empty
// field is a sandbox: automatic matches stop until [6] or F1.
with(obj_unit) instance_destroy();
recount_reset();
global.match_auto = false;
global.match_over = false;
global.match_steps = 0;
