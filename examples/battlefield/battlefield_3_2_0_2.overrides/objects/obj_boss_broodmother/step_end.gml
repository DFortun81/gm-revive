var n, k, a, b;
event_inherited();
if(dead || global.toggle_pause || !_fight_started || !units_exists(_target)) exit;
_brood_cooldown -= 1;
if(_brood_cooldown > 0) exit;

// Hatch a wave around the Broodmother; faster once enraged
n = _brood_base + ds_list_size(_enemylist) div 5;
for(k = 0; k < n; k += 1) {
    a = degtorad(k * 360 / n + random(30));
    b = instance_create(x + cos(a) * 28, y - sin(a) * 28, obj_broodling);
    with(b) {
        _faction = other._faction;
        _mother = other.id;
        depth = -y;
    }
}
_broodlings_hatched += n;
create_text_effect(x, y, c_orange, "-brood hatches-");
_brood_cooldown = _brood_cooldown_time / _enrage_mult;
