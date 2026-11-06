/// @func scr_create_village(_cx, _cy, _radius, _founder_type, _kingdom_id, _is_capital)
function scr_create_village(_cx, _cy, _radius, _founder_type, _kingdom_id = -1, _is_capital = true)
{
    if (_kingdom_id == -1) _kingdom_id = scr_create_kingdom();

    var _ww = obj_world.world_width;
    var _wh = obj_world.world_height;

    // Clamped to the world so bounds loops never index outside the grids
    var _founding_rect = {
        left:   max(0,       _cx - 5),
        right:  min(_ww - 1, _cx + 5),
        top:    max(0,       _cy - 5),
        bottom: min(_wh - 1, _cy + 5),
    };

    var _village = {
        id:           array_length(global.villages),
        kingdom_id:   _kingdom_id,
        name:         scr_generate_kingdom_name(),
        cx:           _cx,
        cy:           _cy,
        radius:       _radius,
        left:         _founding_rect.left,
        top:          _founding_rect.top,
        right:        _founding_rect.right,
        bottom:       _founding_rect.bottom,
        is_capital:   _is_capital,
        founder_type: _founder_type,
        member_ids:   [],
        created_at:   current_time,
        cramped:      false,

        rally_x:      -1,
        rally_y:      -1,
        rally_active: false,
        rally_age:    0,

        resources:     { wood: 0, stone: 0 },
        resource_caps: { wood: 500, stone: 500 },

        construction_id: noone,
        building_id:     noone,
        building_list:   [],

        territory_rects: [_founding_rect],
        expansion_request: false,

        origin_cx: _cx,
        origin_cy: _cy,
    };

    array_push(global.villages, _village);

    var _vid = _village.id;
    var _w   = _ww;

    // Claim founding tiles safely
    for (var _gy = _founding_rect.top; _gy <= _founding_rect.bottom; _gy++)
    {
        for (var _gx = _founding_rect.left; _gx <= _founding_rect.right; _gx++)
        {
            var _idx = _gx + _gy * _w;
            if (obj_world.terrain_grid[_idx] == TERRAIN.WATER)  continue;
            if (obj_world.territory_grid[_idx] != -1)           continue;

            obj_world.territory_grid[_idx] = _vid;
        }
    }

    var _k = global.kingdoms[_kingdom_id];
    array_push(_k.village_ids, _village.id);
    if (_is_capital && _k.capital_village_id == -1)
        _k.capital_village_id = _village.id;
    global.kingdoms[_kingdom_id] = _k;

    // Town hall search now accepts the village's own (just claimed) tiles
    scr_place_construction(_vid);
    return _vid;
}
