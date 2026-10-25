/// @func scr_add_territory_strip(_village_id, _target_gx, _target_gy)
/// @desc Adds a rectangular strip to the village's territory, extending
///       from the current bounding box outward to include (_target_gx, _target_gy).
///       Strips are 5 tiles wide perpendicular to the direction of expansion.
function scr_add_territory_strip(_village_id, _target_gx, _target_gy)
{
    var _v = global.villages[_village_id];
    var _strip_half = 2;

    var _cur_left   = _v.left;
    var _cur_top    = _v.top;
    var _cur_right  = _v.right;
    var _cur_bottom = _v.bottom;

    // Overshoot on each axis
    var _ox = 0;
    var _oy = 0;

    if (_target_gx < _cur_left)   _ox = _target_gx - _cur_left;
    if (_target_gx > _cur_right)  _ox = _target_gx - _cur_right;
    if (_target_gy < _cur_top)    _oy = _target_gy - _cur_top;
    if (_target_gy > _cur_bottom) _oy = _target_gy - _cur_bottom;

    if (_ox == 0 && _oy == 0) return;   // inside, no expansion

    var _strip;

    if (abs(_ox) >= abs(_oy))
    {
        // Horizontal strip (east/west)
        if (_ox < 0)
        {
            _strip = {
                left:   _target_gx,
                right:  _cur_left - 1,
                top:    max(_target_gy - _strip_half, _cur_top),
                bottom: min(_target_gy + _strip_half, _cur_bottom),
            };
        }
        else
        {
            _strip = {
                left:   _cur_right + 1,
                right:  _target_gx,
                top:    max(_target_gy - _strip_half, _cur_top),
                bottom: min(_target_gy + _strip_half, _cur_bottom),
            };
        }
    }
    else
    {
        // Vertical strip (north/south)
        if (_oy < 0)
        {
            _strip = {
                left:   max(_target_gx - _strip_half, _cur_left),
                right:  min(_target_gx + _strip_half, _cur_right),
                top:    _target_gy,
                bottom: _cur_top - 1,
            };
        }
        else
        {
            _strip = {
                left:   max(_target_gx - _strip_half, _cur_left),
                right:  min(_target_gx + _strip_half, _cur_right),
                top:    _cur_bottom + 1,
                bottom: _target_gy,
            };
        }
    }

    // Clamp to advancement max radius
    var _kingdom = global.kingdoms[_v.kingdom_id];
    var _max_r = scr_advancement_max_radius(_kingdom.advancement_level);

    _strip.left   = max(_strip.left,   _v.cx - _max_r);
    _strip.right  = min(_strip.right,  _v.cx + _max_r);
    _strip.top    = max(_strip.top,    _v.cy - _max_r);
    _strip.bottom = min(_strip.bottom, _v.cy + _max_r);

    // Reject if empty
    if (_strip.right < _strip.left) return;
    if (_strip.bottom < _strip.top) return;

    // Add strip
    array_push(_v.territory_rects, _strip);
    global.villages[_village_id] = _v;

    // Sync to territory_grid
    var _w = obj_world.world_width;
    for (var _gy = _strip.top; _gy <= _strip.bottom; _gy++)
    {
        for (var _gx = _strip.left; _gx <= _strip.right; _gx++)
        {
            if (_gx < 0 || _gx >= obj_world.world_width)  continue;
            if (_gy < 0 || _gy >= obj_world.world_height) continue;

            var _idx = _gx + _gy * _w;

            if (obj_world.terrain_grid[_idx] == TERRAIN.WATER) continue;
            if (obj_world.block_grid[_idx]   == 1)             continue;
            if (obj_world.territory_grid[_idx] != -1)          continue;

            obj_world.territory_grid[_idx] = _village_id;
        }
    }

    // Update bounds
    scr_recompute_bounds_from_rects(_village_id);
}