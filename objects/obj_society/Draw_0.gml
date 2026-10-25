var _ts = obj_world.tile_size;

for (var _i = 0; _i < array_length(global.villages); _i++)
{
    var _v = global.villages[_i];
    var _k = global.kingdoms[_v.kingdom_id];
    var _color = _k.color;

    scr_draw_village_territory(_i, _color);
}