/// scr_tile_is_roamable(unit, gx, gy, allow_resource = false)
function scr_tile_is_roamable(_unit, _gx, _gy, _allow_resource = false)
{
    if (_gx < 0 || _gx >= obj_world.world_width)  return false;
    if (_gy < 0 || _gy >= obj_world.world_height) return false;

    var _idx = _gx + _gy * obj_world.world_width;

    if (obj_world.terrain_grid[_idx] == TERRAIN.WATER) return false;

    if (obj_world.block_grid[_idx] == 1)
    {
        if (!_allow_resource) return false;

        // Only resource tiles are excusable
        var _res = obj_world.resource_grid[_idx];
        if (_res != RESOURCE.TREE && _res != RESOURCE.STONE) return false;
    }

    return true;
}