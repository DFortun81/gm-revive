// fx_spell(target, name);
// The impact effect for a spell or special attack landing on target, cast by the calling unit
// (gm-revive overrides). name: "sinister strike", "kick", "crusader strike", "ferocious bite",
// "swipe", "smite", "shadow word: pain", "prayer of healing", "judgement", "hammer of justice",
// "earth shock", "frost shock", "consecration".
////////////////////////////////////////////////////////////////////////////////////////////
var t, h, p, d, i, a, sp, gold, n;
t = argument0;
if(!instance_exists(t)) exit;
h = t.sprite_height * 0.5;
d = point_direction(x, y, t.x, t.y);
gold = make_color_rgb(255, 205, 70);
switch(argument1) {
    case "sinister strike":
        p = fx_make(7, t.x, t.y, h, c_white, 1, 12); p.image_angle = d + 50 + random(30); p._dz = 3;
        p = fx_make(0, t.x, t.y, h, c_white, 0.35, 6);
    break;
    case "kick":
        // a star of impact and the target's spell breaking apart
        p = fx_make(6, t.x, t.y, h * 1.3, c_white, 0.45, 10); p._spin = 20;
        repeat(6) {
            a = random(360); sp = random_range(0.8, 1.6);
            p = fx_make(3, t.x, t.y, h * 1.4, make_color_rgb(170, 110, 255), 0.28, 16);
            p._vx = lengthdir_x(sp, a); p._vy = lengthdir_y(sp, a) * 0.5; p._vh = random_range(0, 1.2); p._spin = 20; p.image_angle = random(360);
        }
    break;
    case "crusader strike":
        p = fx_make(7, t.x, t.y, h, gold, 1.05, 12); p.image_angle = d + 60; p._dz = 3;
        p = fx_make(7, t.x, t.y, h, make_color_rgb(255, 240, 170), 0.8, 10); p.image_angle = d - 60; p._dz = 3;
        p = fx_make(0, t.x, t.y, h, gold, 0.8, 12);
    break;
    case "ferocious bite":
        // two crossing rakes
        p = fx_make(7, t.x, t.y, h, make_color_rgb(220, 30, 20), 1.05, 13); p.image_angle = d + 45; p._dz = 3; p._add = false;
        p = fx_make(7, t.x, t.y, h, make_color_rgb(220, 30, 20), 1.05, 13); p.image_angle = d - 45; p._dz = 3; p._add = false;
        p = fx_make(0, t.x, t.y, h, make_color_rgb(255, 120, 60), 0.45, 8);
    break;
    case "swipe":
        // a wide arc in front of the Druid, sweeping across whatever it's facing
        for(i = -1; i <= 1; i += 1) {
            p = fx_make(7, x + lengthdir_x(24, d + i * 35), y + lengthdir_y(24, d + i * 35) * 0.6, sprite_height * 0.45, make_color_rgb(255, 205, 130), 1.3, 12 + abs(i) * 2);
            p.image_angle = d + i * 35; p._dz = 3;
        }
    break;
    case "smite":
        // a shaft of light comes down on the target
        p = fx_make(5, t.x, t.y, 2, gold, 0.5, 14); p._x1 = t.x; p._y1 = t.y; p._h1 = h + 60;
        p = fx_make(0, t.x, t.y, h, make_color_rgb(255, 235, 150), 0.9, 14);
        with(fx_make(1, t.x, t.y, 0, gold, 1.1, 14)) _squash = 0.5;
    break;
    case "shadow word: pain":
        p = fx_make(0, t.x, t.y, h, make_color_rgb(120, 40, 170), 0.9, 16); p._add = false; p._grow = 1.6;
        repeat(4) { p = fx_make(0, t.x + random_range(-6, 6), t.y, random(h * 1.6), make_color_rgb(90, 20, 140), 0.35, 24); p._add = false; p._vh = 0.4; p._alpha = 0.7; }
        with(instance_create(t.x, t.y, obj_fx_aura)) { _master = t; _kind = 4; _src = other.id; }
    break;
    case "prayer of healing":
        // called for each ally it heals
        with(fx_make(1, t.x, t.y, 0, gold, 1.5, 20)) _squash = 0.5;
        p = fx_make(0, t.x, t.y, h, make_color_rgb(255, 230, 130), 0.8, 16);
        repeat(4) { p = fx_make(2, t.x + random_range(-9, 9), t.y, random_range(2, h), make_color_rgb(255, 225, 120), 0.42, 24); p._vh = 0.6; }
    break;
    case "judgement":
        // a hammer of light falls on the target
        p = fx_make(5, t.x, t.y, h, make_color_rgb(255, 225, 110), 0.65, 12); p._x1 = t.x; p._y1 = t.y; p._h1 = h + 46;
        p = fx_make(6, t.x, t.y, h, gold, 0.6, 14); p._spin = 12;
        p = fx_make(0, t.x, t.y, h, make_color_rgb(255, 240, 180), 1, 12);
        repeat(5) {
            a = random(360); sp = random_range(1, 2);
            p = fx_make(2, t.x, t.y, h, gold, 0.3, 16); p._vx = lengthdir_x(sp, a); p._vy = lengthdir_y(sp, a) * 0.5; p._vh = random_range(-0.5, 1); p._drag = 0.9;
        }
    break;
    case "hammer of justice":
        p = fx_make(6, t.x, t.y, t.sprite_height + 2, gold, 0.7, 16); p._spin = 15; p._vh = -2;
        p = fx_make(0, t.x, t.y, h * 1.4, make_color_rgb(255, 230, 140), 0.8, 12);
    break;
    case "earth shock":
        // the ground cracks under the target: rocks and dust
        with(fx_make(1, t.x, t.y, 0, make_color_rgb(110, 75, 40), 1.4, 16)) { _squash = 0.5; _add = false; }
        repeat(7) {
            a = random(360); sp = random_range(0.6, 1.6);
            p = fx_make(3, t.x, t.y, 2, make_color_rgb(95, 62, 32), random_range(0.45, 0.6), 24 + irandom(8)); p._add = false;
            p._vx = lengthdir_x(sp, a); p._vy = lengthdir_y(sp, a) * 0.5; p._vh = random_range(1.5, 2.8); p._grav = 0.18; p._spin = random_range(-15, 15); p.image_angle = random(360);
        }
        repeat(4) { p = fx_make(0, t.x + random_range(-9, 9), t.y, 3, make_color_rgb(150, 115, 75), 0.65, 26); p._add = false; p._vh = 0.3; p._alpha = 0.75; }
    break;
    case "frost shock":
        p = fx_make(0, t.x, t.y, h, make_color_rgb(140, 210, 255), 0.9, 14);
        repeat(7) {
            a = random(360); sp = random_range(0.7, 1.7);
            p = fx_make(3, t.x, t.y, h, make_color_rgb(150, 220, 255), random_range(0.32, 0.45), 20 + irandom(8));
            p._vx = lengthdir_x(sp, a); p._vy = lengthdir_y(sp, a) * 0.5; p._vh = random_range(0.5, 1.8); p._grav = 0.12; p._spin = random_range(-12, 12); p.image_angle = random(360);
        }
        with(fx_make(1, t.x, t.y, 0, make_color_rgb(170, 230, 255), 1.1, 16)) _squash = 0.5;
    break;
    case "consecration":
        // a few motes of holy light rise from the consecrated ground with each pulse (t is the Paladin)
        n = 3;
        repeat(n) {
            a = random(360); sp = random(_consecration_range * 0.8);
            p = fx_make(2, _consecration_x + lengthdir_x(sp, a), _consecration_y + lengthdir_y(sp, a) * 0.6, 0, make_color_rgb(255, 225, 120), 0.3, 26);
            p._vh = 0.7;
        }
    break;
}
