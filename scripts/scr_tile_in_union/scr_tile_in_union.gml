/// @func scr_tile_in_union(_v, _gx, _gy)
/// @desc Returns true if the tile is claimed by this village.
///       territory_grid is the single source of truth for ownership.
function scr_tile_in_union(_v, _gx, _gy)
{
    if (_gx < 0 || _gx >= obj_world.world_width)  return false;
    if (_gy < 0 || _gy >= obj_world.world_height) return false;
    return (obj_world.territory_grid[_gx + _gy * obj_world.world_width] == _v.id);
}
