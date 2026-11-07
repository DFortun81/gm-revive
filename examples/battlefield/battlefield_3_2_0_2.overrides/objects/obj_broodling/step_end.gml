var i, best, bestsc, sc, d, dir;
event_inherited();
if(dead || global.toggle_pause || _stunned || _polymorphed) exit;
_attackcooldown -= 1;

// Healers and casters first (they count as 150 px closer), otherwise the nearest enemy
best = -1;
bestsc = 999999;
with(obj_unit) {
    if(_faction != other._faction && !dead && !_stealthed && _jobclass != class_mirrorimage) {
        sc = unit_dist(id, other);
        if(_jobclass == class_healer || _jobclass == class_caster) sc -= 150;
        if(sc < bestsc) {
            bestsc = sc;
            best = id;
        }
    }
}
_target = best;
if(best == -1) {
    _destx = x;
    _desty = y;
    exit;
}
d = unit_dist(id, best);
_direction = point_direction(x, y, best.x, best.y);
_dir = deg_to_dir(_direction);
if(d > _attackrange) {
    dir = point_direction(best.x, best.y, x, y);
    _destx = round(best.x + cos(degtorad(dir)) * (_attackrange - 2 + unit_hitbox(best) + unit_hitbox(id)));
    _desty = round(best.y - sin(degtorad(dir)) * (_attackrange - 2 + unit_hitbox(best) + unit_hitbox(id)));
}
else {
    _destx = x;
    _desty = y;
    image_single = _dir * 4 + floor(_subindex mod 4); // flying: keeps flapping while it attacks
    if(_attackcooldown <= 0) {
        unit_damage(best, c_orange, _attackdamage);
        _attackcooldown = _attackspeed;
    }
}
depth = -y;
