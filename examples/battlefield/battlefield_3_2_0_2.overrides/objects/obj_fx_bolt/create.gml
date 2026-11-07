// A bolt of dark energy (gm-revive overrides): Zio's Black Wave and Dark Force's Supreme Black Wave. A
// jagged violet-black bolt from (_x1, _y1, height _h1) to (_x2, _y2, height _h2) that re-forks every
// couple of steps and fades over _maxlife steps; _w scales its width (Supreme Black Wave's pillar is 3).
_x1 = x; _y1 = y; _h1 = 0;
_x2 = x; _y2 = y; _h2 = 0;
_life = 0;
_maxlife = 14;
_w = 1;
_n = 10;
_jag = 7;
_c0 = make_color_rgb(30, 0, 45);     // outer smoke
_c1 = make_color_rgb(140, 50, 215);  // body
_c2 = make_color_rgb(225, 190, 255); // core (additive)
image_speed = 0;
