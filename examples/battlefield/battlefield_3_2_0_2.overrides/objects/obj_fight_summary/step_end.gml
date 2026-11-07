_t += 1;
if(_t > _delay + room_speed * 0.5 && mouse_check_button_pressed(mb_left)) { instance_destroy(); exit; }
if(_t > _delay + _life) instance_destroy();
