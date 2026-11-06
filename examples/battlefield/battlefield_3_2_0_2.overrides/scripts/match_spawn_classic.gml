// match_spawn_classic();
// The original Battlefield army: 30 units a side of fixed classes, placed anywhere on the field.
// (Moved here unchanged from obj_battlefield's create event.)
////////////////////////////////////////////////////////////////////////////////////////////
var i;

for(i = 0;i < 8; i += 1) {
    create_unit(random(room_width), random(room_height), class_warrior, "Alliance");
    create_unit(random(room_width), random(room_height),  class_warrior, "Horde");
}

for(i = 0;i < 5; i += 1) {
    create_unit(random(room_width), random(room_height), class_caster, "Alliance");
    create_unit(random(room_width), random(room_height), class_caster, "Horde");
}

for(i = 0;i < 4; i += 1) {
    create_unit(random(room_width), random(room_height), class_healer, "Alliance");
    create_unit(random(room_width), random(room_height), class_healer, "Horde");
}

for(i = 0;i < 4; i += 1) {
    create_unit(random(room_width), random(room_height), class_shaman, "Alliance");
    create_unit(random(room_width), random(room_height), class_shaman, "Horde");
}

for(i = 0;i < 3; i += 1) {
    create_unit(random(room_width), random(room_height), class_rogue, "Alliance");
    create_unit(random(room_width), random(room_height), class_rogue, "Horde");
}

for(i = 0;i < 2; i += 1) {
    create_unit(random(room_width), random(room_height), class_druid, "Alliance");
    create_unit(random(room_width), random(room_height), class_druid, "Horde");
}

for(i = 0;i < 4; i += 1) {
    create_unit(random(room_width), random(room_height), class_paladin, "Alliance");
    create_unit(random(room_width), random(room_height), class_paladin, "Horde");
}

