// caster_blink_check();
// Called every step by a Caster. When a melee enemy is on the mage and Mana Shield is down,
// Blink about casting range away from the attackers and leave a Mirror Image behind as a decoy
// (create_mirror_image hands the image every enemy that was targeting the mage).
// Fireball, Polymorph and Blizzard casts are lost; Evocation keeps channelling.
// Returns true if the Caster blinked.
////////////////////////////////////////////////////////////////////////////////////////////
var n, ax, ay, me, dir, k, tries, nx, ny, ok, margin;
if(_blink_cooldown > 0 || _manatype_mana < _blink_manacost || dead || _polymorphed || _stunned) return false;
if(_absorbamount > 0) return false; // let Mana Shield soak it first

me = id; n = 0; ax = 0; ay = 0;
with(obj_unit) {
    if(_faction != me._faction && !dead && !_polymorphed && !_stunned && _target == me && _jobclass != class_mirrorimage) {
        if(point_distance(x, y, me.x, me.y) <= range_melee + 8) {
            n += 1; ax += x; ay += y;
        }
    }
}
if(n == 0) return false;

// Away from the attackers; if that runs into the edge of the field, swing around until it fits
dir = point_direction(ax / n, ay / n, x, y);
margin = 24;
ok = false;
for(k = 0; k < 7 && !ok; k += 1) {
    tries = dir + (((k + 1) div 2) * 30) * (1 - 2 * (k mod 2));
    nx = x + cos(degtorad(tries)) * _blink_distance;
    ny = y - sin(degtorad(tries)) * _blink_distance;
    if(nx > margin && nx < room_width - margin && ny > margin && ny < room_height - margin) ok = true;
}
if(!ok) {
    nx = max(margin, min(room_width - margin, x + cos(degtorad(dir)) * _blink_distance));
    ny = max(margin, min(room_height - margin, y - sin(degtorad(dir)) * _blink_distance));
}

// Decoy where I was standing
create_mirror_image(x, y);
create_text_effect(x, y, c_aqua, "-blink-");
caster_blink_fx(x, y, nx, ny);

x = nx; y = ny;
_destx = x; _desty = y;
depth = -y;

if(!_evocation_casting) {
    if(_blizzard_casting) _blizzard_cooldown = _blizzard_cooldown_time;
    _casting = false;
    _polymorph_casting = false;
    _blizzard_casting = false;
    _attackcastwait = 0;
    _attackcasttime = _normal_attackcasttime;
    _target = -1;
}
unit_mana(id, -_blink_manacost);
_blink_cooldown = _blink_cooldown_time;
return true;
