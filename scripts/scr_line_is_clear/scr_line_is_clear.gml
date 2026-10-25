/// @func scr_line_is_clear(_x0, _y0, _x1, _y1)
/// @desc Bresenham line check. Returns true if every tile between
///       (_x0,_y0) and (_x1,_y1) [exclusive of start, inclusive of end]
///       is walkable — not water, not blocked (resources, buildings).
function scr_line_is_clear(_x0, _y0, _x1, _y1)
{
    var _w       = obj_world.world_width;
    var _h       = obj_world.world_height;
    var _terrain = obj_world.terrain_grid;
    var _block   = obj_world.block_grid;

    var _dx = abs(_x1 - _x0);
    var _dy = abs(_y1 - _y0);

    var _sx = (_x0 < _x1) ? 1 : -1;
    var _sy = (_y0 < _y1) ? 1 : -1;

    var _err = _dx - _dy;
    var _cx  = _x0;
    var _cy  = _y0;

    while (true)
    {
        if (_cx < 0 || _cx >= _w) return false;
        if (_cy < 0 || _cy >= _h) return false;

        // Skip the starting tile (the unit is already standing on it)
        if (!(_cx == _x0 && _cy == _y0))
        {
            var _idx = _cx + _cy * _w;

            if (_terrain[_idx] == TERRAIN.WATER) return false;
            if (_block[_idx]   == 1)             return false;
        }

        // Reached the goal
        if (_cx == _x1 && _cy == _y1) return true;

        var _e2 = 2 * _err;
        if (_e2 > -_dy) { _err -= _dy; _cx += _sx; }
        if (_e2 <  _dx) { _err += _dx; _cy += _sy; }
    }

    return true;
}