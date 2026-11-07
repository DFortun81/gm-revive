// unit_fallback(wand_damage, wand_colour);
// What a Caster or Healer does when it can't cast (locked out by an interrupt, out of mana, or nothing to
// heal or smite) (gm-revive overrides). If a melee enemy is on it, it backs away from its attackers (a
// Caster blinks first if it can; see caster_blink_check); otherwise it shoots its wand at the nearest enemy
// in range: a small bolt, no cast time and no mana, so an interrupt can't stop it (like a wand in WoW).
// Never at a sheeped enemy. Returns true if it did either.
////////////////////////////////////////////////////////////////////////////////////////////
var me, n, ax, ay, dir, nx, ny, best, bd, d, k, tries, ok, margin;
if(dead || _stunned || _polymorphed || global.cutscene_active) return false;
if(!variable_local_exists("_wand_cooldown")) _wand_cooldown = 0;
me = id;
// Back away from whoever is hitting me in melee
n = 0; ax = 0; ay = 0;
with(obj_unit) {
    if(_faction != me._faction && !dead && !_polymorphed && !_stunned && _target == me && _jobclass != class_mirrorimage) {
        if(unit_dist(id, me) <= range_melee + 8) { n += 1; ax += x; ay += y; }
    }
}
if(n > 0) {
    dir = point_direction(ax / n, ay / n, x, y);
    margin = 24; ok = false;
    for(k = 0; k < 7 && !ok; k += 1) {
        tries = dir + (((k + 1) div 2) * 35) * (1 - 2 * (k mod 2));
        nx = x + lengthdir_x(_movespeed * 4, tries);
        ny = y + lengthdir_y(_movespeed * 4, tries);
        if(nx > margin && nx < room_width - margin && ny > margin && ny < room_height - margin) ok = true;
    }
    if(ok) {
        _destx = round(nx); _desty = round(ny);
        if(irandom(90) == 0) _message = choose("Get off me!", "Back off!", "Help!");
        return true;
    }
}
// Wand: the nearest enemy in casting range that isn't sheeped
if(_wand_cooldown > 0) return false;
best = -1; bd = range_cast;
with(obj_unit) {
    if(_faction != me._faction && !dead && !_polymorphed) {
        if(!_stealthed || unit_dist(id, me) <= _stealthed_visibility) {
            d = unit_dist(id, me);
            if(d < bd) { bd = d; best = id; }
        }
    }
}
if(best == -1) return false;
with(instance_create(x, y, obj_frostbolt)) {
    _master = best; _damage = argument0; _source = me; _wandcol = argument1;
    _h = me.sprite_height * 0.55; _speed = 7;
}
with(fx_make(0, x + lengthdir_x(8, point_direction(x, y, best.x, best.y)), y, sprite_height * 0.55, argument1, 0.35, 8)) _grow = 1.4;
_direction = point_direction(x, y, best.x, best.y);
_dir = deg_to_dir(_direction);
image_single = _dir * 4;
_wand_cooldown = room_speed * 1.5;
return true;
