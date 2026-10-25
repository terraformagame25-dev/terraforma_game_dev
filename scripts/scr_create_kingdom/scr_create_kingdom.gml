function scr_create_kingdom()
{
    var _hue = irandom(255);
    var _color = make_colour_hsv(_hue, 180, 220);

    var _k = {
        id:                 array_length(global.kingdoms),
        color:              _color,
        name:               scr_generate_kingdom_name(),
        capital_village_id: -1,
        village_ids:        [],
        advancement_level:  1,

        expansion_rally_x:           -1,
        expansion_rally_y:           -1,
        expansion_rally_active:      false,
        expansion_source_village_id: -1,
    };

    array_push(global.kingdoms, _k);
    return _k.id;
}