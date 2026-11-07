// fx_path_bolts(path, style);
// Draws a spell that runs along a path of points (heights in each point's speed), the way the game's
// lightning and Chain Heal paths are built, and deletes the path (gm-revive overrides). Style 0: a crackling
// blue-white lightning bolt from point to point with a burst of sparks where it lands (Lightning Bolt,
// Chain Lightning). Style 1: a ribbon of healing water arcing from one ally to the next (Chain Heal).
// (They were thin flickering lines.)
////////////////////////////////////////////////////////////////////////////////////////////
var pth, st, n, i, b, x1, y1, h1, x2, y2, h2, p;
pth = argument0; st = argument1;
n = path_get_number(pth);
for(i = 1; i < n; i += 1) {
    x1 = path_get_point_x(pth, i - 1); y1 = path_get_point_y(pth, i - 1); h1 = path_get_point_speed(pth, i - 1);
    x2 = path_get_point_x(pth, i); y2 = path_get_point_y(pth, i); h2 = path_get_point_speed(pth, i);
    b = instance_create(x2, y2, obj_fx_bolt);
    b._x1 = x1; b._y1 = y1; b._h1 = h1; b._x2 = x2; b._y2 = y2; b._h2 = h2;
    if(st == 0) {
        b._c0 = make_color_rgb(10, 30, 90); b._c1 = make_color_rgb(90, 170, 255); b._c2 = make_color_rgb(235, 245, 255);
        b._w = 0.75; b._maxlife = 10;
        with(fx_make(0, x2, y2, h2, make_color_rgb(170, 215, 255), 0.7, 8)) _grow = 1.6;
        repeat(4) { p = fx_make(2, x2, y2, h2, make_color_rgb(200, 230, 255), 0.22, 10); p._vx = random_range(-1.6, 1.6); p._vh = random_range(-1, 1.4); }
    }
    else {
        // softer and greener than lightning: a smooth arc of water, barely forked
        b._c0 = make_color_rgb(10, 80, 50); b._c1 = make_color_rgb(70, 220, 150); b._c2 = make_color_rgb(225, 255, 235);
        b._w = 0.55; b._jag = 1.5; b._n = 10; b._maxlife = 18;
    }
}
path_delete(pth);
