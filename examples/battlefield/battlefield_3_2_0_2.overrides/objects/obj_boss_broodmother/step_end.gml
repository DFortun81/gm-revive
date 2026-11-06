var n, k, b, side, sx, sy, mx, my;
event_inherited();
if(dead || global.toggle_pause || !_fight_started || !units_exists(_target)) exit;
if(_message_timer > 0) {
    _message_timer -= 1;
    if(_message_timer <= 0) _message = "";
}
_brood_cooldown -= 1;
if(_brood_cooldown > 0) exit;

// Call a wave in from around the edges of the field (each broodling from its own spot, keeping
// clear of the unit panels down both sides of the screen); faster once enraged
n = _brood_base + ds_list_size(_enemylist) div 5;
mx = 70; my = 40;
for(k = 0; k < n; k += 1) {
    side = irandom(3);
    if(side == 0) { sx = random_range(mx, room_width - mx); sy = my; }
    else if(side == 1) { sx = random_range(mx, room_width - mx); sy = room_height - my; }
    else if(side == 2) { sx = mx; sy = random_range(my, room_height - my); }
    else { sx = room_width - mx; sy = random_range(my, room_height - my); }
    b = instance_create(sx, sy, obj_broodling);
    with(b) {
        _faction = other._faction;
        _mother = other.id;
        depth = -y;
    }
    with(instance_create(sx, sy, obj_pulse)) {
        image_blend = make_color_rgb(255, 140, 40);
        _range = 24;
    }
}
_broodlings_hatched += n;
create_text_effect(x, y, c_orange, "-the brood answers-");
_message = "Come, my children!";
_message_timer = room_speed * 2;
_brood_cooldown = _brood_cooldown_time / _enrage_mult;
