/// @func scr_create_village(_cx, _cy, _radius, _founder_type, _kingdom_id, _is_capital)
function scr_create_village(_cx, _cy, _radius, _founder_type, _kingdom_id = -1, _is_capital = true)
{
    if (_kingdom_id == -1) _kingdom_id = scr_create_kingdom();

    var _founding_rect = {
        left:   _cx - 5,
        right:  _cx + 5,
        top:    _cy - 5,
        bottom: _cy + 5,
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
    var _w   = obj_world.world_width;

    // Claim founding tiles safely
    for (var _gy = _founding_rect.top; _gy <= _founding_rect.bottom; _gy++)
    {
        for (var _gx = _founding_rect.left; _gx <= _founding_rect.right; _gx++)
        {
            if (_gx < 0 || _gx >= obj_world.world_width)  continue;
            if (_gy < 0 || _gy >= obj_world.world_height) continue;

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

    scr_place_construction(_vid);
    return _vid;
}