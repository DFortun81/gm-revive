// arena_of(object_index);
// Which boss encounter (0-7, see arena_init) an object is, or -1. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var k;
arena_init();
for(k = 0; k < 8; k += 1) if(global.arena_obj[k] == argument0) return k;
return -1;
