// (gm-revive overrides) M: sound on -> quiet -> off -> on
global.sound_level -= 1;
if(global.sound_level < 0) global.sound_level = 2;
sound_level_apply();
ini_open("battlefield_settings.ini");
ini_write_real("sound", "level", global.sound_level);
ini_close();
