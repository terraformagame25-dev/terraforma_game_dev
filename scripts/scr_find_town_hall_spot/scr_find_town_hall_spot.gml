/// @func scr_find_town_hall_spot(_cx, _cy)
function scr_find_town_hall_spot(_cx, _cy)
{
    var _w = obj_world.world_width;
    var _h = obj_world.world_height;

    // Search a 10x10 radius around the target point
    for (var _r = 0; _r <= 10; _r++)
    {
        for (var _dy = -_r; _dy <= _r; _dy++)
        {
            for (var _dx = -_r; _dx <= _r; _dx++)
            {
                var _gx = _cx + _dx;
                var _gy = _cy + _dy;

                if (_gx < 1 || _gx >= _w - 1) continue;
                if (_gy < 1 || _gy >= _h - 1) continue;

                // Check a 3x3 area around the spot
                var _valid = true;
                for (var _by = -1; _by <= 1; _by++)
                {
                    for (var _bx = -1; _bx <= 1; _bx++)
                    {
                        var _tx = _gx + _bx;
                        var _ty = _gy + _by;
                        var _idx = _tx + _ty * _w;

                        // Must be empty, no water, and not owned by another village
                        if (obj_world.terrain_grid[_idx] == TERRAIN.WATER) _valid = false;
                        if (obj_world.territory_grid[_idx] != -1) _valid = false;
                        if (obj_world.block_grid[_idx] == 1) _valid = false;

                        if (!_valid) break;
                    }
                    if (!_valid) break;
                }

                if (_valid) return [_gx, _gy];
            }
        }
    }
    return [-1, -1];
}