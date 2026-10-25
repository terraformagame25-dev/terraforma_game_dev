/// @func scr_recompute_village_bounds(_village_id)
/// @desc Recomputes a village's bounding box from its claimed tiles.
///       Also updates cx, cy, and radius as derived values.
function scr_recompute_village_bounds(_village_id)
{
    var _v = global.villages[_village_id];
    var _w = obj_world.world_width;

    var _kingdom = global.kingdoms[_v.kingdom_id];
    var _max_r   = scr_advancement_max_radius(_kingdom.advancement_level);
    var _pad     = _max_r + 2;

    var _scan_min_x = max(0, _v.cx - _pad);
    var _scan_max_x = min(_w - 1, _v.cx + _pad);
    var _scan_min_y = max(0, _v.cy - _pad);
    var _scan_max_y = min(obj_world.world_height - 1, _v.cy + _pad);

    var _found_any = false;
    var _min_x = 999999, _max_x = -999999;
    var _min_y = 999999, _max_y = -999999;

    for (var _gy = _scan_min_y; _gy <= _scan_max_y; _gy++)
    {
        for (var _gx = _scan_min_x; _gx <= _scan_max_x; _gx++)
        {
            if (obj_world.territory_grid[_gx + _gy * _w] == _village_id)
            {
                _found_any = true;
                if (_gx < _min_x) _min_x = _gx;
                if (_gx > _max_x) _max_x = _gx;
                if (_gy < _min_y) _min_y = _gy;
                if (_gy > _max_y) _max_y = _gy;
            }
        }
    }

    if (!_found_any)
    {
        _min_x = _v.cx - 3;
        _max_x = _v.cx + 3;
        _min_y = _v.cy - 3;
        _max_y = _v.cy + 3;
    }

    _v.left   = _min_x;
    _v.top    = _min_y;
    _v.right  = _max_x;
    _v.bottom = _max_y;

    _v.cx     = (_v.left + _v.right)  div 2;
    _v.cy     = (_v.top  + _v.bottom) div 2;
    _v.radius = max(_v.right - _v.left, _v.bottom - _v.top) div 2;

    global.villages[_village_id] = _v;
}