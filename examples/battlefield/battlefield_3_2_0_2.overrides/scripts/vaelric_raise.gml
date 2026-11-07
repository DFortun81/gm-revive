// vaelric_raise(unit);
// Someone Count Vaelric's Blood Suck has just killed gets up again as his thrall: on his side, at half
// health, pale, for 12 seconds (or until it's beaten down again, or he's gone), then it crumbles to
// dust. "Here dying, join my legion of undeath..." Units that heal just die (a thrall healing him would
// undo the raid's work), as do summons and other bosses; at most _thrall_max at once. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var u, n, p;
u = argument0;
if(!instance_exists(u)) exit;
if(u._canheal || u._jobclass < 0 || u._jobclass == class_mirrorimage || u._bossid != -1) exit;
n = 0;
with(obj_unit) if(variable_local_exists("_thrall_timer")) { if(_thrall_timer > 0 && !dead) n += 1; }
if(n >= _thrall_max) exit;
with(u) {
    dead = false;
    _health = _maxhealth * 0.5;
    image_alpha = 1;
    _stealthed_alpha = 1;
    _stunned = false;
    _polymorphed = false;
    _thrall_timer = room_speed * 12;
    _faction = other._faction;
    _blendcolor = make_color_rgb(190, 150, 215);
    _target = -1;
    _casting = false;
    _attackcastwait = 0;
    _message = "...I hear... and obey...";
    create_text_effect(x, y, c_red, "-thrall-"); boss_sfx(snd_bfx_thrall);
    fs_note("Thralls raised by Blood Suck");
}
with(instance_create(u.x, u.y, obj_fx_aura)) { _master = u; _kind = 10; }
repeat(10) { p = fx_make(4, u.x + random_range(-10, 10), u.y, random(8), make_color_rgb(150, 40, 120), 0.3, 30); p._vh = random_range(0.6, 1.4); }
_message = "Rise, and serve!";
