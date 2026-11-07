// zio_rift_fx(progress, done);
// Nightmare: a dark rift tears open high above Zio while he calls Dark Force, tendrils lashing out of it
// (progress 0..1); when it's done, a burst as Dark Force comes through. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var k, p, h, a;
k = argument0; h = 125;
if(!argument1) {
    with(fx_make(0, x, y, h, make_color_rgb(20, 0, 32), 0.9 + 1.8 * k, 8)) { _add = false; _grow = 1.1; _alpha = 0.85; _dz = 400; }
    with(fx_make(0, x, y, h, make_color_rgb(150, 60, 230), 0.35 + 0.8 * k, 8)) { _grow = 1.2; _dz = 400; }
    if(irandom(1) == 0) {
        a = random(360);
        p = fx_make(5, x + lengthdir_x(25 + 40 * k, a), y + lengthdir_y(14 + 20 * k, a), h, make_color_rgb(110, 30, 170), 0.22, 10);
        p._x1 = x; p._y1 = y; p._h1 = h; p._dz = 400;
    }
}
else {
    with(fx_make(1, x, y, h, make_color_rgb(170, 80, 255), 2.4, 18)) { _squash = 1; _dz = 400; }
    with(fx_make(0, x, y, h, make_color_rgb(20, 0, 32), 2.2, 22)) { _add = false; _grow = 0.5; _alpha = 0.9; _dz = 400; }
    repeat(12) {
        p = fx_make(3, x, y, h, make_color_rgb(120, 50, 190), random_range(0.3, 0.45), 24);
        p._vx = random_range(-2.5, 2.5); p._vy = random_range(-1, 1); p._vh = random_range(-1.5, 1.5);
        p._spin = random_range(-15, 15); p.image_angle = random(360); p._dz = 400;
    }
}
