// (gm-revive overrides) hold a class key and click to spawn; J (Paladin) added
if(keyboard_check(ord('A'))) create_unit(mouse_x, mouse_y, class_warrior, "Alliance");
if(keyboard_check(ord('S'))) create_unit(mouse_x, mouse_y, class_caster, "Alliance");
if(keyboard_check(ord('D'))) create_unit(mouse_x, mouse_y, class_healer, "Alliance");
if(keyboard_check(ord('F'))) create_unit(mouse_x, mouse_y, class_shaman, "Alliance");
if(keyboard_check(ord('G'))) create_unit(mouse_x, mouse_y, class_rogue, "Alliance");
if(keyboard_check(ord('H'))) create_unit(mouse_x, mouse_y, class_druid, "Alliance");
if(keyboard_check(ord('J'))) create_unit(mouse_x, mouse_y, class_paladin, "Alliance");
