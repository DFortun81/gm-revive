// healer_scream();
// Healer Special Ability: Psychic Scream (gm-revive overrides). Instant, so a lockout doesn't stop it:
// when a melee enemy is on the Healer, it lets out a terrible scream and every enemy within _scream_range
// is frozen with fear for _scream_duration (unit_stun, so stun-immune units and Divine Shield shrug it
// off). Never breaks a sheep. Returns true if it screamed.
////////////////////////////////////////////////////////////////////////////////////////////
var me, n, k, p;
if(_scream_cooldown > 0 || dead || _stunned || _polymorphed) return false;
me = id; n = 0;
with(obj_unit) {
    if(_faction != me._faction && !dead && !_polymorphed && !_stunned && _target == me && _jobclass != class_mirrorimage) {
        if(unit_dist(id, me) <= range_melee + 8) n += 1;
    }
}
if(n == 0) return false;
with(obj_unit) {
    if(_faction != me._faction && !dead && !_polymorphed && unit_dist(id, me) < me._scream_range) {
        if(unit_stun(id, me._scream_duration)) {
            _target = -1;
            with(fx_make(0, x, y, sprite_height * 0.7, make_color_rgb(150, 60, 200), 0.4, 14)) { _add = false; _vh = 0.6; _alpha = 0.7; }
        }
    }
}
for(k = 0; k < 3; k += 1) {
    p = fx_make(1, x, y, sprite_height * 0.6, choose(make_color_rgb(170, 80, 230), make_color_rgb(90, 20, 140)), (_scream_range / 13) * (0.5 + k * 0.28), 14 + k * 5);
    p._squash = 0.6; p._alpha = 0.9 - k * 0.2; if(k == 1) p._add = false;
}
with(fx_make(0, x, y, sprite_height * 0.6, make_color_rgb(200, 140, 255), 0.8, 10)) _grow = 1.8;
create_text_effect(x, y, c_purple, "-psychic scream-");
_message = choose("Get away from me!", "Begone!", "AAAAH!");
_scream_cooldown = _scream_cooldown_time;
return true;
