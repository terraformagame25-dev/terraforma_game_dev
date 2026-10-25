if (state == "construction")
{
    draw_self();
    exit;
}

var _body = scr_get_building_sprite(building_type, level, false);
var _roof = scr_get_building_sprite(building_type, level, true);

if (_body == -1)
{
    draw_self();
    exit;
}

// Kingdom color for roof tinting
var _kcol = c_white;
if (village_id != -1)
{
    var _k_id = global.villages[village_id].kingdom_id;
    if (_k_id != -1 && _k_id < array_length(global.kingdoms))
    {
        _kcol = global.kingdoms[_k_id].color;
    }
}

// Body
draw_sprite_ext(_body, image_index, x, y, image_xscale, 1, 0, c_white, 1);

// Roof (tinted with kingdom color)
if (_roof != -1)
{
    draw_sprite_ext(_roof, image_index, x, y, image_xscale, 1, 0, _kcol, 1);
}