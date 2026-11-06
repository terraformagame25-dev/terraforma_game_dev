/// @func scr_village_at_tile(gx, gy)
/// @desc Returns the village_id that actually owns this tile, or -1 if none.
///       Reads territory_grid (not bounding boxes), so holes and neighbouring
///       villages' tiles are handled correctly.
function scr_village_at_tile(_gx, _gy)
{
    if (_gx < 0 || _gx >= obj_world.world_width)  return -1;
    if (_gy < 0 || _gy >= obj_world.world_height) return -1;
    return obj_world.territory_grid[_gx + _gy * obj_world.world_width];
}
