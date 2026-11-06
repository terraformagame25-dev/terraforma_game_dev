/// @func scr_find_town_hall_spot(_cx, _cy, _own_village = -1)
/// @desc Finds the nearest valid 3x3 spot (returns the CENTRE tile) around
///       (_cx, _cy). Searches outward ring by ring so the closest spot wins.
///       Tiles already owned by _own_village are allowed, so a village can place
///       its own town hall inside the territory it just claimed. Tiles owned by
///       any other village are rejected.
function scr_find_town_hall_spot(_cx, _cy, _own_village = -1)
{
    var _w = obj_world.world_width;
    var _h = obj_world.world_height;

    for (var _r = 0; _r <= 10; _r++)
    {
        for (var _dy = -_r; _dy <= _r; _dy++)
        {
            for (var _dx = -_r; _dx <= _r; _dx++)
            {
                // Ring only: skip the interior, which earlier rings already tested
                if (max(abs(_dx), abs(_dy)) != _r) continue;

                var _gx = _cx + _dx;
                var _gy = _cy + _dy;

                if (_gx < 1 || _gx >= _w - 1) continue;
                if (_gy < 1 || _gy >= _h - 1) continue;

                var _valid = true;
                for (var _by = -1; _by <= 1 && _valid; _by++)
                {
                    for (var _bx = -1; _bx <= 1 && _valid; _bx++)
                    {
                        var _idx = (_gx + _bx) + (_gy + _by) * _w;

                        if (obj_world.terrain_grid[_idx] == TERRAIN.WATER) _valid = false;
                        if (obj_world.block_grid[_idx] == 1)               _valid = false;

                        var _t = obj_world.territory_grid[_idx];
                        if (_t != -1 && _t != _own_village)                _valid = false;
                    }
                }

                if (_valid) return [_gx, _gy];
            }
        }
    }
    return [-1, -1];
}
