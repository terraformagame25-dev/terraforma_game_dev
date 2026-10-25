/// @func scr_rect_can_place_building(_v, _left, _top, _right, _bottom)
/// @desc Returns true if a building occupying the tile rect
///       (_left, _top) to (_right, _bottom) [inclusive] can be placed.
///       All tiles must be non-water, non-resource, non-blocked,
///       and inside the village territory.
function scr_rect_can_place_building(_v, _left, _top, _right, _bottom)
{
    var _w = obj_world.world_width;

    for (var _gy = _top; _gy <= _bottom; _gy++)
    {
        for (var _gx = _left; _gx <= _right; _gx++)
        {
            if (_gx < 0 || _gx >= obj_world.world_width)  return false;
            if (_gy < 0 || _gy >= obj_world.world_height) return false;

            var _idx = _gx + _gy * _w;

            if (obj_world.terrain_grid[_idx] == TERRAIN.WATER)  return false;
            if (obj_world.resource_grid[_idx] != RESOURCE.NONE) return false;
            if (obj_world.block_grid[_idx]   == 1)              return false;

            if (!scr_tile_in_union(_v, _gx, _gy))               return false;
        }
    }

    return true;
}